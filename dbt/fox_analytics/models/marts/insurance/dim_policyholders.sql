with customers as (
    select * from {{ ref('stg_ins_customers') }}
),

policy_stats as (
    select * from {{ ref('int_ins_customer_policy_stats') }}
)

select
    customers.customer_id,
    customers.full_name,
    customers.dob,
    customers.gender,
    customers.city,
    customers.occupation_class,
    coalesce(policy_stats.number_of_policies, 0) as number_of_policies,
    coalesce(policy_stats.active_policy_count, 0) as active_policy_count,
    coalesce(policy_stats.total_annual_premium, 0) as total_annual_premium,
    coalesce(policy_stats.active_annual_premium, 0) as active_annual_premium
from customers
left join policy_stats
    on customers.customer_id = policy_stats.customer_id
