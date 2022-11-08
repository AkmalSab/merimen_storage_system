<cfdump  var="#FORM#">
<cfquery name="q_last_id" datasource="#Request.MTRDSN#">
    SELECT TOP 1 ITAID
    FROM [FOBJ3010] WITH (NOLOCK)
    WHERE IDOMAINID = <cfqueryparam value="901" cfsqltype="cf_sql_integer">
    ORDER BY ITAID DESC
</cfquery>

<!--- <cfdump  var="#q_last_id.ITAID#"> --->
<cfset ITAID = q_last_id.ITAID + 1>
<!--- <cfdump  var="#ITAID#"> --->

<cfstoredproc PROCEDURE="sspFOBJAudit" DATASOURCE="#Request.MTRDSN#" RETURNCODE=YES>
    <cfprocparam TYPE=IN DBVARNAME=@ITAID VALUE="#ITAID#" CFSQLTYPE="CF_SQL_INTEGER">
    <cfprocparam TYPE=IN DBVARNAME=@ITATYPEID VALUE="1000613" CFSQLTYPE="CF_SQL_INTEGER">
    <cfprocparam TYPE=IN DBVARNAME=@ai_usid VALUE="#SESSION.VARS.USID#" CFSQLTYPE="CF_SQL_INTEGER">
    <cfprocparam TYPE=IN DBVARNAME=@ICRTCOROLE NULL="YES" CFSQLTYPE="CF_SQL_INTEGER">
    <cfprocparam TYPE=IN DBVARNAME=@ICRTCOSECPOS NULL="YES" CFSQLTYPE="CF_SQL_INTEGER">
    <cfprocparam TYPE=IN DBVARNAME=@DTCURDT NULL="YES" CFSQLTYPE="CF_SQL_TIMESTAMP">
    <cfprocparam TYPE=IN DBVARNAME=@IDOMAINID VALUE="901" CFSQLTYPE="CF_SQL_INTEGER">
    <cfprocparam TYPE=IN DBVARNAME=@IOBJID VALUE="#FORM.STORAGEITEMID#" CFSQLTYPE="CF_SQL_INTEGER">
    <cfprocparam TYPE=IN DBVARNAME=@ILINKID NULL="YES" CFSQLTYPE="CF_SQL_INTEGER">
    <cfprocparam TYPE=IN DBVARNAME=@IPARAM1 VALUE="3" CFSQLTYPE="CF_SQL_INTEGER">
    <cfif structKeyExists(form,"AUDITREMARKS")>
        <cfprocparam TYPE=IN DBVARNAME=@VATAREMARKS VALUE="#form.AUDITREMARKS#" CFSQLTYPE="CF_SQL_VARCHAR">
    <cfelse>
        <cfprocparam TYPE=IN DBVARNAME=@VATAREMARKS NULL="YES" CFSQLTYPE="CF_SQL_VARCHAR">
    </cfif>
</cfstoredproc>

<cfdump  var="#cfstoredproc#">

<cflocation  url="#request.webroot#index.cfm?fusebox=MTRroot&fuseaction=dsp_home&#request.mtoken#">
