USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- Create ARCADE_ADS view
CREATE OR REPLACE VIEW ARCADE_ADS AS
SELECT 
    a.submit_time::DATE AS date
    ,a.userid
    ,CASE WHEN a.app_location LIKE 'Smashy%' THEN 'Smashy Pinata' ELSE a.app_location END AS app_location
    ,a.AD_PROVIDER
    ,b.sessions
    ,b.players
    ,DATEDIFF(second,OFFERED_DATETIME,FINISHED_DATETIME) AS interaction_time
    ,a.platform
    ,COUNT(DISTINCT a.sessionid) AS sessions_per_player
    ,SUM(CASE WHEN a.ad_offered LIKE 'True' THEN 1 ELSE 0 END) AS ad_offered
FROM prod_games.arcade.ad a
LEFT JOIN (SELECT 
            submit_time::DATE AS date
            ,platform
            ,COUNT(DISTINCT userid) AS players
            ,COUNT(DISTINCT sessionid) AS sessions 
           FROM prod_games.arcade.apprunning 
           WHERE country LIKE 'US' AND userid IN (SELECT userid 
                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                  WHERE START_DATE >= '3/4/2019') 
           GROUP BY 1,2) b ON b.date = a.submit_time::DATE AND b.platform = a.platform
WHERE a.country LIKE 'US' AND a.ad_offered LIKE 'True'
AND userid IN (SELECT userid 
               FROM prod_games.arcade.FIRST_PLAYED_DATE 
               WHERE START_DATE >= '3/4/2019')
GROUP BY 1,2,3,4,5,6,7,8;

-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- Create reporting view: ARCADE_ADS
CREATE OR REPLACE VIEW ARCADE_ADS AS
SELECT *
FROM prod_games.arcade.arcade_ads;

-- Looker permissions for reporting view
GRANT SELECT ON prod_games.reporting.ARCADE_ADS TO looker_read;
