use database prod_games;
use schema party_dash_proc;
use warehouse prod_games_01;

---------- App Running
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
from @PARTY_DASH_DELTA/appRunning(file_Format => 'util_db.public.json')
) ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
--pattern = '.*2019-05-02.*'    -- update this 
;

---- Appstart
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
from @PARTY_DASH_DELTA/appStart(file_Format => 'util_db.public.json')

) ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
--pattern = '.*2019-05-02.*'    -- update this 
;



--- Custom

truncate table custom_proc;
COPY INTO custom_proc FROM (
 select 
$1:userid 
,$1:name 
,$1:sessionid 
,CAST(DATEADD(SECOND, $1:submit_time/1000 ,'1/1/1970') AS DATETIME) as submit_time
,CAST(DATEADD(SECOND, $1:ts/1000 ,'1/1/1970') AS DATETIME) as ts
,$1:platform 
,$1:city 
,$1:country 
,$1:type 
,$1:appid
,$1:debug_device
,$1:sdk_ver
,$1:user_agent
,$1:custom_params 
,$1:custom_params:site as site
,$1:custom_params:type as cptype
,$1:custom_params:name as cpname
,$1:custom_params:time as time
,$1:custom_params:currency as currency
,$1:custom_params:price as price 
,$1:custom_params:productID as productID
,$1:custom_params:reason as reason
,$1:custom_params:attribution_action as attribution_action
,$1:custom_params:attribution_prompt as attribution_prompt
,$1:custom_params:campaign as campaign
,$1:custom_params:network as network
,$1:custom_params:segment as segment 
,metadata$filename as original_filename
from @PARTY_DASH_DELTA/custom (file_format=> 'util_db.public.json') 
) 
ON_ERROR=ABORT_STATEMENT
PURGE = TRUE
--pattern = '.*2019-05-02.*'    -- update this 
;

--- Device Info  
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
  from @PARTY_DASH_DELTA/deviceInfo(file_Format => 'util_db.public.json')

) ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
--pattern = '.*2019-05-02.*'    -- update this 
;

--- Transaction
TRUNCATE TABLE transaction_proc;
COPY INTO transaction_proc FROM (                            
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
from @PARTY_DASH_DELTA/transaction(file_Format => 'util_db.public.json') 

) ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
--pattern = '.*2019-05-02.*'    -- update this 
;

----------------------- inserting into proc tables --------------
use schema PARTY_DASH;

--truncate PARTY_DASH.apprunning
insert into PARTY_DASH.apprunning
select * from PARTY_DASH_PROC.apprunning_proc;

--truncate PARTY_DASH.appstart
insert into PARTY_DASH.appstart
select * from PARTY_DASH_PROC.appstart_proc;

--truncate PARTY_DASH.custom
insert into PARTY_DASH.custom
select * from PARTY_DASH_PROC.custom_proc;

--truncate PARTY_DASH.deviceinfo
insert into PARTY_DASH.deviceinfo
select * from PARTY_DASH_PROC.deviceinfo_proc;

--truncate PARTY_DASH.transaction
insert into PARTY_DASH.transaction (amount,appid,city,country,currency,debug_device,platform,productid,receipt,receipt_store,receipt_transactionid,receipt_developerPayload,receipt_Payload,sdk_ver,sessionid,submit_time
,ts,transactionid,type,user_agent,userid,original_filename)
select amount,appid,city,country,currency,debug_device,platform,productid,receipt,receipt_store,receipt_transactionid,receipt_developerPayload,receipt_Payload,sdk_ver,sessionid,submit_time
,ts,transactionid,type,user_agent,userid,original_filename 
From PARTY_DASH_PROC.transaction_proc;
