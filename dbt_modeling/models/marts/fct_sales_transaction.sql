{{
    config(
        materialized='incremental',
        unique_key='order_line_id',
        incremental_strategy='merge',
        cluster_by=['order_date_key', 'customer_key']
    )
}}

{% set lookback_days = var('fact_sales_lookback_days', 3) %}

with order_lines as (

    select * from {{ ref('stg_northwind__order_details') }}

),

orders as (

    select * from {{ ref('stg_northwind__orders') }}

),

fct_sales_transaction as (

    select
        -- keys
        order_lines.id as order_line_id,

        -- degenerate dimensions
        orders.id as order_number,
        cast(orders.order_date as date) as order_date,

        -- foreign keys
        coalesce(dim_date_calendar.date_key, -1) as order_date_key,
        coalesce(dim_customer.customer_key, '-1') as customer_key,
        coalesce(dim_employee.employee_key, '-1') as employee_key,
        coalesce(dim_shipper.shipper_key, '-1') as shipper_key,
        coalesce(dim_product.product_key, '-1') as product_key,

        -- additive measures
        order_lines.quantity,
        order_lines.unit_price,
        order_lines.discount,
        order_lines.quantity * order_lines.unit_price as gross_amount,
        order_lines.quantity * order_lines.unit_price * (1 - order_lines.discount) as net_amount,

        -- metadata
        greatest(order_lines._loaded_at, orders.modified_at) as _loaded_at

    from order_lines
    inner join orders
        on order_lines.order_id = orders.id
    left join {{ ref('dim_date_calendar') }}
        on cast(orders.order_date as date) = dim_date_calendar.date_day
    left join {{ ref('dim_customer') }}
        on orders.customer_id = dim_customer.customer_id
    left join {{ ref('dim_employee') }}
        on orders.employee_id = dim_employee.employee_id
    left join {{ ref('dim_shipper') }}
        on orders.shipper_id = dim_shipper.shipper_id
    left join {{ ref('dim_product') }}
        on order_lines.product_id = dim_product.product_id

    {% if is_incremental() %}

    where greatest(order_lines._loaded_at, orders.modified_at) >= (
        select dateadd('day', -{{ lookback_days }}, max(_loaded_at)) from {{ this }}
    )

    {% endif %}

)

select * from fct_sales_transaction
