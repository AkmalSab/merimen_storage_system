<cfsilent><!---
Attributes
ClearSession: Clears the current mtoken of CFID,CFTOKEN and UserID
SetNextLoc: Set current location to be the nextloc URL parameter
NoNextLoc: Strip off nextloc URL parameter from now on
--->
<!---CFIF Application.ApplicationName IS "CRM">
	<!--- **CRM** --->
	<cfset request.MTRDSN=Application.MTRDSN>
	<cfset request.SVCDSN=Application.SVCDSN>
	<cfset request.MTRCATDSN= Application.MTRCATDSN>
	<!---CFSET request.logpath= "/claims/">
	<CFSET REQUEST.WEBROOT=CGI.SERVER_NAME & Request.logpath>
	<CFIF CGI.HTTPS EQ "ON">
	    <CFSET REQUEST.WEBROOT="https://" & Request.Webroot>
	<CFELSE>
	    <CFSET REQUEST.WEBROOT="http://" & Request.Webroot>
	</CFIF>
	<CFIF Not IsDefined("Attributes.NoScript")>
	<script><CFOUTPUT>
	request.webroot="#Request.Webroot#";
	</CFOUTPUT></script>
	</CFIF--->
	<cfexit METHOD=EXITTEMPLATE>
</CFIF--->
<cfif Not IsDefined("Attributes")><CFSET Attributes=StructNew()></CFIF>
<CFPARAM NAME=Attributes.URLPREFIX DEFAULT="">
<cfif CGI.HTTPS EQ "ON">
	<cfset SSLflag="yes">
<cfelse>
	<cfset SSLflag="no">
</cfif>

<CFIF StructKeyExists(Request,"DS") and StructKeyExists(Request.DS,"FN") and StructKeyExists(Request.DS.FN,"SVCDetectMobile")>
	<cfset REQUEST.DS.FN.SVCDetectMobile()>
</CFIF>

<cfset REQUEST.AGENTANDROID=0>
<CFIF IsDefined('CGI.HTTP_USER_AGENT') AND CGI.HTTP_USER_AGENT NEQ ""  AND Request.DS.FN.SVCGetResp() AND FindNoCase("android", CGI.HTTP_USER_AGENT)>
	<cfset REQUEST.AgentAndroid=1>
</CFIF>

<CFIF StructKeyExists(Attributes,"ClearSession")>
	<cfset MURLTOKEN=""><cfset BASICTOKEN="">
	<cfcookie NAME=MACID EXPIRES=NOW HTTPONLY=YES secure="#SSLflag#">
	<CFIF Request.inSession AND IsDefined("SESSION.CFID")>
		<cfcookie NAME=CFID VALUE="#SESSION.CFID#" EXPIRES=NOW HTTPONLY=YES secure="#SSLflag#">
		<cfcookie NAME=CFTOKEN VALUE="#SESSION.CFTOKEN#" EXPIRES=NOW HTTPONLY=YES secure="#SSLflag#">
	<CFELSEIF Request.inSession AND IsDefined("SESSION.JSESSIONID")>
		<cfcookie NAME=JSESSIONID VALUE="#SESSION.JSESSIONID#" EXPIRES=NOW HTTPONLY=YES secure="#SSLflag#">
	<CFELSE>
		<cfcookie NAME=CFID EXPIRES=NOW HTTPONLY=YES secure="#SSLflag#">
		<cfcookie NAME=CFTOKEN EXPIRES=NOW HTTPONLY=YES secure="#SSLflag#">
		<cfcookie NAME=JSESSIONID EXPIRES=NOW HTTPONLY=YES secure="#SSLflag#">
	</CFIF>
<cfelse>
	<!---cfif IsDefined("SESSION.CFID")><cfset MURLTOKEN="CFID=#SESSION.CFID#&CFTOKEN=#SESSION.CFTOKEN#"><cfelse><cfset murltoken=""></cfif--->
	<cfif Request.inSession IS 1>
	 	<CFIF NOT IsDefined("SESSION.VARS.COOKIESESSION")>
			<CFSET BASICTOKEN=SESSION.URLToken><CFSET MURLTOKEN=BASICTOKEN>
		<CFELSE>
			<CFSET BASICTOKEN=""><CFSET MURLTOKEN="">
		</CFIF>
		<cfset request.LOCID=SESSION.VARS.LOCID><cfset MURLTOKEN=ListAppend(MURLTOKEN,"USID=#SESSION.VARS.USID#&RID=#RandRange(1000000,9999999)#","&")>
		<CFIF SESSION.VARS.ORGTYPE IS "D" AND StructKeyExists(URL,"LOCID") AND URL.LOCID IS NOT ""><cfset MURLTOKEN=ListAppend(MURLTOKEN,"LOCID=#Request.DS.FN.SVCSanitizeInput(URL.LOCID)#","&")></cfif>
	<CFELSE>
		<CFSET BASICTOKEN=""><CFSET MURLTOKEN="">
	</cfif>
	<cfif StructKeyExists(URL,"NOLAYOUT")><cfset MURLTOKEN= ListAppend(MURLTOKEN,"NOLAYOUT=#Request.DS.FN.SVCSanitizeInput(URL.NOLAYOUT,'JS-NQ')#","&")></cfif>
	<cfif StructKeyExists(URL,"BR") AND URL.BR IS NOT ""><cfset MURLTOKEN= ListAppend(MURLTOKEN,"BR=#Request.DS.FN.SVCSanitizeInput(URL.BR,'JS-NQ')#","&")></cfif>
	<cfif StructKeyExists(URL,"CT") AND URL.CT IS NOT ""><cfset MURLTOKEN= ListAppend(MURLTOKEN,"CT=#Request.DS.FN.SVCSanitizeInput(URL.CT,'JS-NQ')#","&")></cfif>
	<cfif StructKeyExists(URL,"LANG") AND URL.fusebox IS "MTRCmt"><cfset MURLTOKEN=ListAppend(MURLTOKEN,"LANG=#Request.DS.FN.SVCSanitizeInput(URL.LANG,'JS-NQ')#","&")></cfif>
	<cfif StructKeyExists(URL,"MOBILE") AND listfindnocase("0,1,2", URL.mobile) gt 0><cfset MURLTOKEN=ListAppend(MURLTOKEN,"MOBILE=#Request.DS.FN.SVCSanitizeInput(URL.MOBILE,'JS-NQ')#","&")></cfif>
	<cfif StructKeyExists(URL,"LF") AND URL.LF IS NOT ""><cfset MURLTOKEN= ListAppend(MURLTOKEN,"LF=#URLEncodedFormat(Request.DS.FN.SVCSanitizeInput(URL.LF,'JS-NQ'))#","&")></cfif>
	<!--- Added for Translation works, so that we are not hardcoding the user IDs which can be used to see relevant iLID. --->
	<cfif StructKeyExists(URL,"TRANS")><cfset MURLTOKEN= ListAppend(MURLTOKEN,"TRANS","&")></cfif>
</cfif>
<cfif StructKeyExists(Attributes,"SETNEXTLOC")>
	<cfinclude TEMPLATE="FORMATURL.cfm"><cfset MURLTOKEN=ListAppend(MURLTOKEN,"nextloc=#result#","&")>
<cfelseif StructKeyExists(URL,"NEXTLOC") AND Not StructKeyExists(Attributes,"NoNextLoc")>
	<cfset MURLTOKEN=ListAppend(MURLTOKEN,"nextloc=#URLEncodedFormat(URL.NextLoc)#","&")>
</cfif>
<cfif Len(Application.ApplicationName) GT 6 AND Right(Application.ApplicationName,6) IS "_train">
	<cfset MURLTOKEN=ListAppend(MURLTOKEN,"train=1","&")>
	<cfset BASICTOKEN=ListAppend(BASICTOKEN,"train=1","&")>
</cfif>

<!---cfif IsDefined("SESSION.VARS.CRMMTOKEN")>
	<cfset Request.CRMTOKEN=SESSION.VARS.CRMMTOKEN><!--- for SVCobj drag-drop link --->
</cfif--->

<!---cfset APPLANGPATH=Application.APPLANGPATH>

<cfset logprefix=Application.LOGPATH>
<cfif Right(logprefix,1) IS "/">
	<cfset logprefix=Left(Application.LOGPATH,Len(Application.LOGPATH)-1)>
</cfif>
<cfset svcprefix=Application.SVCPATH>
<cfif Right(svcprefix,1) IS "/">
	<cfset svcprefix=Left(Application.SVCPATH,Len(Application.SVCPATH)-1)>
</cfif>
<cfset curlogpath=logprefix & LCase(APPLANGPATH) & "/">
<cfset cursvcpath=svcprefix & LCase(APPLANGPATH) & "/"--->

<CFSET curlogpath = Application.LOGPATH>
<CFSET curapppath = Application.APPPATH>

<cfset request.mtoken=murltoken>
<!---cfset request.basictoken=basictoken--->
<cfset Request.MTRTOKEN = murltoken><!--- for SVCobj drag-drop link --->

<cfset request.MTRDSN=Application.MTRDSN>
<cfset request.MICDSN=Application.MICDSN>
<cfset request.SVCDSN=Application.SVCDSN>
<cfset request.SSODSN=Application.SSODSN>
<cfset request.SSOPATH=Application.SSOPATH>

<CFIF Not IsDefined("Request.RPTDSN")>
	<CFIF IsDefined("Application.RPTDSN")>
		<cfset request.RPTDSN=Application.RPTDSN>
		<CFIF request.RPTDSN IS NOT request.MTRDSN>
			<cfset sysdate=now()>
			<cfif Request.inSession IS 1>
				<cfset LOCALE=Request.DS.LOCALES[SESSION.VARS.LOCID]>
				<cfset SHIFT=LOCALE.TIMEZONE-APPLICATION.SERVERTIMEZONE>
				<cfif SHIFT IS NOT 0>
					<cfset sysdate=DateAdd("h",SHIFT,sysdate)>
				</cfif>
			</cfif>
			<cfset dow=DatePart("w",sysdate)>
			<cfset systime=DateFormat(sysdate,"HHmm")>
			<!--- HARDCODE!! --->
			<CFIF NOT(dow GE 2 AND dow LE 6 AND systime GE 830 AND systime LE 1730)>
				<!--- Use RptDB from 8.30am-5.30pm working day, other times LiveDB --->
				<cfset request.RPTDSN=request.MTRDSN>
			</CFIF>
		</CFIF>
	<CFELSE>
		<cfset request.RPTDSN=request.MTRDSN>
	</CFIF>
</CFIF>

<cfset request.APIKEY_GOOGLE=Application.APIKEY_GOOGLE>

<cfset request.MTRCATDSN=Application.MTRCATDSN>

<cfset request.logpath= Application.CFPREFIX & curlogpath>
<cfset request.apppath= Application.CFPREFIX & curapppath>
<cfset request.apppathcfc= Application.APPPATHcfc>

<cfset REQUEST.WEBROOT=Attributes.URLPREFIX&curlogpath>
<cfset request.APPROOT=Attributes.URLPREFIX&curapppath>

<cfset request.newUI=false>
<cfif StructKeyExists(SESSION, "SSO_UID")>
	<cfset request.newUI=true>
</cfif>

</cfsilent>
<cfif Not StructKeyExists(Attributes,"NoScript")>
<!--- Lisa note. This is to force standards mode rendering for the login page. --->
<CFIF (listfindnocase("PROD,TRAIN", application.db_mode) EQ 0 OR (StructKeyExists(URL,"LF") AND URL.LF IS NOT "")) AND APPLICATION.appmode eq "CLAIMS" and ((not isdefined("URL.fusebox") and not isdefined("url.fuseaction")) or (isdefined("URL.fuseaction") and URL.fuseaction eq "dsp_login"))><!DOCTYPE html>
	<html><head>
	<meta http-equiv="X-UA-Compatible" content="IE=9">
</cfif>
<script><CFOUTPUT>
var request=new Object();
request.webroot="#Request.Webroot#";
request.mtoken="#Request.MToken#";
request.approot="#request.approot#";
request.apikey_google="#Application.APIKEY_GOOGLE#";
<cfif IsDefined('SESSION.SSO_UID')>
	request.ssoroot="#request.ssopath#"
</cfif>
request.apptmz=<cfif StructKeyExists(Application,"SERVERTIMEZONE") AND IsNumeric(Application.SERVERTIMEZONE)>#Application.SERVERTIMEZONE#<cfelse>8.0</cfif>;
<CFIF Request.inSession IS 1>
	<cfif StructKeyExists(SESSION,"VARS") AND StructKeyExists(SESSION.VARS,"LGID") AND SESSION.VARS.LGID GTE 0>
		request.lgid=#SESSION.VARS.LGID#;
	</cfif>
<CFELSEIF StructKeyExists(Request,"LGID") AND Request.LGID GT 0>
	request.lgid=#Request.LGID#;
</CFIF>
<cfif isdefined("session.vars.userid") and ((listfindnocase("VNADJTRANS,VNTRANS,JPAXIAS_TRANS", session.vars.userid) gt 0 and application.appdevmode eq 1) OR (listfindnocase("SATRINS,SATRREP,SATRADJ,SATRAGENT,SATRSOL,SATRSUPPLIER", session.vars.userid) gt 0 and application.db_mode eq "UAT"))>
JSUserID = "#session.vars.userid#";
</cfif>
request.agentandroid=#request.AgentAndroid#;
</CFOUTPUT></script>
<!--- Similar settings in \CustomTags\settoken.cfm and \index.cfm --->
<cfif Request.inSession IS 1 AND NOT StructKeyExists(SESSION.VARS,"LGID")
		AND NOT(SESSION.VARS.ORGTYPE IS "D")
		AND (ListFind("15,17",Application.APPLOCID)
			<!--- #31905: default language for insurer to english --->
		OR (Application.APPLOCID IS 7 AND NOT(SESSION.VARS.ORGTYPE IS "I"))
		OR (Application.APPLOCID IS 11 AND isdefined("SESSION.vars.ORGTYPE") AND SESSION.vars.ORGTYPE IS "G" AND isdefined("SESSION.VARS.COTYPEID") AND SESSION.VARS.COTYPEID IS 6 AND isdefined("SESSION.VARS.SUBCOTYPEID") AND SESSION.VARS.SUBCOTYPEID IS 4)
		)>
	<cfset Request.DS.FN.SVClangSet("",6)>
</cfif>
</cfif>
