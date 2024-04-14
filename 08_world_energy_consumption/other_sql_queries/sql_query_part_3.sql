--to get the table for the status of nations, 


SELECT *, 
-- total percentage of renewables and non-renewables in the country's energy mix
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
	END AS oil_elec_non_ren_percent

FROM(
SELECT 
	key,
	country,
	year,
	iso_code,
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
	
WHERE electricity_generation IS NOT NULL AND electricity_generation <> 0;



