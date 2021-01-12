-- REPORTING schema
use database prod_games;
use schema reporting;
use warehouse wh_default;

-- How many displays per day of each screen (feedback and rate us)?
create or replace view arcade_feedback_rateus as
select
    submit_time::date as date
    ,platform
    ,case when screen_name like '%feedback%' then 'Feedback'
        when screen_name like '%rate%' then 'Rate Us'
        else screen_name
        end as screen_name
    ,count(userid) as num_displays
from prod_games.arcade.screen_visit
where date >= to_date('2019-03-04')
and (screen_name like '%feedback%'
     or screen_name like '%rate%')
group by 1,2,3;

-- Looker permissions for reporting view
grant select on prod_games.reporting.arcade_feedback_rateus to looker_read;
