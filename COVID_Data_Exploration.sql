SELECT *
FROM FirstProject.coviddeaths
WHERE continent != ''
ORDER BY 3,4;

SELECT *
FROM FirstProject.covidvaccinations
ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM FirstProject.coviddeaths
ORDER BY 1,2;

-- Death percentage
SELECT location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100, 2) AS Deathpercentage
FROM FirstProject.coviddeaths
WHERE location LIKE('%nep%') AND continent != ''
ORDER BY date DESC,2;

-- Infected percentage over total population
SELECT location, date, population,total_cases, round((total_cases/population)*100, 4) AS Infectionrate
FROM FirstProject.coviddeaths
WHERE location LIKE('%nep%') AND continent != ''
ORDER BY date DESC,2;

-- Countries with highest infection rate compared to it's population.
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, ROUND(MAX((total_cases/population)*100),4) AS InfectionRate
FROM FirstProject.coviddeaths
WHERE continent != ''
GROUP BY location, population
ORDER BY InfectionRate DESC;

-- Countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS DeathCount
FROM FirstProject.coviddeaths
WHERE continent != ''
GROUP BY location
ORDER BY DeathCount DESC;

-- Continent with highest death counts.
SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) AS DeathCount
FROM FirstProject.coviddeaths
WHERE continent != ''
GROUP BY continent
ORDER BY DeathCount DESC;

-- Overall death percentages across the world
SELECT SUM(new_cases) AS TotalInfected, SUM(new_deaths) AS TotalDeaths, ROUND((SUM(new_deaths)/SUM(new_cases))*100, 2) AS DeathPercentage
FROM FirstProject.coviddeaths
WHERE continent != '';

-- Using CTE
WITH VacPerc(continent, location, date, population, new_vaccinations,newlyVaccinated)
AS (
	SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS UNSIGNED))
    OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS newlyVaccinated
    FROM FirstProject.coviddeaths AS d
    JOIN FirstProject.covidvaccinations AS v
    ON d.location = v.location
    AND d.date = v.date
    WHERE d.continent != ''
    )
SELECT *, (newlyVaccinated/population)*100
FROM VacPerc;

-- Temp table
USE FirstProject;
DROP TABLE IF EXISTS VactinatedPercentage;
CREATE TABLE  VactinatedPercentage(
continent VARCHAR(255),
location VARCHAR(255),
date DATETIME,
population INT,
new_vaccinations INT,
newlyVaccinated INT
);

INSERT INTO VactinatedPercentage
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
	SUM(v.new_vaccinations)
    OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS newlyVaccinated
    FROM FirstProject.coviddeaths AS d
    JOIN FirstProject.covidvaccinations AS v
    ON d.location = v.location
    AND d.date = v.date;
   -- WHERE d.continent != '';
    
SELECT *, (newlyVaccinated/population)*100
FROM VactinatedPercentage;


-- Creating view
CREATE VIEW VaccinatedPercentage AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
	SUM(CAST(v.new_vaccinations AS SIGNED))
    OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS newlyVaccinated
    FROM FirstProject.coviddeaths AS d
    JOIN FirstProject.covidvaccinations AS v
    ON d.location = v.location
    AND d.date = v.date
    WHERE d.continent != '';