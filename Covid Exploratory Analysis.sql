-- Original data was sourced from https://ourworldindata.org/covid-deaths
-- Dataset can be downloaded from : https://covid.ourworldindata.org/data/owid-covid-data.csv
-- Data was further divided into two smaller datasets : Coviddeaths and Vaccine

-- Both of the datasets was uploaded as tables in database without any transformations

--Getting the first look on our data.
Select location,date_d, total_cases, new_cases, total_deaths, population
from coviddeaths order by 1,2;


-- Clause 'continent is not null' was added to all queries to remove redundant data from calculations and get accurate statistics
-- Total cases vs Total deaths, entire world statistics
Select  location,date_d, total_cases, total_deaths,(total_deaths/total_cases)*100 as death_percentage
from coviddeaths where continent is not null order by 1,2;

-- Total cases vs Total deaths using location filter as INDIA
Select location,date_d, total_cases, total_deaths,(total_deaths/total_cases)*100 as death_percentage
from coviddeaths where location = 'India' and continent is not null order by 1,2;

-- Total Cases vs Population using location filter as INDIA 
-- Result depicts what percentage of cases occured with respect to population of the country
Select location,date_d, total_cases, population,(total_cases/population)*100 as population_infected
from coviddeaths where location = 'India' and continent is not null order by 1,2;


-- Location wise highest infection rate of the population
-- Can be used to check for specific Country by removing Location filter comment
-- In case of "maxpopulationinfected" values returning as NULL, no data for those specific locations was provided in the original dataset
Select location,population , max(total_cases) as Highest_Count,Max((NULLIF(total_cases,0)/population))*100 as max_population_infected
from coviddeaths --where location = 'India'
where continent is not null
group by location, population
order by max_population_infected desc;


-- Location wise highest death rate of the population
-- Can be used to check for specific countries by removing Location filter comment
-- In case of "maxpopulationdeaths" values returning as NULL, no data for those specific locations was provided in the original dataset
Select location,population , max(total_deaths) as Highest_Count,Max((NULLIF(total_deaths,0)/population))*100 as max_population_deaths
from coviddeaths --where location = 'India' 
where continent is not null
group by location, population
order by max_population_deaths desc;



-- Highest Death count for each Individual Country
select location, max(NULLIF(total_deaths,0)) as Total_Death_Count
from coviddeaths --where location = 'India' 
where continent is not null
group by location
order by Total_Death_Count desc;

--Highest Death count for each Individual Continent
select continent, max(NULLIF(total_deaths,0)) as Total_Death_Count
from coviddeaths --where location = 'India' 
where continent is not null
group by continent
order by Total_Death_Count desc;

-- OR
select location, sum(nullif(new_deaths,0)) as Total_Death_Count
from coviddeaths --where location = 'India' 
where continent is null and location not in('World','European Union',
'International') and location not like '%income%'
group by location 
order by Total_Death_Count desc;


-- Global Numbers : Deaths percentage per New Cases based on date from all around the world
Select date_d, sum(new_cases) as total_New_Cases, sum(new_deaths) as total_New_Deaths, (SUM(new_deaths)/SUM (NULLIF(new_cases,0))*100) 
as death_Percentage
from coviddeaths
where continent is not null --and new_cases <>0
group by date_d
order by 1;

-- Total Global Death Count Percentage
Select sum(new_cases) as total_New_Cases, sum(new_deaths) as total_New_Deaths, (SUM(new_deaths)/SUM (NULLIF(new_cases,0))*100) 
as death_Percentage
from coviddeaths
where continent is not null --and new_cases <>0
order by 1,2;

-- Country and Date wise New Vaccinations and Total Vaccines administered to that date
select cds.continent,cds.Location,cds.date_d,vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by cds.Location order by cds.location,cds.date_d) as Total_Vaccination
from coviddeaths cds join vaccine vac
on cds.location = vac.location and cds.date_d = vac.date_d
where cds.location is not null
order by 2,3;


--Country and Date wise New Vaccinations and Total Vaccines administered to that date
-- ToatlVaccinated : % of total population that was Vaccinated sorted by Date and Country
With POPvsVAC (Continent,Location,Date_d,Population,New_Vaccinations,Total_Vaccination )
as
(select cds.continent,cds.Location,cds.date_d,cds.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by cds.Location order by cds.location,cds.date_d) as Total_Vaccination
from coviddeaths cds join vaccine vac
on cds.location = vac.location and cds.date_d = vac.date_d
where cds.location is not null
--order by 2,3)
) select POPvsVaC.*,((Total_Vaccination/Population)*100) as Total_Vaccination_Percentage from POPvsVAC;



-- Total % Population Vaccinated VS Total Population
With POPvsVAC (Continent,Location,Date_d,Population,New_Vaccinations,Total_Vaccination )
as
(select cds.continent,cds.Location,cds.date_d,cds.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by cds.Location order by cds.location,cds.date_d) as Total_Vaccination
from coviddeaths cds join vaccine vac
on cds.location = vac.location and cds.date_d = vac.date_d
where cds.location is not null
--order by 2,3)
) select POPvsVAC.Location, MAX(POPvsVaC.Population) as Population,MAX(POPvsVaC.Total_Vaccination) as Total_Vaccination,
MAX((Total_Vaccination/Population)*100) as Total_Vaccinated_Percentage from POPvsVAC
Group by POPvsVAC.Location
order by 1,2;


-- Creating view for vizualisations later
Create View Vaccinated_popx as 
select cds.continent,cds.Location,cds.date_d,cds.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by cds.Location order by cds.location,cds.date_d) as Total_Vaccination
from coviddeaths cds join vaccine vac
on cds.location = vac.location and cds.date_d = vac.date_d
where cds.location is not null;
--order by 2,3)


