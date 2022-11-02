<cfset DayFrom = "#dateFormat(FORM.DRFROM, 'dd')#">
<cfset DayTo ="#dateFormat(FORM.DRTO, 'dd')#">
<cfset MonthFrom = "#dateFormat(FORM.DRFROM, 'mm')#">
<cfset MonthTo ="#dateFormat(FORM.DRTO, 'mm')#">
<cfset YearFrom = "#dateFormat(FORM.DRFROM, 'yyyy')#">
<cfset YearTo ="#dateFormat(FORM.DRTO, 'yyyy')#">

<cfset FORM.DRFROM = YearFrom&'-'&DayFrom&'-'&MonthFrom>
<cfset FORM.DRTO = YearTo&'-'&DayTo&'-'&MonthTo>
<!--- <cfdump  var="#FORM#"> --->

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
    <cfif len(trim(FORM.USERNAME)) NEQ 0>
        and a.vaCREATOR = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.USERNAME#">
    </cfif>
    <cfif len(trim(FORM.RATING)) NEQ 0>
        and a.iRATING = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.RATING#">
    </cfif>
    <cfif len(trim(FORM.DRFROM)) NEQ 0>
        <cfif len(trim(FORM.DRTO)) NEQ 0>         
            and a.dtCREATIONDATE >= '#dateTimeFormat(FORM.DRFROM,'yyyy-mm-dd')# 00:00:00' AND a.dtCREATIONDATE <= '#dateTimeFormat(FORM.DRTO,'yyyy-mm-dd')# 23:59:59'
        </cfif>
    </cfif>
    group by a.vaCREATOR, b.vaUSName, a.iSTRGTYPEID
    order by a.vaCREATOR
</cfquery>

<!--- <cfdump  var="#q_search_storage#"><cfabort> --->

<cfoutput>
    #serializeJSON(q_search_storage, "struct")#
</cfoutput>

<cfabort>