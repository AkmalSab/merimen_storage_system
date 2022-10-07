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
					<button type="button" class="btn btn-primary">Save</button>
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
                            <form>
                                <tr class="table-active">
                                    <th>Item Name</th>
                                    <td><input type="email" class="form-control" id="exampleFormControlInput1" placeholder=""></td>
                                </tr>
                                <tr class="">
                                    <th>Description</th>
                                    <td><input type="email" class="form-control" id="exampleFormControlInput1" placeholder=""></td>
                                </tr>
                                <tr class="">
                                    <th>Storage Type</th>
                                    <td>
                                        <select class="form-select" aria-label="Default select example">
                                            <option value="null" selected>Open this select menu</option>
                                            <cfoutput query="q_storage_type_select_all">                                                    
                                                <option value="#ISTRGTYPEID#">#VASTRGDESCRIPTION#</option>                                                
                                            </cfoutput>
                                        </select>
                                    </td>
                                </tr>
                                <tr class="">
                                    <th>Rating</th>
                                    <td><input type="email" class="form-control" id="exampleFormControlInput1" placeholder=""></td>
                                </tr>
                                <tr class="">
                                    <th>URL</th>
                                    <td><input type="text" class="form-control" id="exampleFormControlInput1" placeholder=""></td>
                                </tr>
								<tr class="">
                                    <th>Document</th>
                                    <td><input type="file" class="form-control" id="exampleFormControlInput1" placeholder=""></td>
                                </tr>
								<tr class="">
                                    <th>Letter</th>
                                    <td><div id="editorjs"></div></td>
                                </tr>
                            </form>
                        </tbody>
                    </table>
				</div>
			</div>
			<!--- Form --->
		</div>

		<!--- Editor.js --->
		<script src="https://cdn.jsdelivr.net/npm/@editorjs/editorjs@latest"></script>
		<script src="https://cdn.jsdelivr.net/npm/@editorjs/list@latest"></script>
		<script src="https://cdn.jsdelivr.net/npm/@editorjs/header@latest"></script>
		<script src="https://cdn.jsdelivr.net/npm/@editorjs/raw"></script>
		<script src="https://cdn.jsdelivr.net/npm/@editorjs/simple-image@latest"></script>
		<script src="https://cdn.jsdelivr.net/npm/@editorjs/image@2.3.0"></script>
		<script src="https://cdn.jsdelivr.net/npm/@editorjs/checklist@latest"></script>
		<script src="https://cdn.jsdelivr.net/npm/@editorjs/embed@latest"></script>
		<script src="https://cdn.jsdelivr.net/npm/@editorjs/quote@latest"></script>


		<script>
			const editor = new EditorJS({ 
				/** 
				 * Id of Element that should contain the Editor 
				 */ 
				holder: 'editorjs', 
				autofocus: true,
				tools: {
					list: {
						class: List,
						inlineToolbar: true,
						config: {
							defaultStyle: 'unordered'
						}
					},
					header: {
						class: Header,
						shortcut: 'CMD+SHIFT+H',
					},
					raw: RawTool,
					image: SimpleImage,
					image: {
						class: ImageTool,
						config: {
							endpoints: {
							byFile: 'http://localhost:8008/uploadFile', // Your backend file uploader endpoint
							byUrl: 'http://localhost:8008/fetchUrl', // Your endpoint that provides uploading by Url
							}
						}
					},
					checklist: {
						class: Checklist,
						inlineToolbar: true,
					},
					embed: {
						class: Embed,
					},
					quote: {
						class: Quote,
						inlineToolbar: true,
						shortcut: 'CMD+SHIFT+O',
						config: {
							quotePlaceholder: 'Enter a quote',
							captionPlaceholder: 'Quote\'s author',
						},
					},
				}
			})
		</script>

		<!--- 	Bootstrap 5 JS --->
		<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>
		
		<!--- CKEditor 4 --->
		<script src="//cdn.ckeditor.com/4.20.0/standard/ckeditor.js"></script>
	</body>
	</html>
<cfelse>
	<cfthrow TYPE="EX_SECFAILED" ErrorCode="NOLOGIN">
</cfif>
