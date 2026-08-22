with source as (select * from {{ source('northwind', 'order_details') }}),

renamed as (

    select
        -- ids
        raw_data:id::number as id,
        raw_data:order_id::number as order_id,
        raw_data:product_id::number as product_id,
        raw_data:status_id::number as status_id,
        raw_data:purchase_order_id::number as purchase_order_id,
        raw_data:inventory_id::number as inventory_id,

        -- dates
        to_timestamp_ntz(raw_data:date_allocated::number, 6) as date_allocated,

        -- measures
        raw_data:quantity::number as quantity,
        raw_data:unit_price::number(19, 4) as unit_price,
        raw_data:discount::float as discount,

        -- metadata
        _loaded_at,
        _source_file,
        _load_id

    from source

)

select * from renamed
