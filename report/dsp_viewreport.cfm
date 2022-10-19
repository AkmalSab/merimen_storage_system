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

			<!--- Date range --->
			<div class="row mt-3">
				<div class="col">
					<form action="test" method="post" name="testform">
						<table>
							<tr>
								<td class=clsValue1>
									<label for="DateFrom" class="form-label">Date From:</label>
									<input class="form-control" MRMOBJ=CALDATE CHKREQUIRED name="GUIdateFrom" id="GUIdate" type=text>
								</td>
								<td class=clsValue1>
									<label for="DateTo" class="form-label">Date To:</label>
									<input class="form-control" MRMOBJ=CALDATE CHKREQUIRED name="GUIdateTo" id="GUIdate" type=text>
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
				select
				a.vaCREATOR, 
				a.iSTRGTYPEID as storage_type_id,
				(
					select count(iSTRGID)
					from STRG_DATA 
					where vaSTATUS = 'Active' and iSTRGTYPEID = a.iSTRGTYPEID and vaCREATOR = a.vaCREATOR
				) as Active_counters,
				(
					select count(iSTRGID)
					from STRG_DATA a 
					where vaSTATUS = 'Verified' and iSTRGTYPEID = a.iSTRGTYPEID and vaCREATOR = a.vaCREATOR
				) as Verified_counters,
				(
					select count(iSTRGID)
					from STRG_DATA
					where vaSTATUS = 'Outdated' and iSTRGTYPEID = a.iSTRGTYPEID and vaCREATOR = a.vaCREATOR
				) as Outdated_counters
				from STRG_DATA a WITH (NOLOCK)
				where 0=0
				group by a.vaCREATOR,  a.iSTRGTYPEID
			</cfquery>
			<!--- Query to fetch main storage data --->
			<cfdump  var="#q_main_storage_select_all#">
			<!--- Query to fetch main storage data --->
			<!--- Table --->
			<div class="row mt-3">
				<div class="col">
					<table class="table table-striped table-hover">
						<thead>
							<tr>
								<th scope="col">Storage Type</th>
								<th scope="col">Count of Verified</th>
								<th scope="col">Count of Not Verified</th>
								<th scope="col">Count of Classified</th>
							</tr>
						</thead>
						<tbody>
							<cfoutput query="q_main_storage_select_all">
                                <!--- <tr>
                                    <th colspan="4">#VACREATOR#</th>
                                </tr> --->
								<tr>
									<cfif ISTRGTYPEID eq 1>
										<th scope="row">URL</th>
										<cfelseif ISTRGTYPEID eq 2>
											<th scope="row">Documents</th>
											<cfelse>
												<th scope="row">Letter</th>
									</cfif>						
									<td>#COUNTERS#</td>
									<td>#COUNTERS#</td>
									<td>#COUNTERS#</td>									
								</tr>	
                                <!--- <tr>
                                    <td>Total</td>
                                    <td colspan="3">total</td>
                                </tr>	 --->
							</cfoutput>	
                            <tr>
                                <td>Grand Total</td>
                                <td colspan="3">100</td>
                            </tr>											
						</tbody>
					</table>
				</div>
			</div>
			<!--- Table --->
		</div>

		<!--- 	Bootstrap 5 JS --->
		<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>
	</body>
	</html>
<cfelse>
	<cfthrow TYPE="EX_SECFAILED" ErrorCode="NOLOGIN">
</cfif>
