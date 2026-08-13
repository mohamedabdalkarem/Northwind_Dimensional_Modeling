"""dlt extraction pipeline: MySQL -> S3 (Parquet) (Tasks 10-11).

Lands every Northwind table as Hive-partitioned Parquet:

    s3://<bucket>/raw/<table>/load_date=YYYY-MM-DD/<run_id>.parquet

Runnable as a CLI script (`python -m ingestion.pipeline`) AND importable
by Airflow (`from ingestion.pipeline import run_extract`, Task 38).

No per-table incremental cursor is wired in yet: only `inventory_transactions`
has a `transaction_modified_date` column, every other table lacks a
modified-at column to cursor on (see ingestion/README.md). `--full-refresh`
replaces each table's landed files outright; the default appends a new,
uniquely-named snapshot file per run. Incremental vs. full-refresh testing
is Task 12.
"""
import argparse
import os
from urllib.parse import quote_plus

import dlt
from dlt.common.pipeline import LoadInfo
from dlt.destinations import filesystem
from dotenv import load_dotenv

load_dotenv()

try:
    from ingestion.northwind_source import northwind_source
except ImportError:
    from northwind_source import northwind_source

# dataset_name="raw" (see run_extract) supplies the "raw/" segment, so this
# only needs to add the per-table folder, the load_date partition, and the
# file itself. {curr_date} is dlt's own YYYY-MM-DD placeholder; {run_id} is
# aliased below to dlt's load_id, which is already unique per pipeline.run().
FILE_LAYOUT = "{table_name}/load_date={curr_date}/{run_id}.{ext}"


def _mysql_credentials() -> str:
    user = quote_plus(os.environ["MYSQL_USER"])
    password = quote_plus(os.environ["MYSQL_PASSWORD"])
    host = os.environ["MYSQL_HOST"]
    port = os.environ.get("MYSQL_PORT", "3306")
    database = os.environ["MYSQL_DATABASE"]
    return f"mysql+pymysql://{user}:{password}@{host}:{port}/{database}"


def _s3_destination() -> filesystem:
    bucket = os.environ["S3_BUCKET"].rstrip("/")
    if not bucket.startswith("s3://"):
        bucket = f"s3://{bucket}"
    return filesystem(
        bucket_url=bucket,
        layout=FILE_LAYOUT,
        extra_placeholders={
            "run_id": lambda schema_name, table_name, load_id, file_id, ext: load_id,
        },
        credentials={
            "aws_access_key_id": os.environ["AWS_ACCESS_KEY_ID"],
            "aws_secret_access_key": os.environ["AWS_SECRET_ACCESS_KEY"],
            "region_name": os.environ.get("AWS_REGION"),
        },
    )


def run_extract(full_refresh: bool = False) -> LoadInfo:
    """Extract every Northwind table from MySQL and land it as Parquet on S3.

    Args:
        full_refresh: when True, replace each table's previously landed
            files instead of appending a new dated snapshot.
    """
    pipeline = dlt.pipeline(
        pipeline_name="northwind_raw",
        destination=_s3_destination(),
        dataset_name="raw",
        progress="log",
    )
    source = northwind_source(credentials=_mysql_credentials())
    return pipeline.run(
        source,
        loader_file_format="parquet",
        write_disposition="replace" if full_refresh else "append",
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="Extract Northwind MySQL tables to S3 as Parquet.")
    parser.add_argument(
        "--full-refresh",
        action="store_true",
        help="Replace, rather than append to, each table's landed partitions.",
    )
    args = parser.parse_args()
    load_info = run_extract(full_refresh=args.full_refresh)
    print(load_info)


if __name__ == "__main__":
    main()
