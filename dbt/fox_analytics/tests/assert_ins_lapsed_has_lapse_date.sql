/*
  Singular test: every LAPSED policy must have a lapse_date.
  Missing lapse_date on a lapsed policy = data quality issue.
*/
select policy_id, policy_status, lapse_date
from {{ ref('fct_policies') }}
where is_lapsed = true
  and lapse_date is null
