-- Storage integration + external stage to S3
-- Use IAM role trust, NOT embedded keys.
--
-- Bucket / prefix layout (see ingestion/pipeline.py FILE_LAYOUT):
--   s3://northwind-project-data/raw/<table>/load_date=YYYY-MM-DD/<run_id>.parquet

-- ----------------------------------------------------------------------------
-- 0. AWS prerequisite (do this in the AWS console/CLI FIRST, outside Snowflake)
-- ----------------------------------------------------------------------------
-- a) IAM policy scoped to just this bucket/prefix, e.g. "snowflake-s3-northwind-policy":
--      {
--        "Version": "2012-10-17",
--        "Statement": [
--          { "Effect": "Allow",
--            "Action": [
--              "s3:GetObject",
--              "s3:GetObjectVersion",
--              "s3:PutObject",
--              "s3:DeleteObject",
--              "s3:DeleteObjectVersion"
--            ],
--            "Resource": "arn:aws:s3:::northwind-project-data/raw/*" },
--          { "Effect": "Allow", "Action": ["s3:ListBucket", "s3:GetBucketLocation"],
--            "Resource": "arn:aws:s3:::northwind-project-data",
--            "Condition": { "StringLike": { "s3:prefix": ["raw/*"] } } }
--        ]
--      }
--          (drop the Put/Delete actions if this stage should stay read-only)
--
-- b) IAM role "snowflake_s3_role" with a PLACEHOLDER trust policy trusting your
--    own account (Snowflake requires the role to exist before step 1, and the
--    real trusted principal is only known after step 2):
--      {
--        "Version": "2012-10-17",
--        "Statement": [{
--          "Effect": "Allow",
--          "Principal": { "AWS": "arn:aws:iam::<AWS_ACCOUNT_ID>:root" },
--          "Action": "sts:AssumeRole",
--          "Condition": { "StringEquals": { "sts:ExternalId": "0000" } }
--        }]
--      }
--    Attach the policy from (a) to this role.

-- ----------------------------------------------------------------------------
-- 1. Storage integration (ACCOUNTADMIN — only role that can CREATE INTEGRATION)
-- ----------------------------------------------------------------------------
USE ROLE ACCOUNTADMIN;

CREATE STORAGE INTEGRATION IF NOT EXISTS s3_northwind_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::<AWS_ACCOUNT_ID>:role/snowflake_s3_role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://northwind-project-data/raw/')
  COMMENT = 'Trust-based access to the raw landing bucket for LOADER COPY INTO / Snowpipe';

-- LOADER is the role that actually runs CREATE STAGE / COPY INTO in RAW_DB.NORTHWIND
-- (see 03_roles_rbac.sql section 2)
GRANT USAGE ON INTEGRATION s3_northwind_int TO ROLE LOADER;

-- ----------------------------------------------------------------------------
-- 2. Close the trust loop: pull Snowflake's IAM identity, update the AWS role
-- ----------------------------------------------------------------------------
-- Run manually and read two columns from the output:
       DESC INTEGRATION s3_northwind_int;
--     STORAGE_AWS_IAM_USER_ARN  -> principal to trust
--     STORAGE_AWS_EXTERNAL_ID   -> external ID condition
--
-- Then replace the placeholder trust policy on snowflake_s3_role (step 0.b) with:
--      {
--        "Version": "2012-10-17",
--        "Statement": [{
--          "Effect": "Allow",
--          "Principal": { "AWS": "<STORAGE_AWS_IAM_USER_ARN>" },
--          "Action": "sts:AssumeRole",
--          "Condition": { "StringEquals": { "sts:ExternalId": "<STORAGE_AWS_EXTERNAL_ID>" } }
--        }]
--      }

-- ----------------------------------------------------------------------------
-- 3. File format + external stage (LOADER — owns objects in RAW_DB.NORTHWIND)
-- ----------------------------------------------------------------------------
USE ROLE LOADER;
USE WAREHOUSE LOADING_WH;

CREATE FILE FORMAT IF NOT EXISTS RAW_DB.NORTHWIND.parquet_ff
  TYPE = PARQUET
  COMMENT = 'Parquet files landed by ingestion/pipeline.py';

CREATE STAGE IF NOT EXISTS RAW_DB.NORTHWIND.s3_raw_stage
  URL = 's3://northwind-project-data/raw/'
  STORAGE_INTEGRATION = s3_northwind_int
  FILE_FORMAT = RAW_DB.NORTHWIND.parquet_ff
  COMMENT = 'External stage over the dlt landing prefix, one folder per table';

-- ----------------------------------------------------------------------------
-- 4. Verify (run to inspect the result)
-- ----------------------------------------------------------------------------
 DESC INTEGRATION s3_northwind_int;
 DESC STAGE RAW_DB.NORTHWIND.s3_raw_stage;
 LIST @RAW_DB.NORTHWIND.s3_raw_stage;
