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
<cfif IsDefined("SESSION.VARS.ORGTYPE")>

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
        ORDER BY iSTRGTYPEID DESC;
    </cfquery>
    <!--- Query to fetch main storage data --->
	<!--- Query to fetch storage creator --->
	<cfquery name="q_creator_select_all" datasource="#Request.MTRDSN#">
		select distinct iUSID, vaUSName
		from SEC0001 a WITH (NOLOCK) inner join STRG_DATA b WITH (NOLOCK)
		on a.iUSID = b.vaCREATOR;
	</cfquery>
	<!--- Query to fetch storage creator --->
	<!--- Query to fetch labels --->
	<cfquery name="q_select_all_label" datasource="#Request.MTRDSN#">
		SELECT *
		FROM FOBJB3020 WITH (NOLOCK)
		WHERE IDOMAINID = <cfqueryparam cfsqltype="cf_sql_integer" value="901">
	</cfquery>
	<!--- Query to fetch labels --->

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
					<cfoutput>
						<cfif ArrayContains(SESSION.VARS.PERMISSION,"7000")>
							<a type="button" class="btn btn-primary" href="#request.webroot#index.cfm?fusebox=strg&fuseaction=dsp_createitem&#request.mtoken#">Create New Item</a>
						</cfif>			
						<cfif ArrayContains(SESSION.VARS.PERMISSION,"7007")>
							<a type="button" class="btn btn-primary" href="#request.webroot#index.cfm?fusebox=rpt&fuseaction=dsp_viewreport&#request.mtoken#">View Report</a>
						</cfif>									
						<cfif ArrayContains(SESSION.VARS.PERMISSION,"7006")>
							<a type="button" class="btn btn-primary" href="#request.webroot#index.cfm?fusebox=sec&fuseaction=dsp_grouplist&#request.mtoken#">Admin</a>
						</cfif>
					</cfoutput>					
				</div>
			</div>
			<!--- Tabs --->

			<!--- form searching --->
			<form id="searchForm" name="searchForm" action="#" method="#">
				<!--- Search criteria line 1 --->
				<div class="row mt-3">
					<div class="col-12 col-md-6 col-lg-4">
						<label for="StorageType" class="form-label">Storage Type:</label>
						<select class="form-select" aria-label="Default select example" id="StorageType" name="StorageType">
							<option value="">Open this select menu</option>
							<cfoutput query="q_storage_type_select_all">
								<option value="#q_storage_type_select_all.ISTRGTYPEID#">#q_storage_type_select_all.VASTRGDESCRIPTION#</option>
							</cfoutput>
						</select>
					</div>
					<div class="col-12 col-md-6 col-lg-4">
						<label for="ItemName" class="form-label">Item Name:</label>
						<input type="text" class="form-control" id="ItemName" name="ItemName" placeholder="">
						<cfoutput><input type="hidden" class="form-control" id="USID" name="USID" value="#SESSION.VARS.USID#"></cfoutput>
					</div>
					<div class="col-12 col-md-6 col-lg-4">
						<label for="Description" class="form-label">Description:</label>
						<input type="text" class="form-control" id="Description" name="Description" placeholder="">
					</div>
				</div>
				<!--- Search criteria line 1 --->

				<!--- Search criteria line 2 --->
				<div class="row mt-3">
					<div class="col-12 col-md-6 col-lg-4">
						<label for="Creator" class="form-label">Creator:</label>
						<select class="form-select" aria-label="Default select example" id="Creator" name="Creator">
							<option value="">Open this select menu</option>
							<cfoutput query="q_creator_select_all">
								<option value="#q_creator_select_all.iUSID#">#q_creator_select_all.vaUSName#</option>
							</cfoutput>
						</select>
					</div>
					<div class="col-12 col-md-6 col-lg-4">
						<label for="Tags" class="form-label">Tags:</label>
						<select class="form-select" aria-label="Default select example" id="Tags" name="Tags">
							<option value="">Open this select menu</option>
							<cfoutput query="q_select_all_label">
								<option value="#q_select_all_label.ILBLDEFID#">#q_select_all_label.VALBLDESC#</option>
							</cfoutput>
						</select>
					</div>
					<div class="col-12 col-md-6 col-lg-4">
						<label for="Rating" class="form-label">Rating:</label>
						<select class="form-select" aria-label="Default select example" id="Rating" name="Rating">
							<option value="">Open this select menu</option>
							<option value="1">1</option>
							<option value="2">2</option>
							<option value="3">3</option>
							<option value="4">4</option>
							<option value="5">5</option>
						</select>
					</div>
				</div>
				<!--- Search criteria line 2 --->

				<!--- Date range --->
				<div class="row mt-3">
					<div class="col">
						<table>
							<tr>
								<td class=clsValue1>
									<label for="DateFrom" class="form-label">Date From:</label>
									<input class="form-control" MRMOBJ=CALDATE id="GUIdateFrom" name="GUIdateFrom" type=text>
								</td>
								<td class=clsValue1>
									<label for="DateTo" class="form-label">Date To:</label>
									<input class="form-control" MRMOBJ=CALDATE id="GUIdateTo" name="GUIdateTo" type=text>
								</td>
							</tr>
						</table>
					</div>
				</div>
				<!--- Date range --->

				<div class="row mt-3">
					<div class="col-12 col-md-6 col-lg-4">
						<input type="button" class="col-12 btn btn-secondary" value="Search" onclick="searchStorage()"/>
					</div>
					<div class="mt-sm-2 mt-md-0 col-12 col-md-6 col-lg-4">
						<input type="reset" class="col-12 btn btn-warning" value="Reset" onclick="clearForm(this.form);"/>
					</div>
				</div>
			</form>
			<!--- form searching --->

			<script>
				function clearForm(searchForm) {
					var frm_elements = searchForm.elements; 
					for(i=0; i<frm_elements.length; i++)
					{
						// console.log(frm_elements[i].id)
						if (frm_elements[i].checked)
							frm_elements[i].checked = false;
						else if(frm_elements[i].type != 'button' && frm_elements[i].type != 'reset' && frm_elements[i].id != 'USID') frm_elements[i].value = '';
					}	
				}				
			</script>

			<!--- Query to fetch main storage data --->
			<cfif ArrayContains(SESSION.VARS.PERMISSION,"7004")>
				<cfquery name="q_main_storage_select_all" datasource="#Request.MTRDSN#">
					SELECT *, c.vaUSName
					FROM STRG_DATA a WITH (NOLOCK) LEFT JOIN FDOC3006 b WITH (NOLOCK)
					ON a.iOBJID = b.IFILEID
					LEFT JOIN SEC0001 c WITH (NOLOCK)
					ON a.vaCREATOR = c.iUSID
					WHERE iCLASSIFIED in (<cfqueryparam cfsqltype="cf_sql_integer" list="yes" value="0,1">)
					or vaCREATOR = <cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.VARS.USID#">
					ORDER BY iSTRGID DESC;
				</cfquery>
				<cfelse>
					<cfquery name="q_main_storage_select_all" datasource="#Request.MTRDSN#">
						SELECT *, c.vaUSName
						FROM STRG_DATA a WITH (NOLOCK) LEFT JOIN FDOC3006 b WITH (NOLOCK)
						ON a.iOBJID = b.IFILEID
						LEFT JOIN SEC0001 c WITH (NOLOCK)
						ON a.vaCREATOR = c.iUSID
						WHERE iCLASSIFIED = <cfqueryparam cfsqltype="cf_sql_integer" value="0"> or vaCREATOR = <cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.VARS.USID#">
						ORDER BY iSTRGID DESC;
					</cfquery>
			</cfif>
			
			<!--- <cfdump  var="#q_main_storage_select_all#"> --->
			<!--- Query to fetch main storage data --->
			
			<!--- Table --->
			<div class="row mt-3">
				<div class="col">
					<table id="main_storage" class="table table-striped table-hover">
						<thead>
							<tr>
								<th scope="col">Created On</th>
								<th scope="col">Item Name</th>
								<th scope="col">Type</th>
								<th scope="col">Description</th>
								<th scope="col">User Name</th>
								<th scope="col">Tags</th>
								<th scope="col">Rating</th>
								<th scope="col">Classfied</th>
								<th scope="col">Status</th>
								<th scope="col" class="text-center" colspan="2">Action</th>
							</tr>
						</thead>
						<tbody id="tbodies">
							<cfoutput query="q_main_storage_select_all">
								<tr>
									<th scope="row">#dateTimeFormat(DTCREATIONDATE,'dd/mm/yyyy HH:nn:ss')#</th>									
									<td>
										#VAITEMNAME#						
									</td>
									<cfif ISTRGTYPEID eq 1>
										<td>URL</td>
										<cfelseif ISTRGTYPEID eq 2>
											<td>document</td>
											<cfelse>
												<td>Letter</td>
									</cfif>									
									<td>#VADESCRIPTION#</td>
									<td>#VAUSNAME#</td>
									<td>
										<cfquery name="q_select_labels_for_specific_item" datasource="#Request.MTRDSN#">
											SELECT e.*
											FROM STRG_DATA a WITH (NOLOCK)
											LEFT JOIN FOBJ3020 d WITH (NOLOCK)
											ON a.iSTRGID = d.IOBJID
											LEFT JOIN FOBJB3020 e WITH (NOLOCK)
											ON d.ILBLDEFID = e.ILBLDEFID
											WHERE a.iSTRGID = <cfqueryparam value="#ISTRGID#" cfsqltype="cf_sql_integer"> 
											AND  d.IDOMAINID = <cfqueryparam value="901" cfsqltype="cf_sql_integer">
											ORDER BY iSTRGID
										</cfquery>
										<cfloop query="q_select_labels_for_specific_item">
											<span style="color:#ICOLORTXT#;background-color:#ICOLORBGRND#;">#VALBLNAME#</span> <br>
										</cfloop>
									</td>
									<td>#IRATING#</td>
									<cfif ICLASSIFIED EQ 0>
										<td>No</td>
										<cfelse>
											<td>Yes</td>
									</cfif>			
									<td>#VASTATUS#</td>
									<cfif ArrayContains(SESSION.VARS.PERMISSION,"7005")>
										<td>											
											<a class="btn btn-primary" href='#request.webroot#index.cfm?fusebox=strg&fuseaction=dsp_updateitem&id=#iSTRGID#&#request.mtoken#'>Edit</a>								
										</td>
									</cfif>
									<td>
										<cfif ISTRGTYPEID eq 1>
										<a class="btn btn-primary" onclick=JSVCopenWin('#q_main_storage_select_all.VAURLADDRESS#',0,'yes',null,null,true,null)>View</a>
										<cfelseif ISTRGTYPEID eq 2>
											<a class="btn btn-primary" href='docs/#VAFILEORIGNAME#' download>View</a>
											<cfelse>
												<a class="btn btn-primary" onclick=JSVCopenWin('#request.webroot#index.cfm?fusebox=strg&fuseaction=dsp_viewletter&id=#iSTRGID#&#request.mtoken#',0,'yes',null,null,true,null)>View</a>
										</cfif>
									</td>				
								</tr>		
							</cfoutput>												
						</tbody>
					</table>
				</div>
			</div>
			<!--- Table --->

			<!--- 	Logout --->
			<cfoutput>
				<div class="row mt-3">
					<div class="col">
						<a class="btn btn-danger" href="#request.webroot#index.cfm?fusebox=sec&fuseaction=act_logout&#request.mtoken#">Log out</a>
					</div>
				</div>
			</cfoutput>
			<!--- 	Logout --->
		</div>

		<!--- 	Bootstrap 5 JS --->
		<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>

		<script>
			function searchStorage(){
				// AJAX POST Request
				$.post("index.cfm?fusebox=search", //url
				$("#searchForm").serializeArray(), //data
				function(data, status){ //callback
					console.log(data);
					let string = '';
					let bool = false;
					for (var i = 0; i < data.length; i++) {
						if(data.charAt(i) == '['){
							bool = true
							string += data.charAt(i)
						}
						if(bool) string += data.charAt(i)
					}
					const arr = JSON.parse(string.slice(1));

					console.log(arr);

					var table = document.getElementById ("main_storage");
					var tb = document.querySelectorAll('tbody');
					var tbs = document.getElementById('tbodies');

					// remove all tbody's row
					$("#main_storage tbody tr").remove();
					
					for(let i=0; i<arr.length;i++){
						let row = document.createElement('tr');
						let th_1 = document.createElement('th');
						th_1.innerHTML = arr[i].DTCREATIONDATE;						
						let td_1 = document.createElement('td');
						if(arr[i].ISTRGTYPEID == 1)
							td_1.innerHTML = arr[i].VAITEMNAME;
						else if(arr[i].ISTRGTYPEID == 2)
							td_1.innerHTML = arr[i].VAITEMNAME;
						else
							td_1.innerHTML = arr[i].VAITEMNAME;
						let td_2 = document.createElement('td');
						if(arr[i].ISTRGTYPEID == 1) td_2.innerHTML = 'URL';
						else if(arr[i].ISTRGTYPEID == 2) td_2.innerHTML = 'Document';
						else td_2.innerHTML = 'Letter';						
						let td_3 = document.createElement('td');
						td_3.innerHTML = arr[i].VADESCRIPTION;
						let td_4 = document.createElement('td');
						td_4.innerHTML = arr[i].VAUSNAME;
						let td_5 = document.createElement('td');
						td_5.innerHTML = arr[i].IRATING;
						let td_6 = document.createElement('td');
						if(arr[i].ICLASSIFIED == 0) td_6.innerHTML = 'Anyone';
						else td_6.innerHTML = 'Only authorized users';
						let td_7 = document.createElement('td');
						td_7.innerHTML = arr[i].VASTATUS;
						let td_8 = document.createElement('td');
						td_8.innerHTML = <cfoutput>'<a class="btn btn-primary" href="#request.webroot#index.cfm?fusebox=strg&fuseaction=dsp_updateitem&id=' + arr[i].ISTRGID + '&#request.mtoken#">Edit</a>'</cfoutput>		

						let td_9 = document.createElement('td');
						td_9.innerHTML = '<span style="color:#'+ arr[i].ICOLORTXT + ';background-color:#' + arr[i].ICOLORBGRND +';">' + arr[i].VALBLNAME + '</span>';

						let td_10 = document.createElement('td');
						if(arr[i].ISTRGTYPEID == 1)
							td_10.innerHTML = <cfoutput>'<a class="btn btn-primary" style="text-decoration: underline;" onclick=JSVCopenWin("' + arr[i].VAURLADDRESS + '",0,"yes",null,null,true,null)>View</a>'</cfoutput>;
						else if(arr[i].ISTRGTYPEID == 2)
							td_10.innerHTML = '<a class="btn btn-primary" href="docs/'+ arr[i].VAFILEORIGNAME +'" download>View</a>';
						else
							td_10.innerHTML = <cfoutput>'<a class="btn btn-primary" style="text-decoration: underline;" onclick=JSVCopenWin("#request.webroot#index.cfm?fusebox=strg&fuseaction=dsp_viewletter&id=' + arr[i].ISTRGID + '&#request.mtoken#",0,"yes",null,null,true,null)>View</a>'</cfoutput>;
						row.appendChild(th_1)
						row.appendChild(td_1)
						row.appendChild(td_2)
						row.appendChild(td_3)
						row.appendChild(td_4)
						row.appendChild(td_9)
						row.appendChild(td_5)
						row.appendChild(td_6)
						row.appendChild(td_7)
						row.appendChild(td_8)
						row.appendChild(td_10)
						tbs.appendChild(row)
					}
					
				});
			}
		</script>
	</body>
	</html>
<cfelse>
	<cfthrow TYPE="EX_SECFAILED" ErrorCode="NOLOGIN">
</cfif>
