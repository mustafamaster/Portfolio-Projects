-- Data Check
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Data Exploration Begins
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent is not NULL
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths (Shows likelihood of death if you contract covid)
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%Canada%' -> per country percentage
ORDER BY 1,2

-- Total Cases vs Population -> Percentage of population that is infected with Covid
SELECT location, date, total_cases, new_cases, population, (total_cases/population)*100 AS infected_percentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%Canada%' -> per country percentage
ORDER BY 1,2

-- Countries with highest infection rate relative to population
SELECT location, population,  MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS highest_infected_percentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%Canada%' -> per country percentage
GROUP BY location, population
ORDER BY highest_infected_percentage DESC

-- Countries with highest death rate relative to population
SELECT location,  MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%Canada%' -> per country percentage
WHERE continent is not NULL
GROUP BY location
ORDER BY Total_Death_Count DESC

-- Continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
--Where location like '%Canada%'
WHERE continent is not NULL 
GROUP BY continent
ORDER BY Total_Death_Count DESC

-- Global Numbers
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent is not NULL 
GROUP BY date
ORDER BY 1,2

-- Total Population vs Vaccinations (% of population that has received at least 1 vaccine)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not NULL 
ORDER BY 2,3

-- Using CTE to perform calculation on PARTITION BY in previous query
WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not NULL 
--ORDER BY 2,3
)
SELECT *
, (rolling_people_vaccinated /population)*100
FROM PopvsVac

-- Using Temp Table to perform calculation on PARTITION BY in previous query
DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

Insert into #percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
--WHERE dea.continent is not NULL 
--ORDER BY 2,3

SELECT *
, (rolling_people_vaccinated/population)*100
FROM #percent_population_vaccinated

-- Creating view to store data for visualizations
CREATE VIEW percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not NULL