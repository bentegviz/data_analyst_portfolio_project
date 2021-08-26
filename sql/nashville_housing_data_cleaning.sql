/*
Data Cleaning in SQL
Nashville Housing Dataset
https://www.kaggle.com/tmthyjames/nashville-housing-data-1
Apache 2.0 open source license
*/

--View the Dataset First/Top 10 rows
SELECT 
	TOP 10 *
FROM
	[DataAnalyst_PortfolioProject].[dbo].[nashville_housing_data];

/**********Standardize the Date format in 'SaleDate' column**********/
SELECT 
	SaleDate,
	CONVERT(Date, SaleDate)
FROM
	[DataAnalyst_PortfolioProject].[dbo].[nashville_housing_data];  
--attempt to convert SaleDate to datatype Date, not successful

--add column SaleDateConverted as datatype Date
ALTER TABLE dbo.nashville_housing_data
ADD SaleDateConverted DATE;

--modify table to set SaleDateConverted as SaleDate, converted from Timestamp to Date datatype
UPDATE dbo.nashville_housing_data
SET SaleDateConverted = CONVERT(DATE, SaleDate);

--checking SaleDateConverted was added to table
SELECT 
	TOP 10 *
FROM
	[DataAnalyst_PortfolioProject].[dbo].[nashville_housing_data];  


/**********Standardize and Populate 'PropertyAddress' column**********/
SELECT 
	*
FROM
	dbo.nashville_housing_data
WHERE
	PropertyAddress IS NULL
ORDER BY 
	ParcelID;
--multiple NULL values with same ParcelID

--Using a SELF JOIN to check for NULL values
SELECT
	parcelA.ParcelID, parcelA.PropertyAddress, parcelB.ParcelID, parcelB.PropertyAddress  --select ParcelID and PropertyAddress from self joined table
FROM
	dbo.nashville_housing_data  parcelA
JOIN
	dbo.nashville_housing_data  parcelB  --join table on itself
	ON parcelA.ParcelID = parcelB.ParcelID  --where ParcelID is the same
	AND parcelA.[UniqueID ] <> parcelB.[UniqueID ]  --but UniqueID is NOT the same
WHERE parcelA.PropertyAddress IS NULL  --only show null values
--shows PropertyAddress is missing data, even though other entries with identical ParcelID values contain a PropertyAddress

--populating PropertyAddress values
SELECT
	parcelA.ParcelID, parcelA.PropertyAddress, parcelB.ParcelID, parcelB.PropertyAddress, ISNULL(parcelA.PropertyAddress, parcelB.PropertyAddress)  --if parcelA is null, use parcelB value
FROM
	dbo.nashville_housing_data  parcelA
JOIN
	dbo.nashville_housing_data  parcelB  --join table on itself
	ON parcelA.ParcelID = parcelB.ParcelID  --where ParcelID is the same
	AND parcelA.[UniqueID ] <> parcelB.[UniqueID ]  --but UniqueID is NOT the same
WHERE parcelA.PropertyAddress IS NULL  --only show null values
--when parcelA PropertyAddress is NULL, use parcelB Property Address

--updating PropertyAddress where parcelA is null using parcelB values
UPDATE 
	parcelA
SET
	PropertyAddress = ISNULL(parcelA.PropertyAddress, parcelB.PropertyAddress)  --if parcelA is null, use parcelB value
FROM
	dbo.nashville_housing_data  parcelA
JOIN
	dbo.nashville_housing_data  parcelB  --join table on itself
	ON parcelA.ParcelID = parcelB.ParcelID  --where ParcelID is the same
	AND parcelA.[UniqueID ] <> parcelB.[UniqueID ]  --but UniqueID is NOT the same
WHERE parcelA.PropertyAddress IS NULL  --only show null values
--shows no entries when rerunning '--populating PropertyAddress values' query
 

/**********Standardize Address into Individual columns**********/
/**********Splitting 'PropertyAddress' into 'Address', 'City', 'State' columns**********/
--Using SUBSTRING and CHARINDEX
SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,  --select column 'PropertyAddress', starting position = 1
	--CHARINDEX looking for comma within PropertyAddress string, then moving -1 position to remove comma from string selection
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City  --select column 'PropertyAddress'
	--starting position = CHARINDEX looking for comma within PropertyAddress string, moving +1 position to remove comma from string selection
	--length of string
FROM
	dbo.nashville_housing_data

--add column PropertySplitAddress as datatype NVARCHAR
ALTER TABLE dbo.nashville_housing_data
ADD PropertySplitAddress NVARCHAR(255);

--modify table to set PropertySplitAddress as SUBSTRING Address
UPDATE dbo.nashville_housing_data
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

--add column PropertyCityAddress as datatype NVARCHAR
ALTER TABLE dbo.nashville_housing_data
ADD PropertySplitCity NVARCHAR(255);

--modify table to set PropertySplitCity from SUBSTRING City
UPDATE dbo.nashville_housing_data
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--checking PropertySplitAddress and PropertySplitcity were added to table
SELECT 
	TOP 10 *
FROM
	[DataAnalyst_PortfolioProject].[dbo].[nashville_housing_data]
--shows new columns added successfully


/*Splitting 'OwnerAddress' into 'Address', 'City', 'State' columns*/
--Using PARSENAME (only works with '.' in strings)
SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,  -- using PARSENAME, REPLACE commas in column OwnerAddress with periods, starting at 3rd instance of delimiter
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,  -- using PARSENAME, REPLACE commas in column OwnerAddress with periods, starting at 2nd instance of delimiter
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State -- using PARSENAME, REPLACE commas in column OwnerAddress with periods, starting at 1st instance of delimiter
FROM
	dbo.nashville_housing_data


--add column OwnerSplitAddress as datatype NVARCHAR
ALTER TABLE dbo.nashville_housing_data
ADD OwnerSplitAddress NVARCHAR(255);

--modify table to set PropertySplitAddress as PARSENAME Address
UPDATE dbo.nashville_housing_data
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

--add column OwnerSplitCity as datatype NVARCHAR
ALTER TABLE dbo.nashville_housing_data
ADD OwnerSplitCity NVARCHAR(255);

--modify table to set OwnerSplitCity from PARSENAME City
UPDATE dbo.nashville_housing_data
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

--add column OwnerSplitState as datatype NVARCHAR
ALTER TABLE dbo.nashville_housing_data
ADD OwnerSplitState NVARCHAR(255);

--modify table to set OwnerSplitState from PARSENAME City
UPDATE dbo.nashville_housing_data
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--checking OwnerSplitAddress, OwnerSplitSity, and OwnerSplitState were added to table
SELECT 
	TOP 20 *
FROM
	dbo.nashville_housing_data
--shows new columns added successfully


/**********Standardize SoldAsVacant Column**********/
/**********Update any 'Y' or 'N' values to 'Yes' or 'No'**********/
SELECT
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant) AS temp_count
FROM
	dbo.nashville_housing_data
GROUP BY
	SoldAsVacant
ORDER BY temp_count
--shows N, Yes, Y, and No values in SoldAsVacant

--Using CASE to change values of Y and N to Yes and No
SELECT
	SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM
	dbo.nashville_housing_data

--modify table to set SoldAsVacant from CASE
UPDATE dbo.nashville_housing_data
SET SoldAsVacant = 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

--checking OwnerSplitAddress, OwnerSplitSity, and OwnerSplitState were added to table
SELECT
	DISTINCT(SoldAsVacant)
FROM
	dbo.nashville_housing_data
--shows unique values reduced to only Yes or No


/**********Remove Duplicates**********/
/**********Not Generally Advised in SQL Production**********/
/**********Can Lead to Data Loss**********/

/**********Using CTE to Find Duplicates by Row Number**********/
--creating a temp table using Common Table E
WITH RowNumCTE AS(
SELECT
	*,
	ROW_NUMBER() OVER (
	PARTITION BY 
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
			UniqueID
		) row_num		
FROM
	dbo.nashville_housing_data
)
DELETE
FROM
	RowNumCTE
WHERE 
	row_num > 1

--checking removal of duplicate rows
WITH RowNumCTE AS(
SELECT
	*,
	ROW_NUMBER() OVER (
	PARTITION BY 
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
			UniqueID
		) row_num		
FROM
	dbo.nashville_housing_data
)
SELECT
	*
FROM
	RowNumCTE
WHERE 
	row_num > 1
ORDER BY PropertyAddress
--shows duplicate rows have been removed successfully



/**********Remove Unused Columns**********/
/**********Generally Used in Views**********/
/**********Not Generally Advised in SQL Production**********/
/**********Can Lead to Data Loss**********/

--removing columns that offer little value to dataset
ALTER TABLE
	dbo.nashville_housing_data
DROP COLUMN
	OwnerAddress,
	SaleDate,
	TaxDistrict,
	PropertyAddress,
	LegalReference,

ALTER TABLE
	dbo.nashville_housing_data
DROP COLUMN
	OwnerName

--checking removal of columns
SELECT
	*
FROM
	dbo.nashville_housing_data
--shows columns were removed successfully