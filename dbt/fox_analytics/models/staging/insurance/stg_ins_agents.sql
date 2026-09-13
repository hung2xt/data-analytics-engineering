select
    agent_id,
    full_name as agent_name,
    region,
    hire_date,
    agent_status
from {{ source('policy_admin', 't_agent') }}
