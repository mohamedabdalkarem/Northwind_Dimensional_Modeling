"""Ingestion DAG: dlt extract (MySQL->S3) -> COPY INTO Snowflake -> reconcile.
Emits an Asset on success so the transform DAG can react (Tasks 38, 41).
"""
from airflow.decorators import dag, task
from airflow.sdk import Asset          # Airflow 3 asset API
import pendulum

RAW_LOADED = Asset("snowflake://RAW_DB/NORTHWIND")

@dag(schedule="@daily", start_date=pendulum.datetime(2024,1,1), catchup=False)
def northwind_ingestion():

    @task
    def extract():
        from ingestion.pipeline import run_extract   # Task 10-11
        run_extract()

    @task
    def copy_into():
        ...  # SnowflakeOperator / hook COPY INTO (Task 17)

    @task(outlets=[RAW_LOADED])
    def reconcile():
        ...  # row-count check source vs raw (Task 38)

    extract() >> copy_into() >> reconcile()

northwind_ingestion()
