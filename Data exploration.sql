SELECT*
FROM dbo.[Covid Deaths]
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT*
FROM dbo.[Covid Vaccinations]
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM dbo.[Covid Deaths]
WHERE continent IS NOT NULL
ORDER BY 1,2

--Total cases VS Total Death
-- Showing country specific death rates or percentage of deaths against the total cases 
--The Deathrate for Canada was highest in July 2020 and lowest in March 2020

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Rate
FROM dbo.[Covid Deaths]
WHERE Location like '%Canada%'
AND Continent IS NOT NULL
ORDER BY Death_Rate DESC

--Percentage of Population that got infected with COVID
SELECT Location, date, Population, total_cases,  (total_cases/population)*100 AS Percent_Population_Infected
FROM dbo.[Covid Deaths]
WHERE Location like 'Canada'
ORDER BY Percent_Population_Infected DESC

--Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) AS Highest_Infection_Count, MAX(total_cases/ population)*100 AS Percent_Population_Infected
FROM dbo.[Covid Deaths]
--WHERE Location like 'Canada'
GROUP BY location, population
ORDER BY Percent_Population_Infected DESC

--Countries with Highest Death Count per population
SELECT Location, MAX(CAST(total_deaths as int)) AS Total_Deathcount
FROM dbo.[Covid Deaths]
--WHERE Location like 'Canada'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Deathcount DESC

Select Location, MAX(Total_deaths) as TotalDeathCount
From dbo.[Covid Deaths]
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

---Continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths as int)) AS Total_Deathcount
FROM dbo.[Covid Deaths]
--WHERE Location like 'Canada'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Deathcount DESC

--Global Figures
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM dbo.[Covid Deaths]
--WHERE location like 'Canada'
WHERE continent is not null 
--GROUP BY date
ORDER BY 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM dbo.[Covid Deaths] dea
JOIN dbo.[Covid Vaccinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM dbo.[Covid Deaths] dea
JOIN dbo.[Covid Vaccinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM dbo.[Covid Deaths] dea
JOIN dbo.[Covid Vaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null 
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM dbo.[Covid Deaths] dea
JOIN dbo.[Covid Vaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 







