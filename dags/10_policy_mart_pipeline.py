from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator

DBT_PROJECT_DIR = "/opt/airflow/dbt/fox_analytics"
INSURANCE_SELECT = (
    "path:models/staging/insurance "
    "path:models/intermediate/insurance "
    "path:models/marts/insurance"
)


def alert_on_failure(context):
    task_id = context["task_instance"].task_id
    print(f"ALERT: task '{task_id}' failed in DAG '{context['dag'].dag_id}'")


with DAG(
    dag_id="10_policy_mart_pipeline",
    description="Life insurance policy data mart: refresh source -> dbt seed/run/test (insurance domain only).",
    start_date=datetime(2024, 1, 1),
    schedule="@daily",
    catchup=False,
    default_args={
        "retries": 1,
        "retry_delay": timedelta(minutes=2),
        "on_failure_callback": alert_on_failure,
    },
    tags=["insurance", "policy-mart"],
) as dag:
    # Simulates a Policy Administration System (PAS) extract landing in the
    # `policy_admin` schema. In a real pipeline this task would instead be a
    # CDC/ETL job (Debezium, Fivetran, a custom extractor...); here it's a
    # Python script that refreshes synthetic source data.
    refresh_policy_admin_source = BashOperator(
        task_id="refresh_policy_admin_source",
        bash_command="python3 /opt/airflow/scripts/generate_policy_admin_source.py",
    )

    dbt_seed = BashOperator(
        task_id="dbt_seed",
        bash_command=f"cd {DBT_PROJECT_DIR} && dbt seed --select insurance_product_tier",
    )

    dbt_run_insurance = BashOperator(
        task_id="dbt_run_insurance",
        bash_command=f"cd {DBT_PROJECT_DIR} && dbt run --select {INSURANCE_SELECT}",
    )

    dbt_test_insurance = BashOperator(
        task_id="dbt_test_insurance",
        bash_command=f"cd {DBT_PROJECT_DIR} && dbt test --select {INSURANCE_SELECT}",
    )

    refresh_policy_admin_source >> dbt_seed >> dbt_run_insurance >> dbt_test_insurance
