select

Game

,Date

,new_user

,DAU

,WAU

,MAU

,day1Perc as Day_1

,day7Perc as Day_7

,day30Perc as Day_30

,MAU_Benchmark

 

from(select

a.Game

,a.Date

,h.new_user

,cast(a.DAU as NUMBER(38,6)) as DAU

,cast(b.WAU as NUMBER(38,6)) as WAU

,cast(c.MAU as NUMBER(38,6)) as MAU

,day1Perc

,day7Perc

,day30Perc

,1000000 as MAU_Benchmark

from (select 'Arcade' as game, to_date(a.submit_time) as Date, count(distinct a.userid) as DAU from prod_games.arcade.apprunning a 

        where a.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019') group by 1,2) a

left join (select 'Arcade' as game, DATEADD('DAY', seq, Date) AS Date, count(distinct userid) as WAU

            FROM (select distinct to_date(a.submit_time) AS Date, a.userid from prod_games.arcade.apprunning a 

            where a.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')) A,

            (select seq from (select row_number() over (order by 1 ASC)-1 AS seq from information_schema.columns) where seq < 8) B

            group by DATEADD('DAY', seq, Date)) b on a.game = b.game and a.date = b.date

left join (select 'Arcade' as game, DATEADD('DAY', seq, Date) AS Date, count(distinct userid) as MAU

            FROM (select distinct to_date(a.submit_time) AS Date, a.userid from prod_games.arcade.apprunning a 

            where a.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')) A,

            (select seq from (select row_number() over (order by 1 ASC)-1 AS seq from information_schema.columns) where seq < 31) B

            group by DATEADD('DAY', seq, Date)) c on a.game = c.game and a.date = c.date

 

left join (select 'Arcade' as game, dateadd(day,1,a.date) as date, coalesce(cast(c.day1players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day1Perc

            from (select to_date(a.submit_time) as date, count(distinct a.userid) as DAU from prod_games.arcade.apprunning a 

            where a.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')

            group by 1) a

            join (select a.start_date as date, count(distinct a.userid) as New_users from prod_games.arcade.first_played_date a

            where a.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')

            group by 1) b on b.date = a.date

            join (select a.start_date as cohort_date, dateadd(day,1,a.start_date) as day1 ,count(distinct b.userid) as day1players

            from prod_games.arcade.first_played_date a

            join prod_games.arcade.apprunning b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,1,a.start_date)

            where a.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')

            group by 1) c on c.cohort_date = a.date) d on a.game = d.game and a.date = d.date

 

left join (select 'Arcade' as game, dateadd(day,7,a.date) as date, coalesce(cast(c.day7players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day7Perc

            from (select to_date(a.submit_time) as date, count(distinct a.userid) as DAU from prod_games.arcade.apprunning a

            where a.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')

            group by 1) a

            join (select a.start_date as date, count(distinct a.userid) as New_users from prod_games.arcade.first_played_date a

            where a.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')

            group by 1) b on b.date = a.date

            join (select a.start_date as cohort_date, dateadd(day,7,a.start_date) as day7 ,count(distinct b.userid) as day7players

            from prod_games.arcade.first_played_date a

            join prod_games.arcade.apprunning b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,7,a.start_date)

            where a.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')

            group by 1) c on c.cohort_date = a.date) e on a.game = e.game and a.date = e.date

 

left join (select 'Arcade' as game, dateadd(day,30,a.date) as date, coalesce(cast(c.day30players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day30Perc

            from (select to_date(a.submit_time) as date, count(distinct a.userid) as DAU from prod_games.arcade.appstart a join prod_games.arcade.deviceinfo b on b.userid = a.userid

            where b.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')

            group by 1) a

            join (select a.start_date as date, count(distinct a.userid) as New_users from prod_games.arcade.first_played_date a

            where a.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')

            group by 1) b on b.date = a.date

            join (select a.start_date as cohort_date, dateadd(day,30,a.start_date) as day30 ,count(distinct b.userid) as day30players

            from prod_games.arcade.first_played_date a

            join prod_games.arcade.apprunning b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,30,a.start_date)

            where a.country like 'US' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')

            group by 1) c on c.cohort_date = a.date) f on a.game = f.game and a.date = f.date

 

left join (select 'Arcade' as game, start_date as date, count(distinct userid) as new_user

from prod_games.arcade.first_played_date

where country like 'US'

and userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')

group by 1,2) as h on h.game = a.game and h.date = a.date

);
