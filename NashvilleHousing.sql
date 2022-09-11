/* Cleaning Data in SQL Queries */

select*
from PortfolioProject.dbo.NashvilleHousing


-- Standardize DATE ormat
select SaleDateConverted,CONVERT(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing 
SET SaleDate = CONVERT(Date, SaleDate)


Alter Table NashvilleHousing 
Add SaleDateConverted Date; 

update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property addressData
select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null

select a.ParcelID,a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID]

update a
SET propertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID]
where a.propertyAddress is null

-- Breaking out address into individual columns ( Address, City, States)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as City
from PortfolioProject.dbo.NashvilleHousing


Alter Table NashvilleHousing 
Add PropertySplitAddress Nvarchar(255); 

update NashvilleHousing
SET PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Alter Table NashvilleHousing 
Add PropertySplitCity Nvarchar(255); 

update NashvilleHousing
SET PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

--Splitting Owner Address
select *
from PortfolioProject.dbo.NashvilleHousing

select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
from PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing 
Add OwnerSplitAddress Nvarchar(255); 

update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

Alter Table NashvilleHousing 
Add OwnerSplitCity Nvarchar(255); 

update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)


Alter Table NashvilleHousing 
Add OwnerSplitState Nvarchar(255); 

update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

select *
from PortfolioProject.dbo.NashvilleHousing

--Change Y and N to esand No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END

-- Remove Duplicates

With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

from PortfolioProject.dbo.NashvilleHousing
)

select *
--delete
From RowNumCTE
where row_num > 1
order by PropertyAddress

--Delete unused columns


select *
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP Column OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP Column SaleDate
