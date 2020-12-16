use database prod_games;
use schema arcade;
use warehouse wh_default;

-- REPORTING schema
use database prod_games;
use schema reporting;
use warehouse wh_default;

-- Create reporting view: ARCADE_APP_VERSIONS
create or replace view arcade_app_versions as
select distinct
    submit_time::date as date
    ,platform
    ,case when app_version like '%Version: 2.1.5196%' then 'v2.1.5196'
    when app_version like '%Version: 2.1.5307%' then 'v2.1.5307'
    when app_version like '%Version: 2.0.4459%' then 'v2.0.4459'
    when app_version like '%Version: 1.3.3556%' then 'v1.3.3556'
    when app_version like '%Version: 2.0.4443%' then 'v2.0.4443'
    when app_version like '%Version: 2.1.5093%' then 'v2.1.5093'
    else null
    end as app_version
    ,userid
from prod_games.arcade.app_version
where app_version is not null
and (app_version like '%Version: 2.1.5196%'
     or app_version like '%Version: 2.1.5307%'
     or app_version like '%Version: 2.0.4459%'
     or app_version like '%Version: 1.3.3556%'
     or app_version like '%Version: 2.0.4443%'
     or app_version like '%Version: 2.1.5093%'
     and app_version not like '%DEBUG%'
    );
    
-- Looker permissions for reporting view
grant select on prod_games.reporting.arcade_app_versions to looker_read;
