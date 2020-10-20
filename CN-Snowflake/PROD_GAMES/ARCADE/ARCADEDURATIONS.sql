CREATE OR REPLACE VIEW ARCADEDURATIONS AS
SELECT DISTINCT 
    userid || sessionid || submit_time  AS session_id
    ,MAX(duration) AS time_in_app
FROM apprunning
GROUP BY 1;
