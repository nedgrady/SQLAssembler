USE [Assembler]
GO

/****** Object:  Table [dbo].[StandardLibrary]    Script Date: 12/12/2018 21:53:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'dbo.StdFunction', N'U') IS NOT NULL
	DROP TABLE dbo.StdFunction
CREATE TABLE dbo.StdFunction
(
	Code nvarchar(6) PRIMARY KEY CLUSTERED NOT NULL,
	Name nvarchar(200),
	Label nvarchar(8) NOT NULL,
	ArgumentCount int,
	Description nvarchar(200)
)
GO
INSERT	dbo.StdFunction
(
	Code,
	Name,
	Label,
	ArgumentCount,
	Description
)
SELECT	N'STDMUL',
	N'Multiply',
	N'STDMUL',
	2,
	N'Multiplies the two arguments, returning the value of the multiplication. Uses iterative addition.'

CREATE TABLE [dbo].[StdLibraryOp](
	StdFunctionCode nvarchar(6) NOT NULL,
	Idx int NOT NULL,
	[Label] [nvarchar](8) NULL,
	[OpCode] [nvarchar](6) NOT NULL,
	[Arg1] [nvarchar](8) NULL,
	[Arg2] [nvarchar](8) NULL,
PRIMARY KEY CLUSTERED 
(
	StdFunctionCode, [Idx] ASC
))
GO
	
	
	SELECT	N'STDMUL', N'', NULL, NULL
	UNION ALL
	SELECT	NULL, N'STR', N'50000', NULL --arg2
	UNION ALL
	SELECT	NULL, N'LOAD', N'50000', NULL --arg2
	UNION ALL
	SELECT	NULL, N'JGZ', N'POS', NULL
	UNION ALL
	SELECT	NULL, N'LOAD', N'50000', NULL --arg2
	UNION ALL
	SELECT	NULL, N'NEG', NULL, NULL
	UNION ALL
	SELECT	NULL, N'STR', N'50000', NULL -- |arg2|
	UNION ALL
	SELECT	NULL, N'NEG', NULL, NULL -- |arg1|
	UNION ALL
	SELECT	N'POS', N'STR', N'50001', NULL --arg1
	UNION ALL
	SELECT	NULL, N'PUSH', N'0', NULL
	UNION ALL
	SELECT	NULL, N'STR', N'50002', NULL --temp
	UNION ALL
	SELECT	N'START', N'LOAD', N'50000', NULL
	UNION ALL
	SELECT	NULL, N'JEZ', N'END', NULL
	UNION ALL
	SELECT	NULL, N'LOAD', N'50001', NULL
	UNION ALL
	SELECT	NULL, N'LOAD', N'50002', NULL
	UNION ALL
	SELECT	NULL, N'PLUS', NULL, NULL
	UNION ALL
	SELECT	NULL, N'STR', N'50002', NULL --temp
	UNION ALL
	SELECT	NULL, N'PUSH', N'1', NULL
	UNION ALL
	SELECT	NULL, N'LOAD', N'50000', NULL --|arg2|
	UNION ALL
	SELECT	NULL, N'SUB', NULL, NULL --|arg2| - 1
	UNION ALL
	SELECT	NULL, N'STR', N'50000', NULL
	UNION ALL
	SELECT	NULL, N'JUMP', N'START', NULL
	UNION ALL
	SELECT	N'END', N'LOAD', N'50002', NULL

