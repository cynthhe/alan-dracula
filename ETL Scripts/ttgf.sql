--------------- Prod Tables ----------------

use database prod_games;
use schema TTGF_PROC;
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
from @TTGF_DELTA/appRunning(file_Format => 'util_db.public.json')
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
from @TTGF_DELTA/appStart(file_Format => 'util_db.public.json')

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
,$1:custom_params:figure as figure
,$1:custom_params:price as price
,$1:custom_params:currency as currency
,$1:custom_params:productID as productID
,$1:custom_params:reason as reason
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
,metadata$filename as original_filename
from @TTGF_DELTA/custom (file_format=> 'util_db.public.json')
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
  from @TTGF_DELTA/deviceInfo(file_Format => 'util_db.public.json')

) ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
--pattern = '.*2019-05-02.*'    -- update this 
;

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
from @TTGF_DELTA/transaction(file_Format => 'util_db.public.json') 

) ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
--pattern = '.*2019-05-02.*'    -- update this 
;
----------------------- inserting into proc tables --------------
--truncate ttgf.apprunning
insert into ttgf.apprunning
select * from ttgf_proc.apprunning_proc;

--truncate ttgf.appstart
insert into ttgf.appstart
select * from ttgf_proc.appstart_proc;

-- truncate ttgf.custom
insert into ttgf.custom
select * from ttgf_proc.custom_proc;

-- truncate ttgf.deviceinfo
insert into ttgf.deviceinfo
select * from ttgf_proc.deviceinfo_proc;

-- truncate ttgf.transaction
insert into ttgf.transaction (amount,appid,city,country,currency,debug_device,platform,productid,receipt,receipt_store,receipt_transactionid,receipt_developerPayload,receipt_Payload,sdk_ver,sessionid,submit_time
,ts,transactionid,type,user_agent,userid,original_filename)
select amount,appid,city,country,currency,debug_device,platform,productid,receipt,receipt_store,receipt_transactionid,receipt_developerPayload,receipt_Payload,sdk_ver,sessionid,submit_time
,ts,transactionid,type,user_agent,userid,original_filename 
From ttgf_proc.transaction_proc
;