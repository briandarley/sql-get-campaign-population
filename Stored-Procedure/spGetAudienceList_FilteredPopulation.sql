USE [ITS_WSAPP_MASSMAIL]
GO

/****** Object:  StoredProcedure [dbo].[spGetAudienceList_FilteredPopulation]    Script Date: 5/9/2022 8:48:37 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[spGetAudienceList_FilteredPopulation](
	@Criteria CampaignAudienceCriteriaType ReadOnly,
	@IncludeExclude CampaignIncludeExcludeType ReadOnly,
	@BasePopulation BasePopulationType ReadOnly
	)

as
begin
set nocount on

declare @CampaignId int;
select @CampaignId  = CampaignId from @Criteria;

declare @hasUnderGraduates bit;
declare @hasGraduates bit;
declare @hasStaff bit
declare @hasFaculty bit
declare @hasDdd bit
declare @hasRetirees bit
declare @hasVolunteers bit
declare @hasConsultants bit
declare @hasVisitingScholar bit

set @hasUnderGraduates  = 0;
set @hasGraduates		= 0;
set @hasStaff			= 0;
set @hasFaculty			= 0;
set @hasDdd				= 0;
set @hasRetirees		= 0;
set @hasVolunteers		= 0;
set @hasConsultants		= 0;
set @hasVisitingScholar = 0;


declare @ExcludeStudents ResultPopulationType;
declare @ExcludeEmployees ResultPopulationType;
declare @ExcludeAffiliates ResultPopulationType;

declare @IncludeStudents ResultPopulationType;
declare @IncludeEmployees ResultPopulationType;
declare @IncludeAffiliates ResultPopulationType;


declare @ResultPopulation ResultPopulationType;


/*******************************************************************************************************
EXCLUDE Population Logic
Flag population groups that should be removed from the final result
*******************************************************************************************************/
if(exists(select * from @IncludeExclude where ExcludePopCode is not null))
begin
	if(exists(select * from @IncludeExclude where ExcludePopCode = 'UNDERGRADUATES'))
	begin
		set @hasUnderGraduates = 1
	end

	if(exists(select * from @IncludeExclude where ExcludePopCode = 'GRADUATES'))
	begin
		set @hasGraduates = 1
	end

	if(exists(select * from @IncludeExclude where ExcludePopCode = 'STAFF'))
	begin
		set @hasStaff = 1
	end

	if(exists(select * from @IncludeExclude where ExcludePopCode = 'FACULTY'))
	begin
		set @hasFaculty = 1
	end

	if(exists(select * from @IncludeExclude where ExcludePopCode = 'DDD'))
	begin
		set @hasDdd = 1
	end

	if(exists(select * from @IncludeExclude where ExcludePopCode = 'RETIREES'))
	begin
		set @hasRetirees = 1
	end

	if(exists(select * from @IncludeExclude where ExcludePopCode = 'VOLUNTEERS'))
	begin
		set @hasVolunteers = 1
	end

	if(exists(select * from @IncludeExclude where ExcludePopCode = 'CONSULTANTS'))
	begin
		set @hasConsultants = 1
	end

	if(exists(select * from @IncludeExclude where ExcludePopCode = 'VISITING_SCHOLAR'))
	begin
		set @hasVisitingScholar = 1
	end

	




/*******************************************************************************************************
EXCLUDE Student Population
*******************************************************************************************************/
	begin

		insert into @ExcludeStudents (
			Id							
			,Pid							
		)
		
		select ldap.Id, ldap.Pid --,lsy.Graduate 
		from @BasePopulation base
		join MassMail.LdapUser ldap on ldap.Pid = base.Pid
		LEFT JOIN [MassMail].[LdapStudent] AS [ldapStudent] ON [ldap].[Pid] = [ldapStudent].[Pid]
		LEFT JOIN [MassMail].[LdapStudentAcademicGroup] AS [lsag] ON [ldapStudent].[LdapStudentAcademicGroupId] = [lsag].[Id]
		LEFT JOIN [MassMail].[LdapStudentYear] AS [lsy] ON [ldapStudent].[LdapStudentYearId] = [lsy].[Id]

		where 1=1 
			and ldapStudent.Pid is not null
			--if both graduate and undergraduate selected return row
			and (1 = case when @hasUnderGraduates =1 and @hasGraduates = 1 then 1 end 
			--if just graduate, make sure graduate is true
				or 1 = case when graduate = 1 and @hasGraduates = 1 then 1 end
				--if undergraduate but not graduate make sure graduate is false
				or 1 = case when graduate = 0 and @hasUnderGraduates =1 and @hasGraduates = 0 then 1 end)

	end
/*******************************************************************************************************
EXCLUDE Employee Population
*******************************************************************************************************/
	begin
	
		insert into @ExcludeEmployees (
			Id							
			,Pid							
		)
		
		select ldap.Id, ldap.Pid 
		from @BasePopulation base
		join MassMail.LdapUser ldap on ldap.Pid = base.Pid
		left join DDDList ddd on ddd.id = ldap.pid
		where 1=1 
		and 
		((ldap.Employee = 1 and @hasStaff = 1 )
			or (ldap.Faculty = 1 and @hasFaculty = 1)
			or (ddd.Id is not null and @hasDdd = 1)
		)

	end
/*******************************************************************************************************
EXCLUDE Affiliate Population
*******************************************************************************************************/
	begin
	
		insert into @ExcludeAffiliates (
			Id							
			,Pid							
		)
		select ldap.Id, ldap.Pid
		from @BasePopulation base
		join MassMail.LdapUser ldap on ldap.Pid = base.Pid
		join MassMail.LdapUserAffiliate lua on lua.Pid = ldap.pid
		join MassMail.LdapAffiliateType la on la.Id = lua.AffiliateTypeId
		where 1=1 
		and 
		((@hasRetirees = 1 and la.AffiliationType = 'Retiree')
			or (@hasVolunteers = 1 and la.AffiliationType = 'Volunteer')
			or (@hasVisitingScholar = 1 and la.AffiliationType = 'Visiting Scholar')
			or (@hasConsultants = 1 and la.AffiliationType in ('Independent Contractor', 'Other Contractor/Consultant','External Employee','UNC Trustee'))
		)
	end
end


/*******************************************************************************************************
INCLUDE Population Logic
*******************************************************************************************************/
begin

	if(exists(select * from @IncludeExclude where IncludePopCode = 'UNDERGRADUATES'))
	begin
		set @hasUnderGraduates = 1
	end

	if(exists(select * from @IncludeExclude where IncludePopCode = 'GRADUATES'))
	begin
		set @hasGraduates = 1
	end

	if(exists(select * from @IncludeExclude where IncludePopCode = 'STAFF'))
	begin
		set @hasStaff = 1
	end

	if(exists(select * from @IncludeExclude where IncludePopCode = 'FACULTY'))
	begin
		set @hasFaculty = 1
	end

	if(exists(select * from @IncludeExclude where IncludePopCode = 'DDD'))
	begin
		set @hasDdd = 1
	end

	if(exists(select * from @IncludeExclude where IncludePopCode = 'RETIREES'))
	begin
		set @hasRetirees = 1
	end

	if(exists(select * from @IncludeExclude where IncludePopCode = 'VOLUNTEERS'))
	begin
		set @hasVolunteers = 1
	end

	if(exists(select * from @IncludeExclude where IncludePopCode = 'CONSULTANTS'))
	begin
		set @hasConsultants = 1
	end

	if(exists(select * from @IncludeExclude where IncludePopCode = 'VISITING_SCHOLAR'))
	begin
		set @hasVisitingScholar = 1
	end

end
	

/*******************************************************************************************************
FINAL RESULTS
*******************************************************************************************************/

	begin
	;with cteStudents as(
	select 
		ldap.Id							
		,ldap.Pid							
		,ldap.Uid							
		,ldap.MassEmailAllowed
		,ldap.Student				
		,ldap.Employee
		,ldap.DepartmentNumbers
		,ldap.Affiliations				
		,ldap.Mail					
		,ldap.CreateDate
		,ldap.CreateUser				
		,ldap.ChangeDate				
		,ldap.ChangeUser				
		,ldap.Faculty					
		,ldap.ModifyTimeStamp
		,null AffiliateTypes				
		,null AffiliateTypeIds
		,lsag.AcademicGroup				
		,lsag.AcademicGroupCode
		,lsy.Graduate				
		,lsy.AcademicYear
		from @BasePopulation base
		join MassMail.LdapUser ldap on ldap.Pid = base.Pid
		left join @ExcludeStudents ex on ex.Pid = base.Pid
		LEFT JOIN [MassMail].[LdapStudent] AS [ldapStudent] ON [ldap].[Pid] = [ldapStudent].[Pid]
		LEFT JOIN [MassMail].[LdapStudentAcademicGroup] AS [lsag] ON [ldapStudent].[LdapStudentAcademicGroupId] = [lsag].[Id]
		LEFT JOIN [MassMail].[LdapStudentYear] AS [lsy] ON [ldapStudent].[LdapStudentYearId] = [lsy].[Id]

		where 1=1 
			and ex.Pid is null
			and ldapStudent.Pid is not null
			--if both graduate and undergraduate selected return row
			and (
			1 = case when @hasUnderGraduates = 1 and @hasGraduates = 1 then 1 end 
			--if just graduate, make sure graduate is true
				or 1 = case when lsy.graduate = 1 and @hasGraduates = 1 then 1 end
				--if undergraduate but not graduate make sure graduate is false
				or 1 = case when iif(lsy.graduate is null, 0, lsy.graduate) = 0 and @hasUnderGraduates = 1 and @hasGraduates = 0 then 1 end
				           
				)

	),
	cteEmployees as (
		select 
			ldap.Id							
			,ldap.Pid							
			,ldap.Uid							
			,ldap.MassEmailAllowed
			,ldap.Student				
			,ldap.Employee
			,ldap.DepartmentNumbers
			,ldap.Affiliations				
			,ldap.Mail					
			,ldap.CreateDate
			,ldap.CreateUser				
			,ldap.ChangeDate				
			,ldap.ChangeUser				
			,ldap.Faculty					
			,ldap.ModifyTimeStamp
			,null AffiliateTypes				
			,null AffiliateTypeIds
			,null AcademicGroup				
			,null AcademicGroupCode
			,null Graduate				
			,null AcademicYear
				from @BasePopulation base
				join MassMail.LdapUser ldap on ldap.Pid = base.Pid
				left join @ExcludeEmployees ex on ex.Pid = base.pid
				left join DDDList ddd on ddd.id = ldap.pid
				where 1=1 
					and ex.Pid is null
					and 
					(
						(ldap.Employee = 1 and @hasStaff = 1 )
						or (ldap.Faculty = 1 and @hasFaculty = 1)
						or (ddd.Id is not null and @hasDdd = 1)
					)
	),
	cteAffiliates as (

	select 
		ldap.Id							
		,ldap.Pid							
		,ldap.Uid							
		,ldap.MassEmailAllowed
		,ldap.Student				
		,ldap.Employee
		,ldap.DepartmentNumbers
		,ldap.Affiliations				
		,ldap.Mail					
		,ldap.CreateDate
		,ldap.CreateUser				
		,ldap.ChangeDate				
		,ldap.ChangeUser				
		,ldap.Faculty					
		,ldap.ModifyTimeStamp
		,stuff((
				select ',' + la.AffiliationType
				from MassMail.LdapAffiliateType la
				left join MassMail.LdapUserAffiliate lua on lua.AffiliateTypeId = la.Id
				where lua.Pid = ldap.Pid
				for xml path('')
			),1,1,'') as AffiliateTypes
		,stuff((
			select ',' + cast(la.Id as nvarchar(max))
			from MassMail.LdapAffiliateType la
			left join MassMail.LdapUserAffiliate lua on lua.AffiliateTypeId = la.Id
			where lua.Pid = ldap.Pid
			for xml path('')
		),1,1,'') as AffiliateTypeIds
		,null AcademicGroup				
		,null AcademicGroupCode
		,null Graduate				
		,null AcademicYear
		
		from @BasePopulation base
		join MassMail.LdapUser ldap on ldap.Pid = base.Pid
		left join @ExcludeAffiliates ex on ex.Pid = base.pid
		join MassMail.LdapUserAffiliate lua on lua.Pid = ldap.pid
		join MassMail.LdapAffiliateType la on la.Id = lua.AffiliateTypeId
		where 1=1 
			and ex.Pid is null
			and 
				(
					(@hasRetirees = 1 and la.AffiliationType = 'Retiree')
					or (@hasVolunteers = 1 and la.AffiliationType = 'Volunteer')
					or (@hasVisitingScholar = 1 and la.AffiliationType in ('University Temp Svcs Employee', 'Visiting Scholar','UNC Trustee'))
					or (@hasConsultants = 1 and la.AffiliationType in ('Independent Contractor', 'Other Contractor/Consultant','External Employee'))
				)



	)

	   	  

		/*******************************************************************************************************
		INCLUDE Student Population
		*******************************************************************************************************/
		
		select 
		Id							
		,Pid							
		,Uid							
		,MassEmailAllowed
		,Student				
		,Employee
		,DepartmentNumbers
		,Affiliations				
		,Mail					
		,CreateDate
		,CreateUser				
		,ChangeDate				
		,ChangeUser				
		,Faculty					
		,ModifyTimeStamp
		,AffiliateTypes				
		,AffiliateTypeIds
		,AcademicGroup				
		,AcademicGroupCode
		,Graduate				
		,AcademicYear
		from cteStudents
		union 
		/*******************************************************************************************************
		INCLUDE Employee Population
		*******************************************************************************************************/

		select Id							
		,Pid							
		,Uid							
		,MassEmailAllowed
		,Student				
		,Employee
		,DepartmentNumbers
		,Affiliations				
		,Mail					
		,CreateDate
		,CreateUser				
		,ChangeDate				
		,ChangeUser				
		,Faculty					
		,ModifyTimeStamp
		,AffiliateTypes				
		,AffiliateTypeIds
		,AcademicGroup				
		,AcademicGroupCode
		,Graduate				
		,AcademicYear
		from cteEmployees
		union 
		/*******************************************************************************************************
		INCLUDE Affiliate Population
		*******************************************************************************************************/
		select Id							
		,Pid							
		,Uid							
		,MassEmailAllowed
		,Student				
		,Employee
		,DepartmentNumbers
		,Affiliations				
		,Mail					
		,CreateDate
		,CreateUser				
		,ChangeDate				
		,ChangeUser				
		,Faculty					
		,ModifyTimeStamp
		,AffiliateTypes				
		,AffiliateTypeIds
		,AcademicGroup				
		,AcademicGroupCode
		,Graduate				
		,AcademicYear
		from cteAffiliates
				
						
	end


set nocount off
			
end
GO

