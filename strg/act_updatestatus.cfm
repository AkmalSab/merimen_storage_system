<!--- Get specific client details based on ID --->
<!--- <cfdump  var="#FORM#"> --->
<cfquery name="SpecificOfClient" datasource="#Request.MTRDSN#" result="result">
    update STRG_DATA 
    set vaSTATUS=<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#FORM.status#">
    where iSTRGID =<cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.iSTRGID#">
</cfquery>

<cfoutput>
    #serializeJSON(result, "struct")#
</cfoutput>