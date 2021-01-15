-- REPORTING schema
use database prod_games;
use schema reporting;
use warehouse wh_default;

create or replace view prod_games.reporting.weekly_retention_us_games as
select
    game_name
    ,start_week
    ,week_since_start
    ,count(distinct userid) as users
from (select
        case when a.game_name like 'Smashy%' then 'Smashy Pinata'
            when a.game_name like '%Maze' then 'Maize Maze'
            else a.game_name
            end as game_name
        ,a.userid
        ,week(a.start_date) as start_week
        ,week(b.submit_time) as played_week
        ,week(b.submit_time)-week(a.start_date) as week_since_start
      from arcade.FIRST_PLAYED_GAMES_DATE a
      join arcade.game_open b on b.userid = a.userid and b.submit_time::Date >= a.start_date and b.game_name = a.game_name
      where a.country like 'US' and a.start_date >= '3/3/2019' 
      group by 1,2,3,4,5) 
      group by 1,2,3;

-- Looker permissions for reporting view
grant select on prod_games.reporting.weekly_retention_us_games to looker_read;
