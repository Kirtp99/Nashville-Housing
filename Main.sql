-- Cleaning Data using SQL queries

Select *
From [Nashville Housing]..NashvilleHousing


--- Standardise Date Format

Select SaleDate, CONVERT(Date, SaleDate)
From [Nashville Housing]..NashvilleHousing

--Alter Table NashvilleHousing
--Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted
From [Nashville Housing]..NashvilleHousing



--- Polpulate Property Address Data

Select *
From [Nashville Housing]..NashvilleHousing
-- Where PropertyAddress is null
order by ParcelID

-- Same parcel ID will mean the same property address (fill in null values)

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Nashville Housing]..NashvilleHousing a
JOIN [Nashville Housing]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Populate the null value using reference (update the table)

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Nashville Housing]..NashvilleHousing a
JOIN [Nashville Housing]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Check for null value in property address

Select *
From [Nashville Housing]..NashvilleHousing
Where PropertyAddress is null


--- Splitting up property address into individual columns (Street, City)

Select PropertyAddress
From [Nashville Housing]..NashvilleHousing

-- Delimeter for property address is a ,

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From [Nashville Housing]..NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);
Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);
Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


-- Check for columns

Select *
From [Nashville Housing]..NashvilleHousing


--- Splitting up owner address into individual columns (Street, City, State)

Select OwnerAddress
From [Nashville Housing]..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Street
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
From [Nashville Housing]..NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitStreet Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)




--- Change Y and N to Yes and no respectively in Sold as vacant field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From [Nashville Housing]..NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   else SoldAsVacant
	   END
From [Nashville Housing]..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
				   When SoldAsVacant = 'N' THEN 'No'
				   else SoldAsVacant
				   END


--- Remove Duplicates

WITH RowNumCTE as(

Select *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER by UniqueID
				 ) row_num
From [Nashville Housing]..NashvilleHousing
--order by ParcelID
)
Select *
--Delete
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



--- Delete Unused Columns

Select *
From [Nashville Housing]..NashvilleHousing


ALTER TABLE [Nashville Housing]..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate

