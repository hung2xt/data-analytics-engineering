-- Reference solution: models/marts/dim_products.sql

with products as (
    select * from {{ ref('stg_products') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
)

select
    products.product_id,
    products.product_name,
    count(orders.order_id) as times_ordered,
    coalesce(sum(orders.quantity), 0) as total_units_sold,
    coalesce(sum(orders.total_amount), 0) as total_revenue
from products
left join orders
    on products.product_id = orders.product_id
group by 1, 2
