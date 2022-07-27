-- EXPLORACION DE DATOS DE MARKETING CAMPAING

USE DB_marketing_campaign
GO

SELECT *
FROM marketing_campaign$


-- Cantidad de profesionales por gado de estudios
USE DB_marketing_campaign
GO

SELECT DISTINCT(education), COUNT (education) as Cantidad
FROM marketing_campaign$
GROUP BY Education
ORDER BY (Cantidad) desc

-- Edad actual de los clientes

USE DB_marketing_campaign
GO

SELECT id,Year_Birth,DATEDIFF(YEAR,convert(date, convert(varchar(255), Year_Birth) + '0101'), GETDATE()) as EDAD
FROM marketing_campaign$
ORDER BY ID ASC

--Agrega la columna 'AGE'

ALTER TABLE marketing_campaign$ 
Add AGE Nvarchar(255);

UPDATE marketing_campaign$
SET AGE = DATEDIFF(YEAR,convert(date, convert(varchar(255), Year_Birth) + '0101'), GETDATE())

SELECT ID,AGE
FROM marketing_campaign$

--ESTADO CIVIL Y CUANTOS TIENEN Y NO TIENEN HIJOS

USE DB_marketing_campaign
GO

SELECT DISTINCT(Marital_Status), COUNT (Marital_Status) as Cantidad ,CASE WHEN Kidhome = 0 THEN 'NO' WHEN Kidhome >= 1  THEN 'YES' END as HIJOS
FROM marketing_campaign$
GROUP BY Kidhome, Marital_Status
ORDER BY (Cantidad) desc

-- CUANTOS DE LOS MATRIMONIOS REALIZAN SUS COMPRAS TOTALES Y POR QUE MEDIOS

USE DB_marketing_campaign
GO

SELECT DISTINCT(Marital_Status), COUNT (Marital_Status) as Cantidad,SUM(MntWines+MntFruits+MntMeatProducts+MntFishProducts) as [Total Articulos],
SUM(NumStorePurchases) as [En Tienda], SUM(NumWebPurchases) as [Por Web], SUM(NumCatalogPurchases) as [Por Catalogo], SUM(NumDealsPurchases) as [Ofertas]
FROM marketing_campaign$
--WHERE Marital_Status LIKE 'MARRIED'
GROUP BY Marital_Status
ORDER BY (Cantidad) desc


-- CONSUMO DE PRODUCTOS POR EDAD
USE DB_marketing_campaign
GO

SELECT CASE WHEN (AGE >= 18 AND AGE < 35) THEN '18-35'
			WHEN (AGE >= 35 AND AGE < 45) THEN '35-45'
			WHEN (AGE >= 45 AND AGE < 55) THEN '45-55'
			WHEN (AGE >= 55 AND AGE < 65) THEN '55-65'
			WHEN (AGE >= 65 AND AGE < 75) THEN '65-75'
			ELSE 'MAYOR 75'
			END AS [RANGOS DE EDAD], 
SUM(MntWines) AS VINO, SUM(MntFruits) AS FRUTA, SUM(MntMeatProducts) AS CARNES, SUM(MntFishProducts) AS PESCADOS
FROM marketing_campaign$
GROUP BY AGE


--TABLA PARA VISUALIZACION 

ALTER TABLE marketing_campaign$ 
Add RANGEAGE Nvarchar(255);

UPDATE marketing_campaign$
SET RANGEAGE = CASE WHEN (AGE >= 18 AND AGE < 35) THEN '18-35'
			WHEN (AGE >= 35 AND AGE < 45) THEN '35-45'
			WHEN (AGE >= 45 AND AGE < 55) THEN '45-55'
			WHEN (AGE >= 55 AND AGE < 65) THEN '55-65'
			WHEN (AGE >= 65 AND AGE < 75) THEN '65-75'
			ELSE 'MAYOR 75'
			END


CREATE VIEW CAMPAINGFORTABLEU AS
SELECT ID,Year_Birth,AGE,RANGEAGE,Education,Marital_Status,(Kidhome+Teenhome) AS [SONS],Dt_Customer,MntFishProducts,MntFruits,MntGoldProds,MntMeatProducts,MntSweetProducts,NumCatalogPurchases,NumDealsPurchases,
NumStorePurchases,NumWebPurchases,NumWebVisitsMonth
FROM marketing_campaign$
