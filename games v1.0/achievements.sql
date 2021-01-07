-- REPORTING schema
use database prod_games;
use schema reporting;
use warehouse wh_default;

create or replace view prod_games.reporting.achievements as
select 
    submit_time::Date as achievement_date
    ,platform
    ,case when game_name like 'Smashy%' then 'Smashy Pinata'
        when game_name like '%Maze' then 'Maize Maze'
        else game_name
        end as game_name
    ,achievement_name
    ,count(distinct userid) as users
    ,count(*) as times_collected
from prod_games.arcade.ACHIEVEMENT
where country like 'US'
group by 1,2,3,4;

-- Looker permissions for reporting view
grant select on prod_games.reporting.achievements to looker_read;
