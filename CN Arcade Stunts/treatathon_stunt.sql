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

-- DAU who entered Treatathon stunt
CREATE OR REPLACE VIEW treatathon_dau AS
SELECT 
    submit_time::DATE AS date
    ,COUNT(DISTINCT userid) AS dau
FROM prod_games.arcade.stunt_open
WHERE country LIKE 'US' AND userid IN (SELECT userid 
                                       FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                       WHERE START_DATE >= '3/4/2019')
AND stunt_name LIKE '%Halloween%' -- replace with stunt_name = 'stunt name'
AND submit_time::DATE >= TO_DATE('2019-10-01') -- replace with submit_time::DATE >= TO_DATE('2020-10-01')
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
      AND a.stunt_name LIKE '%Halloween%' -- replace with stunt_name = 'stunt name'
      AND a.submit_time::DATE >= TO_DATE('2019-10-01') -- replace with submit_time::DATE >= TO_DATE('2020-10-01')
      GROUP BY 1,2)
ORDER BY week ASC;

-- From the Treatathon stunt, where did the user go next?
CREATE OR REPLACE VIEW treatathon_user_journey AS
WITH treatathon_users AS
    (SELECT
        ts AS playtime
        ,sessionid
        ,userid
     FROM stunt_open
     WHERE stunt_name LIKE '%Halloween%' -- replace with stunt_name = 'stunt name'
     AND country = 'US'
     AND userid IN (SELECT userid
                    FROM prod_games.arcade.FIRST_PLAYED_DATE
                    WHERE START_DATE >= '3/4/2019')
     AND submit_time::DATE >= TO_DATE('2019-10-01') -- replace with submit_time::DATE >= TO_DATE('2020-10-01')
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
      AND submit_time::DATE >= TO_DATE('2019-10-01') -- replace with submit_time::DATE >= TO_DATE('2020-10-01')
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
      AND submit_time::DATE >= TO_DATE('2019-10-01') -- replace with submit_time::DATE >= TO_DATE('2020-10-01')
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
      AND submit_time::DATE >= TO_DATE('2019-10-01') -- replace with submit_time::DATE >= TO_DATE('2020-10-01')
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

-- Neon economy
CREATE OR REPLACE VIEW arcade_neon_economy AS
SELECT DISTINCT
    a.submit_time::DATE AS date
    ,SUM(b.currency_amount) AS total_gained
    ,SUM(a.purchased_item_price) AS total_spent
    ,(total_gained - total_spent) AS neon_net_total
    ,COUNT(DISTINCT a.userid) AS num_users
FROM prod_games.arcade.purchase a
JOIN prod_games.arcade.currency_claimed b
ON a.userid = b.userid AND a.submit_time::DATE = b.submit_time::DATE
WHERE a.userid IN (SELECT userid
                 FROM prod_games.arcade.FIRST_PLAYED_DATE
                 WHERE START_DATE >= '3/4/2019')
//WHERE a.userid = 'e7ca06ae279614cdb85d49f632f3cc4a'
AND a.submit_time::DATE >= TO_DATE('2019-10-07') -- replace with submit_time::DATE >= TO_DATE('2020-10-01')
GROUP BY 1;