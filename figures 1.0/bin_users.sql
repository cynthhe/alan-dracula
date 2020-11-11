USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

CREATE OR REPLACE VIEW fig_per_player_temp AS
SELECT
    distinct_figures_owned
    ,COUNT(DISTINCT userid) AS users
FROM (SELECT
        a.userid
        ,COUNT(DISTINCT a.figureid) AS distinct_figures_owned
      FROM (SELECT 
                userid
                ,figureid 
            FROM prod_games.arcade.GDB_GOTREWARD 
            GROUP BY 1,2) a
      JOIN prod_games.arcade.SCREEN_VISIT b ON b.PLAY_USERID = a.userid
      WHERE b.country LIKE 'US' AND b.userid IN (SELECT userid 
                                                 FROM prod_games.arcade."FIRST_PLAYED_DATE" 
                                                 WHERE START_DATE >= '3/4/2019')
      AND b.screen_name LIKE '%reward%'
      GROUP BY 1)
GROUP BY 1
ORDER BY distinct_figures_owned ASC;

------------------------------------------------
SELECT
  CASE 
    WHEN distinct_figures_owned BETWEEN 1 AND 10 THEN '1-10'
    WHEN distinct_figures_owned BETWEEN 11 AND 20 THEN '11-20'
    WHEN distinct_figures_owned BETWEEN 21 AND 30 THEN '21-30'
    WHEN distinct_figures_owned BETWEEN 31 AND 40 THEN '31-40'
    WHEN distinct_figures_owned BETWEEN 41 AND 50 THEN '41-50'
    ELSE 'More than 50 distinct figures'
  END AS bin
  ,CONCAT(ROUND(((SUM(users) / (SELECT SUM(users) FROM fig_per_player_temp)) * 100), 2), '%') AS "% of Total"
FROM fig_per_player_temp
GROUP BY 1;
