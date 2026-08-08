# Snowflake objects as code (Task 20, optional — do AFTER manual DDL works)
terraform {
  required_providers {
    snowflake = { source = "Snowflake-Labs/snowflake" }
  }
}
# TODO: databases, schemas, warehouses, roles, grants.
