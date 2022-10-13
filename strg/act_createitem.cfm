<!--- If the form has submitted --->
	<cfif structKeyExists(FORM, "ItemName")>
<!--- 		<cfdump  var="#FORM#"><cfabort> --->
		<cfset datatime = CREATEODBCDATETIME( Now() ) />

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
				<cfqueryparam cfsqltype="cf_sql_integer" value=11>, --iOBJID
				<cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.RATING#">, --iRATING
				<cfqueryparam cfsqltype="cf_sql_integer" value=0>, --iCLASSIFIED
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.REMARKS#">, --vaREMARKS
				<cfqueryparam cfsqltype="cf_sql_varchar" value="Active">, --vaSTATUS
				<cfqueryparam cfsqltype="cf_sql_varchar" value="Akmal">, --vaCREATOR
				<cfqueryparam cfsqltype="cf_sql_timestamp" value=#datatime#>, --dtCREATIONDATE
				<cfqueryparam cfsqltype="cf_sql_integer" value="1">, --iMODIFIEDBY
				<cfqueryparam cfsqltype="cf_sql_timestamp" value=#datatime#>, --dtMODIFIEDDATE
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.URL#">, --vaURLADDRESS
				<cfqueryparam cfsqltype="cf_sql_integer" value="0">, --iDOCUMENTID
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.LETTER#"> --vaTEXTFIELD
			)
		</cfquery>

		<cfset id = result_insert.GENERATEDKEY>

		<cfparam name="form.FNEXFILE" default="">

		<cfif len(trim(form.FNEXFILE))>
			<cffile action="upload" fileField="FNEXFILE" destination="C:\Development\mrmstrgsys\docs" nameConflict="makeunique" result="uploadResult">
			<cfdump  var="#uploadResult#">
			<p>Thankyou, your file has been uploaded.</p>
		</cfif>
    <cflocation  url="#request.webroot#index.cfm?fusebox=MTRroot&fuseaction=dsp_home&#request.mtoken#">
</cfif>