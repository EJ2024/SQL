SELECT * 
FROM us_project.us_household_income_statistics;

SELECT *
FROM us_project.us_household_income;

SELECT count(id)
FROM us_project.us_household_income_statistics;

SELECT  count(id)
FROM us_project.us_household_income;

#Identify duplicates income table
SELECT id, count(id)
FROM us_project.us_household_incomeb
group by id
having count(id) > 1
;

SELECT*
FROM (
SELECT row_id, id,
ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
FROM us_project.us_household_incomeb
) duplicate
Where row_num > 1
;

#Delete duplicates
Delete from us_project.us_household_incomeb
where row_id IN (
	SELECT row_id
	FROM (
		SELECT row_id, id,
		ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
		FROM us_project.us_household_incomeb
		) duplicate
	Where row_num > 1)
;

#Identify duplicates income stats table
SELECT id, count(id)
FROM us_project.us_household_income_statistics
group by id
having count(id) > 1
;
#None found

SELECT *
FROM us_project.us_household_incomeb;

#Identify case mistakes
SELECT state_name, count(state_name)
FROM us_project.us_household_incomeb
Group by state_name;

#Correct mistakes
update us_project.us_household_incomeb
set state_name = 'Georgia'
Where state_name = 'georia';

update us_project.us_household_incomeb
set state_name = 'Alabama'
Where state_name = 'alabama';

#Explore abbreviaitions
SELECT distinct state_ab 
FROM us_project.us_household_incomeb
Order by 1;

#Explore place empty cell
SELECT *
FROM us_project.us_household_incomeb
where place = '';

#Correct mistakes
Update us_project.us_household_incomeb
Set place = 'Autaugaville'
where county = 'Autauga County'
and city = 'Vinemont'
;

#Identify type cataegories
Select type, count(type)
from us_project.us_household_incomeb
group by type;

#Fix boroughs
update us_project.us_household_incomeb
set type='Borough'
where type = 'Boroughs';

#Explore land and water columns
Select Aland, Awater
from us_project.us_household_incomeb
where Awater = 0 Or Awater='' or Awater is null;
#no corrections needed

########EDA#########
Select State_name, Aland, Awater
from us_project.us_household_incomeb;

Select State_name, SUM(Aland), SUM(Awater)
from us_project.us_household_incomeb
Group by state_name
order by 2 desc ;

# Join tables
SELECT * 
FROM us_project.us_household_income_statistics;

SELECT *
FROM us_project.us_household_incomeb;

SELECT *
FROM us_project.us_household_incomeb u
join us_project.us_household_income_statistics us
	on u.id=us.id ;


SELECT *
FROM us_project.us_household_incomeb u
right join us_project.us_household_income_statistics us
	on u.id=us.id
where u.id is null;

SELECT *
FROM us_project.us_household_incomeb u
inner join us_project.us_household_income_statistics us
	on u.id=us.id
where mean <> 0;

#look at categorical data
SELECT u.state_name, county, type, `primary`, mean, median
FROM us_project.us_household_incomeb u
inner join us_project.us_household_income_statistics us
	on u.id=us.id
where mean <> 0;

SELECT u.state_name, round(avg(mean),1), round(avg(median),1)
FROM us_project.us_household_incomeb u
inner join us_project.us_household_income_statistics us
	on u.id=us.id
where mean <> 0
group by u.state_name
order by 2
limit 5;

SELECT type, round(avg(mean),1), round(avg(median),1)
FROM us_project.us_household_incomeb u
inner join us_project.us_household_income_statistics us
	on u.id=us.id
where mean <> 0
group by type
order by 2 desc
;

SELECT type, count(type), round(avg(mean),1), round(avg(median),1)
FROM us_project.us_household_incomeb u
inner join us_project.us_household_income_statistics us
	on u.id=us.id
where mean <> 0
group by 1
order by 3 desc
limit 20
;

#Filter outliers
SELECT type, count(type), round(avg(mean),1), round(avg(median),1)
FROM us_project.us_household_incomeb u
inner join us_project.us_household_income_statistics us
	on u.id=us.id
where mean <> 0
group by 1
having count(type) > 100
order by 3 desc
limit 20
;

SELECT *
FROM us_project.us_household_incomeb u
join us_project.us_household_income_statistics us
	on u.id=us.id ;

SELECT u.state_name, city, round(avg(mean),1)
FROM us_project.us_household_incomeb u
join us_project.us_household_income_statistics us
	on u.id=us.id 
group by u.state_name, city
order by round(avg(mean),1) desc;

##AB AdvancedSQL Project
SELECT *
From us_project.us_household_incomeb;

##Create Table
DELIMITER $$
CREATE PROCEDURE Copy_clean_data()
BEGIN

	CREATE TABLE IF NOT EXISTS `us_household_incomeb_cleaned` (
	  `row_id` int DEFAULT NULL,
	  `id` int DEFAULT NULL,
	  `State_Code` int DEFAULT NULL,
	  `State_Name` text,
	  `State_ab` text,
	  `County` text,
	  `City` text,
	  `Place` text,
	  `Type` text,
	  `Primary` text,
	  `Zip_Code` int DEFAULT NULL,
	  `Area_Code` int DEFAULT NULL,
	  `ALand` int DEFAULT NULL,
	  `AWater` int DEFAULT NULL,
	  `Lat` double DEFAULT NULL,
	  `Lon` double DEFAULT NULL,
	  `TimeStamp` TIMESTAMP DEFAULT NULL
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

##Copy data to new table

	INSERT INTO us_household_incomeb_cleaned
	SELECT *, current_timestamp()
	FROM us_project.us_household_incomeb;


END $$
DELIMITER ;



Call Copy_clean_data();

##Run scheduled code
CREATE EVENT run_data_cleaning
ON SCHEDULE EVERY 90 day
DO CALL Copy_clean_data();

DROP event run_data_cleaning;