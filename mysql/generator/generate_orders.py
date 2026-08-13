"""Synthetic order generator.

Inserts N new orders + order_details per run against existing
customers/products, and randomly UPDATEs a few customer addresses
to exercise SCD Type 2 downstream.

Every table touched here has a `modified_at DATETIME ... ON UPDATE
CURRENT_TIMESTAMP` column (01_schema.sql), so MySQL stamps the
change itself - the address UPDATE below just changes columns, it
never has to set modified_at directly.

Usage:
    python -m mysql.generator.generate_orders --orders 50 --address-updates 5
"""
import argparse
import os
import random
from datetime import datetime, timedelta
from decimal import Decimal

import pymysql
from dotenv import load_dotenv
from faker import Faker

load_dotenv()

fake = Faker()

PAYMENT_TYPES = ["Check", "Credit Card", "Cash", "Wire Transfer"]
DISCOUNTS = [0, 0, 0, 0.05, 0.1, 0.15, 0.2]
TAX_RATES = [0, 0.05, 0.0725, 0.08, 0.1]


def _connect() -> pymysql.connections.Connection:
    return pymysql.connect(
        host=os.environ["MYSQL_HOST"],
        port=int(os.environ.get("MYSQL_PORT", 3306)),
        user=os.environ["MYSQL_USER"],
        password=os.environ["MYSQL_PASSWORD"],
        database=os.environ["MYSQL_DATABASE"],
        autocommit=False,
        connect_timeout=10,
        read_timeout=30,
        write_timeout=30,
    )


def _ids(cur, table: str, id_col: str = "id") -> list:
    cur.execute(f"SELECT {id_col} FROM {table}")
    return [row[0] for row in cur.fetchall()]


def _products(cur) -> list:
    cur.execute("SELECT id, list_price FROM products")
    return list(cur.fetchall())


def _insert_order(cur, ctx: dict, min_items: int, max_items: int) -> tuple:
    """Build one synthetic order + its order_details lines, insert both."""
    order_date = fake.date_time_between(start_date="-60d", end_date="now")

    shipped_date = None
    if random.random() < 0.8:
        shipped_date = min(order_date + timedelta(days=random.randint(1, 10)), datetime.now())

    paid_date = None
    if random.random() < 0.7:
        paid_date = min(order_date + timedelta(days=random.randint(0, 5)), datetime.now())

    k = random.randint(min_items, min(max_items, len(ctx["products"])))
    lines = []
    subtotal = Decimal("0")
    for product_id, list_price in random.sample(ctx["products"], k):
        quantity = random.randint(1, 20)
        variance = Decimal(str(round(random.uniform(0.9, 1.1), 4)))
        unit_price = (list_price * variance).quantize(Decimal("0.01"))
        discount = random.choice(DISCOUNTS)
        status_id = random.choice(ctx["detail_status_ids"]) if ctx["detail_status_ids"] else None
        subtotal += quantity * unit_price * (Decimal("1") - Decimal(str(discount)))
        lines.append((product_id, quantity, unit_price, discount, status_id))

    tax_rate = random.choice(TAX_RATES)
    taxes = (subtotal * Decimal(str(tax_rate))).quantize(Decimal("0.01"))
    shipping_fee = Decimal(str(round(random.uniform(0, 50), 2)))

    cur.execute(
        """
        INSERT INTO orders (
            employee_id, customer_id, order_date, shipped_date, shipper_id,
            ship_name, ship_address, ship_city, ship_state_province,
            ship_zip_postal_code, ship_country_region, shipping_fee, taxes,
            payment_type, paid_date, notes, tax_rate, tax_status_id, status_id
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """,
        (
            random.choice(ctx["employee_ids"]) if ctx["employee_ids"] else None,
            random.choice(ctx["customer_ids"]),
            order_date,
            shipped_date,
            random.choice(ctx["shipper_ids"]) if ctx["shipper_ids"] else None,
            fake.company(),
            fake.street_address(),
            fake.city(),
            fake.state(),
            fake.postcode(),
            fake.country(),
            shipping_fee,
            taxes,
            random.choice(PAYMENT_TYPES),
            paid_date,
            fake.sentence() if random.random() < 0.3 else None,
            tax_rate,
            random.choice(ctx["tax_status_ids"]) if ctx["tax_status_ids"] else None,
            random.choice(ctx["order_status_ids"]) if ctx["order_status_ids"] else None,
        ),
    )
    order_id = cur.lastrowid

    cur.executemany(
        """
        INSERT INTO order_details (order_id, product_id, quantity, unit_price, discount, status_id)
        VALUES (%s, %s, %s, %s, %s, %s)
        """,
        [(order_id, pid, qty, price, disc, status_id) for pid, qty, price, disc, status_id in lines],
    )
    return order_id, len(lines)


def _update_customer_addresses(cur, customer_ids: list, n: int) -> list:
    """Move a handful of existing customers to a new address.

    This is the SCD Type 2 trigger: downstream, a dbt snapshot (or
    equivalent) diffs these columns and closes out/opens dimension rows
    when they change. modified_at is bumped automatically by the
    column's ON UPDATE CURRENT_TIMESTAMP (01_schema.sql).
    """
    chosen = random.sample(customer_ids, min(n, len(customer_ids)))
    for customer_id in chosen:
        cur.execute(
            """
            UPDATE customers
            SET address = %s, city = %s, state_province = %s,
                zip_postal_code = %s, country_region = %s
            WHERE id = %s
            """,
            (fake.street_address(), fake.city(), fake.state(), fake.postcode(), fake.country(), customer_id),
        )
    return chosen


def run(orders: int, address_updates: int, min_items: int, max_items: int) -> None:
    conn = _connect()
    try:
        with conn.cursor() as cur:
            ctx = {
                "customer_ids": _ids(cur, "customers"),
                "employee_ids": _ids(cur, "employees"),
                "shipper_ids": _ids(cur, "shippers"),
                "products": _products(cur),
                "order_status_ids": _ids(cur, "orders_status"),
                "tax_status_ids": _ids(cur, "orders_tax_status"),
                "detail_status_ids": _ids(cur, "order_details_status"),
            }

            if not ctx["customer_ids"] or not ctx["products"]:
                raise SystemExit(
                    "customers/products tables are empty - seed the database first (02_seed.sql)."
                )

            order_ids = []
            detail_count = 0
            for _ in range(orders):
                order_id, n_lines = _insert_order(cur, ctx, min_items, max_items)
                order_ids.append(order_id)
                detail_count += n_lines

            updated_customers = _update_customer_addresses(cur, ctx["customer_ids"], address_updates)

        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()

    print(f"Inserted {len(order_ids)} orders / {detail_count} order_details rows.")
    if order_ids:
        print(f"  order ids: {min(order_ids)}..{max(order_ids)}")
    print(f"Updated addresses for {len(updated_customers)} customers: {updated_customers}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Insert synthetic orders + order_details against existing customers/"
            "products, and randomly update a few customer addresses to exercise "
            "SCD Type 2 downstream."
        )
    )
    parser.add_argument("-n", "--orders", type=int, default=20, help="number of new orders to insert (default: 20)")
    parser.add_argument("--min-items", type=int, default=1, help="min order_details lines per order (default: 1)")
    parser.add_argument("--max-items", type=int, default=5, help="max order_details lines per order (default: 5)")
    parser.add_argument(
        "-u", "--address-updates", type=int, default=3,
        help="number of existing customers whose address to randomly change (default: 3)",
    )
    parser.add_argument("--seed", type=int, default=None, help="random seed, for reproducible runs")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if args.seed is not None:
        random.seed(args.seed)
        fake.seed_instance(args.seed)
    run(args.orders, args.address_updates, args.min_items, args.max_items)


if __name__ == "__main__":
    main()
