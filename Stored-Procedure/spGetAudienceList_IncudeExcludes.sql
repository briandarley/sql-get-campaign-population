USE [ITS_WSAPP_MASSMAIL]
GO

/****** Object:  StoredProcedure [dbo].[spGetAudienceList_IncudeExcludes]    Script Date: 5/9/2022 8:47:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--select top 10 * from massmail.Campaign where ExcludeAudience is not null
--declare @criteria CampaignAudienceCriteriaType
--insert into @criteria
--Exec spGetAudienceList_Criteria @jsonCriteria = '{"$id":"1","massMailAllowed":false,"campaignId":2038,"uniqueRecipientsOnly":true,"pageSize":100,"index":0,"sort":"Pid","listSortDirection":0,"departmentNumbers":"[''1'']"}'
--select departmentNumbers from @criteria

CREATE proc [dbo].[spGetAudienceList_IncudeExcludes](@criteria [CampaignAudienceCriteriaType] Readonly)
as
begin
set nocount on
declare @campaignId int 

declare @CampaignIncludeExclude CampaignIncludeExcludeType;



declare @DepartmentNumbers table
(
   Value nvarchar(max)
)
declare @IncludePopulationsCodes table
(
  Value nvarchar(max)
)
declare @ExcludePopulationsCodes table
(
  Value nvarchar(max)
)

select @campaignId = campaignId from @criteria


			if exists(select * from @criteria where DepartmentNumbers is not null)
			begin
				insert into @DepartmentNumbers (Value)
					SELECT value  
						FROM @criteria 
						Cross Apply OpenJson(DepartmentNumbers,'$')
			end 



			/********************************************************************************
			Add Audience Include
			From Criteria 
			From Campaign Defintion
			********************************************************************************/
			begin
				--The common table expressions below are used to convert a comma delimited column into a row of fields
				WITH tmp(DataItem,Value) AS
				(
					SELECT
        
						LEFT(cast(AudienceSelection as varchar(max)), CHARINDEX(',', cast(AudienceSelection as varchar(max)) + ',') - 1),
						STUFF(cast(AudienceSelection as varchar(max)), 1, CHARINDEX(',', cast(AudienceSelection as varchar(max)) + ','), '')
					FROM MassMail.Campaign where id = @campaignId
					UNION all

					SELECT
       
						LEFT(cast(Value as varchar(max)), CHARINDEX(',', cast(Value as varchar(max)) + ',') - 1),
						STUFF(cast(Value as varchar(max)), 1, CHARINDEX(',', cast(Value as varchar(max)) + ','), '')
					FROM tmp
					WHERE
						Value > ''
				)			

				 insert into @IncludePopulationsCodes (Value)
				 select DataItem from tmp;

			 			 

				if exists(select * from @criteria where IncludePopulationsCodes is not null)
				begin
					insert into @IncludePopulationsCodes (value)
					SELECT ipc.value  
						FROM @criteria c
						Cross Apply OpenJson(IncludePopulationsCodes,'$') ipc
						left join @IncludePopulationsCodes i on i.Value = ipc.value
						where  i.Value  is null
				end 
			end


			/********************************************************************************
			Add Audience Exclude
			From Criteria 
			From Campaign Defintion
			********************************************************************************/

			begin
				  --The common table expressions below are used to convert a comma delimited column into a row of fields
				WITH tmp(DataItem,Value) AS
				(
					SELECT
        
						LEFT(cast(ExcludeAudience as varchar(max)), CHARINDEX(',', cast(ExcludeAudience as varchar(max)) + ',') - 1),
						STUFF(cast(ExcludeAudience as varchar(max)), 1, CHARINDEX(',', cast(ExcludeAudience as varchar(max)) + ','), '')
					FROM MassMail.Campaign where id = @campaignId and ExcludeAudience is not null and len(ExcludeAudience) > 0
					UNION all

					SELECT
       
						LEFT(cast(Value as varchar(max)), CHARINDEX(',', cast(Value as varchar(max)) + ',') - 1),
						STUFF(cast(Value as varchar(max)), 1, CHARINDEX(',', cast(Value as varchar(max)) + ','), '')
					FROM tmp
					WHERE
						Value > ''
				)			
				

				insert into @ExcludePopulationsCodes (Value)
				select DataItem from tmp;
				
				

				if exists(select * from @criteria where ExcludePopulationsCodes is not null)
				begin
					insert into @ExcludePopulationsCodes (value)
					SELECT value  
					FROM @criteria 
					Cross Apply OpenJson(ExcludePopulationsCodes,'$')

				end 
			end
			

			/*
			If includes/excludes was not provided, include all populations then
			*/

			if not exists (select * from @IncludePopulationsCodes) and not exists (select * from @ExcludePopulationsCodes)
			begin
				insert into @IncludePopulationsCodes
				select * from ( values
				('UNDERGRADUATES')
				,('GRADUATES')
				,('STAFF')
				,('FACULTY')
				,('DDD')
				,('RETIREES')
				,('VOLUNTEERS')
				,('CONSULTANTS')
				,('VISITING_SCHOLAR')
				) as x(value)

			end 

			

			


			;with cte1 as (
				select Row_number() over(order by value) as RowNum, value DepartmentNumber  from @DepartmentNumbers
			),
			cte2 as (
				/*Any Excludes Should be Removed from the Includes*/
				select Row_number() over(order by inc.value) as RowNum, inc.value [Include]  
				from @IncludePopulationsCodes inc
				left join @ExcludePopulationsCodes d on d.Value = inc.Value
				where d.Value is null
			),
			cte3 as (
				select Row_number() over(order by value) as RowNum, value Exclude from @ExcludePopulationsCodes
			)
			insert into @CampaignIncludeExclude (Department,IncludePopCode,ExcludePopCode)
			select DepartmentNumber, [Include], cte3.Exclude
			from cte1
			full join cte2 on cte1.RowNum = cte2.RowNum
			full join cte3 on cte1.RowNum = cte3.RowNum
			
			
			

			select * from @CampaignIncludeExclude 
set nocount off			
end

GO

