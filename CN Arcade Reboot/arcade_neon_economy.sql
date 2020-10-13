-- REPORTING schema
USE DATABASE prod_games;
USE SCHEMA reporting;
USE warehouse wh_default;

-- Neon economy
CREATE OR REPLACE VIEW arcade_neon_economy AS
SELECT DISTINCT
    a.submit_time::DATE AS date
    ,SUM(a.currency_amount) AS total_claimed
    ,SUM(c.amount) AS total_daily_reward
    ,SUM(b.purchased_item_price) AS total_spent
    ,(total_claimed + total_daily_reward) AS total_gained
    ,(total_gained - total_spent) AS neon_net_total
FROM prod_games.arcade.currency_claimed a
JOIN prod_games.arcade.purchase b
ON a.userid = b.userid AND a.submit_time::DATE = b.submit_time::DATE
JOIN prod_games.arcade.daily_reward c
ON a.userid = c.userid AND a.submit_time::DATE = c.submit_time::DATE
WHERE a.userid IN (SELECT userid
                   FROM prod_games.arcade.FIRST_PLAYED_DATE
                   WHERE START_DATE >= '3/4/2019')
GROUP BY 1;

-- Looker permissions for reporting view
GRANT SELECT ON prod_games.reporting.arcade_neon_economy TO looker_read;


--
with max_new_balance as
    (select distinct
        max(a.ts::DATE) as ts
        ,a.userid
        ,new_balance
     from prod_games.arcade.currency_rewarded a
     join (select distinct
            userid
            ,max(ts) as ts
           from prod_games.arcade.currency_rewarded
           group by userid) b
     on a.userid = b.userid and a.ts = b.ts
     group by a.userid, new_balance
    )
,calculations as
    (select
        ts
        ,sum(new_balance) as current_balance
     from max_new_balance
     group by 1
    )
select
    ts
    ,current_balance
from calculations;

--
select distinct
    max(a.ts::DATE) as ts
    ,a.userid
    ,new_balance
from prod_games.arcade.currency_rewarded a
join (select distinct
        userid
        ,max(ts) as ts
      from prod_games.arcade.currency_rewarded
      group by userid) b
on a.userid = b.userid and a.ts = b.ts
where a.userid = '26c5979e239234fe2afe38664373de1d'
group by a.userid, new_balance;

--
select distinct
    max(ts) as ts
    ,userid
    ,new_balance
from prod_games.arcade.currency_rewarded
where userid = '26c5979e239234fe2afe38664373de1d'
group by userid, new_balance;
