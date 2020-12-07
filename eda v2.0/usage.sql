use database prod_games;
use schema arcade;
use warehouse wh_default;

-- REPORTING schema
use database prod_games;
use schema reporting;
use warehouse wh_default;

-- Day of the week and hour usage for all CNA users
create or replace view arcade_usage as
select distinct
    submit_time::date as date
    ,userid
    ,case when dayofweek(submit_time) = 0 then 'Sunday'
        when dayofweek(submit_time) = 1 then 'Monday'
        when dayofweek(submit_time) = 2 then 'Tuesday'
        when dayofweek(submit_time) = 3 then 'Wednesday'
        when dayofweek(submit_time) = 4 then 'Thursday'
        when dayofweek(submit_time) = 5 then 'Friday'
        when dayofweek(submit_time) = 6 then 'Saturday'
        else null
        end as day_of_week
     ,case when hour(submit_time) = 0 then '7:00 p.m.'
        when hour(submit_time) = 1 then '8:00 p.m.'
        when hour(submit_time) = 2 then '9:00 p.m.'
        when hour(submit_time) = 3 then '10:00 p.m.'
        when hour(submit_time) = 4 then '11:00 p.m.'
        when hour(submit_time) = 5 then '12:00 a.m.'
        when hour(submit_time) = 6 then '1:00 a.m.'
        when hour(submit_time) = 7 then '2:00 a.m.'
        when hour(submit_time) = 8 then '3:00 a.m.'
        when hour(submit_time) = 9 then '4:00 a.m.'
        when hour(submit_time) = 10 then '5:00 a.m.'
        when hour(submit_time) = 11 then '6:00 a.m.'
        when hour(submit_time) = 12 then '7:00 a.m.'
        when hour(submit_time) = 13 then '8:00 a.m.'
        when hour(submit_time) = 14 then '9:00 a.m.'
        when hour(submit_time) = 15 then '10:00 a.m.'
        when hour(submit_time) = 16 then '11:00 a.m.'
        when hour(submit_time) = 17 then '12:00 p.m.'
        when hour(submit_time) = 18 then '1:00 p.m.'
        when hour(submit_time) = 19 then '2:00 p.m.'
        when hour(submit_time) = 20 then '3:00 p.m.'
        when hour(submit_time) = 21 then '4:00 p.m.'
        when hour(submit_time) = 22 then '5:00 p.m.'
        when hour(submit_time) = 23 then '6:00 p.m.'
        else null
        end as hour
from prod_games.arcade.apprunning
where country like 'US' and userid in (select userid
                                       from prod_games.arcade.first_played_date
                                       where start_date >= '3/4/2019'
                                       )
group by 1,2,3,4;

-- Looker permissions for reporting view
grant select on prod_games.reporting.arcade_usage to looker_read;

//Day of the week and hour usage queries separated:

-- Day of the week usage for all CNA users
select distinct
    case when dayofweek(submit_time) = 0 then 'Sunday'
        when dayofweek(submit_time) = 1 then 'Monday'
        when dayofweek(submit_time) = 2 then 'Tuesday'
        when dayofweek(submit_time) = 3 then 'Wednesday'
        when dayofweek(submit_time) = 4 then 'Thursday'
        when dayofweek(submit_time) = 5 then 'Friday'
        when dayofweek(submit_time) = 6 then 'Saturday'
        else null
        end as day_of_week
    ,count(distinct userid) as num_users
from prod_games.arcade.apprunning
where country like 'US' and userid in (select userid
                                       from prod_games.arcade.first_played_date
                                       where start_date >= '3/4/2019'
                                       )
group by 1;

-- Day of the week usage for CNA users who were active in the last 30 days
select distinct 
    case when dayofweek(submit_time) = 0 then 'Sunday'
        when dayofweek(submit_time) = 1 then 'Monday'
        when dayofweek(submit_time) = 2 then 'Tuesday'
        when dayofweek(submit_time) = 3 then 'Wednesday'
        when dayofweek(submit_time) = 4 then 'Thursday'
        when dayofweek(submit_time) = 5 then 'Friday'
        when dayofweek(submit_time) = 6 then 'Saturday'
        else null
        end as day_of_week
    ,count(distinct userid) as num_users
from prod_games.arcade.apprunning
where submit_time::date >= dateadd(day,-30,current_date()) and submit_time::date <= current_date()
and country like 'US' and userid in (select userid
                                     from prod_games.arcade.first_played_date
                                     where start_date >= '3/4/2019'
                                    )
group by 1
order by day_of_week desc;

-- Hour of the day usage for all CNA users
select distinct
    submit_time::date as date
    ,case when hour(submit_time) = 0 then '7:00 p.m.'
        when hour(submit_time) = 1 then '8:00 p.m.'
        when hour(submit_time) = 2 then '9:00 p.m.'
        when hour(submit_time) = 3 then '10:00 p.m.'
        when hour(submit_time) = 4 then '11:00 p.m.'
        when hour(submit_time) = 5 then '12:00 a.m.'
        when hour(submit_time) = 6 then '1:00 a.m.'
        when hour(submit_time) = 7 then '2:00 a.m.'
        when hour(submit_time) = 8 then '3:00 a.m.'
        when hour(submit_time) = 9 then '4:00 a.m.'
        when hour(submit_time) = 10 then '5:00 a.m.'
        when hour(submit_time) = 11 then '6:00 a.m.'
        when hour(submit_time) = 12 then '7:00 a.m.'
        when hour(submit_time) = 13 then '8:00 a.m.'
        when hour(submit_time) = 14 then '9:00 a.m.'
        when hour(submit_time) = 15 then '10:00 a.m.'
        when hour(submit_time) = 16 then '11:00 a.m.'
        when hour(submit_time) = 17 then '12:00 p.m.'
        when hour(submit_time) = 18 then '1:00 p.m.'
        when hour(submit_time) = 19 then '2:00 p.m.'
        when hour(submit_time) = 20 then '3:00 p.m.'
        when hour(submit_time) = 21 then '4:00 p.m.'
        when hour(submit_time) = 22 then '5:00 p.m.'
        when hour(submit_time) = 23 then '6:00 p.m.'
        else null
        end as hour
    ,count(distinct userid) as num_users
from prod_games.arcade.apprunning
group by 1,2;

-- Hour of the day usage for CNA users who were active in the last 30 days
select distinct 
    case when hour(submit_time) = 0 then '7:00 p.m.'
        when hour(submit_time) = 1 then '8:00 p.m.'
        when hour(submit_time) = 2 then '9:00 p.m.'
        when hour(submit_time) = 3 then '10:00 p.m.'
        when hour(submit_time) = 4 then '11:00 p.m.'
        when hour(submit_time) = 5 then '12:00 a.m.'
        when hour(submit_time) = 6 then '1:00 a.m.'
        when hour(submit_time) = 7 then '2:00 a.m.'
        when hour(submit_time) = 8 then '3:00 a.m.'
        when hour(submit_time) = 9 then '4:00 a.m.'
        when hour(submit_time) = 10 then '5:00 a.m.'
        when hour(submit_time) = 11 then '6:00 a.m.'
        when hour(submit_time) = 12 then '7:00 a.m.'
        when hour(submit_time) = 13 then '8:00 a.m.'
        when hour(submit_time) = 14 then '9:00 a.m.'
        when hour(submit_time) = 15 then '10:00 a.m.'
        when hour(submit_time) = 16 then '11:00 a.m.'
        when hour(submit_time) = 17 then '12:00 p.m.'
        when hour(submit_time) = 18 then '1:00 p.m.'
        when hour(submit_time) = 19 then '2:00 p.m.'
        when hour(submit_time) = 20 then '3:00 p.m.'
        when hour(submit_time) = 21 then '4:00 p.m.'
        when hour(submit_time) = 22 then '5:00 p.m.'
        when hour(submit_time) = 23 then '6:00 p.m.'
        else null
        end as hour
    ,count(distinct userid) as num_users
from prod_games.arcade.apprunning
where submit_time::date >= dateadd(day,-30,current_date()) and submit_time::date <= current_date()
and country like 'US' and userid in (select userid
                                     from prod_games.arcade.first_played_date
                                     where start_date >= '3/4/2019'
                                    )
group by 1
order by num_users desc;
