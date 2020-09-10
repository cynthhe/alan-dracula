USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- Figures per player for users who were active in the last 30 days
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
            WHERE date >= DATEADD(day,-30,CURRENT_DATE()) AND date <= CURRENT_DATE()
            GROUP BY 1,2) a
      JOIN prod_games.arcade.SCREEN_VISIT b ON b.PLAY_USERID = a.userid
      WHERE b.country LIKE 'US' AND b.userid IN (SELECT userid 
                                                 FROM prod_games.arcade."FIRST_PLAYED_DATE" 
                                                 WHERE START_DATE >= '3/4/2019')
      AND b.screen_name LIKE '%reward%'
      GROUP BY 1)
GROUP BY 1,2
ORDER BY total_figures_owned ASC, distinct_figures_owned ASC;
