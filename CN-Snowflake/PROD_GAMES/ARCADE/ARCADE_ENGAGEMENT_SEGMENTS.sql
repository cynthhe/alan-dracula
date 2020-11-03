CREATE OR REPLACE VIEW ARCADE_ENGAGEMENT_SEGMENTS AS
SELECT 
    YEAR(date)||LPAD(MONTH(date),2,'0') as yearmonth,
    userid,
    ROUND(AVG(duration)) AS avg_time_per_day_this_month, 
    CASE 
        WHEN avg_time_per_day_this_month BETWEEN 0 AND 3 THEN 'Not engaged'
        WHEN avg_time_per_day_this_month BETWEEN 4 AND 8 THEN 'Engaged'
        WHEN avg_time_per_day_this_month > 8 THEN 'Ultra engaged'
        ELSE 'OTHERS'
        END AS segment
FROM arcade_perday
GROUP BY 1,2;
