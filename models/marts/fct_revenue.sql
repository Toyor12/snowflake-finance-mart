-- Grain: one row per order, finance view with payment reconciliation
select
    order_id,
    customer_id,
    order_date,
    order_status,
    item_count,
    items_revenue,
    freight_revenue,
    gross_order_value,
    total_paid,
    payment_variance,
    case when abs(payment_variance) > 0.01 then true else false end as has_payment_mismatch
from {{ ref('int_order_revenue') }}
