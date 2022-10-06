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

<!--- <cfdump  var="#SESSION#"> --->
<cfif IsDefined("SESSION.VARS.ORGTYPE")>
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
			<div class="row">
				<div class="col">
					<button type="button" class="btn btn-primary">Create New Item</button>
					<button type="button" class="btn btn-primary">View Report</button>
				</div>
			</div>
			<div class="row mt-3">
				<div class="col">
					<button type="button" class="btn btn-warning">Storage Type</button>
					<button type="button" class="btn btn-warning">Item Name</button>
					<button type="button" class="btn btn-warning">Description</button>
				</div>
			</div>
			<div class="row mt-1">
				<div class="col">
					<button type="button" class="btn btn-warning">Created Date From</button>
					<button type="button" class="btn btn-warning">Created Date To</button>
				</div>
			</div>
			<div class="row mt-3">
				<div class="col col-md-4">
					<input type="text" class="form-control"/>
				</div>
				<div class="col col-md-4">
					<button type="button" class="btn btn-secondary">Search</button>
				</div>
			</div>
			<div class="row mt-3">
				<div class="col">
					<table class="table table-striped table-hover">
						<thead>
							<tr>
							<th scope="col">Created On</th>
							<th scope="col">Item Name</th>
							<th scope="col">Storage Type</th>
							<th scope="col">Description</th>
							</tr>
						</thead>
						<tbody>
							<tr>
								<th scope="row">05-10-2022 17:08:00</th>
								<td>Training.pdf</td>
								<td>Documents</td>
								<td>Training files for new comers</td>
							</tr>
							<tr>
								<th scope="row">05-10-2022 17:08:00</th>
								<td>Training.pdf</td>
								<td>Documents</td>
								<td>Training files for new comers</td>
							</tr>
							<tr>
								<th scope="row">05-10-2022 17:08:00</th>
								<td>Training.pdf</td>
								<td>Documents</td>
								<td>Training files for new comers</td>
							</tr>
							<tr>
								<th scope="row">05-10-2022 17:08:00</th>
								<td>Training.pdf</td>
								<td>Documents</td>
								<td>Training files for new comers</td>
							</tr>
							<tr>
								<th scope="row">05-10-2022 17:08:00</th>
								<td>Training.pdf</td>
								<td>Documents</td>
								<td>Training files for new comers</td>
							</tr>
							<tr>
								<th scope="row">05-10-2022 17:08:00</th>
								<td>Training.pdf</td>
								<td>Documents</td>
								<td>Training files for new comers</td>
							</tr>
							<tr>
								<th scope="row">05-10-2022 17:08:00</th>
								<td>Training.pdf</td>
								<td>Documents</td>
								<td>Training files for new comers</td>
							</tr>
							<tr>
								<th scope="row">05-10-2022 17:08:00</th>
								<td>Training.pdf</td>
								<td>Documents</td>
								<td>Training files for new comers</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>

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
