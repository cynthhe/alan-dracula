-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- Create reporting view: ARCADE_SCORE_RANKS
CREATE OR REPLACE VIEW arcade_score_ranks AS
-- What percentage of users attain which Score Ranks (per game)?
SELECT DISTINCT
    game_name
    ,CASE WHEN max_rank_number = 1 THEN 'Rookie'
        WHEN max_rank_number = 2 THEN 'Pro'
        WHEN max_rank_number = 3 THEN 'Champion'
        WHEN max_rank_number = 4 THEN 'Epic'
        WHEN max_rank_number = 5 THEN 'Legend'
        ELSE NULL
        END AS rank_number
    ,COUNT(DISTINCT userid) AS num_users
FROM (SELECT DISTINCT
        userid
        ,CASE WHEN game_name LIKE 'Smashy%' THEN 'Smashy Pinata' 
            WHEN game_name LIKE '%Maze' THEN 'Maize Maze'
            ELSE game_name 
            END AS game_name
        ,MAX(rank_number) AS max_rank_number
      FROM prod_games.arcade.achievement
      WHERE rank_number IS NOT NULL
      AND (game_name = 'Bottle Catch'
           OR game_name = 'Bounceback'
           OR game_name = 'Boxed Up Bears'
           OR game_name = 'Brains vs Bugs'
           OR game_name = 'Burger & Burrito'
           OR game_name = 'Camp Cardboard'
           OR game_name = 'Cut It Out (FULL)'
           OR game_name = 'Diamond Alliance'
           OR game_name = 'Dodge Squad'
           OR game_name = 'Fangs of Fire'
           OR game_name = 'Forever Tower'
           OR game_name = 'French Fry Frenzy'
           OR game_name = 'Galaxy Warp'
           OR game_name = 'Go Go K.O.!'
           OR game_name = 'Gumball''s Block Party'
           OR game_name = 'Jelly of the Beast'
           OR game_name = 'Kicked Out'
           OR game_name LIKE '%Maze'
           OR game_name = 'Mechanoid Menace'
           OR game_name = 'Monster Kicks'
           OR game_name = 'Rainbow Wreckers'
           OR game_name = 'Rainicorn''s Flying Colors'
           OR game_name = 'Rock ''n'' Rush'
           OR game_name = 'Royal Highness'
           OR game_name = 'Rumble Bee'
           OR game_name = 'Scooby''s Knightmare'
           OR game_name = 'Shattered Dreams'
           OR game_name = 'Sick Tricks'
           OR game_name LIKE 'Smashy%'
           OR game_name = 'Squad Goals'
           OR game_name = 'Stack Tracks'
           OR game_name = 'Stellar Odyssey'
           OR game_name = 'Steven Tag'
           OR game_name = 'Teen Titans GOAL!'
           OR game_name = 'Tomb of Doom'
           OR game_name = 'Too Big to Fall'
           OR game_name = 'Xingo Mayhem'
          )
      GROUP BY 1,2
     )
GROUP BY 1,2;

-- Looker permissions for reporting view
GRANT SELECT ON prod_games.reporting.arcade_score_ranks TO looker_read;
