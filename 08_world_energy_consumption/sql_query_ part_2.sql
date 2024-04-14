--checking if the energy sources columns identified total to the electricity_demand. 
--compare electricity_demand with electricity_generation
SELECT country, AVG(electricity_demand) AS average_elec_demand, AVG(electricity_generation) AS average_elec_gen, 
	(AVG(electricity_demand) - AVG(electricity_generation)) AS average_net_demand
FROM energy_per_country
GROUP BY country;

--checking which countries have more supply than demand
SELECT country, average_net_demand
	FROM(
	SELECT country, AVG(electricity_demand) AS average_elec_demand, AVG(electricity_generation) AS average_elec_gen, 
	(AVG(electricity_demand) - AVG(electricity_generation)) AS average_net_demand
	FROM energy_per_country
	GROUP BY country)
WHERE average_net_demand < 0;

--comparing the number of those with greater supply, zero net, and greater demand
SELECT 
	(SELECT COUNT(country) AS num_countries_greater_supply
	FROM (SELECT country, AVG(electricity_demand) AS average_elec_demand, AVG(electricity_generation) AS average_elec_gen, 
	(AVG(electricity_demand) - AVG(electricity_generation)) AS average_net_demand
	FROM energy_per_country
	GROUP BY country)
	WHERE average_net_demand < 0),
	
	(SELECT COUNT(country) AS num_countries_zero_net
	FROM (SELECT country, AVG(electricity_demand) AS average_elec_demand, AVG(electricity_generation) AS average_elec_gen, 
	(AVG(electricity_demand) - AVG(electricity_generation)) AS average_net_demand
	FROM energy_per_country
	GROUP BY country)
	WHERE average_net_demand = 0),
	
	(SELECT COUNT(country) AS num_countries_greater_demand
	FROM (SELECT country, AVG(electricity_demand) AS average_elec_demand, AVG(electricity_generation) AS average_elec_gen, 
	(AVG(electricity_demand) - AVG(electricity_generation)) AS average_net_demand
	FROM energy_per_country
	GROUP BY country)
	WHERE average_net_demand > 0)
	
FROM energy_per_country
LIMIT 1;
--supply is greater = 41
--demand is greater = 104
--net is zero = 70
--total of 215 countries and territories

--checking the same for the most recent year
SELECT year,
	(SELECT COUNT(country) AS num_countries_greater_supply
	FROM 
	(SELECT country, year,
	(electricity_demand - electricity_generation) AS net_demand
	FROM energy_per_country)
	WHERE net_demand < 0 AND year = 
	(SELECT MAX(year)
	FROM energy_per_country)),
	
	(SELECT COUNT(country) AS num_countries_greater_demand
	FROM 
	(SELECT country, year,
	(electricity_demand - electricity_generation) AS net_demand
	FROM energy_per_country)
	WHERE net_demand > 0 AND year = 
	(SELECT MAX(year)
	FROM energy_per_country)),
	
	(SELECT COUNT(country) AS num_countries_zero_net
	FROM 
	(SELECT country, year,
	(electricity_demand - electricity_generation) AS net_demand
	FROM energy_per_country)
	WHERE net_demand = 0 AND year = 
	(SELECT MAX(year)
	FROM energy_per_country))
	
FROM energy_per_country
WHERE year = (SELECT MAX(year) FROM energy_per_country)
GROUP BY year;
--total is low. 79 only. Will check on this

SELECT COUNT(country)
FROM energy_per_country
WHERE year = 2022;
--output is 109. Something is really weird...

SELECT year, COUNT(country)
FROM energy_per_country
GROUP BY year
ORDER BY year ASC;
--wow. There is an increase in the number of countries with records across time! 
--most number of countries started peaking from 2012. The number dropped in 2022, from 220 to 109 only.

--checking if there are null values in 2022. The total count and the total computed are different.
SELECT country, 
FROM energy_per_country
WHERE year = 2022;

SELECT country, electricity_demand, electricity_generation
FROM energy_per_country
WHERE year = 2022 AND (electricity_demand IS NULL OR electricity_generation IS NULL);
--there are 30 countries with null values. Anya naman pala (Oh, that's why.)
--this should always be considered in the analysis

SELECT
 key integer,
    country text COLLATE pg_catalog."default",
    year integer,
    iso_code text COLLATE pg_catalog."default",
    coal_consumption double precision,
    coal_electricity double precision,
    coal_production double precision,
    electricity_demand double precision,
    electricity_generation double precision,
    electricity_share_energy double precision,
    gas_consumption double precision,
    gas_electricity double precision,
    gas_production double precision,
    hydro_consumption double precision,
    hydro_electricity double precision,
    net_elec_imports double precision,
    nuclear_consumption double precision,
    nuclear_electricity double precision,
    oil_consumption double precision,
    oil_electricity double precision,
    oil_production double precision,
    other_renewable_consumption double precision,
    other_renewable_electricity double precision,
    other_renewable_exc_biofuel_electricity double precision,
    primary_energy_consumption double precision,
    solar_consumption double precision,
    solar_electricity double precision,
    wind_consumption double precision,
    wind_electricity double precision,

SELECT
    country,
    year,
	(coal_electricity +
    gas_electricity +
    hydro_electricity +
    nuclear_electricity +
    oil_electricity +
    other_renewable_electricity +
    solar_electricity +
    wind_electricity) AS total_electricity_unknown,
	electricity_demand,
    electricity_generation,
    electricity_share_energy,
	primary_energy_consumption
FROM energy_per_country
--seems like the total of the energy from the different sources are those produced by the nation. Which makes sense logically.
--seems like the electricity_share_energy is the amount of energy that a country uses in the form of electricity. The total energy seems to be the primary_energy_consumption
--to check the total energy generated,
SELECT year, (SUM(total_electricity_unknown - electricity_generation)/SUM(electricity_generation)) AS must_be_near_or_zero_if_relatively_equal
FROM(SELECT 
	country,
    year,
	(coal_electricity +
    gas_electricity +
    hydro_electricity +
    nuclear_electricity +
    oil_electricity +
    other_renewable_electricity +
    solar_electricity +
    wind_electricity) AS total_electricity_unknown,
    electricity_generation
	FROM energy_per_country)
GROUP BY year
ORDER BY year;
--Very small. I checked the percent difference. Almost zero. Therefore, it's safe to assume that the total of the individual energy sources are in fact the electricity generated

--to check the primary energy and elec_share,
SELECT AVG(((electricity_generation)/(primary_energy_consumption)) - electricity_share_energy) AS checking_if_equal
FROM energy_per_country
WHERE primary_energy_consumption IS NOT NULL AND primary_energy_consumption <> 0;
--answer is -13.43798. Too big. It's not a fraction of primary_energy_consumption

--I have to check if the total of the consumptions is the electricity_demand. If so, I have a bigger analysis to do. I have to split to supply and demand.
--SELECT COUNT(
SELECT country,
	(AVG((coal_consumption +
    gas_consumption +
    hydro_consumption +
    nuclear_consumption +
    oil_consumption +
    other_renewable_consumption +
    solar_consumption +
    wind_consumption)- electricity_demand))/AVG(electricity_demand)
FROM energy_per_country
WHERE ((coal_consumption +
    gas_consumption +
    hydro_consumption +
    nuclear_consumption +
    oil_consumption +
    other_renewable_consumption +
    solar_consumption +
    wind_consumption)- electricity_demand) IS NOT NULL
GROUP BY country;
--the difference is too big.
--to summarize, so far, the relationship that I'm sure of is that the total of the output of the individual energy sources is equal to the energy generated
--I just realized that it's not that as necessary to identify the source of energy consumed compared to knowing the renewability of the source of the energy produced.
--therefore, I can proceed with the analysis that involves the particulars of the renewability of the energy source when it comes to production only

-- query the tables (finally!)