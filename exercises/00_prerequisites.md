# 00 - Prerequisites & Mental Model

## Cần cài trước
- Docker Desktop (hoặc Colima/OrbStack) với ít nhất ~4GB RAM rảnh cho containers.
- Postgres local (`fox_dwh`) đang chạy trên máy — Airflow/dbt chạy trong Docker sẽ kết nối ra ngoài vào đây qua `host.docker.internal`.
- `psql` hoặc bất kỳ SQL client nào (DBeaver, TablePlus...) để soi warehouse — không bắt buộc nhưng rất tiện.
- Không cần cài Python/dbt/Airflow trên máy host — mọi thứ chạy trong Docker.

## Vì sao Airflow + dbt đi cùng nhau?

- **dbt** trả lời câu hỏi "transform data như thế nào" — nó biết cách build models, chạy tests, quản lý dependency giữa các model (qua `ref()`), nhưng **dbt không tự chạy theo lịch, không biết đợi data khác load xong**.
- **Airflow** trả lời câu hỏi "khi nào và theo thứ tự nào" — nó orchestrate: chờ file/table nguồn sẵn sàng, chạy ingestion, rồi mới gọi `dbt run`, rồi gửi alert nếu fail, rồi trigger job downstream (BI refresh, ML feature...).

Project này dùng **data thật** của bạn: database `fox_dwh` (Postgres local), bảng `public.enriched_orders` (610 dòng order thật, do 1 pipeline Kafka/Flink khác của bạn tạo ra). Đây là 1 bảng "denormalized" — thông tin customer + product + order bị gộp phẳng vào cùng 1 bảng, rất giống cách data thực tế hay được export ra từ hệ thống operational. Việc của bạn: dùng dbt để tách nó lại thành 1 star schema sạch (`dim_customers`, `dim_products`, `fct_orders`), build vào schema riêng `analytical_engineer` (không đụng vào `public`), rồi dùng Airflow orchestrate toàn bộ.

## Cấu trúc project

```
analytics-engineer/
├── docker-compose.yml       # Airflow (LocalExecutor) — warehouse là Postgres local thật, không phải container
├── airflow/                 # Dockerfile cài dbt-postgres vào image Airflow
├── dags/                    # DAGs bạn viết
├── dbt/fox_analytics/       # dbt project — source: fox_dwh.public.enriched_orders, target: schema analytical_engineer
│                            #   (staging đã có sẵn làm ví dụ mẫu, marts để bạn tự xây)
├── exercises/               # bộ bài tập này
└── solutions/               # đáp án tham khảo — chỉ mở khi bí!
```

Đi tiếp sang [01_environment_setup.md](01_environment_setup.md).
