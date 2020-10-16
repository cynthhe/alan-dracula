CREATE OR REPLACE VIEW ACTIVE_GAME_TIME_IN_GAME AS
SELECT
    a.date
    ,a.userid
    ,sessionid
    ,game_session_id
    ,CASE WHEN b.active_game LIKE 'Smashy%' THEN 'Smashy Pinata' ELSE b.active_game END AS active_game
    ,CASE WHEN a.app_location LIKE 'Smashy%' THEN 'Smashy Pinata' ELSE a.app_location END AS app_location
    ,ROUND(seconds_in_game / 60) AS min_in_game
FROM prod_games.arcade.TIME_IN_GAME a
JOIN prod_games.arcade.arcade_active_game b ON (a.userid = b.userid) AND (a.date = b.date);
