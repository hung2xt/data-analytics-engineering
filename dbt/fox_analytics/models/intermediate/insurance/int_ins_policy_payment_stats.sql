with payments as (
    select * from {{ ref('stg_ins_premium_payments') }}
)

select
    policy_id,
    count(*) as installments_count,
    sum(amount_due) as total_amount_due,
    sum(amount_paid) as total_amount_paid,
    count(*) filter (where payment_status = 'MISSED') as missed_count,
    count(*) filter (where payment_status = 'PARTIAL') as partial_count,
    max(paid_date) as last_paid_date
from payments
group by 1
