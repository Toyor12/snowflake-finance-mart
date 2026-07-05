-- Grain: one row per order with item revenue and payment totals reconciled
with items as (

    select
        order_id,
        count(*) as item_count,
        sum(price) as items_revenue,
        sum(freight_value) as freight_revenue,
        sum(gross_item_value) as gross_order_value
    from {{ ref('stg_order_items') }}
    group by order_id

),

payments as (

    select
        order_id,
        sum(payment_value) as total_paid
    from {{ ref('stg_payments') }}
    group by order_id

)

select
    orders.order_id,
    orders.customer_id,
    orders.order_status,
    orders.order_date,
    items.item_count,
    items.items_revenue,
    items.freight_revenue,
    items.gross_order_value,
    payments.total_paid,
    round(
        coalesce(payments.total_paid, 0)
        - coalesce(items.gross_order_value, 0),
        2
    ) as payment_variance
from {{ ref('stg_orders') }} as orders
left join items
    on orders.order_id = items.order_id
left join payments
    on orders.order_id = payments.order_id
