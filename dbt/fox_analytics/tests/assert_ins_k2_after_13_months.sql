/*
  Singular test: k2_passed must only ever be set (true/false) for policies
  with months_active >= 13. A policy can't have a verdict on a persistency
  checkpoint it hasn't reached yet.
*/
select policy_id, months_active, k2_passed
from {{ ref('fct_policies') }}
where k2_passed is not null
  and months_active < 13
