use database prod_games;
use schema arcade_proc;
use warehouse prod_games_01;

truncate table game_database;
copy into game_database from
(select $1,$1:event,$1:data,metadata$filename, to_date(substr(metadata$filename,15,10),'YYYY/MM/DD')
from @ARCADE_FIREHOSE_DELTA_STAGE (file_Format => 'util_db.public.json')
) ON_ERROR= ABORT_STATEMENT
PURGE = TRUE;
 

truncate table GDB_gotReward;
insert into GDB_gotReward
select
all_data
,parse_json(all_data):userId as userId
,parse_json(data):figure.title as title
,parse_json(data):figure.rarity.title as rarity
,parse_json(data):figure.uuid as figureId
,parse_json(all_data):status as status
,parse_json(data):origin.achievement.title as origin_title
,parse_json(data):origin.achievement.description as origin_description
,event_date
from game_database
where event = 'gotReward'
and parse_json(data):figure.comingSoon = 'false' 
;


truncate table GDB_unlockedAchievement;
insert into GDB_unlockedAchievement
select
parse_json(data):userUuid as userId
,parse_json(data):achievementUuid as achievementUuid
,parse_json(data):packageType as packageType
,cast(split_part(filename, '/', 3) || '/' || split_part(filename, '/', 4) ||'/'||split_part(filename, '/', 2)  as date) as date
,all_data 
from game_database
where event = 'unlockedAchievement'
;

truncate table GBD_figureAddedToInbox;
insert into GBD_figureAddedToInbox
select 
all_data
,event_date
,parse_json(all_data):userId as userId
,parse_json(data):figure.title as title
,parse_json(data):figure.rarity.title as rarity
,parse_json(data):inboxItemId as inboxItemId
,parse_json(data):type as type
,parse_json(all_data):eventid as eventid
,parse_json(all_data):input.type as input_type
,parse_json(all_data):meta.trace_id as trace_id
,parse_json(all_data):status as status
from GAME_DATABASE where event = 'figureAddedToInbox'
;
 

truncate table GBD_openedInboxItem;
insert into GBD_openedInboxItem
select 
all_data
,event_date
,parse_json(all_data):userId as userId
,parse_json(all_data):eventid as eventid
,parse_json(all_data):meta.trace_id as trace_id
,parse_json(all_data):status as status
from GAME_DATABASE where event like 'openedInboxItem'
;

truncate table shop_inventory;
insert into shop_inventory
select 
all_data
,event_date
,CAST(DATEADD(SECOND,parse_json(data):nextRefreshTime/1000,'1/1/1970') AS DATETIME) as next_refresh_time
,parse_json(data):slot1.title as title_slot1
,parse_json(data):slot1.rarity.title as rarity_slot1
,parse_json(data):slot1.price as price_slot1
,parse_json(data):slot1.points as rarity_points_slot1
,parse_json(data):slot1.uuid as eventid_slot1
,parse_json(data):slot1.salePrice as salePrice_slot1
,parse_json(data):slot1.saleDiscount as saleDiscount_slot1
,parse_json(data):slot1.mysteryFigure as mysteryFigure_slot1
,parse_json(data):slot2.title as title_slot2
,parse_json(data):slot2.rarity.title as rarity_slot2
,parse_json(data):slot2.price as price_slot2
,parse_json(data):slot2.points as rarity_points_slot2
,parse_json(data):slot2.uuid as eventid_slot2
,parse_json(data):slot2.salePrice as salePrice_slot2
,parse_json(data):slot2.saleDiscount as saleDiscount_slot2
,parse_json(data):slot2.mysteryFigure as mysteryFigure_slot2
,parse_json(data):slot3.title as title_slot3
,parse_json(data):slot3.rarity.title as rarity_slot3
,parse_json(data):slot3.price as price_slot3
,parse_json(data):slot3.points as rarity_points_slot3
,parse_json(data):slot3.uuid as eventid_slot3
,parse_json(data):slot3.salePrice as salePrice_slot3
,parse_json(data):slot3.saleDiscount as saleDiscount_slot3
,parse_json(data):slot3.mysteryFigure as mysteryFigure_slot3
,parse_json(all_data):event as event
,parse_json(all_data):eventid as eventid
,parse_json(all_data):status as status
,parse_json(data):slot1.namespace as environment
from GAME_DATABASE where event = 'createdShopInventory'
;

truncate table GBD_gained_Currency;
insert into GBD_gained_Currency
select 
all_data
,event_date
,parse_json(all_data):userId as userId
,parse_json(data):amount as amount
,parse_json(data):currentUserCurrency as currentUserCurrency
,parse_json(data):previousUserCurrency as previousUserCurrency
,parse_json(all_data):eventid as eventid
,parse_json(all_data):input.cmd as cmd
,parse_json(all_data):input.jobid as jobid
,parse_json(all_data):input.itemId as itemId
,parse_json(all_data):meta.trace_id as trace_id
,parse_json(all_data):status as status
from GAME_DATABASE where event = 'gainedCurrency'
;

---------- 
insert into prod_games.arcade.game_database
select * from prod_games.arcade_proc.game_database;

insert into prod_games.arcade.GDB_gotReward
select * from prod_games.arcade_proc.GDB_gotReward;

insert into prod_games.arcade.GDB_unlockedAchievement
select * from prod_games.arcade_proc.GDB_unlockedAchievement;

insert into prod_games.arcade.GBD_figureAddedToInbox
select * from prod_games.arcade_proc.GBD_figureAddedToInbox;

insert into prod_games.arcade.GBD_openedInboxItem
select * from prod_games.arcade_proc.GBD_openedInboxItem;

insert into prod_games.arcade.shop_inventory
select * from prod_games.arcade_proc.shop_inventory;

insert into prod_games.arcade.GBD_gained_Currency
select * from prod_games.arcade_proc.GBD_gained_Currency;
