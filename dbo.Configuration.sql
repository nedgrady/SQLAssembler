DROP TABLE IF EXISTS dbo.Configuration
GO
CREATE TABLE dbo.Configuration
(
	Name nvarchar(100) PRIMARY KEY CLUSTERED,
	Setting sql_variant,
	Description nvarchar(max)
)
GO
CREATE OR ALTER FUNCTION dbo.fnConfig
(
	@Name nvarchar(100)
)
RETURNS sql_variant
AS
BEGIN
	RETURN
	(
		SELECT	Setting
		FROM	dbo.Configuration
		WHERE	Name = @Name
	)
END
GO
CREATE OR ALTER FUNCTION dbo.fnConfigInt
(
	@Name nvarchar(100)
)
RETURNS int
AS
BEGIN
	RETURN CONVERT(int, dbo.fnConfig(@Name))
END
GO
INSERT	dbo.Configuration
(
	Name,
	Setting,
	Description
)
SELECT	N'Max Memory', 100000, N'Maximum number of numbers the memory can store. Addressable from 0 - (max-1)'