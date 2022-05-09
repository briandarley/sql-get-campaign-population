USE [ITS_WSAPP_MASSMAIL]
GO

/****** Object:  UserDefinedTableType [dbo].[DddPidsTable]    Script Date: 5/9/2022 8:46:33 AM ******/
CREATE TYPE [dbo].[DddPidsTable] AS TABLE(
	[ID] [nvarchar](255) NULL,
	[Name] [nvarchar](255) NULL,
	[Dept ID] [nvarchar](255) NULL,
	[Department Description] [nvarchar](255) NULL,
	[School_Div] [nvarchar](255) NULL,
	[Reg/Temp] [nvarchar](255) NULL,
	[Descr] [nvarchar](255) NULL,
	[Email] [nvarchar](255) NULL,
	[CB #] [nvarchar](255) NULL
)
GO

