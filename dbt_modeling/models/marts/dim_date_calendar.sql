with date_spine as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="to_date('1990-01-01')",
        end_date="to_date('2030-12-31')"
    ) }}

),
date_parts as (

    select
        cast(date_day as date) as date_day,

        date_part('year', date_day) as year_number,
        date_part('month', date_day) as month_of_year,
        date_part('day', date_day) as day_of_month,
        date_part('quarter', date_day) as quarter_of_year,
        date_part('weekiso', date_day) as iso_week_of_year,
        date_part('dayofweekiso', date_day) as day_of_week_iso,  -- 1=Mon..7=Sun, stable regardless of session WEEK_START
        day(last_day(date_day)) as days_in_month,                -- needed for "last Monday of the month"

        decode(dayname(date_day),
            'Sun','Sunday','Mon','Monday','Tue','Tuesday','Wed','Wednesday',
            'Thu','Thursday','Fri','Friday','Sat','Saturday'
        ) as day_name,

        decode(monthname(date_day),
            'Jan','January','Feb','February','Mar','March','Apr','April',
            'May','May','Jun','June','Jul','July','Aug','August',
            'Sep','September','Oct','October','Nov','November','Dec','December'
        ) as month_name

    from date_spine

),
final as (

    select
        cast(to_char(date_day, 'yyyymmdd') as int) as date_key,   -- surrogate key
        date_day,                                                  -- full date

        day_of_month,
        month_of_year,
        quarter_of_year,
        year_number,
        day_name,
        month_name,
        iso_week_of_year,

        month_of_year as fiscal_period,   -- fiscal year = calendar year, so fiscal period = calendar month

        day_of_week_iso in (6, 7) as is_weekend,

        case
            when month_of_year = 1  and day_of_month = 1 then true                                          -- New Year's Day
            when month_of_year = 1  and day_of_week_iso = 1 and day_of_month between 15 and 21 then true     -- MLK Day: 3rd Mon of Jan
            when month_of_year = 2  and day_of_week_iso = 1 and day_of_month between 15 and 21 then true     -- Presidents Day: 3rd Mon of Feb
            when month_of_year = 5  and day_of_week_iso = 1 and day_of_month > days_in_month - 7 then true   -- Memorial Day: last Mon of May
            when month_of_year = 6  and day_of_month = 19 and year_number >= 2021 then true                  -- Juneteenth (federal since 2021)
            when month_of_year = 7  and day_of_month = 4 then true                                           -- Independence Day
            when month_of_year = 9  and day_of_week_iso = 1 and day_of_month between 1 and 7 then true       -- Labor Day: 1st Mon of Sep
            when month_of_year = 10 and day_of_week_iso = 1 and day_of_month between 8 and 14 then true      -- Columbus Day: 2nd Mon of Oct
            when month_of_year = 11 and day_of_month = 11 then true                                          -- Veterans Day
            when month_of_year = 11 and day_of_week_iso = 4 and day_of_month between 22 and 28 then true     -- Thanksgiving: 4th Thu of Nov
            when month_of_year = 12 and day_of_month = 25 then true                                          -- Christmas Day
            else false
        end as is_holiday

    from date_parts

),

unknown_member as (

    select
        -1 as date_key,
        null as date_day,
        null as day_of_month,
        null as month_of_year,
        null as quarter_of_year,
        null as year_number,
        'Unknown' as day_name,
        'Unknown' as month_name,
        null as iso_week_of_year,
        null as fiscal_period,
        null as is_weekend,
        null as is_holiday

)

select * from final
union all
select * from unknown_member