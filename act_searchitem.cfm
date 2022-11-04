<!--- <cfdump  var="#FORM#"> --->

<cfquery name="q_search_storage" datasource="#Request.MTRDSN#" result="result_search_storage">
    select *, c.vaUSName
    from STRG_DATA a LEFT JOIN FDOC3006 b WITH (NOLOCK) ON a.iOBJID = b.IFILEID
    LEFT JOIN SEC0001 c WITH (NOLOCK) ON a.vaCREATOR = c.iUSID
    <cfif len(trim(FORM.TAGS)) NEQ 0>
        left join FOBJ3020 d WITH (NOLOCK)
        on a.iSTRGID = d.IOBJID
        left join FOBJB3020 e WITH (NOLOCK)
        on d.ILBLDEFID = e.ILBLDEFID
    </cfif>
    where 0=0
    <cfif len(trim(FORM.CREATOR)) NEQ 0>
        and a.vaCREATOR = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.CREATOR#">
    </cfif>
    <cfif len(trim(FORM.DESCRIPTION)) NEQ 0>
        and a.vaDESCRIPTION LIKE '%#FORM.DESCRIPTION#%'
    </cfif>
    <cfif len(trim(FORM.GUIDATEFROM)) NEQ 0>
        and a.dtCREATIONDATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#FORM.GUIDATEFROM#">
    </cfif>
    <cfif len(trim(FORM.GUIDATETO)) NEQ 0>
        and a.dtCREATIONDATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#FORM.GUIDATETO#">
    </cfif>
    <cfif len(trim(FORM.ITEMNAME)) NEQ 0>
        and a.vaITEMNAME LIKE '%#FORM.ITEMNAME#%'
    </cfif>
    <cfif len(trim(FORM.RATING)) NEQ 0>
        and a.iRATING = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.RATING#">
    </cfif>
    <cfif len(trim(FORM.STORAGETYPE)) NEQ 0>
        and a.iSTRGTYPEID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.STORAGETYPE#">
    </cfif>
    <cfif len(trim(FORM.TAGS)) NEQ 0>
        and d.ILBLDEFID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.TAGS#">
    </cfif>
</cfquery>

<cfoutput>
    #serializeJSON(q_search_storage, "struct")#
</cfoutput>

<cfabort>