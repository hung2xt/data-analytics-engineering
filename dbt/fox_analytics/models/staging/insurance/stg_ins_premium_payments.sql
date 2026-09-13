select
    payment_id,
    policy_id,
    due_date,
    paid_date,
    amount_due,
    amount_paid,
    payment_status
from {{ source('policy_admin', 't_premium_payment') }}
