create database zad_graf
go
use zad_graf

-- tabele z wêz³ami

create table kategorie( id int identity,
	nazwa_kat nvarchar(30)
) as node

create table produkty (
	id int identity,
	nazwa_produktu nvarchar(30)
) as node

create table sprzedawcy (
	id int identity,
	nazwisko nvarchar(30)
) as node

create table klienci (
	id int identity,
	imie nvarchar(30)
) as node
go

insert into kategorie(nazwa_kat) values ('S³odycze'), ('Owoce'), ('Napoje')
insert into produkty(nazwa_produktu) values ('Krówka'),('Czekolada'),('Kitkat'),
('Jab³ka'),('Truskawki'),
('Pepsi'),('Sok'),('Woda')
insert into sprzedawcy(nazwisko) values ('Nowak'),('Kowalski')
insert into klienci(imie) values ('Kuba'),('Szymon'),('Monika'),('Asia'),('Kacper')

-- tabele z krawêdziami

go
create table w_kategorii (
	constraint produkt_kategoria connection (produkty to kategorie)
) as edge

create table zamowil (
	constraint klient_produkt connection (klienci to produkty)
) as edge

create table obslugiwal (
	constraint sprzedawca_klient connection (sprzedawcy to klienci)
) as edge

-- kto kogo obs³ugiwa³
go

insert into obslugiwal($from_id, $to_id) values (
	(select $node_id from sprzedawcy where nazwisko = 'Nowak'),
	(select $node_id from klienci where imie = 'Kuba')
),
(
	(select $node_id from sprzedawcy where nazwisko = 'Nowak'),
	(select $node_id from klienci where imie = 'Monika')
),
(
	(select $node_id from sprzedawcy where nazwisko = 'Nowak'),
	(select $node_id from klienci where imie = 'Asia')
),
(
	(select $node_id from sprzedawcy where nazwisko = 'Kowalski'),
	(select $node_id from klienci where imie = 'Szymon')
),
(
	(select $node_id from sprzedawcy where nazwisko = 'Kowalski'),
	(select $node_id from klienci where imie = 'Kacper')
)

-- jak¹ produkt ma kategorie

insert into w_kategorii($from_id, $to_id) values (
	(select $node_id from produkty where nazwa_produktu = 'Krówka'),
	(select $node_id from kategorie where nazwa_kat = 'S³odycze')
),
(
	(select $node_id from produkty where nazwa_produktu = 'Czekolada'),
	(select $node_id from kategorie where nazwa_kat = 'S³odycze')
),
(
	(select $node_id from produkty where nazwa_produktu = 'Kitkat'),
	(select $node_id from kategorie where nazwa_kat = 'S³odycze')
),
(
	(select $node_id from produkty where nazwa_produktu = 'Jab³ka'),
	(select $node_id from kategorie where nazwa_kat = 'Owoce')
),
(
	(select $node_id from produkty where nazwa_produktu = 'Truskawki'),
	(select $node_id from kategorie where nazwa_kat = 'Owoce')
),
(
	(select $node_id from produkty where nazwa_produktu = 'Pepsi'),
	(select $node_id from kategorie where nazwa_kat = 'Napoje')
),
(
	(select $node_id from produkty where nazwa_produktu = 'Sok'),
	(select $node_id from kategorie where nazwa_kat = 'Napoje')
),
(
	(select $node_id from produkty where nazwa_produktu = 'Woda'),
	(select $node_id from kategorie where nazwa_kat = 'Napoje')
)

-- jaki produkt zamówi³ klient
insert into zamowil($from_id, $to_id) values (
	(select $node_id from klienci where imie = 'Kuba'),
	(select $node_id from produkty where nazwa_produktu = 'Jab³ka')
),
(
	(select $node_id from klienci where imie = 'Szymon'),
	(select $node_id from produkty where nazwa_produktu = 'Krówka')
),
(
	(select $node_id from klienci where imie = 'Szymon'),
	(select $node_id from produkty where nazwa_produktu = 'Czekolada')
),
(
	(select $node_id from klienci where imie = 'Monika'),
	(select $node_id from produkty where nazwa_produktu = 'Kitkat')
),
(
	(select $node_id from klienci where imie = 'Monika'),
	(select $node_id from produkty where nazwa_produktu = 'Pepsi')
),
(
	(select $node_id from klienci where imie = 'Asia'),
	(select $node_id from produkty where nazwa_produktu = 'Czekolada')
),
(
	(select $node_id from klienci where imie = 'Asia'),
	(select $node_id from produkty where nazwa_produktu = 'Jab³ka')
),
(
	(select $node_id from klienci where imie = 'Asia'),
	(select $node_id from produkty where nazwa_produktu = 'Sok')
),
(
	(select $node_id from klienci where imie = 'Kacper'),
	(select $node_id from produkty where nazwa_produktu = 'Truskawki')
),
(
	(select $node_id from klienci where imie = 'Kacper'),
	(select $node_id from produkty where nazwa_produktu = 'Woda')
)

-- kategoria danego produktu
select p.nazwa_produktu, k.nazwa_kat 
from produkty p, kategorie k, w_kategorii w
where match(p-(w)->k)

-- pe³ny graf
select s.nazwisko, k.imie, p.nazwa_produktu, kt.nazwa_kat
from sprzedawcy s, klienci k, produkty p , kategorie kt,
obslugiwal o, zamowil z, w_kategorii w
where match(s-(o)->k) and match(k-(z)->p) and
match(p-(w)->kt)

-- klienci którzy zamówili min 3 produkty
select k.imie, p.nazwa_produktu, p1.nazwa_produktu, p2.nazwa_produktu
from klienci k, 
produkty p, produkty p1, produkty p2,
zamowil z, zamowil z1,zamowil z2 
where match(k-(z)->p) and match(k-(z1)->p1)
and match(k-(z2)->p2) and
p.id < p1.id and
p.id < p2.id and
p1.id < p2.id