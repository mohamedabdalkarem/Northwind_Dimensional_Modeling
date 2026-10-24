# Airflow (Tasks 36-44)
- Runs on Airflow 2.10.5 via `docker compose up` in this folder (Task 36)
- Connections: snowflake_default, aws_default, mysql_default (Task 37)
- Two DAGs wired by a Dataset (Task 41); the transform DAG runs dbt (Task 39).