-- Grain: one row per order item, the sales line level
select
    order_items.order_id,
    order_items.order_item_id,
    order_items.product_id,
    orders.customer_id,
    orders.order_date,
    orders.order_status,
    order_items.price,
    order_items.freight_value,
    order_items.gross_item_value
from {{ ref('stg_order_items') }} as order_items
inner join {{ ref('stg_orders') }} as orders
    on order_items.order_id = orders.order_id
