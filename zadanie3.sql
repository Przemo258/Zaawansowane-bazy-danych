create database test
go
use test
go


-- zadanie stworzy� nast�puj�ce drzewo
-- kontynent
-- -kraj
-- --miasto
-- ---ulica

create table zadanie (hierarchia hierarchyid, nazwa nvarchar(60))

go

insert into zadanie (hierarchia, nazwa) values
-- kontynenty
('/1/', 'Afryka'),
('/2/', 'Ameryka Po�udniowa'),
('/3/', 'Ameryka P�nocna'),
('/4/', 'Australia'),
('/5/', 'Europa'),
('/6/', 'Azja'),
-- kraje
--europa
('/5/1/', 'Polska'),
('/5/2/', 'Niemcy'),
('/5/3/', 'Francja'),
('/5/4/', 'Wielka Brytania'),
-- ameryka p�nocna
('/3/1/', 'Stany Zjednoczone'),
('/3/2/', 'Kanada'),
('/3/3/', 'Meksyk'),
-- miasta
-- Polska
('/5/1/1/', 'Warszawa'),
('/5/1/2/', 'Katowice'),
('/5/1/3/', 'Wroc�aw'),
('/5/1/4/', 'Sosnowiec'),
-- Niemcy
('/5/2/1/', 'Berlin'),
('/5/2/1/', 'Monachium'),
('/5/2/1/', 'Kolonia'),
-- ulice
('/5/1/1/1/', 'Polna'),
('/5/1/1/2/', 'Le�na'),
('/5/1/2/1/', 'Ogrodowa'),
('/5/1/2/2/', 'Zmakowa')

go

select *, hierarchia.ToString() as 'Hierarchia' from zadanie

-- 1. wy�wietli� ca�� ga�� drzewa (od korzenia do wybranego li�cia tj ulicy))
declare @lisc hierarchyid
declare @i int = 0
declare @res table(hier hierarchyid)

select @lisc = z.hierarchia from zadanie z
where nazwa = 'Polna'

while @i < @lisc.GetLevel()
begin
	insert into @res (hier) 
		select @lisc.GetAncestor(@i)
	set @i = @i + 1
end

select * from zadanie z where z.hierarchia in (select hier from @res)
order by z.hierarchia

go
-- 2. doda� nowy kraj (dla ch�tnych sprawdzi� czy taki li�� juz istnieje)

declare @idkraj hierarchyid = '/5/5/' 
-- '/5/4/' nie zadzia�a bo ju� taki jest (Wielka Brytania) 
declare @nazwakraj nvarchar(60) = 'Holandia'

if exists (select * from zadanie z where z.hierarchia = @idkraj or z.nazwa = @nazwakraj)	
	throw 69420, 'Taki kraj ju� istnieje', 16
else
	insert into zadanie (hierarchia, nazwa) values (@idkraj, @nazwakraj)

select *, hierarchia.ToString() from zadanie
order by hierarchia.ToString()
go

-- 3. wy�wietli� nazw� kontynentu na kt�rym le�y miasto 'x'
declare @idMiasta hierarchyid = (select z.hierarchia from zadanie z where z.nazwa = 'Warszawa')
select z.nazwa from zadanie z where z.hierarchia = @idMiasta.GetAncestor(2)

go
-- 4. wy�wietli� wszystkie nazwy kraj�w
select z.nazwa from zadanie z where z.hierarchia.GetLevel() = 2

go
-- 5. sprawdzi� czy miasto 'x' le�y na kontynencie 'y'
declare @miasto hierarchyid = (select z.hierarchia from zadanie z where z.nazwa = 'Warszawa')
declare @kontynent hierarchyid = (select z.hierarchia from zadanie z where z.nazwa = 'Azja')

if(@miasto.IsDescendantOf(@kontynent) = 1)
	select 'tak'
else
	select 'nie'

go
-- 6. czy 'x' i 'y' s� krajami

declare @x hierarchyid = (select z.hierarchia from zadanie z where z.nazwa = 'Niemcy')
declare @y hierarchyid = (select z.hierarchia from zadanie z where z.nazwa = 'Polska')

if (@x.GetLevel() = 2 and @y.GetLevel() = 2)
	select 'tak'
else
	select 'nie' 

go
-- 7. wy�wietli� wszystkie ulice miasta 'x'
declare @miasto hierarchyid = (select z.hierarchia from zadanie z where z.nazwa = 'Warszawa')
select z.nazwa from zadanie z
where z.hierarchia.IsDescendantOf(@miasto) = 1 and 
z.hierarchia.GetLevel() = 4

-- 8* odpowiedzie� na te same pytania (nie trzeba wszystkich) bez typu hierarhicznego

create table kontynenty (id_kontynentu int primary key identity,
	nazwa nvarchar(60)
)
go
create table kraje (id_kraju int primary key identity,
	nazwa nvarchar(60),
	id_kontynentu int foreign key references kontynenty(id_kontynentu)
)
go
create table miasta (id_miasta int primary key identity,
	nazwa nvarchar(60),
	id_kraju int foreign key references kraje(id_kraju)
)
go
create table ulice (id_ulicy int primary key identity,
	nazwa nvarchar(60),
	id_miasta int foreign key references miasta(id_miasta)
)

go

insert into kontynenty (nazwa) values ('Afryka'),('Ameryka P�nocna'),
('Australia'),('Europa'),('Azja')

insert into kraje (nazwa, id_kontynentu) values ('Polska',4),('Niemcy',4),('Francja',4),
('Stany Zjednoczone',2),('Kanada',2),('Meksyk',2)

insert into miasta (nazwa, id_kraju) values ('Warszawa',1),('Katowice',1),('Sosnowiec',1),
('Berlin',2),('Monachium',2),('Kolonia',2)

insert into ulice (nazwa, id_miasta) values ('Polna',1),('Le�na',1),
('Ogrodowa',2),('Zmkowa',2),('Zmy�lona',3),('Inna',3)

go

select * from kontynenty
select * from kraje
select * from miasta
select * from ulice

-- wg mnie wszystkie rozwiazania bez korzystania z typu hierarchicznego s� du�o lepsze

-- 1. wy�wietli� ca�� ga�� drzewa (od korzenia do wybranego li�cia tj ulicy))
select ko.nazwa 'kontynent', kr.nazwa 'kraj', m.nazwa 'miasto', u.nazwa 'ulica'
from ulice u
join miasta m on m.id_miasta = u.id_miasta
join kraje kr on kr.id_kraju = m.id_kraju
join kontynenty ko on ko.id_kontynentu = kr.id_kontynentu
where u.nazwa = 'Le�na'

-- 2. doda� nowy kraj (dla ch�tnych sprawdzi� czy taki li�� juz istnieje)
if 'Egipt' not in (select nazwa from kraje)
insert into kraje (nazwa, id_kontynentu) values ('Egipt',1)

select * from kraje

-- 5. sprawdzi� czy miasto 'x' le�y na kontynencie 'y'
select m.nazwa 'miasto', ko.nazwa 'kontynent',
	iif(ko.nazwa = 'Australia', 'Tak', 'Nie') 'W australii?' from miasta m
join kraje kr on kr.id_kraju = m.id_kraju
join kontynenty ko on ko.id_kontynentu = kr.id_kontynentu
where m.nazwa = 'Sosnowiec'

-- 3,4,6,7 s� banalne wi�c je pomijam

drop database test