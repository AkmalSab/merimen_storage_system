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
						<a type="button" class="btn btn-primary" href="#request.webroot#index.cfm?fusebox=strg&fuseaction=dsp_createitem&#request.mtoken#">Create New Item</a>
						<a type="button" class="btn btn-primary" href="#request.webroot#index.cfm?fusebox=strg&fuseaction=dsp_createitem&#request.mtoken#">View Report</a>
						<a type="button" class="btn btn-primary" href="#request.webroot#index.cfm?fusebox=strg&fuseaction=dsp_createitem&#request.mtoken#">Admin</a>
					</cfoutput>					
				</div>
			</div>
			<!--- Tabs --->

			<!--- Search criteria line 1 --->
			<div class="row mt-3">
				<div class="col">
					<label for="StorageType" class="form-label">Storage Type:</label>
					<select class="form-select" aria-label="Default select example">
						<option selected>Open this select menu</option>
						<option value="1">URL</option>
						<option value="2">Document</option>
						<option value="3">PDF</option>
					</select>
				</div>
				<div class="col">
					<label for="ItemName" class="form-label">Item Name:</label>
  					<input type="text" class="form-control" id="ItemName" placeholder="">
				</div>
				<div class="col">
					<label for="Description" class="form-label">Description:</label>
  					<input type="text" class="form-control" id="Description" placeholder="">
				</div>
			</div>
			<!--- Search criteria line 1 --->

			<!--- Search criteria line 2 --->
			<div class="row mt-3">
				<div class="col">
					<label for="Creator" class="form-label">Creator:</label>
					<select class="form-select" aria-label="Default select example">
						<option selected>Open this select menu</option>
						<option value="1">1</option>
						<option value="2">2</option>
						<option value="3">3</option>
					</select>
				</div>
				<div class="col">
					<label for="Tags" class="form-label">Tags:</label>
  					<input type="text" class="form-control" id="Tags" placeholder="">
				</div>
				<div class="col">
					<label for="Creator" class="form-label">Rating:</label>
					<select class="form-select" aria-label="Default select example">
						<option selected>Open this select menu</option>
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
					<form action="test" method="post" name="testform">
						<table>
							<tr>
								<td class=clsValue1>
									<label for="DateFrom" class="form-label">Date From:</label>
									<input class="form-control" MRMOBJ=CALDATE CHKREQUIRED name=GUIdate id=GUIdate type=text>
								</td>
								<td class=clsValue1>
									<label for="DateTo" class="form-label">Date To:</label>
									<input class="form-control" MRMOBJ=CALDATE CHKREQUIRED name=GUIdate id=GUIdate type=text>
								</td>
							</tr>
						</table>
						<!---	<input type=button value="TEST SUBMIT" onclick="if (FormVerify(document.all('testform'))) alert('Everything OK');" class="clsButton"> --->
					</form>
				</div>
			</div>
			<!--- Date range --->

			<div class="row mt-3">
				<div class="col col-md-4">
					<button type="button" class="btn btn-secondary">Search</button>
				</div>
			</div>

			<!--- Query to fetch main storage data --->
			<cfquery name="q_main_storage_select_all" datasource="#Request.MTRDSN#">
				SELECT *
				FROM STRG_DATA WITH (NOLOCK)
				ORDER BY iSTRGID;
			</cfquery>

<!--- 			<cfdump  var="#q_main_storage_select_all#"> --->
			<!--- Query to fetch main storage data --->
			
			<!--- Table --->
			<div class="row mt-3">
				<div class="col">
					<table class="table table-striped table-hover">
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
						<tbody>
							<cfoutput query="q_main_storage_select_all">
								<tr>
									<th scope="row">#DTCREATIONDATE#</th>									
									<td>
										<cfif ISTRGTYPEID eq 1>
										<a style="text-decoration: underline;" onclick=JSVCopenWin('#q_main_storage_select_all.VAURLADDRESS#',0,'yes',null,null,true,null)>#VAITEMNAME#</a>
										<cfelseif ISTRGTYPEID eq 2>
											<a href='#request.webroot#index.cfm?fusebox=strg&fuseaction=dsp_updateitem&id=#iSTRGID#&#request.mtoken#'>#VAITEMNAME#</a>
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
	</body>
	</html>
<cfelse>
	<cfthrow TYPE="EX_SECFAILED" ErrorCode="NOLOGIN">
</cfif>
