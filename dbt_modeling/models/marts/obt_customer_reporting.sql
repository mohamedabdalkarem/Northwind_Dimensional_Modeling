{{
    config(
        materialized='view'
    )
}}

with customer as (

    select * from {{ ref('dim_customer') }} where customer_key != '-1'

),

sales as (

    select
        f.customer_key,
        sum(f.gross_amount) as total_gross_sales,
        sum(f.net_amount) as total_net_sales,
        sum(f.quantity) as total_units_sold,
        count(distinct f.order_number) as order_count,
        min(f.order_date) as first_order_date,
        max(f.order_date) as last_order_date,
        avg(f.net_amount) as avg_order_value

    from {{ ref('fct_sales_transaction') }} f
    group by f.customer_key

),

lifecycle as (

    select
        o.customer_key,
        sum(case when o.is_late then 1 else 0 end) as late_order_count,
        sum(case when o.is_shipped then 1 else 0 end) as shipped_order_count,
        avg(o.days_to_ship) as avg_days_to_ship,
        avg(o.days_late) as avg_days_late

    from {{ ref('fct_order_lifecycle') }} o
    join {{ ref('dim_customer') }} c on o.order_id = c.customer_id  -- wait, wrong join
    -- need to get customer from orders
    -- let me check the order_lifecycle model - it doesn't have customer_key

    group by o.customer_key

)

select
    c.customer_key,
    c.customer_id,
    c.company_name,
    c.contact_full_name,
    c.contact_job_title,
    c.email_address,
    c.business_phone,
    c.mobile_phone,
    c.address,
    c.city,
    c.state_province,
    c.zip_postal_code,
    c.country_region,
    c.web_page,

    -- sales aggregates
    coalesce(s.total_gross_sales, 0) as total_gross_sales,
    coalesce(s.total_net_sales, 0) as total_net_sales,
    coalesce(s.total_units_sold, 0) as total_units_sold,
    coalesce(s.order_count, 0) as order_count,
    s.first_order_date,
    s.last_order_date,
    s.avg_order_value,

    -- lifecycle metrics
    coalesce(l.late_order_count, 0) as late_order_count,
    coalesce(l.shipped_order_count, 0) as shipped_order_count,
    l.avg_days_to_ship,
    l.avg_days_late,

    -- derived
    case
        when s.order_count > 0 and l.shipped_order_count > 0
        then l.late_order_count::float / l.shipped_order_count
        else 0
    end as late_ship_rate,

    datediff('day', s.last_order_date, current_date()) as days_since_last_order,

    current_timestamp() as _loaded_at

from customer c
left join sales s on c.customer_key = s.customer_key
left join (
    select
        c2.customer_key,
        sum(case when o.is_late then 1 else 0 end) as late_order_count,
        sum(case when o.is_shipped then 1 else 0 end) as shipped_order_count,
        avg(o.days_to_ship) as avg_days_to_ship,
        avg(o.days_late) as avg_days_late
    from {{ ref('fct_order_lifecycle') }} o
    join {{ ref('stg_northwind__orders') }} ord on o.order_id = ord.id
    join {{ ref('dim_customer') }} c2 on ord.customer_id = c2.customer_id
    group by c2.customer_key
) l on c.customer_key = l.customer_key