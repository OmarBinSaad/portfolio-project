show databases;
-- show the data
select *
from portfolioproject.coviddeaths;

-- select the data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject.coviddeaths
order by 1,2;

-- looking at Total Cases vs total Deaths
select location, date, total_cases, new_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
from portfolioproject.coviddeaths
order by 1,2 DESC;


select location, date, total_cases, new_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
from portfolioproject.coviddeaths
where location like 'Algeria'
order by 1,2 DESC;

-- looking at Total Cases vs Population
-- show what percentage of population got Covid
select location, date, total_cases, new_cases, total_deaths, population,(total_cases / population) * 100  as PercentagePopulationInfection
from portfolioproject.coviddeaths
-- where location like 'Algeria'
order by PercentagePopulationInfection DESC;


-- look at countries with highest infection rate compared to population
select location, MAX(total_cases ),  MAX(total_deaths), population,MAX((total_cases / population)) * 100  as PercentagePopulationInfection
from portfolioproject.coviddeaths
-- where location like 'Algeria'
where location is not null
group by location, population
order by PercentagePopulationInfection DESC;


-- showing countries with highest death count per population
-- here there is ittle issue, the number is text so I am going to convert it as float
select location, max(cast(total_deaths as float)) as TotalDeath
from portfolioproject.coviddeaths
where location is not null
group by location
order by TotalDeath DESC;


-- let's break things down by continent
select continent,  MAX(total_cases) as TotalCases, max(cast(total_deaths as double)) AS TotalDeaths
from coviddeaths
where continent is not null
group by continent
order by TotalDeaths DESC; 

-- Global Numbers
select date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
from coviddeaths
where total_cases is not null
order by total_cases DESC;

-- The total new cases in the word ordered by date
select sum(new_cases) as NewCases, sum(cast(new_deaths as float)) as TotalDeath, (sum(new_deaths) / sum(cast( new_cases as float))) *100 as MortalityRate
from coviddeaths
where new_cases is not null
-- group by date
order by date asc;


-- Looking at total population vs vaccinations
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as float)) over (partition by death.location order by death.location, death.Date) as RollingPepoleVaccinated,
 -- ('RollingPepoleVaccinated' / population ) * 100 as PercentVaccination
from coviddeaths as death
join covidvacinations as vac
	on death.location = vac.location
    and death.date = vac.date
where death.continent is not null
order by 2,3;




with PopVsVac as(
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as float)) over (partition by death.location order by death.location, death.Date) as RollingPepoleVaccinated
from coviddeaths as death
join covidvacinations as vac
	on death.location = vac.location
    and death.date = vac.date
where death.continent is not null
-- order by 2,3
)
select * , ( RollingPepoleVaccinated / population ) * 100 as PercentVaccination
from PopVsVac;


-- Temp table 
drop table if exists PercentPopulationVaccinated;
create table PercentPopulationVaccinated(
continent char(255),
location char(255),
date char(255),
population numeric,
new_vaccinations char(255),
RollingPepoleVaccinated numeric
);
Insert into PercentPopulationVaccinated 
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as float)) over (partition by death.location order by death.location, death.Date) as RollingPepoleVaccinated
 -- ('RollingPepoleVaccinated' / population ) * 100 as PercentVaccination
from coviddeaths as death
join covidvacinations as vac
	on death.location = vac.location
    and death.date = vac.date
-- where death.continent is not null
order by 2,3;
select *, ('RollingPepoleVaccinated' / population ) * 100 as PercentVaccination
from PercentPopulationVaccinated; 


-- creating view to store data for later Viz
create view PercentPopulationVaccinatedView as
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as float)) over (partition by death.location order by death.location, death.Date) as RollingPepoleVaccinated
 -- ('RollingPepoleVaccinated' / population ) * 100 as PercentVaccination
from coviddeaths as death
join covidvacinations as vac
	on death.location = vac.location
    and death.date = vac.date
 where death.continent is not null;
-- order by 2,3;

select *
from PercentPopulationVaccinatedView;



