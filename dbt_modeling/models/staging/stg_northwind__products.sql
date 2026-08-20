with source as (select * from {{ source('northwind', 'products') }}),

renamed as (

    select
        -- ids
        raw_data:id::number as id,

        -- descriptive attributes
        nullif(trim(raw_data:product_code::string), '') as product_code,
        nullif(trim(raw_data:product_name::string), '') as product_name,
        nullif(trim(raw_data:description::string), '') as description,
        nullif(trim(raw_data:category::string), '') as category,
        nullif(trim(raw_data:quantity_per_unit::string), '') as quantity_per_unit,
        nullif(trim(raw_data:supplier_ids::string), '') as supplier_ids,
        nullif(trim(raw_data:attachments__v_text::string), '') as attachments,

        -- pricing
        raw_data:standard_cost::number(19, 4) as standard_cost,
        raw_data:list_price::number(19, 4) as list_price,

        -- inventory attributes
        raw_data:reorder_level::number as reorder_level,
        raw_data:target_level::number as target_level,
        raw_data:minimum_reorder_quantity::number as minimum_reorder_quantity,
        (raw_data:discontinued::number <> 0) as discontinued,

        to_timestamp_ntz(raw_data:modified_at::number, 6) as modified_at,

        -- metadata
        _loaded_at,
        _source_file,
        _load_id

    from source

)

select * from renamed
