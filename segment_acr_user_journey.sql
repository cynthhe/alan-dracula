-- Segment by people who ACR vs. don’t
CREATE OR REPLACE VIEW segment_acr_user_journey AS
WITH cna_journey AS 
(SELECT DISTINCT
    userid
    ,sessionid
    ,ts
 FROM prod_games.arcade.apprunning
 GROUP BY 1,2,3)
,journey_data AS
(SELECT
    userid
    ,sessionid
    ,ts
    ,location
    ,segment
    ,acr_or_not
    ,RANK() OVER (PARTITION BY sessionid ORDER BY ts ASC) AS action_sequence
 FROM (SELECT
        a.userid
        ,a.sessionid
        ,a.ts
        ,a.screen_name AS location
        ,b.segment
        ,CASE WHEN a.sessionid = c.sessionid THEN 'Yes' ELSE 'No' END AS acr_or_not
       FROM prod_games.arcade.screen_visit a -- screen visit, includes shop
       JOIN prod_games.arcade.engagement_segments b
       ON (a.userid = b.userid) AND ((YEAR(a.ts)||LPAD(MONTH(a.ts),2,'0')) = b.yearmonth)
       JOIN prod_games.arcade.acr_table c 
       ON (a.userid = c.userid)
       WHERE a.sessionid IN (SELECT sessionid
                             FROM cna_journey
                             GROUP BY 1)
       GROUP BY 1,2,3,4,5,6
       UNION ALL
       SELECT
        a.userid
        ,a.sessionid
        ,a.ts
        ,CASE WHEN a.game_name LIKE 'Smashy%' THEN 'Smashy Pinata' ELSE a.game_name END AS location
        ,b.segment
        ,CASE WHEN a.sessionid = c.sessionid THEN 'Yes' ELSE 'No' END AS acr_or_not
       FROM prod_games.arcade.game_open a -- game open
       JOIN prod_games.arcade.engagement_segments b
       ON (a.userid = b.userid) AND ((YEAR(a.ts)||LPAD(MONTH(a.ts),2,'0')) = b.yearmonth)
       JOIN prod_games.arcade.acr_table c 
       ON (a.userid = c.userid)
       WHERE a.sessionid IN (SELECT sessionid
                          FROM cna_journey
                          GROUP BY 1)
       GROUP BY 1,2,3,4,5,6
       UNION ALL
       SELECT
        a.userid
        ,a.sessionid
        ,a.ts
        ,CASE WHEN a.game_name LIKE 'Smashy%' THEN 'Smashy Pinata' ELSE a.game_name END AS location
        ,b.segment
        ,CASE WHEN a.sessionid = c.sessionid THEN 'Yes' ELSE 'No' END AS acr_or_not
       FROM prod_games.arcade.game_start a -- game start
       JOIN prod_games.arcade.engagement_segments b
       ON (a.userid = b.userid) AND ((YEAR(a.ts)||LPAD(MONTH(a.ts),2,'0')) = b.yearmonth)
       JOIN prod_games.arcade.acr_table c 
       ON (a.userid = c.userid)
       WHERE a.sessionid IN (SELECT sessionid
                           FROM cna_journey
                           GROUP BY 1)
       GROUP BY 1,2,3,4,5,6
       UNION ALL
       SELECT
        a.userid
        ,a.sessionid
        ,a.ts
        ,'ACR' AS location
        ,b.segment
        ,CASE WHEN a.sessionid = c.sessionid THEN 'Yes' ELSE 'No' END AS acr_or_not
       FROM prod_games.arcade.ACR a -- ACR
       JOIN prod_games.arcade.engagement_segments b
       ON (a.userid = b.userid) AND ((YEAR(a.ts)||LPAD(MONTH(a.ts),2,'0')) = b.yearmonth)
       JOIN prod_games.arcade.acr_table c 
       ON (a.userid = c.userid)
       WHERE a.sessionid IN (SELECT sessionid
                           FROM cna_journey
                           GROUP BY 1)
       GROUP BY 1,2,3,4,5,6
       UNION ALL
       SELECT
        a.userid
        ,a.sessionid
        ,a.ts
        ,a.stunt_name AS location
        ,b.segment
        ,CASE WHEN a.sessionid = c.sessionid THEN 'Yes' ELSE 'No' END AS acr_or_not
       FROM prod_games.arcade.stunt_open a -- stunts
       JOIN prod_games.arcade.engagement_segments b
       ON (a.userid = b.userid) AND ((YEAR(a.ts)||LPAD(MONTH(a.ts),2,'0')) = b.yearmonth)
       JOIN prod_games.arcade.acr_table c 
       ON (a.userid = c.userid)
       WHERE a.sessionid IN (SELECT sessionid
                             FROM cna_journey
                             GROUP BY 1)
       GROUP BY 1,2,3,4,5,6)
 GROUP BY 1,2,3,4,5,6)
,user_journey AS
(SELECT
    ts::DATE as date
    ,userid
    ,LISTAGG(location, ', ') within GROUP (ORDER BY action_sequence,ts ASC) AS journey
    ,segment
    ,acr_or_not
 FROM journey_data
 WHERE action_sequence <= 20
 GROUP BY date,userid,segment,acr_or_not)
 SELECT
    date
    ,journey
    ,segment
    ,acr_or_not
    ,COUNT(DISTINCT userid) AS users
 FROM user_journey
 GROUP BY 1,2,3,4;
 
-- Create SEGMENT_ACR_USER_JOURNEY_TABLE table
CREATE TABLE SEGMENT_ACR_USER_JOURNEY_TABLE AS
SELECT *
FROM segment_acr_user_journey;

-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- Create reporting view: SEGMENT_MONTHJOINED_USER_JOURNEY_VIEW
CREATE OR REPLACE VIEW segment_acr_user_journey_view AS
SELECT *
FROM prod_games.arcade.SEGMENT_ACR_USER_JOURNEY_TABLE;

-- Looker permissions for reporting view
GRANT SELECT ON prod_games.reporting.segment_acr_user_journey_view TO looker_read;
