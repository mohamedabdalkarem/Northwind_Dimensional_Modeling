# Northwind OLTP → OLAP Data Pipeline

Migrating Northwind's legacy MySQL reporting to a modern analytical warehouse on Snowflake, using dlt, dbt, and Airflow.

## Architecture

![Architecture](readme%20images/archticture.png)

```
MySQL (OLTP) → dlt → S3 (raw Parquet) → Snowflake RAW
   → dbt (staging → dims/facts → marts) → BI Dashboard
Airflow orchestrates. GitHub Actions runs CI.
```

### Data Flow
1. **Source**: Northwind MySQL database (Docker)
2. **Extraction**: dlt pipelines with incremental loading on `modified_at`
3. **Landing**: Amazon S3 as partitioned Parquet files
4. **Warehouse**: Snowflake (RAW_DB, ANALYTICS_DB, DEV_DB)
5. **Transformation**: dbt Core (staging → dimensions/facts → marts/OBT)
6. **Orchestration**: Airflow 3 + Cosmos for dbt integration
7. **BI**: Streamlit dashboard with RBAC (REPORTER role)

### Northwind OLTP ERD
![ERD](readme%20images/northwind-oltp-erd.png)

### Pipeline Route Map
![Route Map](readme%20images/northwind_route_map%20(1).gif)

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
| BI Dashboard | Streamlit |

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Python 3.10+
- Snowflake account
- AWS account (S3)
- Airflow (via Astronomer CLI recommended)

### 1. Start MySQL Source
```bash
docker compose up -d
# Access Adminer at http://localhost:8081
# Server: mysql, User: northwind, Password: northwind, DB: northwind
```

### 2. Configure Environment
```bash
cp .env.example .env
# Edit .env with your Snowflake, AWS, and MySQL credentials
```

### 3. Set Up Snowflake Infrastructure
```bash
# Run SQL scripts in order (or use Terraform)
cd infra/snowflake
# Execute 01_databases.sql through 07_snowpipe.sql
```

### 4. Install Python Dependencies
```bash
pip install -r requirements.txt
pip install -r airflow/requirements.txt
pip install -r dashboard/requirements.txt
```

### 5. Run dlt Ingestion
```bash
cd ingestion
python pipeline.py
```

### 6. Run dbt Transformations
```bash
cd dbt_modeling
dbt debug
dbt run
dbt test
```

### 7. Start Airflow
```bash
cd airflow
astro dev start
# Access at http://localhost:8080
```

### 8. Launch Dashboard
```bash
cd dashboard
streamlit run app.py
```

## Project Structure
```
northwind project/
├── ingestion/           # dlt pipeline (MySQL → S3)
├── dbt_modeling/        # dbt project (transformations)
├── airflow/             # Airflow DAGs + Cosmos config
├── dashboard/           # Streamlit BI dashboard
├── infra/
│   ├── snowflake/       # Manual DDL scripts
│   └── terraform/       # Optional IaC
├── mysql/               # MySQL init scripts + data generator
├── datasets/            # CSV source data
├── docs/                # Architecture, data dictionary, cost analysis
├── scripts/             # Utility scripts
└── snowflake_keys/      # RSA keys for key-pair auth
```

## Business Questions Answered

The marts/OBT models answer:

| Business Process | Key Questions |
|-----------------|---------------|
| **Sales Overview** | Revenue by period, top products/customers, sales rep performance |
| **Product Inventory** | Stock levels, turnover, reorder points, supplier lead times |
| **Customer Reporting** | Customer lifetime value, order frequency, geographic distribution |

## Key Features

- **Incremental Loading**: dlt uses `modified_at` for CDC; small dimension tables full-refresh
- **RBAC**: Snowflake roles (TRANSFORMER, LOADER, REPORTER) with key-pair authentication
- **Data Quality**: dbt tests (unique, not_null, referential integrity, custom)
- **CI/CD**: GitHub Actions for linting, testing, and deployment
- **Cost Monitoring**: Query history analysis per dbt model (see `docs/cost_analysis.md`)

## Documentation

- [Architecture](docs/architecture.md) - Detailed diagram and flow
- [Data Dictionary](docs/data_dictionary.md) - Generated from dbt docs
- [Cost Analysis](docs/cost_analysis.md) - Snowflake credit usage by model

## Project Status

See the Notion build tracker. Minimum viable slice = tasks 1-12, 13-17, 21-30, 35-45, 59-60.

### Completed
- [x] MySQL source with seed data (Docker)
- [x] dlt ingestion pipeline (MySQL → S3)
- [x] Snowflake infrastructure (databases, warehouses, roles, storage integration)
- [x] dbt models (staging → dims/facts → marts)
- [x] Airflow DAGs (ingestion + transform, wired via Assets)
- [x] Streamlit dashboard skeleton
- [x] Documentation structure

### In Progress
- [ ] Dashboard charts and queries
- [ ] Full test coverage
- [ ] GitHub Actions CI/CD
- [ ] Terraform for Snowflake

## License

MIT