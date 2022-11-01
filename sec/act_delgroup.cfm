<!--- 
FILENAME : act_delAlias.cfm
DESCRIPTION :
    Delete Alias
INPUT :
	See below.
	
OUTPUT :

CREATED BY : Seng Wai	
CREATED ON : June 2006

REVISION HISTORY

BY          ON          REMARKS
=========   ==========  ======================================================================================
Kian Yee	8/1/2008	Modified to fit in new mail system

Updates:
- delete alias put into storedproc
 --->



<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCDISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">

<!---cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCobjsec.cfm" ChkOrgType="D,I,A,R,P"--->
<!---cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCobjsec.cfm"--->

<cfparam name=Attributes.iDomainID default="">
<cfparam name=attributes.iobjid default="">
<cfparam name=Attributes.igrpid default="">
<cfparam name=attributes.urlback default="">

<cfif Attributes.URLBACK IS NOT "">
	<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCURLBACK.cfm" iCHKURLBACK=1 CHKURLBACK="#Attributes.URLBACK#">
</cfif>
<cfmodule template="#request.apppath#services/CustomTags\SVCchkinput.cfm" chkstring="#attributes.idomainid##attributes.iobjid##attributes.igrpid#" chktype="NUM">
<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchktask.cfm" isadmin=1 idomainid=#attributes.idomainid# iobjid=#attributes.iobjid# igrpid=#attributes.igrpid#>

<!---cfparam name=attributes.orgtype default=""--->
<!---cfmodule template="#request.apppath#services/CustomTags\SVCchkinput.cfm" chkstring="#attributes.idomainid##attributes.iobjid##attributes.ialiasid#" chktype="NUM">
<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkmail.cfm" isadmin=1 idomainid=#attributes.idomainid# iobjid=#attributes.iobjid# cur_ialiasid=#attributes.ialiasid#--->

<cfstoredproc PROCEDURE='sspFSECDeleteUserGroup' DATASOURCE=#Request.SVCDSN# RETURNCODE=YES>
	<CFPROCPARAM TYPE=IN  DBVARNAME=@igrpid VALUE=#attributes.igrpid# CFSQLTYPE=CF_SQL_INTEGER>
	<CFPROCPARAM TYPE=IN  DBVARNAME=@usid VALUE=#session.vars.usid# CFSQLTYPE=CF_SQL_INTEGER>
</cfstoredproc>
<cfset returncode=CFSTOREDPROC.StatusCode>
<cfif returncode LT 0>
    <cfthrow TYPE=EX_DBERROR ErrorCode="Error Modifying User Group">
</cfif>
<cfabort>
<CFLOCATION URL="#request.webroot#index.cfm?fusebox=SVCsec&fuseaction=dsp_grouplist&iDomainid=#attributes.idomainid#&iObjId=#attributes.iobjid#&urlback=#urlencodedformat(attributes.urlback)#&#Request.MToken#" ADDTOKEN="no">
