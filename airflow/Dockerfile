# Airflow 2.10.5 runtime, matching the image used by airflow/docker-compose.yml.
FROM apache/airflow:2.10.5-python3.12

USER root
COPY requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r /requirements.txt
USER airflow