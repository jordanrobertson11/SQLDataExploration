CREATE TABLE covid
(
	iso_code VARCHAR(255),
	continent VARCHAR(255),
	location VARCHAR(255),
	date DATE,
	total_cases	INT,
	new_cases INT,
	new_cases_smoothed DOUBLE,
	total_deaths INT,
	new_deaths INT,
	new_deaths_smoothed	DOUBLE,
	total_cases_per_million DOUBLE,
	new_cases_per_million DOUBLE,
	new_cases_smoothed_per_million DOUBLE,
	total_deaths_per_million DOUBLE,
	new_deaths_per_million DOUBLE,
	new_deaths_smoothed_per_million	DOUBLE,
	reproduction_rate DOUBLE,
	icu_patients INT,
	icu_patients_per_million DOUBLE,
	hosp_patients INT,
	hosp_patients_per_million DOUBLE,
	weekly_icu_admissions INT,
	weekly_icu_admissions_per_million DOUBLE,
	weekly_hosp_admissions INT,
	weekly_hosp_admissions_per_million DOUBLE,
	total_tests	INT,
	new_tests INT,
	total_tests_per_thousand DOUBLE,
	new_tests_per_thousand DOUBLE,
	new_tests_smoothed INT,
	new_tests_smoothed_per_thousand	DOUBLE,
	positive_rate DOUBLE,
	tests_per_case DOUBLE,
	tests_units	VARCHAR(255),
	total_vaccinations INT,
	people_vaccinated INT,
	people_fully_vaccinated	INT,
	total_boosters INT,
	new_vaccinations INT,
	new_vaccinations_smoothed INT,
	total_vaccinations_per_hundred DOUBLE,
	people_vaccinated_per_hundred DOUBLE,
	people_fully_vaccinated_per_hundred	DOUBLE,
	total_boosters_per_hundred DOUBLE,
	new_vaccinations_smoothed_per_million INT,
	new_people_vaccinated_smoothed INT,
	new_people_vaccinated_smoothed_per_hundred DOUBLE,
	stringency_index DOUBLE,
	population_density DOUBLE,
	median_age DOUBLE,
	aged_65_older DOUBLE,
	aged_70_older DOUBLE,
	gdp_per_capita DOUBLE,
	extreme_poverty	DOUBLE,
	cardiovasc_death_rate DOUBLE,	
	diabetes_prevalence DOUBLE,
	female_smokers DOUBLE,
	male_smokers DOUBLE,
	handwashing_facilities DOUBLE,
	hospital_beds_per_thousand DOUBLE,
	life_expectancy	DOUBLE,
	human_development_index	DOUBLE,
	population INT,
	excess_mortality_cumulative_absolute DOUBLE,	
	excess_mortality_cumulative	DOUBLE,
	excess_mortality DOUBLE,
	excess_mortality_cumulative_per_million DOUBLE
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/owid-covid-data.csv' INTO TABLE covid
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

-- Viewing the whole table

SELECT * 
FROM covid
ORDER BY 3, 4; -- location, date

-- Removing the continent data

SELECT * 
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;

-- Above query not working does not seem to be working. OWID defined regions (continents) can be distinguished by their iso_code that begins with 'OWID'.

SELECT * 
FROM covid
WHERE iso_code NOT LIKE 'OWID%'
ORDER BY 3, 4; 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid
WHERE iso_code NOT LIKE 'OWID%'
ORDER BY 1, 2;

-- Total cases vs. Total deaths (in Australia)

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS death_percentage
FROM covid
WHERE location = 'Australia'
AND iso_code NOT LIKE 'OWID%'
ORDER BY 1, 2;

-- Total cases vs. Population (in Australia)
-- Showing the percentage of population that has contracted Covid

SELECT location, date, total_cases, population, (total_cases / population) * 100 AS contraction_percentage
FROM covid
WHERE location = 'Australia'
AND iso_code NOT LIKE 'OWID%'
ORDER BY 1, 2;

-- Countries highest infection count and contraction rate compared to population

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases / population) * 100 AS contraction_percentage
FROM covid
WHERE iso_code NOT LIKE 'OWID%'
GROUP BY location, population
ORDER BY contraction_percentage DESC;

-- Countries with the highest rates of death

SELECT location, MAX(total_deaths) AS highest_death_count, MAX(total_deaths / population) * 100 AS death_percentage
FROM covid
WHERE iso_code NOT LIKE 'OW%'
GROUP BY location
ORDER BY highest_death_count DESC;

-- By continent

SELECT iso_code, location, MAX(total_deaths) AS highest_death_count, MAX(total_deaths / population) * 100 AS death_percentage
FROM covid
WHERE iso_code LIKE 'OWID%' 
-- Excluding the OWID data that is not a major continent
AND iso_code NOT LIKE 'OWID_WRL'
AND iso_code NOT LIKE 'OWID_HIC' 
AND iso_code NOT LIKE 'OWID_UMC'
AND iso_code NOT LIKE 'OWID_LMC'
AND iso_code NOT LIKE 'OWID_EUN' 
AND iso_code NOT LIKE 'OWID_LIC'
AND iso_code NOT LIKE 'OWID_KOS'
AND iso_code NOT LIKE 'OWID_ENG'
AND iso_code NOT LIKE 'OWID_NIR'
AND iso_code NOT LIKE 'OWID_SCT'
AND iso_code NOT LIKE 'OWID_WLS'
AND iso_code NOT LIKE 'OWID_CYN'
GROUP BY iso_code, location
ORDER BY highest_death_count DESC;

-- Global numbers

SELECT date, SUM(new_cases), SUM(new_deaths), (SUM(new_deaths) / SUM(new_cases)) * 100 AS death_percentage
FROM covid
WHERE iso_code NOT LIKE 'OWID%'
AND MOD(date, 7) = 0
GROUP BY date
ORDER BY 1, 2;

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths) / SUM(new_cases)) * 100 AS death_percentage
FROM covid
WHERE iso_code NOT LIKE 'OWID%'
-- GROUP BY date
ORDER BY 1, 2;

-- Total population vs. vaccinations

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT continent, location, date, population, new_vaccinations
, SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY location
, date) AS rolling_people_vaccinated
FROM covid
WHERE iso_code NOT LIKE 'OWID%'
ORDER BY 2, 3
)
SELECT *, (rolling_people_vaccinated / population) * 100
FROM pop_vs_vac;

-- Visualisations

-- 1

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths) / SUM(new_cases)) * 100 AS death_percentage
FROM covid
WHERE iso_code NOT LIKE 'OWID%'
-- GROUP BY date
ORDER BY 1, 2;

-- 2

SELECT iso_code, location, MAX(total_deaths) AS highest_death_count, MAX(total_deaths / population) * 100 AS death_percentage
FROM covid
WHERE iso_code LIKE 'OWID%' 
-- Excluding the OWID data that is not a major continent
AND iso_code NOT LIKE 'OWID_WRL'
AND iso_code NOT LIKE 'OWID_HIC' 
AND iso_code NOT LIKE 'OWID_UMC'
AND iso_code NOT LIKE 'OWID_LMC'
AND iso_code NOT LIKE 'OWID_EUN' 
AND iso_code NOT LIKE 'OWID_LIC'
AND iso_code NOT LIKE 'OWID_KOS'
AND iso_code NOT LIKE 'OWID_ENG'
AND iso_code NOT LIKE 'OWID_NIR'
AND iso_code NOT LIKE 'OWID_SCT'
AND iso_code NOT LIKE 'OWID_WLS'
AND iso_code NOT LIKE 'OWID_CYN'
GROUP BY iso_code, location
ORDER BY highest_death_count DESC;

-- 3

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases / population) * 100 AS contraction_percentage
FROM covid
WHERE iso_code NOT LIKE 'OWID%'
GROUP BY location, population
ORDER BY contraction_percentage DESC;

-- 4

SELECT location, population, date, MAX(total_cases) AS highest_infection_count, MAX(total_cases / population) * 100 AS contraction_percentage
FROM covid
WHERE iso_code NOT LIKE 'OWID%'
GROUP BY location, population, date
ORDER BY contraction_percentage DESC;