select
    customer_id,
    full_name,
    dob,
    gender,
    city,
    phone,
    email,
    occupation_class
from {{ source('policy_admin', 't_customer') }}
