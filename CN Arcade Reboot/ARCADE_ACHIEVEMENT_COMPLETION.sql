USE DATABASE prod_games;
USE SCHEMA arcade;
USE warehouse wh_default;

-- Create ARCADE_ACHIEVEMENT_COMPLETION view
CREATE OR REPLACE VIEW arcade_achievement_completion AS
-- % of players who have played the game and completed each Achievement (by Game)
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Bottle Catch' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Bottle Catch' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Bounceback' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Bounceback' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Boxed Up Bears' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Boxed Up Bears' -- Specify game name here
AND achievement_name IS NOT NULL
AND (achievement_name != 'Hey, Grizz!'
     AND achievement_name != 'Greetings, Ice Bear!'
     AND achievement_name != 'Hello, Panda!'
     AND achievement_name != 'No More Boxes'
    )
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Brains vs Bugs' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Brains vs Bugs' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Burger & Burrito' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Burger & Burrito' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Camp Cardboard' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Camp Cardboard' -- Specify game name here
AND achievement_name IS NOT NULL
AND achievement_name != 'Adventurer Supreme'
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Diamond Alliance' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Diamond Alliance' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Dodge Squad' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Dodge Squad' -- Specify game name here
AND achievement_name IS NOT NULL
AND (achievement_name != 'Tag Teamer'
     AND achievement_name != 'Point Monger'
    )
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Fangs of Fire' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Fangs of Fire' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2
UNION
SELECT DISTINCT
    CASE WHEN achievement_name LIKE 'Rockin%' THEN 'Rockin’ It' ELSE achievement_name END AS achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Forever Tower' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Forever Tower' -- Specify game name here
AND achievement_name IS NOT NULL
AND achievement_name != 'Rockin’ It'
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'French Fry Frenzy' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'French Fry Frenzy' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Galaxy Warp' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Galaxy Warp' -- Specify game name here
AND achievement_name IS NOT NULL
AND achievement_name != '3x Combo'
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Go Go K.O.!' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Go Go K.O.!' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Gumball''s Block Party' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Gumball''s Block Party' -- Specify game name here
AND achievement_name IS NOT NULL
AND achievement_name != 'Spring-time!'
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Jelly of the Beast' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Jelly of the Beast' -- Specify game name here
AND achievement_name IS NOT NULL
AND (achievement_name != 'Combo Win'
     AND achievement_name != 'Close Call'
     AND achievement_name != 'Frozen Jelly bomb'
     AND achievement_name != 'High Score'
     AND achievement_name != 'Max Out Badgerclops'
     AND achievement_name != 'Max Out Adorabat'
    )
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Kicked Out' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Kicked Out' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Mechanoid Menace' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Mechanoid Menace' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Monster Kicks' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Monster Kicks' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Rainbow Wreckers' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Rainbow Wreckers' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Rainicorn''s Flying Colors' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Rainicorn''s Flying Colors' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Rock ''n'' Rush' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Rock ''n'' Rush' -- Specify game name here
AND achievement_name IS NOT NULL
AND (achievement_name != 'Summon Charlene'
     AND achievement_name != 'Unlock Special Powers'
     AND achievement_name != 'Aluxes Attack'
     AND achievement_name != 'High Score'
     AND achievement_name != 'Upgrade 1 Special to Max'
    )
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Royal Highness' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Royal Highness' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Rumble Bee' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Rumble Bee' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Scooby''s Knightmare' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Scooby''s Knightmare' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Shattered Dreams' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Shattered Dreams' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Sick Tricks' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Sick Tricks' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,CASE WHEN game_name LIKE 'Smashy%' THEN 'Smashy Pinata' ELSE game_name END AS game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name LIKE 'Smashy%' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name LIKE 'Smashy%' -- Specify game name here
AND achievement_name IS NOT NULL
AND (achievement_name != 'YUMMY GUMMY'
     AND achievement_name != 'MASTER SMASHER'
     AND achievement_name != 'GOING APE'
     AND achievement_name != 'SOLD OUT'
     AND achievement_name != 'MAX POWER'
    )
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Squad Goals' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Squad Goals' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Stack Tracks' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Stack Tracks' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Stellar Odyssey' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Stellar Odyssey' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Steven Tag' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Steven Tag' -- Specify game name here
AND achievement_name IS NOT NULL
AND (achievement_name != 'Tag Everyone'
     AND achievement_name != '20x combo'
     AND achievement_name != 'Score 1k Points'
     AND achievement_name != 'Unlock All Powers'
     AND achievement_name != 'Max a power up'
    )
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Teen Titans GOAL!' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Teen Titans GOAL!' -- Specify game name here
AND achievement_name IS NOT NULL
AND (achievement_name != 'Gooooal!'
     AND achievement_name != 'Striker!'
     AND achievement_name != 'Kickin‘ It'
    )
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Tomb of Doom' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Tomb of Doom' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Too Big to Fall' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Too Big to Fall' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2
UNION
SELECT DISTINCT
    achievement_name
    ,game_name
    ,(COUNT(DISTINCT userid)/ (SELECT COUNT(DISTINCT userid) 
                                     FROM prod_games.arcade.game_start
                                     WHERE country LIKE 'US' AND userid IN (SELECT userid
                                                                            FROM prod_games.arcade.first_played_date
                                                                            WHERE start_date >= '3/4/2019')
                                     AND game_name = 'Xingo Mayhem' -- Specify game name here
                              )
     ) AS percent_of_users
FROM prod_games.arcade.achievement
WHERE game_name = 'Xingo Mayhem' -- Specify game name here
AND achievement_name IS NOT NULL
GROUP BY 1,2;

-- Create ARCADE_ACHIEVEMENT_COMPLETION_TABLE table
CREATE TABLE arcade_achievement_completion_table AS
SELECT *
FROM prod_games.arcade.arcade_achievement_completion;

-- Update ARCADE_ACHIEVEMENT_COMPLETION_TABLE table
TRUNCATE TABLE arcade_achievement_completion_table;
INSERT INTO arcade_achievement_completion_table
SELECT *
FROM prod_games.arcade.arcade_achievement_completion;

-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- Create reporting view: ARCADE_ACHIEVEMENT_COMPLETION
CREATE OR REPLACE VIEW ARCADE_ACHIEVEMENT_COMPLETION AS
SELECT *
FROM prod_games.arcade.arcade_achievement_completion_table;

-- Looker permissions for reporting view
GRANT SELECT ON prod_games.reporting.ARCADE_ACHIEVEMENT_COMPLETION TO looker_read;
