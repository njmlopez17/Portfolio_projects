-- Display all from table
SELECT * FROM portfolio_project.covid_deaths ORDER BY 2,3;

-- =======================================================
-- ********GLOBAL NUMBERS********
-- =======================================================

-- Global numbers of cases and deaths and % of death in total account population
SELECT 
    SUM(t_death.total_cases) AS 'Total Cases', 
    SUM(t_death.total_deaths) AS 'Total Deaths',
	(SUM(t_death.total_deaths)/SUM(t_death.total_cases))*100 AS 'Percentage'
FROM
	portfolio_project.covid_deaths AS t_death
WHERE
	t_death.continent IS NOT NULL
ORDER BY
	1,2 
;

-- =======================================================
-- ********BREAK THINGS DOWN BY CONTINENT********
-- =======================================================

-- Display covid death % per continent
SELECT 
	continent AS 'Continent', 
    SUM(total_cases) AS 'Total Cases', 
    SUM(total_deaths) AS 'Total Deaths', 
    (SUM(total_deaths)/SUM(total_cases))*100 AS 'Percentage' 
FROM 
	portfolio_project.covid_deaths 
WHERE
	continent IS NOT NULL
GROUP BY 
	continent
ORDER BY 
	1
;

-- Calculate continent with highest % infection rate compared to its population
SELECT 
    t_death.continent AS 'Continent',
    MAX(t_death.total_cases) AS 'Highest Infected Count', 
	MAX((t_death.total_cases/t_death.population))*100 AS 'Percentage'
FROM
	portfolio_project.covid_deaths AS t_death
WHERE
	t_death.continent IS NOT NULL
GROUP BY
    t_death.continent
ORDER BY
	Percentage DESC
;

-- Calculate continent with highest % death rate compared to its population
SELECT 
    t_death.continent AS 'Continent',
    MAX(t_death.total_deaths) AS 'Highest Death Count', 
	MAX((t_death.total_deaths/t_death.population))*100 AS 'Percentage'
FROM
	portfolio_project.covid_deaths AS t_death
WHERE
	t_death.continent IS NOT NULL
GROUP BY
    t_death.continent
ORDER BY
	Percentage DESC
;

-- =======================================================
-- ********BREAK THINGS DOWN BY COUNTRY (LOCATION)********
-- =======================================================

-- Display total highest count per country (location)
SELECT 
    location AS 'Country',
    MAX(total_deaths) AS 'Total Highest Count' 
FROM 
	portfolio_project.covid_deaths 
GROUP BY 
	location
ORDER BY 
	2 DESC
;

-- Display covid death % per country (location)
SELECT 
    location AS 'Country',
    SUM(total_cases) AS 'Total Cases', 
    SUM(total_deaths) AS 'Total Deaths', 
    (SUM(total_deaths)/SUM(total_cases))*100 AS 'Percentage' 
FROM 
	portfolio_project.covid_deaths 
WHERE
	continent IS NOT NULL
GROUP BY 
	location
ORDER BY 
	4 DESC
;

-- Calculate total cases vs total deaths
-- % likelihood of dying if contracted in certain country
SELECT 
    location AS 'Country',
    date AS 'Date',
    total_cases AS 'Total Cases', 
    total_deaths AS 'Total Deaths', 
	(total_deaths/total_cases)*100 AS 'Percentage'
FROM
	portfolio_project.covid_deaths
WHERE
	continent IS NOT NULL
ORDER BY
	1,2 
;

-- Calculate total cases VS population
-- % of cases vs population per subset of country
SELECT 
    t_death.location AS 'Country',
	t_death.date AS 'Date',
	t_death.population AS 'Population',
    t_death.total_cases AS 'Total Cases', 
    t_death.total_deaths AS 'Total Deaths', 
	(t_death.total_cases/t_death.population)*100 AS 'Percentage'
FROM
	portfolio_project.covid_deaths AS t_death
WHERE
	t_death.location 
		LIKE 
			'%us%'
AND
	t_death.continent IS NOT NULL
ORDER BY
	1,2 
;

-- Calculate total death VS population
-- % of death vs population per subset of country
SELECT 
    t_death.location AS 'Country',
	t_death.date AS 'Date',
	t_death.population AS 'Population',
    t_death.total_cases AS 'Total Cases', 
    t_death.total_deaths AS 'Total Deaths', 
	(t_death.total_deaths/t_death.population)*100 AS 'Percentage'
FROM
	portfolio_project.covid_deaths AS t_death
WHERE
	t_death.location 
		LIKE 
			'%us%'
AND
	t_death.continent IS NOT NULL
ORDER BY
	1,2 
;

-- Calculate country with highest % infection rate compared to its population
SELECT 
    t_death.location AS 'Country',
	t_death.population AS 'Population',
    MAX(t_death.total_cases) AS 'Highest Infected Count', 
	MAX((t_death.total_cases/t_death.population))*100 AS 'Percentage'
FROM
	portfolio_project.covid_deaths AS t_death
WHERE
	t_death.continent IS NOT NULL
GROUP BY
    t_death.location,
	t_death.population
ORDER BY
	Percentage DESC
;

-- Calculate country with highest % death rate compared to its population
SELECT 
    t_death.location AS 'Country',
	t_death.population AS 'Population',
    MAX(t_death.total_deaths) AS 'Highest Death Count', 
	MAX((t_death.total_deaths/t_death.population))*100 AS 'Percentage'
FROM
	portfolio_project.covid_deaths AS t_death
WHERE
	t_death.continent IS NOT NULL
GROUP BY
    t_death.location,
    t_death.population
ORDER BY
	Percentage DESC
;

-- =======================================================
-- ********JOIN Statements********
-- =======================================================

-- Total population vs vaccinations
SELECT
	t_death.continent AS 'Continent',
    t_death.location AS 'Location',
    t_death.date AS 'Date',
    t_death.population AS 'Population',
    t_vacc.new_vaccinations AS 'New Vaccination'
FROM
	portfolio_project.covid_deaths AS t_death
	JOIN
		portfolio_project.covid_vaccinations AS t_vacc
ON
	t_death.location = t_vacc.location
    AND
		t_death.date= t_vacc.date
WHERE
	t_death.continent IS NOT NULL
    AND
		t_vacc.new_vaccinations IS NOT NULL
ORDER BY
	2,3
;

-- =======================================================
-- ********Windows Function********
-- =======================================================

-- Total population vs vaccinations with rolling vaccination numbers by country
SELECT
	t_death.continent AS 'Continent',
    t_death.location AS 'Location',
    t_death.date AS 'Date',
    t_death.population AS 'Population',
    t_vacc.new_vaccinations AS 'New Vaccination',
    SUM(t_vacc.new_vaccinations) 
		OVER(PARTITION BY t_death.location ORDER BY t_death.location, t_death.date) AS 'Rolling Vacc. Numbers'
FROM
	portfolio_project.covid_deaths AS t_death
	JOIN
		portfolio_project.covid_vaccinations AS t_vacc
ON
	t_death.location = t_vacc.location
    AND
		t_death.date= t_vacc.date
WHERE
	t_death.continent IS NOT NULL
ORDER BY
	2,3
;

-- % of people vaccinated by country (using CTE)

With pop_vs_vacc (
	continent,
    location,
    date,
    population,
    new_vaccinations,
    Rolling_Vacc_Numbers
)
AS
(
SELECT
	t_death.continent AS 'Continent',
    t_death.location AS 'Location',
    t_death.date AS 'Date',
    t_death.population AS 'Population',
    t_vacc.new_vaccinations AS 'New Vaccination',
    SUM(t_vacc.new_vaccinations) 
		OVER(PARTITION BY t_death.location ORDER BY t_death.location, t_death.date) AS Rolling_Vacc_Numbers
FROM
	portfolio_project.covid_deaths AS t_death
	JOIN
		portfolio_project.covid_vaccinations AS t_vacc
ON
	t_death.location = t_vacc.location
    AND
		t_death.date= t_vacc.date
WHERE
	t_death.continent IS NOT NULL
)
Select
	*,
    (Rolling_Vacc_Numbers/population)*100 AS '% of people vaccinated'
FROM
	pop_vs_vacc
-- WHERE
-- 	new_vaccinations IS NOT NULL
-- AND
-- 	location = 'Afghanistan'
;

-- % of people vaccinated by country (using TEMP TABLE)

DROP TABLE IF EXISTS tempTB_percent_pop_vacc;

CREATE TABLE tempTB_percent_pop_vacc (
	continent VARCHAR(255),
    location VARCHAR(255),
    date DATE,
    population INT,
    new_vaccinations VARCHAR(255),
    rolling_Vacc_Numbers INT
	)
;

INSERT INTO 
	tempTB_percent_pop_vacc 
SELECT
	t_death.continent AS 'Continent',
    t_death.location AS 'Location',
    t_death.date AS 'Date',
    t_death.population AS 'Population',
    t_vacc.new_vaccinations AS 'New Vaccination',
    SUM(t_vacc.new_vaccinations) 
		OVER(PARTITION BY t_death.location ORDER BY t_death.location, t_death.date) AS Rolling_Vacc_Numbers
FROM
	portfolio_project.covid_deaths AS t_death
	JOIN
		portfolio_project.covid_vaccinations AS t_vacc
ON
	t_death.location = t_vacc.location
    AND
		t_death.date= t_vacc.date
WHERE
	t_death.continent IS NOT NULL
;

Select
	*,
    (Rolling_Vacc_Numbers/population)*100 AS '% of people vaccinated'
FROM
	tempTB_percent_pop_vacc
-- WHERE
-- 	new_vaccinations IS NOT NULL
-- AND
-- 	location = 'Afghanistan'
;

-- =======================================================
-- ********CREATE VIEW********
-- =======================================================

CREATE VIEW view_percent_pop_vacc AS
SELECT
	t_death.continent AS 'Continent',
    t_death.location AS 'Location',
    t_death.date AS 'Date',
    t_death.population AS 'Population',
    t_vacc.new_vaccinations AS 'New Vaccination',
    SUM(t_vacc.new_vaccinations) 
		OVER(PARTITION BY t_death.location ORDER BY t_death.location, t_death.date) AS 'Rolling Vacc. Numbers'
FROM
	portfolio_project.covid_deaths AS t_death
	JOIN
		portfolio_project.covid_vaccinations AS t_vacc
ON
	t_death.location = t_vacc.location
    AND
		t_death.date= t_vacc.date
WHERE
	t_death.continent IS NOT NULL
ORDER BY
	2,3
;

SELECT 
	*
FROM
view_percent_pop_vacc
;

