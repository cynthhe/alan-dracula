use database dev_games;
use schema arcade_proc;
use warehouse reporting_01;

--CREATE OR REPLACE STAGE Arcade
--URL='s3://unity-stats/cnarcade'
--CREDENTIALS = (aws_role = 'arn:aws:iam::133830846648:role/snowflake-s3-stage-access');
--truncate table game_database;
copy into game_database from
(select $1,$1:event,$1:data,metadata$filename, to_date(substr(metadata$filename,15,10),'YYYY/MM/DD')
from @ARCADE_STG/eventfirehose/2019/06/17 (file_Format => 'util_db.public.json') -- change date here
) ON_ERROR= ABORT_STATEMENT;
 
--Also, in your insert this will work better (avoid LIKE if you can, it never gives you good performance but sometimes you gotta do what you gotta do);
--truncate  GDB_gotReward;
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
  and event_date  = TO_DATE('20190617','YYYYMMDD') -- change date here
  ;


--truncate GDB_unlockedAchievement;
insert into GDB_unlockedAchievement
select
parse_json(data):userUuid as userId
,parse_json(data):achievementUuid as achievementUuid
,parse_json(data):packageType as packageType
,cast(split_part(filename, '/', 3) || '/' || split_part(filename, '/', 4) ||'/'||split_part(filename, '/', 2)  as date) as date
,all_data
 
from game_database
where event = 'unlockedAchievement'
 and event_date  = TO_DATE('20190617','YYYYMMDD'); -- change date here
