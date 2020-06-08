USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- retention for CN Arcade
SELECT 
    Game,
    Date, 
    new_user, 
    DAU, 
    WAU, 
    MAU, 
    day1Perc AS Day_1, 
    day7Perc AS Day_7, 
    day30Perc AS Day_30, 
    MAU_Benchmark 
FROM (SELECT 
        a.Game, 
        a.Date, 
        h.new_user, 
        CAST(a.DAU AS NUMBER(38,6)) AS DAU, 
        CAST(b.WAU AS NUMBER(38,6)) AS WAU, 
        CAST(c.MAU AS NUMBER(38,6)) AS MAU, 
        day1Perc, 
        day7Perc, 
        day30Perc, 
        1000000 AS MAU_Benchmark
      FROM (SELECT 
                'Arcade' AS game, 
                TO_DATE(a.submit_time) AS Date, 
                COUNT(DISTINCT a.userid) AS DAU -- Gets DAU
            FROM prod_games.arcade.apprunning a 
            WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                       FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                       WHERE START_DATE >= '3/4/2019') 
            GROUP BY 1,2) a 
      LEFT JOIN (SELECT 
                    'Arcade' AS game, 
                    DATEADD('DAY', seq, Date) AS Date, 
                    COUNT(DISTINCT userid) AS WAU -- Gets WAU
                 FROM (SELECT DISTINCT 
                        TO_DATE(a.submit_time) AS Date, 
                        a.userid 
                       FROM prod_games.arcade.apprunning a 
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019')
                      ) A, 
                 (SELECT seq 
                  FROM (SELECT ROW_NUMBER() OVER (ORDER BY 1 ASC)-1 AS seq 
                        FROM information_schema.columns) 
                  WHERE seq < 8) B
                 GROUP BY DATEADD('DAY', seq, Date)) b ON a.game = b.game AND a.date = b.date 
      LEFT JOIN (SELECT 
                    'Arcade' AS game, 
                    DATEADD('DAY', seq, Date) AS Date, 
                    COUNT(DISTINCT userid) AS MAU -- Gets MAU
                 FROM (SELECT DISTINCT 
                        to_date(a.submit_time) AS Date, 
                        a.userid FROM prod_games.arcade.apprunning a 
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019')
                      ) A, 
                 (SELECT seq 
                  FROM (SELECT ROW_NUMBER() OVER (ORDER BY 1 ASC)-1 AS seq 
                        FROM information_schema.columns) 
                  WHERE seq < 31) B 
                 GROUP BY DATEADD('DAY', seq, Date)) c ON a.game = c.game AND a.date = c.date 
      LEFT JOIN (SELECT 
                    'Arcade' AS game, 
                    DATEADD(day,1,a.date) AS date, 
                    COALESCE(CAST(c.day1players AS NUMBER(38,6))/CAST(New_users AS NUMBER(38,6)),0) AS day1Perc -- Gets Day 1
                 FROM (SELECT 
                        to_date(a.submit_time) AS date, 
                        COUNT(DISTINCT a.userid) AS DAU 
                       FROM prod_games.arcade.apprunning a 
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1) a 
                 JOIN (SELECT 
                        a.start_date AS date, 
                        COUNT(DISTINCT a.userid) AS New_users
                       FROM prod_games.arcade.first_played_date a 
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1) b ON b.date = a.date 
                 JOIN (SELECT 
                        a.start_date AS cohort_date, 
                        DATEADD(day,1,a.start_date) AS day1 , 
                        COUNT(DISTINCT b.userid) AS day1players 
                       FROM prod_games.arcade.first_played_date a 
                       JOIN prod_games.arcade.apprunning b ON b.userid = a.userid AND to_date(b.submit_time) = dateadd(day,1,a.start_date) 
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1) c ON c.cohort_date = a.date) d ON a.game = d.game AND a.date = d.date 
      LEFT JOIN (SELECT 
                    'Arcade' AS game, 
                    DATEADD(day,7,a.date) AS date, 
                    COALESCE(CAST(c.day7players AS NUMBER(38,6))/CAST(New_users AS NUMBER(38,6)),0) AS day7Perc -- Gets Day 7
                 FROM (SELECT 
                        to_date(a.submit_time) AS date, 
                        COUNT(DISTINCT a.userid) AS DAU 
                       FROM prod_games.arcade.apprunning a 
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1) a 
                 JOIN (SELECT 
                        a.start_date AS date, 
                        COUNT(DISTINCT a.userid) AS New_users 
                       FROM prod_games.arcade.first_played_date a 
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1) b on b.date = a.date 
                 JOIN (SELECT 
                        a.start_date AS cohort_date, 
                        DATEADD(day,7,a.start_date) AS day7, 
                        COUNT(DISTINCT b.userid) AS day7players 
                       FROM prod_games.arcade.first_played_date a 
                       JOIN prod_games.arcade.apprunning b ON b.userid = a.userid AND to_date(b.submit_time) = dateadd(day,7,a.start_date) 
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1) c ON c.cohort_date = a.date) e ON a.game = e.game and a.date = e.date 
      LEFT JOIN (SELECT 
                    'Arcade' AS game, 
                    DATEADD(day,30,a.date) AS date, 
                    COALESCE(CAST(c.day30players AS NUMBER(38,6))/CAST(New_users AS NUMBER(38,6)),0) AS day30Perc -- Gets Day 30
                 FROM (SELECT 
                        to_date(a.submit_time) AS date, 
                        COUNT(DISTINCT a.userid) AS DAU 
                       FROM prod_games.arcade.appstart a 
                       JOIN prod_games.arcade.deviceinfo b ON b.userid = a.userid 
                       WHERE b.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1) a 
                 JOIN (SELECT 
                        a.start_date AS date, 
                        COUNT(DISTINCT a.userid) AS New_users 
                       FROM prod_games.arcade.first_played_date a 
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1) b ON b.date = a.date 
                 JOIN (SELECT 
                        a.start_date AS cohort_date, 
                        DATEADD(day,30,a.start_date) AS day30, 
                        COUNT(DISTINCT b.userid) AS day30players 
                       FROM prod_games.arcade.first_played_date a 
                       JOIN prod_games.arcade.apprunning b ON b.userid = a.userid AND to_date(b.submit_time) = dateadd(day,30,a.start_date) 
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1) c ON c.cohort_date = a.date) f ON a.game = f.game AND a.date = f.date 
      LEFT JOIN (SELECT 
                    'Arcade' AS game, 
                    start_date AS date, 
                    COUNT(DISTINCT userid) AS new_user -- Gets new user count
                 FROM prod_games.arcade.first_played_date 
                 WHERE country LIKE 'US' AND userid IN (SELECT userid 
                                                        FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                        WHERE START_DATE >= '3/4/2019') 
                 GROUP BY 1,2) AS h ON h.game = a.game AND h.date = a.date
     );
