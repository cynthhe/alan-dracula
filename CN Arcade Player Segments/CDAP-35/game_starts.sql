USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- Creates segment_gamestarts view
CREATE OR REPLACE VIEW segment_gamestarts AS
SELECT
    a.submit_time::DATE AS date
    ,CASE WHEN a.game_name LIKE 'Smashy%' THEN 'Smashy Pinata' ELSE a.game_name END AS game_name
    ,a.platform
    ,b.segment
    ,COUNT(DISTINCT a.userid) AS users
    ,COUNT(DISTINCT a.sessionid) AS sessions
    ,COUNT(DISTINCT a.game_session_id) AS game_starts
FROM prod_games.arcade.game_open a
JOIN arcade_engagement_segments b ON (a.userid = b.userid) AND ((YEAR(a.submit_time)||LPAD(MONTH(a.submit_time),2,'0')) = b.yearmonth)
WHERE a.country LIKE 'US' 
AND a.userid IN (SELECT userid 
                 FROM prod_games.arcade.FIRST_PLAYED_DATE 
                 WHERE START_DATE >= '3/4/2019')
AND date >= '3/4/2019'
GROUP BY 1,2,3,4;

-- Drops segment_gamestarts view
DROP VIEW segment_gamestarts;

-- Testing segment_gamestarts
SELECT *
FROM segment_gamestarts;

-- Creates ARCADE_SEGMENT_GAMESTARTS table
CREATE TABLE ARCADE_SEGMENT_GAMESTARTS AS
SELECT *
FROM prod_games.arcade.segment_gamestarts;

-- Creates active_game_gamestarts view
CREATE OR REPLACE VIEW active_game_gamestarts AS
SELECT 
    'Arcade' AS game 
    ,a.submit_time::DATE AS date 
    ,a.game_name as ad_game 
    ,CASE WHEN b.active_game LIKE 'Smashy%' THEN 'Smashy Pinata' ELSE b.active_game END AS active_game 
    ,a.platform 
    ,COUNT(DISTINCT a.userid) AS users 
    ,COUNT(DISTINCT a.sessionid) AS sessions 
    ,COUNT(DISTINCT a.game_session_id) AS game_starts 
FROM prod_games.arcade.game_open a 
JOIN arcade_active_game b ON (a.userid = b.userid) AND (a.submit_time::DATE = b.date) 
WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                           FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                           WHERE START_DATE >= '3/4/2019') 
AND date >= '3/4/2019'
GROUP BY 1,2,3,4,5;

-- Drops active_game_gamestarts view
DROP VIEW active_game_gamestarts;

-- Testing active_game_gamestarts
SELECT *
FROM active_game_gamestarts;

-- Creates ARCADE_ACTIVE_GAME_GAMESTARTS table
CREATE TABLE ARCADE_ACTIVE_GAME_GAMESTARTS AS
SELECT *
FROM prod_games.arcade.active_game_gamestarts;
