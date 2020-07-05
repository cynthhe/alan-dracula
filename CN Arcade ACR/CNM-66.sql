USE DATABASE prod_games;
USE SCHEMA arcade;
USE WAREHOUSE wh_default;

-- Create capture view
CREATE OR REPLACE VIEW capture AS
SELECT DISTINCT 
    acr_capture.userid||acr_capture.sessionid||acr_capture.submit_time AS id
    ,userid
    ,sessionid
    ,submit_time
    ,ts
    ,platform
    ,city
    ,country
    ,type
    ,appid
    ,debug_device
    ,sdk
    ,user_agent
    ,custom_params
    ,original_filename
    ,capture_id
    ,capture_time
    ,episode_name
    ,play_userloggedin
    ,success
    ,figure_granted
FROM acr_capture;

-- Drop capture view
DROP VIEW capture;

-- Testing capture view
SELECT *
FROM capture;

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
    code, 
    success,
    COUNT(*)
FROM ACR
GROUP BY 1,2
ORDER BY code;

-- Create ACR view
CREATE VIEW ACR AS
SELECT DISTINCT
    userid, 
    sessionid, 
    submit_time,
    ts,
    platform, 
    city, 
    country, 
    appid,
    debug_device,
    user_agent,
    play_userid,
    play_userloggedin,
    episode_name,
    CASE 
        WHEN code = 0 OR code IS NULL THEN 'True'
        ELSE 'False'
        END AS success,
    code
FROM capture
LEFT JOIN result ON (capture.id = result.id)
WHERE NOT (episode_name IS NULL AND code = 0);

-- Drop ACR view
DROP VIEW ACR;

-- Testing ACR view
SELECT *
FROM ACR;

SELECT *
FROM ACR
WHERE episode_name IS NULL;

SELECT *
FROM ACR
WHERE code IS NULL;

SELECT *
FROM ACR
WHERE (episode_name IS NOT NULL AND code != 0);

SELECT *
FROM ACR
WHERE result_success = 'True';

-- Regina's Charles log (user id: d98fb8c5475f645df88dc8c2186adae3)
SELECT DISTINCT
    userid, 
    sessionid, 
    ts,
    platform, 
    episode_name,
    success,
    code
FROM ACR
WHERE userid = 'd98fb8c5475f645df88dc8c2186adae3'
AND DATE(submit_time) = '2020-05-28';
