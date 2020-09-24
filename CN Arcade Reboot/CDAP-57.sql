USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;
	
//For a benchmark to aid CNA Reboot discovery re: expected game engagement during player lifetime, the games team needs to know following:
//For current CN Arcade, if user churn is defined as players that have not launched the app in prior 30 days, 
//how many sessions and how much time spent in-app do players engage during their lifetime (i.e. from first launch through churn)? 
//Please provide number of session and time spent playing metrics for app churners within the previous 2-3 months. (July 22nd)

--
create or replace view temp_data_set as
select distinct
    submit_time::DATE as date
    ,userid
    ,sessionid
    ,duration
from prod_games.arcade.apprunning
where country like 'US' and userid in (select userid 
                                       from prod_games.arcade.FIRST_PLAYED_DATE 
                                       where START_DATE >= '3/4/2019') 
order by date;

--
create or replace view temp_inactive_num_users as
select
    a.submit_time::DATE as date
    ,count(distinct a.userid) as num_users
from prod_games.arcade.apprunning a
left join prod_games.arcade.temp_data_set b
on a.userid = b.userid
where b.date not between a.submit_time::DATE - interval '30 days' and a.submit_time::DATE
and a.submit_time::DATE >= to_date('2020-07-22')
and a.country like 'US' and a.userid in (select userid
                                         from prod_games.arcade.FIRST_PLAYED_DATE 
                                         where START_DATE >= '3/4/2019')
group by 1;

--
create or replace view temp_inactive_users as
select distinct
    a.userid
    ,a.submit_time::DATE as date
from prod_games.arcade.apprunning a
left join prod_games.arcade.temp_data_set b
on a.userid = b.userid
where b.date not between a.submit_time::DATE - interval '30 days' and a.submit_time::DATE
and a.country like 'US' and a.userid in (select userid
                                         from prod_games.arcade.FIRST_PLAYED_DATE 
                                         where START_DATE >= '3/4/2019')
and a.submit_time::DATE >= to_date('2020-07-22');

--
create or replace view temp_calculations as
select
    submit_time::DATE as date
    ,userid
    ,duration
    ,count(sessionid) as num_sessions
from prod_games.arcade.apprunning
where userid in (select userid
                 from temp_inactive_users
                 group by 1
                )
and country like 'US'
group by 1,2,3;

--
select
    a.date
    ,a.num_users
    ,round(avg(b.duration)) as avg_time
    ,round(avg(b.num_sessions)) as avg_sessions
from temp_inactive_num_users a
left join temp_calculations b
on a.date = b.date
group by 1,2;
