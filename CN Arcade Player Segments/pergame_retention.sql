USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

SELECT 
    Game, 
    Date, 
    new_user, 
    DAU, 
    WAU, 
    MAU, 
    day1Perc AS Day_1, 
    day3Perc AS Day_3, 
    day7Perc AS Day_7, 
    day14Perc AS Day_14, 
    day30Perc AS Day_30, 
    Not_Engaged,
    Engaged,
    Ultra_Engaged
FROM (SELECT 
        a.game_name AS game, 
        a.Date, 
        h.new_user, 
        CAST(a.DAU AS NUMBER(38,6)) AS DAU, 
        CAST(b.WAU AS NUMBER(38,6)) AS WAU, 
        CAST(c.MAU AS NUMBER(38,6)) AS MAU, 
        COALESCE(d.day1Perc,0) AS day1Perc, 
        COALESCE(e.day7Perc,0) AS day7Perc, 
        COALESCE(f.day30Perc,0) AS day30Perc, 
        COALESCE(g.day3Perc,0) AS day3Perc, 
        COALESCE(k.day14Perc,0) AS day14Perc,
        j.Not_Engaged AS Not_Engaged,
        j.Engaged AS Engaged,
        j.Ultra_Engaged AS Ultra_Engaged
      FROM (SELECT 
                game_name, 
                TO_DATE(a.submit_time) AS Date, 
                COUNT(DISTINCT a.userid) AS DAU 
            FROM prod_games.arcade.game_open a 
            JOIN prod_games.arcade.deviceinfo b ON b.userid = a.userid 
            WHERE b.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                       FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                       WHERE START_DATE >= '3/4/2019') 
            GROUP BY 1,2) a 
      LEFT JOIN (SELECT 
                    game_name, 
                    DATEADD('DAY', seq, Date) AS Date, 
                    COUNT(DISTINCT userid) AS WAU 
                 FROM (SELECT 
                        a.game_name, 
                        a.submit_time::DATE AS Date, 
                        a.userid 
                       FROM prod_games.arcade.game_open a 
                       JOIN prod_games.arcade.deviceinfo b ON b.userid = a.userid 
                       WHERE b.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2,3) A, 
                 (SELECT seq 
                  FROM (SELECT ROW_NUMBER() OVER (ORDER BY 1 ASC)-1 AS seq 
                                   FROM information_schema.columns) 
                  WHERE seq < 8) B 
                 GROUP BY game_name, DATEADD('DAY', seq, Date)) b ON a.game_name = b.game_name AND a.date = b.date 
      LEFT JOIN (SELECT 
                    game_name, 
                    DATEADD('DAY', seq, Date) AS Date, 
                    COUNT(DISTINCT userid) AS MAU 
                 FROM (SELECT 
                        a.game_name, 
                        a.submit_time::DATE AS Date, 
                        a.userid 
                       FROM prod_games.arcade.game_open a 
                       JOIN prod_games.arcade.deviceinfo b ON b.userid = a.userid 
                       WHERE b.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2,3) A, 
                 (SELECT seq 
                  FROM (SELECT ROW_NUMBER() OVER (ORDER BY 1 ASC)-1 AS seq 
                        FROM information_schema.columns) WHERE seq < 31) B 
                 GROUP BY game_name, DATEADD('DAY', seq, Date)) c ON a.game_name = c.game_name AND a.date = c.date 
      LEFT JOIN (SELECT 
                    a.game_name, 
                    DATEADD(day,1,a.date) AS date, 
                    COALESCE(CAST(c.day1players AS NUMBER(38,6))/CAST(New_users AS NUMBER(38,6)),0) AS day1Perc 
                 FROM (SELECT 
                        game_name, 
                        TO_DATE(a.submit_time) AS date, 
                        COUNT(DISTINCT a.userid) AS DAU 
                       FROM prod_games.arcade.game_open a 
                       JOIN prod_games.arcade.deviceinfo b ON b.userid = a.userid 
                       WHERE b.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2) a 
                 JOIN (SELECT 
                        a.game_name, 
                        a.start_date AS date, 
                        COUNT(DISTINCT a.userid) AS New_users 
                       FROM prod_games.arcade.first_played_games_date a 
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2) b ON b.date = a.date AND b.game_name = a.game_name 
                 JOIN (SELECT 
                        a.game_name, 
                        a.start_date AS cohort_date, 
                        DATEADD(day,1,a.start_date) AS day1 , 
                        COUNT(DISTINCT b.userid) AS day1players 
                       FROM prod_games.arcade.first_played_games_date a 
                       JOIN prod_games.arcade.game_open b ON b.userid = a.userid AND to_date(b.submit_time) = dateadd(day,1,a.start_date) AND b.game_name = a.game_name 
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2) c ON c.cohort_date = a.date AND c.game_name = a.game_name) d ON a.game_name = d.game_name AND a.date = d.date 
      LEFT JOIN (SELECT 
                    a.game_name, 
                    DATEADD(day,7,a.date) AS date, 
                    COALESCE(CAST(c.day7players AS NUMBER(38,6))/CAST(New_users AS NUMBER(38,6)),0) AS day7Perc 
                 FROM (SELECT 
                        game_name, 
                        TO_DATE(a.submit_time) AS date, 
                        COUNT(DISTINCT a.userid) AS DAU 
                       FROM prod_games.arcade.game_open a JOIN prod_games.arcade.deviceinfo b ON b.userid = a.userid 
                       WHERE b.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2) a 
                 JOIN (SELECT 
                        a.game_name, 
                        a.start_date AS date, 
                        COUNT(DISTINCT a.userid) AS New_users 
                       FROM prod_games.arcade.first_played_games_date a 
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2) b ON b.date = a.date AND b.game_name = a.game_name 
                 JOIN (SELECT 
                        a.game_name, 
                        a.start_date AS cohort_date, 
                        DATEADD(day,7,a.start_date) AS day7, 
                        COUNT(DISTINCT b.userid) AS day7players 
                       FROM prod_games.arcade.first_played_games_date a 
                       JOIN prod_games.arcade.game_open b ON b.userid = a.userid AND TO_DATE(b.submit_time) = DATEADD(day,7,a.start_date) AND b.game_name = a.game_name 
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2) c ON c.cohort_date = a.date AND c.game_name = a.game_name) e ON a.game_name = e.game_name AND a.date = e.date 
      LEFT JOIN (SELECT 
                    a.game_name, 
                    DATEADD(day,30,a.date) AS date, 
                    COALESCE(CAST(c.day30players AS NUMBER(38,6))/CAST(New_users AS NUMBER(38,6)),0) AS day30Perc 
                 FROM (SELECT 
                        game_name, 
                        TO_DATE(a.submit_time) AS date, 
                        COUNT(DISTINCT a.userid) AS DAU 
                       FROM prod_games.arcade.game_open a 
                       JOIN prod_games.arcade.deviceinfo b ON b.userid = a.userid 
                       WHERE b.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2) a 
                 JOIN (SELECT 
                        a.game_name, 
                        a.start_date AS date, 
                        COUNT(DISTINCT a.userid) AS New_users 
                       FROM prod_games.arcade.first_played_games_date a 
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2) b ON b.date = a.date AND b.game_name = a.game_name 
                 JOIN (SELECT 
                        a.game_name, 
                        a.start_date AS cohort_date, 
                        DATEADD(day,30,a.start_date) AS day30, 
                        COUNT(DISTINCT b.userid) AS day30players 
                       FROM prod_games.arcade.first_played_games_date a 
                       JOIN prod_games.arcade.game_open b ON b.userid = a.userid AND TO_DATE(b.submit_time) = DATEADD(day,30,a.start_date) AND b.game_name = a.game_name 
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2) c ON c.cohort_date = a.date AND c.game_name = a.game_name) f ON a.game_name = f.game_name AND a.date = f.date 
      LEFT JOIN (SELECT 
                    a.game_name, 
                    DATEADD(day,3,a.date) AS date, 
                    COALESCE(CAST(c.day3players AS NUMBER(38,6))/CAST(New_users AS NUMBER(38,6)),0) AS day3Perc 
                 FROM (SELECT 
                        game_name, 
                        TO_DATE(a.submit_time) AS date, 
                        COUNT(DISTINCT a.userid) AS DAU 
                       FROM prod_games.arcade.game_open a JOIN prod_games.arcade.deviceinfo b ON b.userid = a.userid 
                       WHERE b.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2) a 
                 JOIN (SELECT 
                        a.game_name, 
                        a.start_date AS date, 
                        COUNT(DISTINCT a.userid) AS New_users 
                       FROM prod_games.arcade.first_played_games_date a 
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2) b ON b.date = a.date AND b.game_name = a.game_name 
                 JOIN (SELECT 
                        a.game_name, 
                        a.start_date AS cohort_date, 
                        DATEADD(day,3,a.start_date) AS day3, 
                        COUNT(DISTINCT b.userid) AS day3players 
                       FROM prod_games.arcade.first_played_games_date a 
                       JOIN prod_games.arcade.game_open b ON b.userid = a.userid AND TO_DATE(b.submit_time) = DATEADD(day,3,a.start_date) AND b.game_name = a.game_name 
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2) c ON c.cohort_date = a.date AND c.game_name = a.game_name) g ON g.game_name = a.game_name AND g.date = a.date 
      LEFT JOIN (SELECT 
                    a.game_name, 
                    DATEADD(day,14,a.date) AS date, 
                    COALESCE(CAST(c.day14players AS NUMBER(38,6))/CAST(New_users AS NUMBER(38,6)),0) AS day14Perc 
                 FROM (SELECT 
                        game_name, 
                        TO_DATE(a.submit_time) AS date, 
                        COUNT(DISTINCT a.userid) AS DAU 
                       FROM prod_games.arcade.game_open a JOIN prod_games.arcade.deviceinfo b ON b.userid = a.userid 
                       WHERE b.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2) a 
                 JOIN (SELECT 
                        a.game_name, 
                        a.start_date AS date, 
                        COUNT(DISTINCT a.userid) AS New_users 
                       FROM prod_games.arcade.first_played_games_date a 
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2) b ON b.date = a.date AND b.game_name = a.game_name 
                 JOIN (SELECT 
                        a.game_name, 
                        a.start_date AS cohort_date, 
                        DATEADD(day,14,a.start_date) AS day14, 
                        COUNT(DISTINCT b.userid) AS day14players 
                       FROM prod_games.arcade.first_played_games_date a 
                       JOIN prod_games.arcade.game_open b ON b.userid = a.userid AND TO_DATE(b.submit_time) = DATEADD(day,14,a.start_date) AND b.game_name = a.game_name 
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2) c ON c.cohort_date = a.date AND c.game_name = a.game_name) k ON k.game_name = a.game_name AND k.date = a.date 
      LEFT JOIN (SELECT 
                    game_name, 
                    start_date AS date, 
                    COUNT(DISTINCT userid) AS new_user 
                 FROM prod_games.arcade.first_played_games_date 
                 WHERE country LIKE 'US' 
                 AND userid IN (SELECT userid 
                                FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                WHERE START_DATE >= '3/4/2019') 
                 GROUP BY 1,2) AS h ON h.game_name = a.game_name AND h.date = a.date
      LEFT JOIN (SELECT 
                    yearmonth, 
                    game_name, 
                    SUM(CASE WHEN segment = 'Not engaged' THEN 1 ELSE 0 END) AS Not_Engaged, 
                    SUM(CASE WHEN segment = 'Engaged' THEN 1 ELSE 0 END) AS Engaged, 
                    SUM(CASE WHEN segment = 'Ultra engaged' THEN 1 ELSE 0 END) AS Ultra_Engaged 
                 FROM arcade_engagement_segments 
                 JOIN prod_games.arcade.game_open ON (arcade_engagement_segments.userid = game_open.userid) 
                 AND (arcade_engagement_segments.yearmonth = YEAR(game_open.submit_time)||LPAD(MONTH(game_open.submit_time),2,'0')) 
                 GROUP BY 1,2) AS j ON j.yearmonth = YEAR(a.date)||LPAD(MONTH(a.date),2,'0') AND j.game_name = a.game_name
     );           