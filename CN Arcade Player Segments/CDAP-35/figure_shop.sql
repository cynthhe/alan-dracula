USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- Creates segment_figure_shop view
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

-- Creates ARCADE_SEGMENT_FIGURE_SHOP table
CREATE TABLE ARCADE_SEGMENT_FIGURE_SHOP AS
SELECT *
FROM prod_games.arcade.segment_figure_shop;

-- Creates active_game_figure_shop view
CREATE OR REPLACE VIEW active_game_figure_shop AS
SELECT
    a.userid
    ,sessionid
    ,a.submit_time
    ,ts
    ,platform
    ,city
    ,country
    ,CASE WHEN b.active_game LIKE 'Smashy%' THEN 'Smashy Pinata' ELSE b.active_game END AS active_game
    ,purchased_item_name
    ,purchased_item_price
FROM prod_games.arcade.purchase a
JOIN prod_games.arcade.arcade_active_game b ON (a.userid = b.userid) AND (a.submit_time::DATE = b.date)
WHERE a.country LIKE 'US'
AND a.submit_time >= '3/4/2019';

-- Creates ARCADE_ACTIVE_GAME_FIGURE_SHOP table
CREATE TABLE ARCADE_ACTIVE_GAME_FIGURE_SHOP AS
SELECT *
FROM prod_games.arcade.active_game_figure_shop;

-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- Creates reporting view: ARCADE_SEGMENT_FIGURE_SHOP_VIEW
CREATE OR REPLACE VIEW ARCADE_SEGMENT_FIGURE_SHOP_VIEW AS
SELECT *
FROM prod_games.arcade.ARCADE_SEGMENT_FIGURE_SHOP;

-- Creates reporting view: ARCADE_ACTIVE_GAME_FIGURE_SHOP_VIEW
CREATE OR REPLACE VIEW ARCADE_ACTIVE_GAME_FIGURE_SHOP_VIEW AS
SELECT *
FROM prod_games.arcade.ARCADE_ACTIVE_GAME_FIGURE_SHOP;

-- Looker permissions for reporting views
GRANT SELECT ON prod_games.reporting.ARCADE_SEGMENT_FIGURE_SHOP_VIEW TO looker_read;
GRANT SELECT ON prod_games.reporting.ARCADE_ACTIVE_GAME_FIGURE_SHOP_VIEW TO looker_read;
