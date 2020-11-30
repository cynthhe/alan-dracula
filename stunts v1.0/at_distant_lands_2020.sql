use database prod_games;
use schema arcade;
use warehouse wh_default;

-- # of users who have HBO Max
select count(distinct userid)
from prod_games.arcade.gdb_gotreward
where title is not null
and (title = 'Scientist Bubblegum'
     or title = 'Olive'
     or title = 'Young Marcy'
     or title = 'Sheriff BMO'
     or title = 'Spacesuit BMO'
     or title = 'Glass Boy'
     or title = 'See-Through Princess'
     or title = 'Y-5'
     or title = 'Mr. M'
     or title = 'Young Finn & Jake'
     or title = 'Bubbline'
    );
    
-- # of users who collected x distinct figures for AT Distant Lands island
with figure_list as
    (select distinct
        userid
        ,count(distinct title) as distinct_figures
     from gdb_gotreward
     where title is not null
     and (title = 'Scientist Bubblegum'
           or title = 'Saint Marceline'
           or title = 'Olive'
           or title = 'Young Marcy'
           or title = 'Sheriff BMO'
           or title = 'Spacesuit BMO'
           or title = 'Glass Boy'
           or title = 'See-Through Princess'
           or title = 'Y-5'
           or title = 'Mr. M'
           or title = 'Young Finn & Jake'
           or title = 'Bubbline'
         )
     and date >= to_date('2020-11-19')
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
            when distinct_figures = 10 then count(distinct userid)
            when distinct_figures = 11 then count(distinct userid)
            when distinct_figures = 12 then count(distinct userid)
            else 'not valid'
            end as num_users
     from figure_list
     group by 1
    )
select
    distinct_figures
    ,round(num_users) as num_users
from count_users
group by 1,2;
