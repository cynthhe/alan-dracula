------------------------------ This MUST run after the other ETLs have run. This is my Reporting ETL and requires that the other tables by updated before it is run ------------------------------

--use role <insert role here>
use database prod_games;
use schema matchland;
use warehouse prod_games_01;

------------------------------------------------------------------------------- Matchland Tables -------------------------------------------------------------------------------


---- Retention US
truncate table reporting_proc.Retention_US_proc;
insert into reporting_proc.Retention_US_proc
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
,coalesce(UV_ARPDAU,0) as UV_ARPDAU
,coalesce(UV_ARPPU,0) as UV_ARPPU
,coalesce(purchasers_UV,0) as purchasers
,coalesce((purchasers_UV/DAU),0) as Conversion 
,coalesce(amt_spent_USD_UV,0) as amt_spent_USD


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
      ,g.amt_spent_USD_UV/g.purchasers_UV as UV_ARPPU
      ,g.amt_spent_USD_UV/a.DAU as UV_ARPDAU
      ,g.purchasers_UV
      ,g.amt_spent_USD_UV

      from (select 'CNML' as game, to_date(a.submit_time) as Date, count(distinct a.userid) as DAU from apprunning a  where a.country like 'US' group by 1,2) a
      left join (select 'CNML' as game, DATEADD('DAY', seq, Date) AS Date, count(distinct userid) as WAU
           FROM (select a.submit_time::date as Date, a.userid from apprunning a where a.country like 'US' group by 1,2) A,
                (select seq from (select row_number() over (order by 1 ASC)-1 AS seq from information_schema.columns) where seq < 8) B
          group by DATEADD('DAY', seq, Date)) b on a.game = b.game and a.date = b.date 
      left join (select 'CNML' as game, DATEADD('DAY', seq, Date) AS Date, count(distinct userid) as MAU
           FROM (select distinct to_date(a.submit_time) AS Date, a.userid from apprunning a  where a.country like 'US') A,
                (select seq from (select row_number() over (order by 1 ASC)-1 AS seq from information_schema.columns) where seq < 31) B
          group by DATEADD('DAY', seq, Date)) c on a.game = c.game and a.date = c.date 

      left join (select 'CNML' as game, dateadd(day,1,a.date) as date, coalesce(cast(c.day1players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day1Perc 
                  from (select to_date(a.submit_time) as date, count(distinct a.userid) as DAU from apprunning a where a.country like 'US' group by 1) a
                  join (select a.first_played_date as date, count(distinct a.userid) as New_users from v_first_played_date a join deviceinfo b on b.userid = a.userid where b.country like 'US' group by 1) b on b.date = a.date
                  join (select a.first_played_date as cohort_date, dateadd(day,1,a.first_played_date) as day1 ,count(distinct b.userid) as day1players from v_first_played_date a
                        join apprunning b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,1,a.first_played_date) 
                        where b.country like 'US' group by 1) c on c.cohort_date = a.date) d on a.game = d.game and a.date = d.date 
      left join (select 'CNML' as game, dateadd(day,7,a.date) as date, coalesce(cast(c.day7players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day7Perc 
                  from (select to_date(a.submit_time) as date, count(distinct a.userid) as DAU from apprunning a where a.country like 'US' group by 1) a
                  join (select a.first_played_date as date, count(distinct a.userid) as New_users from v_first_played_date a join deviceinfo b on b.userid = a.userid where b.country like 'US' group by 1) b on b.date = a.date
                  join (select a.first_played_date as cohort_date, dateadd(day,7,a.first_played_date) as day7 ,count(distinct b.userid) as day7players from v_first_played_date a
                        join apprunning b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,7,a.first_played_date) 
                        where b.country like 'US' group by 1) c on c.cohort_date = a.date) e on a.game = e.game and a.date = e.date 
      left join (select 'CNML' as game, dateadd(day,30,a.date) as date, coalesce(cast(c.day30players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day30Perc 
                  from (select to_date(a.submit_time) as date, count(distinct a.userid) as DAU from appstart a join deviceinfo b on b.userid = a.userid where b.country like 'US' group by 1) a
                  join (select a.first_played_date as date, count(distinct a.userid) as New_users from v_first_played_date a join deviceinfo b on b.userid = a.userid where b.country like 'US' group by 1) b on b.date = a.date
                  join (select a.first_played_date as cohort_date, dateadd(day,30,a.first_played_date) as day30 ,count(distinct b.userid) as day30players from v_first_played_date a
                        join apprunning b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,30,a.first_played_date) 
                        where b.country like 'US' group by 1) c on c.cohort_date = a.date) f on a.game = f.game and a.date = f.date 
        
      left join (select 'CNML' as game 
                  ,date
                  ,sum(price) as amt_spent_USD_UV
                  ,count(distinct userid) as purchasers_UV
                  ,count(*) as items_purchased_UV
                  from (select 'CNML' as game, to_date(a.submit_time) as date, a.userid, a.amount as price
                        
                        from matchland.transaction a
                        join matchland.apprunning r on r.userid = a.userid
                        join matchland.IAP b on a.RECEIPT_TRANSACTIONID = b.RECEIPT_TRANSACTIONID and a.AID = b.AID
                        
                        where r.country like 'US' and TRIM(a.userid) <> '' and a.country like 'US'and a.currency like 'USD' and b.valid like 'true'
                       group by 1,2,3,4)
                    group by 1,2)as g on g.game = a.game and g.date = a.date 
                    
        left join (select 'CNML' as game, a.first_played_date as Date, count(distinct a.userid) as new_user 
                   from v_first_played_date a
                   join apprunning b on b.userid = a.userid and b.country like 'US' group by 1,2) as h on h.game = a.game and h.date = a.date 
)
;

------------- Kochava Retention Table
truncate table reporting_proc.retention_US_Kochava_proc;
insert into reporting_proc.retention_US_Kochava_proc
select
Game
,split_part(site, ')', 1) as site
,Date
,new_user
,DAU
,WAU
,MAU
,day1Perc as Day_1
,day7Perc as Day_7
,day30Perc as Day_30
,coalesce(UV_ARPDAU,0) as UV_ARPDAU
,coalesce(UV_ARPPU,0) as UV_ARPPU
,coalesce(purchasers_UV,0) as purchasers_UV
,coalesce((purchasers_UV/DAU),0) as Conversion 
,coalesce(amt_spent_USD_UV,0) as amt_spent_USD_UV


from(select
      a.Game
      ,a.site
      ,a.Date
      ,h.new_user
      ,cast(a.DAU as NUMBER(38,6)) as DAU
      ,cast(b.WAU as NUMBER(38,6)) as WAU
      ,cast(c.MAU as NUMBER(38,6)) as MAU
      ,day1Perc
      ,day7Perc
      ,day30Perc
      ,g.amt_spent_USD_UV/g.purchasers_UV as UV_ARPPU
      ,g.amt_spent_USD_UV/a.DAU as UV_ARPDAU
      ,g.purchasers_UV
      ,g.amt_spent_USD_UV

      from (select 'CNML' as game, to_date(a.submit_time) as Date, split_part(c.site, '(', 2) as site, count(distinct a.userid) as DAU from apprunning a 
            join custom c on c.userid = a.userid where a.country like 'US' and c.name like 'Kochava_player' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP() 
            group by 1,2,3) a
      left join (select 'CNML' as game, DATEADD('DAY', seq, Date) AS Date, site, count(distinct userid) as WAU
             FROM (select distinct to_date(a.submit_time) AS Date, split_part(c.site, '(', 2) as site, a.userid 
                   from apprunning a join custom c on c.userid = a.userid 
                   where a.country like 'US' and c.name like 'Kochava_player' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP() ) A,
                  (select seq from (select row_number() over (order by 1 ASC)-1 AS seq from information_schema.columns) where seq < 8) B  
            group by DATEADD('DAY', seq, Date),a.site) b on b.game = a.game and b.date = a.date and b.site = a.site
      left join (select 'CNML' as game, DATEADD('DAY', seq, Date) AS Date, site, count(distinct userid) as MAU
             FROM (select distinct to_date(a.submit_time) AS Date, split_part(c.site, '(', 2) as site, a.userid 
                   from apprunning a join custom c on c.userid = a.userid 
                   where a.country like 'US' and c.name like 'Kochava_player' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP() ) A,
                  (select seq from (select row_number() over (order by 1 ASC)-1 AS seq from information_schema.columns) where seq < 31) B  
            group by DATEADD('DAY', seq, Date),a.site) c on c.game = a.game and c.date = a.date and c.site = a.site

      left join (select 'CNML' as game, dateadd(day,1,a.date) as date, a.site, coalesce(cast(c.day1players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day1Perc 
                  from (select to_date(a.submit_time) as date, split_part(c.site, '(', 2) as site, count(distinct a.userid) as DAU 
                        from apprunning a join custom c on c.userid = a.userid 
                        where a.country like 'US' and c.name like 'Kochava_player' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP()  group by 1,2) a
                  join (select a.first_played_date as date, split_part(c.site, '(', 2) as site, count(distinct a.userid) as New_users 
                        from v_first_played_date a join deviceinfo b on b.userid = a.userid join custom c on c.userid = a.userid 
                        where b.country like 'US' and c.name like 'Kochava_player' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP()  group by 1,2) b on b.date = a.date and b.site = a.site
                  join (select a.first_played_date as cohort_date, dateadd(day,1,a.first_played_date) as day1, split_part(d.site, '(', 2) as site ,count(distinct b.userid) as day1players 
                        from v_first_played_date a join apprunning b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,1,a.first_played_date)  
                        join custom d on d.userid = a.userid where b.country like 'US' and d.name like 'Kochava_player' and d.submit_time between '8/9/2018' and CURRENT_TIMESTAMP() 
                        group by 1,d.site) c on c.cohort_date = a.date and c.site = a.site) d on d.game = a.game and d.date = a.date and d.site = a.site
      
     left join (select 'CNML' as game, dateadd(day,7,a.date) as date, a.site, coalesce(cast(c.day7players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day7Perc 
                  from (select to_date(a.submit_time) as date, split_part(c.site, '(', 2) as site, count(distinct a.userid) as DAU 
                        from apprunning a join custom c on c.userid = a.userid 
                        where a.country like 'US' and c.name like 'Kochava_player' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP()  group by 1,2) a
                  join (select a.first_played_date as date, split_part(c.site, '(', 2) as site, count(distinct a.userid) as New_users 
                        from v_first_played_date a join deviceinfo b on b.userid = a.userid join custom c on c.userid = a.userid 
                        where b.country like 'US' and c.name like 'Kochava_player' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP()  group by 1,2) b on b.date = a.date and b.site = a.site
                  join (select a.first_played_date as cohort_date, dateadd(day,7,a.first_played_date) as day7, split_part(d.site, '(', 2) as site ,count(distinct b.userid) as day7players 
                        from v_first_played_date a join apprunning b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,7,a.first_played_date) 
                        join custom d on d.userid = a.userid where b.country like 'US' and d.name like 'Kochava_player' and d.submit_time between '8/9/2018' and CURRENT_TIMESTAMP() 
                        group by 1,d.site) c on c.cohort_date = a.date and c.site = a.site) e on e.game = a.game and e.date = a.date and e.site = a.site
      
     left join (select 'CNML' as game, dateadd(day,30,a.date) as date, a.site, coalesce(cast(c.day30players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day30Perc 
                  from (select to_date(a.submit_time) as date, split_part(c.site, '(', 2) as site, count(distinct a.userid) as DAU 
                        from apprunning a join custom c on c.userid = a.userid 
                        where a.country like 'US' and c.name like 'Kochava_player' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP()  group by 1,2) a
                  join (select a.first_played_date as date, split_part(c.site, '(', 2) as site, count(distinct a.userid) as New_users 
                        from v_first_played_date a join deviceinfo b on b.userid = a.userid join custom c on c.userid = a.userid 
                        where b.country like 'US' and c.name like 'Kochava_player' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP()  group by 1,2) b on b.date = a.date and b.site = a.site
                  join (select a.first_played_date as cohort_date, dateadd(day,7,a.first_played_date) as day30, split_part(d.site, '(', 2) as site ,count(distinct b.userid) as day30players 
                        from v_first_played_date a join apprunning b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,30,a.first_played_date)  
                        join custom d on d.userid = a.userid where b.country like 'US' and d.name like 'Kochava_player' and d.submit_time between '8/9/2018' and CURRENT_TIMESTAMP()  
                        group by 1,d.site) c on c.cohort_date = a.date and c.site = a.site) f on f.game = a.game and f.date = a.date and f.site = a.site
        
      left join (select 'CNML' as game, site ,date ,sum(price) as amt_spent_USD_UV ,count(distinct userid) as purchasers_UV 
                  from (select 'CNML' as game, to_date(a.submit_time) as date, a.userid, split_part(c.site, '(', 2) as site, a.productid, a.amount as price
                       
                        from matchland.transaction a 
                        join matchland.custom c on c.userid = a.userid 
                        join matchland.apprunning b on b.userid = a.userid
                        join matchland.IAP d on a.RECEIPT_TRANSACTIONID = d.RECEIPT_TRANSACTIONID and a.AID = d.AID
                        where b.country like 'US' and a.country like 'US' and c.name like 'Kochava_player' and TRIM(a.userid) <> '' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP() 
                        and a.currency like 'USD' and d.valid like 'true'
                        group by 1,2,3,4,5,6 order by date
                       )
                    group by 1,2,3)as g on g.game = a.game and g.date = a.date and g.site = a.site
     
        left join (select 'CNML' as game, c.submit_time::date as Date, split_part(c.site, '(', 2) as site, count(distinct a.userid) as new_user from v_first_played_date a join apprunning b on b.userid = a.userid 
                   join custom c on c.userid = a.userid where b.country like 'US' and c.name like 'Kochava_player' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP() group by 1,2,3) as h on h.game = a.game and h.date = a.date and h.site = a.site
        
        left join (select 'CNML' as game, a.FIRST_PLAYED_DATE as date, split_part(b.site, '(', 2) as site, count(distinct a.userid) as acquired_users 
                   from V_FIRST_PLAYED_DATE a 
                   join custom b on b.userid = a.userid 
                    where b.site like '%V2%' and a.FIRST_PLAYED_DATE between '10/16/2018' and '11/24/2018' group by 1,2,3) i on i.game = a.game and i.date = a.date and i.site = a.site
    )

where site is not null and site not like '' and site not like '1'
order by amt_spent_USD_UV desc;

------------- Sessions Table
truncate table reporting_proc.sessions_us_proc; 
insert into reporting_proc.sessions_us_proc 
select
'CNML' as Game
,date
,count(distinct userid) as users
,count(distinct sessionid) as sessions
,sum(diff) as minInSession
,sum(diff) / count(distinct sessionid) as avgTimeInSession
,count(distinct sessionid)/count(distinct userid) as avgSessionsPerUser

from (select userid, sessionid, minst::Date as date, datediff(min,minst,maxst) as diff
      from(select a.userid, a.sessionid, min(a.submit_time) as minst, max(a.submit_time) as maxst
            from appRunning a where a.country like 'US'
            group by 1,2
           ))
group by 1,2;

---------- Kochava Sessions
truncate table reporting_proc.sessions_us_Kochava_proc;
insert into reporting_proc.sessions_us_Kochava_proc
select
'CNML' as Game
,site
,date
,count(distinct userid) as users
,count(distinct sessionid) as sessions
,sum(diff) as minInSession
,sum(diff) / count(distinct sessionid) as avgTimeInSession
,count(distinct sessionid)/count(distinct userid) as avgSessionsPerUser

from (select split_part(site, ')', 1) as site, userid, sessionid, minst::Date as date, datediff(min,minst,maxst) as diff
      from(select  split_part(b.site, '(', 2) as site, a.userid, a.sessionid, min(a.submit_time) as minst, max(a.submit_time) as maxst
            from appRunning a
            join custom b on b.userid = a.userid 
           where name like 'Kochava_player' and b.site is not null and b.site not like '1'
            group by 1,2,3
           )) 
group by 1,2,3;

------------------------------------------------------------------------------- TTGF Tables -------------------------------------------------------------------------------
use schema TTGF;

insert into "PROD_GAMES"."REPORTING_PROC"."RETENTION_US_PROC"
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
,coalesce(UV_ARPDAU,0) as UV_ARPDAU
,coalesce(UV_ARPPU,0) as UV_ARPPU
,coalesce(purchasers_UV,0) as purchasers_UV
,coalesce((purchasers_UV/DAU),0) as Conversion 
,coalesce(amt_spent_USD_UV,0) as amt_spent_USD_UV


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
      ,g.amt_spent_USD_UV/g.purchasers_UV as UV_ARPPU
      ,g.amt_spent_USD_UV/a.DAU as UV_ARPDAU
      ,g.purchasers_UV
      ,g.amt_spent_USD_UV

      from (select 'TTGF' as game, to_date(a.submit_time) as Date, count(distinct a.userid) as DAU from apprunning a  where a.country like 'US' group by 1,2) a
      left join (select 'TTGF' as game, DATEADD('DAY', seq, Date) AS Date, count(distinct userid) as WAU
             FROM (select distinct to_date(a.submit_time) AS Date, a.userid from apprunning a where a.country like 'US') A,
                  (select seq from (select row_number() over (order by 1 ASC)-1 AS seq from information_schema.columns) where seq < 8) B  
            group by DATEADD('DAY', seq, Date)) b on a.game = b.game and a.date = b.date 
      left join (select 'TTGF' as game, DATEADD('DAY', seq, Date) AS Date, count(distinct userid) as MAU
             FROM (select distinct to_date(a.submit_time) AS Date, a.userid from apprunning a where a.country like 'US') A,
                  (select seq from (select row_number() over (order by 1 ASC)-1 AS seq from information_schema.columns) where seq < 31) B  
            group by DATEADD('DAY', seq, Date)) c on a.game = c.game and a.date = c.date 

      left join (select 'TTGF' as game, dateadd(day,1,a.date) as date, coalesce(cast(c.day1players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day1Perc 
                  from (select to_date(a.submit_time) as date, count(distinct a.userid) as DAU from apprunning a where a.country like 'US' group by 1) a
                  join (select a.first_played_date as date, count(distinct a.userid) as New_users from v_first_played_date a join deviceinfo b on b.userid = a.userid where b.country like 'US' group by 1) b on b.date = a.date
                  join (select a.first_played_date as cohort_date, dateadd(day,1,a.first_played_date) as day1 ,count(distinct b.userid) as day1players from v_first_played_date a
                        join apprunning b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,1,a.first_played_date) 
                        where b.country like 'US' group by 1) c on c.cohort_date = a.date) d on a.game = d.game and a.date = d.date 
      left join (select 'TTGF' as game, dateadd(day,7,a.date) as date, coalesce(cast(c.day7players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day7Perc 
                  from (select to_date(a.submit_time) as date, count(distinct a.userid) as DAU from apprunning a where a.country like 'US' group by 1) a
                  join (select a.first_played_date as date, count(distinct a.userid) as New_users from v_first_played_date a join deviceinfo b on b.userid = a.userid where b.country like 'US' group by 1) b on b.date = a.date
                  join (select a.first_played_date as cohort_date, dateadd(day,7,a.first_played_date) as day7 ,count(distinct b.userid) as day7players from v_first_played_date a
                        join apprunning b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,7,a.first_played_date) 
                        where b.country like 'US' group by 1) c on c.cohort_date = a.date) e on a.game = e.game and a.date = e.date 
      left join (select 'TTGF' as game, dateadd(day,30,a.date) as date, coalesce(cast(c.day30players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day30Perc 
                  from (select to_date(a.submit_time) as date, count(distinct a.userid) as DAU from apprunning a where a.country like 'US' group by 1) a
                  join (select a.first_played_date as date, count(distinct a.userid) as New_users from v_first_played_date a join deviceinfo b on b.userid = a.userid where b.country like 'US' group by 1) b on b.date = a.date
                  join (select a.first_played_date as cohort_date, dateadd(day,30,a.first_played_date) as day30 ,count(distinct b.userid) as day30players from v_first_played_date a
                        join apprunning b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,30,a.first_played_date) 
                        where b.country like 'US' group by 1) c on c.cohort_date = a.date) f on a.game = f.game and a.date = f.date 
        
      left join (select 'TTGF' as game 
                  ,date
                  ,sum(price) as amt_spent_USD_UV
                  ,count(distinct userid) as purchasers_UV
                  ,count(*) as items_purchased_UV
                  from (select 'CNML' as game
                        ,to_date(submit_time) as date
                        ,userid 
                        ,case when productid like 'com.turner.ttgfigures2.eggs.2' then 'Eggs_2'
                          when productid like 'com.turner.ttgfigures2.eggs.5' then 'Eggs_5'
                          when productid like 'com.turner.ttgfigures2.figures.tier1' then 'Figure'
                          when productid like 'com.turner.ttgfigures2.goldeneggs.5' then 'Golden_eggs_5'
                          when productid like 'com.turner.ttgfigures2.repainttokens.10' then 'Repaint_token_10'
                          when productid like 'com.turner.ttgfigures2.repainttokens.30' then 'Repaint_token_30'                        
                          when productid like 'com.turner.ttgfigures2.repainttokens.50' then 'Repaint_token_50'                       
                          else 'wrong' end as item
                        ,case when productid like 'com.turner.ttgfigures2.eggs.2' and amount = 1.99 then amount
                          when productid like 'com.turner.ttgfigures2.eggs.5' and amount = 3.99 then amount
                          when productid like 'com.turner.ttgfigures2.figures.tier1' and amount = 2.99 then amount
                          when productid like 'com.turner.ttgfigures2.goldeneggs.5' and amount = 9.99 then amount
                          when productid like 'com.turner.ttgfigures2.repainttokens.10' and amount = 0.99 then amount
                          when productid like 'com.turner.ttgfigures2.repainttokens.30' and amount = 1.99 then amount
                          when productid like 'com.turner.ttgfigures2.repainttokens.50' and amount = 2.99 then amount
                          else 0 end as price
                        from transaction where userid not like '' and country like 'US')
                    group by 1,2)as g on g.game = a.game and g.date = a.date 
                    
        left join (select 'TTGF' as game, a.first_played_date as Date, count(distinct a.userid) as new_user 
                   from v_first_played_date a
                   join apprunning b on b.userid = a.userid and b.country like 'US' group by 1,2) as h on h.game = a.game and h.date = a.date 
)
;

------------------- Session
insert into "PROD_GAMES"."REPORTING_PROC"."SESSIONS_US_PROC"
select
'TTGF' as Game
,date
,count(distinct userid) as users
,count(distinct sessionid) as sessions
,sum(diff) as minInSession
,sum(diff) / count(distinct sessionid) as avgTimeInSession
,count(distinct sessionid)/count(distinct userid) as avgSessionsPerUser

from (select userid, sessionid, minst::Date as date, datediff(min,minst,maxst) as diff
      from(select a.userid, a.sessionid, min(a.submit_time) as minst, max(a.submit_time) as maxst
            from appRunning a
            group by 1,2
           )) 
group by 1,2;

------------------------------------------------------------------------------- Party Dash Tables -------------------------------------------------------------------------------

use schema party_dash;
insert into prod_games.reporting_proc.Retention_US_proc
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
,coalesce(UV_ARPDAU,0) as UV_ARPDAU
,coalesce(UV_ARPPU,0) as UV_ARPPU
,coalesce(purchasers_UV,0) as purchasers_UV
,coalesce((purchasers_UV/DAU),0) as Conversion 
,coalesce(amt_spent_USD_UV,0) as amt_spent_USD_UV


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
      ,g.amt_spent_USD_UV/g.purchasers_UV as UV_ARPPU
      ,g.amt_spent_USD_UV/a.DAU as UV_ARPDAU
      ,g.purchasers_UV
      ,g.amt_spent_USD_UV

      from (select 'PD' as game, to_date(a.submit_time) as Date, count(distinct a.userid) as DAU from apprunning a where a.country like 'US' group by 1,2) a
      left join (select 'PD' as game, DATEADD('DAY', seq, Date) AS Date, count(distinct userid) as WAU
             FROM (select distinct to_date(a.submit_time) AS Date, a.userid from apprunning a where a.country like 'US') A,
                  (select seq from (select row_number() over (order by 1 ASC)-1 AS seq from information_schema.columns) where seq < 8) B  
            group by DATEADD('DAY', seq, Date)) b on a.game = b.game and a.date = b.date 
      left join (select 'PD' as game, DATEADD('DAY', seq, Date) AS Date, count(distinct userid) as MAU
             FROM (select distinct to_date(a.submit_time) AS Date, a.userid from apprunning a where a.country like 'US') A,
                  (select seq from (select row_number() over (order by 1 ASC)-1 AS seq from information_schema.columns) where seq < 31) B  
            group by DATEADD('DAY', seq, Date)) c on a.game = c.game and a.date = c.date 

      left join (select 'PD' as game, dateadd(day,1,a.date) as date, coalesce(cast(c.day1players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day1Perc 
                  from (select to_date(a.submit_time) as date, count(distinct a.userid) as DAU from apprunning a where a.country like 'US' group by 1) a
                  join (select a.first_played_date as date, count(distinct a.userid) as New_users from v_first_played_date a join deviceinfo b on b.userid = a.userid where b.country like 'US' group by 1) b on b.date = a.date
                  join (select a.first_played_date as cohort_date, dateadd(day,1,a.first_played_date) as day1 ,count(distinct b.userid) as day1players from v_first_played_date a
                        join apprunning b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,1,a.first_played_date) 
                        where b.country like 'US' group by 1) c on c.cohort_date = a.date) d on a.game = d.game and a.date = d.date 
      left join (select 'PD' as game, dateadd(day,7,a.date) as date, coalesce(cast(c.day7players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day7Perc 
                  from (select to_date(a.submit_time) as date, count(distinct a.userid) as DAU from apprunning a where a.country like 'US' group by 1) a
                  join (select a.first_played_date as date, count(distinct a.userid) as New_users from v_first_played_date a join deviceinfo b on b.userid = a.userid where b.country like 'US' group by 1) b on b.date = a.date
                  join (select a.first_played_date as cohort_date, dateadd(day,7,a.first_played_date) as day7 ,count(distinct b.userid) as day7players from v_first_played_date a
                        join apprunning b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,7,a.first_played_date) 
                        where b.country like 'US' group by 1) c on c.cohort_date = a.date) e on a.game = e.game and a.date = e.date 
      left join (select 'PD' as game, dateadd(day,30,a.date) as date, coalesce(cast(c.day30players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day30Perc 
                  from (select to_date(a.submit_time) as date, count(distinct a.userid) as DAU from apprunning a where a.country like 'US' group by 1) a
                  join (select a.first_played_date as date, count(distinct a.userid) as New_users from v_first_played_date a join deviceinfo b on b.userid = a.userid where b.country like 'US' group by 1) b on b.date = a.date
                  join (select a.first_played_date as cohort_date, dateadd(day,30,a.first_played_date) as day30 ,count(distinct b.userid) as day30players from v_first_played_date a
                        join apprunning b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,30,a.first_played_date) 
                        where b.country like 'US' group by 1) c on c.cohort_date = a.date) f on a.game = f.game and a.date = f.date 
        
      left join (select 'PD' as game 
                  ,date
                  ,sum(price) as amt_spent_USD_UV
                  ,count(distinct userid) as purchasers_UV
                  ,count(*) as items_purchased_UV
                  from (select 'PD' as game, to_date(a.submit_time) as date, a.userid, a.amount as price
                        
                        from matchland.transaction a
                        join matchland.apprunning r on r.userid = a.userid
                        join matchland.IAP b on a.RECEIPT_TRANSACTIONID = b.RECEIPT_TRANSACTIONID and a.aid=b.aid
                        
                        where r.country like 'US' and TRIM(a.userid) <> '' and a.country like 'US'and a.currency like 'USD'
                       group by 1,2,3,4)
                    group by 1,2)as g on g.game = a.game and g.date = a.date 
                    
        left join (select 'PD' as game, a.first_played_date as Date, count(distinct a.userid) as new_user 
                   from v_first_played_date a
                   join apprunning b on b.userid = a.userid and b.country like 'US' group by 1,2) as h on h.game = a.game and h.date = a.date 
)
;

------------- Kochava Retention Table
insert into prod_games.reporting_proc.retention_US_Kochava_proc
select
Game
,split_part(site, ')', 1) as site
,Date
,new_user
,DAU
,WAU
,MAU
,day1Perc as Day_1 
,day7Perc as Day_7
,day30Perc as Day_30
,coalesce(UV_ARPDAU,0) as UV_ARPDAU
,coalesce(UV_ARPPU,0) as UV_ARPPU
,coalesce(purchasers_UV,0) as purchasers_UV
,coalesce((purchasers_UV/DAU),0) as Conversion 
,coalesce(amt_spent_USD_UV,0) as amt_spent_USD_UV


from(select
      a.Game
      ,split_part(a.site, '(', 2) as site
      ,a.Date
      ,h.new_user
      ,cast(a.DAU as NUMBER(38,6)) as DAU
      ,cast(b.WAU as NUMBER(38,6)) as WAU
      ,cast(c.MAU as NUMBER(38,6)) as MAU
      ,day1Perc
      ,day7Perc
      ,day30Perc
      ,g.amt_spent_USD_UV/g.purchasers_UV as UV_ARPPU
      ,g.amt_spent_USD_UV/a.DAU as UV_ARPDAU
      ,g.purchasers_UV
      ,g.amt_spent_USD_UV

      from (select 'PD' as game, to_date(a.submit_time) as Date, c.site, count(distinct a.userid) as DAU from apprunning a 
            join custom c on c.userid = a.userid where a.country like 'US' and c.name like 'Kochava_player' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP() 
            group by 1,2,3) a
      left join (select 'PD' as game, DATEADD('DAY', seq, Date) AS Date, site, count(distinct userid) as WAU
             FROM (select distinct to_date(a.submit_time) AS Date, c.site, a.userid 
                   from apprunning a join custom c on c.userid = a.userid 
                   where a.country like 'US' and c.name like 'Kochava_player' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP() ) A,
                  (select seq from (select row_number() over (order by 1 ASC)-1 AS seq from information_schema.columns) where seq < 8) B  
            group by DATEADD('DAY', seq, Date),a.site) b on a.game = b.game and a.date = b.date and a.site = b.site
      left join (select 'PD' as game, DATEADD('DAY', seq, Date) AS Date, site, count(distinct userid) as MAU
             FROM (select distinct to_date(a.submit_time) AS Date, c.site, a.userid 
                   from appstart a join deviceinfo b on b.userid = a.userid join custom c on c.userid = a.userid 
                   where b.country like 'US' and c.name like 'Kochava_player' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP() ) A,
                  (select seq from (select row_number() over (order by 1 ASC)-1 AS seq from information_schema.columns) where seq < 31) B  
            group by DATEADD('DAY', seq, Date),a.site) c on a.game = c.game and a.date = c.date and a.site = c.site

      left join (select 'PD' as game, dateadd(day,1,a.date) as date, a.site, coalesce(cast(c.day1players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day1Perc 
                  from (select to_date(a.submit_time) as date, c.site, count(distinct a.userid) as DAU 
                        from appstart a join deviceinfo b on b.userid = a.userid join custom c on c.userid = a.userid 
                        where b.country like 'US' and c.name like 'Kochava_player' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP()  group by 1,2) a
                  join (select a.first_played_date as date, c.site, count(distinct a.userid) as New_users 
                        from v_first_played_date a join deviceinfo b on b.userid = a.userid join custom c on c.userid = a.userid 
                        where b.country like 'US' and c.name like 'Kochava_player' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP()  group by 1,2) b on b.date = a.date and b.site = a.site
                  join (select a.first_played_date as cohort_date, dateadd(day,1,a.first_played_date) as day1, d.site ,count(distinct b.userid) as day1players 
                        from v_first_played_date a join appstart b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,1,a.first_played_date) join deviceinfo c on c.userid = a.userid 
                        join custom d on d.userid = a.userid where c.country like 'US' and d.name like 'Kochava_player' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP() 
                        group by 1,d.site) c on c.cohort_date = a.date and c.site = a.site) d on a.game = d.game and a.date = d.date and a.site = d.site
      
     left join (select 'PD' as game, dateadd(day,7,a.date) as date, a.site, coalesce(cast(c.day7players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day7Perc 
                  from (select to_date(a.submit_time) as date, c.site, count(distinct a.userid) as DAU 
                        from appstart a join deviceinfo b on b.userid = a.userid join custom c on c.userid = a.userid 
                        where b.country like 'US' and c.name like 'Kochava_player' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP()  group by 1,2) a
                  join (select a.first_played_date as date, c.site, count(distinct a.userid) as New_users 
                        from v_first_played_date a join deviceinfo b on b.userid = a.userid join custom c on c.userid = a.userid 
                        where b.country like 'US' and c.name like 'Kochava_player' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP()  group by 1,2) b on b.date = a.date and b.site = a.site
                  join (select a.first_played_date as cohort_date, dateadd(day,7,a.first_played_date) as day7, d.site ,count(distinct b.userid) as day7players 
                        from v_first_played_date a join appstart b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,7,a.first_played_date) join deviceinfo c on c.userid = a.userid 
                        join custom d on d.userid = a.userid where c.country like 'US' and d.name like 'Kochava_player' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP() 
                        group by 1,d.site) c on c.cohort_date = a.date and c.site = a.site) e on a.game = e.game and a.date = e.date and a.site = e.site
      
     left join (select 'PD' as game, dateadd(day,30,a.date) as date, a.site, coalesce(cast(c.day30players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day30Perc 
                  from (select to_date(a.submit_time) as date, c.site, count(distinct a.userid) as DAU 
                        from appstart a join deviceinfo b on b.userid = a.userid join custom c on c.userid = a.userid 
                        where b.country like 'US' and c.name like 'Kochava_player' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP()  group by 1,2) a
                  join (select a.first_played_date as date, c.site, count(distinct a.userid) as New_users 
                        from v_first_played_date a join deviceinfo b on b.userid = a.userid join custom c on c.userid = a.userid 
                        where b.country like 'US' and c.name like 'Kochava_player' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP()  group by 1,2) b on b.date = a.date and b.site = a.site
                  join (select a.first_played_date as cohort_date, dateadd(day,7,a.first_played_date) as day30, d.site ,count(distinct b.userid) as day30players 
                        from v_first_played_date a join appstart b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,30,a.first_played_date) join deviceinfo c on c.userid = a.userid 
                        join custom d on d.userid = a.userid where c.country like 'US' and d.name like 'Kochava_player' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP()  
                        group by 1,d.site) c on c.cohort_date = a.date and c.site = a.site) f on a.game = f.game and a.date = f.date and a.site = f.site
        
      left join (select 'PD' as game, site ,date ,sum(price) as amt_spent_USD_UV ,count(distinct userid) as purchasers_UV 
                  from (select 'PD' as game, to_date(a.submit_time) as date, a.userid, c.site, a.productid, a.amount as price
                       
                        from matchland.transaction a 
                        join matchland.custom c on c.userid = a.userid 
                        join matchland.apprunning b on b.userid = a.userid
                        join matchland.IAP d on a.RECEIPT_TRANSACTIONID = d.RECEIPT_TRANSACTIONID and a.aid=d.aid
                        where b.country like 'US' and a.country like 'US' and c.name like 'Kochava_player' and TRIM(a.userid) <> '' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP() 
                        and a.currency like 'USD'
                        group by 1,2,3,4,5,6 order by date
                       )
                    group by 1,2,3)as g on g.game = a.game and g.date = a.date and a.site = g.site
     
     
        left join (select 'PD' as game, c.submit_time::date as Date, c.site, count(distinct a.userid) as new_user from v_first_played_date a join apprunning b on b.userid = a.userid 
                   join custom c on c.userid = a.userid where b.country like 'US' and c.name like 'Kochava_player' and c.submit_time between '8/9/2018' and CURRENT_TIMESTAMP() group by 1,2,3) as h on h.game = a.game and h.date = a.date and a.site = h.site
)
where site is not null and site not like '' and site not like '1'
order by date;

------------- Sessions Table
insert into prod_games.reporting_proc.sessions_us_proc 
select
'PD' as Game
,date
,count(distinct userid) as users
,count(distinct sessionid) as sessions
,sum(diff) as minInSession
,sum(diff) / count(distinct sessionid) as avgTimeInSession
,count(distinct sessionid)/count(distinct userid) as avgSessionsPerUser

from (select userid, sessionid, minst::Date as date, datediff(min,minst,maxst) as diff
      from(select a.userid, a.sessionid, min(a.submit_time) as minst, max(a.submit_time) as maxst
            from appRunning a where a.country like 'US'
            group by 1,2
           ))
group by 1,2;

---------- Kochava Sessions
insert into prod_games.reporting_proc.sessions_us_Kochava_proc
select
'PD' as Game
,site
,date
,count(distinct userid) as users
,count(distinct sessionid) as sessions
,sum(diff) as minInSession
,sum(diff) / count(distinct sessionid) as avgTimeInSession
,count(distinct sessionid)/count(distinct userid) as avgSessionsPerUser

from (select split_part(site, ')', 1) as site, userid, sessionid, minst::Date as date, datediff(min,minst,maxst) as diff
      from(select  split_part(b.site, '(', 2) as site, a.userid, a.sessionid, min(a.submit_time) as minst, max(a.submit_time) as maxst
            from appRunning a
            join custom b on b.userid = a.userid 
           where name like 'Kochava_player' and b.site is not null and b.site not like '1'
            group by 1,2,3
           ))
group by 1,2,3;

------------------------------------------------------------------------------- Inserting Into Tables -------------------------------------------------------------------------------
use database prod_games;
truncate reporting.RETENTION_US;
insert into reporting.RETENTION_US
select * from reporting_proc.RETENTION_US_PROC;

truncate reporting.RETENTION_US_KOCHAVA;
insert into reporting.RETENTION_US_KOCHAVA
select * from reporting_proc.RETENTION_US_KOCHAVA_PROC;

truncate table reporting.SESSIONS_US;
insert into reporting.SESSIONS_US
select * from reporting_proc.SESSIONS_US_PROC;

truncate table reporting.SESSIONS_US_KOCHAVA;
insert into reporting.SESSIONS_US_KOCHAVA
select * from reporting_proc.SESSIONS_US_KOCHAVA_PROC;

------------------------------------------------------------------------------- Arcade Reporting -------------------------------------------------------------------------------
Use Schema Arcade;

truncate prod_games.reporting.ARCADE_RETENTION_US_BY_GAME_table;
insert into prod_games.reporting.ARCADE_RETENTION_US_BY_GAME_table
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

truncate table prod_games.reporting.RETENTION_US_ARCADE_Table;
insert into prod_games.reporting.RETENTION_US_ARCADE_Table 
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

truncate table prod_games.arcade.arcade_time_in_game_old;
insert into prod_games.arcade.arcade_time_in_game_old 
select
a.date
,a.userid
,a.sessionid
,a.game_session_id
,a.app_location
,datediff(s,a.start_time,a.end_times) as seconds_in_game 
,b.platform
,case when c.userid is not null then 'Yes' else 'No' end as registered
from(
select
date
,userid
,sessionid
,game_session_id
,app_location
,start_time
,case when end_time is null then end_time_2 else end_time end as end_times
from(select 
a.date
,a.userid
,a.sessionid
,a.GAME_SESSION_ID
,a.app_location
,b.datetime as start_time
,c.datetime as end_time
,d.datetime as end_time_2

from (select 
date
,userid
,sessionid
,GAME_SESSION_ID
,app_location
,min(rank) as start_rank
,max(rank) as end_rank

from prod_games.arcade.ranking_for_timeingame 
where game_session_id is not null
group by 1,2,3,4,5
order by userid) a
left join prod_games.arcade.ranking_for_timeingame b on b.sessionid = a.sessionid and b.rank = a.start_rank
left join prod_games.arcade.ranking_for_timeingame c on c.sessionid = a.sessionid and c.rank = a.end_rank+1
left join prod_games.arcade.ranking_for_timeingame d on d.sessionid = a.sessionid and d.rank = a.end_rank
group by 1,2,3,4,5,6,7,8
order by GAME_SESSION_ID)
group by 1,2,3,4,5,6,7)a
join prod_games.arcade.apprunning b on b.userid = a.userid
left join prod_games.arcade.REGISTERED c on c.userid = a.userid
group by 1,2,3,4,5,6,7,8;

truncate prod_games.reporting.RETENTION_US_ARCADE_ANDROID_TABLE;
insert into prod_games.reporting.RETENTION_US_ARCADE_ANDROID_TABLE
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
            where a.country like 'US' and a.platform like 'AndroidPlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019') group by 1,2) a
      left join (select 'Arcade' as game, DATEADD('DAY', seq, Date) AS Date, count(distinct userid) as WAU
                 FROM (select distinct to_date(a.submit_time) AS Date, a.userid from prod_games.arcade.apprunning a 
                       where a.country like 'US' and a.platform like 'AndroidPlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')) A,
                      (select seq from (select row_number() over (order by 1 ASC)-1 AS seq from information_schema.columns) where seq < 8) B
                 group by DATEADD('DAY', seq, Date)) b on a.game = b.game and a.date = b.date 
      left join (select 'Arcade' as game, DATEADD('DAY', seq, Date) AS Date, count(distinct userid) as MAU
                 FROM (select distinct to_date(a.submit_time) AS Date, a.userid from prod_games.arcade.apprunning a  
                       where a.country like 'US' and a.platform like 'AndroidPlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')) A,
                      (select seq from (select row_number() over (order by 1 ASC)-1 AS seq from information_schema.columns) where seq < 31) B
                 group by DATEADD('DAY', seq, Date)) c on a.game = c.game and a.date = c.date 

      left join (select 'Arcade' as game, dateadd(day,1,a.date) as date, coalesce(cast(c.day1players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day1Perc 
                  from (select to_date(a.submit_time) as date, count(distinct a.userid) as DAU from prod_games.arcade.apprunning a  
                        where a.country like 'US' and a.platform like 'AndroidPlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1) a
                  join (select a.start_date as date, count(distinct a.userid) as New_users from prod_games.arcade.first_played_date a 
                        where a.country like 'US' and a.platform like 'AndroidPlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1) b on b.date = a.date
                  join (select a.start_date as cohort_date, dateadd(day,1,a.start_date) as day1 ,count(distinct b.userid) as day1players 
                        from prod_games.arcade.first_played_date a
                        join prod_games.arcade.apprunning b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,1,a.start_date) 
                        where a.country like 'US' and a.platform like 'AndroidPlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1) c on c.cohort_date = a.date) d on a.game = d.game and a.date = d.date 
      
     left join (select 'Arcade' as game, dateadd(day,7,a.date) as date, coalesce(cast(c.day7players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day7Perc 
                  from (select to_date(a.submit_time) as date, count(distinct a.userid) as DAU from prod_games.arcade.apprunning a  
                        where a.country like 'US' and a.platform like 'AndroidPlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1) a
                  join (select a.start_date as date, count(distinct a.userid) as New_users from prod_games.arcade.first_played_date a 
                        where a.country like 'US' and a.platform like 'AndroidPlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1) b on b.date = a.date
                  join (select a.start_date as cohort_date, dateadd(day,7,a.start_date) as day7 ,count(distinct b.userid) as day7players 
                        from prod_games.arcade.first_played_date a
                        join prod_games.arcade.apprunning b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,7,a.start_date) 
                        where a.country like 'US'and a.platform like 'AndroidPlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1) c on c.cohort_date = a.date) e on a.game = e.game and a.date = e.date 
      
      left join (select 'Arcade' as game, dateadd(day,30,a.date) as date, coalesce(cast(c.day30players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day30Perc 
                  from (select to_date(a.submit_time) as date, count(distinct a.userid) as DAU from prod_games.arcade.apprunning a  
                        where a.country like 'US' and a.platform like 'AndroidPlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1) a
                  join (select a.start_date as date, count(distinct a.userid) as New_users from prod_games.arcade.first_played_date a 
                        where a.country like 'US'and a.platform like 'AndroidPlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1) b on b.date = a.date
                  join (select a.start_date as cohort_date, dateadd(day,30,a.start_date) as day30 ,count(distinct b.userid) as day30players 
                        from prod_games.arcade.first_played_date a
                        join prod_games.arcade.apprunning b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,30,a.start_date) 
                        where a.country like 'US'and a.platform like 'AndroidPlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1) c on c.cohort_date = a.date) f on a.game = f.game and a.date = f.date 
                    
        left join (select 'Arcade' as game, start_date as date, count(distinct userid) as new_user 
                   from prod_games.arcade.first_played_date 
                   where country like 'US' and platform like 'AndroidPlayer' 
                   and userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                   group by 1,2) as h on h.game = a.game and h.date = a.date 
);


---------------------------------------/////////////////////////////////////////////////------------------------------------
truncate prod_games.reporting.RETENTION_US_ARCADE_IOS_table;
insert into prod_games.reporting.RETENTION_US_ARCADE_IOS_TABLE
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
            where a.country like 'US' and a.platform like 'iPhonePlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019') group by 1,2) a
      left join (select 'Arcade' as game, DATEADD('DAY', seq, Date) AS Date, count(distinct userid) as WAU
                 FROM (select distinct to_date(a.submit_time) AS Date, a.userid from prod_games.arcade.apprunning a  
                       where a.country like 'US' and a.platform like 'iPhonePlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')) A,
                      (select seq from (select row_number() over (order by 1 ASC)-1 AS seq from information_schema.columns) where seq < 8) B
                 group by DATEADD('DAY', seq, Date)) b on a.game = b.game and a.date = b.date 
      left join (select 'Arcade' as game, DATEADD('DAY', seq, Date) AS Date, count(distinct userid) as MAU
                 FROM (select distinct to_date(a.submit_time) AS Date, a.userid from prod_games.arcade.apprunning a  
                       where a.country like 'US' and a.platform like 'iPhonePlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')) A,
                      (select seq from (select row_number() over (order by 1 ASC)-1 AS seq from information_schema.columns) where seq < 31) B
                 group by DATEADD('DAY', seq, Date)) c on a.game = c.game and a.date = c.date 

      left join (select 'Arcade' as game, dateadd(day,1,a.date) as date, coalesce(cast(c.day1players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day1Perc 
                  from (select to_date(a.submit_time) as date, count(distinct a.userid) as DAU from prod_games.arcade.apprunning a  
                        where a.country like 'US' and a.platform like 'iPhonePlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1) a
                  join (select a.start_date as date, count(distinct a.userid) as New_users from prod_games.arcade.first_played_date a 
                        where a.country like 'US' and a.platform like 'iPhonePlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1) b on b.date = a.date
                  join (select a.start_date as cohort_date, dateadd(day,1,a.start_date) as day1 ,count(distinct b.userid) as day1players 
                        from prod_games.arcade.first_played_date a
                        join prod_games.arcade.apprunning b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,1,a.start_date) 
                        where a.country like 'US' and a.platform like 'iPhonePlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1) c on c.cohort_date = a.date) d on a.game = d.game and a.date = d.date 
      
     left join (select 'Arcade' as game, dateadd(day,7,a.date) as date, coalesce(cast(c.day7players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day7Perc 
                  from (select to_date(a.submit_time) as date, count(distinct a.userid) as DAU from prod_games.arcade.apprunning a  
                        where a.country like 'US' and a.platform like 'iPhonePlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1) a
                  join (select a.start_date as date, count(distinct a.userid) as New_users from prod_games.arcade.first_played_date a 
                        where a.country like 'US' and a.platform like 'iPhonePlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1) b on b.date = a.date
                  join (select a.start_date as cohort_date, dateadd(day,7,a.start_date) as day7 ,count(distinct b.userid) as day7players 
                        from prod_games.arcade.first_played_date a
                        join prod_games.arcade.apprunning b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,7,a.start_date) 
                        where a.country like 'US'and a.platform like 'iPhonePlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1) c on c.cohort_date = a.date) e on a.game = e.game and a.date = e.date 
      
      left join (select 'Arcade' as game, dateadd(day,30,a.date) as date, coalesce(cast(c.day30players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day30Perc 
                  from (select to_date(a.submit_time) as date, count(distinct a.userid) as DAU from prod_games.arcade.apprunning a  
                        where a.country like 'US' and a.platform like 'iPhonePlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1) a
                  join (select a.start_date as date, count(distinct a.userid) as New_users from prod_games.arcade.first_played_date a 
                        where a.country like 'US'and a.platform like 'iPhonePlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1) b on b.date = a.date
                  join (select a.start_date as cohort_date, dateadd(day,30,a.start_date) as day30 ,count(distinct b.userid) as day30players 
                        from prod_games.arcade.first_played_date a
                        join prod_games.arcade.apprunning b on b.userid = a.userid and to_date(b.submit_time) = dateadd(day,30,a.start_date) 
                        where a.country like 'US'and a.platform like 'iPhonePlayer' and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                        group by 1) c on c.cohort_date = a.date) f on a.game = f.game and a.date = f.date 
                    
        left join (select 'Arcade' as game, start_date as date, count(distinct userid) as new_user 
                   from prod_games.arcade.first_played_date 
                   where country like 'US' and platform like 'iPhonePlayer' 
                   and userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
                   group by 1,2) as h on h.game = a.game and h.date = a.date );


truncate table prod_games.reporting.ARCADE_ADS_AND_GAMES_TABLE;
insert into prod_games.reporting.ARCADE_ADS_AND_GAMES_TABLE
select
a.date
,a.platform
,a.app_location as game
,sum(a.ad_offered) as ads_offered
,b.game_starts
,b.game_plays
,b.users
,b.sessions

from prod_games.reporting.arcade_ads a
join prod_games.reporting.ARCADE_GAMES_PLAYED b on a.date = b.date and a.platform = b.platform and a.app_location = b.game_name
group by 1,2,3,5,6,7,8;

truncate table prod_games.reporting.ARCADE_WEEKOVERWEEK_TABLE;
insert into prod_games.reporting.ARCADE_WEEKOVERWEEK_TABLE
select 
year||week as yearweek
,RANK() OVER (PARTITION BY platform ORDER BY yearweek asc) as rank
,platform
,week0
,week1
,week1/week0 wow_retention
from(select
      '2019' as year
      ,week(a.submit_time) as week
      ,a.platform
      ,count (distinct a.userid) as week0
      ,count (distinct b.userid) as week1

      from prod_games.arcade.apprunning a
      left join prod_games.arcade.apprunning b on week(b.submit_time) = week(a.submit_time)+1 and a.userid = b.userid
      where a.submit_time::date >= '3/4/2019' and week(a.submit_time) < week(current_timestamp)+1
      and a.userid in (select userid from prod_games.arcade.FIRST_PLAYED_DATE where START_DATE >= '3/4/2019')
      and a.country like 'US'
      group by 1,2,3
      order by week0 desc);
