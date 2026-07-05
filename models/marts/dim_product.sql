select
    product_id,
    product_category,
    product_weight_g
from {{ ref('stg_products') }}
