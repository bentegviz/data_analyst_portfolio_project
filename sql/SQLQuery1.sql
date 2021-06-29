--COVID DEATHS TABLE
--SELECT *
--FROM [owid-covid-data_deaths]
--WHERE continent is not null
--ORDER BY 3,4;

--SELECT *
--FROM [owid-covid-data_vaccinations]
--ORDER BY 3,4

--Select Data to Use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [owid-covid-data_deaths]
ORDER BY location, date;

--Looking at Total Cases vs Total Deaths
--Indicates Percentage of Total Cases resulting in Death
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM [owid-covid-data_deaths]
WHERE location like '%states%'
ORDER BY location, date;

--Looking at Total Cases compared to Population
--Indicates Total Cases per Population
SELECT location, date, total_cases, population, (total_cases/population)*100 AS pop_percentage
FROM [owid-covid-data_deaths]
WHERE location like '%states%'
ORDER BY location, date;

--Looking at the Countries with highest Total Cases compared to Population
SELECT location, population, MAX(total_cases) AS max_infected, MAX((total_cases/population))*100 AS infect_percentage
FROM [owid-covid-data_deaths]
WHERE population > 1000000
GROUP BY location, population
ORDER BY infect_percentage DESC;

--Looking at Country with the highest Death Count per Population
--CAST total_deaths to INT
SELECT location, MAX(CAST(total_deaths AS int)) AS max_deaths
FROM [owid-covid-data_deaths]
--WHERE population > 1000000
WHERE continent is not null
GROUP BY location
ORDER BY max_deaths DESC;

--Looking at Continents and larger Geographic Locations Data Snapshot
SELECT location, MAX(CAST(total_deaths AS int)) AS max_deaths
FROM [owid-covid-data_deaths]
WHERE continent is null
GROUP BY location
ORDER BY max_deaths DESC;

--Looking at Continents and larger Geographic Locations Data Snapshot
SELECT continent, MAX(CAST(total_deaths AS int)) AS max_deaths
FROM [owid-covid-data_deaths]
WHERE continent is not null
GROUP BY continent
ORDER BY max_deaths DESC;

--Global Numbers
--Begin Visualization Queries
--Show Continents with Highest Death Count per Population
SELECT date, SUM(new_cases) AS tota_new_cases, SUM(CAST(new_deaths AS int)) AS total_new_deaths, 
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM [owid-covid-data_deaths]
WHERE continent is not null
GROUP BY date
ORDER BY date;


--COVID VACCINATIONS TABLE
--Joining Data on Location and Date
--Looking at Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS new_vaccinations_by_date
, 
FROM [owid-covid-data_deaths] dea
JOIN [owid-covid-data_vaccinations] vac 
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY location, date;


--Use CTE (Common Table Expression)
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, new_vaccinations_by_date)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS new_vaccinations_by_date 
FROM [owid-covid-data_deaths] dea
JOIN [owid-covid-data_vaccinations] vac 
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY location, date
)

--View CTE
SELECT *, (new_vaccinations_by_date/population)*100 AS new_vaccination_per_date_percentage
FROM pop_vs_vac



--Use TEMP Table
DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
new_vaccinations_by_date numeric
)

INSERT INTO #percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS new_vaccinations_by_date 
FROM [owid-covid-data_deaths] dea
JOIN [owid-covid-data_vaccinations] vac 
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY location, date


--View TEMP Table
SELECT *, (new_vaccinations_by_date/population)*100 AS new_vaccination_per_date_percentage
FROM #percent_population_vaccinated



--CREATE VIEWS for Visualizations in Tableau
CREATE VIEW percent_population_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS new_vaccinations_by_date 
FROM [owid-covid-data_deaths] dea
JOIN [owid-covid-data_vaccinations] vac 
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null


--TODO Create more views for Tableau
CREATE VIEW view2 AS



