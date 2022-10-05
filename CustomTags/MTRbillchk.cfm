<!--- 
Parameters:
	CoID: OrgID to be billed
	CaseID: Case to bill to
	ChkLimit: =1/blank: Raise error if insufficient
	claimtype: case's claim type
Return Values :
	Caller.BillResult = 1 - Billing involved
						2 - Billing
	Caller.PayMode = Payment mode (0,1,3).
	Caller.Credit  = Payee's credit points
--->

<CFPARAM NAME=Attributes.COID type=numeric>
<CFPARAM NAME=Attributes.CASEID type=numeric DEFAULT=0>
<CFPARAM NAME=Attributes.EXTID type=numeric DEFAULT=0>
<CFPARAM NAME=Attributes.CLMGROUP type=string DEFAULT="MTR">
<CFPARAM NAME=Attributes.BILLNOW type=numeric DEFAULT=0>
<CFPARAM NAME=attributes.BILLNOTICE type=numeric default=0>
<cfif attributes.clmgroup IS "MTR">
    <cfset acctypeid=1>
<cfelseif attributes.clmgroup IS "NM">
    <cfset acctypeid=2>
<cfelseif attributes.clmgroup IS "TRUESIGHT">
	<cfset acctypeid=7>
<cfelse>
    <cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCASE" ExtendedInfo="Unknown Account">
</cfif>
<CFSTOREDPROC DATASOURCE=#Request.MTRDSN# PROCEDURE=sspBILCheckBillCase RETURNCODE=Yes>
<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#Attributes.COID# DBVARNAME=@ai_coid>
<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#Attributes.CASEID# DBVARNAME=@ai_caseid>
<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_NUMERIC SCALE=2 DBVARNAME=@ai_credit VARIABLE="Caller.BillCredit">
<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_SMALLINT DBVARNAME=@asi_paymode VARIABLE="Caller.BillPaymode">
<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_SMALLINT VALUE=#Attributes.BILLNOW# DBVARNAME=@asi_billnow>
<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#acctypeid# DBVARNAME=@ai_acctype>
<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#SESSION.VARS.USID# DBVARNAME=@ai_usid>
<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_SMALLINT VALUE=#attributes.BILLNOTICE# DBVARNAME=@asi_shownotice>
<CFIF Attributes.EXTID GT 0>
	<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#Attributes.EXTID# DBVARNAME=@ai_extid>
<CFELSE>
	<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER NULL=YES DBVARNAME=@ai_extid>
</CFIF>
<CFPROCRESULT NAME=Request.q_bill>
</CFSTOREDPROC>
<CFSET Caller.BillResult=CFSTOREDPROC.STATUSCODE>
<CFIF Caller.BillResult IS -2>
	<CFIF IsDefined("Attributes.ChkLimit") AND Attributes.ChkLimit IS 1>
		<CFTHROW Type=EX_SECFAILED ErrorCode=NOCREDITS>
	</CFIF>
<cfelseif Caller.BillResult is -20><!--- 19913 --->
	<cfif IsDefined("Attributes.ChkLimit") AND Attributes.ChkLimit is 1>
		<cfthrow type=EX_SECFAILED errorcode=NOCREDITS>
	</cfif>
<cfelseif Caller.BillResult is -30><!--- #27940,#29945 --->
	<cfif Application.APPLOCID IS 1 AND acctypeid IS 1>
		<CFTHROW Type=EX_SECFAILED ErrorCode=NOCREDITS ExtendedInfo="The account being billed has insufficient credit (minimum 20 required)">
	<cfelseif Application.APPLOCID IS 1 AND acctypeid IS 2>
		<CFTHROW Type=EX_SECFAILED ErrorCode=NOCREDITS ExtendedInfo="The account being billed has insufficient credit (minimum 30 required)">
	<cfelse>
		<CFTHROW Type=EX_SECFAILED ErrorCode=NOCREDITS ExtendedInfo="The account being billed has insufficient credit">
	</cfif>
<CFELSEIF Caller.BillResult IS -100>
	<CFTHROW Type=EX_SECFAILED ErrorCode=NOCREDITS ExtendedInfo="Invalid Account Setup">
<CFELSEIF Caller.BillResult LT 0>
	<CFTHROW Type=EX_DBERROR ErrorCode="BILCHKBILLCASE(#Caller.BillResult#)">
</cfif>

<CFSET Request.BillCOID=Attributes.COID>
<CFSET Request.BillCASEID=Attributes.CASEID>
<CFSET Request.BillCLMGROUP=Attributes.CLMGROUP>
<CFSET Request.BillEXTID=Attributes.EXTID>
