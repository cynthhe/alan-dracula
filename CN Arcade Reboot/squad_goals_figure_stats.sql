USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

select
    submit_time::date as date_played
    ,b.date as date_acquired
    ,count(distinct a.userid)
//    ,trim(Split_part(GAME_INTERACTION_LOCATION,'-',1)) as game_location
//    ,trim(Split_part(GAME_INTERACTION_LOCATION,'-',2)) as button_clicked
//    ,trim(Split_part(GAME_INTERACTION_LOCATION,'-',3)) as details
from prod_games.arcade.game_start a
join prod_games.arcade.gdb_gotreward b on a.play_userid = b.userid
where game_name like 'Squad Goals' 
    and GAME_INTERACTION_LOCATION != 'title' 
    and GAME_INTERACTION_LOCATION != 'pause' 
    and GAME_INTERACTION_LOCATION != 'play' 
    and country like 'US'
    and a.submit_time::date between to_date('2020-06-01') and to_date('2020-06-07')
    and (title = 'Dancing Raven'
     or title = 'Jazz Drummer Beast Boy'
     or title = 'Singing Cyborg'
     or title = 'Jumpa'
     or title = 'Storm'
     or title = 'Birdarang'
     or title = 'Aquaman King of Atlantis'
     or title = 'Juggling Superman'
     or title = 'Cowgirl Wonder Woman'
    )
    and date_acquired between to_date('2020-06-01') and to_date('2020-06-07')
group by 1,2;

-- # of users who collected figures and played Squad Goals that week
select
    num_users
from (select
        count(distinct userid) as num_users
      from gdb_gotreward
      where userid in (select play_userid
                       from game_start
                       where game_name = 'Squad Goals'
                       and submit_time::date between to_date('2020-06-15') and to_date('2020-06-21')
                      )
      and (title = 'Adventure Time Mao Mao & Badgerclops'
           or title != 'Adorabrat'
           or title != 'Tanya Keys'
           or title != 'Rufus & Reggie'
           or title != 'Mail Mole'
           or title != 'Clark Lockjaw'
           or title != 'Sheriff Snugglemagne'
           or title != 'Pet Prom Mao Mao'
           or title != 'Stinky Badgerclops'
          )
      and date between to_date('2020-06-15') and to_date('2020-06-21')
     );

-- # of users who played Squad Goals and collected x amount of distinct figures for Squad Goals that week
with figure_list as
    (select distinct
        userid
        ,count(distinct title) as distinct_figures
     from gdb_gotreward
     where date between to_date('2020-06-15') and to_date('2020-06-21')
     and userid in (select play_userid
                       from game_start
                       where game_name = 'Squad Goals'
                       and submit_time::date between to_date('2020-06-15') and to_date('2020-06-21')
                   )
     and (title = 'Adventure Time Mao Mao & Badgerclops'
           or title = 'Adorabrat'
           or title = 'Tanya Keys'
           or title = 'Rufus & Reggie'
           or title = 'Mail Mole'
           or title = 'Clark Lockjaw'
           or title = 'Sheriff Snugglemagne'
           or title = 'Pet Prom Mao Mao'
           or title = 'Stinky Badgerclops'
         )
     group by 1
    )
,count_users as
    (select distinct
        distinct_figures
        ,case when distinct_figures = 1 then count(distinct userid)
            when distinct_figures = 2 then count(distinct userid)
            when distinct_figures = 3 then count(distinct userid)
            when distinct_figures = 4 then count(distinct userid)
            when distinct_figures = 5 then count(distinct userid)
            when distinct_figures = 6 then count(distinct userid)
            when distinct_figures = 7 then count(distinct userid)
            when distinct_figures = 8 then count(distinct userid)
            when distinct_figures = 9 then count(distinct userid)
            else 'not valid'
            end as num_users
     from figure_list
     group by 1
    )
select
    distinct_figures
    ,round(num_users)
from count_users
group by 1,2;

--
select distinct
    title
    ,rarity
from gdb_gotreward
where title like '%Adventure Time Mao Mao & Badgerclops%'
    or title like '%Adorabrat%'
    or title like '%Tanya Keys%'
    or title like '%Rufus & Reggie%'
    or title like '%Mail Mole%'
    or title like '%Clark Lockjaw%'
    or title like '%Sheriff Snugglemagne%'
    or title like '%Pet Prom Mao Mao%'
    or title like '%Stinky Badgerclops%'
group by 1,2;
