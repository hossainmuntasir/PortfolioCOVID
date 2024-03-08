--SELECT Location, date, total_cases, new_cases, total_deaths, population 
--FROM PortfolioProject.dbo.[CovidDeaths1 ]
--where continent is not null
--order by 1,2

--total cases vs total deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths*1.0/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.[CovidDeaths1 ]
WHERE location like '%Bangladesh%'
order by 1,2
SELECT sum(total_deaths)
FROM PortfolioProject.dbo.[CovidDeaths1 ]
WHERE location like '%Bangladesh%'




--Total Cases vs Population
--What percentage of the population got covid?
SELECT Location, date, total_cases, Population,CAST(round((total_cases*1.0/Population)*100,4)AS DECIMAL(10,4)) as DeathPercentage
FROM PortfolioProject.dbo.[CovidDeaths1 ]
WHERE location like '%states%'
order by 1,2




--Countries with highest infection rate compared to Population
SELECT Location,Population, Max(total_cases) as HighestInfectionCount, CAST(Max((1.0*total_cases/population))*100 AS DECIMAL(10,4)) AS PercentsofPopulationInfected
FROM PortfolioProject.dbo.[CovidDeaths1 ]
WHERE continent is not null
GROUP By Population, Location
order by 4 DESC


--Countries with highest death
SELECT Location,Population, Max(total_deaths) as HighestDeathsCount, CAST(Max((1.0*total_deaths/population))*100 AS DECIMAL(10,4)) AS PercentsofPopulationDied
FROM PortfolioProject.dbo.[CovidDeaths1 ]
WHERE continent is not null
GROUP By Population, Location
order by 3 DESC


--Break it down by continents
SELECT location, Max(total_deaths) as HighestDeathsCount
FROM PortfolioProject.dbo.[CovidDeaths1 ]
WHERE continent is null
GROUP By location
order by 2 DESC


--Global Numbers

SELECT date, SUM(new_cases)as Total_Cases, SUM(new_deaths) AS Total_Deaths, CAST((SUM(new_deaths*1.0)/SUM(new_cases)) AS DECIMAL (10,4))*100 as GlobalDeathPercentage
FROM PortfolioProject.dbo.[CovidDeaths1 ]
WHERE continent is not null
GROUP BY date
ORDER BY 1 DESC


--Total death percentage
SELECT SUM(new_cases)as Total_Cases, SUM(new_deaths) AS Total_Deaths, CAST((SUM(new_deaths*1.0)/SUM(new_cases)) AS DECIMAL (10,4))*100 as GlobalDeathPercentage
FROM PortfolioProject.dbo.[CovidDeaths1 ]
WHERE continent is not null
ORDER BY 1 DESC


SELECT * 
FROM PortfolioProject.dbo.CovidVaccinations1


--Total population vs vaccinations
-- how many peole in the world got vaccinations?
SELECT dea.continent , dea.location, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS Total_Vaccinated
FROM PortfolioProject.dbo.[CovidDeaths1 ] AS dea
JOIN PortfolioProject.dbo.CovidVaccinations1 AS vac
	on dea.location = vac.location 
	and dea.date = vac.date
	WHERE dea.continent is not null
ORDER BY 1,2,3


--CTE == Common Table Expression

WITH PopVsVac (continent, Location, Date, Population, New_Vaccinations, Total_Vaccinated)
as
(
SELECT dea.continent , dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS Total_Vaccinated
FROM PortfolioProject.dbo.[CovidDeaths1 ] AS dea
JOIN PortfolioProject.dbo.CovidVaccinations1 AS vac
	on dea.location = vac.location 
	and dea.date = vac.date
	WHERE dea.continent is not null
--ORDER BY 1,2,3
)

SELECT * , (Total_Vaccinated*1.0/Population)*100 as VaccinatedRate
FROM PopVsVac
WHERE Location like 'Bangladesh'


--Temp table

DROP TABLE IF exists #PercentagePopulationVaccinated
Create TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric, 
Total_Vaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent , dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS Total_Vaccinated
FROM PortfolioProject.dbo.[CovidDeaths1 ] AS dea
JOIN PortfolioProject.dbo.CovidVaccinations1 AS vac
	on dea.location = vac.location 
	and dea.date = vac.date
	WHERE dea.continent is not null




--Creating view for storing data for later
CREATE VIEW PercentagePopulationVaccinated as
SELECT dea.continent , dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS Total_Vaccinated
FROM PortfolioProject.dbo.[CovidDeaths1 ] AS dea
JOIN PortfolioProject.dbo.CovidVaccinations1 AS vac
	on dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null


SELECT * 
FROM PercentagePopulationVaccinated
