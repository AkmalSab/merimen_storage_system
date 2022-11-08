<!--- If the form has submitted --->
<cfif structKeyExists(FORM, "ItemName")>

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

    <!--- Get latest inserted id --->
    <cfset id="">

    <cfstoredproc  procedure="sspSTRGDataInsertUpdate" datasource="#Request.MTRDSN#">
        <cfprocparam type="in" cfsqltype="cf_sql_integer" value="#FORM.STORAGETYPE#" dbVarName=@ai_strgtypeid>, <!--- iSTRGTYPEID --->
        <cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#FORM.ITEMNAME#" dbVarName=@as_itemname>, <!--- vaITEMNAME --->
        <cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#FORM.DESCRIPTION#" dbVarName=@as_description>, <!--- vaDESCRIPTION --->
        <cfprocparam type="in" cfsqltype="cf_sql_integer" value=33 dbVarName=@ai_domainid>, <!--- iDOMAINID --->
        <cfprocparam type="in" cfsqltype="cf_sql_integer" value="#fileid#" dbVarName=@ai_objid>, <!--- iOBJID --->
        <cfprocparam type="in" cfsqltype="cf_sql_integer" value="#FORM.RATING#" dbVarName=@ai_rating>, <!--- iRATING --->
        <cfprocparam type="in" cfsqltype="cf_sql_integer" value="#FORM.CLASSIFIED#" dbVarName=@ai_classfied>, <!--- iCLASSIFIED --->
        <cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#FORM.REMARKS#" dbVarName=@as_remarks>, <!--- vaREMARKS --->
        <cfprocparam type="in" cfsqltype="cf_sql_varchar" value="Active" dbVarName=@as_status>, <!--- vaSTATUS --->
        <cfprocparam type="in" cfsqltype="cf_sql_integer" value="#SESSION.vars.USID#" dbVarName=@ai_creator>, <!--- vaCREATOR --->
        <cfprocparam type="in" cfsqltype="cf_sql_integer" value="#SESSION.VARS.USID#" dbVarName=@ai_modifiedby>, <!--- iMODIFIEDBY --->
        <cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#FORM.URL#" dbVarName=@as_urladdress>, <!--- vaURLADDRESS --->
        <cfprocparam type="in" cfsqltype="cf_sql_integer" value="#fileid#" dbVarName=@ai_documentid>, <!--- iDOCUMENTID --->
        <cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#FORM.LETTER#" dbVarName=@as_textfield> <!--- vaTEXTFIELD --->
        <cfprocparam type="out" CFSQLType="cf_sql_integer" variable="id" dbVarName=@li_id> <!--- last id --->
    </cfstoredproc>
    <!--- query insert into STRG_DATA --->

    <cfoutput>
        id = #id#
    </cfoutput>

    <!--- Insert into labels transaction table (FOBJ3020) --->
    <cfif structKeyExists(FORM, "TAGS")>
        <cfloop list="#form.TAGS#" index="item">
            <cfoutput>
                <cfquery name="q_insert_tags" datasource="#request.mtrdsn#">
                    insert into FOBJ3020 (ILBLDEFID, IDOMAINID, IOBJID, dtCRTON) 
                    values (
                        <cfqueryparam value="#item#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="901" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#GETDATE()#" cfsqltype="cf_sql_timestamp">                        
                    )
                </cfquery>
            </cfoutput>
        </cfloop>
    </cfif>   

    <!--- Redirect to home --->
    <cflocation  url="#request.webroot#index.cfm?fusebox=MTRroot&fuseaction=dsp_home&#request.mtoken#">
</cfif>