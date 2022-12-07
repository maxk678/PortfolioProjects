USE PortfolioProject

Select * 
From CovidDeaths
where continent is not null
order by 3,4

-- Select Data that we are going to be using 

Select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths 
where continent is not null

-- Looking at Total Cases vs Total Deaths in the US

-- Shows likelihood of dying if you contract COVID-19 in the US 
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths 
where location like '%United States'
and continent is not null

-- Looking at Total Cases vs Population
-- Shows what percentage of population with COVID-19
Select location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
from CovidDeaths 
where location like 'United States'
and continent is not null

-- Looking at Countries with Highest Infection Rate compared to Population
Select location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as InfectionRate
from CovidDeaths 
where continent is not null
Group by location, population
order by InfectionRate desc


-- Showing Countries with Highest Death Count
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths 
where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENTS

-- Showing the continents with the highest death count
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount --This one is the correct one
from CovidDeaths 
where continent is null
Group by location
order by TotalDeathCount desc

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths 
where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS
	--Death Percentage Per Day
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths 
where continent is not null
group by date
order by date

	--Overall Death Percentage
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths 
where continent is not null



-- Looking at Total Population vs Vaccinations

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int, cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths cd
JOIN CovidVaccinations cv 
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by cd.location, cd.date

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int, cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths cd
JOIN CovidVaccinations cv 
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by cd.location, cd.date
)

Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac

-- TEMP TABLE

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
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int, cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths cd
JOIN CovidVaccinations cv 
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by cd.location, cd.date

Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int, cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths cd
JOIN CovidVaccinations cv 
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by cd.location, cd.date

Select * 
From PercentPopulationVaccinated