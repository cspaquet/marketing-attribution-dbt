with sessions as (
    select * from {{ ref('stg_ga_sessions') }}
),

-- since we don't have real spend data in the public dataset
-- we simulate campaign spend by channel for demonstration
channel_spend as (
    select 'Organic Search'    as channel, 0.00   as monthly_spend union all
    select 'Paid Search',                  15000.00              union all
    select 'Direct',                       0.00                  union all
    select 'Referral',                     2000.00               union all
    select 'Social',                       5000.00               union all
    select 'Email',                        1500.00               union all
    select 'Display',                      8000.00               union all
    select 'Affiliates',                   3000.00               union all
    select '(Other)',                      500.00
),

channel_performance as (
    select
        channel,
        sum(transactions)                   as total_conversions,
        sum(revenue)                        as total_revenue,
        count(distinct visitor_id)          as unique_visitors
    from sessions
    group by 1
),

cac as (
    select
        p.channel,
        p.total_conversions,
        p.total_revenue,
        p.unique_visitors,
        s.monthly_spend,

        -- cost per acquired customer
        safe_divide(
            s.monthly_spend,
            p.total_conversions
        )                                   as cost_per_acquisition,

        -- return on ad spend
        safe_divide(
            p.total_revenue,
            s.monthly_spend
        )                                   as roas,

        -- revenue per visitor
        safe_divide(
            p.total_revenue,
            p.unique_visitors
        )                                   as revenue_per_visitor

    from channel_performance p
    left join channel_spend s using (channel)
)

select * from cac
order by total_revenue desc