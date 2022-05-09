USE [ITS_WSAPP_MASSMAIL]
GO

/****** Object:  StoredProcedure [dbo].[spGetAudienceList_BasePopulation]    Script Date: 5/9/2022 8:49:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[spGetAudienceList_BasePopulation](@criteria [CampaignAudienceCriteriaType] ReadOnly)

as
begin
set nocount on
declare @MassMailAllowed bit;
declare @CampaignId int;
declare @UniqueRecipientsOnly bit;
declare @BasePopulationType BasePopulationType;
--Users will receive formal
set @MassMailAllowed = 1;


--Users will receive informal and formal
if(exists(select MassMailAllowed from @criteria where MassMailAllowed = 1))
begin 
	set @MassMailAllowed = 0;
end 

select @CampaignId  = CampaignId from @Criteria;
select @UniqueRecipientsOnly  = UniqueRecipientsOnly  from @Criteria;

	
	SELECT distinct
		ldap.Pid,
		ldap.MassEmailAllowed,
		
			case when 
			  crit.pid = ldap.pid 
			 or crit.uid = ldap.uid
			 or crit.AcademicGroupCode = lsag.AcademicGroupCode
			 or crit.AcademicLevelCode = lsy.AcademicLevelCode
			 or crit.AcademicYear = lsy.AcademicYear
			 or crit.Graduate = lsy.Graduate
			 or crit.VisitingExchange = lsy.VisitingExchange then 1 else 0 end FoundMatch
			
			
			FROM 

			[MassMail].[LdapUser] AS [ldap]
			left join [MassMail].Recipient as R on R.pid = ldap.Pid and R.CampaignId = @CampaignId
			LEFT JOIN [MassMail].[LdapStudent] AS [ldapStudent] ON [ldap].[Pid] = [ldapStudent].[Pid]
			LEFT JOIN [MassMail].[LdapStudentAcademicGroup] AS [lsag] ON [ldapStudent].[LdapStudentAcademicGroupId] = [lsag].[Id]
			LEFT JOIN [MassMail].[LdapStudentYear] AS [lsy] ON [ldapStudent].[LdapStudentYearId] = [lsy].[Id]
			LEFT JOIN [DDDList] AS [d] ON [ldap].[Pid] = [d].[Id]
			join @criteria crit on 
					(
					1=1
					and ((ldap.MassEmailAllowed = 0 and crit.MassMailAllowed   = 1)
					      or ldap.MassEmailAllowed  = 1)


					and ldap.pid = case when crit.pid is not null then  crit.pid else ldap.pid end
					and ldap.uid = case when crit.uid is not null then  crit.uid else ldap.uid end
					and (lsag.AcademicGroupCode is null or lsag.AcademicGroupCode = case when crit.AcademicGroupCode is not null then  crit.AcademicGroupCode else lsag.AcademicGroupCode end)
					and (lsy.AcademicLevelCode  is null or lsy.AcademicLevelCode = case when crit.AcademicLevelCode is not null then  crit.AcademicLevelCode else lsy.AcademicLevelCode end)
					and (lsy.AcademicYear  is null or lsy.AcademicYear = case when crit.AcademicYear is not null then  crit.AcademicYear else lsy.AcademicYear end)
					and (lsy.Graduate  is null or lsy.Graduate = case when crit.Graduate is not null then  crit.Graduate else lsy.Graduate end)
					and (lsy.VisitingExchange  is null or lsy.VisitingExchange = case when crit.VisitingExchange is not null then  crit.VisitingExchange else lsy.VisitingExchange end)
				 
					 )
			where 1=1
			and ldap.Mail is not null
			and 1 =
			case when @UniqueRecipientsOnly = 1 and R.pid is null then 1
			     when @UniqueRecipientsOnly = 0 then 1
			else 0
			end;


			

set nocount off

end
GO

