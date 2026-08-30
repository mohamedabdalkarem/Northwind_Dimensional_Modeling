{{
    config(
        materialized='incremental',
        unique_key='id',
        incremental_strategy='merge',
        cluster_by=['order_date_key', 'customer_key']
    )
}}

{% set lookback_days = var('fact_sales_lookback_days', 3) %}

with inventory transactions as(
select * from {{ ref('stg_northwind__inventory_transactions') }}
),

products as (
select * from {{ ref('stg_northwind__products') }}
),

inventory_snapshot as (
    select
    
