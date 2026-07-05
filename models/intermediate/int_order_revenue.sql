-- One row per order with item revenue and payment totals reconciled
with items as (
    select
        order_id,
        count(*)               as item_count,
        sum(price)             as items_revenue,
        sum(freight_value)     as freight_revenue,
        sum(gross_item_value)  as gross_order_value
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
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_date,
    i.item_count,
    i.items_revenue,
    i.freight_revenue,
    i.gross_order_value,
    p.total_paid,
    round(coalesce(p.total_paid, 0) - coalesce(i.gross_order_value, 0), 2) as payment_variance
from {{ ref('stg_orders') }} o
left join items i    on o.order_id = i.order_id
left join payments p on o.order_id = p.order_id
