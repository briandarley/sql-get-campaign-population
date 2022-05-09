USE [ITS_WSAPP_MASSMAIL]
GO

/****** Object:  UserDefinedTableType [dbo].[CampaignAudienceCriteriaType]    Script Date: 5/9/2022 8:46:00 AM ******/
CREATE TYPE [dbo].[CampaignAudienceCriteriaType] AS TABLE(
	[CampaignId] [int] NULL,
	[Pid] [int] NULL,
	[Uid] [nvarchar](max) NULL,
	[MassMailAllowed] [bit] NULL,
	[Employee] [bit] NULL,
	[Faculty] [bit] NULL,
	[Student] [bit] NULL,
	[Graduate] [bit] NULL,
	[Affiliate] [bit] NULL,
	[VisitingExchange] [bit] NULL,
	[AcademicGroupCode] [nvarchar](max) NULL,
	[AcademicLevelCode] [nvarchar](max) NULL,
	[AcademicYear] [bit] NULL,
	[Ddd] [bit] NULL,
	[AffiliateTypes] [nvarchar](max) NULL,
	[DepartmentNumbers] [nvarchar](max) NULL,
	[IncludePopulationsCodes] [nvarchar](max) NULL,
	[ExcludePopulationsCodes] [nvarchar](max) NULL,
	[FilterText] [nvarchar](max) NULL,
	[PageSize] [int] NULL,
	[PageIndex] [int] NULL,
	[Sort] [nvarchar](max) NULL,
	[ListSortDirection] [int] NULL,
	[UniqueRecipientsOnly] [bit] NULL
)
GO

