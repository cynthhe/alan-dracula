-- REPORTING schema
use database prod_games;
use schema reporting;
use warehouse wh_default;

create or replace view prod_games.reporting.arcade_challenge_complete as
select
    submit_time::date as day
    ,game_show_name
    ,case when game_name like 'Smashy%' then 'Smashy Pinata'
        when game_name like '%Maze' then 'Maize Maze'
        else game_name
        end as game_name
    ,goal
    ,reward as currency_awarded_for_Challenge
    ,sum(reward) as total_currency_awarded
    ,count(userid) as total_times_rewarded
from prod_games.arcade.challenge_complete
where country like 'US' and submit_time::date >= '3/3/2020'
group by 1,2,3,4,5;

-- Looker permissions for reporting view
grant select on prod_games.reporting.arcade_challenge_complete to looker_read;
