SELECT *
FROM CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--Order BY 3,4

-- Select Data that we are going to be using

SELECT
Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- also shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percent_deaths
FROM coviddeathscsv
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at total cases vs population
SELECT Location, date, total_cases, population, (total_cases/population)*100 as percent_of_pop
FROM coviddeathscsv
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population
SELECT Location, max(total_cases) as highestinfcount, population, max((total_cases/population))*100 as percent_of_pop
FROM coviddeathscsv
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY 4 desc

-- Looking at countries with highest death rate 
SELECT Location, max(total_deaths) as highestdeathcount, population, max((total_cases/population))*100 as percent_of_pop
FROM coviddeathscsv
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY 3 desc

-- Break things down by continent

SELECT location, max(total_deaths) as highestdeathcount, population, max((total_cases/population))*100 as percent_of_pop
FROM coviddeathscsv
--WHERE location like '%states%'
WHERE continent is null AND location NOT like '%income'
GROUP BY location, population
ORDER BY 2 desc

-- Showing continents with highest death count
SELECT continent, max(total_deaths) as highestdeathcount, max((total_cases/population))*100 as percent_of_pop
FROM coviddeathscsv
--WHERE location like '%states%'
WHERE continent is not null AND location NOT like '%income'
GROUP BY continent
ORDER BY 2 desc

-- Global numbers

SELECT sum(new_cases) sum_new_cases, SUM(new_deaths) sum_new_deaths, sum(new_deaths)/sum(new_cases)*100 --, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeathscsv
WHERE continent is not null

order by 1,2

-- total population vs vax 
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
sum(vax.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_vax_count
FROM coviddeathscsv dea
JOIN covidvaccinationscsv vax
ON dea.location = vax.location AND dea.date = vax.date AND dea.continent = vax.continent
WHERE dea.continent is not null
ORDER BY 2,3

-- Using CTE for rolling vax as percent of population

WITH PopVsVax (continent, location, date, population, new_vaccinations, rolling_vax_count)
as (SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
sum(vax.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_vax_count
FROM coviddeathscsv dea
JOIN covidvaccinationscsv vax
ON dea.location = vax.location AND dea.date = vax.date AND dea.continent = vax.continent
WHERE dea.continent is not null
)
SELECT *, (rolling_vax_count/population)*100
FROM PopsVsVax

-- Create view to store data for later visualizations

CREATE VIEW PercentPopVax as
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
sum(vax.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_vax_count
FROM coviddeathscsv dea
JOIN covidvaccinationscsv vax
ON dea.location = vax.location AND dea.date = vax.date AND dea.continent = vax.continent
WHERE dea.continent is not null