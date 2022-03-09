Select Location, date, total_cases, new_cases, Total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at total Cases vs Total Deaths
-- Shows what percentage of of cases resulted in death

Select Location, date, total_cases,Total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population was infected by covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentOfInfefction
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2

-- looking at countries with the highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentOfInfection
FROM PortfolioProject..CovidDeaths
Group by location, population
order by PercentOfInfection desc

-- Showing countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Death count by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Gloabal Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group By date
Order By 1,2


-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(Convert(bigint,vax.new_vaccinations)) OVER (Partition by dea.location Order by
dea.date) as PeopleVaccinated
--,(PeopleVaccinated)/population*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVax vax
On dea.location = vax.location and dea.date = vax.date
Where dea.continent is not null
Order by 2,3


-- CTE

With PopvsVax (continent, location, date, population, new_vaccinations, PeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(Convert(bigint,vax.new_vaccinations)) OVER (Partition by dea.location Order by
dea.date) as PeopleVaccinated
--,(PeopleVaccinated)/population*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVax vax
On dea.location = vax.location and dea.date = vax.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (PeopleVaccinated/population)*100
From PopvsVax


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(Convert(bigint,vax.new_vaccinations)) OVER (Partition by dea.location Order by
dea.date) as PeopleVaccinated
--,(PeopleVaccinated)/population*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVax vax
On dea.location = vax.location and dea.date = vax.date
Where dea.continent is not null
--Order by 2,3

Select *, (PeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(Convert(bigint,vax.new_vaccinations)) OVER (Partition by dea.location Order by
dea.date) as PeopleVaccinated
--,(PeopleVaccinated)/population*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVax vax
On dea.location = vax.location and dea.date = vax.date
Where dea.continent is not null
--Order by 2,3


Create View InfectionRatePop as
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentOfInfection
FROM PortfolioProject..CovidDeaths
Group by location, population
--order by PercentOfInfection desc

Create View DeathByContinent as
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
--order by TotalDeathCount desc