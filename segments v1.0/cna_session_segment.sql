use database prod_games;
use schema arcade;
use warehouse wh_default;

//CNA lifetime (3/4/19 - 12/16/20)

-- segment by game only
select distinct
count(distinct sessionid)
from prod_games.arcade.apprunning
where country = 'US'
and (sessionid in (select sessionid from prod_games.arcade.game_start)
     and sessionid not in (select sessionid from prod_games.arcade.acr_table)
     and sessionid not in (select sessionid from prod_games.arcade.stunt_open where stunt_name != 'Onboarding Video Stunt')
     and userid in (select userid from prod_games.arcade.first_played_date where start_date >= '3/4/2019')
    );
    
-- segment by disengaged
select distinct
count(distinct sessionid)
from prod_games.arcade.apprunning
where country = 'US'
and (sessionid not in (select sessionid from prod_games.arcade.game_start)
     and sessionid not in (select sessionid from prod_games.arcade.acr_table)
     and sessionid not in (select sessionid from prod_games.arcade.stunt_open where stunt_name != 'Onboarding Video Stunt')
     and userid in (select userid from prod_games.arcade.first_played_date where start_date >= '3/4/2019')
    );
    
-- segment by ACR only
select distinct
count(distinct sessionid)
from prod_games.arcade.apprunning
where country = 'US'
and (sessionid not in (select sessionid from prod_games.arcade.game_start)
     and sessionid in (select sessionid from prod_games.arcade.acr_table)
     and sessionid not in (select sessionid from prod_games.arcade.stunt_open where stunt_name != 'Onboarding Video Stunt')
     and userid in (select userid from prod_games.arcade.first_played_date where start_date >= '3/4/2019')
    );

-- segment by stunt + game
select distinct
count(distinct sessionid)
from prod_games.arcade.apprunning
where country = 'US'
and (sessionid in (select sessionid from prod_games.arcade.game_start)
     and sessionid not in (select sessionid from prod_games.arcade.acr_table)
     and sessionid in (select sessionid from prod_games.arcade.stunt_open where stunt_name != 'Onboarding Video Stunt')
     and userid in (select userid from prod_games.arcade.first_played_date where start_date >= '3/4/2019')
    );
    
-- segment by game + ACR
select distinct
count(distinct sessionid)
from prod_games.arcade.apprunning
where country = 'US'
and (sessionid in (select sessionid from prod_games.arcade.game_start)
     and sessionid in (select sessionid from prod_games.arcade.acr_table)
     and sessionid not in (select sessionid from prod_games.arcade.stunt_open where stunt_name != 'Onboarding Video Stunt')
     and userid in (select userid from prod_games.arcade.first_played_date where start_date >= '3/4/2019')
    );
    
-- segment by stunt only
select distinct
count(distinct sessionid)
from prod_games.arcade.apprunning
where country = 'US'
and (sessionid not in (select sessionid from prod_games.arcade.game_start)
     and sessionid not in (select sessionid from prod_games.arcade.acr_table)
     and sessionid in (select sessionid from prod_games.arcade.stunt_open where stunt_name != 'Onboarding Video Stunt')
     and userid in (select userid from prod_games.arcade.first_played_date where start_date >= '3/4/2019')
    );

-- segment by stunt + game + ACR
select distinct
count(distinct sessionid)
from prod_games.arcade.apprunning
where country = 'US'
and (sessionid in (select sessionid from prod_games.arcade.game_start)
     and sessionid in (select sessionid from prod_games.arcade.acr_table)
     and sessionid in (select sessionid from prod_games.arcade.stunt_open where stunt_name != 'Onboarding Video Stunt')
     and userid in (select userid from prod_games.arcade.first_played_date where start_date >= '3/4/2019')
    );

-- segment by stunt + ACR
select distinct
count(distinct sessionid)
from prod_games.arcade.apprunning
where country = 'US'
and (sessionid not in (select sessionid from prod_games.arcade.game_start)
     and sessionid in (select sessionid from prod_games.arcade.acr_table)
     and sessionid in (select sessionid from prod_games.arcade.stunt_open where stunt_name != 'Onboarding Video Stunt')
     and userid in (select userid from prod_games.arcade.first_played_date where start_date >= '3/4/2019')
    );
