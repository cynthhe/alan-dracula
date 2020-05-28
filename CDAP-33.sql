use database prod_games;
use schema arcade;
use warehouse wh_default;

-- max time in app (seconds) for each user
select userid, sessionid, submit_time::Date as date, max(duration) as time_in_app
from apprunning
group by 1,2,3
limit 100;

-- date range
select min(submit_time::Date) as min_date, max(submit_time::Date) as max_date
from apprunning;

-- duration range
select min(duration) as min_duration, max(duration) as max_duration
from apprunning;

-- number of sessions for each user
select distinct userid, count(sessionid)
from apprunning
group by 1;

-- user with highest duration
select userid, sessionid, submit_time, duration as time_in_app
from apprunning
where userid = '94d043b89f89c4b57b144dedf7a0d350'
order by submit_time;

-- segments within a 1 hour range
select case
when duration between 1 and 720 then '1-720'
when duration between 721 and 1440 then '721-1440'
when duration between 1441 and 2160 then '1441-2160'
when duration between 2160 and 2880 then '2160-2880'
when duration between 2880 and 3600 then '2880-3600'
else 'OTHERS'
end as range_sec,
count(1) as count_
from apprunning
group by range_sec
order by range_sec asc;

-- if a session is quiet for more than 20 minutes, add something to the session id to make it a new session
create view arcadesessions as
with session_run as (
  select * from apprunning
),
lag_events as ( -- events occurring on the same day and with the same user id
  select
  userid,
  submit_time,
  lag(submit_time) over (partition by date(submit_time), userid order by submit_time) as prev -- partition date and user id
  from session_run
),
new_sessions as ( -- determines whether start of a new session
  select
  userid,
  submit_time,
  case -- compares current event time with the previous event time for that user
  when prev is null then 1 -- new session (first event by that user on that day)
  when timediff(minute, submit_time, prev) < -20 then 1 -- new session (if more than 20 minutes has elapsed)
  else 0 -- not a new session
  end as is_new_session -- creates new column 'is_new_session'
  from lag_events
),
session_index as ( -- incrementing each time a new session is found for a given user
  select
  userid,
  submit_time,
  is_new_session,
  sum(is_new_session) over (partition by userid order by submit_time rows between unbounded preceding and current row) as session_index -- # of sessions for given user
  from new_sessions
)
select
cast(userid as varchar) || '-' || cast(session_index as varchar) as session_id, -- creates new session id (concat user id + session index)
userid,
submit_time,
is_new_session,
session_index
from session_index
order by userid, submit_time;

-- drop arcadesessions view
drop view arcadesessions;

-- time in app per session
select distinct userid, sessionid, submit_time::Date as date, round(max(duration) / 60) as time_in_app
from apprunning
group by 1,2,3
having time_in_app between 1 and 20 -- users who have played b/w 1-20 min
order by random() limit 1000; -- get simple random sample of 1000

-- time in app per session (COVID)
select distinct userid, sessionid, submit_time::Date as date, round(max(duration) / 60) as time_in_app
from apprunning
group by 1,2,3
having time_in_app between 1 and 20 and date > '2020-02-29' -- users who have played b/w 1-20 min + starting from 3/1/20
order by random() limit 1000; -- get simple random sample of 1000

-- average time in app per day
select userid, submit_time::Date as date, round(avg(duration / 60)) as time_in_app
from apprunning
group by 1,2
having time_in_app between 1 and 20 -- users who have played an avg b/w 1-20 min
order by random() limit 1000; -- get simple random sample of 1000

-- average time in app per day (COVID)
select userid, submit_time::Date as date, round(avg(duration / 60)) as time_in_app
from apprunning
group by 1,2
having time_in_app between 1 and 20 and date > '2020-02-29'; -- users who have played an avg b/w 1-20 min + starting from 3/1/20
order by random() limit 1000; -- get simple random sample of 1000
