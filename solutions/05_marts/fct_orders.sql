-- Reference solution: models/marts/fct_orders.sql
-- stg_orders is already clean/one-row-per-order-line, so the fact table is
-- mostly a pass-through here — the "modeling work" already happened in
-- staging (deduping customers, deriving products) and in the dims.

select
    order_id,
    customer_id,
    product_id,
    quantity,
    total_amount,
    ordered_at
from {{ ref('stg_orders') }}
