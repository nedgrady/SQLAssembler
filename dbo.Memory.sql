DROP TABLE IF EXISTS dbo.MemoryItem
GO
CREATE TABLE dbo.MemoryItem
(
	Address int NOT NULL,
	Item int NOT NULL
)
GO
CREATE OR ALTER VIEW dbo.vwMemory
AS
SELECT	TOP (dbo.fnConfigInt(N'Max Memory')) N.Num AS Address,
	ISNULL(MI.Item, 0) AS Item
FROM	dbo.Numbers N
	LEFT JOIN dbo.MemoryItem MI ON MI.Address = N.Num
GO
CREATE OR ALTER PROCEDURE dbo.spMemCheck
	@Address int
AS
SET NOCOUNT, XACT_ABORT ON
IF(@Address < 0 OR @Address >= dbo.fnConfigInt(N'Max Memory'))
	RAISERROR (N'Error attempting to access memory location %d', 16, 0, @Address)

GO
CREATE OR ALTER PROCEDURE dbo.STR
	@Address int
AS
SET NOCOUNT ON

EXEC spMemCheck @Address

MERGE	dbo.MemoryItem AS Target
USING
(
	SELECT	dbo.fnTop(),
		@Address
) AS Source(Item, Address)
ON Target.Address = Source.Address
WHEN MATCHED THEN
	UPDATE
	SET	Target.Item = Source.item
WHEN NOT MATCHED THEN
	INSERT
	(
		Address,
		Item
	)
	VALUES
	(
		Source.Address,
		Source.Item
	);
EXEC POP
GO
CREATE OR ALTER FUNCTION dbo.fnMemoryGet
(
	@Address int
)
RETURNS int
AS
BEGIN
	RETURN
	(
		SELECT	Item
		FROM	vwMemory M
		WHERE	M.Address = @Address
	)
END
GO
CREATE OR ALTER PROCEDURE dbo.LOAD
	@Address int
AS
SET NOCOUNT ON

EXEC spMemCheck @Address

DECLARE @ int = dbo.fnMemoryGet(@Address)

EXEC PUSH @