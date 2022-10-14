<cfdump  var="#FORM#">
<!--- <cfoutput>
    <cfif len(trim(FORM.CREATOR)) NEQ 0>
        and vaCREATOR = #FORM.CREATOR#
    </cfif>
    <cfif len(trim(FORM.DESCRIPTION)) NEQ 0>
        and vaDESCRIPTION LIKE '%#FORM.DESCRIPTION#%'
    </cfif>
    <cfif len(trim(FORM.GUIDATEFROM)) NEQ 0>
        and dtCREATIONDATE >= #FORM.GUIDATEFROM#
    </cfif>
    <cfif len(trim(FORM.GUIDATETO)) NEQ 0>
        and dtCREATIONDATE <= #FORM.GUIDATETO#
    </cfif>
    <cfif len(trim(FORM.ITEMNAME)) NEQ 0>
        and vaITEMNAME LIKE '%#FORM.ITEMNAME#%'
    </cfif>
    <cfif len(trim(FORM.RATING)) NEQ 0>
        and iRATING = #FORM.RATING#
    </cfif>
    <cfif len(trim(FORM.STORAGETYPE)) NEQ 0>
        and iSTRGTYPEID = #FORM.STORAGETYPE#
    </cfif>
</cfoutput> --->
<cfquery name="q_search_storage" datasource="#Request.MTRDSN#" result="result_search_storage">
    select * 
    from STRG_DATA
    where 0=0
    <cfif len(trim(FORM.CREATOR)) NEQ 0>
        and vaCREATOR = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.CREATOR#">
    </cfif>
    <cfif len(trim(FORM.DESCRIPTION)) NEQ 0>
        and vaDESCRIPTION LIKE '%#FORM.DESCRIPTION#%'
    </cfif>
    <cfif len(trim(FORM.GUIDATEFROM)) NEQ 0>
        and dtCREATIONDATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#FORM.GUIDATEFROM#">
    </cfif>
    <cfif len(trim(FORM.GUIDATETO)) NEQ 0>
        and dtCREATIONDATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#FORM.GUIDATETO#">
    </cfif>
    <cfif len(trim(FORM.ITEMNAME)) NEQ 0>
        and vaITEMNAME LIKE '%#FORM.ITEMNAME#%'
    </cfif>
    <cfif len(trim(FORM.RATING)) NEQ 0>
        and iRATING = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.RATING#">
    </cfif>
    <cfif len(trim(FORM.STORAGETYPE)) NEQ 0>
        and iSTRGTYPEID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.STORAGETYPE#">
    </cfif>
</cfquery>

<cfdump  var="#q_search_storage#">

<cfabort>