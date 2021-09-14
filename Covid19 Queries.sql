USE Covid19Project

 
select location,date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
where continent is not null
order by 1,2

--Total Cases vs Total Deaths 
select location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where continent is not null
order by 1,2

--Total Cases vs Total Deaths in India 
select location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where location = 'India' and continent is not null
order by 1,2

--Total Cases vs Population 
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths$
where continent is not null
order by 1,2

--Countries with highest infection rate with respect to popualtion
select location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
from CovidDeaths$
where continent is not null
group by location,population
order by PercentPopulationInfected desc

--Countries with highest death count
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

--Countries with highest death count compared to population
select location,population, MAX(((cast(total_deaths as int))/population)*100) as TotalDeathPercentage
from CovidDeaths$
where continent is not null
group by location,population
order by TotalDeathPercentage desc

--Continent Wise analysis
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--Global data
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths$
where continent is not null 
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- Finding percentage of people vaccianted with CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location and dea.date=vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
from PopvsVac