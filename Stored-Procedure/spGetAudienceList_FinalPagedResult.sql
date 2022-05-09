USE [ITS_WSAPP_MASSMAIL]
GO

/****** Object:  StoredProcedure [dbo].[spGetAudienceList_FinalPagedResult]    Script Date: 5/9/2022 8:48:26 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[spGetAudienceList_FinalPagedResult](
	@Criteria CampaignAudienceCriteriaType ReadOnly,
	@ResultPopulation ResultPopulationType ReadOnly
	
	)

as
begin
set nocount on


declare @PageSize int
declare @PageIndex int
declare @Sort nvarchar(max)
declare @SortDir nvarchar(max)


select count(*) from @ResultPopulation


if(exists(select * from @Criteria where pageIndex is not null and pageIndex is not null))
begin

select @PageSize = PageSize, @PageIndex = PageIndex, @Sort = Sort, @SortDir = case when ListSortDirection = 1 then 'ASC' else 'DESC' end from @Criteria
		
		

select i.* from @ResultPopulation i
		order by
			 case when @Sort  = 'Pid' and @SortDir = 'ASC' then i.Pid end asc                         
			,case when @Sort  = 'Pid' and @SortDir = 'DESC' then i.Pid end  desc
			,case when @Sort  = 'Uid' and @SortDir = 'ASC' then i.Uid end asc
			,case when @Sort  = 'Uid' and @SortDir = 'DESC' then i.Uid end desc
			,case when @Sort  = 'Id' and @SortDir = 'ASC' then i.Id end asc
			,case when @Sort  = 'Id' and @SortDir = 'DESC' then i.Id end desc
			,case when @Sort  = 'Student' and @SortDir = 'ASC' then i.Student end asc
			,case when @Sort  = 'Student' and @SortDir = 'DESC' then i.Student end desc
			,case when @Sort  = 'Employee' and @SortDir = 'ASC' then i.Employee end asc
			,case when @Sort  = 'Employee' and @SortDir = 'DESC' then i.Employee end desc
			,case when @Sort  = 'Faculty' and @SortDir = 'ASC' then i.Faculty end asc
			,case when @Sort  = 'Faculty' and @SortDir = 'DESC' then i.Faculty end desc
			,case when @Sort  = 'Affiliations' and @SortDir = 'ASC' then i.Affiliations end asc
			,case when @Sort  = 'Affiliations' and @SortDir = 'DESC' then i.Affiliations end desc
			                      
			Offset @PageSize * @PageIndex  Rows
			Fetch Next @PageSize  Rows Only Option(Recompile)
end
else 
begin
	select i.* from @ResultPopulation i
		order by
			 case when @Sort  = 'Pid' and @SortDir = 'ASC' then i.Pid end asc                         
			,case when @Sort  = 'Pid' and @SortDir = 'DESC' then i.Pid end  desc
			,case when @Sort  = 'Uid' and @SortDir = 'ASC' then i.Uid end asc
			,case when @Sort  = 'Uid' and @SortDir = 'DESC' then i.Uid end desc
			,case when @Sort  = 'Id' and @SortDir = 'ASC' then i.Id end asc
			,case when @Sort  = 'Id' and @SortDir = 'DESC' then i.Id end desc
			,case when @Sort  = 'Student' and @SortDir = 'ASC' then i.Student end asc
			,case when @Sort  = 'Student' and @SortDir = 'DESC' then i.Student end desc
			,case when @Sort  = 'Employee' and @SortDir = 'ASC' then i.Employee end asc
			,case when @Sort  = 'Employee' and @SortDir = 'DESC' then i.Employee end desc
			,case when @Sort  = 'Faculty' and @SortDir = 'ASC' then i.Faculty end asc
			,case when @Sort  = 'Faculty' and @SortDir = 'DESC' then i.Faculty end desc
			,case when @Sort  = 'Affiliations' and @SortDir = 'ASC' then i.Affiliations end asc
			,case when @Sort  = 'Affiliations' and @SortDir = 'DESC' then i.Affiliations end desc
			                      
			

end

set nocount off
			
end
GO

