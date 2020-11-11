USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- Create SEGMENT_FIGURE_SHOP view
CREATE OR REPLACE VIEW segment_figure_shop AS
SELECT
    a.userid
    ,sessionid
    ,a.submit_time
    ,ts
    ,platform
    ,city
    ,country
    ,b.segment
    ,purchased_item_name
    ,purchased_item_price
FROM prod_games.arcade.purchase a
JOIN prod_games.arcade.arcade_engagement_segments b ON (a.userid = b.userid) AND ((YEAR(a.submit_time)||LPAD(MONTH(a.submit_time),2,'0')) = b.yearmonth)
WHERE a.country LIKE 'US'
AND a.submit_time >= '3/4/2019';

-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- Create reporting view: ARCADE_SEGMENT_FIGURE_SHOP_VIEW
CREATE OR REPLACE VIEW ARCADE_SEGMENT_FIGURE_SHOP_VIEW AS
SELECT *
FROM prod_games.arcade.ARCADE_SEGMENT_FIGURE_SHOP;

-- Looker permissions for reporting view
GRANT SELECT ON prod_games.reporting.ARCADE_SEGMENT_FIGURE_SHOP_VIEW TO looker_read;
