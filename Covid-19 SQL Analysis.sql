/*

Covid-19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- 1.
SELECT *
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
ORDER BY 3,4



-- 2.
--Select data that we are going to be using

SELECT location
	  ,date
	  ,total_cases
	  ,new_cases
	  ,total_deaths
	  ,population
FROM [Portfolio Project]..CovidDeaths





-- 3.
--Total Cases vs. Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT location
	  ,date
	  ,total_cases
	  ,total_deaths
	  ,(total_deaths/total_cases)*100 AS death_percentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
ORDER BY 1,2





-- 4.
--Total Cases vs Population
--Shows what percentage of population infected with covid

SELECT location
	  ,date
	  ,population
	  ,total_cases
	  ,(total_cases/population)*100 AS percentage_population_infected
FROM [Portfolio Project]..CovidDeaths
ORDER BY 1,2





-- 5.
--Countries with highest infection rates compared to population

SELECT location
	  ,population
	  ,MAX(total_cases) AS highest_infection_count
	  ,MAX((total_cases/population)*100) AS percentage_population_infected
FROM [Portfolio Project]..CovidDeaths
GROUP BY location, population
ORDER BY percentage_population_infected DESC





-- 6.
--Countries with highest death count per population

SELECT location 
	  ,MAX(CAST(total_deaths AS INT)) AS total_death_count 
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC





--CONTINENT NUMBERS

-- 7.
--Conintent with highest death count per population

SELECT continent
	  ,MAX(CAST(total_deaths AS INT)) AS total_death_count 
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC





-- GLOBAL NUMBERS

-- 8.
-- Total Deaths vs Total Cases
-- Shows percentage of fatal covid cases

SELECT SUM(new_cases) AS total_cases
	  ,SUM(CAST(new_deaths AS INT)) AS total_deaths
	  ,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null 





-- 9.
-- Total Population vs Vaccinations
-- Shows percentage of population that has recieved at least one Covid Vaccine

SELECT dea.continent
	  ,dea.location
	  ,dea.date
	  ,dea.population
	  ,vac.new_vaccinations
	  ,SUM(CONVERT(INT,vac.new_vaccinations)) 
OVER (PARTITION BY dea.Location Order by d.location, d.Date) AS rolling_people_vaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3



-- 10.
-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent
	  ,dea.location
	  ,dea.date
	  ,dea.population
	  ,vac.new_vaccinations
	  ,SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
From PopvsVac





-- 11.
-- Using Temp Table to perform Calculation on PARTITION BY in previous query

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent
	  ,dea.location
	  ,dea.date
	  ,dea.population
	  ,vac.new_vaccinations
	  ,SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated





-- 12.
-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent
	  ,dea.location
	  ,dea.date
	  ,dea.population
	  ,vac.new_vaccinations
	  ,SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 