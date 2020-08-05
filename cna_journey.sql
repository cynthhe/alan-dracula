//1. player journey for arcade
//- first players user journey
//take a union on screen visit, game open, game starts, acr, shop
//userid, timestamp, name of where they were, rank base on time stamp to get step,
//only first session
//
//average actions for each step

WITH cna_journey AS 
(select
userid ,sessionid
from FIRST_PLAYED_DATE),
journey_data as (
select
userid
,sessionid
,ts
,SCREEN_NAME as location
from "PROD_GAMES"."ARCADE"."SCREEN_VISIT" 
where sessionid in (select
userid ,sessionid
from first_session)
union all
select
userid
,sessionid
,ts
,game_name as location
from "PROD_GAMES"."ARCADE".",game_open" 
where sessionid in (select
userid ,sessionid
from first_session))
),
user_level_journey as (
select
userid
,sessionid
,rank(on ts asc) as action_sequence
,location
from journey_data)
select
ranks
,location
,count(distinct userid) as users
,count(distinct sessionid) as sessions
from user_level_journey
group 1,2;
select * from "PROD_GAMES"."ARCADE"."GDB_GOTREWARD" limit 1000;

//WITH ways_to_collect_users AS
//    (SELECT
//        ts AS playtime
//        ,sessionid
//        ,userid
//     FROM stunt_open
//     WHERE stunt_name = 'Ways to Collect Stunt'
//     AND country = 'US'
//     AND submit_time::date >= '7/6/2020')
//,journey_data AS
//(SELECT
//    userid
//    ,ts
//    ,sessionid
//    ,location
//    ,Destination
//    ,RANK() OVER (PARTITION BY sessionid ORDER BY ts Asc) as journey_location
//FROM (SELECT
//        ts
//        ,sessionid
//        ,userid
//        ,EPISODE_NAME AS Location
//        ,'Collect' AS Destination
//      FROM ACR
//      WHERE userid IN (SELECT userid 
//                       FROM ways_to_collect_users 
//                       GROUP BY 1)
//      GROUP BY 1,2,3,4,5
//      UNION ALL
//      SELECT
//        ts
//        ,sessionid
//        ,userid
//        ,game_name AS Location
//        ,'Play' AS Destination
//      FROM game_open
//      WHERE userid IN (SELECT userid 
//                       FROM ways_to_collect_users 
//                       GROUP BY 1)
//      AND game_name LIKE 'Squad Goals'
//      GROUP BY 1,2,3,4,5
//      UNION ALL
//      SELECT
//        ts
//        ,sessionid
//        ,userid
//        ,screen_name AS Location
//        ,'Shop' AS Destination
//      FROM SCREEN_VISIT
//      WHERE userid IN (SELECT userid 
//                       FROM ways_to_collect_users 
//                       GROUP BY 1)
//      AND Location = '/shop'
//      GROUP BY 1,2,3,4,5)
//GROUP BY 1,2,3,4,5)
//SELECT
//    userid
//    ,sessionid
//    ,ts::DATE AS action_date
//    ,journey_location
//    ,location
//    ,Destination
//FROM journey_data
//GROUP BY 1,2,3,4,5,6;
