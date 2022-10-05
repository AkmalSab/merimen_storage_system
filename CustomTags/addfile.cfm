<!--- 
Checks for the script to use in the application.
Parameters: FNAME: Logical name of the application (required)
NOGEN: Do not generate SCRIPT element
PATH: Logical path name
Return Values : RESULT: Filename
--->
<CFPARAM NAME=Attributes.NoGen Default=0>
<CFSET Ret=Request.DS.FN.SVCSvrFileInclude("MTR",Attributes.FName,Attributes.NoGen)>
<CFIF Ret.NoGen IS 0><CFOUTPUT>#RET.HTMSTR#</CFOUTPUT></CFIF>
<CFSET Caller.Result=Ret.PATH>
<!---cfset Attributes.FName=UCase(Trim(Attributes.FName))><cfset Script="JScript.Encode">
<cfparam name="Request.AddedList" default="">
<cfparam name=APPLOCID default=#Application.APPLOCID#>
<CFSET FN=Request.DS.FN>

<cfif ListFind(Request.AddedList, Attributes.FName) is 0>

<cfset Request.AddedList = ListAppend(Request.AddedList, Attributes.FName)>

<cfif Not StructKeyExists(Attributes,"NoGen") OR Attributes.NoGen IS 0>
	<cfoutput>#FN.SVCSvrFileInclude('MTR',Attributes.FName).htmstr#</cfoutput>
</cfif>

<!---
<cfsilent><cfset Request.AddedList = ListAppend(Request.AddedList, Attributes.FName)>
<cfswitch EXPRESSION="#Attributes.FName#">
	<cfcase VALUE="MERI"><cfset SCRIPT="JavaScript"><cfset File0="unencoded/meri9200.js"></cfcase>
	<cfcase VALUE="MES"><cfset SCRIPT="JavaScript"><cfset File0="unencoded/mes9200.js"></cfcase>
	<cfcase VALUE="MCLM"><cfset SCRIPT="JavaScript"><cfset File0="unencoded/mclm9200.js"></cfcase>
	<cfcase VALUE="MPL"><cfset SCRIPT="JavaScript"><cfset File0="unencoded/mpl9200.js"></cfcase>
	<cfcase VALUE="TFW"><cfset SCRIPT="JavaScript"><cfset File0="unencoded/tfw9200.js"></cfcase> 
	<cfcase VALUE="MWP"><cfset SCRIPT="JavaScript"><cfset File0="unencoded/wp9200.js"></cfcase>
	<cfcase VALUE="MTRrep"><cfset SCRIPT="JavaScript"><cfset File0="unencoded/MTRrep9200.js"></cfcase>
	<cfcase VALUE="MTRappvars"><cfset SCRIPT="JavaScript"><cfset File0="unencoded/MTRappvars9200.js"></cfcase>
	<cfcase VALUE="MTRmenugen"><cfset SCRIPT="JavaScript"><cfset File0="unencoded/MTRmenugen9200.js"></cfcase>
	<cfcase VALUE="MTRmenuins"><cfset SCRIPT="JavaScript"><cfset File0="unencoded/MTRmenuins9200.js"></cfcase>
	<cfcase VALUE="MTRmenumrc"><cfset SCRIPT="JavaScript"><cfset File0="unencoded/MTRmenumrc9200.js"></cfcase>
	<cfcase VALUE="MTRmenudev"><cfset SCRIPT="JavaScript"><cfset File0="unencoded/MTRmenudev9200.js"></cfcase>
	<cfcase VALUE="TOOLTIGRA">
		<cfif APPLOCID IS 5>
			<cfset SCRIPT="JavaScript"><cfset File0="toolbar9000@mbz.js">
		<cfelse>
			<cfset SCRIPT="JavaScript"><cfset File0="toolbar9000.js">
		</cfif>
	</cfcase>
	<cfcase VALUE="HOT"><cfset SCRIPT="JavaScript"><cfset File0="hotscpt.js"></cfcase>
	<cfdefaultcase><cfset File0=""></cfdefaultcase>
</cfswitch></cfsilent>
<cfif File0 IS NOT "">
<cfparam NAME=Attributes.WebRoot DEFAULT="#Request.WebRoot#"><cfset File0=Request.WebRoot & "MSupport/" & File0>
<cfif Not IsDefined("Attributes.NoGen") OR Attributes.NoGen IS 0><cfoutput><cfif Script IS "CSS"><link href="#File0#" rel=stylesheet type=text/css><cfelse><script language="#Script#" src="#File0#"></script></cfif></cfoutput></cfif>
</cfif>
<cfset Caller.Result=File0>--->
</cfif--->