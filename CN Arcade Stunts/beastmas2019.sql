USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- Users who were active in the last 30 days who have any of the Beastmas figures
SELECT
    COUNT(DISTINCT a.userid)
FROM prod_games.arcade.gdb_gotreward a
JOIN prod_games.arcade.game_start b ON a.userid = b.play_userid
WHERE submit_time::DATE >= DATEADD(day,-30,CURRENT_DATE()) AND submit_time::DATE <= CURRENT_DATE()
AND country LIKE 'US' AND b.userid IN (SELECT userid
                                       FROM prod_games.arcade.first_played_date
                                       WHERE start_date >= '3/4/2019'
                                      )
AND (title = 'Elf Beast Boy'
     OR title = 'Cat Beast Boy'
     OR title = 'Boa Constrictor Beast Boy'
     OR title = 'Hummingbird Beast Boy'
     OR title = 'Elephant Beast Boy'
     OR title = 'Gorilla Beast Boy'
     OR title = 'Pelican Beast Boy'
     OR title = 'Reindeer Beast Boy'
     OR title = 'Dove Beast Boy'
     OR title = 'Octopus Beast Boy'
     OR title = 'Llama Beast Boy'
     OR title = 'Rat Beast Boy'
     OR title = 'Kangaroo Beast Boy'
     OR title = 'Goldfish Beast Boy'
     OR title = 'Turtle Beast Boy'
     OR title = 'Hound Dog Beast Boy'
     OR title = 'Santa Claus & Elf Beast Boy'
     OR title = 'The Gift of Beast Boy'
     OR title = 'Ghost of Black Friday Present'
     OR title = 'Ugly Sweater Beast Boy'
     OR title = 'Beast Boy in Lights'
     OR title = 'Snowman Beast Boy'
     OR title = 'Beast Boy Under the Mistletoe'
     OR title = 'X-Mas Tree Beast Boy'
    );

-- What % of current CNA players (i.e. within last 30 days) have any of the Beastmas figures in their collection?
SELECT
    title
    ,ROUND(((num_users / (SELECT COUNT(DISTINCT userid) 
                          FROM prod_games.arcade.apprunning 
                          WHERE submit_time::DATE >= DATEADD(day,-30,CURRENT_DATE()) AND submit_time::DATE <= CURRENT_DATE())) * 100), 2) AS percent_of_total
FROM (SELECT
        title
        ,COUNT(DISTINCT userid) AS num_users
      FROM (SELECT DISTINCT 
                a.userid
                ,title
            FROM prod_games.arcade.gdb_gotreward a
            JOIN prod_games.arcade.game_start b ON a.userid = b.play_userid
            WHERE submit_time::DATE >= DATEADD(day,-30,CURRENT_DATE()) AND submit_time::DATE <= CURRENT_DATE()
            AND country LIKE 'US' AND b.userid IN (SELECT userid
                                                   FROM prod_games.arcade.first_played_date
                                                   WHERE start_date >= '3/4/2019'
                                                  )
            AND (title = 'Elf Beast Boy'
                 OR title = 'Cat Beast Boy'
                 OR title = 'Boa Constrictor Beast Boy'
                 OR title = 'Hummingbird Beast Boy'
                 OR title = 'Elephant Beast Boy'
                 OR title = 'Gorilla Beast Boy'
                 OR title = 'Pelican Beast Boy'
                 OR title = 'Reindeer Beast Boy'
                 OR title = 'Dove Beast Boy'
                 OR title = 'Octopus Beast Boy'
                 OR title = 'Llama Beast Boy'
                 OR title = 'Rat Beast Boy'
                 OR title = 'Kangaroo Beast Boy'
                 OR title = 'Goldfish Beast Boy'
                 OR title = 'Turtle Beast Boy'
                 OR title = 'Hound Dog Beast Boy'
                 OR title = 'Santa Claus & Elf Beast Boy'
                 OR title = 'The Gift of Beast Boy'
                 OR title = 'Ghost of Black Friday Present'
                 OR title = 'Ugly Sweater Beast Boy'
                 OR title = 'Beast Boy in Lights'
                 OR title = 'Snowman Beast Boy'
                 OR title = 'Beast Boy Under the Mistletoe'
                 OR title = 'X-Mas Tree Beast Boy'
                )
           )
      GROUP BY 1
     )
GROUP BY 1,2
ORDER BY percent_of_total DESC;

-- Check for figure name spelling
SELECT DISTINCT
    title
    ,rarity
    ,COUNT(*)
FROM prod_games.arcade.gdb_gotreward
WHERE title = 'Elf Beast Boy'
OR title = 'Cat Beast Boy'
OR title = 'Boa Constrictor Beast Boy'
OR title = 'Hummingbird Beast Boy'
OR title = 'Elephant Beast Boy'
OR title = 'Gorilla Beast Boy'
OR title = 'Pelican Beast Boy'
OR title = 'Reindeer Beast Boy'
OR title = 'Dove Beast Boy'
OR title = 'Octopus Beast Boy'                 
OR title = 'Llama Beast Boy'
OR title = 'Rat Beast Boy'
OR title = 'Kangaroo Beast Boy'
OR title = 'Goldfish Beast Boy'
OR title = 'Turtle Beast Boy'
OR title = 'Hound Dog Beast Boy'
OR title = 'Santa Claus & Elf Beast Boy'
OR title = 'The Gift of Beast Boy'
OR title = 'Ghost of Black Friday Present'
OR title = 'Ugly Sweater Beast Boy'
OR title = 'Beast Boy in Lights'
OR title = 'Snowman Beast Boy'
OR title = 'Beast Boy Under the Mistletoe'
OR title = 'X-Mas Tree Beast Boy'
GROUP BY title,num_users;
