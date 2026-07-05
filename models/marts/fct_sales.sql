-- Grain: one row per order item (the sales line level)
select
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    o.customer_id,
    o.order_date,
    o.order_status,
    oi.price,
    oi.freight_value,
    oi.gross_item_value
from {{ ref('stg_order_items') }} oi
inner join {{ ref('stg_orders') }} o
    on oi.order_id = o.order_id
