{{
    config(
        materialized='view'
    )
}}

with sales as (

    select
        f.order_line_id,
        f.order_number,
        f.order_date,
        f.order_date_key,
        f.customer_key,
        f.employee_key,
        f.shipper_key,
        f.product_key,
        f.quantity,
        f.unit_price,
        f.discount,
        f.gross_amount,
        f.net_amount,
        f._loaded_at

    from {{ ref('fct_sales_transaction') }} f

),

customer as (
    select * from {{ ref('dim_customer') }} where customer_key != '-1'
),

employee as (
    select * from {{ ref('dim_employee') }} where employee_key != '-1'
),

shipper as (
    select * from {{ ref('dim_shipper') }} where shipper_key != '-1'
),

product as (
    select * from {{ ref('dim_product') }} where product_key != '-1'
),

order_date as (
    select * from {{ ref('dim_date_calendar') }} where date_key != -1
)

select
    s.order_line_id,
    s.order_number,
    s.order_date,
    s.quantity,
    s.unit_price,
    s.discount,
    s.gross_amount,
    s.net_amount,

    -- customer
    c.company_name as customer_company,
    c.contact_full_name as customer_contact,
    c.city as customer_city,
    c.state_province as customer_state,
    c.country_region as customer_country,
    c.email_address as customer_email,

    -- employee
    e.full_name as employee_name,
    e.job_title as employee_title,
    e.city as employee_city,
    e.country_region as employee_country,

    -- shipper
    sh.company_name as shipper_company,
    sh.contact_full_name as shipper_contact,

    -- product
    p.product_code,
    p.product_name,
    p.category as product_category,
    p.standard_cost,
    p.list_price,
    p.discontinued as product_discontinued,

    -- order date attributes
    od.year_number as order_year,
    od.month_of_year as order_month,
    od.quarter_of_year as order_quarter,
    od.iso_week_of_year as order_iso_week,
    od.day_name as order_day_name,
    od.is_weekend as order_is_weekend,
    od.is_holiday as order_is_holiday,

    s._loaded_at

from sales s
left join customer c on s.customer_key = c.customer_key
left join employee e on s.employee_key = e.employee_key
left join shipper sh on s.shipper_key = sh.shipper_key
left join product p on s.product_key = p.product_key
left join order_date od on s.order_date_key = od.date_key