use database prod_games;
use schema arcade;
use warehouse wh_default;

// CNA lifetime

-- segment by game only
select
    count(distinct userid) as num_users
    ,count(distinct sessionid) as num_sessions
from prod_games.arcade.apprunning
where country = 'US' 
and userid in (
  select userid
  from prod_games.arcade.first_played_date
  where start_date >= '3/4/2019'
)
and userid in (
  select userid
  from prod_games.arcade.game_start
)
and userid not in (
  select userid
  from prod_games.arcade.acr_table
)
and userid not in (
  select userid
  from prod_games.arcade.stunt_open
);

-- segment by game + ACR
select
    count(distinct userid) as num_users
    ,count(distinct sessionid) as num_sessions
from prod_games.arcade.apprunning
where country = 'US' 
and userid in (
  select userid
  from prod_games.arcade.first_played_date
  where start_date >= '3/4/2019'
)
and userid in (
  select userid
  from prod_games.arcade.game_start
)
and userid in (
  select userid
  from prod_games.arcade.acr_table
)
and userid not in (
  select userid
  from prod_games.arcade.stunt_open
);

-- segment by game + stunt
select
    count(distinct userid) as num_users
    ,count(distinct sessionid) as num_sessions
from prod_games.arcade.apprunning
where country = 'US' 
and userid in (
  select userid
  from prod_games.arcade.first_played_date
  where start_date >= '3/4/2019'
)
and userid in (
  select userid
  from prod_games.arcade.game_start
)
and userid not in (
  select userid
  from prod_games.arcade.acr_table
)
and userid in (
  select userid
  from prod_games.arcade.stunt_open
);

-- segment by game + ACR + stunt
select
    count(distinct userid) as num_users
    ,count(distinct sessionid) as num_sessions
from prod_games.arcade.apprunning
where country = 'US' 
and userid in (
  select userid
  from prod_games.arcade.first_played_date
  where start_date >= '3/4/2019'
)
and userid in (
  select userid
  from prod_games.arcade.game_start
)
and userid in (
  select userid
  from prod_games.arcade.acr_table
)
and userid in (
  select userid
  from prod_games.arcade.stunt_open
);

-- segment by ACR
select
    count(distinct userid) as num_users
    ,count(distinct sessionid) as num_sessions
from prod_games.arcade.apprunning
where country = 'US' 
and userid in (
  select userid
  from prod_games.arcade.first_played_date
  where start_date >= '3/4/2019'
)
and userid not in (
  select userid
  from prod_games.arcade.game_start
)
and userid in (
  select userid
  from prod_games.arcade.acr_table
)
and userid not in (
  select userid
  from prod_games.arcade.stunt_open
);

-- segment by ACR + stunt
select
    count(distinct userid) as num_users
    ,count(distinct sessionid) as num_sessions
from prod_games.arcade.apprunning
where country = 'US' 
and userid in (
  select userid
  from prod_games.arcade.first_played_date
  where start_date >= '3/4/2019'
)
and userid not in (
  select userid
  from prod_games.arcade.game_start
)
and userid in (
  select userid
  from prod_games.arcade.acr_table
)
and userid in (
  select userid
  from prod_games.arcade.stunt_open
);

-- segment by stunt
select
    count(distinct userid) as num_users
    ,count(distinct sessionid) as num_sessions
from prod_games.arcade.apprunning
where country = 'US' 
and userid in (
  select userid
  from prod_games.arcade.first_played_date
  where start_date >= '3/4/2019'
)
and userid not in (
  select userid
  from prod_games.arcade.game_start
)
and userid not in (
  select userid
  from prod_games.arcade.acr_table
)
and userid in (
  select userid
  from prod_games.arcade.stunt_open
);

-- segment by disengaged
select
    count(distinct userid) as num_users
    ,count(distinct sessionid) as num_sessions
from prod_games.arcade.apprunning
where country = 'US' 
and userid in (
  select userid
  from prod_games.arcade.first_played_date
  where start_date >= '3/4/2019'
)
and userid not in (
  select userid
  from prod_games.arcade.game_start
)
and userid not in (
  select userid
  from prod_games.arcade.acr_table
)
and userid not in (
  select userid
  from prod_games.arcade.stunt_open
);
