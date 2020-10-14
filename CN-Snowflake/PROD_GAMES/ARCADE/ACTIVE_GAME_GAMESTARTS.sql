CREATE OR REPLACE VIEW ACTIVE_GAME_GAMESTARTS AS
SELECT 
    'Arcade' AS game 
    ,a.submit_time::DATE AS date 
    ,CASE WHEN a.game_name LIKE 'Smashy%' THEN 'Smashy Pinata' ELSE a.game_name END AS ad_game 
    ,CASE WHEN b.active_game LIKE 'Smashy%' THEN 'Smashy Pinata' ELSE b.active_game END AS active_game 
    ,a.platform 
    ,COUNT(DISTINCT a.userid) AS users 
    ,COUNT(DISTINCT a.sessionid) AS sessions 
    ,COUNT(DISTINCT a.game_session_id) AS game_starts 
FROM prod_games.arcade.game_open a 
JOIN prod_games.arcade.arcade_active_game b ON (a.userid = b.userid) AND (a.submit_time::DATE = b.date) 
WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                           FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                           WHERE START_DATE >= '3/4/2019') 
AND date >= '3/4/2019'
GROUP BY 1,2,3,4,5;
