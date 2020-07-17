SELECT
    a.SESSION_DATE::DATE AS date
    ,COUNT(DISTINCT a.device_id) AS DAU
    ,SUM(a.revenue) AS Revenue
    ,SUM(a.revenue)/ COUNT(DISTINCT a.device_id) AS ARPDAU
    ,SUM(a.revenue)/ COUNT(DISTINCT(CASE WHEN a.revenue > 0 THEN a.device_id ELSE NULL END)) AS ARPPU
    ,SUM(a.QUANTITY)/ COUNT(DISTINCT(CASE WHEN a.revenue > 0 THEN a.device_id ELSE NULL END)) AS Txn_Buyers
    ,SUM(CASE WHEN a.product LIKE 'picklepack%' THEN 1 ELSE 0 END)/ SUM(a.QUANTITY) AS Pickle_Rick_Purch_Trans
    ,SUM(CASE WHEN a.product LIKE 'clubrickcoupon%' THEN 1 ELSE 0 END)/ SUM(a.QUANTITY) AS Club_Rick_Coupon_Purch_Trans
    ,COUNT(DISTINCT(CASE WHEN a.revenue > 0 THEN a.device_id ELSE NULL END))/ COUNT(DISTINCT a.device_id) AS buyer_DAU
    ,b.first_purchasers/ COUNT(DISTINCT a.device_id) AS New_Buyer_DAU
    ,b.first_purchasers/ COUNT(DISTINCT(CASE WHEN a.install_date = a.session_date THEN a.device_id ELSE null END)) AS New_Buyer_Installs
    ,COUNT(DISTINCT(CASE WHEN a.install_date = a.session_date THEN a.device_id ELSE null END))/ COUNT(DISTINCT a.device_id) AS Installs_DAU
    ,COUNT(DISTINCT(CASE WHEN a.PURCHASE_DATE > c.FIRST_PURCHASE_DATE THEN a.device_id ELSE null END))/ COUNT(DISTINCT a.device_id) AS repeat_buyers_DAU
    ,COUNT(DISTINCT(CASE WHEN e.revenue > 0 THEN e.device_id ELSE null END))/ COUNT(DISTINCT a.device_id) payer_DAU_DAU
    ,COUNT(DISTINCT(CASE WHEN a.PURCHASE_DATE > c.FIRST_PURCHASE_DATE THEN a.device_id ELSE null END))/ COUNT(DISTINCT(CASE WHEN e.revenue > 0 THEN e.device_id ELSE null END)) AS repeat_buyers_payer_DAU
    ,f.thirty_day_payers/ COUNT(DISTINCT(CASE WHEN e.revenue > 0 THEN e.device_id ELSE null END)) AS thirty_day_act_payer_by_Payer_DAU
    ,COUNT(DISTINCT(CASE WHEN a.PURCHASE_DATE > c.FIRST_PURCHASE_DATE THEN a.device_id ELSE null END))/ f.thirty_day_payers AS repeat_buyer_by_thirty_day_payer_dau
FROM POCKET_MORTYS_SESSIONS_PURCHASES a
LEFT JOIN (SELECT 
            first_purchase_Date
            ,COUNT(DISTINCT device_id) AS first_purchasers
           FROM (SELECT 
                    device_id
                    ,MIN(purchase_date) AS first_purchase_Date 
                 FROM POCKET_MORTYS_SESSIONS_PURCHASES 
                 WHERE purchase_date IS NOT null 
                 GROUP BY 1)
           GROUP BY 1) b ON (b.first_purchase_Date = a.session_date)
LEFT JOIN (SELECT 
            device_id
            ,MIN(purchase_date) AS first_purchase_Date
           FROM POCKET_MORTYS_SESSIONS_PURCHASES 
           WHERE purchase_date IS NOT null 
           GROUP BY 1) c ON (c.device_id = a.device_id)
LEFT JOIN (SELECT 
            device_id
            ,purchase_date
           FROM POCKET_MORTYS_SESSIONS_PURCHASES 
           WHERE purchase_date IS NOT null 
           GROUP BY 1,2 
           ORDER BY device_id ASC) d ON (d.device_id = a.device_id) AND (d.purchase_date = a.session_date::DATE)
LEFT JOIN (SELECT 
            device_id
            ,SUM(revenue) AS revenue
           FROM POCKET_MORTYS_SESSIONS_PURCHASES 
           WHERE purchase_date IS NOT null 
           GROUP BY 1) e ON (e.device_id = a.device_id)
LEFT JOIN (SELECT
            session_date
            ,COUNT(DISTINCT device_id) AS thirty_day_payers
           FROM (SELECT
                    session_date
                    ,device_id
                 FROM POCKET_MORTYS_SESSIONS_PURCHASES
                 WHERE revenue > 0 
                 AND session_date BETWEEN DATEADD(DAY,-30,session_date) AND session_date
                 GROUP BY 1,2)
           GROUP BY 1) f ON (f.session_date = a.session_date)
GROUP BY 1, b.first_purchasers, f.thirty_day_payers
ORDER BY date DESC;
