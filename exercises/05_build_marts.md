# 05 - Build the Marts Layer

## Mục tiêu
Tự xây layer **intermediate** + **marts** — layer staging đã có sẵn làm mẫu, giờ đến lượt bạn biến `enriched_orders` (1 bảng phẳng) thành 1 star schema sạch.

## Việc cần làm

### 1. `models/intermediate/int_customer_order_stats.sql` (ephemeral)
Aggregate `stg_orders` về 1 dòng / customer.

Cột cần có: `customer_id`, `number_of_orders`, `lifetime_value` (tổng `total_amount`), `first_order_at`, `most_recent_order_at`.

### 2. `models/marts/dim_customers.sql` (table)
Join `stg_customers` + `int_customer_order_stats` + seed `tier_benefits` (join theo `tier`).

Cột cần có: `customer_id`, `customer_name`, `email`, `city`, `tier`, `loyalty_points`, `discount_pct`, `free_shipping`, `number_of_orders`, `lifetime_value`, `first_order_at`, `most_recent_order_at`.

### 3. `models/marts/dim_products.sql` (table)
Join `stg_products` với `stg_orders`, group theo product.

Cột cần có: `product_id`, `product_name`, `times_ordered`, `total_units_sold`, `total_revenue`.

### 4. `models/marts/fct_orders.sql` (table)
Về cơ bản là `stg_orders` — vì "phần khó" (tách customer/product ra) đã xử lý ở staging + các dim rồi.

Cột cần có: `order_id`, `customer_id`, `product_id`, `quantity`, `total_amount`, `ordered_at`.

### 5. Chạy & kiểm tra
```bash
dbt run
```
rồi query:
```sql
select * from analytical_engineer.dim_customers order by lifetime_value desc;
select * from analytical_engineer.dim_products order by total_revenue desc;
```

Nếu bí, xem đáp án tham khảo ở [`solutions/05_marts/`](../solutions/05_marts/) — nhưng hãy tự thử trước, kể cả nếu SQL bạn viết ra khác cách trong solutions cũng không sao, miễn đúng kết quả.

## Checkpoint
- [ ] `dbt run` build được `int_customer_order_stats` (ephemeral, không tạo object trong DB — kiểm tra bằng `\dt analytical_engineer.*` sẽ không thấy nó), `dim_customers`, `dim_products`, `fct_orders`.
- [ ] `lifetime_value` của 1 vài customer khớp với tính tay bằng SQL thô (`select sum(total_amount) from analytical_engineer.stg_orders where customer_id = ...`).
- [ ] Bạn giải thích được vì sao 10 customer nhưng có customer `n_loyalty=2` (loyalty_points đổi giữa các order) lại là lý do staging cần logic "lấy dòng mới nhất" thay vì join thẳng vào raw.

Đi tiếp sang [06_testing_and_data_quality.md](06_testing_and_data_quality.md).
