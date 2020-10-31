CREATE OR REPLACE VIEW ARCADE_ACTIVE_GAME AS
SELECT 
    apprunning.submit_time::DATE AS date
    ,apprunning.userid AS userid
    ,game_open.game_name AS active_game
FROM apprunning
JOIN game_open 
ON (apprunning.userid = game_open.userid) 
AND (apprunning.submit_time = game_open.submit_time)
AND game_open.submit_time::DATE BETWEEN DATEADD(DAY, -7, apprunning.submit_time::DATE) 
AND apprunning.submit_time::DATE;
