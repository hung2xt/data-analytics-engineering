select
    product_code,
    product_name,
    product_type,
    premium_term_years,
    min_sum_assured
from {{ source('policy_admin', 't_product') }}
