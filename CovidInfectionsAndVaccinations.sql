-- Extracting data from international Covid infection and vacinations database.
------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------CASES, global and local------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------






Select* 

From PortfolioProject..CovidDeaths
order by 3,4

-- Number of total cases ordered by location then date
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Number of total cases, total deaths and perecentage of those cases resulting in deaths in UK,  ordered by location then date,
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%kingdom%'
order by 1,2

-- Number of total cases, total deaths and proportion of population infected in the USA as a percentage ,  ordered by location then date,
Select Location, date, total_cases, total_deaths,population, (total_cases/population)* 100 as PercentOfPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- maximum infection count, max percent of population infected ,  grouped by location then population, in descending order
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))* 100 as MaxPercentOfPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, population
order by MaxPercentOfPopulationInfected desc

-- maximum infection count, max percent of population infected ,  grouped by location then population and date, in descending order
Select Location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))* 100 as MaxPercentOfPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, population, date
order by MaxPercentOfPopulationInfected desc


-- Maximum death count, max percent of populationdeath ,  grouped by location then population and date, in descending order
Select Location, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((total_deaths/population))* 100 as MaxPercentOfPopulationDeath
From PortfolioProject..CovidDeaths
where continent is not null
Group by Location, population
order by HighestDeathCount desc

-- Maximum death count, grouped by continen if continent value is not null.
Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by HighestDeathCount desc



-- Global Values- infection, infection percentage death percentage, percentage of new deaths that are new cases
-- data may not always be the correct type. In this case i have casted the data to an integer to ensure the sum function doesnt return an error.

Select date, sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2


-- here no grouping is required as total cases sums across the entire data set as does totalDeaths and Death percentage
-- a value in one selected column corresponds to a value the other selected columns
Select  sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
-- Group by date
order by 1,2


-- there has to be a 1 to 1 relationship beteen the selected columns, i.e value in 1 column corresponds to value in another.
-- the sum columns represents multiple values, in 1 cell, but Location represents 1 value in 1 cell, 
-- thefore you have to group values in Location.
Select Location, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths
From PortfolioProject..CovidDeaths
where continent is not null
group by Location



-- joining our table for deaths and vaccinations
-- total ppopulation vs vaccinations

Select cd.continent,cd.location,cd.date, cd.population, cv.new_vaccinations
From PortfolioProject..CovidDeaths  cd
join PortfolioProject..CovidVacinations  cv
-- when you join you have to specify which columns you would like to join on- these columns are common to both tables
	on cd.location = cv.location
	and	cd.date = cv.date
where cd.continent is not null
order by 1,2,3


Select cd.continent,cd.location,cd.date, cd.population, cd.new_deaths, cv.new_vaccinations
From PortfolioProject..CovidDeaths  cd
join PortfolioProject..CovidVacinations  cv
-- when you join you have to specify which columns you would like to join on- these columns are common to both tables
	on cd.location = cv.location
	and	cd.date = cv.date
where cd.continent is not null AND cd.location like '%kingdom%'  AND cd.date > '2021-01-10 00:00:00:000'
order by date

-- rolling sum of people vaccinated

-- sum (y): outputs 1 value to represent the sum of many value inputs
-- sum(y) over ( Partition x): 'OVER' specifies that that this function will run for each row in 'y'
--   'PARTITION ' specifies that for each row in that partition x, the function will use all rows in the partion x
-- as input to the function.
-- sum(y) over ( Partition x order by z): for each row in partition x the function will execute in the order of z such that
-- by default -  the inputs to the function will be the current row value of y and the previous.






Select cd.continent,cd.Location,cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(BIGINT,cv.new_vaccinations)) OVER (Partition by cd.Location order by cd.date ) as RollingSum
From PortfolioProject..CovidDeaths  cd
join PortfolioProject..CovidVacinations  cv
-- when you join you have to specify which columns you would like to join on- these columns are common to both tables
	on cd.location = cv.location
	and	cd.date = cv.date
where cd.continent is not null
order by 2,3

-- USE CTE- Common table expression to use a column that is created later in the same query ( RollingSum)

with PopVsVacCTE(Continent,Location,Date,Population,new_vaccinations,RollingSum)
as 
(
Select cd.continent,cd.Location,cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(BIGINT,cv.new_vaccinations)) OVER (Partition by cd.Location order by cd.date ) as RollingSum
From PortfolioProject..CovidDeaths  cd
join PortfolioProject..CovidVacinations  cv
-- when you join you have to specify which columns you would like to join on- these columns are common to both tables
	on cd.location = cv.location
	and	cd.date = cv.date
where cd.continent is not null
-- order by 2,3
)

Select *, (RollingSum/population)*100 as RollingPercentage
From PopVsVacCTE

-- Using Temp table to use a column that is created later in the same query (RollingSum)

-- Create Temp Table use # to indicate temporary table

Drop Table if exists #percentPopVaccinated
Create Table #percentPopVaccinated (

Continent VARCHAR(255),
Location VARCHAR(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingSum numeric)

Insert into #percentPopVaccinated
Select cd.continent,cd.Location,cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(BIGINT,cv.new_vaccinations)) OVER (Partition by cd.Location order by cd.date ) as RollingSum
From PortfolioProject..CovidDeaths  cd
join PortfolioProject..CovidVacinations  cv
-- when you join you have to specify which columns you would like to join on- these columns are common to both tables
	on cd.location = cv.location
	and	cd.date = cv.date
where cd.continent is not null
-- order by 2,3

Select *, (RollingSum/population)*100 
From #percentPopVaccinated


-- Creating view to store data for data visualisation

Drop View if exists PercentPopVacc

CREATE VIEW PercentPopVacc AS 

Select cd.continent,cd.Location,cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(BIGINT,cv.new_vaccinations)) OVER (Partition by cd.Location order by cd.date ) as RollingSum
From PortfolioProject..CovidDeaths  cd
join PortfolioProject..CovidVacinations  cv
-- when you join you have to specify which columns you would like to join on- these columns are common to both tables
	on cd.location = cv.location
	and	cd.date = cv.date
where cd.continent is not null
-- order by 2,3


USE PortfolioProject

SELECT * FROM PercentPopVacc