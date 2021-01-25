merge into pocket_mortys.pocket_mortys_purchasers t
    using (With merge_source as
(select DISTINCT  
            event_time as event_ts,
            device_id as device_id,
            platform as Platform,       
            EVENT_TIME::date as purchase_date, 
            city,
            substring(event_properties:"$productId"::string,29,30) as product,
            event_properties:"$price"::numeric(38,2) as price,
            sum(event_properties:"$revenue"::numeric(38,2)) as revenue,
            sum(event_properties:"$quantity"::numeric(38,2)) as quantity,
            price as total_price
            from pocket_mortys.pocket_mortys_events 
            where amplitude_event_type = 'verified_revenue'
            and device_id not in (select device_id from test_device_cohort)
            --and city <> 'Atlanta' and city <> 'London'
            --and LOCATION_LAT is not null
            and createddatetime::date > current_date - 1--(select max(event_ts::date) from pocket_mortys.pocket_mortys_purchasers)
            group by event_ts,city,device_id,Platform,purchase_date,product, total_price, event_properties 
            --order by purchase_date desc
           
)

Select distinct * from merge_source
) s

on t.device_id = s.device_id
and t.event_ts = s.event_ts
when matched 
and            t.event_ts <> s.event_ts OR
               t.device_id <> s.device_id OR
               t.platform <> s.platform OR 
               t.purchase_date <> s.purchase_date OR
               t.city <> s.city OR
               t.product <> s.product OR
               t.price <> s.price OR
               t.revenue <> s.revenue OR
               t.quantity <> s.quantity OR 
               t.total_price <> s.total_price
 then
        update
            set
                t.event_ts = s.event_ts,
                t.device_id = t.device_id,
                t.platform = s.platform, 
                t.purchase_date = s.purchase_date,
                t.city = s.city,
                t.product = s.product,
                t.price = s.price,
                t.revenue = s.revenue,
                t.quantity = s.quantity,
                t.total_price = s.total_price
    when not matched then
        insert (t.event_ts,t.device_id, t.platform, t.purchase_date,t.city,t.product,t.price,t.revenue,t.quantity,t.total_price)
        values (s.event_ts,s.device_id, s.platform, s.purchase_date,s.city,s.product,s.price,s.revenue,s.quantity,s.total_price)
