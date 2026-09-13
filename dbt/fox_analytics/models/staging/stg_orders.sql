select
    order_id,
    customer_id,
    product_id,
    quantity,
    total_amount::numeric(12, 2) as total_amount,
    created_at::timestamp as ordered_at
from {{ source('fox_dwh', 'enriched_orders') }}
