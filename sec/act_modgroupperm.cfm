<!--- 
FILENAME : act_modgroupperm.cfm
DESCRIPTION : modify the permissions for a group
INPUT :
OUTPUT :

CREATED BY : Joshua Ting	
CREATED ON : Dec 2008

REVISION HISTORY

BY          ON          REMARKS
=========   ==========  ======================================================================================

Updates:
--->
<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCDISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">
<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCchkguid.cfm" required>
<cfparam name="attributes.igrpid" default="">
<cfparam name="attributes.idomainid" default="">
<cfparam name="attributes.iobjid" default="">
<cfmodule template="#request.apppath#services/CustomTags\SVCchkinput.cfm" chkstring="#attributes.idomainid##attributes.iobjid##attributes.igrpid#" chktype="NUM">
<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchktask.cfm" isadmin=1 idomainid=#attributes.idomainid# iobjid=#attributes.iobjid# igrpid=#attributes.igrpid#>

<cfstoredproc PROCEDURE='sspFSECModUserGroupPerm' DATASOURCE=#Request.MTRDSN# RETURNCODE=YES>
	<CFPROCPARAM TYPE=IN  DBVARNAME=@ai_IGRPID VALUE=#attributes.igrpid# CFSQLTYPE=CF_SQL_INTEGER>
	<CFPROCPARAM TYPE=IN  DBVARNAME=@ai_USID VALUE=#attributes.usid# CFSQLTYPE=CF_SQL_INTEGER>
	<CFPROCPARAM TYPE=IN  DBVARNAME=@ai_COID VALUE=#attributes.iobjid# CFSQLTYPE=CF_SQL_INTEGER>
	<CFPROCPARAM TYPE=IN  DBVARNAME=@as_defplist VALUE=#FORM.OLDPLIST# CFSQLTYPE=CF_SQL_VARCHAR>
	<CFIF NOT IsDefined("FORM.PERCHK")>
		<CFPROCPARAM TYPE=IN  DBVARNAME=@as_perchk VALUE="" CFSQLTYPE=CF_SQL_VARCHAR>
	<CFELSE>
		<CFPROCPARAM TYPE=IN  DBVARNAME=@as_perchk VALUE=#FORM.PERCHK# CFSQLTYPE=CF_SQL_VARCHAR>
	</CFIF>
	<CFPROCPARAM TYPE=IN DBVARNAME=@as_grpname NULL=true CFSQLTYPE="CF_SQL_VARCHAR">
</cfstoredproc>

<script>
	window.close();
	window.opener.location.reload(false);
</script>
