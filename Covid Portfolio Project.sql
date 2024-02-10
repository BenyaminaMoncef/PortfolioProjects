SELECT * 
FROM [Portfolio project]..CovidDeaths
ORDER BY 3,4

--SELECT * 
--FROM [Portfolio project]..CovidVaccinations
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio project]..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths 
--shows likelihood of dying if you contract covid in your country 
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio project]..CovidDeaths
Where location like '%France%'
order by 1,2

--lookinf at the total cases vs population 
--Shows percentage of population got covid 
Select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
From [Portfolio project]..CovidDeaths
where location like '%France%'
Order by 1,2

--Looking at countries with highest infection rate compared to population

Select location, Max(total_cases) as HighestInfectionCount, population, Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio project]..CovidDeaths
--where location like '%France%'
Group by Location, Population 
order by PercentPopulationInfected desc

--Showing countries with highest death count per population 

Select location, Max(cast(total_deaths as int)) as TotalDeathCount, population, Max((total_deaths/population))*100 as PercentPopulationDead
From [Portfolio project]..CovidDeaths
--where location like '%France%'
where continent is not null
Group by Location, Population 
order by TotalDeathCount desc

--Break down things by continent 


--Showing continents with the highest DeathCount 

Select Continent, Max(cast(total_deaths as int)) as TotalDeathCount, Max((total_deaths/population))*100 as PercentPopulationDead
From [Portfolio project]..CovidDeaths
--where location like '%France%'
where continent is not null
Group by Continent
order by TotalDeathCount desc

--global numbers


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int )) as total_deaths , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio project]..CovidDeaths
--Where location like '%France%'
where continent is not null
--Group by date
order by 1,2

--Looking at total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int , vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated ,
(RollingPeopleVaccinated/population)*100
From [Portfolio project]..CovidDeaths dea
 Join [Portfolio project]..CovidVaccinations vac
      On dea.location = vac.location 
	  and dea.date = vac.date
	  where dea.continent is not null 
	  Order by 2,3

-- we have an error se we use the CTE method
-- Use CTE

with PopVsVac ( Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated ) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int , vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
From [Portfolio project]..CovidDeaths dea
 Join [Portfolio project]..CovidVaccinations vac
      On dea.location = vac.location 
	  and dea.date = vac.date
	  where dea.continent is not null 
	 -- Order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
From PopVsVac


-- TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int , vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
From [Portfolio project]..CovidDeaths dea
 Join [Portfolio project]..CovidVaccinations vac
      On dea.location = vac.location 
	  and dea.date = vac.date
	 --where dea.continent is not null 
	 -- Order by 2,3

select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations 

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int , vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
From [Portfolio project]..CovidDeaths dea
 Join [Portfolio project]..CovidVaccinations vac
      On dea.location = vac.location 
	  and dea.date = vac.date
	 where dea.continent is not null 
	 --Order by 2,3

DROP View PercentPopulationVaccinated

select * 
from PercentPopulationVaccinated