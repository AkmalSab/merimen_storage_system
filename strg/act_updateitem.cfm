<!--- <cfdump  var="#FORM#"><cfabort> --->

<!--- If the form has submitted --->
	<cfif structKeyExists(FORM, "ItemName")>

        <!--- Default value for FNEXFILE input type file --->
        <cfparam name="form.FNEXFILE" default="">
        <cfparam name="fileid" default="0">

        <cfif structKeyExists(FORM, "EDITSTORAGE")>

            <!--- If the form has key FNEXFILE which is input type file  --->
            <cfif len(trim(form.FNEXFILE)) NEQ 0>
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

            <!--- Get latest inserted id --->
            <cfset id="">

            <!--- query update STRG_DATA --->
            <cfstoredproc  procedure="sspSTRGDataInsertUpdate" datasource="#Request.MTRDSN#">
                <cfprocparam type="in" cfsqltype="cf_sql_integer" value="#FORM.IDSTORAGE#" dbVarName=@ai_strgid>
                <cfprocparam type="in" cfsqltype="cf_sql_integer" value="#FORM.STORAGETYPE#" dbVarName=@ai_strgtypeid>, <!--- iSTRGTYPEID --->
                <cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#FORM.ITEMNAME#" dbVarName=@as_itemname>, <!--- vaITEMNAME --->
                <cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#FORM.DESCRIPTION#" dbVarName=@as_description>, <!--- vaDESCRIPTION --->
                <cfprocparam type="in" cfsqltype="cf_sql_integer" value="#fileid#" dbVarName=@ai_objid>, <!--- iOBJID --->
                <cfprocparam type="in" cfsqltype="cf_sql_integer" value="#FORM.RATING#" dbVarName=@ai_rating>, <!--- iRATING --->
                <cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#FORM.REMARKS#" dbVarName=@as_remarks>, <!--- vaREMARKS --->
                <cfprocparam type="in" cfsqltype="cf_sql_integer" value="#FORM.CLASSIFIED#" dbVarName=@ai_classfied>, <!--- iCLASSIFIED --->
                <cfprocparam type="in" cfsqltype="cf_sql_integer" value="#SESSION.VARS.USID#" dbVarName=@ai_modifiedby>, <!--- iMODIFIEDBY --->
                <cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#FORM.URL#" dbVarName=@as_urladdress>, <!--- vaURLADDRESS --->
                <cfprocparam type="in" cfsqltype="cf_sql_integer" value="#fileid#" dbVarName=@ai_documentid>, <!--- iDOCUMENTID --->
                <cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#FORM.LETTER#" dbVarName=@as_textfield> <!--- vaTEXTFIELD --->
                <cfprocparam type="out" CFSQLType="cf_sql_integer" variable="id" dbVarName=@li_id> <!--- last id --->
            </cfstoredproc>
            <!--- query update STRG_DATA --->

            <!--- Query to insert audit logs --->
            <cfquery name="q_last_id" datasource="#Request.MTRDSN#">
                SELECT TOP 1 ITAID
                FROM [FOBJ3010] WITH (NOLOCK)
                WHERE IDOMAINID = 901
                ORDER BY ITAID DESC
            </cfquery>

            <cfset ITAID = q_last_id.ITAID + 1>

            <cfstoredproc PROCEDURE="sspFOBJAudit" DATASOURCE="#Request.MTRDSN#" RETURNCODE=YES>
                <cfprocparam TYPE=IN DBVARNAME=@ITAID VALUE="#ITAID#" CFSQLTYPE="CF_SQL_INTEGER">
                <cfprocparam TYPE=IN DBVARNAME=@ITATYPEID VALUE="1000613" CFSQLTYPE="CF_SQL_INTEGER">
                <cfprocparam TYPE=IN DBVARNAME=@ai_usid VALUE="#SESSION.VARS.USID#" CFSQLTYPE="CF_SQL_INTEGER">
                <cfprocparam TYPE=IN DBVARNAME=@ICRTCOROLE NULL="YES" CFSQLTYPE="CF_SQL_INTEGER">
                <cfprocparam TYPE=IN DBVARNAME=@ICRTCOSECPOS NULL="YES" CFSQLTYPE="CF_SQL_INTEGER">
                <cfprocparam TYPE=IN DBVARNAME=@DTCURDT NULL="YES" CFSQLTYPE="CF_SQL_TIMESTAMP">
                <cfprocparam TYPE=IN DBVARNAME=@IDOMAINID VALUE="901" CFSQLTYPE="CF_SQL_INTEGER">
                <cfprocparam TYPE=IN DBVARNAME=@IOBJID VALUE="#FORM.IDSTORAGE#" CFSQLTYPE="CF_SQL_INTEGER">
                <cfprocparam TYPE=IN DBVARNAME=@ILINKID NULL="YES" CFSQLTYPE="CF_SQL_INTEGER">
                <cfprocparam TYPE=IN DBVARNAME=@IPARAM1 VALUE="4" CFSQLTYPE="CF_SQL_INTEGER">
                <cfprocparam TYPE=IN DBVARNAME=@VATAREMARKS VALUE="UPDATE STORAGE CONTENT" CFSQLTYPE="CF_SQL_VARCHAR">
            </cfstoredproc>

            <cfdump  var="#cfstoredproc#">
            <!--- Query to insert audit logs --->
        </cfif>		

        <!--- Insert into labels transaction table (FOBJ3020) --->
        <cfif structKeyExists(FORM, "TAGS")>
            <cfloop list="#form.TAGS#" index="item">
                <cfoutput>
                    <cfquery name="q_insert_tags" datasource="#request.mtrdsn#">
                        insert into FOBJ3020 (ILBLDEFID, IDOMAINID, IOBJID, dtCRTON) values (#item#,901,#id#,GETDATE())
                    </cfquery>
                </cfoutput>
            </cfloop>
        </cfif>
    <cflocation  url="#request.webroot#index.cfm?fusebox=MTRroot&fuseaction=dsp_home&#request.mtoken#">
</cfif>