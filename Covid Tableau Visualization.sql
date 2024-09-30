select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage
from Portfolio..coviddeaths
where continent is not null
order by 1, 2  

select location, sum(cast(new_deaths as int)) as Total_death_count
from Portfolio..coviddeaths
where continent is null
and location not in ('World', 'European Union', 'Ínternational')
group by location
order by Total_death_count desc

select location, population, max(total_cases) as Highest_infection_count, max((total_cases/population))*100 as Percent_population_infected
from Portfolio..coviddeaths
group by location, population
order by Percent_population_infected desc


select location, population, date, max(total_cases) as Highest_infection_count, max((total_cases/population))*100 as Percent_population_infected
from Portfolio..coviddeaths
group by location, population, date
order by Percent_population_infected desc


