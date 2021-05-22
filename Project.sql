--Selecting the CovidDeaths data and ordering it by Location and population-
SELECT * FROM Covid_Project..CovidDeaths
ORDER BY 3,4;

--Selecting the CovidVaccinations data and ordering it by Location and population-
SELECT * FROM Covid_Project..CovidVaccinations
ORDER BY 3,4;

--Selecting particular columns from CovidDeaths dataset-
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM Covid_Project..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Total Cases Vs Total Deaths VS Death Percentage
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DEATH_PERCENT 
FROM Covid_Project..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2
	--For INDIA
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DEATH_PERCENT 
FROM Covid_Project..CovidDeaths
WHERE location IN ('INDIA')
AND continent IS NOT NULL


--Samples tested Vs New Cases
SELECT  DEA.location, DEA.date, DEA.population, VAC.new_tests, DEA.new_cases
FROM Covid_Project..CovidDeaths DEA
JOIN Covid_Project..CovidVaccinations VAC
ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL

	--FOR INDIA
SELECT  DEA.location, DEA.date, DEA.population, DEA.new_cases, VAC.new_tests
FROM Covid_Project..CovidDeaths DEA
JOIN Covid_Project..CovidVaccinations VAC
ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.location = 'INDIA'
AND DEA.continent IS NOT NULL

--Daily Positivity Rate in India
SELECT  DEA.location, DEA.date, DEA.population, DEA.new_cases, VAC.new_tests, (DEA.new_cases/VAC.new_tests)*100 AS Positivity_Rate
FROM Covid_Project..CovidDeaths DEA
JOIN Covid_Project..CovidVaccinations VAC
ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.location = 'INDIA'
AND DEA.continent IS NOT NULL


--Total Cases Vs Total Population Vs Population Affected
SELECT location, date, total_cases, population, (total_cases/population)*100 AS AFFECTED_PERCENT 
FROM Covid_Project..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2 DESC, 5 DESC
	--For INDIA
SELECT location, date, total_cases, population, (total_cases/population)*100 AS AFFECTED_PERCENT 
FROM Covid_Project..CovidDeaths
WHERE location IN ('INDIA')
AND continent IS NOT NULL
ORDER BY 1,2 DESC, 5 DESC

--Average Positivity rate for each Country
SELECT DEA.location, AVG(CAST(VAC.positive_rate AS FLOAT))
FROM Covid_Project..CovidDeaths AS DEA
JOIN Covid_Project..CovidVaccinations AS VAC
ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
GROUP BY DEA.location
ORDER BY 2 DESC


--Countries with Highest- cases and infection rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestCases, (MAX(total_cases)/population)*100 AS HighestInfectionRate 
FROM Covid_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY 4 DESC

--Countries with Highest Death count, Highest Death Percentage compared to Population
SELECT location, MAX(CAST(total_deaths AS int)) AS HighestDeathCount, MAX((total_deaths)/population)*100 AS HighestDeathPercentage
FROM Covid_Project..CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

--Continent with highest Death count, Death Percentage
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount, MAX((total_deaths)/population)*100 AS HighestDeathPercentage
FROM Covid_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC


-- Global numbers per day
SELECT DATE, SUM(new_cases) AS TOTAL_CASES, SUM(CAST(new_deaths AS INT)) AS TOTAL_DEATHS, 
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DEATH_PERCENT 
FROM Covid_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Total Global Numbers
SELECT SUM(new_cases) AS TOTAL_CASES, SUM(CAST(new_deaths AS INT)) AS TOTAL_DEATHS, 
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DEATH_PERCENT 
FROM Covid_Project..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Joining two tables
SELECT * 
FROM Covid_Project..CovidDeaths DEA
JOIN Covid_Project..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date

-- Location Vs Vaccinations
SELECT DEA.location, SUM(CAST(VAC.new_vaccinations AS INT)) AS Vaccinations
FROM Covid_Project..CovidDeaths DEA
JOIN Covid_Project..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
GROUP BY DEA.location
ORDER BY 2 DESC


--Total Population Vs Vaccination each day
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
FROM Covid_Project..CovidDeaths DEA
JOIN Covid_Project..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3

--Total Population Vs Rolling Vaccination
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.New_vaccinations,
SUM(CAST(VAC.new_vaccinations AS INT)) OVER (PARTITION BY DEA.location ORDER BY DEA.LOCATION,
DEA.DATE) AS Rolling_People_Vaccinated
FROM Covid_Project..CovidDeaths DEA
JOIN Covid_Project..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3 


--New Vaccinations Vs Rolling count of people vaccinated Vs Rolling count Percentage
--USING CTE
WITH POPVSVAX (CONTINENT, LOCATION, DATE, POPULATION, NEW_VACCINATIONS, Rolling_People_Vaccinated)
AS
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.New_vaccinations,
SUM(CAST(VAC.new_vaccinations AS INT)) OVER (PARTITION BY DEA.location ORDER BY DEA.LOCATION,
DEA.DATE) AS Rolling_People_Vaccinated
FROM Covid_Project..CovidDeaths DEA
JOIN Covid_Project..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
)
SELECT *, (Rolling_People_Vaccinated/population)*100 as Rolling_Vax_Percentage
FROM POPVSVAX


--USING TEMP TABLE
DROP TABLE IF EXISTS #PERCENTPOPULATIONVACCINATED
CREATE TABLE #PERCENTPOPULATIONVACCINATED
(
CONTINENT NVARCHAR(255),
LOCATION NVARCHAR(255),
DATE DATETIME,
POPULATION NUMERIC,
NEW_VACCINATIONS NUMERIC,
ROLLING_VAX NUMERIC
)

INSERT INTO #PERCENTPOPULATIONVACCINATED
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations AS INT)) OVER (PARTITION BY DEA.location ORDER BY DEA.LOCATION,
DEA.DATE) AS ROLLING_VAX
FROM Covid_Project..CovidDeaths DEA
JOIN Covid_Project..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL

SELECT *, (ROLLING_VAX/POPULATION)*100 AS ROLLING_VAX_PERCENTAGE
FROM #PERCENTPOPULATIONVACCINATED


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
DROP VIEW IF EXISTS PERCENTPOPULATIONVACCINATED;

CREATE VIEW PERCENTPOPULATIONVACCINATED AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations AS INT)) OVER (PARTITION BY DEA.location ORDER BY DEA.LOCATION,
DEA.DATE) AS ROLLING_VAX
FROM Covid_Project..CovidDeaths DEA
JOIN Covid_Project..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL;


SELECT * FROM PERCENTPOPULATIONVACCINATED



