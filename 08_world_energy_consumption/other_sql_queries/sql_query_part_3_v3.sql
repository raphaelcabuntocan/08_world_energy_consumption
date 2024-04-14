--to get the table for the status of nations, 
SELECT *,	
	RANK() OVER (PARTITION BY year ORDER BY hydro_elec_per_capita DESC) AS hydro_per_capita_rank,
	RANK() OVER (PARTITION BY year ORDER BY other_renewable_elec_per_capita DESC) AS other_renewable_per_capita_rank,
	RANK() OVER (PARTITION BY year ORDER BY solar_elec_per_capita DESC) AS solar_per_capita_rank,
	RANK() OVER (PARTITION BY year ORDER BY wind_elec_per_capita DESC) AS wind_rank,
	RANK() OVER (PARTITION BY year ORDER BY coal_elec_per_capita DESC) AS coal_rank,
	RANK() OVER (PARTITION BY year ORDER BY gas_elec_per_capita DESC) AS gas_rank,
	RANK() OVER (PARTITION BY year ORDER BY nuclear_elec_per_capita DESC) AS nuclear_rank,
	RANK() OVER (PARTITION BY year ORDER BY oil_elec_per_capita DESC) AS oil_rank,
	RANK() OVER (PARTITION BY year ORDER BY renewable_elec_per_capita DESC) AS renewable_rank,
	RANK() OVER (PARTITION BY year ORDER BY non_renewable_elec_generated DESC) AS non_renewable_rank,
	RANK() OVER (PARTITION BY year ORDER BY elec_demand_per_capita DESC) AS total_demand_rank,
	RANK() OVER (PARTITION BY year ORDER BY elec_generated_per_capita DESC) AS total_generated_rank,
	RANK() OVER (PARTITION BY year ORDER BY net_elec_supply_per_capita DESC) AS net_elec_supply_rank

FROM(
SELECT *, 
	--for ranks of energy percentage
	RANK() OVER (PARTITION BY year ORDER BY hydro_elec_percent DESC) AS hydro_percent_rank,
	RANK() OVER (PARTITION BY year ORDER BY other_renewable_elec_percent DESC) AS other_renewable_percent_rank,
	RANK() OVER (PARTITION BY year ORDER BY solar_elec_percent DESC) AS solar_percent_rank,
	RANK() OVER (PARTITION BY year ORDER BY wind_elec_percent DESC) AS wind_percent_rank,
	RANK() OVER (PARTITION BY year ORDER BY coal_elec_percent DESC) AS coal_percent_rank,
	RANK() OVER (PARTITION BY year ORDER BY gas_elec_percent DESC) AS gas_percent_rank,
	RANK() OVER (PARTITION BY year ORDER BY nuclear_elec_percent DESC) AS nuclear_percent_rank,
	RANK() OVER (PARTITION BY year ORDER BY oil_elec_percent DESC) AS oil_percent_rank,
	RANK() OVER (PARTITION BY year ORDER BY total_renewable_elec_percent DESC) AS renewable_percent_rank,
	RANK() OVER (PARTITION BY year ORDER BY total_non_renewable_elec_percent DESC) AS non_renewable_percent_rank,
	RANK() OVER (PARTITION BY year ORDER BY net_elec_supply_demand_percent DESC) AS net_supply_demand_percent_rank,

--per capita data
	hydro_electricity/population AS hydro_elec_per_capita,
	other_renewable_electricity/population AS other_renewable_elec_per_capita,
	solar_electricity/population AS solar_elec_per_capita,
	wind_electricity/population AS wind_elec_per_capita,
	renewable_elec_generated/population AS renewable_elec_per_capita,

	coal_electricity/population AS coal_elec_per_capita,
	gas_electricity/population AS gas_elec_per_capita,
	nuclear_electricity/population AS nuclear_elec_per_capita,
	oil_electricity/population AS oil_elec_per_capita,
	non_renewable_elec_generated/population AS non_renewable_elec_per_capita,

	electricity_generation/population AS elec_generated_per_capita, 
	electricity_demand/population AS elec_demand_per_capita,
	net_electricity_supply/population AS net_elec_supply_per_capita

FROM(
SELECT *, 
--total percentage of renewables and non-renewables in the country's energy mix
	renewable_elec_generated/electricity_generation AS total_renewable_elec_percent,
	non_renewable_elec_generated/electricity_generation AS total_non_renewable_elec_percent,
	
--percentage of renewables in the country's renewable energy
	CASE WHEN renewable_elec_generated <> 0 THEN
	hydro_electricity/renewable_elec_generated
	ELSE 0
	END AS hydro_elec_ren_percent,
	
	CASE WHEN renewable_elec_generated <> 0 THEN
	other_renewable_electricity/renewable_elec_generated 
	ELSE 0
	END AS other_renewable_ren_elec_percent,

	CASE WHEN renewable_elec_generated <> 0 THEN
	solar_electricity/renewable_elec_generated 
	ELSE 0
	END AS solar_ren_elec_percent,

	CASE WHEN renewable_elec_generated <> 0 THEN
	wind_electricity/renewable_elec_generated 
	ELSE 0
	END AS wind_ren_elec_percent,

--percentage of non-renewables in the country's non-renewable energy
	CASE WHEN non_renewable_elec_generated <> 0 THEN
	coal_electricity/non_renewable_elec_generated 
	ELSE 0
	END AS coal_elec_non_ren_percent,

	CASE WHEN non_renewable_elec_generated <> 0 THEN
	gas_electricity/non_renewable_elec_generated 
	ELSE 0
	END AS gas_elec_non_ren_percent,

	CASE WHEN non_renewable_elec_generated <> 0 THEN
	nuclear_electricity/non_renewable_elec_generated 
	ELSE 0
	END AS nuclear_elec_non_ren_percent,

	CASE WHEN non_renewable_elec_generated <> 0 THEN
	oil_electricity/non_renewable_elec_generated 
	ELSE 0
	END AS oil_elec_non_ren_percent,

	CASE WHEN net_electricity_supply <> 0 THEN
	net_electricity_supply/electricity_demand 
	ELSE 0
	END AS net_elec_supply_demand_percent,

--for ranks of energy amount
	RANK() OVER (PARTITION BY year ORDER BY hydro_electricity DESC) AS hydro_rank,
	RANK() OVER (PARTITION BY year ORDER BY other_renewable_electricity DESC) AS other_renewable_rank,
	RANK() OVER (PARTITION BY year ORDER BY solar_electricity DESC) AS solar_rank,
	RANK() OVER (PARTITION BY year ORDER BY wind_electricity DESC) AS wind_rank,
	RANK() OVER (PARTITION BY year ORDER BY coal_electricity DESC) AS coal_rank,
	RANK() OVER (PARTITION BY year ORDER BY gas_electricity DESC) AS gas_rank,
	RANK() OVER (PARTITION BY year ORDER BY nuclear_electricity DESC) AS nuclear_rank,
	RANK() OVER (PARTITION BY year ORDER BY oil_electricity DESC) AS oil_rank,
	RANK() OVER (PARTITION BY year ORDER BY renewable_elec_generated DESC) AS renewable_rank,
	RANK() OVER (PARTITION BY year ORDER BY non_renewable_elec_generated DESC) AS non_renewable_rank,
	RANK() OVER (PARTITION BY year ORDER BY electricity_demand DESC) AS total_demand_rank,
	RANK() OVER (PARTITION BY year ORDER BY electricity_generation DESC) AS total_generated_rank,
	RANK() OVER (PARTITION BY year ORDER BY net_electricity_supply DESC) AS net_elec_supply_rank
	
FROM(
SELECT 
	key,
	country,
	year,
	iso_code,
	population,
--renewables
	hydro_electricity,
	other_renewable_electricity,
	solar_electricity,
	wind_electricity,
	
	(hydro_electricity +
	other_renewable_electricity +
	solar_electricity +
	wind_electricity) AS renewable_elec_generated,
	
--non-renewables
	coal_electricity,
	gas_electricity,
	nuclear_electricity,
	oil_electricity,
	
	(coal_electricity +
	gas_electricity +
	nuclear_electricity +
	oil_electricity) AS non_renewable_elec_generated,

--total
	electricity_generation, 
	electricity_demand,
	(electricity_generation - electricity_demand) AS net_electricity_supply,

--percentage of renewables in country's total energy mix
	(hydro_electricity/electricity_generation) AS hydro_elec_percent,
	(other_renewable_electricity/electricity_generation) AS other_renewable_elec_percent,
	(solar_electricity/electricity_generation) AS solar_elec_percent,
	(wind_electricity/electricity_generation) AS wind_elec_percent,
	
--percentage of non-renewables in country's total energy mix
	(coal_electricity/electricity_generation) AS coal_elec_percent,
	(gas_electricity/electricity_generation) AS gas_elec_percent,
	(nuclear_electricity/electricity_generation) AS nuclear_elec_percent,
	(oil_electricity/electricity_generation) AS oil_elec_percent
	
FROM energy_per_country
WHERE electricity_generation IS NOT NULL AND electricity_generation <> 0)
WHERE electricity_generation IS NOT NULL AND electricity_generation <> 0
ORDER BY key ASC)
WHERE electricity_generation IS NOT NULL AND electricity_generation <> 0
ORDER BY key ASC)
WHERE electricity_generation IS NOT NULL AND electricity_generation <> 0
ORDER BY key ASC;




-------------------------------------------------------------------------------------
--Queries for the world table
SELECT year, 
	SUM(population) AS world_population,
--renewables
	SUM(hydro_electricity) AS world_hydro_electricity,
	SUM(other_renewable_electricity) AS world_other_renewable_electricity,
	SUM(solar_electricity) AS world_solar_electricity,
	SUM(wind_electricity) AS world_wind_electricity,
	
	SUM((hydro_electricity +
	other_renewable_electricity +
	solar_electricity +
	wind_electricity)) AS world_renewable_elec_generated,
	
--non-renewables
	SUM(coal_electricity) AS world_coal_electricity,
	SUM(gas_electricity) AS world_gas_electricity,
	SUM(nuclear_electricity) AS world_nuclear_electricity,
	SUM(oil_electricity) AS world_oil_electricity,
	
	SUM((coal_electricity +
	gas_electricity +
	nuclear_electricity +
	oil_electricity)) AS world_non_renewable_elec_generated,

--total
	SUM(electricity_generation) AS world_electricity_generation, 
	SUM(electricity_demand) AS world_electricity_demand,
	SUM((electricity_generation - electricity_demand)) AS world_net_electricity_supply
	
FROM energy_per_country
WHERE electricity_generation IS NOT NULL AND electricity_generation <> 0
GROUP BY year
ORDER BY year ASC;