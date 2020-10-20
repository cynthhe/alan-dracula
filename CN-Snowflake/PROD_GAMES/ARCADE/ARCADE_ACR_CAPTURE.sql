CREATE OR REPLACE VIEW ARCADE_ACR_CAPTURE AS
SELECT
    a.submit_time::date AS date
    ,a.episode_name
    ,b.show_name
    ,a.success
    ,a.figure_granted
    ,a.play_userloggedin
    ,a.platform
    ,COUNT(DISTINCT a.userid) AS users
    ,COUNT(DISTINCT a.sessionid) AS sessions
    ,COUNT(a.userid) AS times_captured
FROM prod_games.arcade.acr_table a
LEFT JOIN prod_games.arcade.episode_show_name b ON b.episode_name = a.episode_name
WHERE a.userid IN (SELECT userid 
                   FROM prod_games.arcade.apprunning 
                   WHERE country LIKE 'US')
AND a.userid IN (SELECT userid 
                 FROM prod_games.arcade.FIRST_PLAYED_DATE 
                 WHERE START_DATE >= '3/4/2019')
GROUP BY 1,2,3,4,5,6,7;
