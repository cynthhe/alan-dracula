//Idle – 1 Visit
//Light – 2 Visits
//Medium – 3-4 Visits
//Heavy – 5+ Visits

//Idle/Light – Not engaged
//Medium – Engaged
//Heavy – Ultra engaged

USE DATABASE tdc_prod_ac;
USE SCHEMA final_adobe;
USE warehouse wh_default;

-- Create UNITY_ADOBE_IDS table
CREATE TABLE unity_adobe_ids AS
SELECT DISTINCT
    a.userid AS unity_id
    ,b.adobe_mcvid AS adobe_id
FROM prod_games.arcade.you_carousel a
JOIN tdc_prod_ac.final_adobe.CARTOON_ADOBE_BDD_MAPP_V b
ON a.adobe_id = b.adobe_mcvid
WHERE b.app_nme LIKE '%playcn_ios%' OR b.app_nme LIKE '%playcn%' OR b.app_nme LIKE '%playcn_android%' OR b.app_nme LIKE '%cnplay_ios%';

-- Create RESEARCH_SEGMENTS view
CREATE OR REPLACE VIEW RESEARCH_SEGMENTS AS
SELECT DISTINCT
    yearmonth
    ,adobe_mcvid
    ,SUM(num_visits) AS total_visits
    ,CASE
        WHEN total_visits BETWEEN 0 AND 2 THEN 'Not engaged'
        WHEN total_visits BETWEEN 3 AND 4 THEN 'Engaged'
        WHEN total_visits >= 5 THEN 'Ultra engaged'
        ELSE 'Others'
        END AS research_segment
FROM (SELECT DISTINCT
        YEAR(date_time)||LPAD(MONTH(date_time),2,'0') AS yearmonth
        ,adobe_mcvid
        ,num_visits
      FROM (SELECT DISTINCT
                date_time
                ,adobe_mcvid
                ,COUNT(adobe_mcvid) AS num_visits
            FROM tdc_prod_ac.final_adobe.CARTOON_ADOBE_BDD_MAPP_V
            WHERE MONTH(date_time) = 7 AND YEAR(date_time) = 2020
            GROUP BY 1,2)
     )
GROUP BY 1,2;

-- Create ARCADE_PERMONTH view
CREATE OR REPLACE VIEW arcade_permonth AS
SELECT DISTINCT
    YEAR(date)||LPAD(MONTH(date),2,'0') AS yearmonth
    ,userid
    ,SUM(duration) AS total_min
FROM arcade_session
GROUP BY 1,2;

-- Create ARCADE_ENGAGEMENT_SEGMENTS_REVISED view
CREATE OR REPLACE VIEW arcade_engagement_segments_revised AS
SELECT 
    yearmonth
    ,userid
    ,total_min
    ,CASE 
        WHEN total_min BETWEEN 0 AND 21 THEN 'Not engaged'
        WHEN total_min BETWEEN 22 AND 81 THEN 'Engaged'
        WHEN total_min > 81 THEN 'Ultra engaged'
        ELSE 'OTHERS'
        END AS segment
FROM arcade_permonth
GROUP BY 1,2,3,4;

-- Create SEGMENT_TEMP view
CREATE OR REPLACE VIEW segment_temp AS
SELECT
    a.yearmonth
    ,b.unity_id
    ,b.adobe_id
    ,a.segment AS prod_segment
    ,a.total_min
    ,c.research_segment
    ,c.total_visits
FROM prod_games.arcade.arcade_engagement_segments_revised a
JOIN prod_games.arcade.unity_adobe_ids b
ON a.userid = b.unity_id
LEFT JOIN prod_games.arcade.research_segments c
ON c.adobe_mcvid = b.adobe_id
WHERE a.yearmonth = 202007;

-- % difference between product and research segments
SELECT
    COUNT(CASE WHEN prod_segment = research_segment THEN 1 ELSE NULL END) AS equal
    ,COUNT(CASE WHEN prod_segment != research_segment THEN 1 ELSE NULL END) AS not_equal
    ,((ABS(equal - not_equal))/((equal + not_equal)/2))*100 AS percent_diff
FROM segment_temp;
