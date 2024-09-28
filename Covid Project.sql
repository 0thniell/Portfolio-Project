select * 
from Portfolio..coviddeaths
order by 3, 4

select *
from Portfolio..covidvaccinations
order by 3, 4  

--select data that we are going to be using
select Location, date, total_cases, new_cases, total_deaths, population
from Portfolio..coviddeaths
order by 1, 2

--looking at total casses vs total deaths

update Portfolio..coviddeaths set total_deaths=null where total_deaths=0
update Portfolio..coviddeaths set total_cases=null where total_cases=0

--shows the likelihood of dying if you contact covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from Portfolio..coviddeaths
where location like '%states%' 
order by 1, 2

--total cases vs population
select Location, date, population, total_cases, (total_cases/population)*100 as percentage_population_infected
from Portfolio..coviddeaths
--where location like '%states%' 
order by 1, 2

--looking at countries with highest infection rate compared to population
select Location, population, max(total_cases) as highest_infection_count, (max(total_cases)/population)*100 as percentage_population_infected
from Portfolio..coviddeaths
group by location, population
order by percentage_population_infected desc

--showing countries with highest death count per population
select Location, max(total_deaths) as total_death_count
from Portfolio..coviddeaths
--where location like '%nigeria%'
where continent is not null
group by location
order by total_death_count desc


--by continent

select continent, max(total_deaths) as total_death_count
from Portfolio..coviddeaths
--where location like '%nigeria%'
where continent is not null
group by continent
order by total_death_count desc


--global numbers

update Portfolio..coviddeaths set new_deaths=null where new_deaths=0
update Portfolio..coviddeaths set new_cases=null where new_cases=0

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as death_percentage
from Portfolio..coviddeaths
where continent is not null
--group by date
order by 1, 2

--looking at total population vs vaccinations

update Portfolio..covidvaccinations set new_vaccinations=0 where new_vaccinations=null

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from Portfolio..coviddeaths dea
join Portfolio..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--use CTE
with PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from Portfolio..coviddeaths dea
join Portfolio..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (rolling_people_vaccinated/population)*100
from PopvsVac


--temp table

drop table if exists #percentage_population_vaccinated
create table #percentage_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
insert into #percentage_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from Portfolio..coviddeaths dea
join Portfolio..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

select *, (rolling_people_vaccinated/population)*100
from #percentage_population_vaccinated


--create view
create view percentpopulationvaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from Portfolio..coviddeaths dea
join Portfolio..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select name
from sys.views
where name like '%percentpopulationvaccinated%'

select OBJECT_DEFINITION(object_id('Portfolio.percentpopulationvaccinated')) as ViewDefinition;

select *
from percentpopulationvaccinated