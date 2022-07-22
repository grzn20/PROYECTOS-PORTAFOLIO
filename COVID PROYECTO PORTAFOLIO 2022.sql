
-- SELECCIONAR LA DATA QUE VAMOS A USAR

SELECT location,date, total_cases,new_cases,total_deaths, population
FROM [PORTAFOLIO PROJECT]..CovidDeaths$
ORDER BY 1,2

-- VEREMOS EL TOTAL DE CASOS VS EL TOTAL DE MUERTES
-- VEREMOS LA PROBALIDAD DE FALLECER DE COVID EN TU PAIS EN CASO DE CONTRAERLO
SELECT location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS Porcentaje_de_muertes
FROM [PORTAFOLIO PROJECT]..CovidDeaths$
WHERE location like 'Peru'
ORDER BY 1,2


-- VEREMOS EL TOTAL DE CASOS VS LA POBLACION EN PERU
SELECT location,date, total_cases,population, (total_cases/population)*100 AS Porcentaje_de_infectados
FROM [PORTAFOLIO PROJECT]..CovidDeaths$
WHERE location like 'Peru'
ORDER BY 1,2

-- Veremos los paises con el mayor porcentaje de infectados de acuerdo a su poblacion total
SELECT location,population, Max(total_cases) as Mayor_Infeccion, Max((total_cases/population))*100 AS Porcentaje__infectados
FROM [PORTAFOLIO PROJECT]..CovidDeaths$
--WHERE location like 'Peru'
Group by location,population
ORDER BY Porcentaje__infectados desc

  -- Veremos los paises con el mayor porcentaje de muertes de acuerdo a su poblacion total
SELECT location,population, Max(total_deaths) as Mayor_Nro_Muertes, Max((total_deaths/population))*100 AS Porcentaje__Fallecidos_por_habitantes
FROM [PORTAFOLIO PROJECT]..CovidDeaths$
--WHERE location like 'Peru'
Group by location,population
ORDER BY Porcentaje__Fallecidos_por_habitantes desc

--Total Muertes por continente
SELECT continent, MAX(cast(total_deaths as int)) as Total_muertes
FROM [PORTAFOLIO PROJECT]..CovidDeaths$
WHERE continent not like ''
Group by continent 
ORDER BY Total_muertes desc

SELECT continent,location, population, MAX(cast(total_deaths as int)) as Total_muertes, MAX(cast(total_cases as int)) as Total_Casos
FROM [PORTAFOLIO PROJECT]..CovidDeaths$
WHERE continent not like '' 
GROUP BY continent,location,population
ORDER BY continent asc

--Numeros Globales
SELECT  SUM(new_cases) as Contagios_Covid, SUM(cast(New_deaths as int)) as Muertes_Covid, (SUM(cast(New_deaths as int))/SUM(new_cases))*100 as Porcentaje_Fallecidos
FROM [PORTAFOLIO PROJECT]..CovidDeaths$
WHERE continent not like '' 
--GROUP BY date
ORDER BY 1,2

--Total de Poblacion vs Total de dosis aplicadas
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS TotalDosisaplicadas
--, (TotalDosisaplicadas/population)*100 AS Dosis_aplicadas_PerCapita
FROM [PORTAFOLIO PROJECT]..CovidDeaths$ dea
JOIN [PORTAFOLIO PROJECT]..CovidVacu$ vac
ON dea.location = vac.location
and dea.date = vac.date 
WHERE dea.continent not like '' and dea.continent is not null -- and dea.location like 'Peru'
ORDER BY 2,3

-- Use CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalDosisAplicadas)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS TotalDosisAplicadas
--, (Total_Dosis_aplicadas/population)*100 AS Dosis_aplicadas_PerCapita
FROM [PORTAFOLIO PROJECT]..CovidDeaths$ dea
JOIN [PORTAFOLIO PROJECT]..CovidVacu$ vac
ON dea.location = vac.location
and dea.date = vac.date 
WHERE dea.continent not like '' and dea.continent is not null -- and dea.location like 'Peru'
--ORDER BY 2,3
)
Select *, (TotalDosisAplicadas/population) AS DosisAplicadasPerCapita
From PopvsVac

-- Nueva Tabla

DROP TABLE IF exists #DOSISVACUNASPERCAPITA
CREATE TABLE #DOSISVACUNASPERCAPITA
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations float,
TotalDosisAplicadas float
)
INSERT INTO #DOSISVACUNASPERCAPITA
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS TotalDosisAplicadas
--, (Total_Dosis_aplicadas/population)*100 AS Dosis_aplicadas_PerCapita
FROM [PORTAFOLIO PROJECT]..CovidDeaths$ dea
JOIN [PORTAFOLIO PROJECT]..CovidVacu$ vac
ON dea.location = vac.location
and dea.date = vac.date 
WHERE dea.continent not like '' and dea.continent is not null -- and dea.location like 'Peru'
--ORDER BY 2,3

Select *, (TotalDosisAplicadas/population) AS DosisAplicadasPerCapita
FROM #DOSISVACUNASPERCAPITA


-- Crear vista para almacenar datos para visualizaciones posteriores

CREATE VIEW DOSISVACUNASPERCAPITA AS
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS TotalDosisAplicadas
--, (Total_Dosis_aplicadas/population)*100 AS Dosis_aplicadas_PerCapita
FROM [PORTAFOLIO PROJECT]..CovidDeaths$ dea
JOIN [PORTAFOLIO PROJECT]..CovidVacu$ vac
ON dea.location = vac.location
and dea.date = vac.date 
WHERE dea.continent not like '' and dea.continent is not null -- and dea.location like 'Peru'
--ORDER BY 2,3

SELECT *
FROM DOSISVACUNASPERCAPITA