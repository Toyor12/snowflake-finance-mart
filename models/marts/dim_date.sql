with date_spine as (

    select
        dateadd(
            day,
            seq4(),
            to_date('2016-01-01')
        ) as date_day
    from table(generator(rowcount => 1096))

)

select
    date_day,
    extract(year from date_day) as year,
    extract(quarter from date_day) as quarter,
    extract(month from date_day) as month,
    monthname(date_day) as month_name,
    extract(dayofweek from date_day) as day_of_week
from date_spine
where date_day < to_date('2019-01-01')
