CREATE OR REPLACE VIEW FIGUREDATAFORTESS AS
SELECT
    date
    ,title
    ,stunt_name
    ,CASE WHEN game IS NOT null THEN 'Game'
        WHEN gameId IS NOT null THEN 'Game'
        WHEN game_name = 'Squad Goals' THEN 'Squad Goals crate'
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
        ,parse_json(all_data):data.figure.origins.gameId::varchar AS gameId
        ,parse_json(all_data):data.figure.origins.acr::varchar AS acr
        ,parse_json(all_data):data.figure.origins.shop::varchar AS shop
        ,parse_json(all_data):data.figure.origins.stuntId::varchar AS stuntId
        ,COUNT(userid) AS figures_rewarded
      FROM prod_games.arcade.GDB_gotReward
      WHERE userid IS NOT null 
      GROUP BY 1,2,3,4,5,6,7,8,9
     )
GROUP BY 1,2,3,4;
