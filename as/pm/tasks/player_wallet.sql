merge into pocket_mortys.pocket_mortys_player_wallet t
   using (

   select b.device_id, b.event_time::date as event_date, b.event_time, b.platform, b.currency_type, b.campaign_blips_and_chitz
         ,b.campaign_schmeckles, b.multiplayer_club_rick_coupons, b.multiplayer_flurbos
   from
   (
      --- this is required to treat back dated data; if an old row is received today but that row is not the latest
      --- user activity then update should not happen since we are keeping the latest event per device and date,
      --- so this sql gets the latest event time per device and date
      select device_id
         ,platform
         ,event_time::date as event_date
         ,max(event_time) as event_time
      from pocket_mortys.pocket_mortys_events
      group by 1,2,3
   ) a,
   (
      select device_id
            ,event_time
            ,platform as platform
            ,MAX(user_properties:"campaign_blips_and_chitz_coupons") as currency_type
            ,MAX(case when user_properties:"campaign_blips_and_chitz_coupons" <>  'Ɛ' then COALESCE(user_properties:"campaign_blips_and_chitz_coupons",0)::numeric(38) end) campaign_blips_and_chitz
            ,MAX(case when user_properties:"campaign_schmeckles" <>  'Ɛ' then COALESCE(user_properties:"campaign_schmeckles",0)::numeric(38) end) campaign_schmeckles
            ,MAX(case when user_properties:"multiplayer_club_rick_coupons" <>  'Ɛ' then COALESCE(user_properties:"multiplayer_club_rick_coupons",0)::numeric(38) end)  multiplayer_club_rick_coupons
            ,MAX(case when user_properties:"multiplayer_flurbos" <>  'Ɛ' then COALESCE(user_properties:"multiplayer_flurbos",0)::numeric(38) end) multiplayer_flurbos
       from pocket_mortys.pocket_mortys_events e
       where createddatetime::date > current_date - 1
     group by 1,2,3
   ) b
   where a.device_id = b.device_id
     and a.event_time = b.event_time
     and a.event_date = b.event_time::date
     and a.platform = b.platform
      ) s
   on     t.device_id = s.device_id
      and t.event_date = s.event_date
      and t.platform = s.platform
   when matched and (
      t.device_id <> s.device_id OR
      t.event_date <> s.event_date OR
      t.platform <> s.platform OR
      t.currency_type <> s.currency_type OR
      t.campaign_blips_and_chitz <> s.campaign_blips_and_chitz OR
      t.campaign_schmeckles <> s.campaign_schmeckles OR
      t.multiplayer_club_rick_coupons <> s.multiplayer_club_rick_coupons OR
      t.multiplayer_flurbos <> s.multiplayer_flurbos ) then
         update set
            t.device_id = s.device_id,
            t.event_date = s.event_date,
            t.platform = s.platform,
            t.currency_type = s.currency_type,
            t.campaign_blips_and_chitz = s.campaign_blips_and_chitz,
            t.campaign_schmeckles = s.campaign_schmeckles,
            t.multiplayer_club_rick_coupons = s.multiplayer_club_rick_coupons,
            t.multiplayer_flurbos = s.multiplayer_flurbos,
            t.last_update_dts = current_timestamp()
   when not matched then
      insert (t.device_id,t.event_date,t.platform,t.currency_type,t.campaign_blips_and_chitz,t.campaign_schmeckles,t.multiplayer_club_rick_coupons,t.multiplayer_flurbos, t.create_dts)
         values (s.device_id,s.event_date,s.platform,s.currency_type,s.campaign_blips_and_chitz,s.campaign_schmeckles,s.multiplayer_club_rick_coupons,s.multiplayer_flurbos, current_timestamp())
