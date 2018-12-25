DROP TABLE IF EXISTS LabelMap
CREATE TABLE LabelMap
(
	SPID int NOT NULL,
	SourceLabel nvarchar(8),
	GeneratedLabel nvarchar(10),
	LineNumber int NOT NULL,
	CONSTRAINT PK_LabelMap PRIMARY KEY CLUSTERED(SPID, SourceLabel),
	CONSTRAINT AK_LabelMap_SPID_GeneratedLabel UNIQUE (SPID, GeneratedLabel)
)
GO
CREATE OR ALTER VIEW vwLabelMap
AS
SELECT	*
FROM	dbo.LabelMap
WHERE	SPID = @@SPID
GO
CREATE OR ALTER PROCEDURE [dbo].[spLabelMapCreate]
AS
SET NOCOUNT, XACT_ABORT, CONCAT_NULL_YIELDS_NULL ON
BEGIN TRY
	DELETE	vwLabelMap

	DECLARE	@DuplicateLabels nvarchar(max) = N''

	SELECT	@DuplicateLabels = STUFF
	((
		SELECT	N', [Line' + CONVERT(nvarchar(8), MAX(Idx)) + N'] ' + Label
		FROM	dbo.Instructions
		GROUP BY	Label
		HAVING	COUNT(Label) > 1
		FOR	XML PATH('')
	), 1, 2, N'')

	DECLARE	@NonExistentLabels nvarchar(max) = N''

	SELECT	@NonExistentLabels = STUFF
	((
		SELECT	N', [Line' + CONVERT(nvarchar(8), MAX(I.Idx)) + N'] ' + I.Arg1
		FROM	dbo.Instructions I
			INNER JOIN dbo.OpCodeArgument A ON I.OpCode = A.OpCode
		WHERE	I.Arg1 IS NOT NULL
		AND	A.TypeLookup = N'LBL'
		AND	NOT EXISTS
		(
			SELECT	Label
			FROM	dbo.Instructions II
			WHERE	I.Arg1 = II.Label
		)
		GROUP BY	I.Arg1
		FOR	XML PATH('')
	), 1, 2, N'')

	IF(LEN(@DuplicateLabels) > 1 OR LEN(@NonExistentLabels) > 1)
	BEGIN
		DECLARE	@Err nvarchar(200) =
		N'Compiler Error:
		' + ISNULL(N'Duplicate Labels: ' + @DuplicateLabels, N'') + N'
		' + ISNULL(N'Non Existent Labels: ' + @NonExistentLabels, N'')

		RAISERROR(@Err, 16, 1)
	END

	INSERT	dbo.vwLabelMap
	(
		SourceLabel,
		GeneratedLabel,
		LineNumber
	)
	SELECT	I.Label,
		N'#LBL' + CONVERT(nvarchar(6), ROW_NUMBER() OVER (ORDER BY @@SPID)),
		I.Idx
	FROM	dbo.Instructions I
	WHERE	Label IS NOT NULL
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 1 ROLLBACK TRAN
	EXEC spErrorHandle
	RETURN 5
END CATCH