with dim_shippers as (

    select
        {{ dbt_utils.generate_surrogate_key(['id']) }} as shipper_key,
        id as shipper_id,
        company as company_name,
        first_name as contact_first_name,
        last_name as contact_last_name,
        concat_ws(' ', first_name, last_name) as contact_full_name,
        job_title as contact_job_title,
        email_address,
        business_phone,
        home_phone,
        mobile_phone,
        fax_number,
        address,
        city,
        state_province,
        zip_postal_code,
        country_region,
        web_page,
        notes

    from {{ ref('stg_northwind__shippers') }}
    qualify row_number() 
    over (partition by id 
    order by _loaded_at desc) = 1
)

select * from dim_shippers
