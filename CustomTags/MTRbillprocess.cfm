<!--- 
Performs the billing as checked earlier using billchk on a case.
Uses the resultset Request.q_bill set by the <CFMODULE TEMPLATE="#Request.LOGPATH#CustomTags\MTRBILLchk...cfm"> earlier.

Parameters:
	CASEID: Billing for which case. Defaults to Request.BillCaseID
	ORGID: Company who incurred the bill. Defaults to orgid.
	USERID: User who incurred the bill. Defaults to current user.
Return Values :
--->
<CFIF IsDefined("Request.q_bill") AND IsQuery(Request.q_bill) AND Request.q_bill.recordcount GT 0>
	<CFPARAM Name=Attributes.COID type=numeric Default=#Request.BillCOID#>
	<CFPARAM Name=Attributes.CASEID type=numeric Default=#Request.BillCASEID#>
	<CFPARAM Name=Attributes.EXTID type=numeric Default=#Request.BillEXTID#>
	<CFPARAM Name=Attributes.CLMGROUP type=string Default=#Request.BillCLMGROUP#>
	<!---CFPARAM Name=Attributes.USERID Default="#SESSION.VARS.USERID#">
	<CFOUTPUT query=Request.q_bill>
	<CFIF AMT GT 0>
		<!---CFSET FORCOID=Request.q_bill.FORCOID><CFIF NOT(FORCOID GT 0)><CFSET FORCOID=SESSION.VARS.ORGID></CFIF--->
		<CFMODULE TEMPLATE="#Request.LOGPATH#CustomTags\MTRBILL.cfm" coid=#FORCOID# payeecoid=#COID# type=#type# user='#Attributes.UserID#' caseid=#Attributes.CASEID# AMT='#AMT#'>
		<!---CFMODULE TEMPLATE="#Request.LOGPATH#CustomTags\MTRBILL.cfm" coid=#Attributes.ORGID# payeecoid=#COID# type=#type# user='#Attributes.UserID#' caseid=#Attributes.CASEID# AMT='#Request.q_bill.AMT#'--->
	<!---CFELSE>
		<CFMODULE TEMPLATE="#Request.LOGPATH#CustomTags\MTRBILL.cfm" coid=#Attributes.ORGID# payeecoid=#COID# type=#type# user='#Attributes.UserID#' caseid=#Attributes.CASEID#--->
	</CFIF>
	</cfoutput--->

	<!--- Always call back the MTRbillchk module to ensure the correct amount being charged, esp. when VAT is activated --->
	<CFMODULE TEMPLATE="#Request.LOGPATH#CustomTags\MTRBILLCHK.cfm" COID=#Attributes.COID# CASEID=#Attributes.CASEID# EXTID=#Attributes.EXTID# CLMGROUP=#Attributes.CLMGROUP# BILLNOW=1 CHKLIMIT>
</CFIF>