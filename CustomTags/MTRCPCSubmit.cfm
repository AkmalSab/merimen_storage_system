<CFPARAM NAME=Attributes.Override DEFAULT=0>

<CFTRY>
<CFSET Caller.CPCResult=0>
<CFIF IsDefined("SESSION.VARS.USERID")>
	<CFSET CPCUSERID="#SESSION.VARS.USERID#">
<CFELSE>
	<CFSET CPCUSERID="unlogged">
</cfif>
<CFSTOREDPROC PROCEDURE="sspCPCWrite" DATASOURCE=#Request.MTRDSN# RETURNCODE=YES>
<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#Attributes.CaseID# DBVARNAME=@ai_caseid>
<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_SMALLINT VALUE=#Attributes.Type# DBVARNAME=@asi_cpctypeid>
</CFSTOREDPROC>
<CFSET returncode = CFSTOREDPROC.StatusCode>
<CFIF returncode LT 0>
	<CFTHROW TYPE=EX_DBERROR ErrorCode="CPCSUBMIT(#returncode#)">
</CFIF>
<CFCATCH>
	<!--- Error populating to CPC, write to DB --->
	<CFSET Caller.CPCResult=-1>
	<CFQUERY NAME=q_trx DATASOURCE=#Request.MTRDSN#>
	INSERT INTO AUD0009 (iLCASEID,siCPCTYPE,aCRTBY)
	VALUES (<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CaseID#">,<cfqueryparam cfsqltype="CF_SQL_SMALLINT" value="#Attributes.Type#">,<cfqueryparam cfsqltype="CF_SQL_CHAR" value="#CPCUSERID#">)
	</cfquery>
	<CFRETHROW>
</CFCATCH>
</CFTRY>