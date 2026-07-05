with source as (
    select * from {{ source('raw', 'orders') }}
)

select
    order_id,
    customer_id,
    lower(order_status)                as order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    cast(order_purchase_timestamp as date) as order_date
from source
where order_id is not null
