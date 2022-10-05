<!--- 
Formats URL for dateranges URL.DRFROM/DRTO to
American format for queries, and generate
HTML controls for setting date range. Include
out of form.

Return Values : 
Caller.DtMthStr: Formatted to American for SQL
Caller.DRText:
--->
<CFIF NOT IsDefined("rptmth")><CFSET rptmth=""><!---<CFPARAM NAME=URL.DTMTH DEFAULT="">---></cfif>
<CFPARAM NAME=Attributes.Width DEFAULT="90%">
<CFIF IsDefined("FORM.DTMTH")>
	<CFIF FORM.DTMTH IS ""><CFSET FORM.DTMTH=rptmth></CFIF>
</cfif>
<CFIF rptmth IS NOT "">
	<!---<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCdtLOCtoDB.cfm" DT=#rptmth# DISP=0 VARRESULT="Caller.DtMthStr">--->
	<CFSET Caller.DtMthStr = rptmth>
	<CFSET Caller.DRText=rpttext>
<CFELSE>
	<CFSET Caller.DtMthStr = "01/01/1900">
	<CFSET Caller.DRText="">
</cfif>
<!--- report query options --->
<CFOUTPUT><TABLE class=clsNoPrint id=rptheader border=0 align=center cellpadding=1 cellspacing=1 style=WIDTH:#Attributes.Width#>
</cfoutput>
<br>
<tr><td align="right" width=40%><b><cfoutput>#Server.SVClang("For the Month of:",5945)#</cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;</b></td>
	<td><SELECT CHKREQUIRED name=selmth onBlur=CSMonthSelect()> 
	<option selected>
	<CFSET startmth = 2001*12+10>
	<CFSET endmth = LSParseNumber(dateformat(now(),"yyyy"))*12+LSParseNumber(dateformat(now(),"mm"))-1>
	<cfoutput>
	<CFLOOP INDEX="mthrange" step="-1"
    	FROM=#endmth#
   		TO=#startmth#>
	<CFSET lyear = Int(mthrange/12)>
	<CFSET lmth = #mthrange# MOD 12>
	<CFIF lmth IS 0>
		<CFSET lyear = lyear-1>
		<CFSET lmth = 12>
	</cfif>
	<CFSWITCH expression=#lmth#>
		<CFCASE value=1><CFSET mthstr="Jan"></cfcase>
		<CFCASE value=2><CFSET mthstr="Feb"></cfcase>
		<CFCASE value=3><CFSET mthstr="Mar"></cfcase>
		<CFCASE value=4><CFSET mthstr="Apr"></cfcase>
		<CFCASE value=5><CFSET mthstr="May"></cfcase>
		<CFCASE value=6><CFSET mthstr="Jun"></cfcase>
		<CFCASE value=7><CFSET mthstr="Jul"></cfcase>
		<CFCASE value=8><CFSET mthstr="Aug"></cfcase>
		<CFCASE value=9><CFSET mthstr="Sep"></cfcase>
		<CFCASE value=10><CFSET mthstr="Oct"></cfcase>
		<CFCASE value=11><CFSET mthstr="Nov"></cfcase>
		<CFCASE value=12><CFSET mthstr="Dec"></cfcase>
	</cfswitch>
	<OPTION value=#lmth#/01/#lyear#<CFIF rptmth IS "#lmth#/01/#lyear#"> SELECTED</CFIF>>#UCASE(mthstr)# #lyear#</OPTION>
	
	<CFSET startmth=startmth+1>
	</CFLOOP>
	</cfoutput>
	</SELECT>
	
	</td></tr>
	<tr style="display:none"><td colspan=2><input name=DTMTH id=DTMTH></td></tr>
	<tr style="display:none"><td colspan=2><input name=DTMTHSTR id=DTMTHSTR></td></tr>
</TABLE>
<script>
AddOnloadCode("CSMonthSelect();");
function CSMonthSelect()
{
	var selobj=document.all("selmth");
	var tempstr2=selobj.options[selobj.selectedIndex].text;
	var tempstr=document.all("selmth").value;
	document.all("DTMTH").value=tempstr;
	document.all("DTMTHSTR").value=tempstr2;
	
}
</script>