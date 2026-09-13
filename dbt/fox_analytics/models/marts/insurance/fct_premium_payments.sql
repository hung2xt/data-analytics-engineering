select
    payment_id,
    policy_id,
    due_date,
    paid_date,
    amount_due,
    amount_paid,
    payment_status,
    amount_due - amount_paid as amount_shortfall
from {{ ref('stg_ins_premium_payments') }}
