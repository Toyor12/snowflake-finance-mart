select
    order_id,
    customer_id,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    lower(order_status) as order_status,
    cast(order_purchase_timestamp as date) as order_date
from {{ source('raw', 'orders') }}
where order_id is not null
