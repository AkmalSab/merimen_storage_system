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
		<!--- Jquery --->
		<script src="https://code.jquery.com/jquery-3.6.1.min.js" integrity="sha256-o88AwQnZB+VDvE9tvIXrMQaPlFFSUTR+nldQm1LuPXQ=" crossorigin="anonymous"></script>
		
	</head>
	<body>
		<div class="container mt-3">

			<!--- Date range --->
			<div class="row mt-3">
				<form id="searchForm" name="searchForm">
					<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCDATERANGE.cfm">
					<div class="row">
						<div class="col-4">
							<label for="UserName" class="form-label">User Name:</label>
							<input type="text" class="form-control" id="UserName" name="UserName" placeholder="">
						</div>
						<div class="col-4">
							<label for="Rating" class="form-label">Rating:</label>
							<input type="text" class="form-control" id="Rating" name="Rating" placeholder="">
						</div>
					</div>
					<input type="button" class="col-12 btn btn-secondary" value="Search" onclick="searchStorage()"/>
				</form>
			</div>
			<!--- Date range --->

			<!--- Query to fetch main storage data --->
			<cfquery name="q_main_storage_report" datasource="#Request.MTRDSN#">
				select
				a.vaCREATOR, 
				a.iSTRGTYPEID as storage_type_id,
				(
					select count(iSTRGID)
					from STRG_DATA 
					where vaSTATUS != 'Verified' and iSTRGTYPEID = a.iSTRGTYPEID and vaCREATOR = a.vaCREATOR
				) as Unverified_counters,
				(
					select count(iSTRGID)
					from STRG_DATA a 
					where vaSTATUS = 'Verified' and iSTRGTYPEID = a.iSTRGTYPEID and vaCREATOR = a.vaCREATOR
				) as Verified_counters,
				(
					select count(iSTRGID)
					from STRG_DATA
					where iCLASSIFIED = 1 and iSTRGTYPEID = a.iSTRGTYPEID and vaCREATOR = a.vaCREATOR
				) as Classified_counters,
				(
					select count(iSTRGID)
					from STRG_DATA
					where vaCREATOR = a.vaCREATOR
				) as Total_counters
				from STRG_DATA a WITH (NOLOCK)
				where 0=0
				group by a.vaCREATOR,  a.iSTRGTYPEID
			</cfquery>
			<!--- Query to fetch main storage data --->
<!--- <cfdump  var="#q_main_storage_report#"> --->
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
							<cfset creator = 0><cfset i = 0>
							<cfoutput query="q_main_storage_report">
								<cfset i += 1>
                                <cfif creator != VACREATOR>
									<cfset creator = VACREATOR>
									<cfset Verified_total = 0>
									<cfset Unverified_total = 0>
									<cfset Classified_total = 0>
									<tr>
										<th colspan="4">#VACREATOR#</th>
									</tr>
								</cfif>
								<tr>
									<cfif STORAGE_TYPE_ID eq 1>
										<td>URL</td>
										<cfelseif STORAGE_TYPE_ID eq 2>
											<td>Documents</td>
											<cfelse>
												<td>Letter</td>
									</cfif>						
									<td>#VERIFIED_COUNTERS#</td><cfset Verified_total += VERIFIED_COUNTERS>
									<td>#UNVERIFIED_COUNTERS#</td><cfset Unverified_total += UNVERIFIED_COUNTERS>
									<td>#CLASSIFIED_COUNTERS#</td><cfset Classified_total += CLASSIFIED_COUNTERS>
								</tr>	
								<cfif creator != q_main_storage_report.UNVERIFIED_COUNTERS[i+1]>
									<tr>
										<th>Total</th>
										<td colspan="3">#TOTAL_COUNTERS#</td>
									</tr>
								</cfif>                                
							</cfoutput>	
                            <tr>
                                <th>Grand Total</th>
                                <td><cfoutput>#Verified_total#</cfoutput></td>
								<td><cfoutput>#Unverified_total#</cfoutput></td>
								<td><cfoutput>#Classified_total#</cfoutput></td>
                            </tr>											
						</tbody>
					</table>
				</div>
			</div>
			<!--- Table --->
		</div>

		<!--- 	Bootstrap 5 JS --->
		<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>

		<script>
			function searchStorage(){
				// AJAX POST Request
				$.post("index.cfm?fusebox=rpt&fuseaction=act_searchreport", //url
				$("#searchForm").serializeArray(), //data
				function(data, status){ //callback
					
				});
			}
		</script>
	</body>
	</html>
<cfelse>
	<cfthrow TYPE="EX_SECFAILED" ErrorCode="NOLOGIN">
</cfif>
