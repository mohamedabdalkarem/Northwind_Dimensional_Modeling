-- Event-driven ingestion: Snowpipe with AUTO_INGEST, triggered by S3 event
-- notifications instead of the Airflow-scheduled COPY INTO in
-- ----------------------------------------------------------------------------
-- 0. Prerequisite
-- ----------------------------------------------------------------------------
-- Run 04_storage_integration.sql first (storage integration + s3_raw_stage)
-- and 05_raw_tables_copy.sql (raw tables must already exist).

-- ----------------------------------------------------------------------------
-- 1. Grant CREATE PIPE to LOADER
-- ----------------------------------------------------------------------------
USE ROLE SECURITYADMIN;
GRANT CREATE PIPE ON SCHEMA RAW_DB.NORTHWIND TO ROLE LOADER;

-- ----------------------------------------------------------------------------
-- 2. Pipes - one per raw table, same grouping/order as 05_raw_tables_copy.sql.
-- ----------------------------------------------------------------------------
USE ROLE LOADER;

-- lookup / reference
CREATE PIPE IF NOT EXISTS RAW_DB.NORTHWIND.orders_status_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO RAW_DB.NORTHWIND.orders_status (raw_data, _source_file, _load_id)
    FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/orders_status/)
    PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = SKIP_FILE;
CREATE PIPE IF NOT EXISTS RAW_DB.NORTHWIND.orders_tax_status_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO RAW_DB.NORTHWIND.orders_tax_status (raw_data, _source_file, _load_id)
    FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/orders_tax_status/)
    PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = SKIP_FILE;
CREATE PIPE IF NOT EXISTS RAW_DB.NORTHWIND.order_details_status_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO RAW_DB.NORTHWIND.order_details_status (raw_data, _source_file, _load_id)
    FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/order_details_status/)
    PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = SKIP_FILE;
CREATE PIPE IF NOT EXISTS RAW_DB.NORTHWIND.purchase_order_status_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO RAW_DB.NORTHWIND.purchase_order_status (raw_data, _source_file, _load_id)
    FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/purchase_order_status/)
    PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = SKIP_FILE;
CREATE PIPE IF NOT EXISTS RAW_DB.NORTHWIND.inventory_transaction_types_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO RAW_DB.NORTHWIND.inventory_transaction_types (raw_data, _source_file, _load_id)
    FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/inventory_transaction_types/)
    PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = SKIP_FILE;
CREATE PIPE IF NOT EXISTS RAW_DB.NORTHWIND.privileges_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO RAW_DB.NORTHWIND.privileges (raw_data, _source_file, _load_id)
    FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/privileges/)
    PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = SKIP_FILE;

-- party tables
CREATE PIPE IF NOT EXISTS RAW_DB.NORTHWIND.customers_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO RAW_DB.NORTHWIND.customers (raw_data, _source_file, _load_id)
    FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/customers/)
    PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = SKIP_FILE;
CREATE PIPE IF NOT EXISTS RAW_DB.NORTHWIND.suppliers_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO RAW_DB.NORTHWIND.suppliers (raw_data, _source_file, _load_id)
    FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/suppliers/)
    PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = SKIP_FILE;
CREATE PIPE IF NOT EXISTS RAW_DB.NORTHWIND.employees_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO RAW_DB.NORTHWIND.employees (raw_data, _source_file, _load_id)
    FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/employees/)
    PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = SKIP_FILE;
CREATE PIPE IF NOT EXISTS RAW_DB.NORTHWIND.shippers_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO RAW_DB.NORTHWIND.shippers (raw_data, _source_file, _load_id)
    FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/shippers/)
    PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = SKIP_FILE;
CREATE PIPE IF NOT EXISTS RAW_DB.NORTHWIND.employee_privileges_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO RAW_DB.NORTHWIND.employee_privileges (raw_data, _source_file, _load_id)
    FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/employee_privileges/)
    PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = SKIP_FILE;

-- catalog
CREATE PIPE IF NOT EXISTS RAW_DB.NORTHWIND.products_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO RAW_DB.NORTHWIND.products (raw_data, _source_file, _load_id)
    FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/products/)
    PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = SKIP_FILE;

-- sales side
CREATE PIPE IF NOT EXISTS RAW_DB.NORTHWIND.orders_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO RAW_DB.NORTHWIND.orders (raw_data, _source_file, _load_id)
    FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/orders/)
    PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = SKIP_FILE;
CREATE PIPE IF NOT EXISTS RAW_DB.NORTHWIND.invoices_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO RAW_DB.NORTHWIND.invoices (raw_data, _source_file, _load_id)
    FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/invoices/)
    PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = SKIP_FILE;
CREATE PIPE IF NOT EXISTS RAW_DB.NORTHWIND.order_details_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO RAW_DB.NORTHWIND.order_details (raw_data, _source_file, _load_id)
    FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/order_details/)
    PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = SKIP_FILE;

-- purchasing side
CREATE PIPE IF NOT EXISTS RAW_DB.NORTHWIND.purchase_orders_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO RAW_DB.NORTHWIND.purchase_orders (raw_data, _source_file, _load_id)
    FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/purchase_orders/)
    PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = SKIP_FILE;
CREATE PIPE IF NOT EXISTS RAW_DB.NORTHWIND.purchase_order_details_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO RAW_DB.NORTHWIND.purchase_order_details (raw_data, _source_file, _load_id)
    FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/purchase_order_details/)
    PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = SKIP_FILE;

-- inventory
CREATE PIPE IF NOT EXISTS RAW_DB.NORTHWIND.inventory_transactions_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO RAW_DB.NORTHWIND.inventory_transactions (raw_data, _source_file, _load_id)
    FROM (SELECT $1, METADATA$FILENAME, $1:_dlt_load_id::VARCHAR FROM @RAW_DB.NORTHWIND.s3_raw_stage/inventory_transactions/)
    PATTERN = '.*load_date=.*[.]parquet' ON_ERROR = SKIP_FILE;

-- ----------------------------------------------------------------------------
-- 3. Get each pipe's SQS ARN
-- ----------------------------------------------------------------------------
SHOW PIPES IN SCHEMA RAW_DB.NORTHWIND;
-- "notification_channel" column = the SQS queue ARN S3 must publish to.
-- Name/ARN pairs, ready to paste into the AWS side below:
SELECT "name" AS pipe_name, "notification_channel" AS sqs_arn
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

-- ----------------------------------------------------------------------------
-- 4. Wire S3 event notifications to each pipe's queue
--    (AWS console, OUTSIDE Snowflake - run once per table, using that
--    table's prefix from FILE_LAYOUT and its pipe's ARN from step 3)
-- ----------------------------------------------------------------------------
-- Console: S3 -> bucket northwind-project-data -> Properties ->
--   Event notifications -> Create event notification
--     Prefix: raw/customers/     (this table's folder, per ingestion/pipeline.py FILE_LAYOUT)
--     Suffix: .parquet
--     Event types: s3:ObjectCreated:*
--     Destination: SQS queue -> "Enter SQS queue ARN" -> paste notification_channel
--   Repeat for every table/pipe pair from step 3.
--
-- ----------------------------------------------------------------------------
-- 5. Verify (run to inspect the result)
-- ----------------------------------------------------------------------------
-- SHOW PIPES IN SCHEMA RAW_DB.NORTHWIND;
-- SELECT SYSTEM$PIPE_STATUS('RAW_DB.NORTHWIND.customers_pipe');
-- -- after dropping a test file under s3://northwind-project-data/raw/customers/:
-- SELECT * FROM TABLE(VALIDATE_PIPE_LOAD(
--   PIPE_NAME => 'RAW_DB.NORTHWIND.customers_pipe',
--   START_TIME => DATEADD(HOUR, -1, CURRENT_TIMESTAMP())));
-- SELECT COUNT(*), MAX(_loaded_at) FROM RAW_DB.NORTHWIND.customers;
