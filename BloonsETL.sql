use database dev_games;
use schema bloons_proc;
use warehouse reporting_01;

-------- inserting into dev_games bloons_proc
truncate batmobile_startsession;
COPY into batmobile_startsession from(
select $1 as userid, $2 as created_at, $3 as client_version, $4 as platform, $5 as country, $6 as session_id
from @ninja_kiwi_stage/batmobile/2018 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
pattern = '.*batmobile_startsession_000.gz.*'
;
COPY into batmobile_startsession from(
select $1 as userid, $2 as created_at, $3 as client_version, $4 as platform, $5 as country, $6 as session_id
from @ninja_kiwi_stage/batmobile/2019 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
pattern = '.*batmobile_startsession_000.gz.*'
;

truncate batmobile_z_user;
COPY into batmobile_z_user from(
select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16
from @ninja_kiwi_stage/batmobile (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
pattern = '.*batmobile_z_user_000.gz.*'
;
truncate batmobile_verifiediap_view;
COPY into batmobile_verifiediap_view from(
select $1,$2,$3,$4
from @ninja_kiwi_stage/batmobile/2018 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
pattern = '.*batmobile_verifiediap_view_000.gz.*'
;
COPY into batmobile_verifiediap_view from(
select $1,$2,$3,$4
from @ninja_kiwi_stage/batmobile/2019 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
pattern = '.*batmobile_verifiediap_view_000.gz.*'
;

truncate batmobile_accountmerged;
COPY into batmobile_accountmerged from(
select $1,$2,$3,$4
from @ninja_kiwi_stage/batmobile/2018  (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
pattern = '.*batmobile_accountmerged_000.gz.*'
;
COPY into batmobile_accountmerged from(
select $1,$2,$3,$4
from @ninja_kiwi_stage/batmobile/2019  (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
pattern = '.*batmobile_accountmerged_000.gz.*'
;

truncate batmobile_starttrack;
COPY into batmobile_starttrack from(
select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14
from @ninja_kiwi_stage/batmobile/2018 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
pattern = '.*batmobile_starttrack_000.gz.*';
COPY into batmobile_starttrack from(
select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14
from @ninja_kiwi_stage/batmobile/2019 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
pattern = '.*batmobile_starttrack_000.gz.*';

truncate batmobile_placecharacter;
COPY into batmobile_placecharacter from(
select $1,$2,$3,$4,$5,$6,$7,$8
from @ninja_kiwi_stage/batmobile/2018 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
pattern = '.*batmobile_placecharacter_000.gz.*';
COPY into batmobile_placecharacter from(
select $1,$2,$3,$4,$5,$6,$7,$8
from @ninja_kiwi_stage/batmobile/2019 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
pattern = '.*batmobile_placecharacter_000.gz.*';

truncate dev_games.bloons_proc.batmobile_kochava;
COPY into dev_games.bloons_proc.batmobile_kochava from(
select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13
from @ninja_kiwi_stage/batmobile/2018 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
pattern = '.*batmobile_kochava_000.gz.*';
COPY into dev_games.bloons_proc.batmobile_kochava from(
select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13
from @ninja_kiwi_stage/batmobile/2019 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
pattern = '.*batmobile_kochava_000.gz.*';

truncate dev_games.bloons_proc.batmobile_buyitem;
COPY into dev_games.bloons_proc.batmobile_buyitem from(
select $1,$2,$3,$4,$5,$6
from @ninja_kiwi_stage/batmobile/2018 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
pattern = '.*batmobile_buyitem_000.gz.*';
COPY into dev_games.bloons_proc.batmobile_buyitem from(
select $1,$2,$3,$4,$5,$6
from @ninja_kiwi_stage/batmobile/2019 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
pattern = '.*batmobile_buyitem_000.gz.*';

truncate dev_games.bloons_proc.batmobile_firstsession;
COPY into dev_games.bloons_proc.batmobile_firstsession from(
select $1,$2,$3,$4,$5,$6
from @ninja_kiwi_stage/batmobile/2018 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
pattern = '.*batmobile_firstsession_000.gz.*';
COPY into dev_games.bloons_proc.batmobile_firstsession from(
select $1,$2,$3,$4,$5,$6
from @ninja_kiwi_stage/batmobile/2019 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
pattern = '.*batmobile_firstsession_000.gz.*';

truncate batmobile_endtrack;
COPY into batmobile_endtrack from(
select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16
from @ninja_kiwi_stage/batmobile/2018 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
pattern = '.*batmobile_endtrack_000.gz.*'
;
COPY into batmobile_endtrack from(
select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16
from @ninja_kiwi_stage/batmobile/2019 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
pattern = '.*batmobile_endtrack_000.gz.*'
;

---------- insert into dev_games bloons
truncate dev_games.bloons.batmobile_startsession;
insert into dev_games.bloons.batmobile_startsession 
select * from dev_games.bloons_proc.batmobile_startsession;

truncate dev_games.bloons.batmobile_z_user;
insert into dev_games.bloons.batmobile_z_user 
select * from dev_games.bloons_proc.batmobile_z_user;

truncate dev_games.bloons.batmobile_verifiediap_view;
insert into dev_games.bloons.batmobile_verifiediap_view 
select * from dev_games.bloons_proc.batmobile_verifiediap_view;

truncate dev_games.bloons.batmobile_accountmerged;
insert into dev_games.bloons.batmobile_accountmerged 
select * from dev_games.bloons_proc.batmobile_accountmerged;

truncate dev_games.bloons.batmobile_starttrack;
insert into dev_games.bloons.batmobile_starttrack 
select * from dev_games.bloons_proc.batmobile_starttrack;

truncate dev_games.bloons.batmobile_placecharacter;
insert into dev_games.bloons.batmobile_placecharacter 
select * from dev_games.bloons_proc.batmobile_placecharacter;

truncate dev_games.bloons.batmobile_kochava;
insert into dev_games.bloons.batmobile_kochava 
select * from dev_games.bloons_proc.batmobile_kochava;

truncate dev_games.bloons.batmobile_buyitem;
insert into dev_games.bloons.batmobile_buyitem 
select * from dev_games.bloons_proc.batmobile_buyitem;

truncate dev_games.bloons.batmobile_firstsession;
insert into dev_games.bloons.batmobile_firstsession 
select * from dev_games.bloons_proc.batmobile_firstsession;

truncate dev_games.bloons.batmobile_endtrack;
insert into dev_games.bloons.batmobile_endtrack 
select * from dev_games.bloons_proc.batmobile_endtrack;

---------- insert into prod_games bloons_proc (need to start pulling from the stage, still to come lol)---

truncate prod_games.bloons_proc.batmobile_startsession;
insert into prod_games.bloons_proc.batmobile_startsession 
select * from dev_games.bloons_proc.batmobile_startsession;

truncate prod_games.bloons_proc.batmobile_z_user;
insert into prod_games.bloons_proc.batmobile_z_user 
select * from dev_games.bloons_proc.batmobile_z_user;

truncate prod_games.bloons_proc.batmobile_verifiediap_view;
insert into prod_games.bloons_proc.batmobile_verifiediap_view 
select * from dev_games.bloons_proc.batmobile_verifiediap_view;

truncate prod_games.bloons_proc.batmobile_accountmerged;
insert into prod_games.bloons_proc.batmobile_accountmerged 
select * from dev_games.bloons_proc.batmobile_accountmerged;

truncate prod_games.bloons_proc.batmobile_starttrack;
insert into prod_games.bloons_proc.batmobile_starttrack 
select * from dev_games.bloons_proc.batmobile_starttrack;

truncate prod_games.bloons_proc.batmobile_placecharacter;
insert into prod_games.bloons_proc.batmobile_placecharacter 
select * from dev_games.bloons_proc.batmobile_placecharacter;

truncate prod_games.bloons_proc.batmobile_kochava;
insert into prod_games.bloons_proc.batmobile_kochava 
select * from dev_games.bloons_proc.batmobile_kochava;

truncate prod_games.bloons_proc.batmobile_buyitem;
insert into prod_games.bloons_proc.batmobile_buyitem 
select * from dev_games.bloons_proc.batmobile_buyitem;

truncate prod_games.bloons_proc.batmobile_firstsession;
insert into prod_games.bloons_proc.batmobile_firstsession 
select * from dev_games.bloons_proc.batmobile_firstsession;

truncate prod_games.bloons_proc.batmobile_endtrack;
insert into prod_games.bloons_proc.batmobile_endtrack 
select * from dev_games.bloons_proc.batmobile_endtrack;

---------- insert into prod_games bloons
truncate prod_games.bloons.batmobile_startsession;
insert into prod_games.bloons.batmobile_startsession 
select * from prod_games.bloons_proc.batmobile_startsession;

truncate prod_games.bloons.batmobile_z_user;
insert into prod_games.bloons.batmobile_z_user 
select * from prod_games.bloons_proc.batmobile_z_user;

truncate prod_games.bloons.batmobile_verifiediap_view;
insert into prod_games.bloons.batmobile_verifiediap_view 
select * from prod_games.bloons_proc.batmobile_verifiediap_view;

truncate prod_games.bloons.batmobile_accountmerged;
insert into prod_games.bloons.batmobile_accountmerged 
select * from prod_games.bloons_proc.batmobile_accountmerged;

truncate prod_games.bloons.batmobile_starttrack;
insert into prod_games.bloons.batmobile_starttrack 
select * from prod_games.bloons_proc.batmobile_starttrack;

truncate prod_games.bloons.batmobile_placecharacter;
insert into prod_games.bloons.batmobile_placecharacter 
select * from prod_games.bloons_proc.batmobile_placecharacter;

truncate prod_games.bloons.batmobile_kochava;
insert into prod_games.bloons.batmobile_kochava 
select * from prod_games.bloons_proc.batmobile_kochava;

truncate prod_games.bloons.batmobile_buyitem;
insert into prod_games.bloons.batmobile_buyitem 
select * from prod_games.bloons_proc.batmobile_buyitem;

truncate prod_games.bloons.batmobile_firstsession;
insert into prod_games.bloons.batmobile_firstsession 
select * from prod_games.bloons_proc.batmobile_firstsession;

truncate prod_games.bloons.batmobile_endtrack;
insert into prod_games.bloons.batmobile_endtrack 
select * from prod_games.bloons_proc.batmobile_endtrack;

---- update reporting tables
truncate table prod_games.bloons.bloons_revenue_us;
insert into prod_games.bloons.bloons_revenue_us
select * from prod_games.bloons.v_batmobile_revenue_kpis_us;

truncate table prod_games.bloons.bloons_retention_us; 
insert into prod_games.bloons.bloons_retention_us
select * from prod_games.bloons.V_BATMOBILE_RETENTION_US;










