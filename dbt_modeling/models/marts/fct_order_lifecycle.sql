{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='merge',
        cluster_by=['order_date_key', 'required_date_key', 'shipped_date_key']
    )
}}

{% set lookback_days = var('fact_lifecycle_lookback_days', 3) %}

with orders as (

    select * from {{ ref('stg_northwind__orders') }}

),

invoices as (

    select * from {{ ref('stg_northwind__invoices') }}

),

order_lifecycle as (

    select
        -- key
        orders.id as order_id,

        -- date keys (FK to dim_date_calendar; -1 = unknown/no date yet)
        coalesce(dim_order_date.date_key, -1)       as order_date_key,
        coalesce(dim_required_date.date_key, -1)    as required_date_key,
        coalesce(dim_shipped_date.date_key, -1)     as shipped_date_key,

        -- degenerate dimensions
        cast(orders.order_date as date)     as order_date,
        cast(invoices.due_date as date)     as required_date,
        cast(orders.shipped_date as date)   as shipped_date,

        -- lag measures: days to ship, days late (positive = late)
        datediff('day', orders.order_date, orders.shipped_date) as days_to_ship,
        datediff(
            'day',
            coalesce(invoices.due_date::date, orders.order_date::date),
            orders.shipped_date
        ) as days_late,

        -- status flags for lifecycle tracking
        case when orders.shipped_date is not null then true else false end as is_shipped,
        case
            when orders.shipped_date is not null
             and invoices.due_date is not null
             and orders.shipped_date > invoices.due_date
            then true else false
        end as is_late,

        -- metadata
        greatest(
            orders._loaded_at,
            orders.modified_at,
            coalesce(invoices._loaded_at, orders._loaded_at),
            coalesce(invoices.modified_at, orders._loaded_at)
        ) as _loaded_at

    from orders
    left join invoices
        on orders.id = invoices.order_id
    left join {{ ref('dim_date_calendar') }} as dim_order_date
        on cast(orders.order_date as date) = dim_order_date.date_day
    left join {{ ref('dim_date_calendar') }} as dim_required_date
        on cast(invoices.due_date as date) = dim_required_date.date_day
    left join {{ ref('dim_date_calendar') }} as dim_shipped_date
        on cast(orders.shipped_date as date) = dim_shipped_date.date_day

    {% if is_incremental() %}

    where greatest(
        orders._loaded_at,
        orders.modified_at,
        coalesce(invoices._loaded_at, orders._loaded_at),
        coalesce(invoices.modified_at, orders._loaded_at)
    ) >= (
        select dateadd('day', -{{ lookback_days }}, max(_loaded_at)) from {{ this }}
    )

    {% endif %}

)

select * from order_lifecycle
