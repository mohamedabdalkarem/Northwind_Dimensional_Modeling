with source as (select * from {{ source('northwind', 'purchase_orders') }}),

renamed as (

    select
        -- ids
        raw_data:id::number as id,
        raw_data:supplier_id::number as supplier_id,
        raw_data:status_id::number as status_id,
        raw_data:created_by::number as created_by,
        raw_data:approved_by::number as approved_by,
        raw_data:submitted_by::number as submitted_by,

        -- dates
        to_timestamp_ntz(raw_data:creation_date::number, 6) as creation_date,
        to_timestamp_ntz(raw_data:submitted_date::number, 6) as submitted_date,
        to_timestamp_ntz(raw_data:approved_date::number, 6) as approved_date,
        to_timestamp_ntz(raw_data:expected_date::number, 6) as expected_date,
        to_timestamp_ntz(raw_data:payment_date::number, 6) as payment_date,

        -- money
        raw_data:shipping_fee::number(19, 4) as shipping_fee,
        raw_data:taxes::number(19, 4) as taxes,
        raw_data:payment_amount::number(19, 4) as payment_amount,
        nullif(trim(raw_data:payment_method::string), '') as payment_method,

        nullif(trim(raw_data:notes::string), '') as notes,
        to_timestamp_ntz(raw_data:modified_at::number, 6) as modified_at,

        -- metadata
        _loaded_at,
        _source_file,
        _load_id

    from source

)

select * from renamed
