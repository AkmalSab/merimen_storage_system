<!--- <cfdump  var="#FORM#"> --->

<!--- If the form has submitted --->
	<cfif structKeyExists(FORM, "ItemName")>

        <!--- Get current date time --->
        <cfset datatime = CREATEODBCDATETIME( Now() ) />

        <!--- Default value for FNEXFILE input type file --->
        <cfparam name="form.FNEXFILE" default="">
        <cfparam  name="fileid" default="0">

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

            <cfquery name="q_insert_strg_data" datasource="#Request.MTRDSN#" result="result_insert">
                update STRG_DATA set
                    iSTRGTYPEID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.STORAGETYPE#">, --iSTRGTYPEID
                    vaITEMNAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.ITEMNAME#">, --vaITEMNAME
                    vaDESCRIPTION = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.DESCRIPTION#">, --vaDESCRIPTION
                    iOBJID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#fileid#">, --iOBJID
                    iRATING = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.RATING#">, --iRATING
                    vaREMARKS = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.REMARKS#">, --vaREMARKS
                    iMODIFIEDBY = <cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.VARS.USID#">,--iMODIFIEDBY
                    dtMODIFIEDDATE = <cfqueryparam cfsqltype="cf_sql_timestamp" value=#datatime#>, --dtMODIFIEDDATE
                    vaURLADDRESS = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.URL#">, --vaURLADDRESS
                    iDOCUMENTID = <cfqueryparam cfsqltype="cf_sql_integer" value="#fileid#">, --iDOCUMENTID
                    vaTEXTFIELD = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.LETTER#"> --vaTEXTFIELD
                where iSTRGID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.IDSTORAGE#">
		    </cfquery>
        </cfif>		
    <cflocation  url="#request.webroot#index.cfm?fusebox=MTRroot&fuseaction=dsp_home&#request.mtoken#">
</cfif>