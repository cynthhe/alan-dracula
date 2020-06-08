use database prod_games;
use schema arcade;
use warehouse wh_default;

-- if a session is quiet for more than 20 minutes, add something to the session id to make it a new session
create view arcadesessions as
with session_run as (
  select * from apprunning
),
lag_events as ( -- events occurring on the same day and with the same user id
  select
  userid,
  sessionid,
  submit_time,
  lag(submit_time) over (partition by date(submit_time), userid order by submit_time) as prev -- partition date and user id
  from session_run
),
new_sessions as ( -- determines whether start of a new session
  select
  userid,
  sessionid,
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
  sessionid,
  submit_time,
  is_new_session,
  sum(is_new_session) over (partition by userid order by submit_time rows between unbounded preceding and current row) as session_index -- # of sessions for given user
  from new_sessions
)
select
distinct userid || sessionid || submit_time  as session_id, -- creates new session id (concat user id + submit time)
userid,
sessionid,
submit_time,
is_new_session,
session_index
from session_index
order by userid, sessionid, submit_time;

-- drop arcadesessions view
drop view arcadesessions;

-- create arcadedurations view
create view arcadedurations as
select distinct userid || sessionid || submit_time  as session_id,
max(duration) as time_in_app
from apprunning
group by 1;

-- drop arcadedurations view
drop view arcadedurations;

-- create arcade_session view (arcadesessions and arcadedurations joined)
create view arcade_session as
select userid, sessionid, submit_time::date as date, is_new_session, session_index, round(time_in_app / 60) as duration
from arcadesessions
join arcadedurations on (arcadesessions.session_id = arcadedurations.session_id);

-- drop arcade_session view
drop view arcade_session;

-- time in app per session
select distinct userid, sessionid, date, duration
from arcade_session
group by 1,2,3,4
having duration between 1 and 20 -- users who have played b/w 1-20 min
order by random() limit 20000; -- get simple random sample of 1000

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
