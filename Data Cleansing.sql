

--------------------------------------------------------------------------------------------------------------------
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--1) Standardise Data Format
--|\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--------------------------------------------------------------------------------------------------------------------
	--overview of data
	Select*
	From PortfolioProject..NVHousing
	
	
	-- a)Date -------------------------------------------------------------------------------------------------------
		-- b) use CONVERT(to datatype,Column) to convet from current(date-time) format
		-- to date format. (This is applied to the view)
	Select SaleDate, CONVERT(Date,SaleDate)
	From PortfolioProject.dbo.NVHousing

		--updating SaleDate in the DB with new format
	
	ALTER TABLE NVHousing ALTER COLUMN SaleDate Date;

		-- Alternatively

		ALTER TABLE NVHousing
		Add SaleDateConverted Date;

		Update NVHousing
		SET SaleDateConverted = CONVERT(Date,SaleDate)



	-- b)Breaking Popertyaddress sub-fields into individual columns----------------------------------------------------------


		-- SUBSTRING(SRING,idx of 1st char, idx of last char)
		-- Select the substring of propertAddress entry that includes all characters from 
		--... the 1st to the character before the comma and give it alias Address

		-- Select the substring of propertAddress entry that includes all characters from 
		--...the character after to comma to he last character and give it alias City
	SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
	, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as City
	From PortfolioProject.dbo.NVHousing


		-- Add city column to database to include address portion of the PropertyAddress
		-- Update PropertyAddress column in database to only include city portion of the PropertyAddress
		-- add colmn first
	ALTER TABLE PortfolioProject.dbo.NVHousing
	ADD City Nvarchar(255);
		-- then alter column
	Update PortfolioProject.dbo.NVHousing
	SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
	,PropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )
	

	-- c)Breaking OwnerAddress sub-fields into individual columns----------------------------------------------------------
		-- Returns the specified part of an object name. The parts of an object that can be retrieved are the object name,
		--... schema name, database name, and server name.
		--1 for object name, 2 for schema name, 3 for databasename, 4 for servername
		-- objects paths are delimited by '.' so commas in our address need to be replaced

	Select OwnerAddress
	From PortfolioProject.dbo.NVHousing

	
	-- create in view
	Select
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) AS OwnerAddress
	,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) AS OwnerCity
	,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) AS OwnerState
	From PortfolioProject.dbo.NVHousing nv


	ALTER TABLE nv
	DROP COLUMN IF EXISTS OwnerState, OwnerCity
	
	--create columns in existing database and alter the exisiting OwnerAddress
	ALTER TABLE PortfolioProject.dbo.NVHousing -- PortfolioProject.dbo.NVHousing 
	Add OwnerCity Nvarchar(255) ,
		OwnerState Nvarchar(255);
		
	
	Update PortfolioProject.dbo.NVHousing
	SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
		,OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
		,OwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
		
	
	

	
	-- b) change y/n to yes/no in 'Sold As Vacant Field ----------------------------------------------------------


	SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
	FROM PortfolioProject.dbo.NVHousing
	Group by SoldAsVacant
	order by 2



	-- create in view
	SELECT SoldAsVacant
	, CASE WHEN SoldAsVacant = 'N' THEN 'No' 
	   WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   ELSE SoldAsVacant
	   END
	FROM PortfolioProject.dbo.NVHousing

	-- update exisiting database with changes
	UPDATE PortfolioProject.dbo.NVHousing
	SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END





--------------------------------------------------------------------------------------------------------------------
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--2)  Populate data values that is left blank  though use of matching values in other entries
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--------------------------------------------------------------------------------------------------------------------
	-- a) Populate property Address data left blank----------------------------------------------------------------

	-- Using ISNULL(value1, value to return) to return a the property address of corresponding to the parcelID if the unique ID is different but parcel ID is the same
	-- two instances a,b of he same table are joined on equivolcal parcelID and non-equivocal Unique ID.
	-- This is done because parcel id corresponds to Property Address, so if parcel id is  the same address must be the same even if it has been left blank
	-- Unique

	Select  T1.[ParcelID]
	FROM PortfolioProject.dbo.NVHousing T1, PortfolioProject.dbo.NVHousing T2
	--Where PropertyAddress is null
	WHERE T1.ParcelID = T2.ParcelID
	-- AND  T1.UniqueID <> T2.UniqueID
	
	Select *
	FROM PortfolioProject.dbo.NVHousing T1, PortfolioProject.dbo.NVHousing T2
	--Where PropertyAddress is null
	WHERE T1.ParcelID = T2.ParcelID
	-- AND  T1.UniqueID <> T2.UniqueID

	ORDER BY T1.UniqueID 

	SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
	FROM PortfolioProject.dbo.NVHousing a
	FULL OUTER JOIN PortfolioProject.dbo.NVHousing b
	ON a.ParcelID = b.ParcelID

	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is null

	
	Update a
	SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
	FROM PortfolioProject.dbo.NVHousing a
	JOIN PortfolioProject.dbo.NVHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--3)Change data types to desired
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--------------------------------------------------------------------------------------------------------------------

 --a)  Change data types 1) --------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--4) Remove Duplicates
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--------------------------------------------------------------------------------------------------------------------


-- a) Remove Duplicates 1---------------------------------------------------------------------------------------------
-- rolling sum of people vaccinated

-- sum (y): outputs 1 value to represent the sum of many value inputs
-- sum(y) over ( Partition x): 'OVER' specifies that that this function will run for each row in 'y'
	--   ...'PARTITION ' specifies that for each row in that partition x, the function will use all rows in the partion x
	-- ... as input to the function.
	-- ...>>> For partitions with muliple value expressions, the aggrigation is applied to to rows where the values of the value expressions are the same.<<<
-- sum(y) over ( Partition x order by z): for each row in partition x the function will execute in the order of z such that
-- by default -  the inputs to the function will be the current row value of y and the previous.


-- Using CTE- Common table expression to use a columns that is created later in the same query


	WITH RowNumCTE AS(
	Select *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID
				,PropertyAddress
				,SalePrice
				,SaleDate
				,LegalReference
				 ORDER BY
					UniqueID
					)AS row_num

	FROM PortfolioProject.dbo.NVHousing
	)
	SELECT *
	FROM RowNumCTE
	WHERE row_num > 1
	ORDER BY PropertyAddress



	SELECT *
	FROM PortfolioProject.dbo.NVHousing



--------------------------------------------------------------------------------------------------------------------
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	--5) Delete Unused Columns
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--------------------------------------------------------------------------------------------------------------------

-- a) Delete Unused Columns 1------------------------------------------------------------------------------------------

	Select *
	From PortfolioProject.dbo.NVHousing

	-- It is assumed that Tax district data will not be used for analysis for the purpose of this data cleansing. 
	-- In practice columns are not dropped unless with high level permissions. 
	-- Columns in a view can be dropped instead by first making a view.
	ALTER TABLE PortfolioProject.dbo.NVHousing
	DROP COLUMN  TaxDistrict

