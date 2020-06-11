USE DATABASE prod_games;
USE SCHEMA arcade;
USE WAREHOUSE wh_default;

-- Create capture view
CREATE VIEW capture AS
SELECT DISTINCT 
    acr_capture.userid||acr_capture.sessionid||acr_capture.submit_time AS id,
    userid, 
    sessionid, 
    submit_time,
    ts,
    platform, 
    city, 
    country, 
    appid,
    play_userid,
    episode_name,
    success
FROM acr_capture;

-- Drop capture view
DROP VIEW capture;

-- Create result view
CREATE VIEW result AS
SELECT DISTINCT 
    acr_result.userid||acr_result.sessionid||acr_result.submit_time AS id, 
    success, 
    acr_result.code
FROM acr_result;

-- Drop result view
DROP VIEW result;

-- Get the rate of each code firing | capture and result views joined on ID
SELECT DISTINCT 
    result.code, 
    COUNT(*)
FROM result
JOIN capture ON (result.id = capture.id)
GROUP BY 1
ORDER BY result.code;

-- Regina's Charles log (user id: d98fb8c5475f645df88dc8c2186adae3)
SELECT DISTINCT
    userid, 
    sessionid, 
    ts,
    platform, 
    episode_name,
    capture.success AS capture_success,
    result.success AS result_success,
    code
FROM capture
JOIN result ON (capture.id = result.id)
HAVING userid = 'd98fb8c5475f645df88dc8c2186adae3'
AND DATE(submit_time) = '2020-05-28';
