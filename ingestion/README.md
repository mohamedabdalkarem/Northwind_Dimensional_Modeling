# Ingestion (dlt)

MySQL → S3 landing zone as partitioned Parquet.

- `pipeline.py` — entry point (Tasks 10-11)
- Incremental on `modified_at`; small dims stay full-refresh (document why).
- Test full-refresh vs incremental + failure path (Task 12).
