USE [ITS_WSAPP_MASSMAIL]
GO

/****** Object:  UserDefinedTableType [dbo].[BasePopulationType]    Script Date: 5/9/2022 8:45:38 AM ******/
CREATE TYPE [dbo].[BasePopulationType] AS TABLE(
	[Pid] [int] NOT NULL,
	[MassEmailAllowed] [bit] NULL,
	[FoundMatch] [bit] NULL,
	PRIMARY KEY CLUSTERED 
(
	[Pid] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO

