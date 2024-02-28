USE PortfolioProject

Select * 
From CovidDeaths
where continent is not null
order by 3,4


Select * 
From CovidVaccinations
where continent is not null
order by 3,4

-- Select Data that we are going to be using 

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like 'United States'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows percentage of population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
Where location like 'United States'
and continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like 'United States'
group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population 

Select location, MAX(total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is not null
group by location, iso_code
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
Select location, MAX(total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is null
group by location
order by TotalDeathCount desc
	
-- Showing continents with the highest death count per population
Select continent, MAX(total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
Select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like 'World'
and new_cases <> 0
group by date, total_cases, total_deaths
order by 1


-- Looking at Total Population vs Vaccinations
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(v.new_vaccinations) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
From CovidDeaths d
Inner Join CovidVaccinations v 
	on d.location = v.location 
	and d.date = v.date
Where d.continent is not null
order by 2,3

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(v.new_vaccinations) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
From CovidDeaths d
Inner Join CovidVaccinations v 
	on d.location = v.location 
	and d.date = v.date
Where d.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac

-- TEMP Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(v.new_vaccinations) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
From CovidDeaths d
Inner Join CovidVaccinations v 
	on d.location = v.location 
	and d.date = v.date
Where d.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(v.new_vaccinations) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
From CovidDeaths d
Inner Join CovidVaccinations v 
	on d.location = v.location 
	and d.date = v.date
Where d.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated