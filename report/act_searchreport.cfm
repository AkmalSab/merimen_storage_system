<!--- <cfdump  var="#FORM#"> --->
<cfset DRFROM = lsParseDateTime("#FORM.DRFROM#","en","dd/mm/yyyy")>
<cfset DRTO = lsParseDateTime("#FORM.DRTO#","en","dd/mm/yyyy")>

<cfquery name="q_search_storage" datasource="#Request.MTRDSN#" result="result_search_storage">
    select
    a.vaCREATOR, 
    a.iSTRGTYPEID as storage_type_id,
    (
        select count(iSTRGID)
        from STRG_DATA 
        where vaSTATUS != 'Verified' and iSTRGTYPEID = a.iSTRGTYPEID and vaCREATOR = a.vaCREATOR
    ) as Unverified_counters,
    (
        select count(iSTRGID)
        from STRG_DATA a 
        where vaSTATUS = 'Verified' and iSTRGTYPEID = a.iSTRGTYPEID and vaCREATOR = a.vaCREATOR
    ) as Verified_counters,
    (
        select count(iSTRGID)
        from STRG_DATA
        where iCLASSIFIED = 1 and iSTRGTYPEID = a.iSTRGTYPEID and vaCREATOR = a.vaCREATOR
    ) as Classified_counters,
    (
        select count(iSTRGID)
        from STRG_DATA
        where vaCREATOR = a.vaCREATOR
    ) as Total_counters
    from STRG_DATA a WITH (NOLOCK)
    where 0=0
    <cfif len(trim(FORM.DRFROM)) NEQ 0>
        and a.dtCREATIONDATE between convert(datetime,#DRFROM#) 
    </cfif>
    <cfif len(trim(FORM.DRTO)) NEQ 0>
        and convert(datetime,#DRTO#)
    </cfif>
    <cfif len(trim(FORM.RATING)) NEQ 0>
        and a.iRATING = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.RATING#">
    </cfif>
    <cfif len(trim(FORM.USERNAME)) NEQ 0>
        and a.vaCREATOR = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.USERNAME#">
    </cfif>
    group by a.vaCREATOR,  a.iSTRGTYPEID
</cfquery>

<!--- <cfdump  var="#result_search_storage#"> --->

<cfoutput>
    #serializeJSON(q_search_storage, "struct")#
</cfoutput>

<cfabort>