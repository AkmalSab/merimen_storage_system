<!---
FILENAME : CLAIMS/root/dsp_clmheader.cfm
DESCRIPTION :
Shortcut to redirect to Repairer/Adj/Ins subfolder claimheaders from common root
depending on COTYPE. Also checks if CASEID passed in is MAIN or SUPP and redirect
to main accordingly.

INPUT/ATTR:
SHOWRPT: Propagate SHOWRPT URL param
TPINS: Propagate TPINS URL param
MCASEID: If provided then don't need to check if caseid is main or not, otherwise
		reroute to maincaseid and put vcaseid=supplementary caseid.

OUTPUT : None.

CREATED BY : Andrew
CREATED ON : 25 Feb 2003

REVISION HISTORY
BY          ON          REMARKS
=========   ==========  ======================================================================================
--->

<!--- <cfdump  var="#Request.MTRDSN#"> --->
<cfif IsDefined("SESSION.VARS.ORGTYPE")>

	<!--- If the form has submitted --->
	<cfif structKeyExists(FORM, "ItemName")>
		<cfdump  var="#FORM#">
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
	</cfif>

	<!---    START IMPORT MERIMEN FRAMEWORK      --->
	<CFSET DS=StructNew()>
	<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCcffunctions.cfm" DS=#DS#>
	<CFSET Request.DS=DS>
	<CFSET Request.DS.FN.SVCSvrFileDSUpdate()>
	<style>
	.code {color:blue; font-family: 'courier sans ms'}
	.quest { color:red;}
	</style>
	<!--- Include these using AddFile --->
	<script>
		var request=new Object();
		<CFOUTPUT>
		request.apppath="#request.apppath#";
		request.approot="#request.approot#";
		</CFOUTPUT>
		sysdt=new Date();
	</script>
	<CFMODULE TEMPLATE="#request.apppath#services/CustomTags/SVCaddfile.cfm" FNAME="JQUERY">
	<CFMODULE TEMPLATE="#request.apppath#services/CustomTags/SVCaddfile.cfm" FNAME="SVCMAIN">
	<CFMODULE TEMPLATE="#request.apppath#services/CustomTags/SVCaddfile.cfm" FNAME="SVCCAL">
	<CFMODULE TEMPLATE="#request.apppath#services/CustomTags/SVCaddfile.cfm" FNAME="SVCCSS">
	<script>AddOnloadCode("MrmPreprocessForm()");</script>
	<!--- END IMPORT MERIMEN FRAMEWORK --->

    <!--- Query to fetch main storage data --->
    <cfquery name="q_storage_type_select_all" datasource="#Request.MTRDSN#">
        SELECT *
        FROM STRGY_TYPE WITH (NOLOCK)
        ORDER BY iSTRGTYPEID;
    </cfquery>
    <!--- Query to fetch main storage data --->

<!---     <cfdump  var="#q_storage_type_select_all#"> --->

	<html lang="en">
	<head>
		<meta charset="UTF-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>Merimen Storage System</title>
		<!--- 	Bootstrap 5 css --->
		<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
	</head>
	<body>
		<div class="container mt-3">
			<!--- Tabs --->
			<div class="row">
				<div class="col">
					<button type="button" class="btn btn-primary" onclick="submitForm()">Save</button>
					<button type="button" class="btn btn-primary">Set to Outdated</button>
					<button type="button" class="btn btn-primary">Verify</button>
                    <button type="button" class="btn btn-primary">Delete</button>
				</div>
			</div>
			<!--- Tabs --->

			<!--- Form --->
			<div class="row mt-3">
				<div class="col">
					<table class="table">
                        <tbody>
                            <cfoutput>
								<form id="createNewStorageItem" action="#request.webroot#index.cfm?fusebox=strg&fuseaction=dsp_createitem&#request.mtoken#" method="post">
							</cfoutput>
									<tr class="table-active">
										<th>Item Name</th>
										<td><input type="text" class="form-control" id="ItemName" name="ItemName" placeholder=""></td>
									</tr>
									<tr class="">
										<th>Description</th>
										<td><input type="text" class="form-control" id="Description" name="Description" placeholder=""></td>
									</tr>
									<tr class="">
										<th>Remarks</th>
										<td><textarea id="Remarks" name="Remarks" class="form-control" rows="10" cols="80"></textarea></td>
									</tr>
									<tr class="">
										<th>Storage Type</th>
										<td>
											<select class="form-select" aria-label="Default select example" id="StorageType" name="StorageType" onchange="StorageTypeChange()">
												<option value="null" selected>Open this select menu</option>
												<cfoutput query="q_storage_type_select_all">                                                    
													<option value="#ISTRGTYPEID#">#VASTRGDESCRIPTION#</option>                                                
												</cfoutput>
											</select>
										</td>
									</tr>
									<tr class="">
										<th>Rating</th>
										<td><input type="number" class="form-control" id="Rating" name="Rating" placeholder=""></td>
									</tr>
									<tr class="" style="display: none;" id="URLtr">
										<th>URL</th>
										<td><input type="text" class="form-control" id="URL" name="URL" placeholder="URL"></td>
									</tr>
									<tr class="" style="display: none;" id="Documenttr">
										<th>Document</th>
										<td><input type="file" class="form-control" id="Document" name="Document" placeholder="Document"></td>
									</tr>
									<tr class="" style="display: none;" id="Lettertr">
										<th>Letter</th>
										<td>
											<textarea id="Letter" name="Letter" rows="10" cols="80"></textarea>
										</td>
									</tr>
								</form>
                        </tbody>
                    </table>
				</div>
			</div>
			<!--- Form --->
		</div>

		<!--- 	Bootstrap 5 JS --->
		<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>

		<!--- CKEditor 4 --->
		<script src="//cdn.ckeditor.com/4.20.0/standard/ckeditor.js"></script>

		<script>
                // Replace the <textarea id="Letter"> with a CKEditor 4
                // instance, using default configuration.
                CKEDITOR.replace( 'Letter' );

				function submitForm() {
					document.getElementById("createNewStorageItem").submit();
				}


				function StorageTypeChange() {
					const StorageType = document.getElementById('StorageType').value;
					const URL = document.getElementById('URLtr');
					const Documents = document.getElementById('Documenttr');
					const Letter = document.getElementById('Lettertr');

					if(StorageType == 1) {
						URL.style.display = "table-row";
						Documents.style.display = "none";
						Letter.style.display = "none";
					}
					else if(StorageType == 2) {
						URL.style.display = "none";
						Documents.style.display = "table-row";
						Letter.style.display = "none";
					}
					else {
						URL.style.display = "none";
						Documents.style.display = "none";
						Letter.style.display = "table-row";
					}
				}
		</script>
	</body>
	</html>
<cfelse>
	<cfthrow TYPE="EX_SECFAILED" ErrorCode="NOLOGIN">
</cfif>
