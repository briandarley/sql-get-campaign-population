USE [ITS_WSAPP_MASSMAIL]
GO

/****** Object:  StoredProcedure [dbo].[spGetAudienceList_Criteria]    Script Date: 5/9/2022 8:48:49 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--Exec spGetAudienceList_Criteria @jsonCriteria = '{"$id":"1","massMailAllowed":false,"campaignId":2038,"uniqueRecipientsOnly":true,"pageSize":100,"index":0,"sort":"Pid","listSortDirection":0}'
CREATE proc [dbo].[spGetAudienceList_Criteria](@jsonCriteria nvarchar(max) )

as
begin
set nocount on


declare @criteria [CampaignAudienceCriteriaType]

insert into @criteria (CampaignId,Pid,Uid,MassMailAllowed,Employee,Faculty,Student,Graduate,Affiliate,VisitingExchange,AcademicGroupCode,AcademicLevelCode,AcademicYear,Ddd,AffiliateTypes,DepartmentNumbers,IncludePopulationsCodes,ExcludePopulationsCodes,FilterText,PageSize,PageIndex,Sort,ListSortDirection,UniqueRecipientsOnly)

SELECT 
	CampaignId,Pid,Uid,MassMailAllowed,Employee,Faculty,Student,Graduate,Affiliate,VisitingExchange,AcademicGroupCode,AcademicLevelCode,AcademicYear,Ddd,AffiliateTypes,DepartmentNumbers,IncludePopulationsCodes,ExcludePopulationsCodes,FilterText,PageSize,PageIndex,Sort,ListSortDirection,UniqueRecipientsOnly
FROM OPENJSON(@jsonCriteria)
WITH (   
    CampaignId int '$.campaignId',
    Pid int '$.pid' ,  
	Uid nvarchar(max) '$.uid' ,  
	MassMailAllowed bit '$.massMailAllowed' ,
	Employee bit '$.employee' ,
	Faculty bit '$.faculty' ,
	Student bit '$.student' ,
	Graduate bit '$.graduate' ,
	Affiliate bit '$.affiliate' ,
	VisitingExchange bit '$.visitingExchange' ,
	AcademicGroupCode  nvarchar(max) '$.academicGroupCode' ,
	AcademicLevelCode nvarchar(max) '$.academicLevelCode' ,
	AcademicYear bit '$.academicYear' ,
	Ddd bit '$.ddd',
	AffiliateTypes nvarchar(max) '$.affiliateTypes',
	DepartmentNumbers nvarchar(max) '$.departmentNumbers' as Json,
	IncludePopulationsCodes nvarchar(max) '$.includePopulationsCodes' as Json,
	ExcludePopulationsCodes nvarchar(max) '$.excludePopulationsCodes' as Json,
	FilterText nvarchar(max) '$.filterText',
	PageSize int '$.pageSize',
    PageIndex int '$.index',
	Sort nvarchar(max) '$.sort',
	ListSortDirection int '$.listSortDirection',
	UniqueRecipientsOnly bit '$.uniqueRecipientsOnly'
) 
select * from @criteria
set nocount off
end


GO

