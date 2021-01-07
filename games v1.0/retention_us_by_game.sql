-- REPORTING schema
use database prod_games;
use schema reporting;
use warehouse wh_default;

create or replace view PROD_GAMES.REPORTING.ARCADE_RETENTION_US_BY_GAME as
select  
    case when Game like 'Smashy%' then 'Smashy Pinata'
        when Game like '%Maze' then 'Maize Maze'
        else Game
        end as Game
    ,Date
    ,new_user
    ,DAU
    ,WAU
    ,MAU
    ,Day_1 
    ,Day_3
    ,Day_7
    ,Day_14
    ,Day_30
from prod_games.reporting.ARCADE_RETENTION_US_BY_GAME_table;

-- Looker permissions for reporting view
grant select on prod_games.reporting.ARCADE_RETENTION_US_BY_GAME to looker_read;
