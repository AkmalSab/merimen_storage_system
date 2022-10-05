<!--- 
Formats URL for dateranges URL.DRFROM/DRTO to
American format for queries, and generate
HTML controls for setting date range. Include
out of form.

Return Values : 
Caller.DtMthStr: Formatted to American for SQL
Caller.DRText:
--->
<CFIF NOT IsDefined("rptqtr")><CFSET rptqtr=""></cfif>
<CFPARAM NAME=Attributes.Width DEFAULT="90%">
<CFIF IsDefined("FORM.DTQTR")>
	<CFIF FORM.DTQTR IS ""><CFSET FORM.DTQTR=rptqtr></CFIF>
</cfif>
<CFIF rptqtr IS NOT "">
	<!---<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCdtLOCtoDB.cfm" DT=#rptmth# DISP=0 VARRESULT="Caller.DtMthStr">--->
	<CFSET Caller.DtQtrStr = rptqtr>
	<CFSET Caller.DRText=rpttext>
<CFELSE>
	<CFSET Caller.DtQtrStr = "01/01/1900">
	<CFSET Caller.DRText="">
</cfif>
<!--- report query options --->
<CFOUTPUT><TABLE class=clsNoPrint id=rptheader border=0 align=center cellpadding=1 cellspacing=1 style=WIDTH:#Attributes.Width#>
</cfoutput>
<br>
<tr><td align="right" width=40%><b><cfoutput>#Server.SVClang("For the Quarter of:",3576)#</cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;</b></td>
	<td><SELECT CHKREQUIRED name=selqtr onBlur=CSQuarterSelect()> 
	<option selected>
	<CFSET startqtr = 2006*4+3><!--- plus last number which represents quarter --->
	<CFSET endqtr = LSParseNumber(dateformat(now(),"yyyy"))*4+4>
	<cfset curyr=LSParseNumber(dateformat(now(),"yyyy"))>
	<cfset curmth=LSParseNumber(dateformat(now(),"mm"))>
	<cfoutput>
	<CFLOOP INDEX="qtrrange" step="-1"
    	TO=#startqtr#
   		FROM=#endqtr#>
	<CFSET lyear = Int(qtrrange/4)>
	<CFSET lqtr = #qtrrange# MOD 4>
	<CFIF lqtr IS 0>
		<CFSET lyear = lyear-1>
		<CFSET lqtr = 4>
	</cfif>
	<CFSWITCH expression=#lqtr#>
		<CFCASE value=1><CFSET qtrstr="1st Qtr"><CFSET lmth=1></cfcase>
		<CFCASE value=2><CFSET qtrstr="2nd Qtr"><CFSET lmth=4></cfcase>
		<CFCASE value=3><CFSET qtrstr="3rd Qtr"><CFSET lmth=7></cfcase>
		<CFCASE value=4><CFSET qtrstr="4th Qtr"><CFSET lmth=10></cfcase>
	</cfswitch>
	<cfif LSParseNumber(curyr&IIf(Len(curmth) EQ 1,"0"&curmth,curmth)) GTE (3+LSParseNumber(lyear&IIf(Len(lmth) EQ 1,"0"&lmth,lmth)))>
	<OPTION value=#lmth#/01/#lyear#<CFIF rptqtr IS "#lmth#/01/#lyear#"> SELECTED</CFIF>>#lyear# #UCASE(qtrstr)#</OPTION>
	</cfif>
	<CFSET startqtr=startqtr+1>
	</CFLOOP>
	</cfoutput>
	</SELECT>
	
	</td></tr>
	<tr style="display:none"><td colspan=2><input name=DTQTR id=DTQTR></td></tr>
	<tr style="display:none"><td colspan=2><input name=DTQTRSTR id=DTQTRSTR></td></tr>
</TABLE>
<script>
AddOnloadCode("CSQuarterSelect();");
function CSQuarterSelect()
{
	var selobj=document.all("selqtr");
	var tempstr2=selobj.options[selobj.selectedIndex].text;
	var tempstr=document.all("selqtr").value;
	document.all("DTQTR").value=tempstr;
	document.all("DTQTRSTR").value=tempstr2;
	
}
</script>