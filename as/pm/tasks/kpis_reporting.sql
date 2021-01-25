create or replace table PROD_GAMES.PM_REPORTING_PROD.pocket_mortys_KPIs as
select
 Date
,new_user
,DAU
,WAU
,MAU
,day1Perc as Day_1 
,day7Perc as Day_7
,day30Perc as Day_30
,coalesce(ARPDAU,0) as ARPDAU
,coalesce(ARPPU,0) as ARPPU
,coalesce(purchasers,0) as purchasers
,coalesce((purchasers/DAU),0) as Conversion 
,coalesce(REVENUE,0) as REVENUE


from(select
       a.Date
      ,h.new_user
      ,cast(a.DAU as NUMBER(38,6)) as DAU
      ,cast(b.WAU as NUMBER(38,6)) as WAU
      ,cast(c.MAU as NUMBER(38,6)) as MAU
      ,day1Perc
      ,day7Perc
      ,day30Perc
      ,g.ARPPU
      ,g.REVENUE/a.DAU as ARPDAU
      ,g.purchasers
      ,g.REVENUE
     
      from (select SESSION_DATE as Date, count(distinct device_id) as DAU from PROD_GAMES.POCKET_MORTYS.POCKET_MORTYS_SESSIONS_PURCHASES group by 1) a
      
     left join (select DATEADD('DAY', seq, Date) AS Date, count(distinct device_id) as WAU
           FROM (select SESSION_DATE as Date, device_id from PROD_GAMES.POCKET_MORTYS.POCKET_MORTYS_SESSIONS_PURCHASES group by 1,2) A,
                (select seq from (select row_number() over (order by 1 ASC)-1 AS seq from information_schema.columns) where seq < 8) B
          group by DATEADD('DAY', seq, Date)) b on b.date = a.date 
      
     left join (select DATEADD('DAY', seq, Date) AS Date, count(distinct device_id) as MAU
           FROM (select SESSION_DATE AS Date, device_id from PROD_GAMES.POCKET_MORTYS.POCKET_MORTYS_SESSIONS_PURCHASES group by 1,2) A,
                (select seq from (select row_number() over (order by 1 ASC)-1 AS seq from information_schema.columns) where seq < 31) B
          group by DATEADD('DAY', seq, Date)) c on c.date = a.date 

      left join (select dateadd(day,1,a.date) as date, coalesce(cast(c.day1players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day1Perc 
                  from (select SESSION_DATE as date, count(distinct device_id) as DAU from PROD_GAMES.POCKET_MORTYS.POCKET_MORTYS_SESSIONS_PURCHASES group by 1) a
                  join (select INSTALL_DATE as date, count(distinct device_id) as New_users from PROD_GAMES.POCKET_MORTYS.POCKET_MORTYS_SESSIONS_PURCHASES group by 1) b on b.date = a.date
                  join (select a.INSTALL_DATE as cohort_date, dateadd(day,1,a.INSTALL_DATE) as day1 ,count(distinct b.device_id) as day1players 
                        from (select INSTALL_DATE , device_id from PROD_GAMES.POCKET_MORTYS.POCKET_MORTYS_SESSIONS_PURCHASES group by 1,2) a
                        join PROD_GAMES.POCKET_MORTYS.POCKET_MORTYS_SESSIONS_PURCHASES b on b.device_id = a.device_id and b.SESSION_DATE = dateadd(day,1,a.INSTALL_DATE) 
                        group by 1) c on c.cohort_date = a.date) d on d.date = a.date 
      left join (select dateadd(day,7,a.date) as date, coalesce(cast(c.day7players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day7Perc 
                  from (select SESSION_DATE as date, count(distinct device_id) as DAU from PROD_GAMES.POCKET_MORTYS.POCKET_MORTYS_SESSIONS_PURCHASES group by 1) a
                  join (select INSTALL_DATE as date, count(distinct device_id) as New_users from PROD_GAMES.POCKET_MORTYS.POCKET_MORTYS_SESSIONS_PURCHASES group by 1) b on b.date = a.date
                  join (select a.INSTALL_DATE as cohort_date, dateadd(day,7,a.INSTALL_DATE) as day7 ,count(distinct b.device_id) as day7players 
                        from (select INSTALL_DATE , device_id from PROD_GAMES.POCKET_MORTYS.POCKET_MORTYS_SESSIONS_PURCHASES group by 1,2) a
                        join PROD_GAMES.POCKET_MORTYS.POCKET_MORTYS_SESSIONS_PURCHASES b on b.device_id = a.device_id and b.SESSION_DATE = dateadd(day,7,a.INSTALL_DATE) 
                        group by 1) c on c.cohort_date = a.date) e on e.date = a.date 
      left join (select dateadd(day,30,a.date) as date, coalesce(cast(c.day30players as NUMBER(38,6))/cast(New_users as NUMBER(38,6)),0) as day30Perc 
                  from (select SESSION_DATE as date, count(distinct device_id) as DAU from PROD_GAMES.POCKET_MORTYS.POCKET_MORTYS_SESSIONS_PURCHASES group by 1) a
                  join (select INSTALL_DATE as date, count(distinct device_id) as New_users from PROD_GAMES.POCKET_MORTYS.POCKET_MORTYS_SESSIONS_PURCHASES group by 1) b on b.date = a.date
                  join (select a.INSTALL_DATE as cohort_date, dateadd(day,30,a.INSTALL_DATE) as day30 ,count(distinct b.device_id) as day30players 
                        from (select INSTALL_DATE , device_id from PROD_GAMES.POCKET_MORTYS.POCKET_MORTYS_SESSIONS_PURCHASES group by 1,2) a
                        join PROD_GAMES.POCKET_MORTYS.POCKET_MORTYS_SESSIONS_PURCHASES b on b.device_id = a.device_id and b.SESSION_DATE = dateadd(day,30,a.INSTALL_DATE) 
                        group by 1) c on c.cohort_date = a.date) f on f.date = a.date 
    
      left join (select 
                  date
                  ,sum(REVENUE) as REVENUE
                  ,sum(REVENUE)/count(distinct DEVICE_ID) as ARPPU
                  ,count(distinct DEVICE_ID) as purchasers
                  from (select SESSION_DATE as date, DEVICE_ID, REVENUE
                        
                        from PROD_GAMES.POCKET_MORTYS.POCKET_MORTYS_SESSIONS_PURCHASES
                        where revenue > 0
                        group by 1,2,3)
                    group by 1)  g on g.date = a.date 
                    
        left join (select INSTALL_DATE as Date, count(distinct DEVICE_ID) as new_user 
                   from PROD_GAMES.POCKET_MORTYS.POCKET_MORTYS_SESSIONS_PURCHASES
                   group by 1) as h on h.date = a.date )
