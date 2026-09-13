select distinct
    product_id,
    product_name
from {{ source('fox_dwh', 'enriched_orders') }}
