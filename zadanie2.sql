-- 1. Utworzy� baz� danych obs�uguj�c� FileTable
create database baza
	on PRIMARY (name = 'Main', filename = 'C:\SQL_Data\main.mdf'),
	FILEGROUP fs contains filestream default
		(name = 'FS', filename = 'C:\SQL_Data\FS')
	log on (name = 'log', filename = 'C:\SQL_Data\main_log.ldf')
	with filestream( NON_TRANSACTED_ACCESS = FULL, DIRECTORY_NAME = 'files')


-- 2. Utworzy� tabel� wykorzystuj�c� FileTable
go
use baza

create table przemek as filetable
select * from przemek

-- 3. skopiowanie istniej�cych plik�w i katalog�w

-- foldery
insert into przemek (name, is_directory) values ('folder1', 1)
exec dbo.insert_into_dir 'folder2', 'folder1', null, 1
exec dbo.insert_into_dir 'folder3', 'folder2', null, 1

-- pliki word
declare @dane_word varbinary
select @dane_word = BulkColumn from 
	openrowset(bulk 'C:\SQL_Data\Copy\word.docx', SINGLE_BLOB) tmp

insert into przemek (name, file_stream) values ('word1.docx', @dane_word)
exec dbo.insert_into_dir 'word2.docx', 'folder1', @dane_word
exec dbo.insert_into_dir 'word3.docx', 'folder2', @dane_word
exec dbo.insert_into_dir 'word4.docx', 'folder3', @dane_word

-- pliki excel
declare @dane_excel varbinary
select @dane_excel = BulkColumn from 
	openrowset(bulk 'C:\SQL_Data\Copy\excel.xlsx', SINGLE_BLOB) tmp

insert into przemek (name, file_stream) values ('excel1.xlsx', @dane_excel)
exec dbo.insert_into_dir 'excel2.xlsx', 'folder3', @dane_excel

-- pliki txt
declare @dane_txt varbinary
select @dane_txt = BulkColumn from 
	openrowset(bulk 'C:\SQL_Data\Copy\text.txt', SINGLE_BLOB) tmp

exec dbo.insert_into_dir 'plik_txt1.txt', 'folder1', @dane_txt
exec dbo.insert_into_dir 'plik_txt2.txt', 'folder2', @dane_txt

select * from przemek

-- 4. Podmieni� zawarto�� 2 plik�w
-- tekstowego
update przemek 
set file_stream = cast(N'Nowa Zawarto��' as varbinary)
where name = 'plik_txt1.txt'

-- nie tekstowego
select name, file_stream from przemek where name = 'word1.docx' 

declare @dane varbinary(max)
select @dane = cast(BulkColumn as varbinary) from 
	openrowset(bulk 'C:\Users\Przemek\Desktop\tmp\nowy.docx', SINGLE_BLOB) x

update przemek 
set file_stream = @dane
where name = 'word1.docx'

select name, file_stream from przemek where name = 'word1.docx'
-- zawarto�� zostaje podmieniona ale word i excel nie dzia�aj� (dane s� �le pobrane)


-- 5. Usun�� plik

delete from przemek
where name = 'excel1.xlsx'


-- 6. Utworzy� procedur� zapisuj�c� pliki do podkatalogu
go
create procedure dbo.insert_into_dir @filename nvarchar(100),
	@dirName nvarchar(100), @binary varbinary(max), @isDir BIT = 0
as
	begin
		
		declare @sciezka_katalogu hierarchyid
		declare @nowa_sciezka varchar(max)

		select @sciezka_katalogu = path_locator
		from przemek where name = @dirName

		
		if @sciezka_katalogu is null throw 69420, 'This directory does not exist', 16

		select @nowa_sciezka = @sciezka_katalogu.ToString() + 
		convert(varchar(20), convert(bigint,substring(convert(binary(16), newid()), 1,6))) +
		'.' +
		convert(varchar(20), convert(bigint,substring(convert(binary(16), newid()), 7,6))) +
		'.' +
		convert(varchar(20), convert(bigint,substring(convert(binary(16), newid()), 13,4))) +
		'/'

		insert into przemek (name, path_locator, file_stream, is_directory)
		values (@filename, @nowa_sciezka, @binary, @isDir)
	end