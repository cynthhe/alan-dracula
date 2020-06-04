use database prod_games;
use schema arcade;
use warehouse wh_default;

-- segmenting groups
select distinct case
when duration between 0 and 4 then 'Not engaged'
when duration between 4 and 8 then 'Engaged'
when duration >= 8 then 'Ultra engaged'
else 'OTHERS'
end as segment,
count(1) as num_users,
concat(round(((num_users / (select count(*) from apprunning)) * 100), 2), '%') as "% of Total"
from arcade_perday
group by segment
order by num_users desc;

-- creates arcade_perday view
create view arcade_perday as
select distinct userid, sessionid, date, is_new_session, session_index, duration
from arcade_session;

-- drop arcade_perday view
drop view arcade_perday;

-- time in app per day view
select *
from arcade_perday;

-- creates arcade_engagement_segments view
create view arcade_engagement_segments as
select month(date) || '-' || year(date) as month, 
userid, 
round(avg(duration)) as avg_time_per_day_this_month,
case
when avg_time_per_day_this_month between 0 and 4 then 'Not engaged'
when avg_time_per_day_this_month between 4 and 8 then 'Engaged'
when avg_time_per_day_this_month >= 8 then 'Ultra engaged'
else 'OTHERS'
end as segment
from arcade_perday
group by 1,2;

-- drops arcade_engagement_segments view
drop view arcade_engagement_segments;

-- testing arcade_engagement_segments view
select *
from arcade_engagement_segments;

select min(date)
from arcade_perday;

select *
from arcade_engagement_segments
where userid = '8c9fa5100fa414d3bab22d66c5411bf8';

select *
from arcade_perday
where userid = '8c9fa5100fa414d3bab22d66c5411bf8';

-- creates arcade_active_game view
create view arcade_active_game as
select apprunning.submit_time::Date as date, apprunning.userid, game_open.game_name
from apprunning
join game_open on (apprunning.userid = game_open.userid) and (apprunning.submit_time = game_open.submit_time)
where date >= dateadd(day, -7, getdate());

-- drop arcade_active_game view
drop view arcade_active_game;

-- testing arcade_active_game view
select *
from arcade_active_game;

select min(date), max(date)
from arcade_active_game;
