# Analytics Engineer Learning Project — Airflow + dbt

Một project thực hành để học Airflow + dbt theo kiểu "học qua làm": Airflow chạy local bằng Docker, dbt build vào schema `analytical_engineer` của **Postgres thật** (`fox_dwh`) trên máy bạn, dùng data thật (`public.enriched_orders`) — không phải data giả lập.

## Bắt đầu nhanh

```bash
# 1. Đảm bảo Postgres local (fox_dwh) đang chạy
brew services list | grep postgresql

# 2. Dựng Airflow
docker compose up -d --build
```

Sau đó mở http://localhost:8080 (đăng nhập `admin` / `admin`).

Rồi đi theo thứ tự trong [`exercises/`](exercises/), bắt đầu từ [00_prerequisites.md](exercises/00_prerequisites.md).

## Cấu trúc project

```
.
├── docker-compose.yml       # Airflow (LocalExecutor) + Postgres metadata DB
│                            #   (warehouse KHÔNG phải container — là fox_dwh thật trên host)
├── airflow/                 # Dockerfile custom cài dbt-postgres vào image Airflow chính thức
├── dags/                    # DAGs — có sẵn 1 DAG "hello world", còn lại bạn tự viết theo exercises
├── dbt/fox_analytics/       # dbt project
│   ├── seeds/               # tier_benefits.csv — lookup table tĩnh (tier -> discount)
│   ├── models/staging/      # đã build sẵn làm ví dụ mẫu (source: fox_dwh.public.enriched_orders)
│   ├── models/intermediate/ # trống — bạn tự xây ở bài 05
│   └── models/marts/        # trống — bạn tự xây ở bài 05
├── exercises/                # 00 → 09, đi theo thứ tự
└── solutions/                 # đáp án tham khảo cho bài 04 và 05 — chỉ mở khi bí
```

## Data & warehouse

- **Database**: `fox_dwh` (Postgres local, user/pass `fox_dwh`/`fox_dwh`).
- **Source (read-only)**: `public.enriched_orders` — 610 order thật do 1 pipeline khác của bạn tạo (Kafka/Flink), 1 bảng denormalized (customer + product + order gộp phẳng vào 1 bảng).
- **Target (dbt build vào đây)**: schema `analytical_engineer` — hoàn toàn tách biệt, không đụng tới `public` hay các schema khác (`app_dev`, `fox_payment`).
- Airflow chạy trong Docker, kết nối ra `fox_dwh` trên host qua `host.docker.internal` (xem `.env`).

## Lộ trình bài tập

| # | Chủ đề |
|---|---|
| 00 | Prerequisites & mental model (Airflow vs dbt làm gì) |
| 01 | Dựng môi trường, kiểm tra kết nối |
| 02 | Airflow basics: DAG, task, operator, retry |
| 03 | dbt basics: seed, source, ref, materialization |
| 04 | Orchestrate dbt bằng Airflow (BashOperator) |
| 05 | Tự xây layer intermediate + marts (star schema từ 1 bảng denormalized) |
| 06 | Testing: generic vs singular tests, severity |
| 07 | Incremental models |
| 08 | Source freshness, alerting, sensors |
| 09 | Capstone: ghép toàn bộ thành 1 pipeline hoàn chỉnh |

## Dừng / dọn dẹp

```bash
docker compose down          # dừng Airflow, giữ lại metadata DB
docker compose down -v       # dừng và xoá luôn metadata DB của Airflow (fox_dwh không bị ảnh hưởng)
```

fox_dwh là Postgres thật của bạn — không bị Docker quản lý, dừng/xoá độc lập qua `brew services`.
