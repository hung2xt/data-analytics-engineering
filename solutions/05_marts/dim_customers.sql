-- Reference solution: models/marts/dim_customers.sql

with customers as (
    select * from {{ ref('stg_customers') }}
),

order_stats as (
    select * from {{ ref('int_customer_order_stats') }}
),

tier_benefits as (
    select * from {{ ref('tier_benefits') }}
)

select
    customers.customer_id,
    customers.customer_name,
    customers.email,
    customers.city,
    customers.tier,
    customers.loyalty_points,
    tier_benefits.discount_pct,
    tier_benefits.free_shipping,
    coalesce(order_stats.number_of_orders, 0) as number_of_orders,
    coalesce(order_stats.lifetime_value, 0) as lifetime_value,
    order_stats.first_order_at,
    order_stats.most_recent_order_at
from customers
left join order_stats
    on customers.customer_id = order_stats.customer_id
left join tier_benefits
    on customers.tier = tier_benefits.tier
