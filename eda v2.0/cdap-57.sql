use database prod_games;
use schema arcade;
use warehouse wh_default;
	
//For a benchmark to aid v2.0 discovery:
//For v1.0, if user churn is defined as players that have not launched the app in prior 30 days, 
//how many sessions and how much time spent in-app do players engage during their lifetime (i.e. from first launch through churn)? 
//Provide number of session and time spent playing metrics for app churners within the previous 2-3 months. (July 22nd)

--
drop view temp_data_set;
create or replace view temp_data_set as
select distinct
    date
    ,userid
    ,sessionid
from prod_games.arcade.arcade_perday
where userid in (select userid 
                 from prod_games.arcade.FIRST_PLAYED_DATE 
                 where START_DATE >= '3/4/2019') 
order by date;

--
drop view temp_inactive_num_users;
create or replace view temp_inactive_num_users as
select
    a.date
    ,count(distinct a.userid) as num_users
from prod_games.arcade.arcade_perday a
left join prod_games.arcade.temp_data_set b
on a.userid = b.userid
where b.date not between a.date - interval '30 days' and a.date
and a.date >= to_date('2020-07-22')
and a.userid in (select userid 
                 from prod_games.arcade.FIRST_PLAYED_DATE 
                 where START_DATE >= '3/4/2019'
                 and country like 'US'
                 )
group by 1;

--
drop view temp_inactive_users;
create or replace view temp_inactive_users as
select distinct
    a.userid
    ,a.date
from prod_games.arcade.arcade_perday a
left join prod_games.arcade.temp_data_set b
on a.userid = b.userid
where b.date not between a.date - interval '30 days' and a.date
and a.date >= to_date('2020-07-22')
and a.userid in (select userid 
               from prod_games.arcade.FIRST_PLAYED_DATE 
               where START_DATE >= '3/4/2019'
               and country like 'US'
              );

--
drop view temp_num_days_active;
create or replace view temp_num_days_active as
select distinct
    a.userid
    ,count(distinct a.date) as num_days_active
from prod_games.arcade.arcade_perday a
left join prod_games.arcade.temp_data_set b
on a.userid = b.userid
where b.date not between a.date - interval '30 days' and a.date
and a.date >= to_date('2020-07-22')
and a.userid in (select userid 
                 from prod_games.arcade.FIRST_PLAYED_DATE 
                 where START_DATE >= '3/4/2019'
                 and country like 'US'
                 )
group by 1;

--
drop view temp_calculations;
create or replace view temp_calculations as
select distinct
    userid
    ,date
    ,sum(duration) as total_time
    ,count(distinct sessionid) as num_sessions
from prod_games.arcade.arcade_perday
where userid in (select userid
                 from temp_inactive_users
                 group by 1
                  )
and userid in (select userid 
               from prod_games.arcade.FIRST_PLAYED_DATE 
               where START_DATE >= '3/4/2019'
               and country like 'US'
              )
group by 1,2;

-- Average # of active Days/lifetime (i.e. from first launch to churn date) | average total sessions per user/lifetime | average total minutes playing per user/lifetime
select distinct
    a.date
    ,a.num_users
    ,round(avg(c.num_days_active)) as avg_days_active
    ,round(avg(b.total_time)) as avg_time
    ,round(avg(b.num_sessions)) as avg_sessions
from temp_inactive_num_users a
join temp_calculations b
on a.date = b.date
join temp_num_days_active c
on b.userid = c.userid
group by 1,2;
