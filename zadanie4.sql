-- tworzenie bazy i tabeli

create database zad_xml;

use zad_xml;

create table zadanie  (
	id int identity primary key,
	opis xml
)

-- wstawianie danych xml
declare @dane xml;

select @dane = cast(BulkColumn as xml) from openrowset
(bulk 'C:\Users\Przemek\OneDrive\Semestr 2\Zaawansowane bazy danych\zajêcia 9\order1.xml',
SINGLE_BLOB) x

declare @dane1 xml;

select @dane1 = cast(BulkColumn as xml) from openrowset
(bulk 'C:\Users\Przemek\OneDrive\Semestr 2\Zaawansowane bazy danych\zajêcia 9\order2.xml',
SINGLE_BLOB) x

declare @dane2 xml;

select @dane2 = cast(BulkColumn as xml) from openrowset
(bulk 'C:\Users\Przemek\OneDrive\Semestr 2\Zaawansowane bazy danych\zajêcia 9\order3.xml',
SINGLE_BLOB) x

declare @dane3 xml;

select @dane3 = cast(BulkColumn as xml) from openrowset
(bulk 'C:\Users\Przemek\OneDrive\Semestr 2\Zaawansowane bazy danych\zajêcia 9\order4.xml',
SINGLE_BLOB) x

insert into zadanie (opis) values (@dane), (@dane1), (@dane2), (@dane3)

select * from zadanie
go

-- daty z³o¿enia zamówieñ
select 
	OrderDate = item.row.value('orderDate[1]', 'nvarchar(20)')
from zadanie
cross apply opis.nodes('/order') item(row)

-- wyœwietlaj¹ce informacje o zamawiaj¹cych

select 
	Firma = item.row.value('company[1]', 'nvarchar(20)'),
	Osoba_kontaktowa = item.row.value('contactname[1]', 'nvarchar(20)'),
	Województwo = item.row.value('(address/state)[1]', 'nvarchar(20)'),
	Kod_pocztowy = item.row.value('(address/zip)[1]', 'nvarchar(20)'),
	Miasto = item.row.value('(address/city)[1]', 'nvarchar(20)'),
	Ulica = item.row.value('(address/street)[1]', 'nvarchar(20)')
from zadanie
cross apply opis.nodes('order/customer') item(row)


-- wyœwietlaj¹ce informacje o zawartoœci zamówienia (co zawiera zamówienie)

select 
	Nazwa = item.row.value('(product/productname)[1]', 'nvarchar(40)'),
	Kategoria = item.row.value('(product/category/categoryname)[1]', 'nvarchar(40)'),
	Opis_Kategorii = item.row.value('(product/category/description)[1]', 'nvarchar(40)'),
	Cena = item.row.value('(unitprice)[1]', 'float'),
	Liczba = item.row.value('(quantity)[1]', 'float'),
	Zni¿ka = item.row.value('(discount)[1]', 'float')
from zadanie 
cross apply opis.nodes('order/orderitems/orderitem') item(row)

-- wyszukuj¹ce zamówienia wysy³ane do konkretnej lokalizacji (np. miasta)

select 
	Firma = item.row.value('company[1]', 'nvarchar(20)'),
	Osoba_kontaktowa = item.row.value('contactname[1]', 'nvarchar(20)'),
	Województwo = item.row.value('(address/state)[1]', 'nvarchar(20)'),
	Kod_pocztowy = item.row.value('(address/zip)[1]', 'nvarchar(20)'),
	Miasto = item.row.value('(address/city)[1]', 'nvarchar(20)'),
	Ulica = item.row.value('(address/street)[1]', 'nvarchar(20)')
from zadanie
cross apply opis.nodes('order/customer') item(row)
where item.row.exist('address/city[.="Katowice"]') = 1

-- uzupe³niaj¹ce wybrane zamówienie o dodatkow¹ zawartoœæ (dodatkowy xml)

update zadanie
set opis.modify('insert <apartamentnumber>5</apartamentnumber> as last into
(order/employee/address)[1]')
where opis.exist('order/employee/firstname[.="Jan"]') = 1