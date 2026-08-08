"""Transform DAG: dbt via Cosmos, triggered by the RAW_LOADED asset (Tasks 39-41)."""
from cosmos import DbtDag, ProjectConfig, ProfileConfig, RenderConfig
from airflow.sdk import Asset
import pendulum

RAW_LOADED = Asset("snowflake://RAW_DB/NORTHWIND")

# TODO (Task 40): run `dbt source freshness` as a gate before the model run.
transform = DbtDag(
    project_config=ProjectConfig("/usr/local/airflow/dbt"),
    profile_config=ProfileConfig(profile_name="northwind", target_name="prod",
                                 profiles_yml_filepath="/usr/local/airflow/dbt/profiles.yml"),
    render_config=RenderConfig(load_method="dbt_manifest"),  # fast parsing
    schedule=[RAW_LOADED],                                    # data-aware (Task 41)
    start_date=pendulum.datetime(2024,1,1),
    catchup=False,
    dag_id="northwind_transform",
    # TODO (Task 42): default_args retries/backoff, execution_timeout, max_active_runs=1
    # TODO (Task 43): on_failure_callback -> Slack
)
