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

	<cfset newurlback = urlencodedformat('#request.webroot#index.cfm?fusebox=sec&fuseaction=dsp_grouplist&#request.mtoken#')>
	
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
	<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCADDFILE.cfm" FNAME="SVCSELECTOR">
	<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCADDFILE.cfm" FNAME="SARISSA">


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
							<a type="button" class="btn btn-primary" href="#request.webroot#index.cfm?fusebox=MTRroot&fuseaction=dsp_home&#request.mtoken#">Return</a>
						</cfif>
					</cfoutput>					
				</div>
			</div>
			<!--- Tabs --->

			<h1 class="text-center">User Groups</h1>		
			
			<!--- Table --->
			<div class="row mt-3">
				<div class="col">
					<table id="main_storage" class="table table-striped table-hover">
						<thead>
							<tr>
								<th scope="col">Group Name</th>
								<th scope="col">Description</th>
								<th scope="col">Created On</th>
								<th scope="col">Permissions</th>
								<th scope="col">Action</th>
							</tr>
						</thead>
						<tbody id="tbodies">									
							<tr>
								<td>1</td>
								<td>1</td>
								<td>1</td>
								<td>1</td>
								<td>1</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
			<!--- Table --->

			<!--- New group creation --->

			<div class="row mt-3">
				<div class="col">
					<h3 class="card text-primary">New Group</h3>
					<cfoutput>
						<form name="createGroup" method="post" action="#request.webroot#index.cfm?fusebox=sec&fuseaction=act_creategroup&iDomainId=11&iObjId=1&urlback=#newurlback#&#request.mtoken#">
					</cfoutput>
						<table class="col-12">
							<tr>
								<td>Group Name</td>
								<td><input type="text" class="form-control" id="grpname" name="grpname" maxlength=30 size=30 CHKREFORMAT="^[a-z0-9@\-]+$" CHKRESAMPLE="a-z,0-9,@,-" onblur="DoReq(this)" CHKREQUIRED></td>
							</tr>
							<tr>
								<td>Description</td>
								<td><input type="text" class="form-control" id="DESC" name="DESC" maxlength=30 size=30 onblur="DoReq(this)" CHKREQUIRED></td>
							</tr>
							<tr>
								<td>Leaders to be added</td>
								<td>
									<input name=leader_name id=leader_name type=Text maxlength=10000 size=50 onChange="Retoken(this,null,null)">
									<input type=button class=clsButton <cfif not Request.DS.FN.SVCGetResp()>style=width:15%</cfif> value="Search" onclick="StartLeaderSearch()">
									<input type=text value="" name=leader_id id=leader_id>
								</td>
							</tr>
							<tr>
								<td>Members to be added</td>
								<td>
									<input name=member_name id=member_name type=Text maxlength=10000 size=50 onChange="Retoken(this,null,null)">
									<input type=button class=clsButton <cfif not Request.DS.FN.SVCGetResp()>style=width:15%</cfif> value="Search" onclick="StartMemberSearch()">
									<input type=text value="" name=member_id id=member_id>
								</td>
							</tr>
							<tr>
								<td></td>
								<td>
									<input type=button value="Create" onclick="SubmitForm(createGroup)">
								</td>
							</tr>
						</table>
					</form>
				</div>
			</div>				
			<!--- New group creation --->


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

		<cfset user_url="#request.webroot#index.cfm?fusebox=sec&fuseaction=xml_SVCGetAllUser">

		<cfoutput>
			<script>
				var LeaderSearch=new SVCPopSelector("LeaderSearch","#user_url#","POPUP","vaUSID","iUSID",1,1,0,"leader_name","leader_id");
				var MemberSearch=new SVCPopSelector("MemberSearch","#user_url#","POPUP","vaUSID","iUSID",1,1,0,"member_name","member_id");

					function StartLeaderSearch() 
					{
						LeaderSearch.StartSearch('',"&G=1");
					}
					function StartMemberSearch()
					{
						MemberSearch.StartSearch('',"&G=1");
					}
					function SubmitForm(frm) 
					{
						if(FormVerify(frm)) {
							FormSubmit(frm);
						}
					}
			</script>
		</cfoutput>
	</body>
	</html>
<cfelse>
	<cfthrow TYPE="EX_SECFAILED" ErrorCode="NOLOGIN">
</cfif>
