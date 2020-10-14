CREATE OR REPLACE VIEW ACR AS
SELECT
    userid
    ,sessionid
    ,submit_time
    ,ts
    ,episode_name
    ,figure_granted
    ,play_userloggedin
    ,platform
    ,city
    ,country
    ,CASE 
        WHEN code = 0 OR code IS NULL THEN 'True'
        ELSE 'False'
        END AS success
    ,code
FROM prod_games.arcade.capture
LEFT JOIN prod_games.arcade.result ON (capture.id = result.id)
WHERE NOT (episode_name IS NULL AND code = 0);
