
-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths$
where location like '%states%' and continent is not null
order by 1,2

--looking at Total Cases vs population
--Shows what percentage of population got COVID
Select location,date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
where location like '%states%' and continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population
Select location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
where continent is not null
group by Location, Population
order by PercentPopulationInfected Desc


--Shows countries with Highest Death Count per Population 
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
group by Location, Population
order by TotalDeathCount Desc

--Breaking down by continents
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount Desc

--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

--Looking at Total Population vs Vaccinations
-- USE CTE
With PopvsVax (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
select deaths.continent, deaths.location, deaths.date, deaths.population,vax.new_vaccinations,
SUM(CONVERT(int,vax.new_vaccinations)) OVER (partition by deaths.location order by deaths.location, deaths.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ deaths
join PortfolioProject..CovidVaccination$ vax
	On deaths.location = vax.location 
	and deaths.date = vax.date
where deaths.continent is not null
)
select*, (RollingPeopleVaccinated/population)*100
from PopvsVax

--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric, 
New_vaccination numeric, 
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select deaths.continent, deaths.location, deaths.date, deaths.population,vax.new_vaccinations,
SUM(CONVERT(int,vax.new_vaccinations)) OVER (partition by deaths.location order by deaths.location, deaths.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ deaths
join PortfolioProject..CovidVaccination$ vax
	On deaths.location = vax.location 
	and deaths.date = vax.date
where deaths.continent is not null

select*, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating view to store data for later visualization 
Create View PercentPopulationVaccinated as 
select deaths.continent, deaths.location, deaths.date, deaths.population,vax.new_vaccinations,
SUM(CONVERT(int,vax.new_vaccinations)) OVER (partition by deaths.location order by deaths.location, deaths.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ deaths
join PortfolioProject..CovidVaccination$ vax
	On deaths.location = vax.location 
	and deaths.date = vax.date
where deaths.continent is not null

select * 
from PercentPopulationVaccinated