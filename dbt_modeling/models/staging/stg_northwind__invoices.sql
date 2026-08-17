with source as (

    select * from {{ source('northwind', 'invoices') }}

),

renamed as (

    select
        -- ids
        raw_data:id::number as id,
        raw_data:order_id::number as order_id,

        -- dates
        to_timestamp_ntz(raw_data:invoice_date::number, 6) as invoice_date,
        to_timestamp_ntz(raw_data:due_date::number, 6) as due_date,

        -- money
        raw_data:tax::number(19, 4) as tax,
        raw_data:shipping::number(19, 4) as shipping,
        raw_data:amount_due::number(19, 4) as amount_due,

        to_timestamp_ntz(raw_data:modified_at::number, 6) as modified_at,

        -- pipeline metadata
        _loaded_at,
        _source_file,
        _load_id

    from source

)

select * from renamed
