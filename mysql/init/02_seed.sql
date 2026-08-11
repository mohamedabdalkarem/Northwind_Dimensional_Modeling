/* =============================================================
   Northwind OLTP - Seed data
   Loads the CSVs in /datasets (mounted into the container at
   /var/lib/mysql-files/datasets, see docker-compose.yml) into the
   tables created by 01_schema.sql.

   FK checks are disabled while loading because
   purchase_order_details <-> inventory_transactions reference each
   other (see 01_schema.sql section 8), so no single load order
   satisfies every constraint.
   ============================================================= */
USE northwind_db;

SET FOREIGN_KEY_CHECKS = 0;

/* -------------------------------------------------------------
   1. Lookup / reference tables
   ------------------------------------------------------------- */

LOAD DATA INFILE '/var/lib/mysql-files/datasets/orders_status.csv'
IGNORE INTO TABLE orders_status
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, status_name);

LOAD DATA INFILE '/var/lib/mysql-files/datasets/orders_tax_status.csv'
IGNORE INTO TABLE orders_tax_status
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, tax_status_name);

LOAD DATA INFILE '/var/lib/mysql-files/datasets/order_details_status.csv'
IGNORE INTO TABLE order_details_status
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, status_name);

LOAD DATA INFILE '/var/lib/mysql-files/datasets/purchase_order_status.csv'
IGNORE INTO TABLE purchase_order_status
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, status);

LOAD DATA INFILE '/var/lib/mysql-files/datasets/inventory_transaction_types.csv'
IGNORE INTO TABLE inventory_transaction_types
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, type_name);

LOAD DATA INFILE '/var/lib/mysql-files/datasets/privileges.csv'
IGNORE INTO TABLE privileges
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, privilege_name);


/* -------------------------------------------------------------
   2. Party tables (identical column layout)
   ------------------------------------------------------------- */

LOAD DATA INFILE '/var/lib/mysql-files/datasets/customer.csv'
IGNORE INTO TABLE customers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(id, company, last_name, first_name, email_address, job_title, business_phone,
 home_phone, mobile_phone, fax_number, address, city, state_province,
 zip_postal_code, country_region, web_page, notes, attachments);

LOAD DATA INFILE '/var/lib/mysql-files/datasets/suppliers.csv'
IGNORE INTO TABLE suppliers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, company, last_name, first_name, email_address, job_title, business_phone,
 home_phone, mobile_phone, fax_number, address, city, state_province,
 zip_postal_code, country_region, web_page, notes, attachments);

LOAD DATA INFILE '/var/lib/mysql-files/datasets/employees.csv'
IGNORE INTO TABLE employees
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, company, last_name, first_name, email_address, job_title, business_phone,
 home_phone, mobile_phone, fax_number, address, city, state_province,
 zip_postal_code, country_region, web_page, notes, attachments);

LOAD DATA INFILE '/var/lib/mysql-files/datasets/shippers.csv'
IGNORE INTO TABLE shippers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, company, last_name, first_name, email_address, job_title, business_phone,
 home_phone, mobile_phone, fax_number, address, city, state_province,
 zip_postal_code, country_region, web_page, notes, attachments);


/* -------------------------------------------------------------
   3. Bridge table
   ------------------------------------------------------------- */

LOAD DATA INFILE '/var/lib/mysql-files/datasets/employee_privileges.csv'
IGNORE INTO TABLE employee_privileges
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(employee_id, privilege_id);


/* -------------------------------------------------------------
   4. Products
   ------------------------------------------------------------- */

LOAD DATA INFILE '/var/lib/mysql-files/datasets/products.csv'
IGNORE INTO TABLE products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(supplier_ids, id, product_code, product_name, description, @standard_cost,
 list_price, @reorder_level, @target_level, quantity_per_unit, discontinued,
 @minimum_reorder_quantity, category, attachments)
SET
    standard_cost            = NULLIF(@standard_cost, ''),
    reorder_level             = NULLIF(@reorder_level, ''),
    target_level              = NULLIF(@target_level, ''),
    minimum_reorder_quantity  = NULLIF(@minimum_reorder_quantity, '');


/* -------------------------------------------------------------
   5. Sales side
   ------------------------------------------------------------- */

LOAD DATA INFILE '/var/lib/mysql-files/datasets/orders.csv'
IGNORE INTO TABLE orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, @employee_id, @customer_id, @order_date, @shipped_date, @shipper_id,
 ship_name, ship_address, ship_city, ship_state_province, ship_zip_postal_code,
 ship_country_region, shipping_fee, taxes, payment_type, @paid_date, notes,
 tax_rate, @tax_status_id, @status_id)
SET
    employee_id   = NULLIF(@employee_id, ''),
    customer_id   = NULLIF(@customer_id, ''),
    order_date    = NULLIF(@order_date, ''),
    shipped_date  = NULLIF(@shipped_date, ''),
    shipper_id    = NULLIF(@shipper_id, ''),
    paid_date     = NULLIF(@paid_date, ''),
    tax_status_id = NULLIF(@tax_status_id, ''),
    status_id     = NULLIF(@status_id, '');

LOAD DATA INFILE '/var/lib/mysql-files/datasets/invoices.csv'
IGNORE INTO TABLE invoices
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, @order_id, @invoice_date, @due_date, tax, shipping, amount_due)
SET
    order_id     = NULLIF(@order_id, ''),
    invoice_date = NULLIF(@invoice_date, ''),
    due_date     = NULLIF(@due_date, '');

LOAD DATA INFILE '/var/lib/mysql-files/datasets/order_details.csv'
IGNORE INTO TABLE order_details
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, order_id, @product_id, quantity, unit_price, discount, @status_id,
 @date_allocated, @purchase_order_id, @inventory_id)
SET
    product_id        = NULLIF(@product_id, ''),
    status_id          = NULLIF(@status_id, ''),
    date_allocated      = NULLIF(@date_allocated, ''),
    purchase_order_id  = NULLIF(@purchase_order_id, ''),
    inventory_id        = NULLIF(@inventory_id, '');


/* -------------------------------------------------------------
   6. Purchasing side
   ------------------------------------------------------------- */

LOAD DATA INFILE '/var/lib/mysql-files/datasets/purchase_orders.csv'
IGNORE INTO TABLE purchase_orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, @supplier_id, @created_by, @submitted_date, @creation_date, @status_id,
 @expected_date, shipping_fee, taxes, @payment_date, payment_amount,
 payment_method, notes, @approved_by, @approved_date, @submitted_by)
SET
    supplier_id     = NULLIF(@supplier_id, ''),
    created_by      = NULLIF(@created_by, ''),
    submitted_date  = NULLIF(@submitted_date, ''),
    creation_date   = NULLIF(@creation_date, ''),
    status_id       = NULLIF(@status_id, ''),
    expected_date   = NULLIF(@expected_date, ''),
    payment_date    = NULLIF(@payment_date, ''),
    approved_by     = NULLIF(@approved_by, ''),
    approved_date   = NULLIF(@approved_date, ''),
    submitted_by    = NULLIF(@submitted_by, '');

LOAD DATA INFILE '/var/lib/mysql-files/datasets/purchase_order_details.csv'
IGNORE INTO TABLE purchase_order_details
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, purchase_order_id, @product_id, quantity, unit_cost, @date_received,
 posted_to_inventory, @inventory_id)
SET
    product_id      = NULLIF(@product_id, ''),
    date_received   = NULLIF(@date_received, ''),
    inventory_id    = NULLIF(@inventory_id, '');


/* -------------------------------------------------------------
   7. Inventory
   ------------------------------------------------------------- */

LOAD DATA INFILE '/var/lib/mysql-files/datasets/inventory_transactions.csv'
IGNORE INTO TABLE inventory_transactions
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, transaction_type, @transaction_created_date, @transaction_modified_date,
 product_id, quantity, @purchase_order_id, @customer_order_id, comments)
SET
    transaction_created_date   = NULLIF(@transaction_created_date, ''),
    transaction_modified_date  = NULLIF(@transaction_modified_date, ''),
    purchase_order_id          = NULLIF(@purchase_order_id, ''),
    customer_order_id          = NULLIF(@customer_order_id, '');


SET FOREIGN_KEY_CHECKS = 1;

/* NOTE: datasets/sales_reports.csv and datasets/strings.csv have no
   corresponding table in 01_schema.sql (they're Access-report/UI
   metadata from the original Northwind template) and are intentionally
   not loaded here. */
