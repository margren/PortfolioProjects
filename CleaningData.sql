SELECT * 
FROM NashvilleHousing

---------- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)
-- OR
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM NashvilleHousing

-------------------------------------------------------------------------


---------- Popumate Property Address Data

SELECT PropertyAddress
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID --Parcel ID is linked to a property addressy


SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID			 
	AND a.[UniqueID ] <> b.[UniqueID ]	
WHERE a.PropertyAddress IS NULL

SELECT PropertyAddress
FROM NashvilleHousing
ORDER BY ParcelID
-------------------------------------------------------------------------


---------- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing
-- You notice there is a comma delimitating the address from the city


SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) AS Address
-- ,CHARINDEX(',', PropertyAddress)
FROM NashvilleHousing


SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
FROM NashvilleHousing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing



ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(255);
ALTER TABLE NashvilleHousing
ADD PropertySplitCity VARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT PropertySplitAddress, PropertySplitCity
FROM NashvilleHousing
-------------------------------------------------------------------------




---------- UPDATE OF THE OWNER ADDRESS

SELECT OwnerAddress
FROM NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),		
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
FROM NashvilleHousing



SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress VARCHAR(255);
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity VARCHAR(255);
ALTER TABLE NashvilleHousing
ADD OwnerSplitState VARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM NashvilleHousing

-------------------------------------------------------------------------



---------- CHANGE Y AND N TO YES AND NO IN SoldAsVacant

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS Total
FROM NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
	CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
	CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS Total
FROM NashvilleHousing
GROUP BY SoldAsVacant

-------------------------------------------------------------------------


---------- REMOVE DUPLICATES

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY	ParcelID, 				
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY UniqueID
			) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress
SELECT *
FROM NashvilleHousing


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY	ParcelID, 				
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY UniqueID
			) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1


-------------------------------------------------------------------------



---------- DELETE UNUSED COLUMNS

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

-------------------------------------------------------------------------
