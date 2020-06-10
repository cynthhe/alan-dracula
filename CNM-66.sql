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
    platform, 
    city, 
    country, 
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

-- Regina's Charles log (user id: db775dd8-99a8-4de9-973a-da0a2c3adb20)
SELECT *
FROM capture
JOIN result ON (capture.id = result.id)
HAVING userid = 'db775dd899a84de9973ada0a2c3adb20';
