USE [ITS_WSAPP_MASSMAIL]
GO

/****** Object:  UserDefinedTableType [dbo].[CampaignIncludeExcludeType]    Script Date: 5/9/2022 8:46:13 AM ******/
CREATE TYPE [dbo].[CampaignIncludeExcludeType] AS TABLE(
	[Department] [nvarchar](max) NULL,
	[IncludePopCode] [nvarchar](max) NULL,
	[ExcludePopCode] [nvarchar](max) NULL
)
GO

