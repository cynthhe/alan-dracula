-- REPORTING schema
use database prod_games;
use schema reporting;
use warehouse wh_default;

create or replace view PROD_GAMES.REPORTING.ARCADE_ADS_AND_GAMES as
select
    date 
    ,platform 
    ,case when game like 'Smashy%' then 'Smashy Pinata'
        when game like '%Maze' then 'Maize Maze'
        else game
        end as game
    ,ads_offered 
    ,game_starts 
    ,game_plays 
    ,users 
    ,sessions 
from reporting.arcade_ads_and_games_table;

-- Looker permissions for reporting view
grant select on prod_games.reporting.ARCADE_ADS_AND_GAMES to looker_read;
