
-- Cleaning Data in SQL Queries

Select *
From PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------

-- Standardize Data Format

Select NewDateFormat, convert(date, SaleDate) as NewDateFormat
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add NewDateFormat date;

Update NashvilleHousing
Set NewDateFormat = convert(date, SaleDate)

----------------------------------------------------------------------------------------

--Populate Property Address Data

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
inner join PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a -- Replacing NULL values in the PropertyAddress column in table a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
inner join PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

----------------------------------------------------------------------------------------

--Breaking out address into individual columns (Address, City, State)

Select -- Preliminary splitting of a string into an address and a city using a Substring
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, Len(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1
, Len(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing




Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select -- Splitting the OwnerAddress column using PARSENAME
PARSENAME(Replace(OwnerAddress,',', '.'),3)
, PARSENAME(Replace(OwnerAddress,',', '.'),2)
, PARSENAME(Replace(OwnerAddress,',', '.'),1)
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',', '.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',', '.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',', '.'),1)

Select *
From PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------

-- Change Y and N to Yes and No is "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	else SoldAsVacant
	End
From PortfolioProject..NashvilleHousing
Order by SoldAsVacant

Update NashvilleHousing
Set SoldAsVacant = 
Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	else SoldAsVacant
End

----------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE as (
Select*,
	ROW_NUMBER() Over(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By  UniqueID
				 ) as Row_Num
From PortfolioProject..NashvilleHousing
--Order by ParcelID
)
Delete
From RowNumCTE
Where Row_Num > 1
--Order by PropertyAddress

----------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject..NashvilleHousing
Drop Column SaleDate