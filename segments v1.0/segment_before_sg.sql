use database prod_games;
use schema arcade;
use warehouse wh_default;

// before Squad Goals launch (6/1/20)

-- segment by game only
select
    count(distinct userid) as num_users
    ,count(distinct sessionid) as num_sessions
from prod_games.arcade.apprunning
where country = 'US'
and submit_time::date < to_date('2020-06-01')
and (userid in (select userid from prod_games.arcade.first_played_date where start_date >= '3/4/2019')
     and userid in (select userid from prod_games.arcade.game_start)
     and userid not in (select userid from prod_games.arcade.acr_table)
     and userid not in (select userid from prod_games.arcade.stunt_open where stunt_name != 'Onboarding Video Stunt')
    );

-- segment by game + ACR
select
    count(distinct userid) as num_users
    ,count(distinct sessionid) as num_sessions
from prod_games.arcade.apprunning
where country = 'US'
and submit_time::date < to_date('2020-06-01')
and (userid in (select userid from prod_games.arcade.first_played_date where start_date >= '3/4/2019')
     and userid in (select userid from prod_games.arcade.game_start)
     and userid in (select userid from prod_games.arcade.acr_table)
     and userid not in (select userid from prod_games.arcade.stunt_open where stunt_name != 'Onboarding Video Stunt')
    );

-- segment by game + stunt
select
    count(distinct userid) as num_users
    ,count(distinct sessionid) as num_sessions
from prod_games.arcade.apprunning
where country = 'US'
and submit_time::date < to_date('2020-06-01')
and (userid in (select userid from prod_games.arcade.first_played_date where start_date >= '3/4/2019')
     and userid in (select userid from prod_games.arcade.game_start)
     and userid not in (select userid from prod_games.arcade.acr_table)
     and userid in (select userid from prod_games.arcade.stunt_open where stunt_name != 'Onboarding Video Stunt')
    );

-- segment by game + ACR + stunt
select
    count(distinct userid) as num_users
    ,count(distinct sessionid) as num_sessions
from prod_games.arcade.apprunning
where country = 'US'
and submit_time::date < to_date('2020-06-01')
and (userid in (select userid from prod_games.arcade.first_played_date where start_date >= '3/4/2019')
     and userid in (select userid from prod_games.arcade.game_start)
     and userid in (select userid from prod_games.arcade.acr_table)
     and userid in (select userid from prod_games.arcade.stunt_open where stunt_name != 'Onboarding Video Stunt')
    );

-- segment by ACR
select
    count(distinct userid) as num_users
    ,count(distinct sessionid) as num_sessions
from prod_games.arcade.apprunning
where country = 'US'
and submit_time::date < to_date('2020-06-01')
and (userid in (select userid from prod_games.arcade.first_played_date where start_date >= '3/4/2019')
     and userid not in (select userid from prod_games.arcade.game_start)
     and userid in (select userid from prod_games.arcade.acr_table)
     and userid not in (select userid from prod_games.arcade.stunt_open where stunt_name != 'Onboarding Video Stunt')
    );

-- segment by ACR + stunt
select
    count(distinct userid) as num_users
    ,count(distinct sessionid) as num_sessions
from prod_games.arcade.apprunning
where country = 'US'
and submit_time::date < to_date('2020-06-01')
and (userid in (select userid from prod_games.arcade.first_played_date where start_date >= '3/4/2019')
     and userid not in (select userid from prod_games.arcade.game_start)
     and userid in (select userid from prod_games.arcade.acr_table)
     and userid in (select userid from prod_games.arcade.stunt_open where stunt_name != 'Onboarding Video Stunt')
    );

-- segment by stunt
select
    count(distinct userid) as num_users
    ,count(distinct sessionid) as num_sessions
from prod_games.arcade.apprunning
where country = 'US'
and submit_time::date < to_date('2020-06-01')
and (userid in (select userid from prod_games.arcade.first_played_date where start_date >= '3/4/2019')
     and userid not in (select userid from prod_games.arcade.game_start)
     and userid not in (select userid from prod_games.arcade.acr_table)
     and userid in (select userid from prod_games.arcade.stunt_open where stunt_name != 'Onboarding Video Stunt')
    );

-- segment by disengaged
select
    count(distinct userid) as num_users
    ,count(distinct sessionid) as num_sessions
from prod_games.arcade.apprunning
where country = 'US'
and submit_time::date < to_date('2020-06-01')
and (userid in (select userid from prod_games.arcade.first_played_date where start_date >= '3/4/2019')
     and userid not in (select userid from prod_games.arcade.game_start)
     and userid not in (select userid from prod_games.arcade.acr_table)
     and userid not in (select userid from prod_games.arcade.stunt_open where stunt_name != 'Onboarding Video Stunt')
    );
