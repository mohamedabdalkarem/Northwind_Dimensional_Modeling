"""dlt source definitions for the Northwind MySQL tables (Task 10).

Wraps `dlt.sources.sql_database.sql_database`, which reflects each table
in `TABLE_NAMES` and yields one `DltResource` per table. Column names,
types, and precision are all reflected from MySQL, and dlt evolves the
destination schema automatically as source tables change - no manual
schema/type mapping is defined here.
"""
from typing import Iterable, List, Optional

import dlt
from dlt.common.configuration.specs import ConnectionStringCredentials
from dlt.sources import DltResource
from dlt.sources.sql_database import sql_database

# All 19 tables in the Northwind OLTP schema (mysql/init/01_schema.sql),
# listed explicitly so ingestion scope is self-documenting and doesn't
# silently pick up unrelated tables added later to the same database.
TABLE_NAMES: List[str] = [
    # lookup / reference
    "orders_status",
    "orders_tax_status",
    "order_details_status",
    "purchase_order_status",
    "inventory_transaction_types",
    "privileges",
    # party tables
    "customers",
    "suppliers",
    "employees",
    "shippers",
    "employee_privileges",
    # catalog
    "products",
    # sales side
    "orders",
    "invoices",
    "order_details",
    # purchasing side
    "purchase_orders",
    "purchase_order_details",
    # inventory
    "inventory_transactions",
]


@dlt.source(name="northwind")
def northwind_source(
    credentials: ConnectionStringCredentials = dlt.secrets.value,
    table_names: Optional[List[str]] = None,
) -> Iterable[DltResource]:
    """One dlt resource per Northwind table, reflected straight off MySQL.

    `reflection_level="full_with_precision"` keeps DECIMAL precision/scale
    (eg. `list_price DECIMAL(19,4)`) intact instead of letting dlt infer a
    looser type from sampled data.
    """
    yield from sql_database(
        credentials=credentials,
        table_names=table_names or TABLE_NAMES,
        reflection_level="full_with_precision",
    ).resources.values()
