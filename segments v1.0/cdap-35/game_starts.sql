USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- Create SEGMENT_GAMESTARTS view
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
JOIN prod_games.arcade.arcade_engagement_segments b ON (a.userid = b.userid) AND ((YEAR(a.submit_time)||LPAD(MONTH(a.submit_time),2,'0')) = b.yearmonth)
WHERE a.country LIKE 'US' 
AND a.userid IN (SELECT userid 
                 FROM prod_games.arcade.FIRST_PLAYED_DATE 
                 WHERE START_DATE >= '3/4/2019')
AND date >= '3/4/2019'
GROUP BY 1,2,3,4;

-- Create ACTIVE_GAME_GAMESTARTS view
CREATE OR REPLACE VIEW active_game_gamestarts AS
SELECT 
    'Arcade' AS game 
    ,a.submit_time::DATE AS date 
    ,CASE WHEN a.game_name LIKE 'Smashy%' THEN 'Smashy Pinata' ELSE a.game_name END AS ad_game 
    ,CASE WHEN b.active_game LIKE 'Smashy%' THEN 'Smashy Pinata' ELSE b.active_game END AS active_game 
    ,a.platform 
    ,COUNT(DISTINCT a.userid) AS users 
    ,COUNT(DISTINCT a.sessionid) AS sessions 
    ,COUNT(DISTINCT a.game_session_id) AS game_starts 
FROM prod_games.arcade.game_open a 
JOIN prod_games.arcade.arcade_active_game b ON (a.userid = b.userid) AND (a.submit_time::DATE = b.date) 
WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                           FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                           WHERE START_DATE >= '3/4/2019') 
AND date >= '3/4/2019'
GROUP BY 1,2,3,4,5;

-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- Create reporting view: ARCADE_SEGMENT_GAMESTARTS_VIEW
CREATE OR REPLACE VIEW ARCADE_SEGMENT_GAMESTARTS_VIEW AS
SELECT *
FROM ARCADE_SEGMENT_GAMESTARTS;

-- Create reporting view: ARCADE_ACTIVE_GAME_GAMESTARTS_VIEW
CREATE OR REPLACE VIEW ARCADE_ACTIVE_GAME_GAMESTARTS_VIEW AS
SELECT *
FROM ARCADE_ACTIVE_GAME_GAMESTARTS;

-- Looker permissions for reporting views
GRANT SELECT ON prod_games.reporting.ARCADE_SEGMENT_GAMESTARTS_VIEW TO looker_read;
GRANT SELECT ON prod_games.reporting.ARCADE_ACTIVE_GAME_GAMESTARTS_VIEW TO looker_read;
