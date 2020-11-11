USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- Create FIGURES_PER_PLAYER_US view
CREATE OR REPLACE VIEW FIGURES_PER_PLAYER_US AS
SELECT
    total_figures_owned
    ,distinct_figures_owned
    ,COUNT(DISTINCT userid) AS users
FROM (SELECT
        a.userid
        ,COUNT(a.figureid) AS total_figures_owned
        ,COUNT(DISTINCT a.figureid) AS distinct_figures_owned
      FROM (SELECT 
                userid
                ,figureid 
            FROM prod_games.arcade.GDB_GOTREWARD 
            GROUP BY 1,2) a
      JOIN prod_games.arcade.SCREEN_VISIT b ON b.PLAY_USERID = a.userid
      WHERE b.country LIKE 'US' AND b.userid IN (SELECT userid 
                                                 FROM prod_games.arcade."FIRST_PLAYED_DATE" 
                                                 WHERE START_DATE >= '3/4/2019')
      AND b.screen_name LIKE '%reward%'
      GROUP BY 1)
GROUP BY 1,2;

-- Create FIGURES_PER_PLAYER_US table
CREATE TABLE FIGURES_PER_PLAYER_US_TABLE AS
SELECT *
FROM FIGURES_PER_PLAYER_US;
 
-- Update FIGURES_PER_PLAYER_US table
TRUNCATE TABLE FIGURES_PER_PLAYER_US_TABLE;
INSERT INTO FIGURES_PER_PLAYER_US_TABLE 
SELECT *
FROM FIGURES_PER_PLAYER_US;

-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- Create reporting view: SEGMENT_USER_JOURNEY_VIEW
CREATE OR REPLACE VIEW FIGURES_PER_PLAYER_US AS
SELECT *
FROM prod_games.arcade.FIGURES_PER_PLAYER_US_TABLE;

-- Looker permissions for reporting view
GRANT SELECT ON prod_games.reporting.FIGURES_PER_PLAYER_US TO looker_read;
