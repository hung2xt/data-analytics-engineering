# Reference solution for exercises/04_orchestrate_dbt_with_airflow.md
# Copy this into dags/ (or write your own version there first!) to try it.

from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator

DBT_PROJECT_DIR = "/opt/airflow/dbt/fox_analytics"

with DAG(
    dag_id="04_dbt_pipeline",
    description="Orchestrates dbt seed -> run -> test for the fox_analytics project.",
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
    tags=["exercise-04"],
) as dag:
    dbt_seed = BashOperator(
        task_id="dbt_seed",
        bash_command=f"cd {DBT_PROJECT_DIR} && dbt seed",
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=f"cd {DBT_PROJECT_DIR} && dbt run",
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=f"cd {DBT_PROJECT_DIR} && dbt test",
    )

    dbt_seed >> dbt_run >> dbt_test
