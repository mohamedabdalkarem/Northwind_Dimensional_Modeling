with source as (

    select * from {{ source('northwind', 'orders') }}

),

renamed as (

    select
        -- ids
        raw_data:id::number as id,
        raw_data:employee_id::number as employee_id,
        raw_data:customer_id::number as customer_id,
        raw_data:shipper_id::number as shipper_id,
        raw_data:status_id::number as status_id,
        raw_data:tax_status_id::number as tax_status_id,

        -- dates
        to_timestamp_ntz(raw_data:order_date::number, 6) as order_date,
        to_timestamp_ntz(raw_data:shipped_date::number, 6) as shipped_date,
        to_timestamp_ntz(raw_data:paid_date::number, 6) as paid_date,

        -- shipping details
        nullif(trim(raw_data:ship_name::string), '') as ship_name,
        nullif(trim(raw_data:ship_address::string), '') as ship_address,
        nullif(trim(raw_data:ship_city::string), '') as ship_city,
        nullif(trim(raw_data:ship_state_province::string), '') as ship_state_province,
        nullif(trim(raw_data:ship_zip_postal_code::string), '') as ship_zip_postal_code,
        nullif(trim(raw_data:ship_country_region::string), '') as ship_country_region,

        -- money / tax
        raw_data:shipping_fee::number(19, 4) as shipping_fee,
        raw_data:taxes::number(19, 4) as taxes,
        raw_data:tax_rate::float as tax_rate,

        -- payment
        nullif(trim(raw_data:payment_type::string), '') as payment_type,
        nullif(trim(raw_data:notes::string), '') as notes,

        to_timestamp_ntz(raw_data:modified_at::number, 6) as modified_at,

        -- pipeline metadata
        _loaded_at,
        _source_file,
        _load_id

    from source

)

select * from renamed
