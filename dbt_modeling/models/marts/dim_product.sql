with dim_products as (

    select
        {{ dbt_utils.generate_surrogate_key(['id']) }} as product_key,
        id as product_id,
        product_code,
        product_name,
        description,
        category,
        quantity_per_unit,
        standard_cost,
        list_price,
        reorder_level,
        target_level,
        minimum_reorder_quantity,
        discontinued

    from {{ ref('stg_northwind__products') }}
    qualify row_number() over (
        partition by id
        order by _loaded_at desc
    ) = 1

),

unknown_member as (

    select
        '-1' as product_key,
        -1 as product_id,
        'Unknown' as product_code,
        'Unknown' as product_name,
        null as description,
        'Unknown' as category,
        null as quantity_per_unit,
        null as standard_cost,
        null as list_price,
        null as reorder_level,
        null as target_level,
        null as minimum_reorder_quantity,
        null as discontinued

)

select * from dim_products
union all
select * from unknown_member
