merge into pocket_mortys.pocket_mortys_sessions_purchases t
   using (With merge_source as
        (select DISTINCT  
           s.device_id as device_id,
           s.session_date::date as session_date,
           install_date::date as install_date,
           P.platform as platform,
           s.platform as platform_type,
           p.purchase_date::date as purchase_date,
           p.city as city,
           p.product as product,
           p.revenue as revenue,
           p.quantity as quantity,
           s.location_lat location_lat,
           s.location_lng location_lng,
           s.country country,
           s.language,
           s.region,
           s.device_carrier,
           count(distinct session_id) session_cnt,
           count(distinct case when game_mode = 'CAMPAIGN' then session_id end) campaign_session_cnt,
           count(distinct case when game_mode = 'MULTIPLAYER' then session_id end) multiplayer_session_cnt,
           count(distinct case when game_mode = 'NONE' or game_mode is null then session_id end) null_session_cnt
       --count(distinct session_id) as session_cnt
from pocket_mortys.pocket_mortys_sessions s
left join pocket_mortys.pocket_mortys_purchasers p
                        on p.device_id = s.device_id  
                        and p.event_ts = s.event_ts 
                        and p.platform = s.platform  
        where s.platform is not null 
        and s.session_date::date = current_date-1
--and s.device_id = '35238637-FBF6-40DF-8450-BCDE224A5B6B' 
--where s.platform is null
--cross join pocket_mortys_devices 
--on d.device_id = s.device_id
--where p.platform is not null
  group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,s.device_carrier
              
)

Select distinct * from merge_source
) s
  
  on 
     t.device_id = s.device_id
     and t.session_date = s.session_date
     and t.purchase_date = s.purchase_date
when matched 
and            t.device_id <> s.device_id OR
               t.session_date <> s.session_date OR
               t.purchase_date <> s.purchase_date OR
               t.platform <> s.platform OR
               t.platform_type <> s.platform_type OR
               t.install_date <> s.install_date OR
               t.city <> s.city OR
               t.product <> s.product OR 
               t.revenue <> s.revenue OR
               t.quantity <> s.quantity OR
               t.location_lat <> s.location_lat OR
               t.location_lng <> s.location_lng OR
               t.country <> s.country OR
               t.language <> s.language OR
               t.region <> s.region OR
               t.device_carrier <> s.device_carrier OR
               t.session_cnt <> s.session_cnt OR
               t.campaign_session_cnt <> s.campaign_session_cnt OR
               t.multiplayer_session_cnt <> s.multiplayer_session_cnt OR
               t.null_session_cnt <> s.null_session_cnt 
 then
        update
            set  
               t.device_id = s.device_id,
               t.session_date = s.session_date,
               t.purchase_date = s.purchase_date,
               t.platform = s.platform,
               t.platform_type = s.platform_type,
               t.install_date = s.install_date,
               t.city = s.city,
               t.product = s.product,
               t.revenue = s.revenue,
               t.quantity = s.quantity,
               t.location_lat = s.location_lat,
               t.location_lng = s.location_lng,
               t.country = s.country,
               t.language = s.language, 
               t.region = s.region,
               t.device_carrier = s.device_carrier,
               t.session_cnt = s.session_cnt,
               t.campaign_session_cnt = s.campaign_session_cnt,
               t.multiplayer_session_cnt = s.multiplayer_session_cnt,
               t.null_session_cnt = s.null_session_cnt
    when not matched then
        insert (t.device_id,t.session_date, t.purchase_date, t.platform,t.platform_type,t.install_date,t.city,t.product,t.revenue,t.quantity,t.location_lat,t.country,t.language,t.region, t.device_carrier,t.session_cnt,t.campaign_session_cnt,t.multiplayer_session_cnt,t.null_session_cnt)
        values (s.device_id,s.session_date, s.purchase_date, s.platform,s.platform_type,s.install_date,s.city,s.product,s.revenue,s.quantity,s.location_lat,s.country,s.language,s.region, s.device_carrier,s.session_cnt,s.campaign_session_cnt,s.multiplayer_session_cnt,s.null_session_cnt)
