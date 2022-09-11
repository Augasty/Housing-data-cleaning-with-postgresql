--CLEAINING DATA IN SQL QUERIES

select * from public.nashville

--STANDARDIZE DATE FORMAT
select saledate, to_date(saledate,'Month DD, YYYY')
from public.nashville n 

update nashville 
set saledate = to_date(saledate,'Month DD, YYYY')

--populate empty property address data by checking same parceid 
select *
from public.nashville n 
where propertyaddress = '' 
order by parcelid 

update nashville 
set propertyaddress = null 
where propertyaddress = '' 


select a.parcelid , a.propertyaddress , b.parcelid , b.propertyaddress ,coalesce(a.propertyaddress,b.propertyaddress)
from public.nashville a join public.nashville b 
on a.parcelid = b.parcelid 
and a."UniqueID " <> b."UniqueID " 
where a.propertyaddress is null


update public.nashville a
set propertyaddress = b.propertyaddress
from public.nashville b 
where a.parcelid = b.parcelid 
and a."UniqueID " <> b."UniqueID "
and a.propertyaddress is null

--breaking out address into individual columns (address, city, state)


select propertyaddress 
from public.nashville n
--order by parcelid 


select substring(propertyaddress,1,(strpos(propertyaddress,',')-1)) as address,  
substring(propertyaddress,(strpos(propertyaddress,',')+1), length(propertyaddress)) as town
from public.nashville n

alter table public.nashville 
add propertysplitaddress varchar(100), add propertysplitcity varchar(50)

update public.nashville 
set propertysplitaddress =  substring(propertyaddress,1,(strpos(propertyaddress,',')-1)) ,
propertysplitcity = substring(propertyaddress,(strpos(propertyaddress,',')+1), length(propertyaddress)) 

select propertyaddress , propertysplitaddress, propertysplitcity
from public.nashville n 


--spliting owner address 

select
split_part(owneraddress,',',1), 
split_part(owneraddress,',',2), 
split_part(owneraddress,',',3)
from public.nashville n  


alter table public.nashville 
add ownerstreet varchar(100),
add ownertown varchar(50),
add ownerstate varchar(50)

update public.nashville 
set ownerstreet = split_part(owneraddress,',',1),
ownertown = split_part(owneraddress,',',2),
ownerstate = split_part(owneraddress,',',3)

select owneraddress , ownerstreet, ownertown, ownerstate
from public.nashville n 



-- change Y and N to yes and no in sold as vacant field

select distinct(soldasvacant),count(soldasvacant) 
from public.nashville n 
group by soldasvacant 
order by 2

select soldasvacant ,
case when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant 
end
from public.nashville n 

update public.nashville 
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant 
end



update cards c
set position = c2.seqnum
    from (select c2.*, row_number() over () as seqnum
          from cards c2
         ) c2
    where c2.pkid = c.pkid

--remove duplicates
alter table public.nashville add row_num int


update public.nashville n1
set row_num = rn 
from(select n2.*, row_number() over(partition by propertyaddress , saleprice ,saledate ,
legalreference order by "UniqueID "  ) as rn from public.nashville n2) n2
where n2."UniqueID " =  n1."UniqueID " 

delete from public.nashville  where row_num > 1

select * from public.nashville 

--drop unused columns 
alter table public.nashville 
drop column owneraddress, drop column taxdistrict , drop column propertyaddress





