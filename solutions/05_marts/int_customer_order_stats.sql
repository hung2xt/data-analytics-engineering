-- Reference solution: models/intermediate/int_customer_order_stats.sql
-- Aggregates order lines to one row per customer.

with orders as (
    select * from {{ ref('stg_orders') }}
)

select
    customer_id,
    count(order_id) as number_of_orders,
    sum(total_amount) as lifetime_value,
    min(ordered_at) as first_order_at,
    max(ordered_at) as most_recent_order_at
from orders
group by 1
