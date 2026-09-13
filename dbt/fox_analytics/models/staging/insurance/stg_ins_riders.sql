select
    rider_id,
    policy_id,
    rider_type,
    rider_premium,
    sum_assured_rider,
    rider_status,
    effective_date
from {{ source('policy_admin', 't_rider') }}
