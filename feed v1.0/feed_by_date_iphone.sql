USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- Create FEED_BY_DATE_IPHONE view
CREATE OR REPLACE VIEW FEED_BY_DATE_IPHONE AS
SELECT
    date
    ,feed_name
    ,feed_scroll
    ,screen_visit_order
    ,COUNT(userid) AS visits
    ,COUNT(DISTINCT userid) AS distinct_visitors
    ,COUNT(DISTINCT sessionid) AS distinct_sessions
    ,COUNT(sessionid) AS sessions
FROM (SELECT
        userid
        ,sessionid
        ,ts::DATE AS date
        ,RANK() OVER (PARTITION BY sessionid ORDER BY ts ASC) AS screen_visit_order
        ,feed_name
        ,feed_scroll
      FROM (SELECT 
                userid
                ,sessionid
                ,ts      
                ,feed_name
                ,feed_scroll 
            FROM prod_games.arcade.feed 
            WHERE platform LIKE 'iPhonePlayer' AND userid IN (SELECT userid 
                                                              FROM prod_games.arcade.first_played_date 
                                                              WHERE START_DATE >= '3/4/2019') 
            GROUP BY 1,2,3,4,5)) 
GROUP BY 1,2,3,4;

-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- Create reporting view: FEED_BY_DATE_IPHONE
CREATE OR REPLACE VIEW FEED_BY_DATE_IPHONE AS
SELECT *
FROM prod_games.arcade.FEED_BY_DATE_IPHONE;

-- Looker permissions for reporting view
GRANT SELECT ON prod_games.reporting.FEED_BY_DATE_IPHONE TO looker_read;
