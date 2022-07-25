--Limpieza de datos en sql

SELECT *
FROM [DataCleanProject]..Sheet1$
ORDER BY 1,2

-- Dar formato a columna fecha

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM [DataCleanProject]..Sheet1$

UPDATE Sheet1$
SET SaleDate = CONVERT(Date,SaleDate)

-- Populate Property Address data

SELECT *
FROM [DataCleanProject]..Sheet1$
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [DataCleanProject]..Sheet1$ a
JOIN [DataCleanProject]..Sheet1$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [DataCleanProject]..Sheet1$ a
JOIN [DataCleanProject]..Sheet1$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- dividir la dirección en columnas individuales en dirección, ciudad y estado

SELECT PropertyAddress
FROM [DataCleanProject]..Sheet1$
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Dirección
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Ciudad

FROM [DataCleanProject]..Sheet1$


ALTER TABLE Sheet1$
Add PropertySplitAddress Nvarchar(255);

UPDATE Sheet1$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Sheet1$
Add PropertySplitCity Nvarchar(255);

UPDATE Sheet1$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT *
FROM [DataCleanProject]..Sheet1$

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM [DataCleanProject]..Sheet1$



ALTER TABLE Sheet1$
Add OwnerSplitAddress Nvarchar(255);

UPDATE Sheet1$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Sheet1$
Add OwnerSplitCity Nvarchar(255);

UPDATE Sheet1$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Sheet1$
Add OwnerSplitState Nvarchar(255);

UPDATE Sheet1$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM [DataCleanProject]..Sheet1$

--Cambie Y y N a Sí y No en el campo "SoldAsVacant"

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [DataCleanProject]..Sheet1$
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM [DataCleanProject]..Sheet1$

UPDATE Sheet1$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- ELIMINAR LOS DUPLICADOS

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM [DataCleanProject]..Sheet1$
--order by ParcelID
)
DELETE 
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

SELECT *
FROM [DataCleanProject]..Sheet1$

-- Eliminar columnas no utilizadas

Select *
From [DataCleanProject]..Sheet1$


ALTER TABLE [DataCleanProject]..Sheet1$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
