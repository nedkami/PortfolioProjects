select * from coviddeaths
where continent is not null 

select count(*) from covidvaccinations2
select location , `date` , total_cases , new_cases , total_deaths , population
from coviddeaths 
order by 1,2

-- Looking at the Total Cases vs Total Deaths
select location , `date` , total_cases , total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths 
order by 1,2

-- Looking at the Total Cases vs Population
select location , `date` , population , total_cases , (total_cases/population)*100 as 'Percentage of Total Cases' 
from coviddeaths 
order by 1,2

-- Looking only for USA the Percentage of Total Cases Vs population 
select location , `date` , population , total_cases , (total_cases/population)*100 as 'Percentage of Total Cases' 
from coviddeaths
where location like '%states%'
order by 1,2

-- Lookin at the Countries with highest infection rate compared to population
select location , population, date , Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as 'Percentage of Total Cases' 
from coviddeaths 
group by location , population , date
order by 'Percentage of Total Cases' desc 

-- Showing countries with highest death count per population

select location , Max(total_deaths) as TotalDeathCount 
from coviddeaths 
where continent is not null 
group by location 
order by TotalDeathCount desc

-- Breaking data by Continents 

select continent , Max(total_deaths) as TotalDeathCount 
from coviddeaths 
where continent is not null 
group by continent  
order by TotalDeathCount desc


-- Global numbers

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths , sum(new_deaths)/sum(new_cases) * 100 as DeathPercentage
from coviddeaths
where continent is not null 
order by 1,2

-- looking at total Population vs Vaccinations
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations , sum(vac.new_vaccinations) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

	from coviddeaths dea
join covidvaccinations2 vac
 on dea.location = vac.location 
 and dea.date = vac.date 
 where dea.continent is not null 
order by 2,3
 
 -- use CTE 
with PopVsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)    
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations)
 over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations2 vac
 on dea.location = vac.location 
 and dea.date = vac.date 
 where dea.continent is not null 
-- order by 2,3
)
select * , (RollingPeopleVaccinated/population)*100
from PopVsVac;

-- Temp Table

drop table if exists populationvaccinated;
CREATE TABLE populationvaccinated(
continent text,
location text,
dated date,
population bigint,
new_vaccinations int,
rollingpeoplevaccinated int
);

insert into populationvaccinated 
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations , sum(vac.new_vaccinations) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations2 vac
on dea.location = vac.location 
and dea.date = vac.date ;
-- where dea.continent is not null 
-- order by 2,3
select *,(RollingPeopleVaccinated/population)*100
from populationvaccinated

 
 -- creating view

create view populationvaccinated as
select dea.continent , dea.location , dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations2 vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null 

-- order by 2,3

