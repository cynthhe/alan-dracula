USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- Creates segment_acr view
CREATE OR REPLACE VIEW segment_acr AS
SELECT
    a.userid
    ,a.submit_time
    ,b.segment
    ,episode_name
    ,figure_granted
    ,play_userloggedin
    ,platform
    ,success
    ,code
FROM prod_games.arcade.ACR a
JOIN prod_games.arcade.arcade_engagement_segments b ON (a.userid = b.userid) AND ((YEAR(a.submit_time)||LPAD(MONTH(a.submit_time),2,'0')) = b.yearmonth)
WHERE a.country LIKE 'US'
AND a.submit_time >= '3/4/2019';

-- Drops segment_acr view
DROP VIEW segment_acr;

-- Tests segment_acr view
SELECT *
FROM segment_acr;

-- Creates ARCADE_SEGMENT_ACR table
CREATE TABLE ARCADE_SEGMENT_ACR AS
SELECT *
FROM segment_acr;

-- Creates active_game_acr view
CREATE OR REPLACE VIEW active_game_acr AS
SELECT DISTINCT
    a.userid
    ,CASE WHEN b.active_game LIKE 'Smashy%' THEN 'Smashy Pinata' ELSE b.active_game END AS active_game
    ,sessionid
    ,a.submit_time
    ,ts
    ,platform
    ,city
    ,country
    ,capture_id
    ,capture_time
    ,episode_name
    ,play_userloggedin
    ,figure_granted
    ,success
    ,code
FROM prod_games.arcade.ACR a
JOIN prod_games.arcade.arcade_active_game b ON (a.userid = b.userid) AND (a.submit_time::DATE = b.date)
WHERE a.country LIKE 'US'
AND a.submit_time >= '3/4/2019';

-- Testing active_game_acr view
SELECT *
FROM active_game_acr;

SELECT DISTINCT 
    code 
    ,success
    ,COUNT(*)
FROM active_game_acr
GROUP BY 1,2
ORDER BY code;

-- Creates ARCADE_ACTIVE_GAME_ACR table
CREATE TABLE ARCADE_ACTIVE_GAME_ACR AS
SELECT *
FROM prod_games.arcade.active_game_acr;

-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- Creates reporting view: ARCADE_SEGMENT_ACR_VIEW
CREATE OR REPLACE VIEW ARCADE_SEGMENT_ACR_VIEW AS
SELECT *
FROM prod_games.reporting.ARCADE_SEGMENT_ACR;

-- Creates reporting view: ARCADE_ACTIVE_GAME_ACR_VIEW
CREATE OR REPLACE VIEW ARCADE_ACTIVE_GAME_ACR_VIEW AS
SELECT *
FROM ARCADE_ACTIVE_GAME_ACR;

-- Looker permissions for reporting views
GRANT SELECT ON prod_games.reporting.ARCADE_SEGMENT_ACR_VIEW TO looker_read;
GRANT SELECT ON prod_games.reporting.ARCADE_ACTIVE_GAME_ACR_VIEW TO looker_read;
