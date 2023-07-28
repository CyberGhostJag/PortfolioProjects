SELECT * 
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at the total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in the US
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at the total cases vs the population
-- Shows what percentage of the population has covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as GotCovid
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
GROUP BY population, location
ORDER BY PercentPopulationInfected desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
SELECT location, MAX(cast(total_deaths as int)) as TotalDeaths
FROM CovidDeaths
WHERE Continent is null
GROUP BY location
ORDER BY TotalDeaths desc

-- Showing Countries with Highest Mortality per Country

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeaths
FROM CovidDeaths
WHERE Continent is not null
GROUP BY population, location
ORDER BY TotalDeaths desc

-- Showing the Continents with the Highest Death Count

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeaths
FROM CovidDeaths
WHERE Continent is not null
GROUP BY continent
ORDER BY TotalDeaths desc


-- Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date 
ORDER BY 1,2


SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null 
ORDER BY 1,2



SELECT * 
FROM CovidVaccinations$
ORDER BY 3,4

-- Looking at total population vs Vaccination

SELECT Dea.continent, dea.location, Dea.date, dea.population, Vax.new_vaccinations, SUM(CONVERT(int,Vax.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RunningTotalVax
FROM CovidDeaths AS Dea
JOIN CovidVaccinations$ AS Vax
	ON Dea.location = Vax.location
	AND Dea.date = Vax.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Use CTE

WITH PopvsVax (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT Dea.continent, dea.location, Dea.date, dea.population, Vax.new_vaccinations, SUM(CONVERT(int,Vax.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RunningTotalVax
FROM CovidDeaths AS Dea
JOIN CovidVaccinations$ AS Vax
	ON Dea.location = Vax.location
	AND Dea.date = Vax.date
WHERE dea.continent is not null
)
SELECT * , (RollingPeopleVaccinated/Population)*100 as PercentageOfPopulationVaxxed
FROM PopvsVax


-- Temp Table

--DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT Dea.continent, dea.location, Dea.date, dea.population, Vax.new_vaccinations, SUM(CONVERT(int,Vax.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RunningTotalVax
FROM CovidDeaths AS Dea
JOIN CovidVaccinations$ AS Vax
	ON Dea.location = Vax.location
	AND Dea.date = Vax.date
WHERE dea.continent is not null 

SELECT * , (RollingPeopleVaccinated/Population)*100 as PercentageOfPopulationVaxxed
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT Dea.continent, dea.location, Dea.date, dea.population, Vax.new_vaccinations, SUM(CONVERT(int,Vax.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RunningTotalVax
FROM CovidDeaths AS Dea
JOIN CovidVaccinations$ AS Vax
	ON Dea.location = Vax.location
	AND Dea.date = Vax.date
WHERE dea.continent is not null 

SELECT *
FROM PercentPopulationVaccinated
