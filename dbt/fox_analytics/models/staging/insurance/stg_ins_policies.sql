with policies as (
    select
        policy_id,
        policy_number,
        customer_id,
        agent_id,
        product_code,
        issue_date,
        policy_status,
        premium_frequency,
        annual_premium,
        sum_assured,
        lapse_date,
        updated_at
    from {{ source('policy_admin', 't_policy') }}
)

select
    *,
    policy_status = 'LAPSED' as is_lapsed,
    -- policy age in months since issue, regardless of status — used to know
    -- whether a persistency checkpoint (K2 @ 13 months) is even evaluable yet
    (
        extract(year from age(current_date, issue_date)) * 12
        + extract(month from age(current_date, issue_date))
    )::int as months_active,
    -- only meaningful for lapsed policies: how long it survived before lapsing
    case
        when lapse_date is not null then
            (
                extract(year from age(lapse_date, issue_date)) * 12
                + extract(month from age(lapse_date, issue_date))
            )::int
    end as months_to_lapse
from policies
