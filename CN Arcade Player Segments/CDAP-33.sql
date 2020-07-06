USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- If a session is quiet for more than 20 minutes, add something to the session ID to make it a new session
CREATE OR REPLACE VIEW arcadesessions AS
WITH session_run AS (
  SELECT * 
  FROM apprunning
),
lag_events AS ( -- Events occurring on the same day and with the same user ID
  SELECT
    userid
    ,sessionid
    ,submit_time
    ,LAG(submit_time) OVER (PARTITION BY DATE(submit_time), userid ORDER BY submit_time) AS PREV -- Partition date and user ID
  FROM session_run
),
new_sessions AS ( -- Determines whether start of a new session
  SELECT
    userid
    ,sessionid
    ,submit_time
    ,CASE -- Compares current event time with the previous event time for that user
    WHEN PREV IS NULL THEN 1 -- New session (first event by that user on that day)
    WHEN timediff(minute, submit_time, PREV) < -20 THEN 1 -- New session (if more than 20 minutes has elapsed)
    ELSE 0 -- Not a new session
    END AS is_new_session -- Creates new column 'is_new_session'
  FROM lag_events
),
session_index AS ( -- Incrementing each time a new session is found for a given user
  SELECT
    userid
    ,sessionid
    ,submit_time
    ,is_new_session
    ,SUM(is_new_session) OVER (PARTITION BY userid ORDER BY submit_time ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS session_index -- # of sessions for given user
  FROM new_sessions
)
SELECT
    DISTINCT userid || sessionid || submit_time  AS session_id -- Creates new session ID (concat user ID + submit time)
    ,userid
    ,sessionid
    ,submit_time
    ,is_new_session
    ,session_index
FROM session_index
ORDER BY userid, sessionid, submit_time;

-- Drop arcadesessions view
DROP VIEW arcadesessions;

-- Testing arcadesessions view
SELECT *
FROM arcadesessions;

-- Create arcadedurations view
CREATE OR REPLACE VIEW arcadedurations AS
SELECT 
    DISTINCT userid || sessionid || submit_time  AS session_id
    ,MAX(duration) AS time_in_app
FROM apprunning
GROUP BY 1;

-- Drop arcadedurations view
DROP VIEW arcadedurations;

-- Testing arcadedurations view
SELECT *
FROM arcadedurations;

-- Create arcade_session view (arcadesessions and arcadedurations joined)
CREATE OR REPLACE VIEW arcade_session AS
SELECT 
    userid
    ,sessionid
    ,submit_time::DATE AS date
    ,is_new_session
    ,session_index
    ,ROUND(time_in_app / 60) AS duration
FROM arcadesessions
JOIN arcadedurations ON (arcadesessions.session_id = arcadedurations.session_id);

-- Drop arcade_session view
DROP VIEW arcade_session;

-- Testing arcade_session view
SELECT *
FROM arcade_session;

-- Time in app per session
SELECT DISTINCT 
    userid
    ,sessionid
    ,date
    ,duration
FROM arcade_session
GROUP BY 1,2,3,4
HAVING duration BETWEEN 1 AND 20 -- users who have played b/w 1-20 min
ORDER BY RANDOM() LIMIT 20000; -- get simple random sample of 1000

-- Time in app per session (COVID)
SELECT DISTINCT 
    userid
    ,sessionid
    ,submit_time::DATE AS date
    ,ROUND(MAX(duration) / 60) AS time_in_app
FROM apprunning
GROUP BY 1,2,3
HAVING time_in_app BETWEEN 1 AND 20 AND date > '2020-02-29' -- Users who have played b/w 1-20 min + starting from 3/1/20
ORDER BY RANDOM() LIMIT 1000; -- Get simple random sample of 1000

-- Average time in app per day
SELECT 
    userid 
    ,submit_time::DATE AS date
    ,ROUND(AVG(duration / 60)) AS time_in_app
FROM apprunning
GROUP BY 1,2
HAVING time_in_app BETWEEN 1 AND 20 -- Users who have played an avg b/w 1-20 min
ORDER BY RANDOM() LIMIT 1000; -- Get simple random sample of 1000

-- Average time in app per day (COVID)
SELECT 
    userid
    ,submit_time::DATE AS date
    ,ROUND(AVG(duration / 60)) AS time_in_app
FROM apprunning
GROUP BY 1,2
HAVING time_in_app BETWEEN 1 AND 20 AND date > '2020-02-29'; -- Users who have played an avg b/w 1-20 min + starting from 3/1/20
ORDER BY RANDOM() LIMIT 1000; -- Get simple random sample of 1000
