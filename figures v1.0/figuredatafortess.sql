USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

CREATE OR REPLACE VIEW PROD_GAMES.ARCADE.FIGUREDATAFORTESS AS
SELECT
    date
    ,title
    ,stunt_name
    ,CASE WHEN game IS NOT null THEN 'Game'
        WHEN gameId IS NOT null THEN 'Game'
        WHEN game_name = 'Squad Goals' THEN 'Squad Goals crate'
        WHEN figure_shop IS NOT NULL THEN 'Shop'
        WHEN acr_tag IS NOT NULL THEN 'ACR'
        WHEN stunt_name IS NOT NULL THEN 'Stunt'
        WHEN stuntId IS NOT null THEN 'Stunt'
        WHEN acr = 'true' THEN 'ACR'
        WHEN shop = 'true' THEN 'Shop'
        ELSE 'ACR'
        END AS capture_method
    ,SUM(figures_rewarded) AS figures_rewarded
FROM (SELECT
        date
        ,TITLE
        ,parse_json(all_data):data.figure.hints.game::varchar AS game
        ,parse_json(all_data):data.origin.rewardMethod.stunt::varchar AS stunt_name
        ,parse_json(all_data):data.origin.rewardMethod.game::varchar AS game_name
        ,parse_json(all_data):data.origin.rewardMethod.figureshop::varchar AS figure_shop
        ,parse_json(all_data):data.origin.rewardMethod.acr::varchar AS acr_tag
        ,parse_json(all_data):data.figure.origins.gameId::varchar AS gameId
        ,parse_json(all_data):data.figure.origins.acr::varchar AS acr
        ,parse_json(all_data):data.figure.origins.shop::varchar AS shop
        ,parse_json(all_data):data.figure.origins.stuntId::varchar AS stuntId
        ,COUNT(userid) AS figures_rewarded
      FROM prod_games.arcade.GDB_gotReward
      WHERE userid IS NOT null 
      GROUP BY 1,2,3,4,5,6,7,8,9,10,11
     )
GROUP BY 1,2,3,4;

-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- Create reporting view: ARCADE_SEGMENT_ACR_VIEW
CREATE OR REPLACE VIEW FIGUREDATAFORTESS AS
SELECT *
FROM prod_games.arcade.FIGUREDATAFORTESS;

-- Looker permissions for reporting view
GRANT SELECT ON prod_games.reporting.FIGUREDATAFORTESS TO looker_read;
