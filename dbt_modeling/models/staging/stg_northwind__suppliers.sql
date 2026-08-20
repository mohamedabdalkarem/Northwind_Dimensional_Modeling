with source as (select * from {{ source('northwind', 'suppliers') }}),

renamed as (

    select
        -- ids
        raw_data:id::number as id,

        -- names
        nullif(trim(raw_data:company::string), '') as company,
        nullif(trim(raw_data:last_name::string), '') as last_name,
        nullif(trim(raw_data:first_name::string), '') as first_name,
        nullif(trim(raw_data:email_address::string), '') as email_address,
        nullif(trim(raw_data:job_title::string), '') as job_title,

        -- phone / fax
        nullif(trim(raw_data:business_phone::string), '') as business_phone,
        nullif(trim(raw_data:home_phone::string), '') as home_phone,
        nullif(trim(raw_data:mobile_phone::string), '') as mobile_phone,
        nullif(trim(raw_data:fax_number::string), '') as fax_number,

        -- address
        nullif(trim(raw_data:address::string), '') as address,
        nullif(trim(raw_data:city::string), '') as city,
        nullif(trim(raw_data:state_province::string), '') as state_province,
        nullif(trim(raw_data:zip_postal_code::string), '') as zip_postal_code,
        nullif(trim(raw_data:country_region::string), '') as country_region,

        -- other attributes
        nullif(trim(raw_data:web_page::string), '') as web_page,
        nullif(trim(raw_data:notes::string), '') as notes,
        nullif(trim(raw_data:attachments__v_text::string), '') as attachments,
        to_timestamp_ntz(raw_data:modified_at::number, 6) as modified_at,

        -- metadata
        _loaded_at,
        _source_file,
        _load_id

    from source

)

select * from renamed
