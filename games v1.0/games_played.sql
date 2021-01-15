-- REPORTING schema
use database prod_games;
use schema reporting;
use warehouse wh_default;

create or replace view prod_games.reporting.arcade_games_played as
select 
    a.submit_time::date as date
    ,case when a.game_name like 'Smashy%' then 'Smashy Pinata'
        when a.game_name like '%Maze' then 'Maize Maze'
        else a.game_name 
        end as game_name
    ,a.platform
    ,count(distinct a.userid) as users
    ,count(distinct a.sessionid) as sessions
    ,count(distinct a.game_session_id) as game_starts
    ,count(distinct(b.game_session_id||b.ts)) as game_plays
from prod_games.arcade.game_open a
left join prod_games.arcade.game_start b on b.game_session_id = a.game_session_id and b.country like 'US' 
and b.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019') and b.INTERACTION like '%play%' 
where a.country like 'US' 
and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
and date >= '3/4/2019'
group by 1,2,3;

-- Looker permissions for reporting view
grant select on prod_games.reporting.arcade_games_played to looker_read;
