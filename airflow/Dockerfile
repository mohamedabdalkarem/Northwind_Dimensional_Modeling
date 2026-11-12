FROM apache/airflow:2.10.5-python3.12

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential pkg-config default-libmysqlclient-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

USER airflow

ARG AIRFLOW_VERSION=2.10.5
ARG PYTHON_VERSION=3.12
ENV CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"

COPY requirements.txt dbt-requirements.txt /tmp/

# Airflow providers: constrained to versions compatible with Airflow 2.10.5
RUN pip install --no-cache-dir -r /tmp/requirements.txt --constraint "${CONSTRAINT_URL}"

# dbt: isolated virtualenv so it never conflicts with Airflow's dependencies
RUN python -m venv /home/airflow/dbt_venv \
    && /home/airflow/dbt_venv/bin/pip install --no-cache-dir --upgrade pip \
    && /home/airflow/dbt_venv/bin/pip install --no-cache-dir --default-timeout=100 -r /tmp/dbt-requirements.txt