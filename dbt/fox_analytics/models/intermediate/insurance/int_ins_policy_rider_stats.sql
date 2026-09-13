with riders as (
    select * from {{ ref('stg_ins_riders') }}
)

select
    policy_id,
    count(*) as rider_count,
    sum(rider_premium) filter (where rider_status = 'ACTIVE') as active_rider_premium
from riders
group by 1
