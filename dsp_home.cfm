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
        ORDER BY iSTRGTYPEID;
    </cfquery>
    <!--- Query to fetch main storage data --->
	<!--- Query to fetch storage creator --->
	<cfquery name="q_creator_select_all" datasource="#Request.MTRDSN#">
		select distinct iUSID, vaUSName
		from SEC0001 a join STRG_DATA b
		on a.iUSID = b.vaCREATOR;
	</cfquery>
	<!--- Query to fetch storage creator --->

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
						<a type="button" class="btn btn-primary" href="#request.webroot#index.cfm?fusebox=rpt&fuseaction=dsp_viewreport&#request.mtoken#">View Report</a>
						<a type="button" class="btn btn-primary" href="#request.webroot#index.cfm?fusebox=sec&fuseaction=dsp_grouplist&#request.mtoken#">Admin</a>
					</cfoutput>					
				</div>
			</div>
			<!--- Tabs --->

			<!--- form searching --->
		<cfoutput>
			<form id="searchForm" name="searchForm" action="#" method="#">
		</cfoutput>
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
						<input type="text" class="form-control" id="Tags" name="Tags" placeholder="">
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
						<input type="reset" class="col-12 btn btn-warning" value="Reset"/>
					</div>
				</div>
			</form>
			<!--- form searching --->

			<!--- Query to fetch main storage data --->
			<cfif ArrayContains(SESSION.VARS.PERMISSION,"7004")>
				<cfquery name="q_main_storage_select_all" datasource="#Request.MTRDSN#">
					SELECT *
					FROM STRG_DATA a LEFT JOIN FDOC3006 b WITH (NOLOCK)
					ON a.iOBJID = b.IFILEID
					WHERE iCLASSIFIED = 0 
					and iCLASSIFIED = 1 
					or vaCREATOR = #SESSION.VARS.USID#
					ORDER BY iSTRGID;
				</cfquery>
				<cfelse>
					<cfquery name="q_main_storage_select_all" datasource="#Request.MTRDSN#">
						SELECT *
						FROM STRG_DATA a LEFT JOIN FDOC3006 b WITH (NOLOCK)
						ON a.iOBJID = b.IFILEID
						WHERE iCLASSIFIED = 0 
						or vaCREATOR = #SESSION.VARS.USID#
						ORDER BY iSTRGID;
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
								<th scope="col">Storage Type</th>
								<th scope="col">Description</th>
								<th scope="col">Creator - User Name</th>
								<th scope="col">Rating</th>
								<th scope="col">Classfied yes/no</th>
								<th scope="col">Status</th>
								<th scope="col">Action</th>
							</tr>
						</thead>
						<tbody id="tbodies">
							<cfoutput query="q_main_storage_select_all">
								<tr>
									<th scope="row">#dateTimeFormat(DTCREATIONDATE,'dd/mm/yyyy HH:nn:ss')#</th>									
									<td>
										<cfif ISTRGTYPEID eq 1>
										<a style="text-decoration: underline;" onclick=JSVCopenWin('#q_main_storage_select_all.VAURLADDRESS#',0,'yes',null,null,true,null)>#VAITEMNAME#</a>
										<cfelseif ISTRGTYPEID eq 2>
											<a href='docs/#VAFILEORIGNAME#' download>#VAITEMNAME#</a>
											<cfelse>
												<a style="text-decoration: underline;" onclick=JSVCopenWin('#request.webroot#index.cfm?fusebox=strg&fuseaction=dsp_viewletter&id=#iSTRGID#&#request.mtoken#',0,'yes',null,null,true,null)>#VAITEMNAME#</a>
										</cfif>										
									</td>
									<cfif ISTRGTYPEID eq 1>
										<td>URL</td>
										<cfelseif ISTRGTYPEID eq 2>
											<td>document</td>
											<cfelse>
												<td>Letter</td>
									</cfif>									
									<td>#VADESCRIPTION#</td>
									<td>#VACREATOR#</td>
									<td>#IRATING#</td>
									<cfif ICLASSIFIED EQ 0>
										<td>Anyone</td>
										<cfelse>
											<td>Only authorized users</td>
									</cfif>			
									<td>#VASTATUS#</td>
									<td>
										<a class="btn btn-primary" href='#request.webroot#index.cfm?fusebox=strg&fuseaction=dsp_updateitem&id=#iSTRGID#&#request.mtoken#'>Edit</a>
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
							td_1.innerHTML = <cfoutput>'<a style="text-decoration: underline;" onclick=JSVCopenWin("' + arr[i].VAURLADDRESS + '",0,"yes",null,null,true,null)>' + arr[i].VAITEMNAME + '</a>'</cfoutput>;
						else if(arr[i].ISTRGTYPEID == 2)
							td_1.innerHTML = <cfoutput>'<a href="#request.webroot#index.cfm?fusebox=strg&fuseaction=dsp_updateitem&id=' + arr[i].iSTRGID + '&#request.mtoken#">' + arr[i].VAITEMNAME + '</a>'</cfoutput>;
						else
							td_1.innerHTML = <cfoutput>'<a style="text-decoration: underline;" onclick=JSVCopenWin("#request.webroot#index.cfm?fusebox=strg&fuseaction=dsp_viewletter&id=' + arr[i].ISTRGID + '&#request.mtoken#",0,"yes",null,null,true,null)>' + arr[i].VAITEMNAME + '</a>'</cfoutput>;
						let td_2 = document.createElement('td');
						if(arr[i].ISTRGTYPEID == 1) td_2.innerHTML = 'URL';
						else if(arr[i].ISTRGTYPEID == 2) td_2.innerHTML = 'Document';
						else td_2.innerHTML = 'Letter';						
						let td_3 = document.createElement('td');
						td_3.innerHTML = arr[i].VADESCRIPTION;
						let td_4 = document.createElement('td');
						td_4.innerHTML = arr[i].VACREATOR;
						let td_5 = document.createElement('td');
						td_5.innerHTML = arr[i].IRATING;
						let td_6 = document.createElement('td');
						if(arr[i].ICLASSIFIED == 0) td_6.innerHTML = 'Anyone';
						else td_6.innerHTML = 'Only authorized users';
						let td_7 = document.createElement('td');
						td_7.innerHTML = arr[i].VASTATUS;
						let td_8 = document.createElement('td');
						td_8.innerHTML = <cfoutput>'<a class="btn btn-primary" href="#request.webroot#index.cfm?fusebox=strg&fuseaction=dsp_updateitem&id=' + arr[i].ISTRGID + '&#request.mtoken#">Edit</a>'</cfoutput>			
						row.appendChild(th_1)
						row.appendChild(td_1)
						row.appendChild(td_2)
						row.appendChild(td_3)
						row.appendChild(td_4)
						row.appendChild(td_5)
						row.appendChild(td_6)
						row.appendChild(td_7)
						row.appendChild(td_8)
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
