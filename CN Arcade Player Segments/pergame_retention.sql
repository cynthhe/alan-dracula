USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- Create game_retention view
CREATE VIEW game_retention AS
SELECT 
    Game, 
    Date, 
    active_game,
    new_user, 
    DAU, 
    WAU, 
    MAU, 
    day1Perc AS Day_1, 
    day3Perc AS Day_3, 
    day7Perc AS Day_7, 
    day14Perc AS Day_14, 
    day30Perc AS Day_30
FROM (SELECT 
        a.game_name AS game, 
        a.Date, 
        a.active_game,
        h.new_user, 
        CAST(a.DAU AS NUMBER(38,6)) AS DAU, 
        CAST(b.WAU AS NUMBER(38,6)) AS WAU, 
        CAST(c.MAU AS NUMBER(38,6)) AS MAU, 
        COALESCE(d.day1Perc,0) AS day1Perc, 
        COALESCE(e.day7Perc,0) AS day7Perc, 
        COALESCE(f.day30Perc,0) AS day30Perc, 
        COALESCE(g.day3Perc,0) AS day3Perc, 
        COALESCE(k.day14Perc,0) AS day14Perc
      FROM (SELECT 
                game_name, 
                TO_DATE(a.submit_time) AS Date, 
                c.active_game,
                COUNT(DISTINCT a.userid) AS DAU -- Gets DAU
            FROM prod_games.arcade.game_open a 
            JOIN prod_games.arcade.deviceinfo b ON (b.userid = a.userid) 
            JOIN arcade_active_game c ON (a.userid = c.userid) AND (a.submit_time::Date = c.date)
            WHERE b.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                       FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                       WHERE START_DATE >= '3/4/2019') 
            GROUP BY 1,2,3) a 
      LEFT JOIN (SELECT 
                    game_name, 
                    active_game,
                    DATEADD('DAY', seq, Date) AS Date, 
                    COUNT(DISTINCT userid) AS WAU -- Gets WAU
                 FROM (SELECT 
                        a.game_name, 
                        a.submit_time::DATE AS Date, 
                        a.userid, 
                        c.active_game
                       FROM prod_games.arcade.game_open a 
                       JOIN prod_games.arcade.deviceinfo b ON (b.userid = a.userid) 
                       JOIN arcade_active_game c ON (a.userid = c.userid) AND (a.submit_time::Date = c.date)
                       WHERE b.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2,3,4) A, 
                 (SELECT seq 
                  FROM (SELECT ROW_NUMBER() OVER (ORDER BY 1 ASC)-1 AS seq 
                                   FROM information_schema.columns) 
                  WHERE seq < 8) B 
                 GROUP BY 1,2,3) b ON (a.game_name = b.game_name) AND (a.date = b.date) AND (a.active_game = b.active_game) 
      LEFT JOIN (SELECT 
                    game_name, 
                    active_game,
                    DATEADD('DAY', seq, Date) AS Date, 
                    COUNT(DISTINCT userid) AS MAU -- Gets MAU
                 FROM (SELECT 
                        a.game_name, 
                        a.submit_time::DATE AS Date, 
                        a.userid, 
                        c.active_game
                       FROM prod_games.arcade.game_open a 
                       JOIN prod_games.arcade.deviceinfo b ON (b.userid = a.userid) 
                       JOIN arcade_active_game c ON (a.userid = c.userid) AND (a.submit_time::Date = c.date)
                       WHERE b.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2,3,4) A, 
                 (SELECT seq 
                  FROM (SELECT ROW_NUMBER() OVER (ORDER BY 1 ASC)-1 AS seq 
                        FROM information_schema.columns) WHERE seq < 31) B 
                 GROUP BY 1,2,3) c ON (a.game_name = c.game_name) AND (a.date = c.date) AND (a.active_game = c.active_game) 
      LEFT JOIN (SELECT 
                    a.game_name, 
                    DATEADD(day,1,a.date) AS date, 
                    active_game,
                    COALESCE(CAST(c.day1players AS NUMBER(38,6))/CAST(New_users AS NUMBER(38,6)),0) AS day1Perc -- Gets Day 1
                 FROM (SELECT 
                        game_name, 
                        TO_DATE(a.submit_time) AS date, 
                        c.active_game,
                        COUNT(DISTINCT a.userid) AS DAU 
                       FROM prod_games.arcade.game_open a 
                       JOIN prod_games.arcade.deviceinfo b ON b.userid = a.userid 
                       JOIN arcade_active_game c ON (a.userid = c.userid) AND (a.submit_time::Date = c.date)
                       WHERE b.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2,3) a 
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
                       GROUP BY 1,2,3) c ON (c.cohort_date = a.date) AND (c.game_name = a.game_name)) d ON (a.game_name = d.game_name) AND (a.date = d.date) AND (a.active_game = d.active_game) 
      LEFT JOIN (SELECT 
                    a.game_name, 
                    DATEADD(day,7,a.date) AS date, 
                    active_game,
                    COALESCE(CAST(c.day7players AS NUMBER(38,6))/CAST(New_users AS NUMBER(38,6)),0) AS day7Perc -- Gets Day 7
                 FROM (SELECT 
                        game_name, 
                        TO_DATE(a.submit_time) AS date, 
                        c.active_game,
                        COUNT(DISTINCT a.userid) AS DAU 
                       FROM prod_games.arcade.game_open a 
                       JOIN prod_games.arcade.deviceinfo b ON (b.userid = a.userid)
                       JOIN arcade_active_game c ON (a.userid = c.userid) AND (a.submit_time::Date = c.date)
                       WHERE b.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2,3) a 
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
                       GROUP BY 1,2,3) c ON (c.cohort_date = a.date) AND (c.game_name = a.game_name)) e ON (a.game_name = e.game_name) AND (a.date = e.date) AND (a.active_game = e.active_game) 
      LEFT JOIN (SELECT 
                    a.game_name, 
                    DATEADD(day,30,a.date) AS date, 
                    active_game,
                    COALESCE(CAST(c.day30players AS NUMBER(38,6))/CAST(New_users AS NUMBER(38,6)),0) AS day30Perc -- Gets Day 30
                 FROM (SELECT 
                        game_name, 
                        TO_DATE(a.submit_time) AS date, 
                        c.active_game,
                        COUNT(DISTINCT a.userid) AS DAU 
                       FROM prod_games.arcade.game_open a 
                       JOIN prod_games.arcade.deviceinfo b ON (b.userid = a.userid) 
                       JOIN arcade_active_game c ON (a.userid = c.userid) AND (a.submit_time::Date = c.date)
                       WHERE b.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2,3) a 
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
                       GROUP BY 1,2,3) c ON (c.cohort_date = a.date) AND (c.game_name = a.game_name)) f ON (a.game_name = f.game_name) AND (a.date = f.date) AND (a.active_game = f.active_game) 
      LEFT JOIN (SELECT 
                    a.game_name, 
                    DATEADD(day,3,a.date) AS date,
                    active_game,
                    COALESCE(CAST(c.day3players AS NUMBER(38,6))/CAST(New_users AS NUMBER(38,6)),0) AS day3Perc -- Gets Day 3
                 FROM (SELECT 
                        game_name, 
                        TO_DATE(a.submit_time) AS date, 
                        c.active_game,
                        COUNT(DISTINCT a.userid) AS DAU 
                       FROM prod_games.arcade.game_open a 
                       JOIN prod_games.arcade.deviceinfo b ON (b.userid = a.userid) 
                       JOIN arcade_active_game c ON (a.userid = c.userid) AND (a.submit_time::Date = c.date)
                       WHERE b.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2,3) a 
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
                       GROUP BY 1,2,3) c ON (c.cohort_date = a.date) AND (c.game_name = a.game_name)) g ON (a.game_name = g.game_name) AND (a.date = g.date) AND (a.active_game = g.active_game) 
      LEFT JOIN (SELECT 
                    a.game_name, 
                    DATEADD(day,14,a.date) AS date, 
                    active_game,
                    COALESCE(CAST(c.day14players AS NUMBER(38,6))/CAST(New_users AS NUMBER(38,6)),0) AS day14Perc -- Gets Day 14
                 FROM (SELECT 
                        game_name, 
                        TO_DATE(a.submit_time) AS date, 
                        c.active_game,
                        COUNT(DISTINCT a.userid) AS DAU 
                       FROM prod_games.arcade.game_open a 
                       JOIN prod_games.arcade.deviceinfo b ON (b.userid = a.userid) 
                       JOIN arcade_active_game c ON (a.userid = c.userid) AND (a.submit_time::Date = c.date)
                       WHERE b.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2,3) a 
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
                       GROUP BY 1,2,3) c ON (c.cohort_date = a.date) AND (c.game_name = a.game_name)) k ON (a.game_name = k.game_name) AND (a.date = k.date) AND (a.active_game = k.active_game) 
      LEFT JOIN (SELECT 
                    game_name, 
                    start_date AS date, 
                    active_game,
                    COUNT(DISTINCT a.userid) AS new_user 
                 FROM prod_games.arcade.first_played_games_date a
                 JOIN arcade_active_game b ON (a.userid = b.userid) AND (a.start_date = b.date)
                 WHERE country LIKE 'US' 
                 AND a.userid IN (SELECT userid 
                                FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                WHERE START_DATE >= '3/4/2019') 
                 GROUP BY 1,2,3) AS h ON (a.game_name = h.game_name) AND (a.date = h.date) AND (a.active_game = h.active_game)
     );
     
-- Drop game_retention view
DROP VIEW game_retention;
