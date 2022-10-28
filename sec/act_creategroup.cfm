<!--- 
FILENAME : act_mailAlias.cfm
DESCRIPTION :
    Display mail alias belong to an person.
INPUT :
	See below.
	
OUTPUT :

CREATED BY : Seng Wai	
CREATED ON : June 2006

REVISION HISTORY

BY          ON          REMARKS
=========   ==========  ======================================================================================
Kian Yee	8/1/2008	Modified to fit in new mail system

UPDATES:
- transactions were moved to storedproc
- checkcase added
- combined both create mail group and create alias here
* storedproc entrance for create company mail account,create mail group, and create single user mail account
	- sspFMSGcreateAlias - passing in different alias_type to create different types
 --->


<!---cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\DISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">
<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCobjsec.cfm"--->

<cfdump  var="#FORM#">
<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCDISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">
<!--- <cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkguid.cfm" required> --->

<cfparam name=Attributes.iDomainID default="">
<cfparam name=attributes.iObjid default="">
<cfparam name=attributes.urlback default="">
<cfif Attributes.URLBACK IS NOT "">
	<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCURLBACK.cfm" iCHKURLBACK=1 CHKURLBACK="#Attributes.URLBACK#">
</cfif>

<cfmodule template="#request.apppath#services/CustomTags\SVCchkinput.cfm" chkstring="#attributes.idomainid##attributes.iobjid#" chktype="NUM">
<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchktask.cfm" isadmin=1 idomainid=#attributes.idomainid# iobjid=#attributes.iobjid#>

<!---cfmodule template="#request.apppath#services/CustomTags\SVCchkinput.cfm" chkstring="#attributes.idomainid##attributes.iobjid#" chktype="NUM">
<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkmail.cfm" isadmin=1 idomainid=#attributes.idomainid# iobjid=#attributes.iobjid#--->


<cfquery name=q_checkgroup datasource=#request.mtrdsn#>
select igrpid from FSEC4001 where VAGRPNAME = <cfqueryparam CFSQLTYPE="cf_sql_varchar" value="#form.grpname#"> AND icoid=<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.iobjid#"> and sistatus=0
</cfquery>

<cfif q_checkgroup.recordcount neq 0>
	<cfoutput>
	<script>
	alert('#Server.SVClang("{0} already exist. Please choose another group name",12480,0,"#JSStringFormat(form.grpname)#")#');
	window.location.href="#request.webroot#index.cfm?fusebox=sec&fuseaction=dsp_grouplist&idomainid=#attributes.idomainid#&iobjid=#attributes.iobjid#&urlback=#URLencodedformat(attributes.urlback)#&#request.mtoken#";
	</script>
	</cfoutput>
	<cfexit>
</cfif>

<cfinclude template="qry_sspFSECCreateUserGroup.cfm">

<CFLOCATION url="#request.webroot#index.cfm?fusebox=sec&fuseaction=dsp_grouplist&idomainid=#attributes.idomainid#&iobjid=#attributes.iobjid#&urlback=#URLencodedformat(attributes.urlback)#&#request.mtoken#" ADDTOKEN="no">

