-- Credit guardrails
-- One resource monitor shared by both warehouses: notify at 75%, hard-suspend
-- running/new queries at 100%. Resets automatically at the start of each month.
USE ROLE ACCOUNTADMIN;

CREATE RESOURCE MONITOR IF NOT EXISTS PIPELINE_CREDIT_MONITOR
  WITH
    CREDIT_QUOTA = 100          -- placeholder: tune to actual monthly credit budget
    FREQUENCY = MONTHLY
    START_TIMESTAMP = IMMEDIATELY
  TRIGGERS
    ON 75  PERCENT DO NOTIFY    -- email/notify account admins, warehouses keep running
    ON 100 PERCENT DO SUSPEND;  -- let running queries finish, block new ones

-- Attach to both warehouses so the monitor's quota is shared across ingestion
-- and transform load, instead of scoping it account-wide.
ALTER WAREHOUSE LOADING_WH   SET RESOURCE_MONITOR = PIPELINE_CREDIT_MONITOR;
ALTER WAREHOUSE TRANSFORM_WH SET RESOURCE_MONITOR = PIPELINE_CREDIT_MONITOR;

-- ----------------------------------------------------------------------------
-- Verify (run to inspect the result)
-- ----------------------------------------------------------------------------
-- SHOW RESOURCE MONITORS;
-- DESC WAREHOUSE LOADING_WH;
-- DESC WAREHOUSE TRANSFORM_WH;
