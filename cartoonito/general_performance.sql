-- ADOBE schema
use database tdc_prod_ac;
use schema final_adobe;
use warehouse wh_default;

-- ARCADE schema
use database prod_games;
use schema arcade;
use warehouse wh_default;

-- Create CARTOONITO view
create or replace view cartoonito as
select distinct
    date_time::date as date
    ,visitor_id
    ,geo_zip
    ,case when referrer_url like '%cartoonnetwork%' then 'Inside our site'
        when referrer_url like '%bing%' then 'Bing'
        when referrer_url like '%google%' then 'Google'
        when referrer_url like '%t.co%' then 'Twitter'
        when referrer_url like '%wikipedia%' then 'Wikipedia'
        when referrer_url like '%wiki%' then 'Wiki'
        when referrer_url like '%yahoo%' then 'Yahoo'
        when referrer_url like '%duckduckgo%' then 'Duck Duck Go'
        when referrer_url like '%instagram%' then 'Instagram'
        else 'Typed/Bookmarked'
        end as referrer_site
     ,case when os_typ_dsc like '%chrome%' then 'PC'
        when os_typ_dsc like '%ios%' then 'iOS'
        when os_typ_dsc like '%macintosh%' then 'Mac'
        when os_typ_dsc like '%windows%' then 'PC'
        when os_typ_dsc like '%android%' then 'Android'
        else 'Other'
        end as device_type
from tdc_prod_ac.final_adobe.cartoon_adobe_bdd_web_v
where page_url like '%https://www.cartoonnetwork.com/cartoonito/%'
and (referrer_url not like '%jira%'
     or referrer_url not like '%dnserrorassist%'
    );
    
-- Create CARTOONITO_TABLE table
create table cartoonito_table as
select *
from prod_games.arcade.cartoonito;
    
-- Update CARTOONITO table
truncate table cartoonito_table;
insert into cartoonito_table
select *
from cartoonito;

-- REPORTING schema
use database prod_games;
use schema reporting;
use warehouse wh_default;

-- Create reporting view: CARTOONITO
create or replace view cartoonito as
select *
from prod_games.arcade.cartoonito_table;

-- Looker permissions for reporting view
grant select on prod_games.reporting.cartoonito to looker_read;
