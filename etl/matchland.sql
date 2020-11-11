------------------------------------------------------------------  Prod  ------------------------------------------------------------------
-- Use Role <Prod ETL Role>
USE DATABASE PROD_GAMES;
use schema MATCHLAND_PROC;
use warehouse prod_games_01;

-- App Running
TRUNCATE TABLE apprunning_proc;
COPY INTO apprunning_proc FROM (
 select 
 $1:appid
,$1:city
,$1:country
,$1:debug_device
,$1:duration
,$1:platform
,$1:sdk_ver
,$1:sessionid
,CAST(DATEADD(SECOND, $1:submit_time/1000 ,'1/1/1970') AS DATETIME) as submit_time
,CAST(DATEADD(SECOND, $1:ts/1000 ,'1/1/1970') AS DATETIME) as ts
,$1:type
,$1:user_agent
,$1:userid
,metadata$filename
from @MATCHLAND_DELTA/appRunning(file_Format => 'util_db.public.json')
) ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
-- pattern = '.*2019-05-21.*'    -- update this 
;
---- App Start
TRUNCATE TABLE appstart_proc;
COPY INTO appstart_proc FROM (
  select $1:appid
      ,$1:debug_device
      ,$1:duration
      ,$1:platform
      ,$1:sdk_ver
      ,$1:sessionid
      ,CAST(DATEADD(SECOND, $1:submit_time/1000 ,'1/1/1970') AS DATETIME) as submit_time
      ,CAST(DATEADD(SECOND, $1:time_stamp/1000 ,'1/1/1970') AS DATETIME) as time_stamp 
      ,$1:type
      ,$1:user_agent
      ,$1:userid
      ,metadata$filename
from @MATCHLAND_DELTA/appStart(file_Format => 'util_db.public.json')
) ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
-- pattern = '.*2019-05-21.*'    -- update this 
; 


---- Custom
truncate table custom_proc;
COPY INTO custom_proc FROM (
  select 
$1:userid 
,$1:name 
 ---- Custom Param 
 ,$1:custom_params:ad_op as ad_op -- varchar
 ,$1:custom_params:converted_gold as converted_gold -- int
 ,$1:custom_params:currency as currency -- varchar
 ,$1:custom_params:game_level as game_level -- int
 ,$1:custom_params:gem_cost as gem_cost -- float
 ,$1:custom_params:gold_cost as gold_cost -- int
 ,$1:custom_params:hero_name as hero_name -- varchar
 ,$1:custom_params:hero_stars as hero_stars -- int
 ,$1:custom_params:hero_upgrade as hero_upgrade -- varchar
 ,$1:custom_params:item_type as item_type -- int
 ,$1:custom_params:loot_item AS loot_item -- varchar
 ,$1:custom_params:market_item as market_item -- varchar
 ,$1:custom_params:overall_progress as overall_progress -- int
 ,$1:custom_params:package as package -- int 
 ,$1:custom_params:player_level as player_level -- int
 ,$1:custom_params:price as price -- float
 ,$1:custom_params:productid as productid -- varchar
 ,$1:custom_params:quantity as quantity -- int
 ,$1:custom_params:reason as reason -- varchar
 ,$1:custom_params:team_power as team_power -- int
 ,$1:custom_params:timespurchased as timespurchased -- int
 ,$1:custom_params:wave_index as wave_index -- varchar
 ,$1:custom_params:xp_level as xp_level -- int
,$1:custom_params:level AS level -- int
 ---- Gem Spent 
 ,$1:custom_params:shop_speedup as gs_shop_speedup -- int
 ,$1:custom_params:quickloot_refresh as gs_quickloot_refresh -- int
 ,$1:custom_params:gold_converted as gs_gold_converted -- int
 ,$1:custom_params:revive as gs_revive -- int
 ,$1:custom_params:evos as gs_evos -- int
 ,$1:custom_params:energy_big as gs_energy_big -- int
 ,$1:custom_params:energy_small as gs_energy_small -- int
 ,$1:custom_params:gold_package as gs_gold_package -- int
 ,$1:custom_params:spices as gs_spices -- int
 ---- Kochava 
 ,$1:custom_params:campaign as k_campaign -- int
 ,$1:custom_params:campaign_id as k_campaign_id -- int
 ,$1:custom_params:date as k_date -- int
 ,$1:custom_params:network as k_network -- int
 ,$1:custom_params:network_id as k_network_id -- int
 ,$1:custom_params:network_key as k_network_key -- int
 ,$1:custom_params:segment as k_segment -- int
 ,$1:custom_params:tracker as k_tracker -- int
 ,$1:custom_params:tracker_id as k_tracker_id -- int
 ,$1:custom_params:attribution_action as k_attribution_action -- int
 ,$1:custom_params:attribution_prompt as k_attribution_prompt -- int
 ,$1:custom_params:site as k_site -- int
 ,$1:custom_params:site_id as k_site_id -- int
 ---- All My Nulls
 ,case when $1:custom_params:Notifications is null then 'ios' else 'False' end as notifications -- varchar
 ,case when $1:custom_params:Notifications_Android is null then 'android' else 'False' end as Notifications_Android -- varchar
 ,case when $1:custom_params:ads_watched is null then 'True' else 'False' end as ads_watched -- boolean
 ,case when $1:custom_params:cheetahroo is null then 'True' else 'False' end as cheetahroo -- boolean 
 ,case when $1:custom_params:Rate_Us_YEAP is null then 'True' else 'False' end as rated -- boolean
 ,case when $1:custom_params:Rate_Us_NOPE is null then 'False' else 'True' end as didnt_rate -- boolean
--,lower($1:custom_params)
,$1:sessionid 
,CAST(DATEADD(SECOND, $1:submit_time/1000 ,'1/1/1970') AS DATETIME) as submit_time
,CAST(DATEADD(SECOND, $1:ts/1000 ,'1/1/1970') AS DATETIME) as ts
,$1:platform 
,$1:city 
,$1:country 
,$1:type 
,$1:appid
,$1:debug_device
,$1:sdk
,$1:user_agent 
,metadata$filename
from @MATCHLAND_DELTA/custom/(file_Format => 'util_db.public.json')
) 
ON_ERROR=ABORT_STATEMENT
PURGE = TRUE
--pattern = '.*2019-05-21.*'    -- update this 
;
---- Device Info
TRUNCATE TABLE deviceinfo_proc;
COPY INTO deviceinfo_proc FROM (
 select 
  $1:ads_tracking
,$1:app_install_mode
,$1:app_name
,$1:app_ver
,$1:appid
,$1:city
,$1:country
,$1:debug_build
,$1:debug_device
,$1:engine_ver
,$1:license_type
,$1:make
,$1:model
,$1:os_ver
,$1:platform
,$1:processor_type
,$1:rooted_jailbroken
,$1:sdk_ver
,$1:sessionid
,CAST(DATEADD(SECOND, $1:submit_time/1000 ,'1/1/1970') AS DATETIME) as submit_time
,$1:system_memory_size
,$1:timezone
,CAST(DATEADD(SECOND, $1:ts/1000 ,'1/1/1970') AS DATETIME) as ts
,$1:type
,$1:user_agent
,$1:userid
,metadata$filename
  from @MATCHLAND_DELTA/deviceInfo(file_Format => 'util_db.public.json')
) ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
--pattern = '.*2019-05-21.*'    -- update this 
;

-- IAP
--truncate table matchland_proc.iap_proc
--copy into matchland_proc.iap_proc From(
--select 
--$1:AID
--,$1:RECEIPT_TRANSACTIONID
--,$1:create_time
--,$1:response
--,$1:valid
--,metadata$filename
--from @matchland_stage/iap(file_Format => 'util_db.public.json'))
--ON_ERROR= ABORT_STATEMENT
--pattern = '.*2018-11-11.*' -- Currently need to reload this table daily as it has new data being added across the date ranges. Will update as soon as process is complete.
--

---- Transaction
TRUNCATE TABLE transaction_proc3;
Copy INTO transaction_proc3 FROM (                        
 select
 $1:amount as amount
,$1:appid as appid
,$1:city as city
,$1:country as country
,$1:currency as currency
,$1:debug_device as debug_device
,$1:platform as platform
,$1:productid as productid
,$1:receipt
,parse_json($1:receipt.data)['Store'] 
,parse_json($1:receipt.data)['TransactionID'] 
,parse_json($1:receipt.data)['developerPayload']
,parse_json($1:receipt.data)['Payload']
,$1:sdk_ver as sdk_ver
,$1:sessionid as sessionid
,CAST(DATEADD(SECOND, $1:submit_time/1000 ,'1/1/1970') AS DATETIME) as submit_time
,CAST(DATEADD(SECOND, $1:ts/1000 ,'1/1/1970') AS DATETIME) as ts
,$1:transactionid as transactionid
,$1:type
,$1:user_agent
,$1:userid
,metadata$filename
from @MATCHLAND_DELTA/transaction(file_Format => 'util_db.public.json') 
) ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
--pattern = '.*2019-05-21.*'    -- update this 
;

  
-- truncate matchland.apprunning
insert into matchland.apprunning
select * from apprunning_proc;

-- truncate matchland.appstart
insert into matchland.appstart
select * from appstart_proc;

-- truncate matchland.custom
insert into matchland.custom
select * from custom_proc;

-- truncate matchland.deviceinfo
insert into matchland.deviceinfo
select * from deviceinfo_proc;

-- truncate matchland.iap
-- insert into matchland.iap
-- select * from iap_proc

--truncate matchland.transaction
insert into matchland.transaction (amount,appid,city,country,currency,debug_device,platform,productid,receipt,receipt_store,receipt_transactionid,receipt_developerPayload,receipt_Payload,sdk_ver,sessionid,submit_time
,ts,transactionid,type,user_agent,userid,original_filename)
select amount,appid,city,country,currency,debug_device,platform,productid,receipt,receipt_store,receipt_transactionid,receipt_developerPayload,receipt_Payload,sdk_ver,sessionid,submit_time
,ts,transactionid,type,user_agent,userid,original_filename 
From transaction_proc3;
