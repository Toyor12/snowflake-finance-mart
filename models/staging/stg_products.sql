with source as (
    select * from {{ source('raw', 'products') }}
)

select
    product_id,
    coalesce(product_category_name, 'unknown') as product_category,
    product_weight_g
from source
where product_id is not null
