# 06 - Testing & Data Quality

## Khái niệm cốt lõi
- **Generic tests** (đã dùng ở staging): `unique`, `not_null`, `accepted_values`, `relationships` — khai báo trong `schema.yml`, tái sử dụng được cho nhiều cột/model.
- **Singular tests**: 1 file `.sql` trong `tests/`, query trả về **0 dòng = pass**. Dùng khi logic test phức tạp, đặc thù, không generic hoá được.
- **Severity**: `error` (default, fail cả pipeline) vs `warn` (log cảnh báo, không fail) — hữu ích khi test còn "thử nghiệm".
- `dbt build` = chạy seed + run + test + snapshot theo đúng thứ tự dependency (thay vì gọi riêng từng lệnh).

## Việc cần làm

1. Thêm test cho marts trong `models/marts/schema.yml` (file bạn tự tạo):
   - `fct_orders.customer_id` → test `relationships` tới `dim_customers.customer_id` (đảm bảo không có order "mồ côi").
   - `fct_orders.product_id` → test `relationships` tới `dim_products.product_id`.
   - `dim_customers.lifetime_value` → test `not_null`.

2. Viết 1 singular test `tests/assert_no_negative_order_amounts.sql`:
   ```sql
   select *
   from {{ ref('fct_orders') }}
   where total_amount < 0 or quantity <= 0
   ```
   (query trả 0 dòng = pass — không có order với số tiền âm hoặc số lượng ≤ 0).

3. Thử đổi 1 test sang `severity: warn` (ví dụ `accepted_values` của `tier` trong `stg_customers`), cố tình đưa 1 giá trị tier lạ vào data (dùng cách `update public.enriched_orders` như ở bài 04), chạy `dbt test` và quan sát: log có `WARN` màu vàng nhưng exit code vẫn 0 (không fail pipeline). Đừng quên sửa lại data gốc sau đó.

4. Chạy `dbt build` thay vì gọi tay từng lệnh, xem thứ tự thực thi trong log.

## Checkpoint
- [ ] `dbt test` chạy hết các test trên, PASS.
- [ ] Bạn tái hiện được 1 `WARN` không làm fail pipeline, và giải thích khi nào nên dùng `warn` thay vì `error`.
- [ ] Bạn hiểu sự khác nhau generic vs singular test — khi nào chọn cái nào.

Đi tiếp sang [07_incremental_models.md](07_incremental_models.md).
