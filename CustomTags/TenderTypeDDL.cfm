<cfmodule template="#request.apppath#services/CustomTags/SVCADDFILE.cfm" fname="JQUERYUI">
<cfmodule template="#request.apppath#services/CustomTags/SVCADDFILE.cfm" fname="JQUERYUI_CSS">

<CFPARAM NAME="Attributes.NOFORM" default=0>
<CFPARAM NAME="Attributes.NOEMPTY" default=0>
<CFPARAM NAME="Attributes.MTRNM" default=3><!--- to show motor claim type or NM claim type. bit 1:motor,2:nm --->
<!--- <CFPARAM NAME="Attributes.CLAIMTYPE" default="">
<CFPARAM NAME="Attributes.CLMTYPE" default=""> --->
<cfset orgtype=#session.vars.orgtype#>

<style>
.etblock {
  display: block;
  width: 100%;
  border: none;
  background-color: #4467AE;
  color: white;
  padding: 8px 28px;
  font-size: 16px;
  cursor: pointer;
  text-align: center;
  font-weight:bold;
  margin-bottom:5px;
}
.etblock:hover {
  background-color: #FF8C2E;
  color: white;
  font-weight:bold;
}
.ui-button-icon-only {
        width: 2em;
        box-sizing: border-box;
        text-indent: -9999px;
        white-space: nowrap;
}
</style>
<script>
<!--- function JSFIXED_CT_FN() {
	$('#TENDERTYPECTRL').val( JSFIXED_CT ); 
	$('#TENDERTYPECTRL').hide().before( "&nbsp; <span style='font-size:110%;font-weight:bold'>"+$('#TENDERTYPECTRL option:selected').text()+"</span>" );	
	$('#TENDERTYPECTRL').before(" &nbsp; <input type=button onclick='TenderTypeModal(\""+JSCLMGROUP+"\")' value='"+JSVClang('Change Tender Type',0)+"' class=clsButton>");
	
} --->
<cfoutput>
<!--- function TenderTypeSelect(type)
{
	<cfif Attributes.NOFORM eq 0>
	if(FormVerify(document.getElementById('TENDERTYPE_FORM')))
	{
	</cfif>	
	<!--- need to get back all the other parameters from the URL when changing the claimtype, if came from searchpol screen. --->
	<cfset url_param_str = "">
	<CFMODULE TEMPLATE="#request.apppath#services/CustomTags/SVCFORMATURL.cfm" URL="&#CGI.QUERY_STRING#" exclude_adtl="fuseaction,fusebox,CLMTYPE,FIXED_CT,CLMGROUP">
	<cfif isdefined("result") and result neq ""><cfset url_param_str="#URLDecode(result)#"></cfif>
	var ic=document.getElementById('sleINSCOID');
	<!--- end --->
	<!--- <cfif orgtype IS "I"> --->
	<!--- //document.location.href=request.webroot+"index.cfm?fusebox=MTRinsureretender&fuseaction=dsp_edittenderreg&TENDERTYPE="+$('##TENDERTYPECTRL').val()+"<cfif Attributes.CLMTYPE neq "">&CLMTYPE=#Attributes.CLMTYPE#</cfif>#url_param_str#&"+request.mtoken;		 --->
	document.location.href=request.webroot+"index.cfm?fusebox=MTRinsureretender&fuseaction=dsp_edittenderreg&TENDERTYPE="+$('##TENDERTYPECTRL').val()+              "#url_param_str#&"+request.mtoken;

	
<!--- MTRinsureretender&fuseaction=dsp_edittenderreg
 --->
	
	
	<cfif Attributes.NOFORM eq 0>
	}
	</cfif>
} --->
function gotoCrtTender(type)
{
	<cfif session.vars.orgtype IS "I">
	document.location.href=request.webroot+"index.cfm?fusebox=MTRinsureretender&fuseaction=dsp_edittenderreg&TENDERTYPE="+type+"&"+request.mtoken;
	<cfelseif session.vars.orgtype IS "A">
	var gc=document.getElementById('sleINSCOID');
	document.location.href=request.webroot+"index.cfm?fusebox=MTRadjusteretender&fuseaction=dsp_edittenderreg&TENDERTYPE="+type+"&INSCOID="+gc.value+"&"+request.mtoken;
	</cfif>
}
</cfoutput>
function etInsSel(o,oDIV) {
	oDIV=document.getElementById(oDIV);
	etattr=(o.value>0?(o.options[o.selectedIndex].getAttribute('ETATTR')>0?o.options[o.selectedIndex].getAttribute('ETATTR'):0):null);
	oDIV.style.display=(etattr!=null?'':'none');
	$(oDIV).find("button[ETYPECLS='MTR']").show();
	if(etattr>0&&(etattr&1)==1)
		$(oDIV).find("button[ETYPECLS='NM']").show();
	else
		$(oDIV).find("button[ETYPECLS='NM']").hide();
}
function TenderTypeModal(type)
{
	var wWidth = document.body.clientWidth;
	var wHeight = document.body.clientHeight;
	var dWidth = 500; //wWidth*0.80;
	var dHeight = 350; //wHeight*0.9;	
	
	<cfif Attributes.NOFORM eq 1>
	$( '#TENDERTYPECTRL').html( "" );
	$( '#TENDERTYPECTRL').html( $('#TENDERTYPECTRL').html() );
	document.getElementById('TENDERTYPECTRL').remove(0); //remove empty
	$('#TENDERTYPECTRL').val( JSFIXED_CT ); //reselect
	</cfif>
	
	$('#TENDERTYPECTRLAREA').css("overflow","auto").dialog({
		modal:true,
		maxHeight: dHeight,
		width: dWidth,
		height: dHeight,
		resizable: false,
		position: { my: "center top+"+wHeight/3 , at: "center top", of: window },
		buttons: {
<!--- 					"Proceed": function() {
						<cfif Attributes.NOFORM eq 0>
						if( FormVerify(document.getElementById('TENDERTYPE_FORM')))
						{
						</cfif>
							modal = false;
							$(this).dialog("close");
							$('body').css('overflow','auto');
							TenderTypeSelect(type);
						<cfif Attributes.NOFORM eq 0>}</cfif>
					},
					"Cancel": function() {
						modal = true;
						$(this).dialog("close");
						$('body').css('overflow','auto');
					} --->
				},
		close: function() {
        	$('body').css('overflow','auto');
		}		
	}); 

	$('.ui-widget-overlay').css('opacity', 0.8);
	$('.dlg-no-title, .ui-dialog-titlebar').css('font-size','12px');
	$('body').css('overflow','hidden');
	DoReq('TENDERTYPECTRL');
}
function preloadTenderTypeDDL() {
	oINS=document.getElementById('DIVETTYPEINS');
	oET=document.getElementById('DIVETTYPESEL');
	if(oINS==null) {
		oET.style.display='block';
	}
}
AddOnloadCode("preloadTenderTypeDDL();");
</script>

<cfset listAllowed = "">
<cfloop list=#Request.DS.CLMTYPELIST# index=a><cfif BitAnd(SESSION.VARS.CLMTYPEACCMASK,a) IS a><cfset listAllowed = listAppend(listAllowed,Request.DS.CLMTYPE[a])></cfif></cfloop>
<style>.ui-button-text-only .ui-button-text {font-size:12px;}</style>
<!--- <CFIF bitand(Attributes.MTRNM,1) eq 1> --->
<div id="TENDERTYPECTRLAREA" style="display:none; overflow:auto; height:200px; font-size:12px;" title="<cfoutput>#Server.SVCLang('Create New Tender',7203)#</cfoutput>">
	<cfif ORGTYPE IS "A">
		<cfquery name="q_ins" DATASOURCE="#Request.MTRDSN#">
		select a.vaCONAME, a.vaCOBRNAME, ETTYPEATTR=cast((CASE WHEN ISNULL(b.vaATTR,'')='' THEN 0 ELSE b.vaATTR END) as integer), inscoid=a.icoid
		FROM SEC0005 a with (nolock)
		LEFT JOIN fsys0013 b with (nolock) ON b.vaattrtype='COADMIN' AND b.iattrid=(selecT iattrid from fsys0012 where vaattrtype='COADMIN' and vaFieldLogicName='COATTR-TENDERTYPE')
			AND b.iowndomid=10 and b.iownobjid=a.icoid
		WHERE a.siCOTYPEID=2 AND a.siSTATUS=0 AND (a.siSUBSCRIBE&1)=1 and a.igcoid=a.icoid 
		and a.siETENDER=1 AND a.dtETender<=getdate() and a.ilocid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.vars.locid#">
		ORDER BY a.vaCONAME, case when a.igcoid=a.icoid then 0 else 1 end, a.vaCOBRNAME	
		</cfquery>
		<div id="DIVETTYPEINS" style="display:block">
			<div style="margin-bottom:3px"><cfoutput>#Server.SVClang("Insurer",0)# :</cfoutput></div>
			<select id="sleINSCOID" style="width:100%" onchange="etInsSel(this,'DIVETTYPESEL');">
				<option value=""></option>
				<cfoutput query="q_ins">
					<cfif (attributes.MTRNM GT 0 AND BITAND(attributes.MTRNM,1) IS 1) OR (attributes.MTRNM GT 0 AND BITAND(attributes.MTRNM,2) IS 2 AND BITAND(ETTYPEATTR,1) IS 1)>
						<option ETATTR="#ETTYPEATTR#" value=#inscoid#>#vaCONAME#<!--- <cfif vaCOBRNAME NEQ ""> (#vaCOBRNAME#)</cfif> ---></option>
					</cfif>
				</cfoutput>
			</select>
		</div>
		<br>
	</cfif>
	<br>
	<div id="DIVETTYPESEL" style="display:none"> 
		<cfoutput>#Server.SVClang("Please select a Tender Type",0)# :</cfoutput>	
		<br><br>
		<cfoutput>
		<cfset NMS_ENABLE=1>
		<cfif session.vars.orgtype IS "I">
			<cfset NMS_ENABLE=0>
			<cfset ETTYPEATTR_INS=Val(request.ds.FN.SVCgetExtAttrLogic("COADMIN",0,"COATTR-TENDERTYPE",10,session.vars.gcoid))>
			<cfif ETTYPEATTR_INS GT 0 AND BITAND(ETTYPEATTR_INS,1) IS 1><cfset NMS_ENABLE=1></cfif>
		</cfif>
		<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="281R"><!--- Access Tender Type: Motor --->
		<cfset acs_motor=#canread#>
		<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="282R"><!--- Access Tender Type: Non-motor --->
		<cfset acs_nm=#canread#>
		<cfloop array=#request.ds.ettype.sort("text","asc")# index="idx">
			<cfset insertit=0>
			<cfif attributes.MTRNM GT 0 AND BITAND(attributes.MTRNM,1) IS 1 AND idx NEQ 11 AND acs_motor IS 1><!--- motor --->
				<cfset insertit=1>
			</cfif>
			<cfif attributes.MTRNM GT 0 AND BITAND(attributes.MTRNM,2) IS 2 AND idx IS 11 AND NMS_ENABLE IS 1 AND acs_nm IS 1><!--- non-motor --->
				<cfset insertit=1>
			</cfif>		
			<cfif LISTFINDNOCASE("5,6",idx) GT 0>
				<cfif NOT(session.vars.locid IS 2)>
					<cfset insertit=0>
				<cfelseif idx IS 11 AND NOT(Attributes.MTRNM GT 0 AND BITAND(Attributes.MTRNM,2) IS 2)>
					<cfset insertit=0>
				</cfif>
			</cfif>
			<cfif insertit IS 1>
				<button ETYPECLS="<cfif idx is 11>NM<cfelse>MTR</cfif>" class="etblock" onclick="Javascript:gotoCrtTender(#idx#)">#request.ds.ettype[idx]#</button>
			</cfif>
		</cfloop>
		</cfoutput>
	</div>
</div>
<!--- </cfif> --->