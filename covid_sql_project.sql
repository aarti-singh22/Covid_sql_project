create database PortfolioProject;

use PortfolioProject;

select * from PortfolioProject..CovidDeaths where continent is not null order by 3,4

--select * from PortfolioProject..CovidVaccinations order by 3,4

select location,date, total_cases, new_cases, total_deaths, population from CovidDeaths order by 1,2

--looking at total cases vs total deaths countrywise
--shows likelyhood of dying if you contract covid in your country

select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage from CovidDeaths 
where location like 'india' order by 1,2

--total cases vs population
--shows percentage of population got covid

select location,date, total_cases, population, (total_cases/population)*100 as covid_percentage from CovidDeaths 
where location like 'india' order by 1,2

--Countries with highest infection rate as compared to population

select location,population, max(total_cases) as maximum_case, max((total_cases/population)*100) as maximum_CovidPercentage
from CovidDeaths group by location, population order by maximum_CovidPercentage desc

--countries with highest death count per population

select location, max(cast(total_deaths as int)) as death_count from CovidDeaths group by location order by death_count desc

--population continent wise

select continent, max(cast(total_deaths as int)) as death_count from CovidDeaths
where continent is not null group by continent order by death_count desc

select location, max(cast(total_deaths as int)) as death_count from CovidDeaths
where continent is null group by location order by death_count desc

--Counts worldwide

select date, sum(cast(new_deaths as int)) as total_deaths, sum(new_cases) as total_cases, sum(convert(int,new_deaths))/sum(new_cases)*100 as death_percent
from CovidDeaths where continent is not null group by date order by date desc

--Total Population vs Vaccination

select d.date, d.continent, d.location, d.population, v.new_vaccinations,sum(convert(bigint,v.new_vaccinations)) 
over(partition by d.location order by d.location, d.date) as PeopleVaccinated from CovidDeaths d join CovidVaccinations v 
on d.date = v.date and d.location = v.location where d.continent is not null and v.new_vaccinations is not null

--CTE

with popvsvacc(date,continent,location,population,new_vaccinations,PeopleVaccinated)
AS(
select d.date, d.continent, d.location, d.population, v.new_vaccinations,sum(convert(bigint,v.new_vaccinations)) 
over(partition by d.location order by d.location, d.date) as PeopleVaccinated from CovidDeaths d join CovidVaccinations v 
on d.date = v.date and d.location = v.location where d.continent is not null and v.new_vaccinations is not null
)
select *, (PeopleVaccinated/population)*100 as vaccination_percentage from popvsvacc


--temp table
create table #PeopleVaccinatednew
(date datetime, continent nvarchar(255), location nvarchar(255), population numeric, new_vaccinations numeric, PeopleVaccinated numeric)

insert into #PeopleVaccinatednew
select d.date, d.continent, d.location, d.population, v.new_vaccinations,sum(convert(bigint,v.new_vaccinations)) 
over(partition by d.location order by d.location, d.date) as PeopleVaccinated from CovidDeaths d join CovidVaccinations v 
on d.date = v.date and d.location = v.location where d.continent is not null and v.new_vaccinations is not null

select * from #PeopleVaccinatednew

--create view

create view PeopleVaccinatedview as 
select d.date, d.continent, d.location, d.population, v.new_vaccinations,sum(convert(bigint,v.new_vaccinations)) 
over(partition by d.location order by d.location, d.date) as PeopleVaccinated from CovidDeaths d join CovidVaccinations v 
on d.date = v.date and d.location = v.location where d.continent is not null and v.new_vaccinations is not null

select * from PeopleVaccinatedview
