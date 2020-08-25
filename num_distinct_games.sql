USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- How many distinct games on average per session are played?
SELECT per_session
FROM (SELECT ROUND(AVG(num_game_session)) AS per_session
      FROM (SELECT DISTINCT
                userid
                ,sessionid
                ,COUNT(DISTINCT game_name) AS num_game_session -- # of games per session
            FROM prod_games.arcade.game_open
            WHERE country LIKE 'US'
            AND userid IN (SELECT userid
                           FROM prod_games.arcade.first_played_date
                           WHERE start_date >= '3/4/2019')
            GROUP BY 1,2)
      );
      
-- How many distinct games on average per day?
SELECT per_day
FROM (SELECT ROUND(AVG(num_game_day)) AS per_day
      FROM (SELECT DISTINCT
                    userid
                    ,submit_time::DATE AS date
                    ,COUNT(DISTINCT game_name) AS num_game_day -- # of games per day
                 FROM prod_games.arcade.game_open
                 WHERE country LIKE 'US'
                 AND userid IN (SELECT userid
                                FROM prod_games.arcade.first_played_date
                                WHERE start_date >= '3/4/2019')
                 GROUP BY 1,2)
     );
     
-- How many distinct games on average per week?
SELECT per_week
FROM (SELECT ROUND(AVG(num_game_week)) AS per_week
      FROM (SELECT DISTINCT
                    userid
                    ,DATEADD('DAY', seq, date) AS date 
                    ,COUNT(DISTINCT game_name) AS num_game_week -- # of games per week
                 FROM (SELECT DISTINCT
                       userid
                       ,submit_time::DATE AS date
                       ,game_name
                       FROM prod_games.arcade.game_open
                       WHERE country LIKE 'US'
                       AND userid IN (SELECT userid
                                      FROM prod_games.arcade.first_played_date
                                      WHERE start_date >= '3/4/2019')
                      ) A,
                 (SELECT seq
                  FROM (SELECT ROW_NUMBER() OVER (ORDER BY 1 ASC)-1 AS seq 
                        FROM information_schema.columns)
                  WHERE seq < 8) B
                 GROUP BY 1,2)
     );
     
-- How many distinct games on average per 30 days?
SELECT per_30_days
FROM (SELECT ROUND(AVG(num_game_30)) AS per_30_days
      FROM (SELECT DISTINCT
                    userid
                    ,DATEADD('DAY', seq, date) AS date
                    ,COUNT(DISTINCT game_name) AS num_game_30 -- # of games per 30 days
                 FROM (SELECT DISTINCT
                       userid
                       ,submit_time::DATE AS date
                       ,game_name
                       FROM prod_games.arcade.game_open
                       WHERE country LIKE 'US'
                       AND userid IN (SELECT userid
                                      FROM prod_games.arcade.first_played_date
                                      WHERE start_date >= '3/4/2019')
                      ) A,
                 (SELECT seq
                  FROM (SELECT ROW_NUMBER() OVER (ORDER BY 1 ASC)-1 AS seq 
                        FROM information_schema.columns)
                  WHERE seq < 31) B
                 GROUP BY 1,2)
     );
