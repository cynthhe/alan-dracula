USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- Creates user_journey view
CREATE OR REPLACE VIEW user_journey AS
WITH ways_to_collect_users AS
    (SELECT
        ts AS playtime
        ,sessionid
        ,userid
     FROM stunt_open
     WHERE stunt_name = 'Ways to Collect Stunt'
     AND country = 'US'
     AND submit_time::date >= '7/6/2020')
,journey_data AS
(SELECT
    userid
    ,ts
    ,sessionid
    ,location
    ,Destination
    ,RANK() OVER (PARTITION BY sessionid ORDER BY ts ASC) AS journey_location
FROM (SELECT
        ts
        ,sessionid
        ,userid
        ,EPISODE_NAME AS Location
        ,'Collect' AS Destination
      FROM ACR
      WHERE userid IN (SELECT userid 
                       FROM ways_to_collect_users 
                       GROUP BY 1)
      GROUP BY 1,2,3,4,5
      UNION ALL
      SELECT
        ts
        ,sessionid
        ,userid
        ,game_name AS Location
        ,'Play' AS Destination
      FROM game_open
      WHERE userid IN (SELECT userid 
                       FROM ways_to_collect_users 
                       GROUP BY 1)
      AND game_name LIKE 'Squad Goals'
      GROUP BY 1,2,3,4,5
      UNION ALL
      SELECT
        ts
        ,sessionid
        ,userid
        ,screen_name AS Location
        ,'Shop' AS Destination
      FROM SCREEN_VISIT
      WHERE userid IN (SELECT userid 
                       FROM ways_to_collect_users 
                       GROUP BY 1)
      AND Location = '/shop'
      GROUP BY 1,2,3,4,5)
GROUP BY 1,2,3,4,5)
SELECT
    userid
    ,sessionid
    ,ts::DATE AS action_date
    ,journey_location
    ,location
    ,Destination
FROM journey_data
GROUP BY 1,2,3,4,5,6;

-- Testing user_journey view
SELECT *
FROM user_journey;

SELECT DISTINCT
    Destination
    ,COUNT(sessionid)
    ,COUNT(userid)
FROM user_journey
GROUP BY 1;

-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- Creates reporting view: ARCADE_USER_JOURNEY_VIEW
CREATE OR REPLACE VIEW ARCADE_USER_JOURNEY_VIEW AS
SELECT *
FROM prod_games.arcade.user_journey;

-- Looker permissions for reporting views
GRANT SELECT ON prod_games.reporting.ARCADE_USER_JOURNEY_VIEW TO looker_read;
