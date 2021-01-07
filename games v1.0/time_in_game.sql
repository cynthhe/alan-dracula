-- REPORTING schema
use database prod_games;
use schema reporting;
use warehouse wh_default;

create or replace view prod_games.reporting.arcade_time_in_game as
select
    date
    ,userid
    ,sessionid
    ,game_session_id
    ,case when app_location like 'Smashy%' then 'Smashy Pinata' 
        when app_location like '%Maze' then 'Maize Maze'
        else app_location 
        end as app_location
    ,seconds_in_game 
    ,platform
    ,registered
from arcade.arcade_time_in_game_old;

-- Looker permissions for reporting view
grant select on prod_games.reporting.arcade_time_in_game to looker_read;
