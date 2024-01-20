select * 
from PortfolioProject..CVDeaths
where continent is not null
order by 3,4
--select * 
--from PortfolioProject.dbo.CovidVaccinations$
--order by 3,4
--select data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

--Looking at total cases vs Total Deaths
--shows the likelihood of dying if you contratc covid in your country

select location, date, total_cases, total_deaths, (convert(float,total_deaths)/Nullif(convert(float,total_cases),0))*100 as Per_ofDeaths
from PortfolioProject.dbo.CVDeaths
where location= 'United States'
order by 1,2
select distinct location 
from PortfolioProject.dbo.cvvaccinations
order by location

--looking at total cases Vs Population
select location, date,  population, total_cases, (convert(float,total_cases)/Nullif(convert(float,population),0))*100 as Per_ofDeaths
from PortfolioProject.dbo.CVDeaths
--where location= 'United States'
order by 1,2

--looking at countries with highest infection rate compaer to population
select location,  population, Max(total_cases) as Highest_infectouscount, Max((convert(float,total_cases)/Nullif(convert(float,population),0)))*100 as Per_ofPopulationInfected
from PortfolioProject.dbo.CVDeaths
--where location= 'United States'
group by location,population
order by Per_ofPopulationInfected desc 

--showing the countires highest death counts per population 
select location, Max(cast(total_deaths as int)) as death_count
from PortfolioProject.dbo.CVDeaths
where continent is not null
--where location= 'United States'
group by location
order by death_count desc

--Lets break things down by continent

select Continent, Max(cast(total_deaths as int)) as death_count
from PortfolioProject.dbo.CVDeaths
where continent is not null
--where location= 'United States'
group by Continent
order by death_count desc

--showing the continent with the highest death count per population
select Continent, Max(cast(total_deaths as int)) as death_count
from PortfolioProject.dbo.CVDeaths
where continent is not null
--where location= 'United States'
group by Continent
order by death_count desc

--global Numbers
select sum(new_cases) as totalNe_cases, sum(cast(new_deaths as int)) as Totalnew_deaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage--total_cases, total_deaths, (convert(float,total_cases)/Nullif(convert(float,population),0))*100 as Per_ofDeaths
from PortfolioProject.dbo.CVDeaths
where continent is not null
--where location= 'United States'
--group by date
order by 1,2

--Looking ata total population vs vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CVDeaths dea
Join PortfolioProject.dbo.CVVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

---CTE
with PopvsVac (Continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CVDeaths dea
Join PortfolioProject.dbo.CVVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--Temp Table 
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CVDeaths dea
Join PortfolioProject.dbo.CVVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visualizations

create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CVDeaths dea
Join PortfolioProject.dbo.CVVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select * 
from PercentPopulationVaccinated