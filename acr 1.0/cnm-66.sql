USE DATABASE prod_games;
USE SCHEMA arcade;
USE WAREHOUSE wh_default;

-- Create CAPTURE view
CREATE OR REPLACE VIEW capture AS
SELECT DISTINCT 
    acr_capture.userid||acr_capture.sessionid||acr_capture.submit_time AS id
    ,userid
    ,sessionid
    ,ts
    ,submit_time
    ,platform
    ,capture_time
    ,episode_name
    ,play_userloggedin
    ,city
    ,country
    ,success
    ,figure_granted
FROM prod_games.arcade.acr_capture
WHERE userid IN (SELECT userid 
                 FROM prod_games.arcade.apprunning 
                 WHERE country LIKE 'US')
AND userid IN (SELECT userid 
               FROM prod_games.arcade.FIRST_PLAYED_DATE 
               WHERE START_DATE >= '3/4/2019');
              
-- Create RESULT view
CREATE OR REPLACE VIEW result AS
SELECT DISTINCT 
    acr_result.userid||acr_result.sessionid||acr_result.submit_time AS id 
    ,success
    ,acr_result.code
FROM acr_result;

-- Drop result view
DROP VIEW result;

-- Testing result view
SELECT *
FROM result;

-- Create ACR view
CREATE OR REPLACE VIEW ACR AS
SELECT
    userid
    ,sessionid
    ,submit_time
    ,ts
    ,episode_name
    ,figure_granted
    ,play_userloggedin
    ,platform
    ,city
    ,country
    ,CASE 
        WHEN code = 0 OR code IS NULL THEN 'True'
        ELSE 'False'
        END AS success
    ,code
FROM prod_games.arcade.capture
LEFT JOIN prod_games.arcade.result ON (capture.id = result.id)
WHERE NOT (episode_name IS NULL AND code = 0);

-- Get the rate of each code firing | capture and result views joined on ID
SELECT DISTINCT 
    code 
    ,success
    ,COUNT(*)
FROM ACR
GROUP BY 1,2
ORDER BY code;

-- Regina's Charles log (user id: d98fb8c5475f645df88dc8c2186adae3)
SELECT DISTINCT
    userid 
    ,sessionid 
    ,ts
    ,platform
    ,episode_name
    ,success
    ,code
FROM ACR
WHERE userid = 'd98fb8c5475f645df88dc8c2186adae3'
AND DATE(submit_time) = '2020-05-28';
