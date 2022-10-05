<cfmodule template="#request.apppath#services/CustomTags/SVCADDFILE.cfm" fname="JQUERYUI">
<cfmodule template="#request.apppath#services/CustomTags/SVCADDFILE.cfm" fname="JQUERYUI_CSS">

<CFPARAM NAME="Attributes.NOFORM" default=0>
<CFPARAM NAME="Attributes.NOEMPTY" default=0>
<CFPARAM NAME="Attributes.MTRNM" default=3><!--- bit 1:motor,2:nm --->
<CFPARAM NAME="Attributes.CLAIMTYPE" default="">
<CFPARAM NAME="Attributes.CLMTYPE" default="">

<script>
function JSFIXED_CT_FN() {
	$('#_CLMTYPECTRL').val( JSFIXED_CT ); 
	$('#_CLMTYPECTRL').hide().before( "&nbsp; <span style='font-size:110%;font-weight:bold'>"+$('#_CLMTYPECTRL option:selected').text()+"</span>" );	
	$('#_CLMTYPECTRL').before(" &nbsp; <input type=button onclick='ClaimTypeModal(\""+JSCLMGROUP+"\")' value='"+JSVClang('Change Claim Type',31857)+"' class=clsButton>");
	
}
<cfoutput>
function ClaimTypeSelect(type)
{
	<cfif Attributes.NOFORM eq 0>
	if(FormVerify(document.getElementById(type+'_CLAIMTYPE_FORM')))
	{
	</cfif>	
	<!--- need to get back all the other parameters from the URL when changing the claimtype, if came from searchpol screen. --->
	<cfset url_param_str = "">
	<CFMODULE TEMPLATE="#request.apppath#services/CustomTags/SVCFORMATURL.cfm" URL="&#CGI.QUERY_STRING#" exclude_adtl="fuseaction,fusebox,CLMTYPE,FIXED_CT,CLMGROUP">
	<cfif isdefined("result") and result neq ""><cfset url_param_str="#URLDecode(result)#"></cfif>
	<!--- end --->
	<!--- 42729 --->
	var tempCLMTYPECTRL = $('##'+type+'_CLMTYPECTRL').val();
	var vstand = "";
	if (tempCLMTYPECTRL == 'SC'){
		var vstand = "&standalone=1";
	}
	document.location.href=request.webroot+"index.cfm?fusebox=MTRclaim&fuseaction=dsp_clmreg&CLMGROUP="+type+"&FIXED_CT="+tempCLMTYPECTRL+vstand+"<cfif Attributes.CLMTYPE neq "">&CLMTYPE=#Attributes.CLMTYPE#</cfif>#url_param_str#&"+request.mtoken;		
	<cfif Attributes.NOFORM eq 0>
	}
	</cfif>
}
</cfoutput>
function ClaimTypeModal(type)
{
	var wWidth = document.body.clientWidth;
	var wHeight = document.body.clientHeight;
	var dWidth = 300; //wWidth*0.80;
	var dHeight = 150; //wHeight*0.9;	
	
	<cfif Attributes.NOFORM eq 1>
	$( '#'+type+'_CLMTYPECTRL').html( "" );
	$( '#'+type+'_CLMTYPECTRL').html( $('#_CLMTYPECTRL').html() );
	document.getElementById(type+'_CLMTYPECTRL').remove(0); //remove empty
	$('#'+type+'_CLMTYPECTRL').val( JSFIXED_CT ); //reselect
	</cfif>
	
	$('#'+type+'_CLAIMTYPE').css("overflow","auto").dialog({
		modal:true,
		maxHeight: dHeight,
		width: dWidth,
		height: "auto",
		width: "auto",
		resizable: false,
		position: { my: "center top+"+wHeight/3 , at: "center top", of: window },
		buttons: {
					"Proceed": function() {
						<cfif Attributes.NOFORM eq 0>
						if( FormVerify(document.getElementById(type+'_CLAIMTYPE_FORM')))
						{
						</cfif>
							modal = false;
							$(this).dialog("close");
							$('body').css('overflow','auto');
							ClaimTypeSelect(type);
						<cfif Attributes.NOFORM eq 0>}</cfif>
					},
					"Cancel": function() {
						modal = true;
						$(this).dialog("close");
						$('body').css('overflow','auto');
					}
				},
		close: function() {
        	$('body').css('overflow','auto');
		}		
	}); 

	$('.ui-widget-overlay').css('opacity', 0.8);
	$('.dlg-no-title, .ui-dialog-titlebar').css('font-size','12px');
	$('body').css('overflow','hidden');
	DoReq(type+'_CLMTYPECTRL');
}
</script>

<cfset listAllowed = "">
<cfloop list=#Request.DS.CLMTYPELIST# index=a><cfif BitAnd(SESSION.VARS.CLMTYPEACCMASK,a) IS a><cfset listAllowed = listAppend(listAllowed,Request.DS.CLMTYPE[a])></cfif></cfloop>
<style>.ui-button-text-only .ui-button-text {font-size:12px;}</style>
<CFIF bitand(Attributes.MTRNM,1) eq 1>
<div id="MTR_CLAIMTYPE" style="display:none; overflow:auto; height:200px; font-size:12px;" title="<cfoutput>#Server.SVCLang('Create MOTOR Claim',7203)#</cfoutput>">
	<cfoutput>#Server.SVClang("Please select a Claim Type",31858)# :</cfoutput>
	<br>
	<cfif Attributes.NOFORM eq 0><form id="MTR_CLAIMTYPE_FORM"></cfif>
	<select CHKNAME="Claim Type" CHKREQUIRED name="MTR_ddlbCLAIMTYPE" id="MTR_CLMTYPECTRL" onchange="DoReq(this);">
		<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\ClaimType.cfm" CLMTYPE_SEL_ALL="1" CLMTYPEALLOW="#listAllowed#" CURGCOID="#session.vars.gcoid#" DISP="0" LOCID="#SESSION.VARS.LOCID#" NOEMPTY=#Attributes.NOEMPTY# CLAIMTYPE=#Attributes.CLAIMTYPE# CLMTYPE=#Attributes.CLMTYPE#>
	</select>
	<cfif Attributes.NOFORM eq 0></form></cfif>
</div>
</cfif>
<CFIF bitand(Attributes.MTRNM,2) eq 2>
<div id="NM_CLAIMTYPE" style="display:none; overflow:auto; height:200px; font-size:12px;" title="<cfoutput>#Server.SVCLang('Create NON-MOTOR Claim',4090)#</cfoutput>">
	<cfoutput>#Server.SVClang("Please select a Claim Type",31858)# :</cfoutput>
	<br>
	<cfif Attributes.NOFORM eq 0><form id="NM_CLAIMTYPE_FORM"></cfif>
	<select CHKNAME="Claim Type" CHKREQUIRED name="NM_ddlbCLAIMTYPE" id="NM_CLMTYPECTRL" onchange="DoReq(this);">
	<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\ClaimType.cfm" CLMTYPE_SEL_ALL="1" CLMTYPEALLOW="#listAllowed#" CURGCOID="#session.vars.gcoid#" DISP="0" LOCID="#SESSION.VARS.LOCID#" CLMGROUP=NM NOEMPTY=#Attributes.NOEMPTY# CLAIMTYPE=#Attributes.CLAIMTYPE# CLMTYPE=#Attributes.CLMTYPE#>
	</select>
	<cfif Attributes.NOFORM eq 0></form></cfif>
</div>
</cfif>