USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- Create ARCADE_ACR_CAPTURE view
CREATE OR REPLACE VIEW ARCADE_ACR_CAPTURE AS
SELECT
    a.submit_time::date AS date
    ,a.episode_name
    ,b.show_name
    ,a.success
    ,a.figure_granted
    ,a.play_userloggedin
    ,a.platform
    ,COUNT(DISTINCT a.userid) AS users
    ,COUNT(DISTINCT a.sessionid) AS sessions
    ,COUNT(a.userid) AS times_captured
FROM prod_games.arcade.acr_table a
LEFT JOIN prod_games.arcade.episode_show_name b on b.episode_name = a.episode_name
WHERE a.userid IN (SELECT userid 
                   FROM prod_games.arcade.apprunning 
                   WHERE country LIKE 'US')
AND a.userid IN (SELECT userid 
                 FROM prod_games.arcade.FIRST_PLAYED_DATE 
                 WHERE START_DATE >= '3/4/2019')
GROUP BY 1,2,3,4,5,6,7;

-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- Create reporting view: ARCADE_ACR_CAPTURE
CREATE OR REPLACE VIEW ARCADE_ACR_CAPTURE AS
SELECT *
FROM prod_games.arcade.ARCADE_ACR_CAPTURE;

-- Looker permissions for reporting view
GRANT SELECT ON prod_games.reporting.ARCADE_ACR_CAPTURE TO looker_read;
