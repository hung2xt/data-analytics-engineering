# 04 - Orchestrate dbt with Airflow

## Mục tiêu
Đây là bài quan trọng nhất: nối Airflow với dbt, thay vì gõ tay `dbt run` trong terminal như bài 03.

## Việc cần làm

1. Tạo file `dags/04_dbt_pipeline.py` với 1 DAG gồm 3 task tuần tự dùng `BashOperator`:
   `dbt_seed` → `dbt_run` → `dbt_test`.

   Gợi ý:
   - dbt project nằm ở `/opt/airflow/dbt/fox_analytics` bên trong container (đã mount qua volume).
   - `BashOperator` cần `cd` vào thư mục đó trước khi gọi `dbt`, ví dụ:
     `bash_command="cd /opt/airflow/dbt/fox_analytics && dbt run"`.
   - `DBT_PROFILES_DIR` đã được set sẵn qua biến môi trường của container (xem `docker-compose.yml`), dbt sẽ tự tìm thấy `profiles.yml`.

2. Trigger DAG từ UI, xem log từng task — log chính là output của lệnh `dbt` như khi bạn chạy tay.

3. Cố tình làm 1 test fail — vì source ở đây là bảng thật, **luôn lưu lại giá trị gốc trước khi sửa** để restore đúng:
   ```sql
   -- 1. Ghi nhớ order_id + tier gốc, ví dụ order_id = 'ORD-1768700493696', tier gốc = 'Platinum'
   select order_id, tier from public.enriched_orders limit 1;

   -- 2. Sửa tạm sang giá trị không hợp lệ
   update public.enriched_orders set tier = 'Diamond' where order_id = 'ORD-1768700493696';
   ```
   Chạy lại DAG: `dbt_run` vẫn pass, nhưng `dbt_test` fail (`accepted_values` trên `stg_customers.tier`) → task đỏ, DAG dừng.
   ```sql
   -- 3. Trả lại giá trị gốc
   update public.enriched_orders set tier = 'Platinum' where order_id = 'ORD-1768700493696';
   ```
   Chạy lại DAG để thấy nó xanh trở lại.

Nếu bí, xem [`solutions/04_dbt_pipeline_dag.py`](../solutions/04_dbt_pipeline_dag.py) — nhưng cố tự viết trước đã.

## Checkpoint
- [ ] DAG `04_dbt_pipeline` chạy xanh hết cả 3 task.
- [ ] Bạn tái hiện được 1 lần fail có chủ đích và hiểu vì sao Airflow dừng ở đúng task đó.
- [ ] Bạn giải thích được vì sao đây là pattern phổ biến hơn "cron chạy dbt trực tiếp": Airflow cho bạn retry, alert, dependency với các job khác (ingestion, BI refresh...).

Đi tiếp sang [05_build_marts.md](05_build_marts.md).
