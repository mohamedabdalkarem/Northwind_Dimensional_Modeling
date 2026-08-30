{{
    config(
        materialized='table',
        cluster_by=['snapshot_date_key', 'product_key']
    )
}}

with products as (

    select
        product_key,
        product_id,
        product_name,
        category,
        reorder_level,
        target_level,
        minimum_reorder_quantity,
        discontinued

    from {{ ref('dim_product') }}
    where product_key != '-1'

),

dates as (

    select
        date_key,
        date_day

    from {{ ref('dim_date_calendar') }}
    where date_key != -1

),

product_days as (

    select
        d.date_key   as snapshot_date_key,
        p.product_key,
        p.product_id,
        p.product_name,
        p.category,
        p.reorder_level,
        p.target_level,
        p.minimum_reorder_quantity,
        p.discontinued

    from dates d
    cross join products p

),

transactions as (

    select
        product_id,
        cast(transaction_created_date as date) as txn_date,
        transaction_type,
        quantity,
        case
            when transaction_type = 1 then quantity      -- Purchased
            when transaction_type = 2 then -quantity     -- Sold
            when transaction_type = 3 then 0             -- On Hold (no stock change)
            when transaction_type = 4 then -quantity     -- Waste
            else 0
        end as stock_delta

    from {{ ref('stg_northwind__inventory_transactions') }}

),

running_stock as (

    select
        pd.snapshot_date_key,
        pd.product_key,
        sum(t.stock_delta) over (
            partition by pd.product_key
            order by pd.snapshot_date_key
            rows unbounded preceding
        ) as units_in_stock

    from product_days pd
    left join transactions t
        on pd.product_id = t.product_id
        and t.txn_date <= pd.date_day

    where pd.snapshot_date_key <= (
        select max(date_key) from {{ ref('dim_date_calendar') }} where date_day <= current_date()
    )

)

select
    snapshot_date_key,
    product_key,
    units_in_stock,
    reorder_level,
    target_level,
    minimum_reorder_quantity,
    discontinued,
    case
        when units_in_stock <= reorder_level then true
        else false
    end as is_below_reorder,
    case
        when units_in_stock >= target_level then true
        else false
    end as is_at_target,
    current_timestamp() as _loaded_at

from running_stock
order by snapshot_date_key, product_key