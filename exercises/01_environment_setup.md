# 01 - Environment Setup

## Mục tiêu
Dựng được Airflow chạy local qua Docker, xác nhận dbt (bên trong container) kết nối được ra Postgres thật (`fox_dwh`) trên host.

## Việc cần làm

1. Đảm bảo Postgres local đang chạy:
   ```bash
   brew services list | grep postgresql
   psql -h 127.0.0.1 -p 5432 -U fox_dwh -d fox_dwh -c "select 1;"
   ```
   (password: xem giá trị `DW_PASSWORD` trong file `.env` cục bộ của bạn — không commit file này). Nếu fail, xem lại phần "Nếu gặp lỗi" bên dưới.

2. Build & khởi động Airflow:
   ```bash
   docker compose up -d --build
   ```
   Lần đầu `airflow-init` sẽ chạy migrate DB + tạo user admin/admin rồi thoát (exit code 0 là thành công).

3. Kiểm tra các container đang chạy:
   ```bash
   docker compose ps
   ```
   Bạn cần thấy `postgres` (metadata DB của Airflow), `airflow-webserver`, `airflow-scheduler` đều `healthy`/`Up`. Lưu ý: **không có container `warehouse`** — warehouse của project này là Postgres thật ngoài host.

4. Mở Airflow UI: http://localhost:8080 — đăng nhập `admin` / `admin`.
   Bạn sẽ thấy DAG `00_hello_airflow` trong danh sách (chưa cần chạy vội, để dành bài 02).

5. Xác nhận dbt (chạy trong container) kết nối được ra `fox_dwh` trên host:
   ```bash
   docker compose exec airflow-scheduler bash
   cd $DBT_PROFILES_DIR
   dbt debug
   ```
   Kỳ vọng: `All checks passed!`. Đây chính là điểm hay của bài này: container gọi ra ngoài host qua `host.docker.internal` — pattern thường gặp khi dev local nhưng muốn Airflow chạy trong Docker.

## Checkpoint
- [ ] `psql` connect được `fox_dwh` từ host.
- [ ] `docker compose ps` cho thấy các service Airflow đều up.
- [ ] Đăng nhập được Airflow UI.
- [ ] `dbt debug` (chạy trong container) báo "All checks passed!".

## Nếu gặp lỗi

- **Postgres local không chạy / connection refused**: thường do stale `postmaster.pid`. Kiểm tra:
  ```bash
  brew services info postgresql@14
  tail -n 20 /usr/local/var/log/postgresql@14.log
  ```
  Nếu log báo `lock file "postmaster.pid" already exists` nhưng PID đó không phải postgres thật (`ps -p <pid>`), xoá file rồi restart:
  ```bash
  rm /usr/local/var/postgresql@14/postmaster.pid
  brew services restart postgresql@14
  ```
- **`dbt debug` báo không connect được `host.docker.internal`**: trên Docker Desktop (macOS/Windows) tên này tự resolve về host, không cần cấu hình gì thêm. Nếu bạn chạy Docker Engine trên Linux thuần, `extra_hosts` trong `docker-compose.yml` đã map sẵn — nếu vẫn lỗi, thử đổi `DW_HOST` trong `.env` sang IP thật của host.
- Port 8080 bị chiếm: sửa port mapping trong `docker-compose.yml`.
- `airflow-init` fail: xem log bằng `docker compose logs airflow-init`.

Đi tiếp sang [02_airflow_basics.md](02_airflow_basics.md).
