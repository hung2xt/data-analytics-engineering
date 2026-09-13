# 03 - dbt Basics

## Khái niệm cốt lõi
- **source**: khai báo bảng raw đã tồn tại sẵn trong warehouse (do 1 tool ingest khác load vào) — xem `dbt/fox_analytics/models/staging/sources.yml`, trỏ vào `fox_dwh.public.enriched_orders` (bảng thật, không phải seed).
- **seed**: file CSV nhỏ, dbt tự load thành table — ở project này dùng cho `tier_benefits.csv`, 1 bảng lookup tĩnh (tier → % discount) không có sẵn trong warehouse, join vào `dim_customers` sau này.
- **model**: 1 file `.sql` = 1 `SELECT`, dbt tự wrap thành `CREATE VIEW`/`CREATE TABLE`.
- **ref()**: cách 1 model refer tới model khác (hoặc seed) — dbt tự tính dependency graph (DAG!) từ đó.
- **materialization**: `view` (mặc định cho staging), `table`, `ephemeral` (inline vào query cha, không tạo object trong DB), `incremental` (bài 07).

Project đã có sẵn layer **staging** (`stg_customers`, `stg_orders`, `stg_products`) làm ví dụ mẫu — đọc qua 3 file đó trong `dbt/fox_analytics/models/staging/` trước khi làm tiếp. Chú ý `stg_customers.sql`: vì `enriched_orders` là bảng denormalized (thông tin customer lặp lại trên mỗi order line, và có thể lệch nhau — ví dụ `loyalty_points` tăng dần theo thời gian), model này phải dùng `row_number()` để lấy giá trị **mới nhất** theo customer — 1 pattern rất hay gặp khi raw data không phải từ 1 OLTP DB sạch.

## Việc cần làm

1. Exec vào container và chạy:
   ```bash
   docker compose exec airflow-scheduler bash
   cd $DBT_PROFILES_DIR
   dbt seed      # load tier_benefits.csv
   dbt run       # build staging views (đọc trực tiếp từ fox_dwh.public.enriched_orders)
   dbt test      # chạy các test khai báo trong schema.yml
   ```

2. Soi kết quả trong warehouse (psql hoặc DBeaver, db `fox_dwh`, schema `analytical_engineer`):
   ```sql
   select * from analytical_engineer.stg_orders limit 10;
   select tier, count(*) from analytical_engineer.stg_customers group by 1;
   ```

3. Sinh docs & xem lineage graph:
   ```bash
   dbt docs generate
   dbt docs serve --port 8081
   ```
   (cần map thêm port 8081 trong docker-compose nếu muốn xem từ host, hoặc `docker compose exec` rồi curl từ trong container để đọc HTML — không bắt buộc, chỉ để biết tính năng này tồn tại).

## Checkpoint
- [ ] `dbt seed`, `dbt run`, `dbt test` đều chạy thành công (test PASS).
- [ ] Bạn query được `stg_orders`, `stg_customers`, `stg_products` trong schema `analytical_engineer` (schema `public` không hề bị đụng tới).
- [ ] Bạn giải thích được vì sao staging dùng `source()` chứ không `ref()` để trỏ tới raw tables, và vì sao `stg_customers` cần logic "lấy dòng mới nhất" thay vì `select distinct` đơn giản.

Đi tiếp sang [04_orchestrate_dbt_with_airflow.md](04_orchestrate_dbt_with_airflow.md).
