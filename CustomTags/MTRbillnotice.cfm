<!--- 
Parameters:
	CoID: OrgID to be billed
	CaseID: Case to bill to
	ChkLimit: =1/blank: Raise error if insufficient
	ShowBlockQuote: Whether to wrap the content in a blockquote (red text)
Return Values :
	Caller.BillResult = 1 - Billing involved
						2 - Billing
	Caller.PayMode = Payment mode (0,1,3).
	Caller.Credit  = Payee's credit points
--->

<cfif IsDefined("Caller.BillResult") AND Caller.BillResult GE 0 AND IsDefined("Request.q_bill") AND IsQuery(Request.q_bill) AND Request.q_bill.recordcount GT 0>
	<cfparam name=Attributes.ShowBlockQuote type=numeric default=1>
	<CFIF Attributes.ShowBlockQuote IS 1><blockquote CLASS=clsColorWarning style="padding:2px">
	<div align=center style=width:100%><div style=text-align:left;width:80%></CFIF>
	<cfoutput>#Server.SVClang("By proceeding to the next page, you may be charged for your usage of {0} system.",1146,0,"<cfoutput>#Application.APPFULLNAME#</cfoutput>'s")#</cfoutput>
	<!---cfif IsDefined("Request.q_bill") AND IsQuery(Request.q_bill) AND Request.q_bill.recordcount GT 0--->
	<br><br><ul>
	<cfoutput query=Request.q_bill>
	<li>
	<cfif cotype IS NOT "O">
		<cfif cotype IS "R">
		#Server.SVClang("{0} points for {1}, billed to Repairer",3577,0,"#Request.DS.FN.SVCNum(AMT)#","#DSC#")#
		<cfelseif cotype IS "A">
		#Server.SVClang("{0} points for {1}, billed to Adjuster",3578,0,"#Request.DS.FN.SVCNum(AMT)#","#DSC#")#
		<cfelseif cotype IS "I">
		#Server.SVClang("{0} points for {1}, billed to Insurer",3579,0,"#Request.DS.FN.SVCNum(AMT)#","#DSC#")#
		<cfelseif cotype IS "L">
		#Server.SVClang("{0} points for {1}, billed to Solicitor",7717,0,"#Request.DS.FN.SVCNum(AMT)#","#DSC#")#
		<cfelseif cotype IS "EA">
		#Server.SVClang("{0} points for {1}, billed to External/TP Administrator",36014,0,"#Request.DS.FN.SVCNum(AMT)#","#DSC#")#
		</cfif>
	<cfelse>
		#Server.SVClang("{0} points for {1}",3580,0,"#Request.DS.FN.SVCNum(AMT)#","#DSC#")#
	</cfif>
	<!---CFIF cotype is not "O">
	(#HTMLEditFormat(BILLCONAME)#)
	</CFIF--->
	<CFIF IsDefined("siVATinTRX") AND siVATinTRX IS 0><span style="font-size:80%">&nbsp;&nbsp;[ #Server.SVClang("excluding tax which will be added in monthly invoice",52103)# ]</span></CFIF>
	</li>
	</cfoutput>
	</ul>
	<!---/cfif--->
	<cfif IsDefined("Caller.BillPaymode")>
		<cfif BitAnd(Caller.BillPaymode,1) IS 0>
			<cfif IsDefined("Caller.BillCredit")>
			<br><cfoutput>#Server.SVClang("Current Credit Points Balance:",1147)#</cfoutput> <cfoutput>#Caller.BillCredit#</cfoutput>
			</cfif>
		</cfif>
	</cfif>
	<CFIF Attributes.ShowBlockQuote IS 1></div></div>
	</blockquote></CFIF>
</cfif>