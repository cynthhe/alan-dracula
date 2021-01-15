-- REPORTING schema
use database prod_games;
use schema reporting;
use warehouse wh_default;

create or replace view prod_games.reporting.arcade_lessengagedgamesplayed as
select
    case when a.game_name like 'Smashy%' then 'Smashy Pinata'
        when a.game_name like '%Maze' then 'Maize Maze'
        else a.game_name
        end as game_name
    ,b.date_diff
    ,count(distinct a.userid) as users
    ,count(a.GAME_SESSION_ID) as games
    ,count(distinct a.submit_time::date) as days_game_was_played
from prod_games.arcade.game_open a
join (select 
        userid
        ,date_diff
        ,sessions
      from (select 
                userid
                ,datediff(day, min(submit_time::date), max(submit_time::date)) as date_diff
                ,count(distinct sessionid) as sessions
            from prod_games.arcade.apprunning
            where country like 'US' and userid in (select 
                                                    userid 
                                                   from prod_games.arcade.first_played_date 
                                                   where start_date >= '3/4/2019')
            group by 1)
      where date_diff <= 6 or sessions <= 5) b on b.userid = a.userid
      group by 1,2;

-- Looker permissions for reporting view
grant select on prod_games.reporting.arcade_lessengagedgamesplayed to looker_read;
