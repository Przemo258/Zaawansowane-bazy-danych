use baza

create table przemek (fil_id int primary key identity,
id uniqueidentifier not null unique rowguidcol default newid(),
opis varchar(255),
dane varbinary(max) filestream)

checkpoint
select * from przemek

--dowolny plik tekstowy
insert into przemek (opis, dane) values ('pierwszy plik tekstowy',
cast('to jest dowolny plik' as varbinary(max)))

-- pusty plik
insert into przemek (opis, dane) 
values ('pusty plik', cast('' as varbinary(max)))

-- zdjecie
insert into przemek(dane)
(select * from openrowset(bulk 'C:\Dane\kopiuj\img.jpg', single_blob) dane)

-- tekstowy z zawartoscia
insert into przemek(dane)
(select * from openrowset(bulk 'C:\Dane\kopiuj\tekstowy.txt', single_blob) dane)

--pusty
insert into przemek(dane)
(select * from openrowset(bulk 'C:\Dane\kopiuj\pusty.txt', single_blob) dane)

-- zmiana pliku
UPDATE przemek
SET dane = CAST('Nowa zawartosc' AS VARBINARY(MAX))
WHERE fil_id = 1;

-- zmiana pliku nietekstowego
UPDATE przemek
SET dane = (select * from openrowset(bulk 'C:\Dane\kopiuj\img2.jpg', single_blob) dane)
WHERE fil_id = 3;

--usun plik
delete from przemek where fil_id = 3