USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- Create ARCADE_SEGMENT_WOW view
CREATE OR REPLACE VIEW ARCADE_SEGMENT_WOW AS
SELECT
    week
    ,segment
    ,week0
    ,week1
    ,week1/week0 AS wow_retention
FROM (SELECT
        YEAR(a.submit_time) AS year
        ,WEEK(a.submit_time) AS week
        ,c.segment
        ,COUNT(DISTINCT a.userid) as week0
        ,COUNT(DISTINCT b.userid) as week1
      FROM prod_games.arcade.apprunning a
      LEFT JOIN prod_games.arcade.apprunning b ON WEEK(b.submit_time) = WEEK(a.submit_time)+1 AND (a.userid = b.userid)
      JOIN prod_games.arcade.arcade_engagement_segments c ON (a.userid = c.userid) AND ((YEAR(a.submit_time)||LPAD(MONTH(a.submit_time),2,'0')) = c.yearmonth)
      WHERE YEAR(a.submit_time) = '2020' AND WEEK(a.submit_time) < WEEK(CURRENT_TIMESTAMP)+1
      AND a.userid IN (SELECT userid 
                       FROM prod_games.arcade.FIRST_PLAYED_DATE 
                       WHERE START_DATE >= '3/4/2019')
      AND a.country LIKE 'US'
      GROUP BY 1,2,3)
ORDER BY week ASC;

-- Update the ARCADE_SEGMENT_WOW_TABLE
TRUNCATE TABLE ARCADE_SEGMENT_WOW_TABLE;
INSERT INTO ARCADE_SEGMENT_WOW_TABLE 
SELECT *
FROM ARCADE_SEGMENT_WOW;

-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- Creates reporting view: ARCADE_SEGMENT_WOW_VIEW
CREATE OR REPLACE VIEW ARCADE_SEGMENT_WOW_VIEW AS
SELECT *
FROM prod_games.arcade.ARCADE_SEGMENT_WOW_TABLE;

-- Looker permissions for reporting views
GRANT SELECT ON prod_games.reporting.ARCADE_SEGMENT_WOW_VIEW TO looker_read;
