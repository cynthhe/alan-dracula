merge into pocket_mortys.pocket_mortys_sessions t
    using (With merge_source as
(with install_dates as (

    select 
        device_id,
        min(event_time::date) as install_date
        from pocket_mortys.pocket_mortys_events
        group by 1
)

    select distinct
      s.event_time as event_ts,
      s.event_properties:"game_mode"::string as game_mode,
      s.device_id as device_id,
      s.platform as platform, 
      s.event_time::date session_date, 
      i.install_date install_date,
      s.session_id,
      count(s.session_id) as session_cnt 
      from pocket_mortys.pocket_mortys_events s
      left join install_dates i
      on i.device_id = s.device_id 
--      where s.event_time::date = '2019-12-05'
 where createddatetime::date > current_date - 1
      and s.device_id not in (select c.device_id from test_device_cohort c) 
      group by 1,2,3,4,5,6,7
      --
 
)
Select distinct * from merge_source
) s

on t.device_id = s.device_id
and t.event_ts = s.event_ts
when matched 
and            t.event_ts <> s.event_ts OR
               t.game_mode <> s.game_mode OR
               t.device_id <> s.device_id OR
               t.platform <> s.platform OR 
               t.session_date <> s.session_date OR
               t.install_date <> s.install_date OR
               t.session_id <> s.session_id OR
               t.session_cnt <> s.session_cnt
 then
        update
            set
                t.event_ts = s.event_ts,
                t.game_mode = s.game_mode, 
                t.device_id = s.device_id,
                t.platform = s.platform, 
                t.install_date = s.install_date,
                t.session_date = s.session_date,
                t.session_id = s.session_id,
                t.session_cnt = s.session_cnt
    when not matched then
        insert (t.event_ts,t.game_mode,t.device_id, t.platform, t.install_date,t.session_date,t.session_id,t.session_cnt)
        values (s.event_ts,s.game_mode,s.device_id, s.platform, s.install_date,s.session_date,s.session_id,s.session_cnt)
