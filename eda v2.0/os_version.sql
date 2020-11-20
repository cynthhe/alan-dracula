USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- Create REPORTING view: ARCADE_OS_VERSION
CREATE OR REPLACE VIEW ARCADE_OS_VERSION AS
SELECT DISTINCT
    submit_time::DATE AS date
    ,CASE
        WHEN os_ver LIKE 'iPhone OS 9%' THEN 'iOS 9'
        WHEN os_ver LIKE 'iOS 10%' THEN 'iOS 10'
        WHEN os_ver LIKE 'iOS 11%' THEN 'iOS 11'
        WHEN os_ver LIKE 'iOS 12%' THEN 'iOS 12'
        WHEN os_ver LIKE 'iOS 13%' THEN 'iOS 13'
        WHEN os_ver LIKE 'iOS 14%' THEN 'iOS 14'
        WHEN os_ver LIKE 'Android OS 4%' THEN 'Android OS 4'
        WHEN user_agent LIKE '%Android 4%' THEN 'Android OS 4'
        WHEN os_ver LIKE 'Android OS 5%' THEN 'Android OS 5'
        WHEN user_agent LIKE '%Android 5%' THEN 'Android OS 5'
        WHEN os_ver LIKE 'Android OS 6%' THEN 'Android OS 6'
        WHEN user_agent LIKE '%Android 6%' THEN 'Android OS 6'
        WHEN os_ver LIKE 'Android OS 7%' THEN 'Android OS 7'
        WHEN user_agent LIKE '%Android 7%' THEN 'Android OS 7'
        WHEN os_ver LIKE 'Android OS 8%' THEN 'Android OS 8'
        WHEN user_agent LIKE '%Android 8%' THEN 'Android OS 8'
        WHEN os_ver LIKE 'Android OS Yandexian 8%' THEN 'Android OS 8'
        WHEN os_ver LIKE 'Android OS 9%' THEN 'Android OS 9'
        WHEN user_agent LIKE '%Android 9%' THEN 'Android OS 9'
        WHEN os_ver LIKE 'Android OS P%' THEN 'Android OS 9'
        WHEN user_agent LIKE '%Android P%' THEN 'Android OS 9'
        WHEN os_ver LIKE 'Android OS 10%' THEN 'Android OS 10'
        WHEN user_agent LIKE '%Android 10%' THEN 'Android OS 10'
        WHEN os_ver LIKE 'Android OS Q%' THEN 'Android OS 10'
        WHEN user_agent LIKE '%Android Q%' THEN 'Android OS 10'
        WHEN os_ver LIKE 'Android OS 11%' THEN 'Android OS 11'
        WHEN user_agent LIKE '%Android 11%' THEN 'Android OS 11'
        WHEN os_ver LIKE 'Windows%' THEN 'Windows'
        WHEN os_ver LIKE 'Mac OS%' THEN 'Mac OS'
        ELSE 'Android OS (unknown version)'
        END AS os_ver
    ,COUNT(*) as num_users
FROM prod_games.arcade.deviceinfo
WHERE os_ver IS NOT null
GROUP BY 1,2;

-- Looker permissions for reporting view
GRANT SELECT ON prod_games.reporting.ARCADE_OS_VERSION TO looker_read;

-- 01/21/2019
select min(submit_time::date)
from deviceinfo;

--
select distinct 
    os_ver
    ,user_agent
    ,count(*)
from prod_games.arcade.deviceinfo
where os_ver is not null
and (os_ver not like 'iPhone OS 9%'
     and os_ver not like 'iOS 10%'
     and os_ver not like 'iOS 11%'
     and os_ver not like 'iOS 12%'
     and os_ver not like 'iOS 13%'
     and os_ver not like 'iOS 14%'
     and os_ver not like 'Android OS 4%'
     and user_agent not like '%Android 4%'
     and os_ver not like 'Android OS 5%'
     and user_agent not like '%Android 5%'
     and os_ver not like 'Android OS 6%'
     and user_agent not like '%Android 6%'
     and os_ver not like 'Android OS 7%'
     and user_agent not like '%Android 7%'
     and os_ver not like 'Android OS 8%'
     and user_agent not like '%Android 8%'
     and os_ver not like 'Android OS Yandexian 8%'
     and os_ver not like 'Android OS 9%'
     and user_agent not like '%Android 9%'
     and user_agent not like '%Android P%'
     and os_ver not like 'Android OS P%'
     and os_ver not like 'Android OS 10%'
     and user_agent not like '%Android 10%'
     and os_ver not like 'Android OS Q%'
     and user_agent not like '%Android Q%'
     and os_ver not like 'Android OS 11%'
     and user_agent not like '%Android 11%'
     and os_ver not like 'Windows%'
     and os_ver not like 'Mac OS%'
     and os_ver is not null
    )
group by 1,2;
