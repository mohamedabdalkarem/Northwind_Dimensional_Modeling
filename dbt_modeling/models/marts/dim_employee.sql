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

),

unknown_member as (

    select
        '-1' as employee_key,
        -1 as employee_id,
        'Unknown' as first_name,
        'Unknown' as last_name,
        'Unknown' as full_name,
        'Unknown' as job_title,
        null as email_address,
        null as business_phone,
        null as home_phone,
        null as mobile_phone,
        null as fax_number,
        null as address,
        null as city,
        null as state_province,
        null as zip_postal_code,
        null as country_region,
        null as web_page,
        null as notes

)

select * from dim_employees
union all
select * from unknown_member