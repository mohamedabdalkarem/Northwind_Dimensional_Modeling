with source as (

    select * from {{ source('northwind', 'inventory_transactions') }}

),

renamed as (

    select
        -- ids
        raw_data:id::number as id,
        raw_data:product_id::number as product_id,
        raw_data:transaction_type::number as transaction_type,
        raw_data:purchase_order_id::number as purchase_order_id,
        raw_data:customer_order_id::number as customer_order_id,

        -- quantity
        raw_data:quantity::number as quantity,

        -- dates
        to_timestamp_ntz(raw_data:transaction_created_date::number, 6) as transaction_created_date,
        to_timestamp_ntz(raw_data:transaction_modified_date::number, 6) as transaction_modified_date,

        nullif(trim(raw_data:comments::string), '') as comments,
        to_timestamp_ntz(raw_data:modified_at::number, 6) as modified_at,

        -- pipeline metadata
        _loaded_at,
        _source_file,
        _load_id

    from source

)

select * from renamed
