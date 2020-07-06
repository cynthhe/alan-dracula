USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- Segmenting groups
SELECT DISTINCT 
    CASE
        WHEN duration BETWEEN 0 AND 4 THEN 'Not engaged'
        WHEN duration BETWEEN 4 AND 8 THEN 'Engaged'
        WHEN duration >= 8 THEN 'Ultra engaged'
        ELSE 'OTHERS'
        END AS segment
    ,COUNT(1) AS num_users
    ,CONCAT(ROUND(((num_users / (SELECT COUNT(*) FROM apprunning)) * 100), 2), '%') AS "% of Total"
FROM arcade_perday
GROUP BY segment
ORDER BY num_users DESC;

-- Creates arcade_perday view
CREATE OR REPLACE VIEW arcade_perday AS
SELECT DISTINCT 
    userid 
    ,sessionid
    ,date
    ,is_new_session
    ,session_index
    ,duration
FROM arcade_session;

-- Drop arcade_perday view
DROP VIEW arcade_perday;

-- Testing arcade_perday view
SELECT *
FROM arcade_perday;

-- Creates arcade_engagement_segments view
CREATE OR REPLACE VIEW arcade_engagement_segments AS
SELECT 
    YEAR(date)||LPAD(MONTH(date),2,'0') as yearmonth
    ,userid
    ,ROUND(AVG(duration)) AS avg_time_per_day_this_month
    ,CASE 
        WHEN avg_time_per_day_this_month BETWEEN 0 AND 3 THEN 'Not engaged'
        WHEN avg_time_per_day_this_month BETWEEN 4 AND 8 THEN 'Engaged'
        WHEN avg_time_per_day_this_month > 8 THEN 'Ultra engaged'
        ELSE 'OTHERS'
        END AS segment
FROM arcade_perday
GROUP BY 1,2;

-- Drops arcade_engagement_segments view
DROP VIEW arcade_engagement_segments;

-- Testing arcade_engagement_segments view
SELECT *
FROM arcade_engagement_segments;

SELECT MIN(date)
FROM arcade_perday;

SELECT *
FROM arcade_engagement_segments
WHERE userid = '8c9fa5100fa414d3bab22d66c5411bf8';

SELECT *
FROM arcade_perday
WHERE userid = '8c9fa5100fa414d3bab22d66c5411bf8';

-- Creates arcade_active_game view
CREATE OR REPLACE VIEW arcade_active_game AS
SELECT 
    apprunning.submit_time::DATE AS date
    ,apprunning.userid AS userid
    ,game_open.game_name AS active_game
FROM apprunning
JOIN game_open ON (apprunning.userid = game_open.userid) AND (apprunning.submit_time = game_open.submit_time)
AND game_open.submit_time::DATE BETWEEN DATEADD(DAY, -7, apprunning.submit_time::DATE) AND apprunning.submit_time::DATE;

-- Drop arcade_active_game view
DROP VIEW arcade_active_game;

-- Testing arcade_active_game view
SELECT *
FROM arcade_active_game;

SELECT 
    MIN(date)
    ,MAX(date)
FROM arcade_active_game;
