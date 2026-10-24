"""Transform DAG: run dbt models, triggered by the RAW_LOADED dataset (Tasks 39-41).

The compose mounts ./include at /opt/airflow/include, so the dbt project must be
reachable there (e.g. /opt/airflow/include/dbt). Point the `northwind_dbt_dir`
Airflow Variable at it.
"""
from airflow.datasets import Dataset
from airflow.decorators import dag
from airflow.models import Variable
from airflow.operators.bash import BashOperator
import pendulum

RAW_LOADED = Dataset("snowflake://RAW_DB/NORTHWIND")

@dag(
    schedule=[RAW_LOADED],
    start_date=pendulum.datetime(2024, 1, 1),
    catchup=False,
    dag_id="northwind_transform",
    default_args={"retries": 2, "owner": "northwind"},
    tags=["northwind", "transform"],
)
def northwind_transform():
    dbt_dir = Variable.get("northwind_dbt_dir", default_var="/opt/airflow/include/dbt")

    # TODO (Task 40): run `dbt source freshness` as a gate before the model run.
    BashOperator(
        task_id="dbt_build",
        bash_command=f"dbt build --project-dir {dbt_dir}",
    )

northwind_transform()