-- Raw landing tables + COPY INTO
--
-- One RAW_DB.NORTHWIND table per Northwind source table, landing each row
-- as-is in a VARIANT column. Typing/flattening happens in dbt staging,
-- not here - RAW stays schema-on-read so a source column change doesn't
-- break the load, it just shows up as a new key in raw_data.
--
-- Every raw table has the same four columns:
--   raw_data      VARIANT       - the full row, exactly as dlt wrote it to Parquet
--   _loaded_at    TIMESTAMP_LTZ - when this COPY ran (Snowflake-side, not file mtime)
--   _source_file  VARCHAR       - staged file this row came from (METADATA$FILENAME)
--   _load_id      VARCHAR       - dlt's load_id for the run that produced the row
--                                 (dlt stamps this onto every row as _dlt_load_id;
--                                 it's also the run_id in the S3 file name
--
-- "$1" against a Parquet-backed stage returns the whole row as an OBJECT, so no
-- per-table column list is needed to land it - only to pull the two metadata
-- fields out alongside it.

USE ROLE LOADER;
USE WAREHOUSE LOADING_WH;

-- ----------------------------------------------------------------------------
-- 1. Raw landing tables
-- ----------------------------------------------------------------------------

-- lookup / reference
CREATE TABLE IF NOT EXISTS RAW_DB.NORTHWIND.orders_status (
  raw_data VARIANT NOT NULL, _loaded_at TIMESTAMP_LTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(), _source_file VARCHAR NOT NULL, _load_id VARCHAR NOT NULL);
CREATE TABLE IF NOT EXISTS RAW_DB.NORTHWIND.orders_tax_status (
  raw_data VARIANT NOT NULL, _loaded_at TIMESTAMP_LTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(), _source_file VARCHAR NOT NULL, _load_id VARCHAR NOT NULL);
CREATE TABLE IF NOT EXISTS RAW_DB.NORTHWIND.order_details_status (
  raw_data VARIANT NOT NULL, _loaded_at TIMESTAMP_LTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(), _source_file VARCHAR NOT NULL, _load_id VARCHAR NOT NULL);
CREATE TABLE IF NOT EXISTS RAW_DB.NORTHWIND.purchase_order_status (
  raw_data VARIANT NOT NULL, _loaded_at TIMESTAMP_LTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(), _source_file VARCHAR NOT NULL, _load_id VARCHAR NOT NULL);
CREATE TABLE IF NOT EXISTS RAW_DB.NORTHWIND.inventory_transaction_types (
  raw_data VARIANT NOT NULL, _loaded_at TIMESTAMP_LTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(), _source_file VARCHAR NOT NULL, _load_id VARCHAR NOT NULL);
CREATE TABLE IF NOT EXISTS RAW_DB.NORTHWIND.privileges (
  raw_data VARIANT NOT NULL, _loaded_at TIMESTAMP_LTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(), _source_file VARCHAR NOT NULL, _load_id VARCHAR NOT NULL);

-- party tables
CREATE TABLE IF NOT EXISTS RAW_DB.NORTHWIND.customers (
  raw_data VARIANT NOT NULL, _loaded_at TIMESTAMP_LTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(), _source_file VARCHAR NOT NULL, _load_id VARCHAR NOT NULL);
CREATE TABLE IF NOT EXISTS RAW_DB.NORTHWIND.suppliers (
  raw_data VARIANT NOT NULL, _loaded_at TIMESTAMP_LTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(), _source_file VARCHAR NOT NULL, _load_id VARCHAR NOT NULL);
CREATE TABLE IF NOT EXISTS RAW_DB.NORTHWIND.employees (
  raw_data VARIANT NOT NULL, _loaded_at TIMESTAMP_LTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(), _source_file VARCHAR NOT NULL, _load_id VARCHAR NOT NULL);
CREATE TABLE IF NOT EXISTS RAW_DB.NORTHWIND.shippers (
  raw_data VARIANT NOT NULL, _loaded_at TIMESTAMP_LTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(), _source_file VARCHAR NOT NULL, _load_id VARCHAR NOT NULL);
CREATE TABLE IF NOT EXISTS RAW_DB.NORTHWIND.employee_privileges (
  raw_data VARIANT NOT NULL, _loaded_at TIMESTAMP_LTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(), _source_file VARCHAR NOT NULL, _load_id VARCHAR NOT NULL);

-- catalog
CREATE TABLE IF NOT EXISTS RAW_DB.NORTHWIND.products (
  raw_data VARIANT NOT NULL, _loaded_at TIMESTAMP_LTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(), _source_file VARCHAR NOT NULL, _load_id VARCHAR NOT NULL);

-- sales side
CREATE TABLE IF NOT EXISTS RAW_DB.NORTHWIND.orders (
  raw_data VARIANT NOT NULL, _loaded_at TIMESTAMP_LTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(), _source_file VARCHAR NOT NULL, _load_id VARCHAR NOT NULL);
CREATE TABLE IF NOT EXISTS RAW_DB.NORTHWIND.invoices (
  raw_data VARIANT NOT NULL, _loaded_at TIMESTAMP_LTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(), _source_file VARCHAR NOT NULL, _load_id VARCHAR NOT NULL);
CREATE TABLE IF NOT EXISTS RAW_DB.NORTHWIND.order_details (
  raw_data VARIANT NOT NULL, _loaded_at TIMESTAMP_LTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(), _source_file VARCHAR NOT NULL, _load_id VARCHAR NOT NULL);

-- purchasing side
CREATE TABLE IF NOT EXISTS RAW_DB.NORTHWIND.purchase_orders (
  raw_data VARIANT NOT NULL, _loaded_at TIMESTAMP_LTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(), _source_file VARCHAR NOT NULL, _load_id VARCHAR NOT NULL);
CREATE TABLE IF NOT EXISTS RAW_DB.NORTHWIND.purchase_order_details (
  raw_data VARIANT NOT NULL, _loaded_at TIMESTAMP_LTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(), _source_file VARCHAR NOT NULL, _load_id VARCHAR NOT NULL);

-- inventory
CREATE TABLE IF NOT EXISTS RAW_DB.NORTHWIND.inventory_transactions (
  raw_data VARIANT NOT NULL, _loaded_at TIMESTAMP_LTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(), _source_file VARCHAR NOT NULL, _load_id VARCHAR NOT NULL);

-- ----------------------------------------------------------------------------
-- 2. COPY INTO - load each table's staged Parquet
-- ----------------------------------------------------------------------------

-- lookup / reference
COPY INTO RAW_DB.NORTHWIND.orders_status (raw_data, _source_file, _load_id)
  FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/orders_status/)
  PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = ABORT_STATEMENT;
COPY INTO RAW_DB.NORTHWIND.orders_tax_status (raw_data, _source_file, _load_id)
  FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/orders_tax_status/)
  PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = ABORT_STATEMENT;
COPY INTO RAW_DB.NORTHWIND.order_details_status (raw_data, _source_file, _load_id)
  FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/order_details_status/)
  PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = ABORT_STATEMENT;
COPY INTO RAW_DB.NORTHWIND.purchase_order_status (raw_data, _source_file, _load_id)
  FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/purchase_order_status/)
  PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = ABORT_STATEMENT;
COPY INTO RAW_DB.NORTHWIND.inventory_transaction_types (raw_data, _source_file, _load_id)
  FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/inventory_transaction_types/)
  PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = ABORT_STATEMENT;
COPY INTO RAW_DB.NORTHWIND.privileges (raw_data, _source_file, _load_id)
  FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/privileges/)
  PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = ABORT_STATEMENT;

-- party tables
COPY INTO RAW_DB.NORTHWIND.customers (raw_data, _source_file, _load_id)
  FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/customers/)
  PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = ABORT_STATEMENT;
COPY INTO RAW_DB.NORTHWIND.suppliers (raw_data, _source_file, _load_id)
  FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/suppliers/)
  PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = ABORT_STATEMENT;
COPY INTO RAW_DB.NORTHWIND.employees (raw_data, _source_file, _load_id)
  FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/employees/)
  PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = ABORT_STATEMENT;
COPY INTO RAW_DB.NORTHWIND.shippers (raw_data, _source_file, _load_id)
  FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/shippers/)
  PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = ABORT_STATEMENT;
COPY INTO RAW_DB.NORTHWIND.employee_privileges (raw_data, _source_file, _load_id)
  FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/employee_privileges/)
  PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = ABORT_STATEMENT;

-- catalog
COPY INTO RAW_DB.NORTHWIND.products (raw_data, _source_file, _load_id)
  FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/products/)
  PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = ABORT_STATEMENT;

-- sales side
COPY INTO RAW_DB.NORTHWIND.orders (raw_data, _source_file, _load_id)
  FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/orders/)
  PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = ABORT_STATEMENT;
COPY INTO RAW_DB.NORTHWIND.invoices (raw_data, _source_file, _load_id)
  FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/invoices/)
  PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = ABORT_STATEMENT;
COPY INTO RAW_DB.NORTHWIND.order_details (raw_data, _source_file, _load_id)
  FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/order_details/)
  PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = ABORT_STATEMENT;

-- purchasing side
COPY INTO RAW_DB.NORTHWIND.purchase_orders (raw_data, _source_file, _load_id)
  FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/purchase_orders/)
  PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = ABORT_STATEMENT;
COPY INTO RAW_DB.NORTHWIND.purchase_order_details (raw_data, _source_file, _load_id)
  FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/purchase_order_details/)
  PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = ABORT_STATEMENT;

-- inventory
COPY INTO RAW_DB.NORTHWIND.inventory_transactions (raw_data, _source_file, _load_id)
  FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/inventory_transactions/)
  PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = ABORT_STATEMENT;

-- ----------------------------------------------------------------------------
-- 3. Verify (run to inspect the result)
-- ----------------------------------------------------------------------------
-- SELECT COUNT(*), MAX(_loaded_at) FROM RAW_DB.NORTHWIND.orders;
-- SELECT raw_data, _source_file, _load_id FROM RAW_DB.NORTHWIND.orders LIMIT 10;
