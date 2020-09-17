USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- Segmenting groups
SELECT DISTINCT 
    CASE 
        WHEN avg_time_per_day_this_month BETWEEN 0 AND 3 THEN 'Not engaged'
        WHEN avg_time_per_day_this_month BETWEEN 4 AND 8 THEN 'Engaged'
        WHEN avg_time_per_day_this_month > 8 THEN 'Ultra engaged'
        ELSE 'OTHERS'
        END AS segment
    ,COUNT(1) AS num_users
    ,CONCAT(ROUND(((num_users / (SELECT COUNT(*) FROM apprunning)) * 100), 2), '%') AS "% of Total"
FROM arcade_perday
GROUP BY segment
ORDER BY num_users DESC;

-- Create ARCADE_PERDAY view
CREATE OR REPLACE VIEW arcade_perday AS
SELECT DISTINCT 
    userid 
    ,sessionid
    ,date
    ,is_new_session
    ,session_index
    ,duration
FROM arcade_session;

-- Create ARCADE_ENGAGEMENT_SEGMENTS view
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

-- Create ARCADE_ACTIVE_GAME view
CREATE OR REPLACE VIEW arcade_active_game AS
SELECT 
    apprunning.submit_time::DATE AS date
    ,apprunning.userid AS userid
    ,game_open.game_name AS active_game
FROM apprunning
JOIN game_open ON (apprunning.userid = game_open.userid) AND (apprunning.submit_time = game_open.submit_time)
AND game_open.submit_time::DATE BETWEEN DATEADD(DAY, -7, apprunning.submit_time::DATE) AND apprunning.submit_time::DATE;
