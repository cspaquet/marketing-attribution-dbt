with source as (
    select * from {{ source('google_analytics', 'ga_sessions_20170801') }}
),

cleaned as (
    select
        visitId                                         as session_id,
        fullVisitorId                                   as visitor_id,
        date                                            as session_date,
        channelGrouping                                 as channel,
        device.deviceCategory                          as device_type,
        geoNetwork.country                             as country,
        totals.visits                                  as visits,
        totals.pageviews                               as pageviews,
        totals.timeOnSite                              as time_on_site_seconds,
        totals.transactions                            as transactions,
        coalesce(totals.totalTransactionRevenue, 0) 
            / 1000000                                  as revenue
    from source
)

select * from cleaned