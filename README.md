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
├── dags/                    # DAGs
│   ├── 00_hello_airflow.py       # sanity-check DAG
│   └── 10_policy_mart_pipeline.py # orchestrate domain policy: refresh source -> dbt seed/run/test
├── scripts/
│   ├── generate_policy_admin_source.py # tạo schema policy_admin + data giả lập (customers/agents/products/policies/premium_payments/riders)
│   └── test_ci_locally.sh              # test CI workflow trên 1 DB tạm, không đụng fox_dwh thật
├── dbt/fox_analytics/       # dbt project (2 domain cùng chung 1 project, build vào cùng schema analytical_engineer)
│   ├── seeds/               # tier_benefits.csv, insurance_product_tier.csv — lookup table tĩnh
│   ├── models/staging/      # domain "orders" (mẫu có sẵn) + models/staging/insurance/ (domain policy, build sẵn)
│   ├── models/intermediate/ # domain "orders" trống (bài 05) + models/intermediate/insurance/ (build sẵn)
│   └── models/marts/        # domain "orders" trống (bài 05) + models/marts/insurance/ (build sẵn)
├── ci/fixtures/             # fixture data cho GitHub Actions (domain orders) — xem .github/workflows/ci.yml
├── exercises/                # 00 → 09, đi theo thứ tự
└── solutions/                 # đáp án tham khảo cho bài 04 và 05 — chỉ mở khi bí
```

## Data & warehouse

- **Database**: `fox_dwh` (Postgres local, user/pass `fox_dwh`/`fox_dwh`).
- **Domain "orders"** — source (read-only): `public.enriched_orders` — 610 order thật do 1 pipeline khác của bạn tạo (Kafka/Flink), 1 bảng denormalized (customer + product + order gộp phẳng vào 1 bảng). Đây là domain dùng cho các bài tập 00-09.
- **Domain "insurance"** (data mart mô phỏng cho life insurance policy) — source (read-only): schema `policy_admin` (`t_customer`, `t_agent`, `t_product`, `t_policy`, `t_premium_payment`, `t_rider`) — data giả lập bởi `scripts/generate_policy_admin_source.py`, đứng vai một Policy Administration System thật. Transformation build sẵn đầy đủ: `dim_policyholders`, `dim_agents`, `dim_insurance_products`, `fct_policies` (có tính `k2_passed` — mốc persistency 13 tháng), `fct_premium_payments`, `fct_policy_riders`. Orchestrate bằng DAG `10_policy_mart_pipeline`.
- **Target (dbt build vào đây)**: schema `analytical_engineer` — cả 2 domain cùng build vào đây (tên model không trùng nhau), hoàn toàn tách biệt khỏi `public`/`policy_admin` và các schema khác (`app_dev`, `fox_payment`).
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

## CI/CD

`.github/workflows/ci.yml` chạy trên mỗi push/PR vào `main`:
- **lint-and-validate**: `ruff` lint cho `dags/`, `solutions/`, `scripts/`; validate `docker-compose.yml`.
- **dbt-build**: dựng 1 Postgres service container tạm (không phải fox_dwh thật), load fixture cho domain orders (`ci/fixtures/enriched_orders_seed.sql`) + chạy `scripts/generate_policy_admin_source.py` cho domain insurance, rồi `dbt build` toàn bộ project.

Test workflow này ngay trên máy (không cần đợi GitHub Actions) bằng `scripts/test_ci_locally.sh` — nó tạo 1 database tạm `ci_test_db`, làm y hệt CI, rồi tự xoá, không đụng vào `fox_dwh` thật.

## Dừng / dọn dẹp

```bash
docker compose down          # dừng Airflow, giữ lại metadata DB
docker compose down -v       # dừng và xoá luôn metadata DB của Airflow (fox_dwh không bị ảnh hưởng)
```

fox_dwh là Postgres thật của bạn — không bị Docker quản lý, dừng/xoá độc lập qua `brew services`.
