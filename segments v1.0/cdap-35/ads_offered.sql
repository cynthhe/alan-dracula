USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- Create SEGMENT_ADS_OFFERED view
CREATE OR REPLACE VIEW segment_ads_offered AS
SELECT
    a.submit_time::DATE AS date
    ,a.userid
    ,CASE WHEN a.app_location LIKE 'Smashy%' THEN 'Smashy Pinata' ELSE a.app_location END AS app_location
    ,c.segment
    ,a.AD_PROVIDER
    ,b.sessions
    ,b.players
    ,DATEDIFF(second,OFFERED_DATETIME,FINISHED_DATETIME) AS interaction_time
    ,a.platform
    ,COUNT(DISTINCT a.sessionid) AS sessions_per_player
    ,SUM(CASE WHEN a.ad_offered LIKE 'True' THEN 1 ELSE 0 END) AS ad_offered
FROM prod_games.arcade.ad a
LEFT JOIN (SELECT 
            submit_time::DATE as date
            ,platform
            ,COUNT(DISTINCT a.userid) AS players
            ,COUNT(DISTINCT sessionid) AS sessions 
           FROM prod_games.arcade.apprunning a 
           WHERE country LIKE 'US' AND a.userid IN (SELECT userid 
                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                  WHERE START_DATE >= '3/4/2019') 
           GROUP BY 1,2) b ON (b.date = a.submit_time::DATE) AND (b.platform = a.platform)
JOIN prod_games.arcade.arcade_engagement_segments c ON (a.userid = c.userid) AND ((YEAR(a.submit_time)||LPAD(MONTH(a.submit_time),2,'0')) = c.yearmonth)
WHERE a.country LIKE 'US' AND a.ad_offered LIKE 'True'
AND a.userid IN (SELECT userid 
               FROM prod_games.arcade.FIRST_PLAYED_DATE 
               WHERE START_DATE >= '3/4/2019')
GROUP BY 1,2,3,4,5,6,7,8,9;

-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- Create reporting view: ARCADE_SEGMENT_ADS_OFFERED_VIEW
CREATE OR REPLACE VIEW ARCADE_SEGMENT_ADS_OFFERED_VIEW AS
SELECT *
FROM ARCADE_SEGMENT_ADS_OFFERED;

-- Looker permissions for reporting view
GRANT SELECT ON prod_games.reporting.ARCADE_SEGMENT_ADS_OFFERED_VIEW TO looker_read;
