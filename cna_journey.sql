-- Segment on month they joined
WITH cna_journey AS 
(SELECT
    userid
    ,MIN(sessionid) AS sessionid
    ,MIN(ts) AS ts
 FROM prod_games.arcade.apprunning
 GROUP BY 1)
,journey_data AS
(SELECT
    userid
    ,sessionid
    ,ts
    ,location
    ,segment
    ,RANK() OVER (PARTITION BY sessionid ORDER BY ts ASC) AS action_sequence
 FROM (SELECT
        a.userid
        ,a.sessionid
        ,a.ts
        ,a.screen_name AS location
        ,b.segment
       FROM prod_games.arcade.screen_visit a -- screen visit, includes shop
       JOIN prod_games.arcade.engagement_segments b
       ON (a.userid = b.userid) AND ((YEAR(a.ts)||LPAD(MONTH(a.ts),2,'0')) = b.yearmonth)
       WHERE a.sessionid IN (SELECT sessionid
                             FROM cna_journey
                             GROUP BY 1)
       AND a.ts IN (SELECT ts
                    FROM cna_journey
                    GROUP BY 1)
       GROUP BY 1,2,3,4,5
       UNION ALL
       SELECT
        a.userid
        ,a.sessionid
        ,a.ts
        ,CASE WHEN a.game_name LIKE 'Smashy%' THEN 'Smashy Pinata' ELSE a.game_name END AS location
        ,b.segment
       FROM prod_games.arcade.game_open a -- game open
       JOIN prod_games.arcade.engagement_segments b
       ON (a.userid = b.userid) AND ((YEAR(a.ts)||LPAD(MONTH(a.ts),2,'0')) = b.yearmonth)
       WHERE a.sessionid IN (SELECT sessionid
                          FROM cna_journey
                          GROUP BY 1)
       AND a.ts IN (SELECT ts
                    FROM cna_journey
                    GROUP BY 1)
       GROUP BY 1,2,3,4,5
       UNION ALL
       SELECT
        a.userid
        ,a.sessionid
        ,a.ts
        ,CASE WHEN a.game_name LIKE 'Smashy%' THEN 'Smashy Pinata' ELSE a.game_name END AS location
        ,b.segment
       FROM prod_games.arcade.game_start a -- game start
       JOIN prod_games.arcade.engagement_segments b
       ON (a.userid = b.userid) AND ((YEAR(a.ts)||LPAD(MONTH(a.ts),2,'0')) = b.yearmonth)
       WHERE a.sessionid IN (SELECT sessionid
                           FROM cna_journey
                           GROUP BY 1)
       AND a.ts IN (SELECT ts
                    FROM cna_journey
                    GROUP BY 1)
       GROUP BY 1,2,3,4,5
       UNION ALL
       SELECT
        a.userid
        ,a.sessionid
        ,a.ts
        ,'ACR' AS location
        ,b.segment
       FROM prod_games.arcade.ACR a -- ACR
       JOIN prod_games.arcade.engagement_segments b
       ON (a.userid = b.userid) AND ((YEAR(a.ts)||LPAD(MONTH(a.ts),2,'0')) = b.yearmonth)
       WHERE a.sessionid IN (SELECT sessionid
                           FROM cna_journey
                           GROUP BY 1)
       AND a.ts IN (SELECT ts
                    FROM cna_journey
                    GROUP BY 1)
       GROUP BY 1,2,3,4,5
       UNION ALL
       SELECT
        a.userid
        ,a.sessionid
        ,a.ts
        ,a.stunt_name AS location
        ,b.segment
       FROM prod_games.arcade.stunt_open a -- stunts
       JOIN prod_games.arcade.engagement_segments b
       ON (a.userid = b.userid) AND ((YEAR(a.ts)||LPAD(MONTH(a.ts),2,'0')) = b.yearmonth)
       WHERE a.sessionid IN (SELECT sessionid
                             FROM cna_journey
                             GROUP BY 1)
       AND a.ts IN (SELECT ts
                    FROM cna_journey
                    GROUP BY 1)
       GROUP BY 1,2,3,4,5)
 GROUP BY 1,2,3,4,5)
 SELECT
    action_sequence
    ,location
    ,segment
    ,COUNT(DISTINCT userid) AS users
FROM journey_data
GROUP BY 1,2,3
HAVING users >= 50
ORDER BY action_sequence ASC;

-- I need stunt
--Segment on month they joined, segmented by people who ACR vs Don’t and Segmented by total # of months they have been in arcade (so have they stuck around)
