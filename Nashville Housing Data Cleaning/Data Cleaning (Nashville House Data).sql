SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------
-- Standardize Date Format
SELECT sale_date_converted, CONVERT(Date,sale_date)
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET sale_date = CONVERT(Date,sale_date)

-- or (alternative method)

ALTER TABLE NashvilleHousing
ADD sale_date_converted Date;

UPDATE NashvilleHousing
SET sale_date_converted = CONVERT(Date,sale_date)
 ------------------------------------------------------------------------------------------------------------
-- Populate Property Address data
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--Where property_address is null
ORDER BY parcel_id

SELECT a.parcel_id, a.property_address, b.parcel_id, b.property_address, ISNULL(a.property_address,b.property_address)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.parcel_id = b.parcel_id
	AND a.[unique_id ] <> b.[unique_id ]
WHERE a.property_address IS NULL

UPDATE a
SET property_address = ISNULL(a.property_address,b.property_address)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.parcel_id = b.parcel_id
	AND a.[unique_id ] <> b.[unique_id ]
WHERE a.property_address IS NULL
-------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)
SELECT property_address
FROM PortfolioProject.dbo.NashvilleHousing
--Where property_address is null
--order by parcel_id

SELECT
SUBSTRING(property_address, 1, CHARINDEX(',', property_address) -1 ) as Address
, SUBSTRING(property_address, CHARINDEX(',', property_address) + 1 , LEN(property_address)) as Address

FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD property_split_address Nvarchar(255);

UPDATE NashvilleHousing
SET property_split_address = SUBSTRING(property_address, 1, CHARINDEX(',', property_address) -1 )

ALTER TABLE NashvilleHousing
ADD property_split_city Nvarchar(255);

UPDATE NashvilleHousing
SET property_split_city = SUBSTRING(property_address, CHARINDEX(',', property_address) + 1 , LEN(property_address))

SELECT *
From PortfolioProject.dbo.NashvilleHousing

SELECT owner_address
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(owner_address, ',', '.') , 3)
,PARSENAME(REPLACE(owner_address, ',', '.') , 2)
,PARSENAME(REPLACE(owner_address, ',', '.') , 1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD owner_split_address Nvarchar(255);

UPDATE NashvilleHousing
SET owner_split_address = PARSENAME(REPLACE(owner_address, ',', '.') , 3)

ALTER TABLE NashvilleHousing
ADD owner_split_city Nvarchar(255);

UPDATE NashvilleHousing
SET owner_split_city = PARSENAME(REPLACE(owner_address, ',', '.') , 2)

ALTER TABLE NashvilleHousing
ADD owner_split_state Nvarchar(255);

UPDATE NashvilleHousing
SET owner_split_state = PARSENAME(REPLACE(owner_address, ',', '.') , 1)


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
-------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(sold_as_vacant), COUNT(sold_as_vacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY sold_as_vacant
ORDER BY 2

SELCT sold_as_vacant
, CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
	   WHEN sold_as_vacant = 'N' THEN 'No'
	   ELSE sold_as_vacant
	   END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET sold_as_vacant = CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
	   WHEN sold_as_vacant = 'N' THEN 'No'
	   ELSE sold_as_vacant
	   END
-------------------------------------------------------------------------------------------------------------
-- Remove Duplicates
WITH row_num_CTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY parcel_id,
				 property_address,
				 sale_price,
				 sale_date,
				 legal_reference
				 ORDER BY
					unique_id
					) row_num

FROM PortfolioProject.dbo.NashvilleHousing
--order by parcel_id
)
SELECT *
FROM row_num_CTE
WHEN row_num > 1
ORDER BY property_address

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
---------------------------------------------------------------------------------------------------------
-- Delete Unused Columns
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN owner_address, tax_district, property_address, sale_date
-----------------------------------------------------------------------------------------------
