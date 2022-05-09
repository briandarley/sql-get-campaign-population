USE [ITS_WSAPP_MASSMAIL]
GO

/****** Object:  UserDefinedTableType [dbo].[ResultPopulationType]    Script Date: 5/9/2022 8:46:43 AM ******/
CREATE TYPE [dbo].[ResultPopulationType] AS TABLE(
	[Id] [int] NOT NULL,
	[Pid] [int] NOT NULL,
	[Uid] [nvarchar](50) NOT NULL,
	[MassEmailAllowed] [bit] NOT NULL,
	[Student] [bit] NULL,
	[Employee] [bit] NULL,
	[DepartmentNumbers] [nvarchar](500) NULL,
	[Affiliations] [nvarchar](max) NULL,
	[Mail] [nvarchar](255) NULL,
	[CreateDate] [datetime] NULL,
	[CreateUser] [varchar](50) NULL,
	[ChangeDate] [datetime] NULL,
	[ChangeUser] [varchar](50) NULL,
	[Faculty] [bit] NULL,
	[ModifyTimeStamp] [datetime] NULL,
	[AffiliateTypes] [nvarchar](max) NULL,
	[AffiliateTypeIds] [nvarchar](max) NULL,
	[AcademicGroup] [nvarchar](100) NULL,
	[AcademicGroupCode] [nvarchar](10) NULL,
	[Graduate] [bit] NULL,
	[AcademicYear] [bit] NULL,
	PRIMARY KEY CLUSTERED 
(
	[Pid] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO

