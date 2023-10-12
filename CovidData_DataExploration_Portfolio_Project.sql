
SELECT *
FROM `myportfolio-401818.Covid.CovidDeaths`
WHERE continent IS NOT NULL
ORDER BY 3, 4

-- Select data I am going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `myportfolio-401818.Covid.CovidDeaths`
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths for the United States
-- Shows what percentage of total cases result in deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM `myportfolio-401818.Covid.CovidDeaths`
WHERE location like '%States%'
ORDER BY 1, 2

-- Looking at Total Cases vs Population for Costa Rica
-- Shows what percentage of Population has gotten Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM `myportfolio-401818.Covid.CovidDeaths`
WHERE location like '%Costa%'
ORDER BY 1, 2

-- Looking at Countries with highest infection rate compared to population

SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM `myportfolio-401818.Covid.CovidDeaths`
GROUP BY location, population
ORDER BY 4 DESC

-- Looking at Countries with highest death rate compared to population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM `myportfolio-401818.Covid.CovidDeaths`
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- Breaking things down by continent

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM `myportfolio-401818.Covid.CovidDeaths`
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC

-- Global Numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM `myportfolio-401818.Covid.CovidDeaths`
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM `myportfolio-401818.Covid.CovidDeaths`
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1

-- combining death and vaccination tables to look at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM `myportfolio-401818.Covid.CovidDeaths` dea
JOIN `myportfolio-401818.Covid.CovidVaccinations` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1, 2, 3

-- Now creating a new column that creates a running count of new vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM `myportfolio-401818.Covid.CovidDeaths` dea
JOIN `myportfolio-401818.Covid.CovidVaccinations` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- Uing CTE 

WITH PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM `myportfolio-401818.Covid.CovidDeaths` dea
JOIN `myportfolio-401818.Covid.CovidVaccinations` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *
FROM PopvsVac

-- Using Temp Table

CREATE TABLE #PercentPopulationVaccinated
(
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM `myportfolio-401818.Covid.CovidDeaths` dea
JOIN `myportfolio-401818.Covid.CovidVaccinations` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW myportfolio-401818.Covid.PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM `myportfolio-401818.Covid.CovidDeaths` dea
JOIN `myportfolio-401818.Covid.CovidVaccinations` vac 
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM `myportfolio-401818.Covid.PercentPopulationVaccinated`
