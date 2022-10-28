<cfdump  var="#Request#"><cfabort>
<cfstoredproc PROCEDURE='sspFSECCreateUserGroup' DATASOURCE=#Request.mtrdsn# RETURNCODE=YES>
	<CFPROCPARAM TYPE=IN  DBVARNAME=@grpname VALUE=#form.grpname# CFSQLTYPE=CF_SQL_VARCHAR>
	<CFPROCPARAM TYPE=IN  DBVARNAME=@desc VALUE=#form.desc# CFSQLTYPE=CF_SQL_VARCHAR>
	<CFPROCPARAM TYPE=IN  DBVARNAME=@creator VALUE=#session.vars.usid# CFSQLTYPE=CF_SQL_INTEGER>
	<CFPROCPARAM TYPE=IN  DBVARNAME=@icoid VALUE=#attributes.iobjid# CFSQLTYPE=CF_SQL_INTEGER>

</cfstoredproc>
<cfset cur_groupid = CFSTOREDPROC.STATUSCODE>

	<cfif cur_groupid LT 0>
		<cfthrow TYPE=EX_DBERROR ErrorCode="Error Creating User Group">
	</cfif>

<cfif form.leader_name neq "">
<cfset form.leader_name=replace(form.leader_name,' ','','all')>
<cfset form.leader_name = ''''&Replace(form.leader_name,';',''',''','all')&''''>

<cfquery name=breaklist datasource=#request.mtrdsn#>
select iusid from sec0001 where vausid IN (<cfqueryparam value="#PreserveSingleQuotes(form.leader_name)#" cfsqltype="CF_SQL_NVARCHAR" list="true">)
</cfquery>

<cfoutput query=breaklist>
<cfstoredproc PROCEDURE='sspFSECModUserGroup' DATASOURCE=#Request.mtrdsn# RETURNCODE=YES>
	<CFPROCPARAM TYPE=IN  DBVARNAME=@group_id VALUE=#cur_groupid# CFSQLTYPE=CF_SQL_INTEGER>
	<CFPROCPARAM TYPE=IN  DBVARNAME=@user_id VALUE=#iusid# CFSQLTYPE=CF_SQL_INTEGER>
	<CFPROCPARAM TYPE=IN  DBVARNAME=@action_type VALUE=1 CFSQLTYPE=CF_SQL_INTEGER>
	<CFPROCPARAM TYPE=IN  DBVARNAME=@leadership VALUE=1 CFSQLTYPE=CF_SQL_SMALLINT>		
</cfstoredproc>
	<cfset returncode=CFSTOREDPROC.StatusCode>
	<cfif returncode LT 0>
		<cfthrow TYPE=EX_DBERROR ErrorCode="Error Modifying User Group">
	</cfif>
</cfoutput>
</cfif>

<cfif form.member_name neq "">
<cfset form.member_name=replace(form.member_name,' ','','all')>
<cfset form.member_name = ''''&Replace(form.member_name,';',''',''','all')&''''>

<cfquery name=breaklist datasource=#request.mtrdsn#>
select iusid from sec0001 where vausid IN (<cfqueryparam value="#PreserveSingleQuotes(form.member_name)#" cfsqltype="CF_SQL_NVARCHAR" list="true">)
</cfquery>

<cfoutput query=breaklist>
<cfstoredproc PROCEDURE='sspFSECModUserGroup' DATASOURCE=#Request.mtrdsn# RETURNCODE=YES>
	<CFPROCPARAM TYPE=IN  DBVARNAME=@group_id VALUE=#cur_groupid# CFSQLTYPE=CF_SQL_INTEGER>
	<CFPROCPARAM TYPE=IN  DBVARNAME=@user_id VALUE=#iusid# CFSQLTYPE=CF_SQL_INTEGER>
	<CFPROCPARAM TYPE=IN  DBVARNAME=@action_type VALUE=1 CFSQLTYPE=CF_SQL_INTEGER>
	<CFPROCPARAM TYPE=IN  DBVARNAME=@leadership VALUE=0 CFSQLTYPE=CF_SQL_SMALLINT>		
</cfstoredproc>
	<cfset returncode=CFSTOREDPROC.StatusCode>
	<cfif returncode LT 0>
		<cfthrow TYPE=EX_DBERROR ErrorCode="Error Modifying User Group">
	</cfif>
</cfoutput>
</cfif>


