{{
    config(
        materialized='view'
    )
}}

with inventory as (

    select
        f.snapshot_date_key,
        f.product_key,
        f.units_in_stock,
        f.reorder_level,
        f.target_level,
        f.minimum_reorder_quantity,
        f.discontinued,
        f.is_below_reorder,
        f.is_at_target,
        f._loaded_at

    from {{ ref('fct_inventory_snapshot') }} f

),

product as (
    select * from {{ ref('dim_product') }} where product_key != '-1'
),

snapshot_date as (
    select * from {{ ref('dim_date_calendar') }} where date_key != -1
)

select
    i.snapshot_date_key,
    i.units_in_stock,
    i.reorder_level,
    i.target_level,
    i.minimum_reorder_quantity,
    i.discontinued,
    i.is_below_reorder,
    i.is_at_target,

    -- product
    p.product_id,
    p.product_code,
    p.product_name,
    p.category as product_category,
    p.quantity_per_unit,
    p.standard_cost,
    p.list_price,
    p.target_level as product_target_level,
    p.reorder_level as product_reorder_level,

    -- snapshot date attributes
    d.year_number as snapshot_year,
    d.month_of_year as snapshot_month,
    d.quarter_of_year as snapshot_quarter,
    d.iso_week_of_year as snapshot_iso_week,
    d.day_name as snapshot_day_name,
    d.is_weekend as snapshot_is_weekend,
    d.is_holiday as snapshot_is_holiday,

    i._loaded_at

from inventory i
left join product p on i.product_key = p.product_key
left join snapshot_date d on i.snapshot_date_key = d.date_key