SELECT 
    'Arcade' AS game, 
    DATEADD(day,30,a.date) AS date, 
    c.active_game,
    COALESCE(CAST(c.day30players AS NUMBER(38,6))/CAST(New_users AS NUMBER(38,6)),0) AS day30Perc -- Gets Day 30
FROM (SELECT DISTINCT
        TO_DATE(a.submit_time) AS date, 
        c.active_game,
        COUNT(DISTINCT a.userid) AS DAU 
      FROM prod_games.arcade.apprunning a 
      JOIN arcade_active_game c ON (a.userid = c.userid) AND (a.submit_time::Date = c.date)
      WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                 FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                 WHERE START_DATE >= '3/4/2019') 
      GROUP BY 1,2) a 
      JOIN (SELECT DISTINCT
                a.start_date AS date, 
                b.active_game,
                COUNT(DISTINCT a.userid) AS New_users 
            FROM prod_games.arcade.first_played_date a 
            JOIN arcade_active_game b ON (a.userid = b.userid) AND (a.start_date = b.date) 
            WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                       FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                       WHERE START_DATE >= '3/4/2019') 
            GROUP BY 1,2) b ON (b.date = a.date) AND (b.active_game = a.active_game)
            JOIN (SELECT DISTINCT
                    a.start_date AS cohort_date, 
                    DATEADD(day,30,a.start_date) AS day30,
                    c.active_game,
                    COUNT(DISTINCT b.userid) AS day30players 
                  FROM prod_games.arcade.first_played_date a 
                  JOIN prod_games.arcade.apprunning b ON b.userid = a.userid AND TO_DATE(b.submit_time) = DATEADD(day,30,a.start_date)
                  JOIN arcade_active_game c ON (b.userid = c.userid) AND (b.submit_time::Date = c.date) 
                  WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                             FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                             WHERE START_DATE >= '3/4/2019') 
                  GROUP BY 1,2,3) c ON (c.cohort_date = a.date) AND (c.active_game = a.active_game);
