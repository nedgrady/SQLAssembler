DROP TABLE IF EXISTS dbo.Stack
CREATE TABLE dbo.Stack
(
	SPID int NOT NULL DEFAULT @@SPID,
	Idx int NOT NULL,
	Value int NOT NULL,
	CONSTRAINT PK_Stack PRIMARY KEY CLUSTERED (SPID, Idx)
)
GO
CREATE OR ALTER VIEW vwStack
AS
SELECT	*
FROM	dbo.Stack
WHERE	SPID = @@SPID
GO
DROP TABLE IF EXISTS dbo.Context
CREATE TABLE dbo.Context
(
	SPID int PRIMARY KEY CLUSTERED, --SPID keyed table so we can support multiple programs executing at once.
	StackPointer int NOT NULL,
	ProgramCounter int NOT NULL
)
GO
CREATE OR ALTER VIEW vwContext
AS
SELECT	*
FROM	dbo.Context
WHERE	SPID = @@SPID
GO
CREATE OR ALTER FUNCTION dbo.fnProgramCounterGet()
RETURNS int
AS
BEGIN
	RETURN
	(
		SELECT	TOP (1) ProgramCounter
		FROM	vwContext
	)
END
GO
CREATE OR ALTER FUNCTION dbo.fnStackPointerGet()
RETURNS int
AS
BEGIN
	RETURN
	(
		SELECT	TOP (1) StackPointer
		FROM	dbo.vwContext
	)
END
GO
CREATE OR ALTER PROCEDURE spContextInitialize
	@StackPointer int = 0,
	@ProgramCounter int = 0
AS
SET NOCOUNT, XACT_ABORT ON
BEGIN TRY
	IF	@StackPointer IS NULL
	OR	@ProgramCounter IS NULL
	OR	@StackPointer < 0
	OR	@ProgramCounter < 0
	BEGIN
		RAISERROR
		(
			N'Runtime Error (spContextInitialize): @StackPointer set to %d @ProgramCounter set to %d', 16, 1,
			@StackPointer,
			@ProgramCounter
		) WITH NOWAIT
	END

	BEGIN TRAN
		DELETE	dbo.vwContext
		
		INSERT	dbo.Context
		(
			SPID,
			StackPointer,
			ProgramCounter
		)
		SELECT	@@SPID,
			@StackPointer,
			@ProgramCounter
	COMMIT TRAN
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 1 ROLLBACK TRAN
	EXEC spErrorHandle
	RETURN 651
END CATCH
GO

CREATE OR ALTER PROCEDURE spProgramCounterMove
	@NewValue int = NULL
AS
SET NOCOUNT, XACT_ABORT ON

DECLARE	@MaxLine int,
	@NextLine int

-- If we aren't passed a new value, assume we're just going to the next instruction.
IF @NewValue IS NULL
BEGIN
	SELECT	@NextLine = dbo.fnProgramCounterGet() + 1

	EXEC spProgramCounterMove
		@NextLine
END

IF	@NewValue < 1
OR	NOT EXISTS
	(
		SELECT	*
		FROM	dbo.vwRunningCode
		WHERE	LineNumber = @NewValue
	)
BEGIN
	SELECT	@MaxLine = LineNumber
	FROM	vwRunningCode

	RAISERROR
	(
		N'Runtime Error (spProgramCounterMove): Program Counter out of range. Specified %d expected value between 1 and %d', 16, 1,
		@NextLine,
		@MaxLine
	) WITH NOWAIT
END

UPDATE	vwContext
SET	ProgramCounter = @NewValue
GO

CREATE OR ALTER PROCEDURE spStackPointerSet
	@NewValue int
AS
SET NOCOUNT, XACT_ABORT ON

IF @NewValue IS NULL
	RAISERROR

DELETE dbo.vwStack