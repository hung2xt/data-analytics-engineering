with policies as (
    select * from {{ ref('stg_ins_policies') }}
),

payment_stats as (
    select * from {{ ref('int_ins_policy_payment_stats') }}
),

rider_stats as (
    select * from {{ ref('int_ins_policy_rider_stats') }}
)

select
    policies.policy_id,
    policies.policy_number,
    policies.customer_id,
    policies.agent_id,
    policies.product_code,
    policies.issue_date,
    policies.policy_status,
    policies.premium_frequency,
    policies.annual_premium,
    policies.sum_assured,
    policies.lapse_date,
    policies.is_lapsed,
    policies.months_active,

    coalesce(payment_stats.installments_count, 0) as installments_count,
    coalesce(payment_stats.total_amount_due, 0) as total_amount_due,
    coalesce(payment_stats.total_amount_paid, 0) as total_amount_paid,
    coalesce(payment_stats.missed_count, 0) as missed_installments_count,
    payment_stats.last_paid_date,

    coalesce(rider_stats.rider_count, 0) as rider_count,
    coalesce(rider_stats.active_rider_premium, 0) as active_rider_premium,

    -- K2 persistency checkpoint: did the policy stay in force through month 13?
    -- null = not old enough yet to tell (policy age < 13 months);
    -- once evaluable, always true or false (never left null).
    case
        when policies.months_active < 13 then null
        when policies.is_lapsed and policies.months_to_lapse < 13 then false
        else true
    end as k2_passed

from policies
left join payment_stats
    on policies.policy_id = payment_stats.policy_id
left join rider_stats
    on policies.policy_id = rider_stats.policy_id
