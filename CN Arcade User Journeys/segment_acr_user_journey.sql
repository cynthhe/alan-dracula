USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- Create SEGMENT_ACR_USER_JOURNEY view
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
        ,CASE WHEN a.userid = c.userid THEN 'Yes' ELSE 'No' END AS acr_or_not
       FROM prod_games.arcade.screen_visit a -- screen visit
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
        ,CASE WHEN a.userid = c.userid THEN 'Yes' ELSE 'No' END AS acr_or_not
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
        ,a.stunt_name AS location
        ,b.segment
        ,CASE WHEN a.userid = c.userid THEN 'Yes' ELSE 'No' END AS acr_or_not
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
    a.ts::DATE AS date
    ,a.userid
    ,LISTAGG(location, ', ') within GROUP (ORDER BY action_sequence,a.ts ASC) AS journey
    ,segment
    ,acr_or_not
 FROM journey_data a
 WHERE action_sequence <= 20
 GROUP BY date,a.userid,segment,acr_or_not)
 SELECT
    date
    ,journey
    ,segment
    ,acr_or_not
    ,COUNT(DISTINCT userid) AS users
 FROM user_journey
 GROUP BY 1,2,3,4;
 
DROP VIEW segment_acr_user_journey;
 
-- Update SEGMENT_ACR_USER_JOURNEY_TABLE table
TRUNCATE TABLE SEGMENT_ACR_USER_JOURNEY_TABLE;
INSERT INTO SEGMENT_ACR_USER_JOURNEY_TABLE 
SELECT *
FROM segment_acr_user_journey;

DROP TABLE SEGMENT_ACR_USER_JOURNEY_TABLE;

-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- Create reporting view: SEGMENT_ACR_USER_JOURNEY_VIEW
CREATE OR REPLACE VIEW segment_acr_user_journey_view AS
SELECT *
FROM prod_games.arcade.SEGMENT_ACR_USER_JOURNEY_TABLE;

DROP VIEW segment_acr_user_journey_view;

-- Looker permissions for reporting view
GRANT SELECT ON prod_games.reporting.segment_acr_user_journey_view TO looker_read;
