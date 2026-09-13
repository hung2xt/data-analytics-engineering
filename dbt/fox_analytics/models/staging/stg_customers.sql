-- enriched_orders is denormalized: customer attributes (tier, loyalty_points)
-- repeat on every order line for that customer, and can drift between lines
-- (loyalty_points changes as new orders come in). We keep the most recent
-- value per customer_id, ranked by created_at.

with ranked as (
    select
        customer_id,
        customer_name,
        email,
        city,
        tier,
        loyalty_points,
        row_number() over (
            partition by customer_id
            order by created_at desc
        ) as rn
    from {{ source('fox_dwh', 'enriched_orders') }}
)

select
    customer_id,
    customer_name,
    email,
    city,
    tier,
    loyalty_points
from ranked
where rn = 1
