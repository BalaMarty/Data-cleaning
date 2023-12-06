/* Cleaning data */
select * from NashvilleHousing

---Standardize date format

select SalesDateConverted ,convert(date,SaleDate)
from NashvilleHousing

update NashvilleHousing
set SalesDateConverted  = convert(date,SaleDate)

Alter table NashvilleHousing
add SalesDateConverted date

---Populate property address

select n1.ParcelID,n1.PropertyAddress,n2.ParcelID,n2.PropertyAddress
from NashvilleHousing n1 join NashvilleHousing n2
on n1.ParcelID = n2.ParcelID and n1.[UniqueID ]<>n2.[UniqueID ]
where n1.PropertyAddress is null

update n1
set PropertyAddress = ISNULL(n1.PropertyAddress,n2.PropertyAddress)
from NashvilleHousing n1 join NashvilleHousing n2
on n1.ParcelID = n2.ParcelID and n1.[UniqueID ]<>n2.[UniqueID ]

---Breaking out Address into Individual columns (Address,City)

select PropertyAddress,SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+2,LEN(PropertyAddress)-(CHARINDEX(',',PropertyAddress)+1)) as city
from NashvilleHousing

Alter table NashvilleHousing
add PropertySplitAddress varchar(100)

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


Alter table NashvilleHousing
add PropertySplitCity varchar(100)

Update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+2,LEN(PropertyAddress)-(CHARINDEX(',',PropertyAddress)+1))


select * from NashvilleHousing


select OwnerAddress,
PARSENAME(Replace(OwnerAddress,',','.'),3) as Address,
PARSENAME(Replace(OwnerAddress,',','.'),2) as City,
PARSENAME(Replace(OwnerAddress,',','.'),1) as State
from NashvilleHousing


Alter table NashvilleHousing
add OwnerSplitAddress varchar(100)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3) 

Alter table NashvilleHousing
add OwnerSplitCity varchar(100)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2) 

Alter table NashvilleHousing
add OwnerSplitState varchar(100)

update NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

select * from NashvilleHousing 


---- change Y and N to yes and No in 'Sold in vacant'



Select distinct(SoldAsVacant),count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant

update NashvilleHousing
set SoldAsVacant= case when SoldAsVacant = 'Y' Then 'Yes'
					   when SoldAsVacant = 'N' Then 'No' 
					   ELSE SoldAsVacant
					   END 


select * from NashvilleHousing

---remove duplicates

with rowCte as(
select *,ROW_NUMBER() over(
Partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference order by UniqueID) rowN
from NashvilleHousing)
Delete from rowCte
where rowN > 1


---Remove Unused data

select * from NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress

alter table NashvilleHousing
drop column PropertyAddress,SaleDate,TaxDistrict