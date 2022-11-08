<!--- Get specific client details based on ID --->
<!--- <cfdump  var="#FORM#"> --->
<cfquery name="SpecificOfClient" datasource="#Request.MTRDSN#" result="result">
    update STRG_DATA 
    set vaSTATUS=<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#FORM.status#">
    where iSTRGID =<cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.iSTRGID#">
</cfquery>

<!--- insert into audit --->
<cfdump  var="#FORM#">
<cfquery name="q_last_id" datasource="#Request.MTRDSN#">
    SELECT TOP 1 ITAID
    FROM [FOBJ3010] WITH (NOLOCK)
    WHERE IDOMAINID = <cfqueryparam value="901" cfsqltype="cf_sql_integer">
    ORDER BY ITAID DESC
</cfquery>

<cfset ITAID = q_last_id.ITAID + 1>

<cfstoredproc PROCEDURE="sspFOBJAudit" DATASOURCE="#Request.MTRDSN#" RETURNCODE=YES>
    <cfprocparam TYPE=IN DBVARNAME=@ITAID VALUE="#ITAID#" CFSQLTYPE="CF_SQL_INTEGER">
    <cfprocparam TYPE=IN DBVARNAME=@ITATYPEID VALUE="1000613" CFSQLTYPE="CF_SQL_INTEGER">
    <cfprocparam TYPE=IN DBVARNAME=@ai_usid VALUE="#FORM.USID#" CFSQLTYPE="CF_SQL_INTEGER">
    <cfprocparam TYPE=IN DBVARNAME=@ICRTCOROLE NULL="YES" CFSQLTYPE="CF_SQL_INTEGER">
    <cfprocparam TYPE=IN DBVARNAME=@ICRTCOSECPOS NULL="YES" CFSQLTYPE="CF_SQL_INTEGER">
    <cfprocparam TYPE=IN DBVARNAME=@DTCURDT NULL="YES" CFSQLTYPE="CF_SQL_TIMESTAMP">
    <cfprocparam TYPE=IN DBVARNAME=@IDOMAINID VALUE="901" CFSQLTYPE="CF_SQL_INTEGER">
    <cfprocparam TYPE=IN DBVARNAME=@IOBJID VALUE="#FORM.iSTRGID#" CFSQLTYPE="CF_SQL_INTEGER">
    <cfprocparam TYPE=IN DBVARNAME=@ILINKID NULL="YES" CFSQLTYPE="CF_SQL_INTEGER">
    <cfprocparam TYPE=IN DBVARNAME=@VATAREMARKS VALUE="UPDATE STATUS TO #FORM.status#" CFSQLTYPE="CF_SQL_VARCHAR">
</cfstoredproc>

<cfdump  var="#cfstoredproc#">
<!--- insert into audit --->


<cfoutput>
    #serializeJSON(result, "struct")#
</cfoutput>