with policies as (
    select * from {{ ref('stg_ins_policies') }}
)

select
    customer_id,
    count(policy_id) as number_of_policies,
    count(policy_id) filter (where policy_status = 'ACTIVE') as active_policy_count,
    sum(annual_premium) as total_annual_premium,
    sum(annual_premium) filter (where policy_status = 'ACTIVE') as active_annual_premium
from policies
group by 1
