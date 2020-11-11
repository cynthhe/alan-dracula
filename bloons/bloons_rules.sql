-- rules / date / number of players / total plays
select Rule1||''||Rule2||''||Rule3 as rules
,created_at::Date as date
,count(distinct userid) as players
,count(userid) as plays
//,min(created_at) as start
//,max(created_at) as endtime
from prod_games.bloons.BATMOBILE_STARTMARSTRACK
where created_at::Date >= '6/20/2019'
group by 1,2
having count(distinct userid) > 500;
