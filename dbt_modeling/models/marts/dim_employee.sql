with dim_employees as (

    select
        {{ dbt_utils.generate_surrogate_key(['id']) }} as employee_key,
        id as employee_id,
        first_name,
        last_name,
        concat_ws(' ', first_name, last_name) as full_name,
        job_title,
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

    from {{ ref('stg_northwind__employees') }}

    qualify row_number() over (
        partition by id
        order by _loaded_at desc
    ) = 1

)

select * from dim_employees