<!--- If the form has submitted --->
<cfif structKeyExists(FORM, "ItemName")>
    <cfset datatime = CREATEODBCDATETIME( Now() ) />
    <!--- <cfdump  var="#FORM#"><cfabort> --->

    <!--- Default value for FNEXFILE input type file --->
    <cfparam name="form.FNEXFILE" default="">
    <cfparam  name="fileid" default="0">
    

    <!--- If the form has key FNEXFILE which is input type file  --->
    <cfif len(trim(form.FNEXFILE))>
        <!--- Upload file to local folder --->
        <cffile action="upload" fileField="FNEXFILE" destination="C:\Development\mrmstrgsys\docs" nameConflict="makeunique" result="uploadResult">
        <!--- <cfdump  var="#uploadResult#"> --->

        <!--- query insert into FDOC3006 --->
        <cfquery name="q_insert_fdoc3006" datasource="#Request.MTRDSN#" result="result_insert_fdoc3006">
            insert into FDOC3006
            (
                VAFILEPATH,
                VAFILENAME,
                VAFILEORIGNAME,
                VAFILEEXT,
                IFILESIZE
            )
            values
            (
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#uploadResult.SERVERDIRECTORY#">, --VAFILEPATH
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#uploadResult.CLIENTFILENAME#">, --VAFILENAME
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#uploadResult.SERVERFILE#">, --VAFILEORIGNAME
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#uploadResult.CLIENTFILEEXT#">, --VAFILEEXT
                <cfqueryparam cfsqltype="cf_sql_integer" value="#uploadResult.FILESIZE#"> --IFILESIZE
            )
        </cfquery>
        <!--- query insert into FDOC3006 --->

        <!--- Get latest inserted id --->
        <cfset fileid = result_insert_fdoc3006.GENERATEDKEY>
    </cfif>

    <!--- query insert into STRG_DATA --->
    <cfquery name="q_insert_strg_data" datasource="#Request.MTRDSN#" result="result_insert">
        insert into STRG_DATA 
        (
            iSTRGTYPEID,
            vaITEMNAME,
            vaDESCRIPTION, 
            iDOMAINID,
            iOBJID,
            iRATING,
            iCLASSIFIED,
            vaREMARKS,
            vaSTATUS,
            vaCREATOR,
            dtCREATIONDATE,
            iMODIFIEDBY,
            dtMODIFIEDDATE,
            vaURLADDRESS,
            iDOCUMENTID,
            vaTEXTFIELD
        )
        values 
        ( 
            <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.STORAGETYPE#">, --iSTRGTYPEID
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.ITEMNAME#">, --vaITEMNAME
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.DESCRIPTION#">, --vaDESCRIPTION
            <cfqueryparam cfsqltype="cf_sql_integer" value=33>, --iDOMAINID
            <cfqueryparam cfsqltype="cf_sql_integer" value="#fileid#">, --iOBJID
            <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.RATING#">, --iRATING
            <cfqueryparam cfsqltype="cf_sql_integer" value=0>, --iCLASSIFIED
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.REMARKS#">, --vaREMARKS
            <cfqueryparam cfsqltype="cf_sql_varchar" value="Active">, --vaSTATUS
            <cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.vars.USID#">, --vaCREATOR
            <cfqueryparam cfsqltype="cf_sql_timestamp" value=#datatime#>, --dtCREATIONDATE
            <cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.VARS.USID#">, --iMODIFIEDBY
            <cfqueryparam cfsqltype="cf_sql_timestamp" value=#datatime#>, --dtMODIFIEDDATE
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.URL#">, --vaURLADDRESS
            <cfqueryparam cfsqltype="cf_sql_integer" value="#fileid#">, --iDOCUMENTID
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.LETTER#"> --vaTEXTFIELD
        )
    </cfquery>
    <!--- query insert into STRG_DATA --->

    <!--- Get latest inserted id --->
    <cfset id = result_insert.GENERATEDKEY>

    <!--- Redirect to home --->
    <cflocation  url="#request.webroot#index.cfm?fusebox=MTRroot&fuseaction=dsp_home&#request.mtoken#">
</cfif>