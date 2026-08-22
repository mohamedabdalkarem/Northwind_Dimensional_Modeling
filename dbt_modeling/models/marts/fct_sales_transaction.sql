with order_lines as (

    select * from {{ ref('stg_northwind__order_details') }}

),

orders as (

    select * from {{ ref('stg_northwind__orders') }}

),

fct_sales_transaction as (

    select
        -- degenerate dimension
        orders.id as order_number,

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
        order_lines.quantity * order_lines.unit_price * (1 - order_lines.discount) as net_amount

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

)

select * from fct_sales_transaction
