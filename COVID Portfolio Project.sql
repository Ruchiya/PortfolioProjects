Select * From CovidProject.coviddeaths;

-- Looking at the Total Cases VS Total Deaths
-- Show the Likelihood of death if got covid
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidProject.coviddeaths
Where location like '%state%'
order by 1;


-- Looking at the Total Case VS Population
-- Show % of population got Covid
Select location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected 
from CovidProject.coviddeaths
Where location like '%state%'
order by 1;

-- Looking at Countries with Highest Infection Rate Compare to population 
Select location,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
from CovidProject.coviddeaths
group by Location, Population
order by PercentagePopulationInfected desc;


-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(Total_deaths as SIGNED)) as TotalDeathCount -- issue with Total_death as TEXT type
from CovidProject.coviddeaths
WHERE continent != ''-- stop showing the World, Europe, North America etc.. 
group by Location
order by TotalDeathCount desc;

-- Break things down by Continent - Correct Number
SELECT location, MAX(cast(Total_deaths as SIGNED)) as TotalDeathCount -- issue with Total_death as TEXT type
from CovidProject.coviddeaths
WHERE continent = '' --  showing the World, Europe, North America etc.. 
group by location
order by TotalDeathCount desc; -- the number won't look exact. 

-- Break things down by Continent  - does not show the correct number 
SELECT continent, MAX(cast(Total_deaths as SIGNED)) as TotalDeathCount -- issue with Total_death as TEXT type
from CovidProject.coviddeaths
WHERE continent != ''-- stop showing the World, Europe, North America etc.. 
group by continent
order by TotalDeathCount desc; -- the number won't look exact. 

-- Global Number
Select date, SUM(new_cases), SUM(new_deaths), SUM(new_deaths)/SUM(new_cases) *100 as DeathPercentage
from CovidProject.coviddeaths
where continent != ''
Group by date
order by 1;


-- Join Covid Death & Vacinnation Table 
-- Looking at Total Population VS vaccinations 

SET SQL_SAFE_UPDATES = 0;
UPDATE CovidProject.coviddeaths
SET date = STR_TO_DATE(date, '%d/%m/%y') 
WHERE date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{2}$';

UPDATE CovidProject.covidvaccinations
SET date = STR_TO_DATE(date, '%d/%m/%y') 
WHERE date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{2}$';

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) over (Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated  
from CovidProject.coviddeaths dea  -- create alias 'dea'
Join CovidProject.covidvaccinations vac -- create alias 'vac'
	On dea.location = vac.location
    And dea.date = vac.date
where dea.continent != ''
Order by 2,3;

-- USE CTE common table expression
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) over (Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated  
from CovidProject.coviddeaths dea  -- create alias 'dea'
Join CovidProject.covidvaccinations vac -- create alias 'vac'
	On dea.location = vac.location
    And dea.date = vac.date
where dea.continent != ''
)
Select *, (RollingPeopleVaccinated/Population)* 100
From PopvsVac;

-- Creating View to Store data for later visualisation 
USE CovidProject; 
CREATE VIEW `PercentPopulationVaccinated` AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) over (Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated  
from CovidProject.coviddeaths dea  -- create alias 'dea'
Join CovidProject.covidvaccinations vac -- create alias 'vac'
	On dea.location = vac.location
    And dea.date = vac.date
where dea.continent != '';

Select * From percentpopulationvaccinated;