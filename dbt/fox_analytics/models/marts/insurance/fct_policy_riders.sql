-- Bridge/fact table: 1 row per (policy, rider) — a policy can carry
-- multiple riders, so this is a many-to-one from rider up to policy.
select
    rider_id,
    policy_id,
    rider_type,
    rider_premium,
    sum_assured_rider,
    rider_status,
    effective_date
from {{ ref('stg_ins_riders') }}
