USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- % of players that have completed each Achievement (by Game) | All CNA players
SELECT DISTINCT
    achievement_name
    ,ROUND((COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.apprunning 
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                              )
     )*100,2) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Camp Cardboard' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1
ORDER BY percent_of_users DESC;

-- # of players that have completed each Achievement (by Game) | All CNA players
SELECT DISTINCT
    achievement_name
    ,COUNT(DISTINCT userid) AS num_users
FROM prod_games.arcade.achievement
WHERE game_name = 'French Fry Frenzy' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1
ORDER BY num_users DESC;

-- % of MAU that have completed each Achievement (by Game)
SELECT DISTINCT
    achievement_name
    ,ROUND((num_users/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.apprunning
                                     WHERE submit_time::DATE >= DATEADD(day,-30,CURRENT_DATE()) AND submit_time::DATE <= CURRENT_DATE()
                                     AND country LIKE 'US' AND userid IN (SELECT userid
                                                                          FROM prod_games.arcade.first_played_date
                                                                          WHERE start_date >= '3/4/2019')
                              )
     )*100,2) AS percent_of_users
FROM (SELECT
        achievement_name
        ,COUNT(DISTINCT a.userid) AS num_users
      FROM prod_games.arcade.achievement a
      JOIN prod_games.arcade.apprunning b ON a.userid = b.userid
      WHERE b.submit_time::DATE >= DATEADD(day,-30,CURRENT_DATE()) AND b.submit_time::DATE <= CURRENT_DATE()
      AND b.country LIKE 'US' AND b.userid IN (SELECT userid
                                               FROM prod_games.arcade.first_played_date
                                               WHERE start_date >= '3/4/2019')
      AND game_name = 'French Fry Frenzy' -- Specify game name here
      AND achievement_name IS NOT NULL
      GROUP BY 1
)
GROUP BY 1,2
ORDER BY percent_of_users DESC;

-- # of MAU that have completed each Achievement (by Game)
SELECT DISTINCT
    achievement_name
    ,num_users
FROM (SELECT
        achievement_name
        ,COUNT(DISTINCT a.userid) AS num_users
      FROM prod_games.arcade.achievement a
      JOIN prod_games.arcade.apprunning b ON a.userid = b.userid
      WHERE b.submit_time::DATE >= DATEADD(day,-30,CURRENT_DATE()) AND b.submit_time::DATE <= CURRENT_DATE()
      AND b.country LIKE 'US' AND b.userid IN (SELECT userid
                                               FROM prod_games.arcade.first_played_date
                                               WHERE start_date >= '3/4/2019')
      AND game_name = 'French Fry Frenzy' -- Specify game name here
      AND achievement_name IS NOT NULL
      GROUP BY 1
)
GROUP BY 1,2
ORDER BY num_users DESC;

-- % of players who have played the game and completed each Achievement (by Game)
SELECT DISTINCT
    achievement_name
    ,ROUND((COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Galaxy Warp' -- Specify game name here
                              )
     )*100,2) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Galaxy Warp' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1
ORDER BY percent_of_users DESC;

-- Check for game name spelling
select distinct game_name
from prod_games.arcade.achievement
where game_name like '%Big%';
