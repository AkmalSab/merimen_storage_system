<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCDISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">

<!---cfif Not IsDefined("SESSION.VARS.USERID")>
	<cfthrow TYPE="EX_SECFAILED" ErrorCode="NOLOGIN">
</cfif--->

<cfparam name="attributes.idomainid" default="">
<cfparam name="attributes.iobjid" default="">
<cfparam name="attributes.igrpid" default="">

<cfmodule template="#request.apppath#services/CustomTags\SVCchkinput.cfm" chkstring="#attributes.idomainid##attributes.iobjid##attributes.igrpid#" chktype="NUM">
<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchktask.cfm" isadmin=1 idomainid=#attributes.idomainid# iobjid=#attributes.iobjid# igrpid=#attributes.igrpid#>

<!---cfmodule template="#request.apppath#services/CustomTags\SVCchkinput.cfm" chkstring="#attributes.idomainid##attributes.iobjid##attributes.cur_ialiasid#" chktype="NUM">
<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkmail.cfm" isadmin=1 idomainid=#attributes.idomainid# iobjid=#attributes.iobjid# cur_ialiasid=#attributes.cur_ialiasid#--->

<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCADDFILE.cfm" FNAME="SVCCSS">
<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCADDFILE.cfm" FNAME="SARISSA">
<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCADDFILE.cfm" FNAME="SVCSELECTOR">
<!---cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCADDFILE.cfm" FNAME="SVCMAIL"--->

<!--- retrieve siCOTYPEID to determine permissions available to the company --->
<cfif Not IsDefined("Attributes.IOBJID")>
	<cfthrow TYPE="GRPPERMFAILED" ErrorCode="COIDNOTFOUND">
<cfelse>
	<!---cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\CHKCASE.cfm" ChkCoID=1 COID="#Attributes.IOBJID#"--->

	<cfset mode = 0>
	<cfquery name="q_coperm" datasource=#Request.SVCDSN#>
	SELECT a.siCOTYPEID,a.iGCOID,a.iLOCID
	FROM SEC0005 a WITH (NOLOCK)
	WHERE a.iCOID=<cfqueryparam cfsqltype="cf_sql_integer" value="#Attributes.IOBJID#">
	</cfquery>
</cfif>
<cfif q_coperm.recordcount IS NOT 1>
	<cfthrow TYPE="GRPPERMFAILED" ErrorCode="BADCOPERM">
</cfif>
<cfset li_cotypeid=q_coperm.siCOTYPEID>
<cfset cotypemask=2^(li_cotypeid-1)>
<cfset GCOID=q_coperm.iGCOID>
<CFSET LOCID=q_coperm.ilocid>


<!--- This should mirror the permissions in dsp_userprofile --->
<!--- Exclude permissions: PERMGRPNOTLIST, permdislist--->
<CFSET PERMGRPNOTLIST = "">
<CFSET PERMDISLIST = "">
<!--- <cfif application.appmode eq "CLAIMS">
	<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\MTRexcludePerm.cfm" ORGTYPE="#session.vars.orgtype#" LOCID="#LOCID#" COID="#GCOID#">
</CFIF> --->

<!--- retrieve permissions according to cotypemask --->
<cfquery name="q_grpperm" datasource=#Request.MTRDSN#>
SELECT a.iPERMGRPID, c.vaPERMGRPNAME,a.siPGROUP,a.siPREQUIRED,a.vaDESC,
CHK=CASE WHEN b.siPGROUP IS NULL THEN 0 ELSE 1 END,
PRIVATE_PERM=CASE WHEN EXISTS(SELECT 1 FROM SEC0003_CO d WITH (NOLOCK) WHERE d.siPGROUP=a.siPGROUP) THEN 1 ELSE 0 END,
PRIVATE_GCOID=d.iGCOID
FROM SEC0003 a WITH (NOLOCK)
	LEFT JOIN FSEC4004 b WITH (NOLOCK) ON a.siPGROUP=b.siPGROUP AND b.iGRPID=<cfqueryparam cfsqltype="cf_sql_integer" value="#Attributes.IGRPID#"> AND b.siSTATUS=0
	LEFT JOIN SEC0023 c WITH (NOLOCK) ON a.iPERMGRPID=c.iPERMGRPID
	LEFT JOIN SEC0003_CO d WITH (NOLOCK) ON d.siPGROUP=a.siPGROUP AND d.iGCOID=<cfqueryparam value="#GCOID#" cfsqltype="CF_SQL_INTEGER">
WHERE a.siCOTYPEID & <cfqueryparam cfsqltype="cf_sql_integer" value="#cotypemask#"> > 0 AND a.siSTATUS=0
<CFIF LOCID IS 2 AND SESSION.VARS.ORGTYPE IS NOT "D">
    AND a.siPGROUP NOT IN (440,503,444,442,441,443,500,504,501,502,53)
</CFIF>
<CFIF PERMGRPNOTLIST neq "">
    AND c.iPERMGRPID NOT IN (<cfqueryparam value="#PERMGRPNOTLIST#" cfsqltype="CF_SQL_INTEGER" list="true">)
</CFIF>
<CFIF PERMDISLIST neq "">
    AND a.siPGROUP not in (<cfqueryparam value="#PERMDISLIST#" cfsqltype="CF_SQL_NUMERIC" list="true">)
</cfif>
ORDER BY a.iPERMGRPID,a.vaDESC
</cfquery>

<script>
function ClkHelp(cotypemask)
{	w=window.open(request.webroot+'index.cfm?fusebox=SVCadmin&fuseaction=dsp_userpermhelp&cotypemask='+cotypemask+'&nolayout=1&'+request.mtoken,'PermWindow','resizable=yes,scrollbars=yes,menubar=no;');
}
</script>
<CFOUTPUT>
<form name=ModGroupPerm action="#request.webroot#index.cfm?fusebox=sec&fuseaction=act_modgroupperm&idomainid=#attributes.idomainid#&iobjid=#attributes.iobjid#&igrpid=#attributes.igrpid#&USID=#SESSION.VARS.USID#&#request.mtoken#" method=post>
<br><table CELLPADDING=3 CELLSPACING=0 align=center style="border:##214383 1px solid;width:90%">
<tr><td align=center bgcolor=##214383 style=color:white><b>#Server.SVClang("Permissions Assigned to Group",12514)#: &nbsp; &nbsp;<input type=button class=clsButton value="#Server.SVClang("Help",1090)#" onclick="ClkHelp(#cotypemask#)"><br>#Attributes.grpname#</b></td></tr>
</CFOUTPUT>
<tr><td bgcolor=#EEEEEE align=center>
<div align=left style="width:90%">
<cfset allpermlist = ""><cfset oldpermlist = "">
<cfset curgrp=-1>
<cfoutput query=q_grpperm>
    <cfset AllowMod=1>
    <cfif siPREQUIRED GT 0>
        <cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GRPLIST="#siPREQUIRED#R">
        <cfif CanRead IS 0>
            <cfset AllowMod=0>
        </cfif>
    <cfelse>
    </cfif>
    <CFIF curgrp IS NOT iPERMGRPID>
        <CFSET curgrp=iPERMGRPID>
        <br><b><u>#vaPERMGRPNAME#</u></b><br>
    </CFIF>

    <cfif (PRIVATE_PERM IS 0 OR (PRIVATE_PERM IS 1 AND PRIVATE_GCOID IS GCOID))>
        <input 
        type="checkbox" 
        value="#siPGROUP#" 
        ID="P#siPGROUP#"
        <CFIF AllowMod IS 0> 
            DISABLED
        <CFELSE> 
            NAME=PERCHK
        </CFIF>
        <CFIF CHK IS 1> 
            CHECKED
        </cfif>>&nbsp;
        <cfif SESSION.VARS.ORGTYPE IS "D">
            (#siPGROUP#) 
        </cfif>#vaDESC#<br>
    </cfif>
    <cfif AllowMod IS 1>
        <cfset allpermlist=ListAppend(allpermlist,siPGROUP)>
        <cfif Chk IS 1>
            <cfset oldpermlist=ListAppend(oldpermlist,siPGROUP)>
        </CFIF>
    </cfif>
</cfoutput>
<cfoutput>
<input type="hidden" NAME="GRPNAME" ID="GRPNAME" value="#Attributes.grpname#">
<input type="hidden" NAME="ALLPLIST" ID="ALLPLIST" value="#allpermlist#">
<input type="hidden" NAME="OLDPLIST" ID="OLDPLIST" value="#oldpermlist#">

</div>
</td></tr></table>

<br><center><input type="button" class=clsButton value="#Server.SVClang("Submit",1593)#" onclick="javascript:submitform()">&nbsp;<input type="button" class=clsButton value="#Server.SVClang("Cancel",6812)#" onclick="javascript:window.close()"></center><br>
</cfoutput>
<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkguid.cfm" start>
</form>

<script>
function submitform(){
	ModGroupPerm.submit();
}
</script>