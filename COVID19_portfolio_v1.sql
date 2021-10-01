Select *
From PortfolioProject..CovidDeaths
Where continent is not NULL
order by location,date

--Select *
--From PortfolioProject..CovidVaccination
--order by location,date

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not NULL
order by location, date

--Total cases vs Total deaths
--Percentage of dying if you got affected by Covid in Vietnam
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'Vietnam' --or location like %vViet%
and continent is not NULL
order by location, date

--Total cases vs Population
Select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Viet%'
Where continent is not NULL
order by location, date

--Looking at Countries with highest infection rate compare to population
Select location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Viet%'
Where continent is not NULL
Group by location, population
order by PercentPopulationInfected desc

--Looing at Countries with highest death rate compare to population
Select location, MAX(cast(total_deaths as int)) as TotalDeath 
From PortfolioProject..CovidDeaths
--Where location like '%Viet%'
Where continent is not NULL
Group by location
order by TotalDeath desc

--Time to order by continents
Select location, MAX(cast(total_deaths as int)) as TotalDeath 
From PortfolioProject..CovidDeaths
--Where location like '%Viet%'
Where continent is NULL
Group by location
order by TotalDeath desc

--Showing the continent with highest death count per population
Select location, population, MAX(cast(total_deaths as int)) as TotalDeath, MAX((total_deaths/ population))*100 as ConDeathPer
From PortfolioProject..CovidDeaths
--Where location like '%Viet%'
Where continent is NULL and population is not NULL --get ride of location 'international' with null population 
Group by location, population
order by ConDeathPer desc

--GLOBAL NUMBERS
Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Viet%'
Where continent is not NULL   
Group by date
order by 1,2 


--Looking at total population vs vaccinations
Select D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(cast(V.new_vaccinations as int)) Over (Partition by D.location order by D.location, D.date) As VaccinatedPeople --Use Over(Partition to add up values from column)
--, (VacinaedPeople/population)*100
From PortfolioProject..CovidDeaths D
Join PortfolioProject..CovidVaccination V
	On D.location = V.location
	and D.date = V.date
Where D.continent is not NULL
Order by 2,3


--Create a Temp Table
Drop table if exists #PercentPopulationVacinnated
Create table #PercentPopulationVacinnated(
		Continent nvarchar(255),
		Location nvarchar(255),
		Date datetime,
		Population numeric,
		New_vaccination numeric,
		VaccinatedPeople numeric
)

Insert into #PercentPopulationVacinnated
Select D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(cast(V.new_vaccinations as bigint)) Over (Partition by D.location order by D.location, D.date) As VaccinatedPeople --Use Over(Partition to add up values from column)
--, (VacinaedPeople/population)*100
From PortfolioProject..CovidDeaths D
Join PortfolioProject..CovidVaccination V
	On D.location = V.location
	and D.date = V.date
--Where D.continent is not NULL
--Order by 2,3

Select *, (VaccinatedPeople/population)*100 
from #PercentPopulationVacinnated

--Create View to store data
Create View PercentPopulationVacinnated as
Select D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(cast(V.new_vaccinations as bigint)) Over (Partition by D.location order by D.location, D.date) As VaccinatedPeople --Use Over(Partition to add up values from column)
--, (VacinaedPeople/population)*100
From PortfolioProject..CovidDeaths D
Join PortfolioProject..CovidVaccination V
	On D.location = V.location
	and D.date = V.date
Where D.continent is not NULL
--Order by 2,3

Select * 
from PercentPopulationVacinnated