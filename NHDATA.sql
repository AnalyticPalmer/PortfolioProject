SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[NHDATA]


------------------------------------------------------------------
  --Cleaning Housing Data 

  Select	*
  From	PortfolioProject.dbo.NHDATA

------------------------------------------------------------------
  --Standardize Sale Date 

  Select	SaleDate, CONVERT(Date,SaleDate)
  From	PortfolioProject.dbo.NHDATA

  Alter Table NHDATA
  Add SalesDate Date; 

  Update	NHDATA
  Set	SalesDate = Convert(Date,SaleDate)

  Select	SalesDate, CONVERT(Date,SaleDate)
  From	PortfolioProject.dbo.NHDATA

-----------------------------------------------------------------
  --Pouplated Property Address

  Select	PropertyAddress
  From	PortfolioProject.dbo.NHDATA

   Select	*
  From	PortfolioProject.dbo.NHDATA
  Where PropertyAddress is NULL

  Select	*
  From	PortfolioProject.dbo.NHDATA
  Order By ParcelID

  Select	a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
  From	PortfolioProject.dbo.NHDATA a
  JOIN PortfolioProject.dbo.NHDATA b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
  Where a.PropertyAddress is null

 SELECT a.ParcelID, 
       ISNULL(a.PropertyAddress, b.PropertyAddress) AS PropertyAddress 
FROM PortfolioProject.dbo.NHDATA a
JOIN PortfolioProject.dbo.NHDATA b ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NHDATA a
JOIN PortfolioProject.dbo.NHDATA b ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


-----------------------------------------------------------------------------------
--Breaking Address into individual columns ( address, state, city)

Select PropertyAddress
From PortfolioProject.dbo.NHDATA

SELECT 
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address_Part1,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address_Part2
FROM PortfolioProject.dbo.NHDATA;

Alter Table PortfolioProject.dbo.NHDATA
  Add PropertyAdd nvarchar(255); 

  Update	PortfolioProject.dbo.NHDATA
  Set	PropertyAdd = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


  Alter Table PortfolioProject.dbo.NHDATA
  Add PropertyAddCity nvarchar(255); 

  Update	PortfolioProject.dbo.NHDATA
  Set	PropertyAddCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

  SELECT *
  FROM PortfolioProject.dbo.NHDATA


  SELECT OwnerAddress
  FROM PortfolioProject.dbo.NHDATA

  SELECT 
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) ,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) ,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 
FROM PortfolioProject.dbo.NHDATA;


Alter Table PortfolioProject.dbo.NHDATA
  Add OwnerAdd nvarchar(255); 

  Update	PortfolioProject.dbo.NHDATA
  Set	OwnerAdd =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 


  Alter Table PortfolioProject.dbo.NHDATA
  Add OwnerAddCity nvarchar(255); 

  Update	PortfolioProject.dbo.NHDATA
  Set	OwnerAddCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 



    Alter Table PortfolioProject.dbo.NHDATA
  Add OwnerAddState nvarchar(255); 

  Update	PortfolioProject.dbo.NHDATA
  Set	OwnerAddState =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 


-------------------------------------------------------------------------------
--Change Y and N to Yes and No in 'Sold As Vacant' Field

  Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
  FROM PortfolioProject.dbo.NHDATA
  GROUP BY SoldAsVacant
  ORDER BY 2


  SELECT SoldAsVacant,
  CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
  FROM PortfolioProject.dbo.NHDATA


  UPDATE PortfolioProject.dbo.NHDATA
  SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END


--------------------------------------------------------------------------
--Remove Duplictaes


WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY
				UniqueID
				) row_num
FROM PortfolioProject.dbo.NHDATA
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY
				UniqueID
				) row_num
FROM PortfolioProject.dbo.NHDATA
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress




------------------------------------------------------------------
--Delete Unused Column


SELECT *
FROM PortfolioProject.dbo.NHDATA


ALTER TABLE PortfolioProject.dbo.NHDATA
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NHDATA
DROP COLUMN SaleDate

