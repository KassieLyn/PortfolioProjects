/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select *  
from PortfolioProject.dbo.CovidDeaths
where continent is not null


select location, date, total_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1, 2

-- Total Cases vs Total Deaths/ Death Percentage in the United States

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%United States%'
and continent is not null
order by 1, 2


-- Total Cases vs Population/ Percentage of population infected with Covid

Select location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
order by 1,2


-- Countries with Highest Death Count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- Contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- Total Population vs Vaccinations / Shows Percentage of Population that has been vaccinated

Select d.continent, d.location, d.date, d.population, v.new_vaccinations, (v.new_vaccinations/ d.population)*100 as PercentPopulationVaccinated
From PortfolioProject.dbo.CovidDeaths d
Join PortfolioProject.dbo.CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
order by 3,4



-- Using CTE to perform Calculation on Partition
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
	Select d.continent, d.location, d.date, d.population, v.new_vaccinations
	, SUM(CONVERT(float,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
	From PortfolioProject.dbo.CovidDeaths d
	Join PortfolioProject.dbo.CovidVaccinations v
		On d.location = v.location
		and d.date = v.date
	where d.continent is not null 

)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac



-- Using Temporary Table to perform Calculation on Partition By in previous query

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
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
	, SUM(CONVERT(float,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
	From PortfolioProject.dbo.CovidDeaths d
	Join PortfolioProject.dbo.CovidVaccinations v
		On d.location = v.location
		and d.date = v.date
	where d.continent is not null 

-- view temp table 
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Create View
Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
	, SUM(CONVERT(float,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
	From PortfolioProject.dbo.CovidDeaths d
	Join PortfolioProject.dbo.CovidVaccinations v
		On d.location = v.location
		and d.date = v.date
	where d.continent is not null 

-- view the PercentPopulationVaccinated view
select * from PercentPopulationVaccinated