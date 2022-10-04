<!---    START IMPORT MERIMEN FRAMEWORK      --->
<CFPARAM NAME=URL.locid DEFAULT=1>
<CFIF CGI.HTTP_HOST IS "192.168.1.48">
	<!--- Old: 192.168.1.231 --->
	<CFSET REQUEST.APPPATH="/Internal/">
	<CFSET REQUEST.APPROOT="/Internal/">
<CFELSE>
	<CFSET REQUEST.APPPATH="/">
	<CFSET REQUEST.APPROOT="/">
</CFIF>
<CFSET REQUEST.SVCDSN="claims_dev">
<CFSET REQUEST.LOGPATH="/claims/">
<CFSET DS=StructNew()>
<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCcffunctions.cfm" DS=#DS#>
<CFSET Request.DS=DS>
<CFSET Request.DS.FN.SVCSvrFileDSUpdate()>
<style>
.code {color:blue; font-family: 'courier sans ms'}
.quest { color:red;}
</style>
<!--- Include these using AddFile --->
<script>
var request=new Object();
<CFOUTPUT>
request.apppath="#request.apppath#";
request.approot="#request.approot#";
</CFOUTPUT>
sysdt=new Date();
</script>
<CFMODULE TEMPLATE="#request.apppath#services/CustomTags/SVCaddfile.cfm" FNAME="JQUERY">
<CFMODULE TEMPLATE="#request.apppath#services/CustomTags/SVCaddfile.cfm" FNAME="SVCMAIN">
<CFMODULE TEMPLATE="#request.apppath#services/CustomTags/SVCaddfile.cfm" FNAME="SVCCAL">
<CFMODULE TEMPLATE="#request.apppath#services/CustomTags/SVCaddfile.cfm" FNAME="SVCCSS">
<CFMODULE TEMPLATE="#request.apppath#services/CustomTags/SVCaddfile.cfm" FNAME="SVCLOGIN">
<script>AddOnloadCode("MrmPreprocessForm()");</script>
<!--- END IMPORT MERIMEN FRAMEWORK --->