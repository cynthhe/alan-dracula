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
