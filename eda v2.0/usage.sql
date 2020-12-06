use database prod_games;
use schema arcade;
use warehouse wh_default;

//Day of the week usage

-- all CNA users
select distinct 
    dayofweek(submit_time) as day_of_week
    ,count(distinct userid)
from apprunning
group by 1
order by day_of_week desc;

-- CNA users who were active in the last 30 days
select distinct 
    dayofweek(submit_time) as day_of_week
    ,count(distinct userid)
from prod_games.arcade.apprunning
where submit_time::date >= dateadd(day,-30,current_date()) and submit_time::date <= current_date()
and country like 'US' and userid in (select userid
                                     from prod_games.arcade.first_played_date
                                     where start_date >= '3/4/2019'
                                    )
group by 1
order by day_of_week desc;
