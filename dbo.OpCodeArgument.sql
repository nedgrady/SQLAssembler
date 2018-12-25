DROP TABLE OpCodeArgument
DROP TABLE OpCodeArgumentTypeLookup

IF OBJECT_ID(N'dbo.OpCodeArgument') IS NULL
	CREATE TABLE dbo.OpCodeArgument
	(
		OpCode nvarchar(6),
		Idx int,
		TypeLookup char(3)
	)

IF OBJECT_ID(N'dbo.OpCodeArgumentTypeLookup') IS NULL
	CREATE TABLE dbo.OpCodeArgumentTypeLookup
	(
		TypeLoopkup char(3),
		Description nvarchar(20),
		GeneratedCode nvarchar(200)
	)

TRUNCATE TABLE OpCodeArgumentTypeLookup

INSERT	dbo.OpCodeArgumentTypeLookup
(
	TypeLoopkup,
	Description,
	GeneratedCode
)
SELECT	N'LBL', N'Label', N''
UNION ALL
SELECT	N'INT', N'Literal Integer', N''
UNION ALL
SELECT	N'MEM', N'Memory Address', N''

INSERT	dbo.OpCodeArgument
(
	OpCode,
	Idx,
	TypeLookup
)
SELECT	N'PUSH', 0, N'INT'
UNION ALL
SELECT	N'JUMP', 0, N'LBL'
UNION ALL
SELECT	N'JGZ', 0, N'LBL'
UNION ALL
SELECT	N'JLZ', 0, N'LBL'
UNION ALL
SELECT	N'JEZ', 0, N'LBL'
UNION ALL
SELECT	N'JNZ', 0, N'LBL'
UNION ALL
SELECT	N'STR', 0, N'MEM'
UNION ALL
SELECT	N'LOAD', 0, N'MEM'