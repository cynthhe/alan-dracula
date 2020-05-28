use database prod_games;
use schema arcade;
use warehouse wh_default;

-- create capture view
create view capture as
select distinct acr_capture.userid||acr_capture.sessionid||acr_capture.submit_time as id,
userid, sessionid, submit_time, platform, city, country, success
from acr_capture;

-- drop capture view
drop view capture;

-- create result view
create view result as
select distinct acr_result.userid||acr_result.sessionid||acr_result.submit_time as id,
success, acr_result.code
from acr_result;

-- drop result view
drop view result;

-- get the rate of each code firing | capture and result views joined on id
select distinct result.code, count(*)
from result
join capture on (result.id = capture.id)
group by 1
order by result.code;

-- Regina's Charles log (user id: db775dd8-99a8-4de9-973a-da0a2c3adb20)
select *
from capture
join result on (capture.id = result.id)
having userid = 'db775dd8-99a8-4de9-973a-da0a2c3adb20';
