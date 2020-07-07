USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- Creates segment_acr view
CREATE OR REPLACE VIEW segment_acr AS
SELECT
    a.userid
    ,b.segment
    ,sessionid
    ,a.submit_time
    ,ts
    ,platform
    ,city
    ,country
    ,capture_id
    ,capture_time
    ,episode_name
    ,play_userloggedin
    ,figure_granted
    ,success
    ,code
FROM ACR a
JOIN arcade_engagement_segments b ON (a.userid = b.userid) AND ((YEAR(a.submit_time)||LPAD(MONTH(a.submit_time),2,'0')) = b.yearmonth)
WHERE a.country LIKE 'US'
AND a.submit_time >= '3/4/2019';

-- Drops segment_acr view
DROP VIEW segment_acr;

-- Tests segment_acr view
SELECT *
FROM segment_acr;

USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- Create ARCADE_SEGMENT_ACR view for REPORTING schema
CREATE OR REPLACE VIEW ARCADE_SEGMENT_ACR AS 
SELECT
    userid
    ,segment
    ,sessionid
    ,submit_time
    ,ts
    ,platform
    ,city
    ,country
    ,capture_id
    ,capture_time
    ,episode_name
    ,play_userloggedin
    ,figure_granted
    ,success
    ,code
FROM prod_games.arcade.segment_acr;

-- Grant LOOKER_READ role
GRANT SELECT ON prod_games.reporting.arcade_segment_acr TO looker_read;
