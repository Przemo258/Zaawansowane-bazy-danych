-- tworzenie bazy i tabeli

create database zad_json;

use zad_json;

create table zadanie  (
	id int identity primary key,
	opis nvarchar(max)
)

-- wstawianie danych xml
declare @dane nvarchar(max);

select @dane = BulkColumn from openrowset
(bulk 'C:\Users\Przemek\OneDrive\Semestr 2\Zaawansowane bazy danych\zaj�cia 10\order1.json',
SINGLE_CLOB) x

declare @dane1 nvarchar(max);

select @dane1 = BulkColumn from openrowset
(bulk 'C:\Users\Przemek\OneDrive\Semestr 2\Zaawansowane bazy danych\zaj�cia 10\order2.json',
SINGLE_CLOB) x

declare @dane2 nvarchar(max);

select @dane2 = BulkColumn from openrowset
(bulk 'C:\Users\Przemek\OneDrive\Semestr 2\Zaawansowane bazy danych\zaj�cia 10\order3.json',
SINGLE_CLOB) x

declare @dane3 nvarchar(max);

select @dane3 = BulkColumn from openrowset
(bulk 'C:\Users\Przemek\OneDrive\Semestr 2\Zaawansowane bazy danych\zaj�cia 10\order3.json',
SINGLE_CLOB) x

insert into zadanie (opis) values (@dane), (@dane1), (@dane2), (@dane3)

select * from zadanie 
go

-- daty z�o�enia zam�wie�
select 
	j.DataZam�wienia
from zadanie z
cross apply openjson(z.opis, '$.order') with (
	DataZam�wienia nvarchar(40) '$.orderDate'
) j

-- wy�wietlaj�ce informacje o zamawiaj�cych

select 
	Firma,
	Osoba_kontaktowa,
	Wojew�dztwo,
	Kod_pocztowy,
	Miasto,
	Ulica
from zadanie z
cross apply openjson(z.opis, '$.order.customer') with (
	Firma nvarchar(40) '$.company',
	Osoba_kontaktowa nvarchar(20) '$.contactname',
	Wojew�dztwo nvarchar(20) '$.address.state',
	Kod_pocztowy nvarchar(20) '$.address.zip',
	Miasto nvarchar(20) '$.address.city' ,
	Ulica nvarchar(20) '$.address.street'
) j


-- wy�wietlaj�ce informacje o zawarto�ci zam�wienia (co zawiera zam�wienie)

select 
	Nazwa,
	Kategoria,
	Opis_Kategorii,
	Cena,
	Liczba,
	Zni�ka
from zadanie z
cross apply openjson(z.opis, '$.order.orderitems.orderitem') with (
	Nazwa nvarchar(40) '$.product.productname',
	Kategoria nvarchar(40) '$.product.category.categoryname',
	Opis_Kategorii nvarchar(40) '$.product.category.description',
	Cena float '$.unitprice',
	Liczba float '$.quantity',
	Zni�ka float '$.discount'
) j

-- wyszukuj�ce zam�wienia wysy�ane do konkretnej lokalizacji (np. miasta)

select 
	Firma,
	Osoba_kontaktowa,
	Wojew�dztwo,
	Kod_pocztowy,
	Miasto,
	Ulica
from zadanie z
cross apply openjson(z.opis, '$.order.customer') with (
	Firma nvarchar(20) '$.company',
	Osoba_kontaktowa nvarchar(20) '$.contactname',
	Wojew�dztwo nvarchar(20) '$.address.state',
	Kod_pocztowy nvarchar(20) '$.address.zip',
	Miasto nvarchar(20) '$.address.city',
	Ulica nvarchar(20) '$.address.street'
) j
where j.Miasto = 'Katowice'

-- uzupe�niaj�ce wybrane zam�wienie o dodatkow� zawarto�� (dodatkowy xml)

update zadanie
set opis = json_modify(zadanie.opis, '$.order.employee.address.apartamentnumber', 5)
where json_value(zadanie.opis, '$.order.employee.firstname') = 'Jan'

select 
	Name,ApartamentNumber
from zadanie z
cross apply openjson(z.opis, '$.order.employee') with (
	Name nvarchar(20) '$.firstname',
	ApartamentNumber int '$.address.apartamentnumber'
) j