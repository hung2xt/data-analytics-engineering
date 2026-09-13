with policies as (
    select * from {{ ref('stg_ins_policies') }}
)

select
    agent_id,
    count(policy_id) as policies_sold,
    count(policy_id) filter (where policy_status = 'ACTIVE') as active_policies,
    count(policy_id) filter (where policy_status = 'LAPSED') as lapsed_policies,
    sum(annual_premium) as total_annual_premium_sold
from policies
group by 1
