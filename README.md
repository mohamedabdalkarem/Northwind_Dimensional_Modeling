# Northwind OLTP → OLAP Data Pipeline

Migrating Northwind's legacy MySQL reporting to a modern analytical
warehouse on Snowflake, using dlt, dbt, and Airflow.

> This README is a skeleton. Fill each section as you complete the
> matching tasks in the Notion tracker. (Tasks 59–60)

## Architecture
<!-- TODO (Task 59): embed docs/images/architecture.png -->

```
MySQL (OLTP) → dlt → S3 (raw Parquet) → Snowflake RAW
   → dbt (staging → dims/facts → marts) → BI Dashboard
Airflow orchestrates. GitHub Actions runs CI.
```

## Tech Stack
| Layer | Tool |
|-------|------|
| Source | MySQL 8 (Docker) |
| Extraction | dlt |
| Landing | Amazon S3 |
| Warehouse | Snowflake |
| Transformation | dbt Core |
| Orchestration | Airflow 3 + Cosmos |
| CI/CD | GitHub Actions |

## Setup
<!-- TODO (Task 64): step-by-step setup instructions -->

## Business Questions Answered
<!-- TODO: list the questions your marts answer -->

## Project Status
See the Notion build tracker. Minimum viable slice = tasks 1-12, 13-17, 21-30, 35-45, 59-60.
