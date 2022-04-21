-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you get covid in the US
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM CovidDeaths$
WHERE location like '%united states%'
ORDER BY 1, 2 DESC

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as InfectionRate 
FROM CovidDeaths
WHERE location like '%united states%'
ORDER BY 1, 2 DESC

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as InfectionRate 
FROM CovidDeaths$
--WHERE location like '%united states%'
GROUP BY location, population
ORDER BY 4 DESC

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC  

-- Showing Continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global Numbers
SELECT SUM(cast(new_cases as int)) as TotalCases, SUM(cast(new_deaths as float)) as TotalDeaths, SUM(cast(new_deaths as float))/sum(new_cases)*100 as DeathPercentage 
FROM CovidDeaths$
WHERE continent is not null


-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_vainations, RollingPeopleVaccinated)
AS
(
-- Looking at Total Population vs Vaccinations
--shows vax per day
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated

FROM CovidDeaths$ dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1, 2, 3 
)

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentVaccinatedPop
From PopvsVac


-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RolledPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1, 2, 3  

SELECT *, (RolledPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1, 2, 3  

