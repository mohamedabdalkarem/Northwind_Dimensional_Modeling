"""dlt extraction pipeline: MySQL -> S3 (Parquet) (Tasks 10-11).

Runnable as a CLI script AND importable by Airflow (Task 38).
"""
import dlt
from dlt.sources.sql_database import sql_database

def run_extract(full_refresh: bool = False):
    # TODO (Task 10): configure sql_database source over MySQL
    # TODO (Task 11): add dlt.sources.incremental on modified_at per table
    # TODO: filesystem destination -> s3://<bucket>/raw/{table}/load_date=.../
    raise NotImplementedError("Tasks 10-11")

if __name__ == "__main__":
    run_extract()
