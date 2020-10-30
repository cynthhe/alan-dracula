-- Version 1.0.1
-- Add Arcade 2.1 statistics data

use database prod_games;
use schema arcade_proc;
use warehouse prod_games_01;

-------------------------------------------------- Unity Tables --------------------------------------------------

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
from @ARCADE_DELTA/appRunning(file_Format => 'util_db.public.json')
) ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
--pattern = '.*2019-03-29.*'    -- update this 
;


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
from @ARCADE_DELTA/appStart(file_Format => 'util_db.public.json')

) ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
--pattern = '.*2018-10-26.*'    -- update this 
;

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
,$1:sdk
,$1:user_agent 
,replace($1:custom_params, 'NaN', '0') as custom_params
,metadata$filename as original_filename
from @ARCADE_DELTA/custom (file_format=> 'util_db.public.json')
) 
ON_ERROR=ABORT_STATEMENT
PURGE = TRUE
--pattern = '.*2018-10-26.*'    -- update this 
;

  
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
  from @ARCADE_DELTA/deviceInfo(file_Format => 'util_db.public.json')

) ON_ERROR= ABORT_STATEMENT 
PURGE = TRUE
--pattern = '.*2018-10-26.*'    -- update this 
;


TRUNCATE TABLE transaction_proc;
Copy INTO transaction_proc FROM (                        
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
from @ARCADE_DELTA/transaction(file_Format => 'util_db.public.json') 

) ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
--pattern = '.*2018-10-26.*'    -- update this 
;
TRUNCATE table Kochava_player;
Insert INTO Kochava_player 
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,parse_json(custom_params):attribution_action as attribution_action
,parse_json(custom_params):attribution_prompt as attribution_prompt
,parse_json(custom_params):campaign as campaign
,parse_json(custom_params):campaign_id as campaign_id
,parse_json(custom_params):network as network
,parse_json(custom_params):network_key as network_key
,parse_json(custom_params):segment as segment
,parse_json(custom_params):site as site
,parse_json(custom_params):site_id as site_id
,parse_json(custom_params):tracker_id as tracker_id
from custom_proc
where name like 'Kochava_player'     
--and original_filename like '%2019-1-26%' -- update this 
;

truncate table acr_capture;
Insert INTO acr_capture 
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,parse_json(custom_params):capture_id as capture_id
,CAST(DATEADD(SECOND, parse_json(custom_params):capture_time ,'1/1/1970') AS DATETIME) as capture_time
,parse_json(custom_params):episode_name as episode_name
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin
,parse_json(custom_params):success as success
,parse_json(custom_params):figure_granted as figure_granted
from custom_proc
where name like 'acr_capture'     
--and original_filename like '%2019-1-26%' -- update this 
;

-- 12/16/2019 CDAP-26 updated achievement script
TRUNCATE TABLE arcade_proc.achievement;
Insert INTO arcade_proc.achievement
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,CAST(DATEADD(SECOND, parse_json(custom_params):achievement_datetime,'1/1/1970') AS DATETIME) as achievement_datetime
,parse_json(custom_params):achievement_name as achievement_name
,parse_json(custom_params):event_interaction as event_interaction
,parse_json(custom_params):game_interaction_location as game_interaction_location
,parse_json(custom_params):game_name as game_name
,parse_json(custom_params):game_session_id as game_session_id
,parse_json(custom_params):game_show_name as game_show_name
,parse_json(custom_params):interaction as interaction
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin
---- The fields below are new/need to be added
,parse_json(custom_params):adobe_id as adobe_id
,parse_json(custom_params):app_version as app_version
,parse_json(custom_params):award_type as award_type
,parse_json(custom_params):currency_granted as currency_granted
,parse_json(custom_params):rank_number as rank_number

from arcade_proc.custom_proc
where name like 'achievement'  ;

TRUNCATE TABLE ad;
Insert INTO ad
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,parse_json(custom_params):ad_offered as ad_offered
,parse_json(custom_params):ad_provider as ad_provider
,parse_json(custom_params):app_location as app_location
,CAST(DATEADD(SECOND, parse_json(custom_params):finished_datetime ,'1/1/1970') AS DATETIME) as finished_datetime
,CAST(DATEADD(SECOND, parse_json(custom_params):offered_datetime,'1/1/1970') AS DATETIME) as offered_datetime
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin

from custom_proc
where name like 'ad';

TRUNCATE TABLE deeplink;
Insert INTO deeplink
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,CAST(DATEADD(SECOND,parse_json(custom_params):datetime_clicked,'1/1/1970') AS DATETIME) as datetime_clicked
,parse_json(custom_params):deeplink as deeplink
,parse_json(custom_params):play_userloggedin as play_userloggedin
from custom_proc
where name like 'deeplink';

TRUNCATE TABLE delete_account;
Insert INTO delete_account
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,CAST(DATEADD(SECOND,parse_json(custom_params):delete_account_datetime,'1/1/1970') AS DATETIME) as delete_account_datetime
,parse_json(custom_params):delete_account_location as delete_account_location
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin
from custom_proc
where name like 'delete_account'  ;

truncate table favorite_added;
Insert INTO favorite_added
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,CAST(DATEADD(SECOND,parse_json(custom_params):date_favorited,'1/1/1970') AS DATETIME) as date_favorited
,parse_json(custom_params):name as game_name
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin
from custom_proc
where name like 'favorite_added'  ;

truncate table favorite_removed;
Insert INTO favorite_removed
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,CAST(DATEADD(SECOND,parse_json(custom_params):date_unfavorited,'1/1/1970') AS DATETIME) as date_unfavorited
,parse_json(custom_params):name as game_name
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin
from custom_proc
where name like 'favorite_removed'  ;

truncate table feed;
Insert INTO feed
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,CAST(DATEADD(SECOND,parse_json(custom_params):entry_time,'1/1/1970') AS DATETIME) as entry_time
,CAST(DATEADD(SECOND,parse_json(custom_params):exit_time,'1/1/1970') AS DATETIME) as exit_time
,parse_json(custom_params):feed_itemscount as feed_itemscount
,parse_json(custom_params):feed_name as feed_name
,replace(parse_json(custom_params):feed_scroll,',','.') as feed_scroll
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin
from custom_proc
where name like 'feed'  ;

truncate table game_highscore;
Insert INTO game_highscore
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,parse_json(custom_params):event_interaction as event_interaction
,parse_json(custom_params):game_interaction_location as game_interaction_location
,parse_json(custom_params):game_name as game_name
,parse_json(custom_params):game_session_id as game_session_id
,parse_json(custom_params):game_show_name as game_show_name
,parse_json(custom_params):high_score as high_score
,parse_json(custom_params):interaction as interaction
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin
,CAST(DATEADD(SECOND,parse_json(custom_params):score_datetime,'1/1/1970') AS DATETIME) as score_datetime

from custom_proc
where name like 'game_highscore'  ;

truncate table game_open;
Insert INTO game_open
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,CAST(DATEADD(SECOND,parse_json(custom_params):entry_time,'1/1/1970') AS DATETIME) as entry_time
,parse_json(custom_params):game_name as game_name
,parse_json(custom_params):game_session_id as game_session_id
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin


from custom_proc
where name like 'game_open'  ;

truncate table game_start;
Insert INTO game_start
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,parse_json(custom_params):event_gamestart as event_gamestart
,parse_json(custom_params):event_interaction as event_interaction
,parse_json(custom_params):game_interaction_location as game_interaction_location
,parse_json(custom_params):game_name as game_name
,parse_json(custom_params):game_session_id as game_session_id
,parse_json(custom_params):game_show_name as game_show_name
,parse_json(custom_params):interaction as interaction
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin

from custom_proc
where name like 'game_start'  ;

truncate table logged_in;
Insert INTO logged_in
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,CAST(DATEADD(SECOND,parse_json(custom_params):login_datetime,'1/1/1970') AS DATETIME) as login_datetime
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin

from custom_proc
where name like 'logged_in'  ;

truncate table logout;
Insert INTO logout
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,CAST(DATEADD(SECOND,parse_json(custom_params):logout_datetime,'1/1/1970') AS DATETIME) as logout_datetime
,parse_json(custom_params):logout_location as logout_location
,parse_json(custom_params):play_userloggedin as play_userloggedin

from custom_proc
where name like 'logout'  ;

truncate table navigation;
Insert INTO navigation
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,parse_json(custom_params):button_clicked as button_clicked
,CAST(DATEADD(SECOND,parse_json(custom_params):clicked_time,'1/1/1970') AS DATETIME) as clicked_time
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin

from custom_proc
where name like 'navigation'  ;

truncate table registered;
Insert INTO registered
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,parse_json(custom_params):play_userid as play_userid
,CAST(DATEADD(SECOND,parse_json(custom_params):registration_datetime,'1/1/1970') AS DATETIME) as registration_datetime
,parse_json(custom_params):registration_location as registration_location

from custom_proc
where name like 'registered'  ;

truncate table screen_visit;
Insert INTO screen_visit
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,parse_json(custom_params):previous_screen as previous_screen
,parse_json(custom_params):screen_name as screen_name
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin
from custom_proc
where name like 'screen_visit'  ;

truncate table stunt_open;
Insert INTO stunt_open
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,CAST(DATEADD(SECOND,parse_json(custom_params):entry_time,'1/1/1970') AS DATETIME) as entry_time
,parse_json(custom_params):stunt_name as stunt_name
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin
from custom_proc
where name like 'stunt_open'  ;

truncate table prod_games.arcade_proc.game_exit;
Insert INTO prod_games.arcade_proc.game_exit
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,CAST(DATEADD(SECOND, parse_json(custom_params):exit_time ,'1/1/1970') AS DATETIME) as exit_time
,parse_json(custom_params):game_name as game_name
,parse_json(custom_params):game_session_id as game_session_id
,parse_json(custom_params):package_id as package_id
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin
from custom_proc
where name like 'game_exit';

truncate table prod_games.arcade_proc.stunt_exit;
Insert INTO prod_games.arcade_proc.stunt_exit 
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,CAST(DATEADD(SECOND, parse_json(custom_params):exit_time ,'1/1/1970') AS DATETIME) as exit_time
,parse_json(custom_params):package_id as package_id
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin
,parse_json(custom_params):stunt_name as stunt_name
,parse_json(custom_params):stunt_session_id as stunt_session_id
from custom_proc
where name like 'stunt_exit'     
;

truncate table prod_games.arcade_proc.card_click;
Insert INTO prod_games.arcade_proc.card_click 
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,parse_json(custom_params):card_destination as card_destination
,parse_json(custom_params):card_id as card_id
,replace(parse_json(custom_params):card_position,',','.') as card_position
,parse_json(custom_params):card_property as card_property
,parse_json(custom_params):card_title as card_title
,CAST(DATEADD(SECOND, parse_json(custom_params):clicked_time ,'1/1/1970') AS DATETIME) as clicked_time
,parse_json(custom_params):feed_name as feed_name
,parse_json(custom_params):game_name as game_name
,parse_json(custom_params):package_id as package_id
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin

from custom_proc
where name like 'card_click';

--truncate prod_games.arcade.achievement
insert into prod_games.arcade.achievement
select * from  prod_games.arcade_proc.achievement;

--truncate prod_games.arcade.ACR_CAPTURE
insert into prod_games.arcade.ACR_CAPTURE
select * from  prod_games.arcade_proc.ACR_CAPTURE;

--truncate prod_games.arcade.AD
insert into prod_games.arcade.AD
select * from  prod_games.arcade_proc.AD;

--truncate prod_games.arcade.APPRUNNING
insert into prod_games.arcade.APPRUNNING
select * from  prod_games.arcade_proc.APPRUNNING_proc;

--truncate prod_games.arcade.APPSTART
insert into prod_games.arcade.APPSTART
select * from  prod_games.arcade_proc.APPSTART_proc;

--truncate prod_games.arcade.custom
insert into prod_games.arcade.custom
select * from  prod_games.arcade_proc.custom_proc;

--truncate prod_games.arcade.DEEPLINK
insert into prod_games.arcade.DEEPLINK
select * from  prod_games.arcade_proc.DEEPLINK;

--truncate prod_games.arcade.DELETE_ACCOUNT
insert into prod_games.arcade.DELETE_ACCOUNT
select * from  prod_games.arcade_proc.DELETE_ACCOUNT;

--truncate prod_games.arcade.DEVICEINFO
insert into prod_games.arcade.DEVICEINFO
select * from  prod_games.arcade_proc.DEVICEINFO_proc;

--truncate prod_games.arcade.FAVORITE_ADDED
insert into prod_games.arcade.FAVORITE_ADDED
select * from  prod_games.arcade_proc.FAVORITE_ADDED;

--truncate prod_games.arcade.FAVORITE_REMOVED
insert into prod_games.arcade.FAVORITE_REMOVED
select * from  prod_games.arcade_proc.FAVORITE_REMOVED;

--truncate prod_games.arcade.FEED
insert into prod_games.arcade.FEED
select * from  prod_games.arcade_proc.FEED;

--truncate prod_games.arcade.GAME_HIGHSCORE
insert into prod_games.arcade.GAME_HIGHSCORE
select * from  prod_games.arcade_proc.GAME_HIGHSCORE;

--truncate prod_games.arcade.GAME_OPEN
insert into prod_games.arcade.GAME_OPEN
select * from  prod_games.arcade_proc.GAME_OPEN;

--truncate prod_games.arcade.GAME_START
insert into prod_games.arcade.GAME_START
select * from  prod_games.arcade_proc.GAME_START;

--truncate prod_games.arcade.KOCHAVA_PLAYER
insert into prod_games.arcade.KOCHAVA_PLAYER
select * from  prod_games.arcade_proc.KOCHAVA_PLAYER;

--truncate prod_games.arcade.LOGGED_IN
insert into prod_games.arcade.LOGGED_IN
select * from  prod_games.arcade_proc.LOGGED_IN;

--truncate prod_games.arcade.LOGOUT
insert into prod_games.arcade.LOGOUT
select * from  prod_games.arcade_proc.LOGOUT;

--truncate prod_games.arcade.NAVIGATION
insert into prod_games.arcade.NAVIGATION
select * from  prod_games.arcade_proc.NAVIGATION;

--truncate prod_games.arcade.REGISTERED
insert into prod_games.arcade.REGISTERED
select * from  prod_games.arcade_proc.REGISTERED;

--truncate prod_games.arcade.SCREEN_VISIT
insert into prod_games.arcade.SCREEN_VISIT
select * from  prod_games.arcade_proc.SCREEN_VISIT;

--truncate prod_games.arcade.STUNT_OPEN
insert into prod_games.arcade.STUNT_OPEN
select * from  prod_games.arcade_proc.STUNT_OPEN;

--truncate prod_games.arcade.TRANSACTION
insert into prod_games.arcade.TRANSACTION
select * from  prod_games.arcade_proc.TRANSACTION_proc;

--truncate prod_games.arcade.game_exit
insert into prod_games.arcade.game_exit
select * from prod_games.arcade_proc.game_exit;

--truncate prod_games.arcade.stunt_exit
insert into prod_games.arcade.stunt_exit
select * from prod_games.arcade_proc.stunt_exit;

--truncate prod_games.arcade.card_click
insert into prod_games.arcade.card_click
select * from prod_games.arcade_proc.card_click;

-- 12/16/2019 CDAP-26
--- this is for the insert into proc portion of the ETL
-- Purchase table
truncate table arcade_proc.purchase;
Insert INTO arcade_proc.purchase
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,parse_json(custom_params):adobe_id as adobe_id
,parse_json(custom_params):app_version as app_version
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin
,parse_json(custom_params):purchase_currency as purchase_currency
,parse_json(custom_params):purchased_item_id as purchased_item_id
,parse_json(custom_params):purchased_item_name as purchased_item_name
,parse_json(custom_params):purchased_item_price as purchased_item_price
,parse_json(custom_params):shop_interaction_id as shop_interaction_id

from arcade_proc.custom_proc
where name like 'purchase'  ;

truncate arcade_proc.currency_claimed;
Insert INTO arcade_proc.currency_claimed
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,parse_json(custom_params):adobe_id as adobe_id
,parse_json(custom_params):app_version as app_version
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin
,parse_json(custom_params):currency_amount as currency_amount
,parse_json(custom_params):currency_type as currency_type
,parse_json(custom_params):granting_action as granting_action
,parse_json(custom_params):new_balance as new_balance
,parse_json(custom_params):previous_balance as previous_balance
,parse_json(custom_params):timestamp as timestamp

from arcade_proc.custom_proc
where name like 'currency_claimed' ;

truncate arcade_proc.you_carousel;
Insert INTO arcade_proc.you_carousel
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,parse_json(custom_params):adobe_id as adobe_id
,parse_json(custom_params):app_version as app_version
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin
,REPLACE(parse_json(custom_params):carousel_scroll_left,',','.') as carousel_scroll_left
,REPLACE(parse_json(custom_params):carousel_scroll_right,',','.') as carousel_scroll_right
,parse_json(custom_params):game_id as game_id
,parse_json(custom_params):game_name as game_name
,parse_json(custom_params):timestamp as timestamp

from arcade_proc.custom_proc
where name like 'you_carousel' ;


truncate arcade_proc.app_version;
Insert INTO arcade_proc.app_version
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,parse_json(custom_params):app_version as app_version

from arcade_proc.custom_proc
where name like 'app_version' ;

--- this is for the insert into prod portion of the ETL

insert into arcade.purchase
select * from arcade_proc.purchase;

insert into arcade.currency_claimed
select * from arcade_proc.currency_claimed;

insert into arcade.you_carousel
select * from arcade_proc.you_carousel;

insert into arcade.app_version
select * from arcade_proc.app_version;


-- CNO-1607: include 2.1 events
-- populate processing tables
truncate table arcade_proc.daily_challenge_proc;
insert into arcade_proc.daily_challenge_proc
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,parse_json(custom_params):adobe_id as adobe_id
,parse_json(custom_params):amount as amount
,parse_json(custom_params):app_version as app_version
,CAST(DATEADD(SECOND, parse_json(custom_params):expiration,'1/1/1970') AS DATETIME) as expiration
,parse_json(custom_params):game_id as game_id
,parse_json(custom_params):game_name as game_name
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin
,parse_json(custom_params):reward_type as reward_type
,parse_json(custom_params):score as score

from arcade_proc.custom_proc
where name like 'daily_challenge';

truncate table arcade_proc.currency_rewarded_proc;
insert into arcade_proc.currency_rewarded_proc
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,parse_json(custom_params):adobe_id as adobe_id
,parse_json(custom_params):amount as amount
,parse_json(custom_params):app_version as app_version
,parse_json(custom_params):currency_amount as currency_amount
,parse_json(custom_params):currency_type as currency_type
,parse_json(custom_params):new_balance as new_balance
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin
,parse_json(custom_params):previous_balance as previous_balance

from arcade_proc.custom_proc
where name like 'currency_rewarded';

truncate table arcade_proc.challenge_complete_proc;
insert into arcade_proc.challenge_complete_proc
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,parse_json(custom_params):adobe_id as adobe_id
,parse_json(custom_params):app_version as app_version
,parse_json(custom_params):award_type as award_type
,parse_json(custom_params):event_interaction as event_interaction
,parse_json(custom_params):game_interaction_location as game_interaction_location
,parse_json(custom_params):game_name as game_name
,parse_json(custom_params):game_session_id as game_session_id
,parse_json(custom_params):game_show_name as game_show_name
,parse_json(custom_params):goal as goal
,parse_json(custom_params):interaction as interaction
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin
,parse_json(custom_params):reward as reward


from arcade_proc.custom_proc
where name like 'challenge_complete';

truncate table arcade_proc.preference_change_proc;
insert into arcade_proc.preference_change_proc
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,parse_json(custom_params):adobe_id as adobe_id
,parse_json(custom_params):app_version as app_version
,CAST(DATEADD(SECOND, parse_json(custom_params):clicked_time,'1/1/1970') AS DATETIME) as clicked_time
,parse_json(custom_params):notifications_enabled as notifications_enabled
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin

from arcade_proc.custom_proc
where name like 'preference_change';

truncate table arcade_proc.daily_reward_proc;
insert into arcade_proc.daily_reward_proc
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,parse_json(custom_params):adobe_id as adobe_id
,parse_json(custom_params):app_version as app_version
,parse_json(custom_params):amount as amount
,parse_json(custom_params):item as item
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin
,parse_json(custom_params):skip_button as skip_button

from arcade_proc.custom_proc
where name like 'daily_reward';

truncate table arcade_proc.acr_result;
insert into arcade_proc.acr_result
select 
userid 
,name 
,sessionid 
,submit_time
,ts
,platform 
,city 
,country 
,type 
,appid
,debug_device
,sdk
,user_agent 
,custom_params 
,original_filename
,parse_json(custom_params):acr_version as acr_version
,parse_json(custom_params):adobe_id as adobe_id
,parse_json(custom_params):app_version as app_version
,parse_json(custom_params):bucket_granted_id as bucket_granted_id
,parse_json(custom_params):capture_id as capture_id
,CAST(DATEADD(SECOND, parse_json(custom_params):capture_time,'1/1/1970') AS DATETIME) as capture_time
,parse_json(custom_params):code as code
,parse_json(custom_params):episode_name as episode_name
,parse_json(custom_params):play_userid as play_userid
,parse_json(custom_params):play_userloggedin as play_userloggedin
,parse_json(custom_params):success as success


from arcade_proc.custom_proc
where name like 'acr_result';

-- populate live Table
insert into arcade.daily_challenge 
select * from arcade_proc.daily_challenge_proc;

insert into arcade.currency_rewarded 
select * from arcade_proc.currency_rewarded_proc;

insert into arcade.challenge_complete 
select * from arcade_proc.challenge_complete_proc;

insert into arcade.preference_change 
select * from arcade_proc.preference_change_proc;

insert into arcade.daily_reward 
select * from arcade_proc.daily_reward_proc;

insert into arcade.acr_result
select * from arcade_proc.acr_result;