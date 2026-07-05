select
    order_id,
    payment_sequential,
    payment_installments,
    payment_value,
    lower(payment_type) as payment_type
from {{ source('raw', 'payments') }}
where order_id is not null
