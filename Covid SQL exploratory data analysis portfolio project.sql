Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4 


--Looking at total cases vs total Deaths.
--Shows liklehood of dying if you contract Covid in your country


Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentrage
From PortfolioProject..CovidDeaths 
Where location like '%states%'
order by 1, 2




-- Looking at the total cases vs Population
--Shows what percentage of the population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as Percentpopulation
From PortfolioProject..CovidDeaths 
Where location like '%states%'
order by 1, 2

--looking at coutries with the highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as
Percentpopulationinfected
From PortfolioProject..CovidDeaths 
--Where location like '%states%'
Group by Location, Population
order by Percentpopulationinfected desc

--LETS BREAK THINGS DOWN BY CONTINENT


--showing countries with highest death count per population


Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like'%states%'
Where continent is not null
Group by location
order by TotalDeathcount desc


--Showing continents with the highest death count per population




--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast
(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths 
--Where location like '%states%'
where continent is not null 
--Group by date
order by 1, 2



--looking at total population vs vaccinations 



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeoplevaccinated/population)*100 
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date 
where dea.continent is not null 
order by 2, 3

--USE CTE


with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingpeopleVaccinated) 
as 
(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeoplevaccinated/population)*100 
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date 
where dea.continent is not null 
--order by 2, 3
)
Select *, (RollingpeopleVaccinated/Population)*100
From PopvsVac 


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.Date) as #RollingPeopleVaccinated
--, (RollingPeoplevaccinated/population)*100 
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date 
--where dea.continent is not null 
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated






--Creating a view ro store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeoplevaccinated/population)*100 
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date 
where dea.continent is not null 
--order by 2, 3
