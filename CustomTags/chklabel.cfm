<cfsilent>
<cfparam name="attributes.caseid" default="">
<cfparam name="Attributes.CHKLABEL" default=""><!--- label ID list, either in +ve or ~[labelid] --->
<cfif attributes.caseid IS ""><CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADPARAM" EXTENDEDINFO="CHKLABEL/1"></cfif>
<CFSTOREDPROC PROCEDURE="sspFOBJLabelGet" DATASOURCE=#Request.SVCDSN# RETURNCODE=YES>
<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=1 DBVARNAME=@ai_domainid>
<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#Attributes.CaseID# DBVARNAME=@ai_objid>
<CFPROCPARAM TYPE=out CFSQLTYPE=CF_SQL_VARCHAR variable="CALLER.CASELABEL" DBVARNAME=@labellist>
<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER value=1 DBVARNAME=@mode>
</CFSTOREDPROC>
<cfif attributes.CHKLABEL NEQ "">
	<cfloop list=#attributes.CHKLABEL# index="value">
		<cfif (LEFT(value,1) IS "~" AND LISTFIND(CALLER.CASELABEL,value) IS 0) OR ( LEFT(value,1) NEQ "~" AND LISTFIND(CALLER.CASELABEL,value) GT 0)>
			<!--- do nothing --->
		<cfelse>
			<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCSTAT" EXTENDEDINFO="Invalid case access with specific label">
		</cfif>
	</cfloop>
</cfif>
</cfsilent>