# 02 - Airflow Basics

## Khái niệm cốt lõi
- **DAG**: một pipeline, định nghĩa bằng Python, gồm các task và dependency giữa chúng (không cho phép vòng lặp — Directed *Acyclic* Graph).
- **Task**: một đơn vị công việc, tạo ra từ một **Operator** (PythonOperator, BashOperator, ...).
- **Operator**: template quy định task đó *làm gì* (chạy Python function, chạy bash command, gọi API...).
- **Scheduler**: process quyết định khi nào task được chạy, dựa vào `schedule` và trạng thái dependency.
- **Executor**: quyết định task chạy ở đâu/như thế nào (ở đây dùng `LocalExecutor` — chạy song song trên cùng máy, đơn giản cho local dev).

## Việc cần làm

1. Trong Airflow UI, bật (unpause) DAG `00_hello_airflow`, trigger chạy thủ công (nút ▶), xem log của task `say_hello`.

2. Tạo file mới `dags/02_my_first_dag.py` với:
   - 3 task tuần tự dùng `PythonOperator`: `extract` → `transform` → `load` (mỗi task chỉ cần `print(...)` gì đó).
   - Dùng `>>` để set dependency.
   - Đặt `retries=2`, `retry_delay=timedelta(seconds=10)` cho task `transform`, cho nó `raise Exception("boom")` để quan sát Airflow tự retry trước khi fail hẳn.

3. Trigger DAG, quan sát trong tab **Graph**: task nào chạy song song được, task nào phải chờ.

## Checkpoint
- [ ] DAG `00_hello_airflow` chạy thành công, xem được log.
- [ ] DAG của bạn có 3 task nối tiếp, và bạn quan sát được hành vi retry.
- [ ] Bạn giải thích được khác nhau giữa DAG / Task / Operator / Scheduler / Executor bằng lời của mình.

Đi tiếp sang [03_dbt_basics.md](03_dbt_basics.md).
