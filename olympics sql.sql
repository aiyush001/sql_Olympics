--select * from athlete_events;
select * from noc_regions;
select * from athlete_event;

--1> Problem Statement: Write a SQL query to find the total no of Olympic Games held as per the dataset

select count(distinct games) as total_olympic_games
from athlete_event;

/*select count(*) as total_olympic_games
from
(select *,
row_number() over(partition by games) as rn
from athlete_events) x
where x.rn=1;*/

--2> Problem Statement: Write a SQL query to list down all the Olympic Games held so far.

select distinct(games),year,season
from athlete_event
order by games;

--3> Problem Statement: SQL query to fetch total no of countries participated in each olympic games.

select *,
 
count(team) over(partition by games order by games) as total_participant
from athlete_event;
--------------------------
-- 6. Identify the sport which was played in all summer olympics.

--1 > find total no of summer olympic games
-- 2> find for each sport, how many games they were played in

/*select count(distinct games) as c,season,
from athlete_event
group by  games,season
having lower(season)='summer';*/

with t1 as
(select count(distinct games) as total_summer_games
from athlete_event
where lower(season)='summer'),

 t2 as
(select distinct sport,games
from athlete_event
where lower(season)='summer'
order by games),

 t3 as
(select sport,count(games) as total_no_games
from t2
group by sport)

select *
from t3
join t1 on t1.total_summer_games = t3.total_no_games;
--------------------------------------------------------



--------------------------------------------------------

--  4. Which year saw the highest and lowest no of countries participating in olympics.

    with total_games as
	
	(select games,nr.region
	from athlete_event ae
	join noc_regions nr on ae.noc=nr.noc
	group by games,nr.region
	order by games,region),

	total_countries as
	
	(select games, count(1) as total_participant_countries
	from total_games
	group by games)
	--select * from total_countries;
	--final_result as
	
	    select    distinct 
		            concat (first_value(games) over(order by total_participant_countries), ' - ',
	                              first_value(total_participant_countries)over(order by total_participant_countries)) as lowest,
			       concat (first_value(games)over(order by total_participant_countries desc),'-',
			                       first_value(total_participant_countries)over(order by total_participant_countries desc)) as highest
				   
				   from total_countries;
		

  -------------------------------------------------------
-- 5. Which nation has participated in all of the olympic games

with total_games as

(select count (distinct games) as tot_no_game
from athlete_event),

  total_game as
	
	(select games,nr.region
	from athlete_event ae
	join noc_regions nr on ae.noc=nr.noc
	group by games,nr.region
	order by games,region),

 number_of_times as

	 (select region,count(region) as no_of_prtcpte
	 from total_game
	 group by region)
	-- having count(region)= 51)
	 --select * from number_of_times

select nt.*
from number_of_times nt
join total_games tg on nt.no_of_prtcpte=tg.tot_no_game;

-------------------------------------------------------------------------------
-- 6. Identify the sport which was played in all summer olympics.

--1 > find total no of summer olympic games
-- 2> find for each sport, how many games they were played in

/*select count(distinct games) as c,season,
from athlete_event
group by  games,season
having lower(season)='summer';*/

with t1 as
(select count(distinct games) as total_summer_games
from athlete_event
where lower(season)='summer'),

 t2 as
(select distinct games,sport
from athlete_event
where lower(season)='summer'
order by games),

 t3 as
(select sport,count(games) as total_no_games
from t2
group by sport)
-- select * from t3;

select *
from t3
join t1 on t1.total_summer_games = t3.total_no_games;

-------------------------------------------------------------

-- 7.  Which Sports were just played only once in the olympics.

    with tot_games as
	 (select distinct games, sport
	 from athlete_event
	 group by games,sport
	 order by games,sport),

	 tot_sports as
	 (select sport,count(sport) as no_of_time
	 from tot_games
	 group by sport)
	 --having count(sport)=1)
	 --select * from t2;
	 select ts.*,tg.games
	 from tot_games tg
	 join tot_sports ts on tg.sport=ts.sport
	 where no_of_time=1;

----------------------------------------------------------------------
-- 8. Fetch the total no of sports played in each olympic games.
with tot_games as
(select distinct games,sport
from athlete_event
group by games,sport
order by games),

tot_sports as
(select games,count(games) as no_of_sports
from tot_games
group by games)
select * from tot_sports;
----------------------------------------------
    select * from athlete_event;
-- 9.  Fetch oldest athletes to win a gold medal

    WITH t1 as
     (select name,sex,cast(case when age='NA' then '0' else age end as int) as age,team,games,sport,year,season,city,event,medal
	 from athlete_event
	 where lower(medal)='gold'),

	 old_athlete as
	 (select *,
	 rank()over(order by age desc) as rnk
	from t1 )
	select * 
	from old_athlete
	where rnk=1;

--------------------------------------------------------------
-- 10. Find the Ratio of male and female athletes participated in all olympic games.
	 
select sex,count(sex)
from athlete_event
group by sex;

-------------------------------
-- 11. Top 5 athletes who have won the most gold medals.

with t1 as
(select  name,count(medal) as gold_medal
from athlete_event
group by name,medal
having lower(medal)='gold'
order by count(medal) desc),

t2 as
(select *,
dense_rank() over(order by gold_medal desc) as rnk
from t1)

select *
from t2
where t2.rnk between 1 and 5;
--------------------------------------------
12. Top 5 athletes who have won the most medals (gold/silver/bronze).
      with t1 as(
     select name,team,count(name) as total_medal
	 from athlete_event
	 where medal <>'NA'
	 group by name,team
	 order by total_medal desc
	 ),
	  t2 as
	      (select t1.*,
		         dense_rank()over(order by t1.total_medal desc) as rnk
				 from t1
				 )
				 select * from t2
				 where t2.rnk<6;
---------------------------------------------------
13.Top 5 most successful countries in olympics. Success is defined by no of medals won.
   with t1 as
(select nr.region,count(nr.region)as total_medals
from athlete_event ae
left join noc_regions nr on ae.noc=nr.noc
where medal<>'NA'
group by nr.region
order by total_medals desc),
 t2 as
	      (select t1.*,
		         dense_rank()over(order by t1.total_medals desc) as rnk
				 from t1
				 )
				 select * from t2
				 where t2.rnk<6;
----------------------------------------------------
14.List down total gold, silver and broze medals won by each country.
     select nr.region as country,medal,count(1) as total_medals
	 from athlete_event ar
	 join noc_regions nr on ar.noc=nr.noc
	 where medal<>'NA'
	 group by nr.region,medal
	 order by nr.region,medal

	 --create extension tablefunc;

	 select country,coalesce(gold,0) as gold,coalesce(silver,0)as silver,coalesce(bronze,0)as bronze
	 from crosstab('select nr.region as country,medal,count(1)
	 from athlete_event ar
	 join noc_regions nr on ar.noc=nr.noc
	 where medal<>''NA''
	 group by nr.region,medal
	 order by nr.region,medal',
	 'values(''Bronze''),(''Gold''),(''Silver'')')
	 as result(country varchar,bronze bigint,gold bigint, silver bigint)
     order by gold desc,silver desc, bronze desc

