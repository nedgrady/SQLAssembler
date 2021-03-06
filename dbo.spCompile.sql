USE [Assembler]
GO
/****** Object:  StoredProcedure [dbo].[spCompile]    Script Date: 08/12/2018 23:15:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spCompile]
AS
SET NOCOUNT, CONCAT_NULL_YIELDS_NULL ON
BEGIN TRY
	DECLARE @CRLF char(2) = char(13) + char(10)
	DECLARE @TAB char(1) = char(09)

	EXEC spLabelMapCreate

	BEGIN TRAN
		DELETE	dbo.vwContext

		INSERT	dbo.RunningCode
		(
			LineNumber,
			SQL,
			Assembler
		)
		SELECT	ROW_NUMBER() OVER(ORDER BY @@SPID),
			REPLACE
			(
				REPLACE(O.Generation, N'%T', N'dbo.fnTop()'), -- %T -> Stack Top
				N'%0',
				CASE
					WHEN A.TypeLookup = N'INT' THEN CONVERT(nvarchar(8), CONVERT(int, I.Arg1))
					WHEN A.TypeLookup = N'LBL' THEN LA.LineNumber
					WHEN A.TypeLookup = N'MEM' THEN I.Arg1 --Memory access is just via numbers, at the moment...
					ELSE N''
				END
			),
			FormattedInstructions.Str
		FROM	dbo.Instructions I
			INNER JOIN dbo.OpCode O ON O.Code LIKE I.OpCode
			LEFT JOIN dbo.vwLabelMap LL ON LL.SourceLabel LIKE I.Label
			LEFT JOIN dbo.vwLabelMap LA ON LA.SourceLabel = I.Arg1
			LEFT JOIN dbo.OpCodeArgument A ON O.Code LIKE A.OpCode
			CROSS APPLY
			(
				-- No dependency on the specific columns in Instructions,
				-- but no space between the labels/op codes etc. :(
				SELECT
				(
					SELECT	*
					FROM	Instructions II
					WHERE	I.Idx = II.Idx
					FOR	XML PATH(''),
					type
				).value('.', 'nvarchar(max)')
			) AS FormattedInstructionsAll(Str)
			CROSS APPLY
			(
				SELECT
				(
					SELECT	ISNULL(II.Label + N':', N'') + N' ',
						ISNULL(II.OpCode, N'') + N' ',
						ISNULL(II.Arg1, N'') + N' ',
						ISNULL(II.Arg2, N'') + N' ' 
					FROM	Instructions II
					WHERE	I.Idx = II.Idx
					FOR	XML PATH(''),
					type
				).value('.', 'nvarchar(max)')
			) AS FormattedInstructions (Str)
	COMMIT TRAN
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 1 ROLLBACK TRAN
	EXEC spErrorHandle
	RETURN 651
END CATCH