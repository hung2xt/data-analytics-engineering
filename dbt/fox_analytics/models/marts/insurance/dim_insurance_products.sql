with products as (
    select * from {{ ref('stg_ins_products') }}
),

tier_mapping as (
    select * from {{ ref('insurance_product_tier') }}
),

policies as (
    select * from {{ ref('stg_ins_policies') }}
),

sales as (
    select
        product_code,
        count(policy_id) as policies_sold,
        sum(sum_assured) as total_sum_assured
    from policies
    group by 1
)

select
    products.product_code,
    products.product_name,
    products.product_type,
    products.premium_term_years,
    products.min_sum_assured,
    tier_mapping.tier_label,
    tier_mapping.is_flagship,
    coalesce(sales.policies_sold, 0) as policies_sold,
    coalesce(sales.total_sum_assured, 0) as total_sum_assured
from products
left join tier_mapping
    on products.product_code = tier_mapping.product_code
left join sales
    on products.product_code = sales.product_code
