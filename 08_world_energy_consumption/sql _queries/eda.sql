--Check the countries. Filter out the non-country entities
SELECT country
FROM world_energy_consumption;

--Exploring what the parentheses mean in country names
SELECT DISTINCT country
FROM world_energy_consumption
WHERE country LIKE '%(%';
--It seems like all data that have parentheses are collection of countries. 
--They have to be removed for other queries that are country-specific.

--Selecting countries only.
SELECT DISTINCT world_energy_consumption.country
FROM world_energy_consumption
WHERE country NOT IN (SELECT DISTINCT country
FROM world_energy_consumption
WHERE country LIKE '%(%')
ORDER BY world_energy_consumption.country;
--there are organizations that don't have parentheses, preventing me from filtering them out through this query.

--the countries might be those that have iso codes
SELECT DISTINCT country, iso_code
FROM world_energy_consumption
WHERE iso_code IS NULL;
--there are countries that do not have an iso code here such as Kosovo, and Yugoslavia
--USSR does not have an iso code as well. 
--I need to investigate why USSR is here and does it really represent the whole USSR and then Russia after the collapse?

--checking USSR
SELECT *
FROM world_energy_consumption
WHERE country = 'USSR';
--its data stopped at 1991 except only for the GDP

--I'll check Russia if it exists
SELECT *
FROM world_energy_consumption
WHERE country LIKE '%Russia%';
--Russia exists but its records only started from 1985.
--It would be best if the analysis would exclude USSR in order to create a more reliable analysis for each of the republics.

--It seems like I need to manually select the countries, but I could start with the iso code first.
SELECT DISTINCT country, iso_code
FROM world_energy_consumption
WHERE iso_code IS NULL
ORDER BY country;
--Note: Countries without iso code: Kosovo
--Czechoslovakia (after googling, Czechoslovakia is not a country anymore)
--Yugoslavia has dissolved to other countries already.
--check if there are countries mentioned in the names of the groups if they have their own data as well such as: Mexico, Serbia, Montenegro, South Korea,

--checking Kosovo,
SELECT *
FROM world_energy_consumption
WHERE country = 'Kosovo';
--it has records albeit incomplete. GDP is missing. But electricity generation, energy per capita, etc. are available

--checking Mexico and the others
SELECT *
FROM world_energy_consumption
WHERE country = 'Mexico' OR country = 'South Korea' OR country = 'Serbia' OR country = 'Montenegro';
--they have individual records

--finalizing the table that contains individual countries only
SELECT *
FROM world_energy_consumption
WHERE iso_code IS NOT NULL OR country = 'Kosovo';
--checking the list of countries
SELECT DISTINCT country
FROM(SELECT *
	FROM world_energy_consumption
	WHERE iso_code IS NOT NULL OR country = 'Kosovo')
ORDER BY country ASC;
--check if the Cook Islands should be removed
--it seems like Gibraltar has a similar status. I think it would be best not to remove them so as to avoid unnecessary complications.
--check the data of the Netherlands and the Netherlands Antilles

SELECT *
FROM world_energy_consumption
WHERE country = 'Netherlands Antilles';
--better not to remove it because it may be separate from the values present in the Netherlands.

--creating a temp_table for the countries and territories
CREATE TABLE energy_per_country AS
SELECT *
FROM world_energy_consumption
WHERE iso_code IS NOT NULL OR country = 'Kosovo'
ORDER BY country;
--checking...
SELECT *
FROM energy_per_country;
--works properly

--check if data is clean. check for duplicates
SELECT duplicate_check_ref, COUNT(duplicate_check_ref)
FROM(
	SELECT CONCAT(country,(year :: text),population) AS duplicate_check_ref
	FROM energy_per_country)
GROUP BY duplicate_check_ref
HAVING COUNT(duplicate_check_ref) <> 1;
--there are no duplicates

--checking for negative values
SELECT *
FROM energy_per_country
WHERE electricity_generation < 0 
	OR electricity_demand < 0
	OR per_capita_electricity < 0;
--as of the three columns, there are no negative data

--checking for validity of years
SELECT key, country, year
FROM energy_per_country
WHERE year < 1800 OR year > 2024;
--all are within range

SELECT *
FROM energy_per_country;
