USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

//CREATE OR REPLACE VIEW app_version_onboarding AS
//SELECT
//    userid
//    ,sessionid
//    ,app_version
//FROM prod_games.arcade.app_version
//WHERE app_version LIKE '%1.3.3556%' OR app_version LIKE '%1.3.3568%' OR app_version LIKE '%1.3.3569%'
//OR app_version LIKE '%1.3.3570%' OR app_version LIKE '%1.3.37%' OR app_version LIKE '%1.3.38%' OR app_version LIKE '%1.3.4%' OR app_version LIKE '%2.%'
//AND app_version NOT LIKE '%ACC%' OR app_version NOT LIKE '%TEST%' OR app_version NOT LIKE '%DEBUG%';

-- Create SEGMENT_FIRSTPLAYER_USER_JOURNEY view
CREATE OR REPLACE VIEW segment_firstplayer_user_journey AS
WITH cna_journey AS 
(SELECT
    userid
    ,MIN(sessionid) AS sessionid
    ,MIN(ts) AS ts
 FROM prod_games.arcade.apprunning
 GROUP BY 1)
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
       FROM prod_games.arcade.screen_visit a -- screen visit
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
,user_journey AS
(SELECT
    ts::DATE AS date
    ,userid
    ,LISTAGG(location, ', ') within GROUP (ORDER BY action_sequence,ts ASC) AS journey
    ,segment
 FROM journey_data
 WHERE action_sequence <= 20
 GROUP BY date,userid,segment)
 SELECT
    date
    ,journey
    ,segment
    ,COUNT(DISTINCT userid) AS users
 FROM user_journey
 WHERE journey LIKE '%Onboarding Video Stunt, /home%' OR journey LIKE '%/home, Onboarding Video Stunt%'
 GROUP BY 1,2,3;
 
-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- Create reporting view: SEGMENT_FIRSTPLAYER_USER_JOURNEY_VIEW
CREATE OR REPLACE VIEW segment_firstplayer_user_journey_view AS
SELECT *
FROM prod_games.arcade.segment_firstplayer_user_journey;

-- Looker permissions for reporting view
GRANT SELECT ON prod_games.reporting.segment_firstplayer_user_journey_view TO looker_read;
