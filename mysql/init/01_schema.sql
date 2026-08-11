/* =============================================================
   Northwind OLTP - MySQL DDL  (MySQL 5.7+ / 8.x, InnoDB)
   ============================================================= */
DROP DATABASE IF EXISTS northwind_db;
CREATE DATABASE northwind_db
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;
USE northwind_db;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS inventory_transactions;
DROP TABLE IF EXISTS purchase_order_details;
DROP TABLE IF EXISTS purchase_orders;
DROP TABLE IF EXISTS order_details;
DROP TABLE IF EXISTS invoices;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS employee_privileges;
DROP TABLE IF EXISTS shippers;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS privileges;
DROP TABLE IF EXISTS inventory_transaction_types;
DROP TABLE IF EXISTS purchase_order_status;
DROP TABLE IF EXISTS order_details_status;
DROP TABLE IF EXISTS orders_tax_status;
DROP TABLE IF EXISTS orders_status;

SET FOREIGN_KEY_CHECKS = 1;


/* -------------------------------------------------------------
   1. Lookup / reference tables
   ------------------------------------------------------------- */

CREATE TABLE orders_status (
    id           TINYINT      NOT NULL,
    status_name  VARCHAR(50)  NOT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE orders_tax_status (
    id               TINYINT      NOT NULL,
    tax_status_name  VARCHAR(50)  NOT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE order_details_status (
    id           INT          NOT NULL,
    status_name  VARCHAR(50)  NOT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE purchase_order_status (
    id      INT          NOT NULL,
    status  VARCHAR(50),
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE inventory_transaction_types (
    id         TINYINT      NOT NULL,
    type_name  VARCHAR(50)  NOT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE privileges (
    id              INT NOT NULL AUTO_INCREMENT,
    privilege_name  VARCHAR(50),
    PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;


/* -------------------------------------------------------------
   2. Party tables (identical column layout)
   ------------------------------------------------------------- */

CREATE TABLE customers (
    id               INT NOT NULL AUTO_INCREMENT,
    company          VARCHAR(50),
    last_name        VARCHAR(50),
    first_name       VARCHAR(50),
    email_address    VARCHAR(50),
    job_title        VARCHAR(50),
    business_phone   VARCHAR(25),
    home_phone       VARCHAR(25),
    mobile_phone     VARCHAR(25),
    fax_number       VARCHAR(25),
    address          LONGTEXT,
    city             VARCHAR(50),
    state_province   VARCHAR(50),
    zip_postal_code  VARCHAR(15),
    country_region   VARCHAR(50),
    web_page         LONGTEXT,
    notes            LONGTEXT,
    attachments      LONGBLOB,
    PRIMARY KEY (id),
    INDEX ix_customers_city            (city),
    INDEX ix_customers_company         (company),
    INDEX ix_customers_first_name      (first_name),
    INDEX ix_customers_last_name       (last_name),
    INDEX ix_customers_zip_postal_code (zip_postal_code),
    INDEX ix_customers_state_province  (state_province)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE suppliers (
    id               INT NOT NULL AUTO_INCREMENT,
    company          VARCHAR(50),
    last_name        VARCHAR(50),
    first_name       VARCHAR(50),
    email_address    VARCHAR(50),
    job_title        VARCHAR(50),
    business_phone   VARCHAR(25),
    home_phone       VARCHAR(25),
    mobile_phone     VARCHAR(25),
    fax_number       VARCHAR(25),
    address          LONGTEXT,
    city             VARCHAR(50),
    state_province   VARCHAR(50),
    zip_postal_code  VARCHAR(15),
    country_region   VARCHAR(50),
    web_page         LONGTEXT,
    notes            LONGTEXT,
    attachments      LONGBLOB,
    PRIMARY KEY (id),
    INDEX ix_suppliers_city            (city),
    INDEX ix_suppliers_company         (company),
    INDEX ix_suppliers_first_name      (first_name),
    INDEX ix_suppliers_last_name       (last_name),
    INDEX ix_suppliers_zip_postal_code (zip_postal_code),
    INDEX ix_suppliers_state_province  (state_province)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE employees (
    id               INT NOT NULL AUTO_INCREMENT,
    company          VARCHAR(50),
    last_name        VARCHAR(50),
    first_name       VARCHAR(50),
    email_address    VARCHAR(50),
    job_title        VARCHAR(50),
    business_phone   VARCHAR(25),
    home_phone       VARCHAR(25),
    mobile_phone     VARCHAR(25),
    fax_number       VARCHAR(25),
    address          LONGTEXT,
    city             VARCHAR(50),
    state_province   VARCHAR(50),
    zip_postal_code  VARCHAR(15),
    country_region   VARCHAR(50),
    web_page         LONGTEXT,
    notes            LONGTEXT,
    attachments      LONGBLOB,
    PRIMARY KEY (id),
    INDEX ix_employees_city            (city),
    INDEX ix_employees_company         (company),
    INDEX ix_employees_first_name      (first_name),
    INDEX ix_employees_last_name       (last_name),
    INDEX ix_employees_zip_postal_code (zip_postal_code),
    INDEX ix_employees_state_province  (state_province)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE shippers (
    id               INT NOT NULL AUTO_INCREMENT,
    company          VARCHAR(50),
    last_name        VARCHAR(50),
    first_name       VARCHAR(50),
    email_address    VARCHAR(50),
    job_title        VARCHAR(50),
    business_phone   VARCHAR(25),
    home_phone       VARCHAR(25),
    mobile_phone     VARCHAR(25),
    fax_number       VARCHAR(25),
    address          LONGTEXT,
    city             VARCHAR(50),
    state_province   VARCHAR(50),
    zip_postal_code  VARCHAR(15),
    country_region   VARCHAR(50),
    web_page         LONGTEXT,
    notes            LONGTEXT,
    attachments      LONGBLOB,
    PRIMARY KEY (id),
    INDEX ix_shippers_city            (city),
    INDEX ix_shippers_company         (company),
    INDEX ix_shippers_first_name      (first_name),
    INDEX ix_shippers_last_name       (last_name),
    INDEX ix_shippers_zip_postal_code (zip_postal_code),
    INDEX ix_shippers_state_province  (state_province)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;


/* -------------------------------------------------------------
   3. Bridge table
   ------------------------------------------------------------- */

CREATE TABLE employee_privileges (
    employee_id   INT NOT NULL,
    privilege_id  INT NOT NULL,
    PRIMARY KEY (employee_id, privilege_id),
    INDEX ix_emppriv_privilege_id (privilege_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* -------------------------------------------------------------
   4. Products
   ------------------------------------------------------------- */

CREATE TABLE products (
    supplier_ids             LONGTEXT,
    id                       INT NOT NULL AUTO_INCREMENT,
    product_code             VARCHAR(25),
    product_name             VARCHAR(50),
    description              LONGTEXT,
    standard_cost            DECIMAL(19,4) DEFAULT 0.0000,
    list_price               DECIMAL(19,4) NOT NULL DEFAULT 0.0000,
    reorder_level            INT,
    target_level             INT,
    quantity_per_unit        VARCHAR(50),
    discontinued             TINYINT       NOT NULL DEFAULT 0,
    minimum_reorder_quantity INT,
    category                 VARCHAR(50),
    attachments              LONGBLOB,
    PRIMARY KEY (id),
    INDEX ix_products_product_code (product_code)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;


/* -------------------------------------------------------------
   5. Sales side
   ------------------------------------------------------------- */

CREATE TABLE orders (
    id                    INT NOT NULL AUTO_INCREMENT,
    employee_id           INT,
    customer_id           INT,
    order_date            DATETIME,
    shipped_date          DATETIME,
    shipper_id            INT,
    ship_name             VARCHAR(50),
    ship_address          LONGTEXT,
    ship_city             VARCHAR(50),
    ship_state_province   VARCHAR(50),
    ship_zip_postal_code  VARCHAR(50),
    ship_country_region   VARCHAR(50),
    shipping_fee          DECIMAL(19,4) DEFAULT 0.0000,
    taxes                 DECIMAL(19,4) DEFAULT 0.0000,
    payment_type          VARCHAR(50),
    paid_date             DATETIME,
    notes                 LONGTEXT,
    tax_rate              DOUBLE        DEFAULT 0,
    tax_status_id         TINYINT,
    status_id             TINYINT       DEFAULT 0,
    PRIMARY KEY (id),
    INDEX ix_orders_customer_id   (customer_id),
    INDEX ix_orders_employee_id   (employee_id),
    INDEX ix_orders_shipper_id    (shipper_id),
    INDEX ix_orders_tax_status_id (tax_status_id),
    INDEX ix_orders_status_id     (status_id),
    INDEX ix_orders_ship_zip      (ship_zip_postal_code)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE invoices (
    id            INT NOT NULL AUTO_INCREMENT,
    order_id      INT,
    invoice_date  DATETIME,
    due_date      DATETIME,
    tax           DECIMAL(19,4) DEFAULT 0.0000,
    shipping      DECIMAL(19,4) DEFAULT 0.0000,
    amount_due    DECIMAL(19,4) DEFAULT 0.0000,
    PRIMARY KEY (id),
    INDEX ix_invoices_order_id (order_id)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE order_details (
    id                 INT NOT NULL AUTO_INCREMENT,
    order_id           INT NOT NULL,
    product_id         INT,
    quantity           DECIMAL(18,4) NOT NULL DEFAULT 0.0000,
    unit_price         DECIMAL(19,4) DEFAULT 0.0000,
    discount           DOUBLE        NOT NULL DEFAULT 0,
    status_id          INT,
    date_allocated     DATETIME,
    purchase_order_id  INT,
    inventory_id       INT,
    PRIMARY KEY (id),
    INDEX ix_od_order_id   (order_id),
    INDEX ix_od_product_id (product_id),
    INDEX ix_od_status_id  (status_id),
    INDEX ix_od_inventory_id (inventory_id)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;


/* -------------------------------------------------------------
   6. Purchasing side
   ------------------------------------------------------------- */

CREATE TABLE purchase_orders (
    id              INT NOT NULL AUTO_INCREMENT,
    supplier_id     INT,
    created_by      INT,
    submitted_date  DATETIME,
    creation_date   DATETIME,
    status_id       INT           DEFAULT 0,
    expected_date   DATETIME,
    shipping_fee    DECIMAL(19,4) NOT NULL DEFAULT 0.0000,
    taxes           DECIMAL(19,4) NOT NULL DEFAULT 0.0000,
    payment_date    DATETIME,
    payment_amount  DECIMAL(19,4) DEFAULT 0.0000,
    payment_method  VARCHAR(50),
    notes           LONGTEXT,
    approved_by     INT,
    approved_date   DATETIME,
    submitted_by    INT,
    PRIMARY KEY (id),
    UNIQUE KEY ak_purchase_orders_id (id),
    INDEX ix_po_created_by  (created_by),
    INDEX ix_po_status_id   (status_id),
    INDEX ix_po_supplier_id (supplier_id)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE purchase_order_details (
    id                   INT NOT NULL AUTO_INCREMENT,
    purchase_order_id    INT           NOT NULL,
    product_id           INT,
    quantity             DECIMAL(18,4) NOT NULL,
    unit_cost            DECIMAL(19,4) NOT NULL,
    date_received        DATETIME,
    posted_to_inventory  TINYINT       NOT NULL DEFAULT 0,
    inventory_id         INT,
    PRIMARY KEY (id),
    INDEX ix_pod_inventory_id      (inventory_id),
    INDEX ix_pod_purchase_order_id (purchase_order_id),
    INDEX ix_pod_product_id        (product_id)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;


/* -------------------------------------------------------------
   7. Inventory
   ------------------------------------------------------------- */

CREATE TABLE inventory_transactions (
    id                         INT     NOT NULL AUTO_INCREMENT,
    transaction_type           TINYINT NOT NULL,
    transaction_created_date   DATETIME,
    transaction_modified_date  DATETIME,
    product_id                 INT     NOT NULL,
    quantity                   INT     NOT NULL,
    purchase_order_id          INT,
    customer_order_id          INT,
    comments                   VARCHAR(255),
    PRIMARY KEY (id),
    INDEX ix_it_customer_order_id (customer_order_id),
    INDEX ix_it_product_id        (product_id),
    INDEX ix_it_purchase_order_id (purchase_order_id),
    INDEX ix_it_transaction_type  (transaction_type)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;


/* =============================================================
   8. Foreign keys - ENFORCED in MySQL/InnoDB.
      Added after all tables exist because of the circular
      references between purchase_order_details and
      inventory_transactions.
   ============================================================= */

ALTER TABLE employee_privileges
    ADD CONSTRAINT fk_emppriv_employee  FOREIGN KEY (employee_id)  REFERENCES employees (id),
    ADD CONSTRAINT fk_emppriv_privilege FOREIGN KEY (privilege_id) REFERENCES privileges (id);

ALTER TABLE orders
    ADD CONSTRAINT fk_orders_employee   FOREIGN KEY (employee_id)   REFERENCES employees (id),
    ADD CONSTRAINT fk_orders_customer   FOREIGN KEY (customer_id)   REFERENCES customers (id),
    ADD CONSTRAINT fk_orders_shipper    FOREIGN KEY (shipper_id)    REFERENCES shippers (id),
    ADD CONSTRAINT fk_orders_tax_status FOREIGN KEY (tax_status_id) REFERENCES orders_tax_status (id),
    ADD CONSTRAINT fk_orders_status     FOREIGN KEY (status_id)     REFERENCES orders_status (id);

ALTER TABLE invoices
    ADD CONSTRAINT fk_invoices_order    FOREIGN KEY (order_id)      REFERENCES orders (id);

ALTER TABLE order_details
    ADD CONSTRAINT fk_od_order          FOREIGN KEY (order_id)      REFERENCES orders (id),
    ADD CONSTRAINT fk_od_product        FOREIGN KEY (product_id)    REFERENCES products (id),
    ADD CONSTRAINT fk_od_status         FOREIGN KEY (status_id)     REFERENCES order_details_status (id);

ALTER TABLE purchase_orders
    ADD CONSTRAINT fk_po_supplier       FOREIGN KEY (supplier_id)   REFERENCES suppliers (id),
    ADD CONSTRAINT fk_po_created_by     FOREIGN KEY (created_by)    REFERENCES employees (id),
    ADD CONSTRAINT fk_po_status         FOREIGN KEY (status_id)     REFERENCES purchase_order_status (id);

ALTER TABLE purchase_order_details
    ADD CONSTRAINT fk_pod_po            FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders (id),
    ADD CONSTRAINT fk_pod_product       FOREIGN KEY (product_id)        REFERENCES products (id),
    ADD CONSTRAINT fk_pod_inventory     FOREIGN KEY (inventory_id)      REFERENCES inventory_transactions (id);

ALTER TABLE inventory_transactions
    ADD CONSTRAINT fk_it_type           FOREIGN KEY (transaction_type)  REFERENCES inventory_transaction_types (id),
    ADD CONSTRAINT fk_it_product        FOREIGN KEY (product_id)        REFERENCES products (id),
    ADD CONSTRAINT fk_it_purchase_order FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders (id),
    ADD CONSTRAINT fk_it_customer_order FOREIGN KEY (customer_order_id) REFERENCES orders (id);