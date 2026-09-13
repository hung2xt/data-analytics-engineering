with agents as (
    select * from {{ ref('stg_ins_agents') }}
),

performance as (
    select * from {{ ref('int_ins_agent_performance') }}
)

select
    agents.agent_id,
    agents.agent_name,
    agents.region,
    agents.hire_date,
    agents.agent_status,
    coalesce(performance.policies_sold, 0) as policies_sold,
    coalesce(performance.active_policies, 0) as active_policies,
    coalesce(performance.lapsed_policies, 0) as lapsed_policies,
    coalesce(performance.total_annual_premium_sold, 0) as total_annual_premium_sold
from agents
left join performance
    on agents.agent_id = performance.agent_id
