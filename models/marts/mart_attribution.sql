with sessions as (
    select * from {{ ref('stg_ga_sessions') }}
),

-- last touch attribution: give 100% credit to the last channel
-- the visitor used before converting
attributed as (
    select
        session_date,
        channel,
        country,
        device_type,
        count(distinct visitor_id)          as unique_visitors,
        sum(visits)                         as total_sessions,
        sum(transactions)                   as total_conversions,
        sum(revenue)                        as total_revenue,
        safe_divide(
            sum(transactions),
            sum(visits)
        )                                   as conversion_rate,
        safe_divide(
            sum(revenue),
            sum(transactions)
        )                                   as avg_order_value
    from sessions
    group by 1, 2, 3, 4
)

select * from attributed