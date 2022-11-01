<!--- <cfdump  var="#FORM#"> --->

<cfif len(trim(FORM.DRFROM)) NEQ 0><cfset DRFROM = lsParseDateTime("#FORM.DRFROM#","en","dd/mm/yyyy")></cfif>
<cfif len(trim(FORM.DRTO)) NEQ 0><cfset DRTO = lsParseDateTime("#FORM.DRTO#","en","dd/mm/yyyy")></cfif>

<cfquery name="q_search_storage" datasource="#Request.MTRDSN#" result="result_search_storage">
    select
    a.vaCREATOR, 
    b.vaUSName,
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
    from STRG_DATA a JOIN SEC0001 b WITH (NOLOCK)
    on a.vaCREATOR = b.iUSID
    where 0=0
    group by a.vaCREATOR, b.vaUSName, a.iSTRGTYPEID
</cfquery>

<!--- <cfdump  var="#result_search_storage#"> --->

<cfoutput>
    #serializeJSON(q_search_storage, "struct")#
</cfoutput>

<cfabort>