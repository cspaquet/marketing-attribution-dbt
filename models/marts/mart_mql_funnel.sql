with sessions as (
    select * from {{ ref('stg_ga_sessions') }}
),

funnel as (
    select
        session_date,
        channel,
        device_type,
        country,

        -- top of funnel
        sum(visits)                             as total_sessions,
        count(distinct visitor_id)              as unique_visitors,
        sum(pageviews)                          as total_pageviews,

        -- engagement
        safe_divide(
            sum(pageviews),
            sum(visits)
        )                                       as pages_per_session,
        safe_divide(
            sum(time_on_site_seconds),
            sum(visits)
        )                                       as avg_time_on_site_seconds,

        -- bottom of funnel
        sum(transactions)                       as total_conversions,
        sum(revenue)                            as total_revenue,

        -- funnel rates
        safe_divide(
            sum(transactions),
            count(distinct visitor_id)
        )                                       as visitor_conversion_rate,
        safe_divide(
            sum(transactions),
            sum(visits)
        )                                       as session_conversion_rate

    from sessions
    group by 1, 2, 3, 4
)

select * from funnel