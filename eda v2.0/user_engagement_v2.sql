-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

create or replace view arcade_user_engagement_v2 as
-- who used it and what month they used it
with monthly_usage as (
  select distinct
    userid 
    ,datediff(month, '2019-03-04', submit_time::DATE) as time_period -- # of months since 3/4/2019
  from prod_games.arcade.apprunning
  where userid in (select userid 
                   from prod_games.arcade.FIRST_PLAYED_DATE 
                   where START_DATE >= '3/4/2019')
  and country like 'US'
  and time_period >= 0
  group by 1,2 
  order by 1,2
)
-- what is the next and previous month they used it, partitioned by user
,lag_lead as (
  select
    userid
    ,time_period
    ,lag(time_period,1) over (partition by userid order by userid, time_period) as lag -- previous month they used it
    ,lead(time_period,1) over (partition by userid order by userid, time_period) as lead -- next month they used it
  from monthly_usage
)
-- the difference between their current month and the next month
-- if it's 1, the user came back the next month
-- if it's 2+, there's a churn
,lag_lead_with_diffs as (
  select 
    userid
    ,time_period
    ,lag
    ,lead
    ,(time_period - lag) as lag_size
    ,(lead - time_period) as lead_size 
  from lag_lead
)
,calculated as (
  select 
    userid
    ,time_period
    ,case when lag is null then 'MAU'
        when lag_size = 1 then 'MAU'
        when lag_size > 1 then 'MAU'
        end as this_month_value
    ,case when (lead_size > 1 OR lead_size IS NULL) then 'CHURN'
        else NULL
        end as next_month_churn
  from lag_lead_with_diffs
)
select 
    time_period
    ,this_month_value
    ,count(distinct userid) as num_users
from calculated
group by 1,2
union
select 
    time_period+1
    ,next_month_churn
    ,count(distinct userid) as num_users
from calculated
where next_month_churn is not null
group by 1,2
order by 1;

-- Looker permissions for reporting view
GRANT SELECT ON prod_games.reporting.arcade_user_engagement_v2 TO looker_read;
