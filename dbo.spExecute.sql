DROP TABLE IF EXISTS dbo.RunningCode
GO
CREATE TABLE dbo.RunningCode
(
	SPID int DEFAULT @@SPID,
	LineNumber int NOT NULL,
	SQL nvarchar(200) NOT NULL,
	Assembler nvarchar(200) NOT NULL,
	CONSTRAINT PK_RunningCode PRIMARY KEY CLUSTERED (SPID, LineNUmber)
)
GO
CREATE OR ALTER VIEW vwRunningCode
AS
SELECT	*
FROM	dbo.RunningCode
WHERE	SPID = @@SPID
GO
CREATE OR ALTER PROCEDURE spExecute
	@StartLineNumber int = 1
AS
	SET NOCOUNT ON
	DECLARE	@Break bit = 0,
		@Sql nvarchar(200),
		@StackTop int

	EXEC spContextInitialize
		@StackPointer = DEFAULT,
		@ProgramCounter = @StartLineNumber

	WHILE(1 = 1)
	BEGIN
		SELECT	@Sql = dbo.fnNextLine(),
			@StackTop = dbo.fnTop()

		IF @Sql IS NULL
			BREAK

		EXEC spPrintStack
		RAISERROR (N'Executing line %d: %s', 0, 1, @StackTop, @Sql) WITH NOWAIT


		EXEC sp_executesql
			@Sql,
			N'@ST int',
			@St = @StackTop

		UPDATE	dbo.ProgramCounter
		SET	Number = Number + 1

	END

SELECT	dbo.fnTop()
GO

CREATE OR ALTER FUNCTION dbo.fnNextLine ()
RETURNS nvarchar(200)
AS
BEGIN
	RETURN
	(
		SELECT	TOP (1) SQL
		FROM	dbo.vwRunningCode
		WHERE	LineNumber =  dbo.fnProgramCounterGet()
	)
END
GO