USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- Creates segment_time_in_game view
CREATE OR REPLACE VIEW segment_time_in_game AS
SELECT
    date
    ,a.userid
    ,sessionid
    ,game_session_id
    ,b.segment
    ,CASE WHEN a.app_location LIKE 'Smashy%' THEN 'Smashy Pinata' ELSE a.app_location END AS app_location
    ,ROUND(seconds_in_game / 60) AS min_in_game
FROM prod_games.arcade.TIME_IN_GAME a
JOIN prod_games.arcade.arcade_engagement_segments b ON (a.userid = b.userid) AND ((YEAR(a.date)||LPAD(MONTH(a.date),2,'0')) = b.yearmonth);

-- Creates ARCADE_SEGMENT_TIME_IN_GAME table
CREATE TABLE ARCADE_SEGMENT_TIME_IN_GAME AS
SELECT *
FROM prod_games.arcade.segment_time_in_game;

-- Creates active_game_time_in_game view
CREATE OR REPLACE VIEW active_game_time_in_game AS
SELECT
    a.date
    ,a.userid
    ,sessionid
    ,game_session_id
    ,CASE WHEN b.active_game LIKE 'Smashy%' THEN 'Smashy Pinata' ELSE b.active_game END AS active_game
    ,CASE WHEN a.app_location LIKE 'Smashy%' THEN 'Smashy Pinata' ELSE a.app_location END AS app_location
    ,ROUND(seconds_in_game / 60) AS min_in_game
FROM prod_games.arcade.TIME_IN_GAME a
JOIN prod_games.arcade.arcade_active_game b ON (a.userid = b.userid) AND (a.date = b.date);

-- Creates ARCADE_ACTIVE_GAME_TIME_IN_GAME table
CREATE TABLE ARCADE_ACTIVE_GAME_TIME_IN_GAME AS
SELECT *
FROM prod_games.arcade.active_game_time_in_game;

-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- Creates reporting view: ARCADE_SEGMENT_TIME_IN_GAME_VIEW
CREATE OR REPLACE VIEW ARCADE_SEGMENT_TIME_IN_GAME_VIEW AS
SELECT *
FROM ARCADE_SEGMENT_TIME_IN_GAME;

-- Creates reporting view: ARCADE_ACTIVE_GAME_TIME_IN_GAME_VIEW
CREATE OR REPLACE VIEW ARCADE_ACTIVE_GAME_TIME_IN_GAME_VIEW AS
SELECT *
FROM ARCADE_ACTIVE_GAME_TIME_IN_GAME;

-- Looker permissions for reporting views
GRANT SELECT ON prod_games.reporting.ARCADE_SEGMENT_TIME_IN_GAME_VIEW TO looker_read;
GRANT SELECT ON prod_games.reporting.ARCADE_ACTIVE_GAME_TIME_IN_GAME_VIEW TO looker_read;
