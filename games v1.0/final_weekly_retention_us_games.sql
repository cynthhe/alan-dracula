-- REPORTING schema
use database prod_games;
use schema reporting;
use warehouse wh_default;

create or replace view prod_games.reporting.final_weekly_retention_us_games as
select
    case when a.game_name like 'Smashy%' then 'Smashy Pinata'
        when a.game_name like '%Maze' then 'Maize Maze'
        else a.game_name
        end as game_name
    ,a.start_week
    ,a.week_since_start
    ,a.users/b.cohort_size as retention
from reporting.weekly_retention_US_games a
join (select 
        start_week
        ,users as cohort_size 
      from reporting.weekly_retention_us 
      where week_since_start = 0) b on b.start_week = a.start_week;

-- Looker permissions for reporting view
grant select on prod_games.reporting.final_weekly_retention_us_games to looker_read;
