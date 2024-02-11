SELECT * FROM PortfolioProject.dbo.HousingData

/*Data Cleaning in SQL */

--Standarize date format
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.HousingData

UPDATE PortfolioProject.dbo.HousingData
SET SaleDate = CONVERT(Date, SaleDate)


--Populate Property Address data
SELECT *
FROM PortfolioProject.dbo.HousingData
WHERE PropertyAddress is null
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.HousingData as a
JOIN PortfolioProject.dbo.HousingData as b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL( a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.HousingData as a
JOIN PortfolioProject.dbo.HousingData as b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

--Breaking out addresses into individual Columns (Address, City, State)
SELECT PropertyAddress
FROM PortfolioProject.dbo.HousingData


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress) +1), LEN(PropertyAddress)-(CHARINDEX(',', PropertyAddress))) as Address
FROM PortfolioProject.dbo.HousingData


ALTER TABLE PortfolioProject.dbo.HousingData
ADD PropertySplitAddress Nvarchar(255)

UPDATE PortfolioProject.dbo.HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE PortfolioProject.dbo.HousingData
ADD PropertySplitCity Nvarchar(255)

UPDATE PortfolioProject.dbo.HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress) +1), LEN(PropertyAddress)-(CHARINDEX(',', PropertyAddress)))


SELECT * 
FROM PortfolioProject.dbo.HousingData

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3 ),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2 ),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1 )
FROM PortfolioProject.dbo.HousingData


ALTER TABLE PortfolioProject.dbo.HousingData
ADD OwnerSplitAddress Nvarchar(255)

UPDATE PortfolioProject.dbo.HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3 )


ALTER TABLE PortfolioProject.dbo.HousingData
ADD OwnerSplitCity Nvarchar(255)

UPDATE PortfolioProject.dbo.HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2 )


ALTER TABLE PortfolioProject.dbo.HousingData
ADD OwnerSplitState Nvarchar(255)

UPDATE PortfolioProject.dbo.HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1 )

--Change 1 and 0 to Yes and No in "Sold as Vacant" fied

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.HousingData
GROUP BY SoldAsVacant

ALTER TABLE PortfolioProject.dbo.HousingData
ADD SoldAsVacant1 Nvarchar(3)


UPDATE PortfolioProject.dbo.HousingData
SET SoldAsVacant1 = CASE SoldAsVacant
						WHEN 0 THEN 'No'
						WHEN 1 THEN 'Yes'
						ELSE CAST(SoldAsVacant AS NVARCHAR(3))
						END
FROM PortfolioProject.dbo.HousingData

SELECT COUNT(SoldAsVacant), SoldAsVacant1
FROM PortfolioProject.dbo.HousingData
GROUP BY SoldAsVacant1


ALTER TABLE PortfolioProject.dbo.HousingData
DROP COLUMN SoldAsVacant


SELECT SoldAsVacant
FROM PortfolioProject.dbo.HousingData




SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = '0' THEN 'No'
	 WHEN SoldAsVacant = '1' THEN 'Yes'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject.dbo.HousingData

--Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY 
		UniqueID
		) row_num
FROM PortfolioProject.dbo.HousingData
)

SELECT * 
FROM RowNumCTE 
WHERE row_num > 1
--ORDER BY PropertyAddress



--Delete unused columns

ALTER TABLE PortfolioProject.dbo.HousingData
DROP COLUMN OwnerAddress, TaxDistrict

ALTER TABLE PortfolioProject.dbo.HousingData
DROP COLUMN SaleDate


SELECT * FROM PortfolioProject.dbo.HousingData