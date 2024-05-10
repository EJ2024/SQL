select *
FROM world_life_expectancy.world_life_expectancy
;

#Verified deletion of duplicates
SELECT Country, year, concat(Country, year), count(concat(country, year))
FROM world_life_expectancy.world_life_expectancy
Group by Country, year, concat(country, year)
having count(concat(country, year)) >1
;

#Find duplicate rows for country+ year
SELECT Country, year, concat(Country, year)
FROM world_life_expectancy.world_life_expectancy;

Select *
From (
	select Row_ID,
	concat(Country, year),
	Row_Number() Over(Partition by concat(Country, year) Order by concat(Country, year)) as Row_Num
	From world_life_expectancy.world_life_expectancy
    ) as Row_Table
Where row_num >1
;

#Removed duplicates
Delete from world_life_expectancy.world_life_expectancy
Where 
	Row_ID IN (
    select Row_ID
From (
	select Row_ID,
	concat(Country, year),
	Row_Number() Over(Partition by concat(Country, year) Order by concat(Country, year)) as Row_Num
	From world_life_expectancy.world_life_expectancy
    ) as Row_Table
Where row_num >1
)
;

#Explore countries classified as Developing/identify blank enteries
Select Distinct(country)
from world_life_expectancy.world_life_expectancy
where status = 'Developing'
;

#Identify specific blank enteries
Update world_life_expectancy.world_life_expectancy
SET Status = 'Developing'
Where country in (Select Distinct(country)
    from world_life_expectancy.world_life_expectancy
    where status = 'Developing')
    ;

# Populate blank enteries by joining tables for Developing countries
Update world_life_expectancy.world_life_expectancy t1
Join world_life_expectancy.world_life_expectancy t2
    On t1.country = t2.country
Set t1.status = 'Developing'
where t1.status = ''
and t2.status <> ''
and t2.status = 'Developing'
;

# Populate blank enteries by joining tables for Developed countries
Update world_life_expectancy.world_life_expectancy t1
Join world_life_expectancy.world_life_expectancy t2
    On t1.country = t2.country
Set t1.status = 'Developed'
where t1.status = ''
and t2.status <> ''
and t2.status = 'Developed'
;

# Identify blank values in Life Expectancy
select *
from world_life_expectancy.world_life_expectancy 
Where `Life expectancy` = ''
; 

#Specifying columns to explore
select country, year, `Life expectancy`
from world_life_expectancy.world_life_expectancy 
;

#self join to populate the blank life exp with the average of year before and year after
select t1.country, t1.year, t1.`Life expectancy`,
t2.country, t2.year, t2.`Life expectancy`,
t3.country, t3.year, t3.`Life expectancy`,
Round((t2.`Life expectancy`+ t3.`Life expectancy`)/2,1)
from world_life_expectancy.world_life_expectancy t1
join world_life_expectancy.world_life_expectancy t2
	on t1.country = t2.country
	and t1.year=t2.year -1
join world_life_expectancy.world_life_expectancy t3
	on t1.country = t3.country
	and t1.year=t3.year +1
where t1.`Life expectancy` = ''
    ;

#Updating table with blank life exp values with life exp avg(of previous and following years)
Update world_life_expectancy.world_life_expectancy t1
join world_life_expectancy.world_life_expectancy t2
	on t1.country = t2.country
	and t1.year=t2.year -1
join world_life_expectancy.world_life_expectancy t3
	on t1.country = t3.country
	and t1.year=t3.year +1
Set t1.`Life expectancy` = Round((t2.`Life expectancy`+ t3.`Life expectancy`)/2,1)
where t1.`Life expectancy` = ''
;

select *
from world_life_expectancy.world_life_expectancy 
; 

#Exploring increase in life exp per country
select Country, MIN(`Life expectancy`), Max(`Life expectancy`),
round (Max(`Life expectancy`) - MIN(`Life expectancy`), 1 ) As Life_inc_15_yrs
from world_life_expectancy.world_life_expectancy 
group by Country
having Min(`Life expectancy`) <> 0
and Max(`Life expectancy`) <>0
order by Life_inc_15_yrs asc
; 

#Finding avf life exp per year for all countries
select year, Round(Avg(`Life expectancy`),2)
from world_life_expectancy.world_life_expectancy 
where `Life expectancy` <> 0
and `Life expectancy` <> 0
group by year
order by year
; 

select *
from world_life_expectancy.world_life_expectancy 
; 

#Explore country, life exp and gdp
select country, round(avg( `Life expectancy`),1) as life_exp, round(avg( gdp),1) as gdp
from world_life_expectancy.world_life_expectancy 
group by country
having life_exp >0
and gdp > 0
order by life_exp asc
; 

#use case statements to find ranges
select 
sum(Case when gdp>=1500 then 1 else 0 end) high_gdp_count,
avg(Case when gdp>= 1500 then `Life expectancy` else null end) high_gdp_life_exp,
sum(Case when gdp <=1500 then 1 else 0 end) low_gdp_count,
avg(Case when gdp <= 1500 then `Life expectancy` else null end) low_gdp_life_exp
from world_life_expectancy.world_life_expectancy 
; 

#Find avg life exp per status
Select status, round(avg( `Life expectancy`),1)
from world_life_expectancy.world_life_expectancy
group by status
;

#Explore the countries in each status to evaluate impact on life exp
Select status, count(distinct country), round(avg( `Life expectancy`),1)
from world_life_expectancy.world_life_expectancy
group by status
;

#Explore correlation between life exp and bmi
select country, round(avg( `Life expectancy`),1) as life_exp, round(avg( bmi),1) as bmi
from world_life_expectancy.world_life_expectancy 
group by country
having life_exp >0
and bmi > 0
order by bmi desc
;

#Use rolling total and exploring countries with United in name
select country, year, `Life expectancy`, `Adult Mortality`, 
sum( `Adult Mortality`) over(partition by country order by year) as rolling_total
from world_life_expectancy.world_life_expectancy 
where country like '%United%'
; 
