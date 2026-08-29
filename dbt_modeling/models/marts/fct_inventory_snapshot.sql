{{
    config(
        materialized='incremental',
        unique_key='order_line_id',
        incremental_strategy='merge',
        cluster_by=['order_date_key', 'customer_key']
    )
}}

{% set lookback_days = var('fact_sales_lookback_days', 3) %}

with inventory as(
select * from {{ ref('stg_northwind__inventory_transactions') }}
),

