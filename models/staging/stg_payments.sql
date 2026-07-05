with source as (
    select * from {{ source('raw', 'payments') }}
)

select
    order_id,
    payment_sequential,
    lower(payment_type)  as payment_type,
    payment_installments,
    payment_value
from source
where order_id is not null
