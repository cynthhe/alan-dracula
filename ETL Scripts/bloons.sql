use database prod_games;
use schema bloons_proc;
use warehouse prod_games_01;

-------- inserting into prod_games bloons_proc
truncate batmobile_startsession;
COPY into batmobile_startsession from(
select $1 as userid, $2 as created_at, $3 as client_version, $4 as platform, $5 as country, $6 as session_id
from @batmobile_delta_stage/2020 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
pattern = '.*batmobile_startsession_000.gz.*'
;

truncate batmobile_z_user;
COPY into batmobile_z_user from(
select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16
from @batmobile_delta_stage (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
pattern = '.*batmobile_z_user_000.gz.*'
;


truncate batmobile_verifiediap_view;
COPY into batmobile_verifiediap_view from(
select $1,$2,$3,$4
from @batmobile_delta_stage/2020 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
pattern = '.*batmobile_verifiediap_view_000.gz.*'
;

truncate batmobile_accountmerged;
COPY into batmobile_accountmerged from(
select $1,$2,$3,$4
from @batmobile_delta_stage/2020  (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
pattern = '.*batmobile_accountmerged_000.gz.*'
;

truncate batmobile_starttrack;
COPY into batmobile_starttrack from(
select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14
from @batmobile_delta_stage/2020 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
pattern = '.*batmobile_starttrack_000.gz.*';

truncate batmobile_placecharacter;
COPY into batmobile_placecharacter from(
select $1,$2,$3,$4,$5,$6,$7,$8
from @batmobile_delta_stage/2020 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
pattern = '.*batmobile_placecharacter_000.gz.*';

truncate prod_games.bloons_proc.batmobile_kochava;
COPY into prod_games.bloons_proc.batmobile_kochava from(
select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13
from @batmobile_delta_stage/2020 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
pattern = '.*batmobile_kochava_000.gz.*';

truncate prod_games.bloons_proc.batmobile_buyitem;
COPY into prod_games.bloons_proc.batmobile_buyitem from(
select $1,$2,$3,$4,$5,$6
from @batmobile_delta_stage/2020 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
pattern = '.*batmobile_buyitem_000.gz.*';

truncate prod_games.bloons_proc.batmobile_firstsession;
COPY into prod_games.bloons_proc.batmobile_firstsession from(
select $1,$2,$3,$4,$5,$6
from @batmobile_delta_stage/2020 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
pattern = '.*batmobile_firstsession_000.gz.*';

truncate batmobile_endtrack;
COPY into batmobile_endtrack from(
select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16
from @batmobile_delta_stage/2020 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
pattern = '.*batmobile_endtrack_000.gz.*'
;

truncate batmobile_startmarstrack;
COPY into batmobile_startmarstrack from(
select $1,$2,$3,$4,$5,$6,$7,$8,$9
from @batmobile_delta_stage/2020 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
pattern = '.*batmobile_startmarstrack_000.gz.*'
;

truncate batmobile_buyitem_pre;
COPY into batmobile_buyitem_pre from(
select $1,$2,$3,$4,$5,$6,$7
from @batmobile_delta_stage/2020 (file_format=> 'util_db.public.psv'))
ON_ERROR= ABORT_STATEMENT
PURGE = TRUE
pattern = '.*batmobile_buyitem_pre_000.gz.*'
;

---------- insert into prod_games bloons
insert into prod_games.bloons.batmobile_startsession 
select * from prod_games.bloons_proc.batmobile_startsession;

insert into prod_games.bloons.batmobile_z_user 
select * from prod_games.bloons_proc.batmobile_z_user;

insert into prod_games.bloons.batmobile_verifiediap_view 
select * from prod_games.bloons_proc.batmobile_verifiediap_view;

insert into prod_games.bloons.batmobile_accountmerged 
select * from prod_games.bloons_proc.batmobile_accountmerged;

insert into prod_games.bloons.batmobile_starttrack 
select * from prod_games.bloons_proc.batmobile_starttrack;

insert into prod_games.bloons.batmobile_placecharacter 
select * from prod_games.bloons_proc.batmobile_placecharacter;

insert into prod_games.bloons.batmobile_kochava 
select * from prod_games.bloons_proc.batmobile_kochava;

insert into prod_games.bloons.batmobile_buyitem 
select * from prod_games.bloons_proc.batmobile_buyitem;

insert into prod_games.bloons.batmobile_firstsession 
select * from prod_games.bloons_proc.batmobile_firstsession;

insert into prod_games.bloons.batmobile_endtrack 
select * from prod_games.bloons_proc.batmobile_endtrack;

insert into prod_games.bloons.batmobile_startmarstrack 
select * from prod_games.bloons_proc.batmobile_startmarstrack;

insert into prod_games.bloons.batmobile_buyitem_pre 
select * from prod_games.bloons_proc.batmobile_buyitem_pre;


---- update reporting tables
use warehouse prod_games_01;
truncate table prod_games.bloons.bloons_revenue_us;
insert into prod_games.bloons.bloons_revenue_us
select * from prod_games.bloons.v_batmobile_revenue_kpis_us;

truncate table prod_games.bloons.bloons_retention_us; 
insert into prod_games.bloons.bloons_retention_us
select * from prod_games.bloons.V_BATMOBILE_RETENTION_US;
