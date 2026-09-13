# 08 - Source Freshness, Sensors & Alerting

## dbt source freshness
`dbt/fox_analytics/models/staging/sources.yml` đã khai báo freshness cho `enriched_orders`:
```yaml
loaded_at_field: created_at
freshness:
  warn_after: {count: 7, period: day}
  error_after: {count: 30, period: day}
```
`enriched_orders` là data thật nhưng đứng yên từ lúc bạn tạo nó (không có order mới đổ về liên tục) — nếu đã hơn 30 ngày kể từ `created_at` mới nhất, đây chính xác là tình huống thật: nguồn data ngừng update và cần được cảnh báo, không phải bug.

## Việc cần làm

1. Chạy thử:
   ```bash
   dbt source freshness
   ```
   Quan sát output: nếu `enriched_orders` đã "cũ" quá ngưỡng, nó sẽ báo `ERROR`/`WARN` — đây là hành vi **đúng như mong đợi**, không phải bug. Nếu bạn vừa mới insert order test ở bài 07 và quên xoá, freshness có thể còn `PASS` — hãy chắc bạn đã dọn dẹp.

2. Thêm task `dbt_source_freshness` vào đầu DAG `04_dbt_pipeline` (trước `dbt_seed`), dùng `BashOperator` gọi `dbt source freshness`. Đặt `retries=0` và quan sát task này fail đỏ mà không chặn bạn hiểu vì sao (task tiếp theo `dbt_seed` không nên phụ thuộc kết quả freshness ở bài tập này — set `trigger_rule="all_done"` cho `dbt_seed` nếu bạn muốn pipeline vẫn tiếp tục sau khi freshness fail, để mô phỏng "cảnh báo nhưng không chặn" — hoặc để mặc định chặn, tuỳ bạn muốn mô phỏng tình huống nào).

3. Thêm `on_failure_callback` cho DAG hoặc 1 task cụ thể — 1 Python function đơn giản `print(f"ALERT: {context['task_instance'].task_id} failed!")` để mô phỏng gửi Slack/email thật (không cần tích hợp Slack thật, chỉ cần hiểu cơ chế callback).

4. (Đọc hiểu, không bắt buộc code) Tìm hiểu `ExternalTaskSensor` — dùng khi 1 DAG cần chờ 1 DAG khác (ví dụ DAG ingestion) chạy xong trước khi bắt đầu, thay vì đoán giờ bằng `schedule`.

## Checkpoint
- [ ] Bạn chạy được `dbt source freshness` và đọc hiểu output ERROR/WARN/PASS.
- [ ] DAG của bạn có 1 callback in ra "ALERT" khi 1 task fail.
- [ ] Bạn giải thích được khi nào dùng Sensor thay vì chỉ dựa vào `schedule`/thời gian cố định.

Đi tiếp sang [09_capstone_project.md](09_capstone_project.md).
