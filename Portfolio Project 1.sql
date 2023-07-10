SELECT*
FROM PortfolioProject..[Covid Deaths]
Order By 3,4

SELECT*
FROM PortfolioProject.dbo.[Covid Deaths]
Order By 3,4

/* Select Data That Will Be Used*/

SELECT Location, date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..[Covid Deaths]
Order By 1,2

-- Looking at Total Cases vs Total Deaths--
--Changing the Data Type of the column to Float (Using CAST) So I Can Do Calculations On It--
SELECT Location, date,total_cases,total_deaths,CAST (total_deaths as Float)/CAST (total_cases AS Float)*100 AS Death_Percentage
FROM PortfolioProject..[Covid Deaths]
Order By 1,2

--Changing the Data Type of the column to Float (Using Convert) So I Can Do Calculations On It--
--Shows Likelyhood of Dying if You Contract Covid in A country (using US as a case study)--
SELECT Location, date,total_cases,total_deaths,Convert(Float,total_deaths)/Convert(Float,total_cases)*100 as DeathVsCases
FROM PortfolioProject..[Covid Deaths]
WHERE location like '%state%'
Order By 1,2

/*Looking at the TotalCases Vs Population*/
--Shows The Percentage of the Population With Covid--
SELECT Location, date,population,total_cases,Convert(Float,total_cases)/population*100 as CasesVsPopulation
FROM PortfolioProject..[Covid Deaths]
WHERE location in ('Nigeria','united states')
Order By 1,2

--What Country Has the Highest Covid Infection Rate Compared to its Population--
SELECT Location,population,MAX (total_cases) AS HighestInfectionCount,MAX (Convert(Float,total_cases)/population)*100 as PercentPopulationinfected
FROM PortfolioProject..[Covid Deaths]
GROUP BY Location,population
Order By 4 DESC

--SHOWING COUNTRIES WITH HIGHEST DEAD COUNT PER POPULATION--
SELECT Location, MAX (cast(total_deaths as float)) AS TotalDeathCount
FROM PortfolioProject..[Covid Deaths]
WHERE continent is not null
GROUP BY Location
Order By 2 DESC

--LET'S BREAK THINGS DOWN BY CONTINENT--
SELECT continent, MAX (cast(total_deaths as float)) AS TotalDeathCount
FROM PortfolioProject..[Covid Deaths]
WHERE continent is not null
GROUP BY continent
Order By 2 DESC

--SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION--
SELECT continent, MAX (cast(total_deaths as float)) AS TotalDeathCount, MAX (CAST(total_deaths as float)/population)*100 as DeathCountPopulation
FROM PortfolioProject..[Covid Deaths]
WHERE continent is not null
GROUP BY continent
Order By 3 DESC

--GLOBAL NUMBERS (Using Date To Group)--
SELECT date,SUM (new_cases) total_cases,SUM (new_deaths) Total_deaths, SUM (new_deaths)/SUM(new_cases)*100 as NewDeathCases
FROM PortfolioProject..[Covid Deaths]
WHERE continent is not null
AND new_cases <> 0 
GROUP BY date
ORDER BY 1,2

--GLOBAL NUMBERS (NO GROUPING)
SELECT SUM (new_cases) total_cases,SUM (new_deaths) Total_deaths, SUM (new_deaths)/SUM(new_cases)*100 as NewDeathCases
FROM PortfolioProject..[Covid Deaths]
WHERE continent is not null
AND new_cases <> 0 
ORDER BY 1,2

--LOOKING AT TOTAL POPULATION VS VACCINATIONS
SELECT CD.continent, CD.location, CD.date,CD.population,CV.new_vaccinations,CV.total_vaccinations,
SUM (CAST(CV.new_vaccinations AS FLOAT)) OVER (Partition by CD.Location ORDER BY CD.Location, CD.date)
AS RollingPeopleVaccinated,

FROM PortfolioProject..[Covid Vaccination] CV
JOIN PortfolioProject..[Covid Deaths] CD
ON CV.location= CD.location
AND CV.date = CD.date
WHERE CD.continent is not null
ORDER BY 2,3

--USE CTE--
WITH PopvsVac (Continent, Location,Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT CD.continent, CD.location, CD.date,CD.population,CV.new_vaccinations,
SUM (CAST(CV.new_vaccinations AS FLOAT)) OVER (Partition by CD.Location ORDER BY CD.Location, CD.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..[Covid Vaccination] CV
JOIN PortfolioProject..[Covid Deaths] CD
ON CV.location= CD.location
AND CV.date = CD.date
WHERE CD.continent is not null
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE--
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT CD.continent, CD.location, CD.date,CD.population,CV.new_vaccinations,
SUM (CAST(CV.new_vaccinations AS FLOAT)) OVER (Partition by CD.Location ORDER BY CD.Location, CD.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..[Covid Vaccination] CV
JOIN PortfolioProject..[Covid Deaths] CD
ON CV.location= CD.location
AND CV.date = CD.date
WHERE CD.continent is not null

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS--
CREATE VIEW PercentPopulationVaccinated as
SELECT CD.continent, CD.location, CD.date,CD.population,CV.new_vaccinations,
SUM (CAST(CV.new_vaccinations AS FLOAT)) OVER (Partition by CD.Location ORDER BY CD.Location, CD.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..[Covid Vaccination] CV
JOIN PortfolioProject..[Covid Deaths] CD
ON CV.location= CD.location
AND CV.date = CD.date
WHERE CD.continent is not null

SELECT*
FROM PercentPopulationVaccinated