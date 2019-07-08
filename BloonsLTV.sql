-- calculates the amount of money that a player will spend in Bloons
-- how much you can spend on acquiring new customers
-- factors I want to determine: (1) who are the highest-value players (2) how much risk are we exposed to (3) how much can we afford to spend to acquire new players

-- revenue
use prod_games;
select * from PROD_GAMES.BLOONS.BLOONS_REVENUE_US;
select max(date) from PROD_GAMES.BLOONS.BLOONS_REVENUE_US;
select * from PROD_GAMES.BLOONS_PROC.BATMOBILE_Z_USER;
select count(*) from PROD_GAMES.BLOONS_PROC.BATMOBILE_Z_USER where JOIN_DATE = '2019-07-08 00:00:00.000'; -- today's total number of users that joined
select count (USERID) from PROD_GAMES.BLOONS_PROC.BATMOBILE_Z_USER where INACTIVE = 'no'; -- total number of active users

select DATE, PURCHASERS, ARPPU from PROD_GAMES.BLOONS.BLOONS_REVENUE_US
where DATE >= '2018-08-28';

select * from PROD_GAMES.BLOONS.BLOONS_REVENUE_US where DATE = '2018-08-28';
select * from PROD_GAMES.BLOONS.BLOONS_REVENUE_US where DATE = '2019-07-07';

-- number of users joined
select JOIN_DATE, count(USERID) from PROD_GAMES.BLOONS_PROC.BATMOBILE_Z_USER
where JOIN_DATE >= '2018-08-28 00:00:00.000'
group by JOIN_DATE order by JOIN_DATE asc;

-- user
select count(USERID) from PROD_GAMES.BLOONS_PROC.BATMOBILE_Z_USER where JOIN_DATE = '2018-08-28';
select count(USERID) from PROD_GAMES.BLOONS_PROC.BATMOBILE_Z_USER where JOIN_DATE = '2019-07-08';
select max(JOIN_DATE) from PROD_GAMES.BLOONS_PROC.BATMOBILE_Z_USER;
select * from PROD_GAMES.BLOONS_PROC.BATMOBILE_Z_USER where MAX_RANK = '2000000000';
select * from  PROD_GAMES.BLOONS.BATMOBILE_Z_USER where USERID = 'NO_LINKd6288a99640f39bd53c5f9bcd0b26d57';

-- start
select date, (revenue * 193) as "LTV" from PROD_GAMES.BLOONS.BLOONS_REVENUE_US;
