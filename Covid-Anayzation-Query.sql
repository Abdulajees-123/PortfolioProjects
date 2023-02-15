--select * from CovidVaccination
--ORDER BY 3,4

select * from CovidDeath
WHERE continent IS NOT NULL
ORDER BY 3,4
GO

--Looking at total cases and total deaths
--Shows likelihood of dying when you contract covid in our country
SELECT location,date,total_cases,new_cases,total_deaths,population,
(total_deaths/total_cases)*100 AS Death_Percentage											
FROM CovidDeath
WHERE location ='United States' 
AND continent IS NOT NULL
ORDER BY 1,2
GO


--Looking at Total cases VS population
--Shows what percentage of population got covid
SELECT location,date,total_cases,population,new_cases,
(total_cases/population)*100 AS Infected_Percentage	
FROM CovidDeath									
WHERE location ='United States' 
AND continent IS NOT NULL
AND date BETWEEN '2020-01-28 00:00:00.000' AND '2021-04-30 00:00:00.000'
ORDER BY 1,2
GO

--Looking at countries with higher percentage rate compared to population

SELECT location,population,MAX(total_cases) AS highestinfectionCount,
MAX((total_cases/population)*100) AS PercentpopulationInfected	
FROM CovidDeath									
WHERE 
--location like '%emirates%' AND
date BETWEEN '2020-01-28 00:00:00.000' AND '2021-04-30 00:00:00.000'
AND continent IS NOT NULL
GROUP BY location,population
ORDER BY PercentpopulationInfected DESC
GO

--Showing countries with highest death count per population

SELECT location,MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM CovidDeath									
WHERE 
--location like '%emirates%' AND
date BETWEEN '2020-01-28 00:00:00.000' AND '2021-04-30 00:00:00.000'
AND continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

--Let's break things down based on continent

--Showing continents with highest death count per population

SELECT continent,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeath									
WHERE 
--location like '%emirates%' AND
date BETWEEN '2020-01-28 00:00:00.000' AND '2021-04-30 00:00:00.000'
AND location NOT IN('High income','Upper middle income')
AND continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC
GO


--Global Numbers


SELECT SUM(new_cases) AS Total_cases,SUM(CAST(new_deaths AS int)) AS Total_Deaths,
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeath									
WHERE 
--location like '%emirates%' AND
date BETWEEN '2020-01-28 00:00:00.000' AND '2021-04-30 00:00:00.000'
AND location NOT IN('High income','Upper middle income')
AND continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2
GO


--Looking at total poeple VS vaccinations

With popvsvac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(

		select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
		SUM(CAST(cv.new_vaccinations AS int)) OVER(PARTITION BY cd.location ORDER BY cd.location,cd.date) AS RollingPeopleVaccinated
		from 
		CovidDeath CD JOIN CovidVaccination CV
		ON(CD.location=CV.location AND CD.date=CV.date)
		WHERE 

		CD.date BETWEEN '2020-01-28 00:00:00.000' AND '2021-04-30 00:00:00.000'
		AND CD.location NOT IN('High income','Upper middle income')
		AND CD.continent IS NOT NULL
--		ORDER By 2,3
)

SELECT *,(RollingPeopleVaccinated/population)*100 AS PercentageOfVaccination
FROM popvsvac
ORDER By 2,3


--Create View for storE data later for  visualization

CREATE VIEW PercentPopulationVaccinated
AS
		select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
		SUM(CAST(cv.new_vaccinations AS int)) OVER(PARTITION BY cd.location ORDER BY cd.location,cd.date) AS RollingPeopleVaccinated
		from 
		CovidDeath CD JOIN CovidVaccination CV
		ON(CD.location=CV.location AND CD.date=CV.date)
		WHERE 

		CD.date BETWEEN '2020-01-28 00:00:00.000' AND '2021-04-30 00:00:00.000'
		AND CD.location NOT IN('High income','Upper middle income')
		AND CD.continent IS NOT NULL

GO

SELECT top 100 * FROM PercentPopulationVaccinated

