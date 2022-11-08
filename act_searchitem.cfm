<!--- <cfdump  var="#FORM#"> --->

<cfset formLength = 0>

<cfloop collection="#FORM#" item="item">
    <cfoutput>#item# : #len(trim(FORM[item]))#</cfoutput>
    <cfif FORM[item] NEQ FIELDNAMES>
        <cfset formLength += len(trim(FORM[item]))> 
    </cfif>
</cfloop>

<cfset FORM.GUIDATEFROM=LSDateFormat(FORM.GUIDATEFROM,"yyyy-mm-dd","English (UK)")>
<cfset FORM.GUIDATETO=LSDateFormat(FORM.GUIDATETO,"yyyy-mm-dd","English (UK)")>

<!--- if user submit blank form --->
<cfif formLength EQ 0>
    <!--- run basic query --->
    <cfquery name="q_search_storage" datasource="#Request.MTRDSN#" result="result_search_storage">
        SELECT *, c.vaUSName
        FROM STRG_DATA a WITH (NOLOCK) LEFT JOIN FDOC3006 b WITH (NOLOCK)
        ON a.iOBJID = b.IFILEID
        LEFT JOIN SEC0001 c WITH (NOLOCK)
        ON a.vaCREATOR = c.iUSID
        WHERE iCLASSIFIED = <cfqueryparam cfsqltype="cf_sql_integer" value="0"> or vaCREATOR = <cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.VARS.USID#">
        ORDER BY iSTRGID DESC;
    </cfquery>
    <!--- if there is search criteria provided in the form --->
    <cfelse>
        <!--- run basic query with condition criteria --->
        <cfquery name="q_search_storage" datasource="#Request.MTRDSN#" result="result_search_storage">
            select *, c.vaUSName
            from STRG_DATA a WITH (NOLOCK) 
            LEFT JOIN FDOC3006 b WITH (NOLOCK) ON a.iOBJID = b.IFILEID
            LEFT JOIN SEC0001 c WITH (NOLOCK) ON a.vaCREATOR = c.iUSID
            <cfif len(trim(FORM.TAGS)) NEQ 0>
                LEFT JOIN FOBJ3020 d WITH (NOLOCK)
                ON a.iSTRGID = d.IOBJID
                LEFT JOIN FOBJB3020 e WITH (NOLOCK)
                ON d.ILBLDEFID = e.ILBLDEFID
            </cfif>
            where 0=0
            <cfif len(trim(FORM.CREATOR)) NEQ 0>
                and a.vaCREATOR = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.CREATOR#">
            </cfif>
            <cfif len(trim(FORM.DESCRIPTION)) NEQ 0>
                and a.vaDESCRIPTION LIKE <cfqueryparam cfsqltype="cf_sql_nvarchar" value="%#FORM.DESCRIPTION#%">
            </cfif>
            <cfif len(trim(FORM.GUIDATEFROM)) NEQ 0>
                and a.dtCREATIONDATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#FORM.GUIDATEFROM#">
            </cfif>
            <cfif len(trim(FORM.GUIDATETO)) NEQ 0>
                and a.dtCREATIONDATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#dateAdd('d', 1, FORM.GUIDATETO)#">
            </cfif>
            <cfif len(trim(FORM.ITEMNAME)) NEQ 0>
                and a.vaITEMNAME LIKE <cfqueryparam cfsqltype="cf_sql_nvarchar" value="%#FORM.ITEMNAME#%">
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
</cfif>

<!--- return the result in JSON format --->
<cfoutput>#serializeJSON(q_search_storage, "struct")#</cfoutput>

<!--- end process --->
<cfabort>