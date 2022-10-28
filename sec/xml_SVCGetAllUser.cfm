<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCDISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">
<!---
This cfm will output a standard XML content. Used in Merimen Scanning Tool for retrieving a specific car information.
TODO:
- Filter certain case statuses
- Check for COID
--->
<!--- SQL query --->
<cfparam name="URL.R" default="50">
<!--- sort --->
<cfparam name="URL.E" default="">
<!--- filter --->
<cfparam name="URL.F" default="">
<!---gcoid--->
<cfparam name="URL.G" default="">
<cfparam name="URL.CLMTYPEMASK" default="">
<cfparam name="URL.SHOWPHONE" default=0>

<cfparam name="URL.S" default=""> <!--- user section --->
<cfparam name="URL.RRGROUP" default=""> <!--- 45474 - Round Robin group --->

<!--- search mode --->
<!---cfparam name="attributes.M" default=0--->
<!---cfparam name="attributes.criteria" default="">
<cfparam name="attributes.sicotypeid" default="">
<cfparam name="attributes.vaCompanyCriteria" default=""--->

<cfset URL.F=Replace(URL.F,"'","","ALL")>
<cfoutput>
<cfquery name="q_AllUsers" datasource=#request.SVCDSN#>

	select DISTINCT TOP <!--- @CFIGNORESQL_S --->#VAL(URL.R)#<!--- @CFIGNORESQL_E ---> p.iUSID,p.vaUSID,p.vausname,p.aTELNO,p.vamphone from
	
	SEC0001 p with (nolock)
	LEFT JOIN FOBJ3025 sect with (nolock) on sect.silogtype=901 AND sect.idomid=11 and sect.iOBJID=p.iUSID and sect.sistatus=0
	where p.sistatus=0
	<CFIF URL.F IS NOT "">
		and (vaUSID like N'%'+<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#URL.F#">+'%' or vaUSNAME like N'%'+<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#URL.F#">+'%')
	</CFIF>
	<CFIF URL.CLMTYPEMASK IS NOT "">
	and iCLMTYPEACCMASK&<cfqueryparam cfsqltype="cf_sql_integer" value="#URL.CLMTYPEMASK#">>0
	</CFIF>
	<cfif URL.G eq "">
		
		-- 45474
		<cfif URL.G NEQ 1510007>
			<cfif URL.RRGROUP neq "">
				AND p.iUSID IN (SELECT iBGRPDOMVAL FROM BIZ0020 WITH(NOLOCK) WHERE iBGRPID=<cfqueryparam cfsqltype="cf_sql_integer" value="#URL.RRGROUP#">)
			</cfif>
		<cfelse>
			and p.iCOID=<cfqueryparam cfsqltype="cf_sql_integer" value="#URL.E#">
		</cfif>

	<cfelse>
	and p.icoid in (select icoid from sec0005 where igcoid = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.G#">)
	</cfif>
	<CFIF URL.S NEQ "">
		and sect.i1 IN (SELECT val FROM StringToTable(<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#URL.S#">, ','))
	</CFIF>
	<!---cfif attributes.sicotypeid NEQ "">
		and sicotypeid=<cfqueryparam value="#attributes.sicotypeid#" cfsqltype="CF_SQL_NUMERIC">
	</cfif--->
		
	<!---cfif attributes.vaCompanyCriteria NEQ "">
		and (vaconame like '%#attributes.vaCompanyCriteria#%' or vacomailprefix like '%#attributes.vaCompanyCriteria#%')
	</cfif--->	
	<cfif  URL.G EQ 200036>
		ORDER BY p.vausname
	</cfif>
	
	<!---order by iusid--->

</cfquery>
</cfoutput>

<!--- XML output --->
<cfcontent reset="yes" type="text/xml; charset=utf-8"><cfoutput><?xml version="1.0" standalone="yes"?>
<company>
	<summary>
		<title>User Search</title>
		<recordcount>#q_AllUsers.recordcount#</recordcount>
		<columns>iUSID,User ID,User Name<CFIF URL.SHOWPHONE IS 1>,Tel Phone,Mobile Phone</CFIF></columns>
	</summary></cfoutput>
		<cfoutput query="q_AllUsers">
		<data>
			<iUSID>#iUSID#</iUSID>
			<vaUSID>#XMLFormat(vaUSID)#</vaUSID>
			<vaUSNAME>#XMLFormat(vaUSNAME)#</vaUSNAME>
			<CFIF URL.SHOWPHONE IS 1>	
			<aTELNO>#XMLFormat(aTELNO)#</aTELNO>	
			<vamphone>#XMLFormat(vamphone)#</vamphone>
			</CFIF>			
		</data>
		</cfoutput>
<cfoutput>
</company>
</cfoutput>


