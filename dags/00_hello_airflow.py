from datetime import datetime

from airflow import DAG
from airflow.operators.python import PythonOperator


def say_hello():
    print("Hello from Airflow! Environment is working.")


with DAG(
    dag_id="00_hello_airflow",
    description="Sanity-check DAG: confirms the Airflow environment is wired up correctly.",
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
    tags=["exercise-02"],
) as dag:
    hello_task = PythonOperator(
        task_id="say_hello",
        python_callable=say_hello,
    )
