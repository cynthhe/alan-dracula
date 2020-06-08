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
    MAU_Benchmark,
    Segment
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
        1000000 AS MAU_Benchmark,
        segment AS Segment
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
      LEFT JOIN (SELECT 
                    date, 
                    ROUND(AVG(duration)) AS avg_time_per_day, 
                    CASE 
                        WHEN avg_time_per_day BETWEEN 0 AND 4 THEN 'Not engaged'
                        WHEN avg_time_per_day BETWEEN 4 AND 8 THEN 'Engaged'
                        WHEN avg_time_per_day >= 8 THEN 'Ultra engaged'
                        ELSE 'OTHERS'
                        END AS segment
                 FROM prod_games.arcade.arcade_perday
                 GROUP BY 1) AS j ON j.date = a.date
     );

-- retention per game
select
Game
,Date
,new_user
,DAU
,WAU
,MAU
,day1Perc as Day_1 
,day3Perc as Day_3
,day7Perc as Day_7
,day14Perc as Day_14
,day30Perc as Day_30

from(select
      a.game_name as game
      ,a.Date
      ,h.new_user
      ,cast(a.DAU as NUMBER(38,6)) as DAU
      ,cast(b.WAU as NUMBER(38,6)) as WAU
      ,cast(c.MAU as NUMBER(38,6)) as MAU
      ,coalesce(d.day1Perc,0) as day1Perc 
      ,coalesce(e.day7Perc,0) as day7Perc
      ,coalesce(f.day30Perc,0) as day30Perc
      ,coalesce(g.day3Perc,0) as day3Perc
      ,coalesce(k.day14Perc,0) as day14Perc

     from (select game_name, to_date(a.submit_time) as Date, count(distinct a.userid) as DAU from prod_games.arcade.game_open a join prod_games.arcade.deviceinfo b on b.userid = a.userid 
            where b.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019') group by 1,2) a
      left join (select game_name, DATEADD('DAY', seq, Date) AS Date, count(distinct userid) as WAU
                  FROM (select a.game_name, a.submit_time::Date AS Date, a.userid from prod_games.arcade.game_open a 
                        join prod_games.arcade.deviceinfo b on b.userid = a.userid 
                        where b.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019') group by 1,2,3) A,
                        (select seq from (select row_number() over (order by 1 ASC)-1 AS seq from information_schema.columns) where seq < 8) B
                        group by game_name, DATEADD('DAY', seq, Date)) b on a.game_name = b.game_name and a.date = b.date 
      left join (select game_name, DATEADD('DAY', seq, Date) AS Date, count(distinct userid) as MAU
                  FROM (select a.game_name, a.submit_time::Date AS Date, a.userid from prod_games.arcade.game_open a 
                        join prod_games.arcade.deviceinfo b on b.userid = a.userid 
                        where b.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019') group by 1,2,3) A,
                        (select seq from (select row_number() over (order by 1 ASC)-1 AS seq from information_schema.columns) where seq < 31) B
                        group by game_name, DATEADD('DAY', seq, Date)) c on a.game_name = c.game_name and a.date = c.date 

      left join (select a.game_name, dateadd(day,1,a.date) as date, coalesce(cast(c.day1players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day1Perc 
                  from (select game_name, to_date(a.submit_time) as date, count(distinct a.userid) as DAU 
                        from prod_games.arcade.game_open a join prod_games.arcade.deviceinfo b on b.userid = a.userid 
                        where b.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1,2) a
                  join (select a.game_name, a.start_date as date, count(distinct a.userid) as New_users 
                        from prod_games.arcade.first_played_games_date a 
                        where a.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1,2) b on b.date = a.date and b.game_name = a.game_name
                  join (select a.game_name, a.start_date as cohort_date, dateadd(day,1,a.start_date) as day1 ,count(distinct b.userid) as day1players 
                        from prod_games.arcade.first_played_games_date a
                        join prod_games.arcade.game_open b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,1,a.start_date) and b.game_name = a.game_name
                        where a.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1,2) c on c.cohort_date = a.date and c.game_name = a.game_name) d on a.game_name = d.game_name and a.date = d.date 
      
     left join (select a.game_name, dateadd(day,7,a.date) as date, coalesce(cast(c.day7players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day7Perc 
                  from (select game_name, to_date(a.submit_time) as date, count(distinct a.userid) as DAU 
                        from prod_games.arcade.game_open a join prod_games.arcade.deviceinfo b on b.userid = a.userid 
                        where b.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1,2) a
                  join (select a.game_name, a.start_date as date, count(distinct a.userid) as New_users 
                        from prod_games.arcade.first_played_games_date a 
                        where a.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1,2) b on b.date = a.date and b.game_name = a.game_name
                  join (select a.game_name, a.start_date as cohort_date, dateadd(day,7,a.start_date) as day7 ,count(distinct b.userid) as day7players 
                        from prod_games.arcade.first_played_games_date a
                        join prod_games.arcade.game_open b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,7,a.start_date) and b.game_name = a.game_name
                        where a.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1,2) c on c.cohort_date = a.date and c.game_name = a.game_name) e on a.game_name = e.game_name and a.date = e.date 
      
      left join (select a.game_name, dateadd(day,30,a.date) as date, coalesce(cast(c.day30players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day30Perc 
                  from (select game_name, to_date(a.submit_time) as date, count(distinct a.userid) as DAU 
                        from prod_games.arcade.game_open a join prod_games.arcade.deviceinfo b on b.userid = a.userid 
                        where b.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1,2) a
                  join (select a.game_name, a.start_date as date, count(distinct a.userid) as New_users 
                        from prod_games.arcade.first_played_games_date a 
                        where a.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1,2) b on b.date = a.date and b.game_name = a.game_name
                  join (select a.game_name, a.start_date as cohort_date, dateadd(day,30,a.start_date) as day30 ,count(distinct b.userid) as day30players 
                        from prod_games.arcade.first_played_games_date a
                        join prod_games.arcade.game_open b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,30,a.start_date) and b.game_name = a.game_name
                        where a.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1,2) c on c.cohort_date = a.date and c.game_name = a.game_name) f on a.game_name = f.game_name and a.date = f.date 

      left join (select a.game_name, dateadd(day,3,a.date) as date, coalesce(cast(c.day3players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day3Perc 
                  from (select game_name, to_date(a.submit_time) as date, count(distinct a.userid) as DAU 
                        from prod_games.arcade.game_open a join prod_games.arcade.deviceinfo b on b.userid = a.userid 
                        where b.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1,2) a
                  join (select a.game_name, a.start_date as date, count(distinct a.userid) as New_users 
                        from prod_games.arcade.first_played_games_date a 
                        where a.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1,2) b on b.date = a.date and b.game_name = a.game_name
                  join (select a.game_name, a.start_date as cohort_date, dateadd(day,3,a.start_date) as day3 ,count(distinct b.userid) as day3players 
                        from prod_games.arcade.first_played_games_date a
                        join prod_games.arcade.game_open b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,3,a.start_date) and b.game_name = a.game_name
                        where a.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1,2) c on c.cohort_date = a.date and c.game_name = a.game_name) g on g.game_name = a.game_name and g.date = a.date 
                 
    left join (select a.game_name, dateadd(day,14,a.date) as date, coalesce(cast(c.day14players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day14Perc 
                  from (select game_name, to_date(a.submit_time) as date, count(distinct a.userid) as DAU 
                        from prod_games.arcade.game_open a join prod_games.arcade.deviceinfo b on b.userid = a.userid 
                        where b.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1,2) a
                  join (select a.game_name, a.start_date as date, count(distinct a.userid) as New_users 
                        from prod_games.arcade.first_played_games_date a 
                        where a.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1,2) b on b.date = a.date and b.game_name = a.game_name
                  join (select a.game_name, a.start_date as cohort_date, dateadd(day,14,a.start_date) as day14 ,count(distinct b.userid) as day14players 
                        from prod_games.arcade.first_played_games_date a
                        join prod_games.arcade.game_open b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,14,a.start_date) and b.game_name = a.game_name
                        where a.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1,2) c on c.cohort_date = a.date and c.game_name = a.game_name) k on k.game_name = a.game_name and k.date = a.date
                 
                 
        left join (select game_name, start_date as date, count(distinct userid) as new_user 
                   from prod_games.arcade.first_played_games_date 
                   where country like 'US' 
                   and userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                   group by 1,2) as h on h.game_name = a.game_name and h.date = a.date 
);
