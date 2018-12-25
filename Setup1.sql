IF DB_ID(N'ASsembler') IS NULL
	CREATE DATABASE Assembler
GO
USE Assembler
DROP TABLE IF EXISTS Numbers
GO
CREATE TABLE dbo.Numbers
(
	Num int primary key clustered
)
GO
INSERT	dbo.Numbers
SELECT	TOP (100000) ROW_NUMBER() OVER (ORDER BY @@SPID)
FROM	sys.all_columns c1
	CROSS JOIN sys.all_columns c2
GO
	CREATE OR ALTER FUNCTION [dbo].[tfnChars]
(
	@str nvarchar(200),
	@Start int,
	@Chars int
)
RETURNS TABLE AS
RETURN
SELECT	TOP(@Chars) Num,
	SUBSTRING(@Str, Num, 1) [Char],
	ASCII(SUBSTRING(@Str, Num, 1)) [ASCII],
	UNICODE(SUBSTRING(@Str, Num, 1)) [UNICODE]
FROM	dbo.Numbers
WHERE	Num >= @Start
AND	Num < @Start + @Chars
ORDER BY	Num ASC
GO
CREATE OR ALTER FUNCTION [dbo].[tfnReplaceNonAlpha]
(
	@Str nvarchar(200),
	@Start int,
	@Chars int,
	@Replace char(1)
)
RETURNS TABLE
AS
RETURN
SELECT
(
	SELECT	CASE
			WHEN
			(
				(LOWER(C.Char) NOT BETWEEN 'a' AND 'z') AND
				(C.Char NOT BETWEEN '0' AND '9')
			) THEN @Replace
			ELSE C.Char
		END
	FROM	tfnChars(@Str, @Start, @Chars) C
	FOR	XML PATH ('')
) AS [Str]