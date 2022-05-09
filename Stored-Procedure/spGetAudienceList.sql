USE [ITS_WSAPP_MASSMAIL]
GO

/****** Object:  StoredProcedure [dbo].[spGetAudienceList3]    Script Date: 5/9/2022 8:47:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--spGetAudienceList3 @jsonCriteria = '{"$id":"1","massMailAllowed":false,"campaignId":2038,"uniqueRecipientsOnly":true,"pageSize":100,"index":0,"sort":"Pid","listSortDirection":0}'
CREATE proc [dbo].[spGetAudienceList3](@jsonCriteria nvarchar(max) )
as
set nocount on

declare @criteria CampaignAudienceCriteriaType
declare @includeExclude CampaignIncludeExcludeType;
declare @BasePopulation BasePopulationType;
declare @ResultPopulation ResultPopulationType

begin --Declare SP Variables/Tables

--Step 1 Conver JSON to Criteria Table
insert into @criteria
Exec spGetAudienceList_Criteria @jsonCriteria = @jsonCriteria

--Step 2 Get Excude/Include/Departments all in one table
insert into @includeExclude 
Exec spGetAudienceList_IncudeExcludes @criteria

--Step 3 Get Base Population 
insert into @BasePopulation
exec spGetAudienceList_BasePopulation @criteria 

--*********************************************************
--Todo squeeze out performance from the below
--*********************************************************

--Step 4 Get Complete Filtered Population
insert into @ResultPopulation
exec [spGetAudienceList_FilteredPopulation] 
	@criteria ,
	@includeExclude ,
	@BasePopulation
	
	--select * from @ResultPopulation
--Step 5 Offer paging to the final result given criteria
exec spGetAudienceList_FinalPagedResult @criteria ,@ResultPopulation



set nocount off

end



GO

