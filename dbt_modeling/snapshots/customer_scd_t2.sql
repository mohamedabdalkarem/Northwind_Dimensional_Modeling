{% snapshot customer_scd_t2 %}

{{
    config(
        target_schema='snapshots',
        unique_key='id',
        strategy='timestamp',
        updated_at='modified_at',
        invalidate_hard_deletes=True,
    )
}}

select *
from {{ ref('stg_northwind__customers') }}
qualify row_number() over (partition by id order by _loaded_at desc) = 1

{% endsnapshot %}
