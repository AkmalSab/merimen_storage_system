<CFIF NOT(Len(Application.ApplicationName) GT 6 AND Right(Application.ApplicationName,6) IS "_train")>
<CFPARAM name="Attributes.user" default="UNKNOWN">
<CFPARAM name="Attributes.caseid" default="0">
<CFPARAM name="Attributes.amt" default="NULL">
<CFPARAM name="Attributes.type" default="0">
<cfstoredproc datasource="#Request.MTRDSN#" procedure="sspBILBill" returncode="Yes">
<cfprocparam TYPE=IN cfsqltype=CF_SQL_INTEGER value="#attributes.coid#" DBVARNAME=@ai_initcoid>
<CFIF IsDefined("Attributes.PayeeCOID")>
	<cfprocparam TYPE=IN cfsqltype=CF_SQL_INTEGER value="#attributes.payeecoid#" DBVARNAME=@ai_billcoid>
<CFELSE>
	<cfprocparam TYPE=IN cfsqltype=CF_SQL_INTEGER value=0 NULL=YES DBVARNAME=@ai_billcoid>
</cfif>
<cfprocparam TYPE=IN cfsqltype=CF_SQL_INTEGER value="#attributes.type#" DBVARNAME=@ai_billt>
<cfprocparam TYPE=IN cfsqltype=CF_SQL_INTEGER value="#SESSION.VARS.USID#" DBVARNAME=@ai_initusid>
<cfprocparam TYPE=IN cfsqltype=CF_SQL_INTEGER value=1 DBVARNAME=@ai_domid>
<CFIF attributes.caseid GT 0>
	<cfprocparam TYPE=IN cfsqltype=CF_SQL_INTEGER value="#attributes.caseid#" DBVARNAME=@ai_objid>
<CFELSE>
	<cfprocparam TYPE=IN cfsqltype=CF_SQL_INTEGER value=0 null=yes DBVARNAME=@ai_objid>
</CFIF>
<CFIF IsDefined("attributes.remark")>
<cfprocparam TYPE=IN cfsqltype=CF_SQL_VARCHAR value="#attributes.remark#" DBVARNAME=@as_remark>
<CFELSE>
<cfprocparam TYPE=IN cfsqltype=CF_SQL_VARCHAR value="" null=yes DBVARNAME=@as_remark>
</cfif>
<CFIF UCase(Trim(attributes.amt)) IS "NULL">
	<cfprocparam type=IN cfsqltype=CF_SQL_MONEY null=yes value=0 DBVARNAME=@amn_amount>
<CFELSE>
	<cfprocparam type=IN cfsqltype=CF_SQL_MONEY value="#attributes.amt#" DBVARNAME=@amn_amount>
</CFIF>
</cfstoredproc>
<CFSET Caller.BillResult = CFSTOREDPROC.StatusCode>
<!---CFIF Caller.BillResult IS -1>
	<CFTHROW Type=EX_DBERROR ErrorCode=BILLING>
</CFIF--->
<CFIF Caller.BillResult LT 0>
	<CFTHROW Type=EX_DBERROR ErrorCode="BILLING(#Caller.BillResult#)">
</CFIF>
</cfif>