Select *
From PortfolioProject..CovidDeath$
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--Order by 3,4

--  Selecting the data to be used

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeath$
Where continent is not Null
Order by 1,2

-- Consider the total number of disease cases versus the number of deaths 
-- The likelihood of Covid 19 infection is pretty high

Select location, date, total_cases, total_deaths,
(cast(total_deaths as float)/cast(total_cases as float))*100 as DeathsPercentage
From PortfolioProject..CovidDeath$
Where continent is not Null
and location like '%russia%'
Order by 1,2

-- Consider the total number of cases of illnesses compared to the population
-- Percentage of population infected with covid

Select location, date, population, total_cases,
(cast(total_cases as float)/population)*100 as PercentageInfection
From PortfolioProject..CovidDeath$
--Where location like '%russia%'
Order by 1,2

-- Let's look at the countries with the highest infection rates

Select location, population, MAX(cast(total_cases as int)) as HightInfectionCount,
(Max(cast(total_cases as int))/population)*100 as PercentageInfection
From PortfolioProject..CovidDeath$
--Where location like '%russia%'
Group by location, population
Order by PercentageInfection desc

-- Countries with the highest mortality rate

Select location, MAX(cast(total_deaths as int)) as TotalDeaths
From PortfolioProject..CovidDeath$
Where continent is not Null
Group by location
Order by TotalDeaths desc

-- Continents with the highest mortality rates

Select continent, MAX(cast(total_deaths as int)) as TotalDeaths
From PortfolioProject..CovidDeath$
Where continent is not Null
Group by continent
Order by TotalDeaths desc

-- Global values of mortality

Select Sum(new_cases) as total_cases, Sum(new_deaths) as total_deaths, 
(Sum(new_deaths)/Sum(new_cases))*100 as DeathsPercentage
From PortfolioProject..CovidDeath$
Where continent is not Null
--and location like '%russia%'
--Group by date
Order by 1,2

-- Let's look at the total population versus vaccination

Select dea.continent, dea.location, dea.date, dea.population,
cast(vac.new_vaccinations as float) as new_vaccination,
 Sum(convert(float, vac.new_vaccinations)) OVER (partition by dea.location
 Order by dea.location, dea.date) as RollingPeopleVaccinated
 -- (RollingPeopleVaccinated/dea.population)*100 - Нельзя использоват созданный столбец
From PortfolioProject..CovidDeath$ as dea
Join PortfolioProject..CovidVaccinations$ as vac
	ON dea.location= vac.location
	and dea.date = vac.date
Where dea.continent is not Null
Order by 2,3

-- Let's do it through the CTE

With PercentageVaccinated (continent, location, date, population, new_vaccinations
, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population,
cast(vac.new_vaccinations as float) as new_vaccination,
 Sum(convert(float, vac.new_vaccinations)) OVER (partition by dea.location
 Order by dea.location, dea.date) as RollingPeopleVaccinated
 -- (RollingPeopleVaccinated/dea.population)*100 - Нельзя использоват созданный столбец
From PortfolioProject..CovidDeath$ as dea
Join PortfolioProject..CovidVaccinations$ as vac
	ON dea.location= vac.location
	and dea.date = vac.date
Where dea.continent is not Null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PercentageVaccinated
Order By 2,3

-- Let's do it through a temporary table

Drop table if exists #PercentageVaccinated
Create table #PercentageVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentageVaccinated
Select dea.continent, dea.location, dea.date, dea.population,
cast(vac.new_vaccinations as float) as new_vaccination,
 Sum(convert(float, vac.new_vaccinations)) OVER (partition by dea.location
 Order by dea.location, dea.date) as RollingPeopleVaccinated
 -- (RollingPeopleVaccinated/dea.population)*100 - Нельзя использоват созданный столбец
From PortfolioProject..CovidDeath$ as dea
Join PortfolioProject..CovidVaccinations$ as vac
	ON dea.location= vac.location
	and dea.date = vac.date
Where dea.continent is not Null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
From #PercentageVaccinated
Order By 2,3

--Let's create a view to store data for visualization

Create View PercentageVaccinated as

Select dea.continent, dea.location, dea.date, dea.population,
cast(vac.new_vaccinations as float) as new_vaccination,
 Sum(convert(float, vac.new_vaccinations)) OVER (partition by dea.location
 Order by dea.location, dea.date) as RollingPeopleVaccinated
 -- (RollingPeopleVaccinated/dea.population)*100 - Нельзя использоват созданный столбец
From PortfolioProject..CovidDeath$ as dea
Join PortfolioProject..CovidVaccinations$ as vac
	ON dea.location= vac.location
	and dea.date = vac.date
Where dea.continent is not Null
--Order by 2,3

Select *
From PercentageVaccinated