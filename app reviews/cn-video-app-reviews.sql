use database prod_games;
use schema arcade;
use warehouse wh_default;

create table cn_video_app_reviews (
  Country varchar
  ,Rating int
  ,Date date
  ,Version varchar
  ,Username varchar
  ,Title varchar
  ,Content varchar
);

drop table cn_video_app_reviews;

-- REPORTING schema
use database prod_games;
use schema reporting;
use warehouse wh_default;

create or replace view happy_review_ratings as
select
    date
    ,version
    ,sum(case when rating = '4' or rating = '5' then 1 else 0 end) as high_rating_counter
    ,sum(case when rating = '1' or rating = '2' or rating = '3' or rating = '4' or rating = '5' then 1 else 0 end) as total_reviews
from prod_games.arcade.cn_video_app_reviews
where date is not null
and version is not null
group by 1,2;

-- Looker permissions for reporting view
grant select on prod_games.reporting.happy_review_ratings to looker_read;
