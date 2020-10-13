-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

create or replace view arcade_user_engagement as
with monthly_usage as (
  select distinct
    userid 
    ,datediff(month, '2019-03-04', submit_time::DATE) as time_period
  from prod_games.arcade.apprunning
  where userid in (select userid 
                   from prod_games.arcade.FIRST_PLAYED_DATE 
                   where START_DATE >= '3/4/2019')
  and country like 'US'
  and time_period >= 0
  group by 1,2 
  order by 1,2
)
,lag_lead as (
  select
    userid
    ,time_period
    ,lag(time_period,1) over (partition by userid order by userid, time_period) as lag
    ,lead(time_period,1) over (partition by userid order by userid, time_period) as lead
  from monthly_usage
)
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
    time_period
    ,case when lag is null then 'NEW'
        when lag_size = 1 then 'ACTIVE'
        when lag_size > 1 then 'RETURN'
        end as this_month_value
    ,case when (lead_size > 1 OR lead_size IS NULL) then 'CHURN'
        else NULL
        end as next_month_churn
    ,count(distinct userid) as num_users
  from lag_lead_with_diffs
  group by 1,2,3
)
select 
    time_period
    ,this_month_value
    ,sum(num_users) as num_users
from calculated
group by 1,2
union
select 
    time_period+1
    ,'CHURN'
    ,num_users
from calculated
where next_month_churn is not null
order by 1;

-- Looker permissions for reporting view
GRANT SELECT ON prod_games.reporting.arcade_user_engagement TO looker_read;
