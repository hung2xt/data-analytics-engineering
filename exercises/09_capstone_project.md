# 09 - Capstone: Bring It All Together

## Mục tiêu
Ghép toàn bộ kỹ năng từ bài 01-08 thành 1 DAG production-style hoàn chỉnh, và (nếu muốn) mở rộng ra ngoài domain orders.

## Task chính

Xây `dags/09_capstone_pipeline.py`:

1. `check_source_freshness` (`dbt source freshness`).
2. `dbt_seed` (load `tier_benefits.csv`).
3. `dbt_run` — chỉ chạy marts sau khi staging build xong (dbt tự lo qua `ref()`, bạn không cần tự chia task theo layer).
4. `dbt_test`.
5. `notify_success` — 1 PythonOperator in ra tóm tắt (ví dụ số dòng trong `dim_customers`, `fct_orders` — query trực tiếp bằng `psycopg2`/hook trong Python, kết nối `fox_dwh` qua `host.docker.internal`).
6. Toàn bộ DAG có `on_failure_callback` báo lỗi (từ bài 08).
7. Đặt `schedule="@daily"` (dù chạy manual để test, nhưng mô phỏng đúng lịch chạy thật).

## Mở rộng (chọn 1-2 cái, tuỳ hứng)

- **Thêm 1 domain hoàn toàn khác**: `public` schema của `fox_dwh` còn có sẵn 1 bộ data NBA thật (`games`, `teams`, `players`, `player_seasons`, `game_details`, `arena`) — không liên quan gì tới `enriched_orders`. Thêm source + staging + marts riêng cho domain này (ví dụ `fct_games`, `dim_players` với thống kê điểm số trung bình theo mùa) trong cùng schema `analytical_engineer`. Đây là tình huống rất thật: 1 warehouse thường chứa nhiều domain nghiệp vụ khác nhau, không phải 1 project = 1 domain.
- **Airflow Connections**: thay vì hard-code `DW_*` qua env var trong `profiles.yml`, tạo 1 Postgres Connection trong Airflow UI, và inject vào dbt qua 1 `PythonOperator` generate `profiles.yml` động từ Connection lúc runtime (pattern gần với thực tế production hơn khi có nhiều environment dev/staging/prod).
- **astronomer-cosmos**: thử thay `BashOperator` bằng package [astronomer-cosmos](https://astronomer.github.io/astronomer-cosmos/) — nó tự parse `manifest.json` của dbt và tạo 1 task Airflow **cho từng model** (thay vì 1 task to gọi `dbt run` cho cả project), giúp bạn thấy được task nào fail chính xác, retry riêng từng model.
- **CI đơn giản**: viết 1 GitHub Action chạy `dbt build` mỗi lần push (dùng service container Postgres, seed data giả thay vì fox_dwh thật) để tự động hoá bài 01-06.

## Checkpoint cuối
- [ ] DAG capstone chạy xanh end-to-end, tự chứa (không cần bạn gõ tay lệnh nào trong terminal).
- [ ] Bạn có thể vẽ sơ đồ (trên giấy hoặc README riêng) giải thích toàn bộ luồng: source (`fox_dwh.public.enriched_orders`) → staging → intermediate → marts (`analytical_engineer`) → test → alert.
- [ ] Bạn tự tin giải thích trong phỏng vấn: "Airflow orchestrate, dbt transform" nghĩa là gì, và vì sao tách 2 tool thay vì gộp chung.

Chúc mừng — đến đây bạn đã có đủ nền tảng để làm việc như 1 Analytics Engineer thực thụ. Bước tiếp theo tự nhiên là học thêm: dbt semantic layer/MetricFlow, Airflow trên Kubernetes (KubernetesPodOperator), data quality tool khác (Great Expectations, Soda), và BI layer (Looker/Metabase/PowerBI) nối lên marts bạn vừa xây.
