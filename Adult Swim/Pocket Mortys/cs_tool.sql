USE DATABASE prod_games;
USE SCHEMA pocket_mortys;
USE warehouse wh_default;

-- Create POCKET_MORTYS_DURATION view
CREATE OR REPLACE VIEW pocket_mortys_duration AS
SELECT
    session_id
    ,MIN(event_time) AS start_time
    ,MAX(event_time) AS end_time
    ,DATEDIFF(minute, start_time, end_time) AS total_min_in_game
FROM prod_games.pocket_mortys.pocket_mortys_events
WHERE event_time::DATE >= '8/17/2020'
GROUP BY 1;

-- Create POCKET_MORTYS_STAGING view
CREATE OR REPLACE VIEW pocket_mortys_staging AS
SELECT
    client_user_id
    ,device_id
    ,session_id
    ,country
    ,event_time
FROM prod_games.pocket_mortys.pocket_mortys_events
WHERE client_user_id IS NOT NULL
AND event_time::DATE >= '8/17/2020';

-- Create POCKET_MORTYS_CS_TOOL table
CREATE TABLE pocket_mortys_cs_tool AS
SELECT
    b.client_user_id
    ,b.country
    ,c.total_min_in_game
    ,COUNT(DISTINCT b.session_id) AS total_sessions
    ,MIN(b.event_time::DATE) AS first_play_date
    ,IFNULL(SUM(a.revenue), 0) AS total_revenue
FROM prod_games.pocket_mortys.pocket_mortys_sessions_purchases a
JOIN prod_games.pocket_mortys.pocket_mortys_staging b
ON a.device_id = b.device_id
JOIN pocket_mortys_duration c
ON b.session_id = c.session_id
GROUP BY 1,2,3;

-- PM_REPORTING_PROD schema
USE DATABASE prod_games;
USE SCHEMA pm_reporting_prod;
USE warehouse wh_default;

-- Create reporting view: POCKET_MORTYS_CS_TOOL
CREATE OR REPLACE VIEW pocket_mortys_cs_tool AS
SELECT *
FROM prod_games.pocket_mortys.pocket_mortys_cs_tool;
