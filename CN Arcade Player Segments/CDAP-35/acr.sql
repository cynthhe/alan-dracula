USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- Create SEGMENT_ACR view
CREATE OR REPLACE VIEW segment_acr AS
SELECT
    a.userid
    ,a.submit_time
    ,b.segment
    ,episode_name
    ,figure_granted
    ,play_userloggedin
    ,platform
    ,success
    ,code
FROM prod_games.arcade.ACR a
JOIN prod_games.arcade.arcade_engagement_segments b ON (a.userid = b.userid) AND ((YEAR(a.submit_time)||LPAD(MONTH(a.submit_time),2,'0')) = b.yearmonth)
WHERE a.country LIKE 'US'
AND a.submit_time >= '3/4/2019';

-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- Create reporting view: ARCADE_SEGMENT_ACR_VIEW
CREATE OR REPLACE VIEW ARCADE_SEGMENT_ACR_VIEW AS
SELECT *
FROM prod_games.reporting.ARCADE_SEGMENT_ACR;

-- Looker permissions for reporting view
GRANT SELECT ON prod_games.reporting.ARCADE_SEGMENT_ACR_VIEW TO looker_read;
