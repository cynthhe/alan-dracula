CREATE OR REPLACE VIEW ARCADESESSIONS AS
WITH session_run AS (
  SELECT * 
  FROM apprunning
)
,lag_events AS ( -- events occurring on the same day and with the same user id
  SELECT
    userid
    ,sessionid
    ,submit_time
    ,LAG(submit_time) OVER (PARTITION BY DATE(submit_time), userid ORDER BY submit_time) AS PREV -- partition date and user id
  FROM session_run
)
,new_sessions AS ( -- determines whether start of a new session
  SELECT
    userid
    ,sessionid
    ,submit_time
    ,CASE -- compares current event time with the previous event time for that user
        WHEN PREV IS null THEN 1 -- new session (first event by that user on that day)
        WHEN TIMEDIFF(minute, submit_time, PREV) < -20 THEN 1 -- new session (if more than 20 minutes has elapsed)
        ELSE 0 -- not a new session
        END AS is_new_session -- creates new column 'is_new_session'
  FROM lag_events
)
,session_index AS ( -- incrementing each time a new session is found for a given user
  SELECT
    userid
    ,sessionid
    ,submit_time
    ,is_new_session
    ,SUM(is_new_session) OVER (PARTITION BY userid ORDER BY submit_time ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS session_index -- # of sessions for given user
  FROM new_sessions
)
SELECT DISTINCT 
    userid || sessionid || submit_time AS session_id -- creates new session id (concat user id + submit time)
    ,userid
    ,sessionid
    ,submit_time
    ,is_new_session
    ,session_index
FROM session_index
ORDER BY userid,sessionid,submit_time;
