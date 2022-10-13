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

<cfif IsDefined("SESSION.sessionid")>

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
<!--- 		<cflocation  url="#request.webroot#index.cfm?fusebox=MTRroot&fuseaction=dsp_home&#request.mtoken#"> --->
		
	</cfif>

	<!--- If the user is viewing current item --->
	<cfif isDefined('URL.Id')>
		<!--- Query to fetch specific item --->
		<cfquery name="q_main_storage_select_specific" datasource="#Request.MTRDSN#">
			SELECT *
			FROM STRG_DATA WITH (NOLOCK)
			WHERE iSTRGID = #URL.id#
		</cfquery>

<!--- 		<cfdump  var="#q_main_storage_select_specific#"> --->
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
	<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCaddfile.cfm" FNAME="SVCDOC">

	<script>AddOnloadCode("MrmPreprocessForm()");</script>
	<!--- END IMPORT MERIMEN FRAMEWORK --->

    <!--- Query to fetch main storage data --->
    <cfquery name="q_storage_type_select_all" datasource="#Request.MTRDSN#">
        SELECT *
        FROM STRGY_TYPE WITH (NOLOCK)
        ORDER BY iSTRGTYPEID;
    </cfquery>
    <!--- Query to fetch main storage data --->

<!--- 	<cfdump  var="#q_storage_type_select_all#"> --->

	<html lang="en">
	<head>
		<meta charset="UTF-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>Merimen Storage System</title>
		<!--- 	Bootstrap 5 css --->
		<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
		<!--- Jquery --->
		<script src="https://code.jquery.com/jquery-3.6.1.min.js" integrity="sha256-o88AwQnZB+VDvE9tvIXrMQaPlFFSUTR+nldQm1LuPXQ=" crossorigin="anonymous"></script>
	</head>
	<body onload="StorageTypeChange()">
		<div class="container mt-3">

			<!--- Update status alert --->
			<div id="statusAlert" class="row" style="display: none;">
				<div class="col">
					<div class="alert alert-success alert-dismissible fade show" role="alert">
						<strong>Successfully!</strong> update item storage status to <strong><span id="storageStatus"></span></strong>.
						<button type="button" class="btn-close" onclick="hideStatusAlert()" aria-label="Close"></button>
					</div>
				</div>
			</div>
			<!--- Tabs --->
			<div class="row">
				<div class="col">
					<button type="button" class="btn btn-primary" onclick="submitForm()">Save</button>
					<cfif isDefined('URL.Id')>
						<button type="button" class="btn btn-primary" onclick="updateStatus('Outdated')">Set to Outdated</button>
						<button type="button" class="btn btn-primary" onclick="updateStatus('Verified')">Verify</button>
						<button type="button" class="btn btn-primary" onclick="updateStatus('Deleted')">Delete</button>
					</cfif>					
				</div>
			</div>
			<!--- Tabs --->

			<!--- Form --->
			<div class="row mt-3">
				<div class="col">
					<table class="table">
                        <tbody>
                            <cfoutput>
								<form id="createNewStorageItem" name="createNewStorageItem" action="#request.webroot#index.cfm?fusebox=strg&fuseaction=dsp_createitem&#request.mtoken#" method="post" enctype="multipart/form-data">		
							</cfoutput>					
									<tr class="table-active">
										<td class=clsField1>Item Name</td>
										<td class=clsValue1>
											<cfoutput>
												<cfif isDefined('URL.Id')>
													<input type="text" class="form-control" id="ItemName" name="ItemName" value="#q_main_storage_select_specific.VAITEMNAME#" onblur="ObjUpperCase(this)" CHKREQUIRED>
													<cfelse>
														<input type="text" class="form-control" id="ItemName" name="ItemName" onblur="ObjUpperCase(this)" CHKREQUIRED>
												</cfif>
											</cfoutput>
										</td>
									</tr>
									<tr class="">
										<td class=clsField1>Description</td>
										<td class=clsValue1>
											<cfoutput>
												<cfif isDefined('URL.Id')>
													<input type="text" class="form-control" id="Description" name="Description" value="#q_main_storage_select_specific.VADESCRIPTION#" onblur="ObjUpperCase(this)" CHKREQUIRED>
													<cfelse>
														<input type="text" class="form-control" id="Description" name="Description" onblur="ObjUpperCase(this)" CHKREQUIRED>
												</cfif>		
											</cfoutput>									
										</td>
									</tr>
									<tr class="table-active">
										<td class=clsField1>Remarks</td>
										<td class=clsValue1>
											<cfoutput>
												<cfif isDefined('URL.Id')>
													<textarea id="Remarks" name="Remarks" class="form-control" rows="10" cols="80" onblur="ObjUpperCase(this)" CHKREQUIRED>#q_main_storage_select_specific.VAREMARKS#</textarea>
													<cfelse>
														<textarea id="Remarks" name="Remarks" class="form-control" rows="10" cols="80" onblur="ObjUpperCase(this)" CHKREQUIRED></textarea>
												</cfif>
											</cfoutput>											
										</td>
									</tr>
									<tr class="">
										<td class=clsField1>Storage Type</td>
										<td class=clsValue1>
											<select class="form-select" aria-label="Default select example" id="StorageType" name="StorageType" onchange="StorageTypeChange()" onblur="ObjUpperCase(this)" CHKREQUIRED>
												<option value="null" selected>Open this select menu</option>
												<cfoutput query="q_storage_type_select_all">   
													<cfif isDefined('URL.Id')>
														<cfif q_main_storage_select_specific.ISTRGTYPEID EQ ISTRGTYPEID>
															<option value="#ISTRGTYPEID#" selected>#VASTRGDESCRIPTION#</option>
															<cfelse>
																<option value="#ISTRGTYPEID#">#VASTRGDESCRIPTION#</option>
														</cfif>														
													</cfif>
													<option value="#ISTRGTYPEID#">#VASTRGDESCRIPTION#</option>
												</cfoutput>
											</select>
										</td>
									</tr>
									<tr class="table-active">
										<td class=clsField1>Rating</td>
										<td class=clsValue1>
											<cfoutput>
												<cfif isDefined('URL.Id')>
													<input type="number" class="form-control" id="Rating" name="Rating" min="1" max="5" value="#q_main_storage_select_specific.IRATING#" onblur="JSVCNumLOC(this,1,5,null,null,null,null,null,false,false,alertmsg)" CHKREFORMAT="^([0-9]{1})$" CHKREQUIRED>
													<cfelse>
														<input type="number" class="form-control" id="Rating" name="Rating" min="1" max="5" onblur="JSVCNumLOC(this,1,5,null,null,null,null,null,false,false,alertmsg)" CHKREFORMAT="^([0-9]{1})$" CHKREQUIRED>
												</cfif>			
											</cfoutput>								
										</td>
									</tr>
									<tr class="" style="display: none;" id="URLtr">
										<td class=clsField1>URL</td>
										<td class=clsValue1>
											
											<cfoutput>
												<cfif isDefined('URL.Id')>
													<input type="text" class="form-control" id="URL" name="URL" value="#q_main_storage_select_specific.VAURLADDRESS#" placeholder="URL">
													<cfelse>
														<input type="text" class="form-control" id="URL" name="URL" placeholder="URL">
												</cfif>			
											</cfoutput>
										</td>
									</tr>
									<tr class="" style="display: none;" id="Documenttr">
										<td class=clsField1>Document</td>
										<td class=clsValue1>
											<script>SVCDocSingleDocAttach("Upload Docs","ExFile",1000000,"DOC,DOCX,RTF,TXT,XLS,XLSX,PPT,PPTX,PDF,GIF,JPE,JPEG,JPG,PNG,HTM,HTML,TIF,TIFF",0,1,0);</script>			
										</td>
									</tr>
									<tr class="" style="display: none;" id="Lettertr">
										<td class=clsField1>Letter</td>
										<td class=clsValue1>
											<cfoutput>
												<cfif isDefined('URL.Id')>
													<textarea id="Letter" name="Letter" rows="10" cols="80">#q_main_storage_select_specific.VATEXTFIELD#</textarea>
													<cfelse>
														<textarea id="Letter" name="Letter" rows="10" cols="80"></textarea>
												</cfif>			
											</cfoutput>											
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
                CKEDITOR.replace('Letter');

				function submitForm() {
					if (FormVerify(document.all('createNewStorageItem'))) {
                    	alert('Everything OK');
						document.getElementById("createNewStorageItem").submit();
					}
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

				function updateStatus(ItemStatus){
					// AJAX POST Request
					$.post("index.cfm?fusebox=strg&fuseaction=act_updatestatus", //url
					{
						iSTRGID: <cfoutput>#URL.ID#</cfoutput>, //data
						Status: ItemStatus
					},
					function(data, status){ //callback
						// var res = JSON.parse(data)
						console.log(data, status, ItemStatus)						
					});
					document.getElementById("statusAlert").style.display = 'block';
					document.getElementById("storageStatus").innerHTML = ItemStatus;
				}

				function hideStatusAlert() {
					document.getElementById("statusAlert").style.display = 'none';
				}
		</script>
	</body>
	</html>
<cfelse>
	<cfthrow TYPE="EX_SECFAILED" ErrorCode="NOLOGIN">
</cfif>
