USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

//ACR Conversion:
//
//How many users who were not collecting before were converted by this stunt?
//Game Economy:
//
//How many neons are being spent? How does that compare to other
//time periods that are not similar to the stunt/where there was no stunt at all?
//Does this stunt remove currency from the game?
//What levers do we need to pull to drain economy?
//Determine whether revenue needs to be looked at an economy level as a whole or player level.
//Dashboard Layout:
//
//DAU (daily active users)
//WOW (week over week)
//# of users who went where (ACR/Squad Goals/Shop) from the stunt page
//ACR Conversion
//Game Economy

-- # of users who entered Treatathon stunt
SELECT 
    submit_time::DATE AS date
    ,COUNT(DISTINCT userid) AS num_users
FROM prod_games.arcade.stunt_open
WHERE country LIKE 'US' AND userid IN (SELECT userid 
                                       FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                       WHERE START_DATE >= '3/4/2019')
AND stunt_name = 'Halloween 2020 Treat-A-Thon' -- replace with stunt_name = 'stunt name'
AND submit_time::DATE >= TO_DATE('2020-10-01') -- replace with submit_time::DATE >= TO_DATE('2020-10-01')
GROUP BY 1;

-- WOW
CREATE OR REPLACE VIEW treatathon_wow AS
SELECT
    week
    ,week0
    ,week1
    ,week1/week0 AS wow_retention
FROM (SELECT
        YEAR(a.submit_time) AS year
        ,WEEK(a.submit_time) AS week
        ,COUNT(DISTINCT a.userid) as week0
        ,COUNT(DISTINCT b.userid) as week1
      FROM prod_games.arcade.stunt_open a
      LEFT JOIN prod_games.arcade.stunt_open b ON WEEK(b.submit_time) = WEEK(a.submit_time)+1 AND (a.userid = b.userid)
      WHERE YEAR(a.submit_time) = '2020' AND WEEK(a.submit_time) < WEEK(CURRENT_TIMESTAMP)+1
      AND a.userid IN (SELECT userid 
                       FROM prod_games.arcade.FIRST_PLAYED_DATE 
                       WHERE START_DATE >= '3/4/2019')
      AND a.country LIKE 'US'
      AND a.stunt_name = 'Halloween 2020 Treat-A-Thon' -- replace with stunt_name = 'stunt name'
      AND a.submit_time::DATE >= TO_DATE('2020-10-01') -- replace with submit_time::DATE >= TO_DATE('2020-10-01')
      GROUP BY 1,2)
ORDER BY week ASC;

-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- From the Treatathon stunt, where did the user go next?
CREATE OR REPLACE VIEW treatathon_user_journey AS
WITH treatathon_users AS
    (SELECT
        ts AS playtime
        ,sessionid
        ,userid
     FROM prod_games.arcade.stunt_open
     WHERE stunt_name = 'Halloween 2020 Treat-A-Thon' -- replace with stunt_name = 'stunt name'
     AND country = 'US'
     AND userid IN (SELECT userid
                    FROM prod_games.arcade.FIRST_PLAYED_DATE
                    WHERE START_DATE >= '3/4/2019')
     AND submit_time::DATE >= TO_DATE('2020-10-01') -- replace with submit_time::DATE >= TO_DATE('2020-10-01')
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
                       FROM treatathon_users 
                       GROUP BY 1)
      AND submit_time::DATE >= TO_DATE('2020-10-01') -- replace with submit_time::DATE >= TO_DATE('2020-10-01')
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
                       FROM treatathon_users 
                       GROUP BY 1)
      AND game_name LIKE 'Squad Goals'
      AND submit_time::DATE >= TO_DATE('2020-10-01') -- replace with submit_time::DATE >= TO_DATE('2020-10-01')
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
                       FROM treatathon_users 
                       GROUP BY 1)
      AND Location = '/shop'
      AND submit_time::DATE >= TO_DATE('2020-10-01') -- replace with submit_time::DATE >= TO_DATE('2020-10-01')
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
GRANT SELECT ON prod_games.reporting.treatathon_user_journey TO looker_read;

-- How many users who were not collecting before were converted by this stunt?
//before the stunt: users who never acr'ed ever in their lifetime? if this stunt converted them to acr?
