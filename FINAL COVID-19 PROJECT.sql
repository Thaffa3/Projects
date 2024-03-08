--Select *
--From Covid_19_Project..CovidDeaths
--Order by 3,4

--Select *
--From Covid_19_Project..CovidVaccinations
--Order by 3,4

-- Selecting The Relevant Data 

Select Location, date, total_cases, new_cases, total_deaths, population 
From Covid_19_Project..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Deaths VS Total Cases
-- Shows the Likelihood of Dying if you Contact Covid In your Country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From Covid_19_Project..CovidDeaths
Where Location like '%states%'
and continent is not null
Order by 1,2

-- Looking at Total Cases vs Population.
-- Shows What Percentage of Population got Covid

Select Location, date, population, total_cases, (total_cases/population) * 100 as DeathPercentage
From Covid_19_Project..CovidDeaths
--Where Location like '%states%'
Order by 1,2

--Looking at Countries with Hihest Infection rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases /population))*100 as PercentPopulationInfected
From Covid_19_Project..CovidDeaths
Group by Location, population
Order by PercentPopulationInfected desc

-- Showing Counties With Highest Death Count Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Covid_19_Project..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc


-- Showing Continent with Highest Death count

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Covid_19_Project..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(New_deaths as int)) as total_deahs, 
SUM(cast(new_deaths as int)) / SUM(New_Cases)*100 as DeathPercentage
From Covid_19_Project..CovidDeaths
where continent is not null
Order by 1,2

-- JOINING TABLES

Select *
From Covid_19_Project..CovidDeaths dea
Join Covid_19_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population VS Vaccinations
-- Using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From Covid_19_Project..CovidDeaths dea
Join Covid_19_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)* 100
From PopvsVac


-- CREATING A TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From Covid_19_Project..CovidDeaths dea
Join Covid_19_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/population)* 100
From #PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR VISUALIZATION

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From Covid_19_Project..CovidDeaths dea
Join Covid_19_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated