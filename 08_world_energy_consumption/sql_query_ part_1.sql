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

--checking if the share_elec total to 100 percent
SELECT
	(biofuel_share_elec +
	coal_share_elec +
	fossil_share_elec +
	gas_share_elec +
	hydro_share_elec +
	low_carbon_share_elec + 
	nuclear_share_elec + 
	oil_share_elec + 
	other_renewables_share_elec + 
	renewables_share_elec + 
	solar_share_elec + 
	wind_share_elec) AS total
FROM energy_per_country
WHERE country = 'United States' AND year = 2000;
--output is 210.826. It's not equal to 100 percent. Therefore, some of it are collective. Have to determine which are the individual values.

--removing fossil
SELECT
	(biofuel_share_elec +
	coal_share_elec +
	gas_share_elec +
	hydro_share_elec +
	low_carbon_share_elec + 
	nuclear_share_elec + 
	oil_share_elec + 
	other_renewables_share_elec + 
	renewables_share_elec + 
	solar_share_elec + 
	wind_share_elec) AS total
FROM energy_per_country
WHERE country = 'United States' AND year = 2000;
--output is 139.884
--removing renewables_share
SELECT
	(biofuel_share_elec +
	coal_share_elec +
	gas_share_elec +
	hydro_share_elec +
	low_carbon_share_elec + 
	nuclear_share_elec + 
	oil_share_elec + 
	other_renewables_share_elec + 
	solar_share_elec + 
	wind_share_elec) AS total
FROM energy_per_country
WHERE country = 'United States' AND year = 2000;
--output is 130.654
SELECT
	biofuel_share_elec,
	coal_share_elec,
	gas_share_elec,
	hydro_share_elec,
	low_carbon_share_elec, 
	nuclear_share_elec,
	oil_share_elec,
	other_renewables_share_elec,
	renewables_share_elec,
	solar_share_elec,
	wind_share_elec
FROM energy_per_country
WHERE country = 'United States' AND year = 2000;
--low carbon has 29.058 share. Looks like this is collective as well.

--removing low carbon,
SELECT
	(biofuel_share_elec +
	coal_share_elec +
	gas_share_elec +
	hydro_share_elec +
	nuclear_share_elec + 
	oil_share_elec + 
	other_renewables_share_elec + 
	solar_share_elec + 
	wind_share_elec) AS total
FROM energy_per_country
WHERE country = 'United States' AND year = 2000;
--101.596. 
--other_renewables has a value of 1.968 while biofuel is 1.597. Removing biofuel will make the total equal to 100 percent.
--will be removing biofuel and then apply to other dates to check if the other years will equal to 100 percent as well. 
--Will do this with other countries for further verification.

--removing biofuel
SELECT
	(coal_share_elec +
	gas_share_elec +
	hydro_share_elec +
	nuclear_share_elec + 
	oil_share_elec + 
	other_renewables_share_elec + 
	solar_share_elec + 
	wind_share_elec) AS total
FROM energy_per_country
WHERE country = 'United States' AND year = 2000;
--output is 99.9990

--trying with other years
SELECT year,
	(coal_share_elec +
	gas_share_elec +
	hydro_share_elec +
	nuclear_share_elec + 
	oil_share_elec + 
	other_renewables_share_elec + 
	solar_share_elec + 
	wind_share_elec) AS total
FROM energy_per_country
WHERE country = 'United States';
--works very well

--taking the average total share
SELECT AVG (total) AS average_total
	FROM (
	SELECT year,
	(coal_share_elec +
	gas_share_elec +
	hydro_share_elec +
	nuclear_share_elec + 
	oil_share_elec + 
	other_renewables_share_elec + 
	solar_share_elec + 
	wind_share_elec) AS total
	FROM energy_per_country
	WHERE country = 'United States');
--output is 99.8879. Great! 
--we have determined the individual energy sources: coal, gas, hydro, nuclear, oil, other renewables, solar, wind
--will confirm this using other country's values
SELECT AVG (total) AS average_total_countries, STDDEV(total) AS stddev_total_countries
	FROM (
	SELECT country, year,
	(coal_share_elec +
	gas_share_elec +
	hydro_share_elec +
	nuclear_share_elec + 
	oil_share_elec + 
	other_renewables_share_elec + 
	solar_share_elec + 
	wind_share_elec) AS total
	FROM energy_per_country);
--result is 99.9722, with respect to all nations
--standard deviation is 0.22478 only
--therefore, these are the individual sources of energy

--creating a query for non-renewable sources of energy
SELECT
	key, 
	country, 
	year,
	coal_cons_change_pct,
	coal_cons_change_twh,
	coal_cons_per_capita,
	coal_electricity,
	coal_prod_change_pct,
	coal_prod_change_twh,
	coal_prod_per_capita,
	coal_production
	coal_share_elec,
	coal_share_energy,
	gas_cons_change_pct,
	gas_cons_change_twh,
	gas_consumption,
	gas_elec_per_capita,
	gas_electricity,
	gas_energy_per_capita,
	gas_prod_change_pct,
	gas_prod_per_capita,
	gas_production,
	gas_share_elec,
	gas_share_energy,
	nuclear_cons_change_pct,
	nuclear_cons_change_twh,
	nuclear_consumption,
	nuclear_elec_per_capita,
	nuclear_share_elec,
	nuclear_share_energy,
	oil_cons_change_pct,
	oil_cons_change_twh,
	oil_consumption,
	oil_elec_per_capita,
	oil_electricity,
	oil_energy_per_capita,
	oil_prod_change_pct,
	oil_prod_change_twh,
	oil_prod_per_capita,
	oil_production,
	oil_share_elec,
	oil_share_energy
FROM energy_per_country;


--corrected the name of the columns
ALTER TABLE energy_per_country
RENAME COLUMN bioful_consumption TO biofuel_consumption;

ALTER TABLE energy_per_country
RENAME COLUMN soalr_elec_per_capita TO solar_elec_per_capita;

ALTER TABLE energy_per_country
RENAME COLUMN other_renwewables_share_energy to other_renewables_share_energy;

ALTER TABLE world_energy_consumption
RENAME COLUMN bioful_consumption TO biofuel_consumption;

ALTER TABLE world_energy_consumption
RENAME COLUMN soalr_elec_per_capita TO solar_elec_per_capita;

ALTER TABLE world_energy_consumption
RENAME COLUMN other_renwewables_share_energy to other_renewables_share_energy;

--for renewables
SELECT key, country, year,
	hydro_cons_change_pct,
	hydro_cons_change_twh,
	hydro_consumption,
	hydro_elec_per_capita,
	hydro_share_elec,
	hydro_share_energy,
	other_renewable_consumption,
	other_renewable_electricity,
	other_renewable_exc_biofuel_electricity,
	other_renewables_cons_change_pct,
	other_renewables_cons_change_twh,
	other_renewables_elec_per_capita,
	other_renewables_elec_per_capita_exc_biofuel,
	other_renewables_energy_per_capita,
	other_renewables_share_elec,
	other_renewables_share_energy,
	solar_cons_change_pct,
	solar_cons_change_twh,
	solar_consumption,
	solar_elec_per_capita,
	solar_electricity,
	solar_energy_per_capita,
	solar_share_elec,
	solar_share_energy,
	wind_cons_change_pct,
	wind_cons_change_twh,
	wind_consumption,
	wind_elec_per_capita,
	wind_electricity,
	wind_energy_per_capita,
	wind_share_elec,
	wind_share_energy, EH
FROM energy_per_country;

--for other data
SELECT key, country, year,
	iso_code,
	population,
	gdp,
	carbon_intensity_elec,
	electricity_demand,
	electricity_generation,
	electricity_share_energy,
	energy_cons_change_pct,
	energy_cons_change_twh,
	energy_per_capita,
	energy_per_gdp,
	greenhouse_gas_emissions,
	net_elec_imports,
	net_elec_imports_share_demand,
	per_capita_electricity,
	primary_energy_consumption
FROM energy_per_country;

--create csv files for each of the objectives for tableau and/or python analysis
--

	