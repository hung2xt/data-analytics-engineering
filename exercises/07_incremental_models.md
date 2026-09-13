# 07 - Incremental Models

## Vì sao cần incremental?
`table` materialization rebuild toàn bộ data mỗi lần chạy — ổn với vài trăm dòng như `enriched_orders`, nhưng với bảng hàng tỷ dòng thì quá chậm/tốn kém. **Incremental** chỉ xử lý phần data *mới* mỗi lần chạy.

## Khái niệm cốt lõi
- `{{ config(materialized='incremental', unique_key='order_id') }}` ở đầu model.
- `{% if is_incremental() %} ... {% endif %}`: block SQL này **chỉ áp dụng** khi bảng đích đã tồn tại (không áp dụng ở lần chạy đầu tiên/full-refresh).
- Pattern kinh điển: `where ordered_at > (select max(ordered_at) from {{ this }})` — `{{ this }}` = chính bảng đang build.
- `dbt run --full-refresh`: bỏ qua logic incremental, drop & rebuild lại từ đầu (dùng khi đổi logic model, hoặc nghi ngờ data bị lệch).

## Việc cần làm

1. Tạo model mới `models/marts/fct_orders_incremental.sql`, copy logic từ `fct_orders` nhưng thêm:
   ```sql
   {{ config(materialized='incremental', unique_key='order_id') }}

   select
       order_id,
       customer_id,
       product_id,
       quantity,
       total_amount,
       ordered_at
   from {{ ref('stg_orders') }}

   {% if is_incremental() %}
   where ordered_at > (select coalesce(max(ordered_at), '1900-01-01') from {{ this }})
   {% endif %}
   ```

2. Chạy `dbt run --select fct_orders_incremental` 2 lần liên tiếp, xem log lần 2 có báo "0 rows inserted" không (vì không có order nào mới hơn max hiện có).

3. Thêm 1 order thật mới trực tiếp vào `enriched_orders` (mô phỏng data mới đổ về), với `created_at` là **thời điểm hiện tại**:
   ```sql
   insert into public.enriched_orders
       (order_id, customer_id, customer_name, email, city, tier, loyalty_points, product_id, product_name, quantity, total_amount, created_at)
   values
       ('ORD-TEST-001', 1001, 'Diana Prince', 'diana@email.com', 'Paris', 'Platinum', 4185, 'P001', 'Laptop', 1, 1200, now());
   ```
   Rồi `dbt run --select fct_orders_incremental` — quan sát chỉ dòng mới được insert thêm (không rebuild toàn bộ).

4. Chạy `dbt run --select fct_orders_incremental --full-refresh` để thấy nó rebuild lại từ đầu.

5. Dọn dẹp: xoá dòng test bạn vừa thêm để không làm lệch số liệu các bài sau:
   ```sql
   delete from public.enriched_orders where order_id = 'ORD-TEST-001';
   ```
   rồi `dbt run --full-refresh` lại toàn bộ project 1 lần cho sạch.

## Checkpoint
- [ ] Bạn quan sát được sự khác biệt giữa run thường (incremental) và `--full-refresh`.
- [ ] Bạn giải thích được vì sao `unique_key` quan trọng (tránh insert trùng nếu 1 record được update).

Đi tiếp sang [08_sensors_freshness_alerting.md](08_sensors_freshness_alerting.md).
