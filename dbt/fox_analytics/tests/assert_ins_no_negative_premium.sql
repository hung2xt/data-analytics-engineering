/*
  Singular test: no policy should have a negative annual_premium, and no
  premium payment should have a negative amount_paid.
*/
select policy_id, annual_premium
from {{ ref('fct_policies') }}
where annual_premium < 0

union all

select payment_id, amount_paid
from {{ ref('fct_premium_payments') }}
where amount_paid < 0
