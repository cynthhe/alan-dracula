USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- From the Beastmas stunt, where did the user go next?
CREATE OR REPLACE VIEW beastmas_user_journey AS
WITH beastmas_users AS
    (SELECT
        ts AS playtime
        ,sessionid
        ,userid
     FROM prod_games.arcade.stunt_open
     WHERE stunt_name = 'Holiday Stunt - Intro' -- replace with stunt_name = 'stunt name'
     AND country = 'US'
     AND userid IN (SELECT userid
                    FROM prod_games.arcade.FIRST_PLAYED_DATE
                    WHERE START_DATE >= '3/4/2019')
     AND submit_time::DATE >= TO_DATE('2020-12-01') -- replace with submit_time::DATE >= TO_DATE('2020-12-01')
    )
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
        ,'ACR' AS Destination
      FROM prod_games.arcade.ACR
      WHERE userid IN (SELECT userid 
                       FROM beastmas_users 
                       GROUP BY 1)
      AND submit_time::DATE >= TO_DATE('2020-12-01') -- replace with submit_time::DATE >= TO_DATE('2020-12-01')
      GROUP BY 1,2,3,4,5
      UNION ALL
      SELECT
        ts
        ,sessionid
        ,userid
        ,game_name AS Location
        ,'Squad Goals' AS Destination
      FROM prod_games.arcade.game_open
      WHERE userid IN (SELECT userid 
                       FROM beastmas_users 
                       GROUP BY 1)
      AND game_name LIKE 'Squad Goals'
      AND submit_time::DATE >= TO_DATE('2020-12-01') -- replace with submit_time::DATE >= TO_DATE('2020-10-01')
      GROUP BY 1,2,3,4,5
      UNION ALL
      SELECT
        ts
        ,sessionid
        ,userid
        ,screen_name AS Location
        ,'Figure Shop' AS Destination
      FROM prod_games.arcade.screen_visit
      WHERE userid IN (SELECT userid 
                       FROM beastmas_users 
                       GROUP BY 1)
      AND Location = '/shop'
      AND submit_time::DATE >= TO_DATE('2020-12-01') -- replace with submit_time::DATE >= TO_DATE('2020-10-01')
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

-- Looker permissions for reporting view
GRANT SELECT ON prod_games.reporting.beastmas_user_journey TO looker_read;
