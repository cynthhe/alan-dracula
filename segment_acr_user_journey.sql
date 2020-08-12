-- Segment by people who ACR vs. don’t
CREATE VIEW segment_acr_user_journey AS
WITH cna_journey AS 
(SELECT DISTINCT
    a.userid
    ,a.sessionid
    ,a.ts
    ,CASE WHEN a.sessionid = b.sessionid THEN 'Yes' ELSE 'No' END AS acr_or_not
 FROM prod_games.arcade.apprunning a
 JOIN prod_games.arcade.acr_table b ON (a.userid = b.userid)
 GROUP BY 1,2,3,4)
,journey_data AS
(SELECT
    userid
    ,sessionid
    ,ts
    ,location
    ,segment
    ,RANK() OVER (PARTITION BY sessionid ORDER BY ts ASC) AS action_sequence
 FROM (SELECT
        a.userid
        ,a.sessionid
        ,a.ts
        ,a.screen_name AS location
        ,b.segment
       FROM prod_games.arcade.screen_visit a -- screen visit, includes shop
       JOIN prod_games.arcade.engagement_segments b
       ON (a.userid = b.userid) AND ((YEAR(a.ts)||LPAD(MONTH(a.ts),2,'0')) = b.yearmonth)
       WHERE a.sessionid IN (SELECT sessionid
                             FROM cna_journey
                             GROUP BY 1)
       GROUP BY 1,2,3,4,5
       UNION ALL
       SELECT
        a.userid
        ,a.sessionid
        ,a.ts
        ,CASE WHEN a.game_name LIKE 'Smashy%' THEN 'Smashy Pinata' ELSE a.game_name END AS location
        ,b.segment
       FROM prod_games.arcade.game_open a -- game open
       JOIN prod_games.arcade.engagement_segments b
       ON (a.userid = b.userid) AND ((YEAR(a.ts)||LPAD(MONTH(a.ts),2,'0')) = b.yearmonth)
       WHERE a.sessionid IN (SELECT sessionid
                          FROM cna_journey
                          GROUP BY 1)
       GROUP BY 1,2,3,4,5
       UNION ALL
       SELECT
        a.userid
        ,a.sessionid
        ,a.ts
        ,CASE WHEN a.game_name LIKE 'Smashy%' THEN 'Smashy Pinata' ELSE a.game_name END AS location
        ,b.segment
       FROM prod_games.arcade.game_start a -- game start
       JOIN prod_games.arcade.engagement_segments b
       ON (a.userid = b.userid) AND ((YEAR(a.ts)||LPAD(MONTH(a.ts),2,'0')) = b.yearmonth)
       WHERE a.sessionid IN (SELECT sessionid
                           FROM cna_journey
                           GROUP BY 1)
       GROUP BY 1,2,3,4,5
       UNION ALL
       SELECT
        a.userid
        ,a.sessionid
        ,a.ts
        ,'ACR' AS location
        ,b.segment
       FROM prod_games.arcade.ACR a -- ACR
       JOIN prod_games.arcade.engagement_segments b
       ON (a.userid = b.userid) AND ((YEAR(a.ts)||LPAD(MONTH(a.ts),2,'0')) = b.yearmonth)
       WHERE a.sessionid IN (SELECT sessionid
                           FROM cna_journey
                           GROUP BY 1)
       GROUP BY 1,2,3,4,5
       UNION ALL
       SELECT
        a.userid
        ,a.sessionid
        ,a.ts
        ,a.stunt_name AS location
        ,b.segment
       FROM prod_games.arcade.stunt_open a -- stunts
       JOIN prod_games.arcade.engagement_segments b
       ON (a.userid = b.userid) AND ((YEAR(a.ts)||LPAD(MONTH(a.ts),2,'0')) = b.yearmonth)
       WHERE a.sessionid IN (SELECT sessionid
                             FROM cna_journey
                             GROUP BY 1)
       GROUP BY 1,2,3,4,5)
 GROUP BY 1,2,3,4,5)
 SELECT
    action_sequence
    ,location
    ,segment
    ,COUNT(DISTINCT a.userid) AS users
FROM journey_data a
JOIN cna_journey b ON (a.userid = b.userid)
GROUP BY 1,2,3
HAVING users >= 50
ORDER BY action_sequence ASC;

-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- Create reporting view: SEGMENT_MONTHJOINED_USER_JOURNEY_VIEW
CREATE OR REPLACE VIEW segment_monthjoined_user_journey_view AS
SELECT *
FROM prod_games.arcade.segment_monthjoined_user_journey;

-- Looker permissions for reporting view
GRANT SELECT ON prod_games.reporting.segment_monthjoined_user_journey_view TO looker_read;
