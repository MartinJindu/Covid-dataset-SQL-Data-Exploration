Select *
From PortfolioProject..CovidDeath
Where continent is not null
Order By 3,4;

Select *
From PortfolioProject..CovidVaccinations
Order By 3,4;

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeath
Order By 1,2;


-- Looking at total cases vs Total Death
-- Show likelihood of dying if you contact covid in your country
Select location, date, total_cases, total_deaths, (Convert(decimal(18,2), total_deaths) / Convert(decimal(12,2), total_cases))*100 As DeathRatePercentage
From CovidDeath
Where location like '%Nigeria'
Order By 1,2;

-- Looking at total cases vs polpulation
-- Show waht percentage of population that has got covid

Select location, date, population, total_cases, (Convert(decimal(18,2), total_cases) / Convert(decimal(12,2), population))*100 As PopulationInfectedPercentage
From CovidDeath
Where location like '%Nigeria'
Order By 1,2;

Select location, date, population, total_cases, (Convert(decimal(18,2), total_cases) / Convert(decimal(12,2), population))*100 As PopulationInfectedPercentage
From CovidDeath
Order By 1,2;

--Country with highest infection rate compared to polpulation

Select location, population, Max(total_cases) as HighestInfectionCount, Max((Convert(decimal(18,2), total_cases) / Convert(decimal(12,2), population)))*100 As PopulationInfectedPercentage
From CovidDeath
Group By location, population
Order By PopulationInfectedPercentage desc;

-- Showing Countries with the highest Death count per population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeath
Where continent is not null
Group By location
Order By TotalDeathCount desc;

-- BREAK THINGS BY CONTINENT

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeath
Where continent is null
and location not in ('High income','Upper middle income', 'Lower middle income', 'Low income')
Group By location
Order By TotalDeathCount desc;
--
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeath
Where continent is not null
Group By continent
Order By TotalDeathCount desc;

-- Continent with highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeath
Where continent is not null
Group By continent
Order By TotalDeathCount desc;

--Global Numbers

Select date, Sum(new_cases) As TotalNew_Cases, sum(new_deaths) as TotalNew_Death
, nullif(Sum(Convert(decimal(12,2), new_deaths)),0) / Sum(convert(decimal(12,2), new_cases))*100 As DeathRatePercentage 
From CovidDeath
Where continent is not null
Group By date
Order By 1,2;

Select Sum(new_cases) As TotalNew_Cases, sum(new_deaths) as TotalNew_Death
, nullif(Sum(Convert(decimal(12,2), new_deaths)),0) / Sum(convert(decimal(12,2), new_cases))*100 As DeathRatePercentage 
From CovidDeath
Where continent is not null
Order By 1,2;

--Looking at total Population vs Vacination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidDeath dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2, 3;
---

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(decimal(12,2), vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location
, dea.date) As RollingPeopleVaccinated
from CovidDeath dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2, 3;

--Using CTE To find Population Vs Vaccinated

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(decimal(12,2), vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location
, dea.date) As RollingPeopleVaccinated
from CovidDeath dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 As PopulationPercentageVaccinated
From PopvsVac;


---Using Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(decimal(12,2), vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location
, dea.date) As RollingPeopleVaccinated
from CovidDeath dea Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date;


Select *, (RollingPeopleVaccinated/Population)*100 As PopulationPercentageVaccinated
From #PercentPopulationVaccinated
Order By PopulationPercentageVaccinated;


-- Creating Views

Create View PercentPopulationVaccinated As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(decimal(12,2), vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location
, dea.date) As RollingPeopleVaccinated
from CovidDeath dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null;


Select *
From PercentPopulationVaccinated;