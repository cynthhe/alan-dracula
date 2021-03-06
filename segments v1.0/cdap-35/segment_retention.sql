USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- Create ARCADE_RETENTION view
CREATE OR REPLACE VIEW ARCADE_RETENTION AS
SELECT 
    Game
    ,Date 
    ,segment
    ,new_user 
    ,DAU 
    ,WAU 
    ,MAU
    ,day1Perc AS Day_1 
    ,day7Perc AS Day_7
    ,day30Perc AS Day_30 
    ,MAU_Benchmark
FROM (SELECT 
        a.Game 
        ,a.Date 
        ,a.segment
        ,h.new_user 
        ,CAST(a.DAU AS NUMBER(38,6)) AS DAU 
        ,CAST(b.WAU AS NUMBER(38,6)) AS WAU 
        ,CAST(c.MAU AS NUMBER(38,6)) AS MAU 
        ,day1Perc
        ,day7Perc 
        ,day30Perc 
        ,1000000 AS MAU_Benchmark
      FROM (SELECT 
                'Arcade' AS game 
                ,TO_DATE(a.submit_time) AS Date
                ,b.segment
                ,COUNT(DISTINCT a.userid) AS DAU -- Gets DAU
            FROM prod_games.arcade.apprunning a 
            JOIN arcade_engagement_segments b ON (a.userid = b.userid) AND ((YEAR(a.submit_time)||LPAD(MONTH(a.submit_time),2,'0')) = b.yearmonth)
            WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                       FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                       WHERE START_DATE >= '3/4/2019') 
            GROUP BY 1,2,3) a 
      LEFT JOIN (SELECT 
                    'Arcade' AS game 
                    ,DATEADD('DAY', seq, Date) AS Date 
                    ,segment
                    ,COUNT(DISTINCT userid) AS WAU -- Gets WAU 
                 FROM (SELECT DISTINCT
                       TO_DATE(a.submit_time) AS Date 
                       ,a.userid 
                       ,c.segment 
                       FROM prod_games.arcade.apprunning a 
                       JOIN arcade_engagement_segments c ON (a.userid = c.userid) AND ((YEAR(a.submit_time)||LPAD(MONTH(a.submit_time),2,'0')) = c.yearmonth) 
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019')
                      ) A, 
                 (SELECT seq 
                  FROM (SELECT ROW_NUMBER() OVER (ORDER BY 1 ASC)-1 AS seq 
                        FROM information_schema.columns) 
                  WHERE seq < 8) B 
                 GROUP BY 1,2,3) b ON (a.game = b.game) AND (a.date = b.date) AND (a.segment = b.segment)
      LEFT JOIN (SELECT 
                    'Arcade' AS game
                    ,DATEADD('DAY', seq, Date) AS Date 
                    ,segment 
                    ,COUNT(DISTINCT userid) AS MAU -- Gets MAU 
                 FROM (SELECT DISTINCT
                        TO_DATE(a.submit_time) AS Date 
                        ,a.userid 
                        ,c.segment 
                       FROM prod_games.arcade.apprunning a 
                       JOIN arcade_engagement_segments c ON (a.userid = c.userid) AND ((YEAR(a.submit_time)||LPAD(MONTH(a.submit_time),2,'0')) = c.yearmonth) 
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019')
                      ) A, 
                 (SELECT seq 
                  FROM (SELECT ROW_NUMBER() OVER (ORDER BY 1 ASC)-1 AS seq 
                        FROM information_schema.columns) 
                  WHERE seq < 31) B 
                 GROUP BY 1,2,3) c ON (a.game = c.game) AND (a.date = c.date) AND (a.segment = c.segment) 
      LEFT JOIN (SELECT 
                    'Arcade' AS game
                    ,DATEADD(day,1,a.date) AS date 
                    ,b.segment
                    ,COALESCE(CAST(c.day1players AS NUMBER(38,6))/CAST(New_users AS NUMBER(38,6)),0) AS day1Perc -- Gets Day 1
                 FROM (SELECT DISTINCT
                        TO_DATE(a.submit_time) AS date
                        ,b.segment
                        ,COUNT(DISTINCT a.userid) AS DAU
                       FROM prod_games.arcade.apprunning a 
                       JOIN arcade_engagement_segments b ON (a.userid = b.userid) AND ((YEAR(a.submit_time)||LPAD(MONTH(a.submit_time),2,'0')) = b.yearmonth) 
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2) a 
                 JOIN (SELECT DISTINCT
                        a.start_date AS date 
                        ,b.segment
                        ,COUNT(DISTINCT a.userid) AS New_users
                       FROM prod_games.arcade.first_played_date a 
                       JOIN arcade_engagement_segments b ON (a.userid = b.userid) AND ((YEAR(a.start_date)||LPAD(MONTH(a.start_date),2,'0')) = b.yearmonth)
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2) b ON (a.date = b.date) AND (a.segment = b.segment)
                 JOIN (SELECT DISTINCT
                        a.start_date AS cohort_date 
                        ,DATEADD(day,1,a.start_date) AS day1 
                        ,c.segment
                        ,COUNT(DISTINCT b.userid) AS day1players 
                       FROM prod_games.arcade.first_played_date a 
                       JOIN prod_games.arcade.apprunning b ON b.userid = a.userid AND TO_DATE(b.submit_time) = DATEADD(day,1,a.start_date)
                       JOIN arcade_engagement_segments c ON (b.userid = c.userid) AND ((YEAR(b.submit_time)||LPAD(MONTH(b.submit_time),2,'0')) = c.yearmonth)
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2,3) c 
                 ON (c.cohort_date = a.date) AND (c.segment = a.segment)) d ON (a.game = d.game) AND (a.date = d.date) AND (a.segment = d.segment) 
      LEFT JOIN (SELECT 
                    'Arcade' AS game
                    ,DATEADD(day,7,a.date) AS date
                    ,b.segment
                    ,COALESCE(CAST(c.day7players AS NUMBER(38,6))/CAST(New_users AS NUMBER(38,6)),0) AS day7Perc -- Gets Day 7
                 FROM (SELECT DISTINCT
                        TO_DATE(a.submit_time) AS date
                        ,b.segment
                        ,COUNT(DISTINCT a.userid) AS DAU 
                       FROM prod_games.arcade.apprunning a 
                       JOIN arcade_engagement_segments b ON (a.userid = b.userid) AND ((YEAR(a.submit_time)||LPAD(MONTH(a.submit_time),2,'0')) = b.yearmonth)
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2) a 
                 JOIN (SELECT DISTINCT
                        a.start_date AS date 
                        ,b.segment
                        ,COUNT(DISTINCT a.userid) AS New_users 
                       FROM prod_games.arcade.first_played_date a 
                       JOIN arcade_engagement_segments b ON (a.userid = b.userid) AND ((YEAR(a.start_date)||LPAD(MONTH(a.start_date),2,'0')) = b.yearmonth)
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2) b ON (a.date = b.date) AND (a.segment = b.segment)
                 JOIN (SELECT DISTINCT
                        a.start_date AS cohort_date
                        ,DATEADD(day,7,a.start_date) AS day7 
                        ,c.segment
                        ,COUNT(DISTINCT b.userid) AS day7players 
                       FROM prod_games.arcade.first_played_date a 
                       JOIN prod_games.arcade.apprunning b ON b.userid = a.userid AND to_date(b.submit_time) = dateadd(day,7,a.start_date) 
                       JOIN arcade_engagement_segments c ON (b.userid = c.userid) AND ((YEAR(b.submit_time)||LPAD(MONTH(b.submit_time),2,'0')) = c.yearmonth)
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2,3) c 
                 ON (c.cohort_date = a.date) AND (c.segment = a.segment)) e ON (a.game = e.game) AND (a.date = e.date) AND (a.segment = e.segment) 
      LEFT JOIN (SELECT 
                    'Arcade' AS game
                    ,DATEADD(day,30,a.date) AS date
                    ,c.segment
                    ,COALESCE(CAST(c.day30players AS NUMBER(38,6))/CAST(New_users AS NUMBER(38,6)),0) AS day30Perc -- Gets Day 30
                 FROM (SELECT DISTINCT
                        TO_DATE(a.submit_time) AS date
                        ,c.segment
                        ,COUNT(DISTINCT a.userid) AS DAU
                       FROM prod_games.arcade.appstart a
                       JOIN prod_games.arcade.deviceinfo b ON (b.userid = a.userid)
                       JOIN arcade_engagement_segments c ON (a.userid = c.userid) AND ((YEAR(a.submit_time)||LPAD(MONTH(a.submit_time),2,'0')) = c.yearmonth)
                       WHERE b.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2) a 
                 JOIN (SELECT DISTINCT
                        a.start_date AS date
                        ,b.segment
                        ,COUNT(DISTINCT a.userid) AS New_users 
                       FROM prod_games.arcade.first_played_date a 
                       JOIN arcade_engagement_segments b ON (a.userid = b.userid) AND ((YEAR(a.start_date)||LPAD(MONTH(a.start_date),2,'0')) = b.yearmonth)
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2) b ON (b.date = a.date) AND (b.segment = a.segment) 
                 JOIN (SELECT DISTINCT
                        a.start_date AS cohort_date
                        ,DATEADD(day,30,a.start_date) AS day30
                        ,c.segment
                        ,COUNT(DISTINCT b.userid) AS day30players 
                       FROM prod_games.arcade.first_played_date a 
                       JOIN prod_games.arcade.apprunning b ON b.userid = a.userid AND to_date(b.submit_time) = dateadd(day,30,a.start_date) 
                       JOIN arcade_engagement_segments c ON (b.userid = c.userid) AND ((YEAR(b.submit_time)||LPAD(MONTH(b.submit_time),2,'0')) = c.yearmonth)
                       WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                                  FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                                  WHERE START_DATE >= '3/4/2019') 
                       GROUP BY 1,2,3) c ON (c.cohort_date = a.date) AND (c.segment = a.segment)) f ON (a.game = f.game) AND (a.date = f.date) AND (a.segment = f.segment) 
      LEFT JOIN (SELECT 
                    'Arcade' AS game
                    ,start_date AS date
                    ,c.segment
                    ,COUNT(DISTINCT a.userid) AS new_user -- Gets new user count
                 FROM prod_games.arcade.first_played_date a
                 JOIN prod_games.arcade.apprunning b ON b.userid = a.userid AND TO_DATE(b.submit_time) = a.start_date
                 JOIN arcade_engagement_segments c ON (b.userid = c.userid) AND ((YEAR(b.submit_time)||LPAD(MONTH(b.submit_time),2,'0')) = c.yearmonth)
                 WHERE a.country LIKE 'US' AND a.userid IN (SELECT userid 
                                                        FROM prod_games.arcade.FIRST_PLAYED_DATE 
                                                        WHERE START_DATE >= '3/4/2019') 
                 GROUP BY 1,2,3) AS h ON (a.game = h.game) AND (a.date = h.date) AND (a.segment = h.segment)
     );
