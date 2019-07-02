/**
-- calculates the amount of money that a player will spend in Bloons
-- how much you can spend on acquiring new customers
-- factors I want to determine: (1) who are the highest-value players (2) how much risk are we exposed to (3) how much can we afford to spend to acquire new players

month_ARPU AS
(SELECT
     visit_month, 
     Avg(revenue) AS ARPU 
FROM
     (SELECT
          Cust_id,
          Datediff(MONTH, ‘2010-01-01’, transaction_date) AS visit_month, 
          Sum(transaction_size) AS revenue 
     FROM   transactions 
     WHERE  transaction_date > Dateadd(‘year’, -1, CURRENT_DATE) 
     GROUP BY
           1, 
           2) 
GROUP BY 1)

WITH monthly_visits AS 
(SELECT
     DISTINCT
     Datediff(month, ‘2010-01-01’, transaction_date) AS visit_month, 
     cust_id 
FROM            transactions 
WHERE
transaction_date > dateadd(‘year’, -1, current_date)), 

--------------------------
calculating churn rate

(SELECT
avg(churn_rate) 
FROM
     (SELECT
          current_month, 
          Count(CASE 
               WHEN cust_type='churn' THEN 1 
               ELSE NULL 
          END)/count(cust_id) AS churn_rate 
     FROM
          (SELECT
               past_month.visit_month + interval ‘1 month’ AS current_month, 
               past_month.cust_id, 
               CASE
                    WHEN this_month.cust_id IS NULL THEN 'churn' 
                    ELSE 'retained' 
               END AS cust_type 
          FROM
               monthly_visits past_month 
           LEFT JOIN monthly_visits this_month ON
                    this_month.cust_id=past_month.cust_id
                    AND this_month.visit_month=past_month.visit_month + interval ‘1 month’
          )data
     GROUP BY 1)
)
**/

use prod_games;
select * from "PROD_GAMES"."BLOONS_PROC"."BATMOBILE_BUYITEM";
