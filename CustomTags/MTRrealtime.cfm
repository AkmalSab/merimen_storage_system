<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCDISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">
<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\MTRHEADER.cfm">
	
<CFPARAM NAME=Attributes.TPINS DEFAULT=0>
<CFPARAM NAME=Attributes.REASON DEFAULT=0>
<CFPARAM NAME=Attributes.StatCode DEFAULT=0>
<CFPARAM NAME=Attributes.TRIGGER DEFAULT="">
<CFPARAM NAME=Attributes.CLMID DEFAULT=0>
<CFPARAM NAME=Attributes.GCOID DEFAULT=0>
<CFPARAM NAME=Attributes.REQID DEFAULT=0>

<CFSET APPATH = request.apppath>
<CFSET INSGCOID="">

<CFQUERY name=q_trx datasource=#request.MTRDSN#>
	    SELECT inscoid=i.icoid,CurrentDate=GETDATE() ,I.dtAUTH,I.iEFFFLAG
	    	FROM TRX0008 I WITH (NOLOCK)
	    	INNER JOIN TRX0001 R WITH (NOLOCK) ON i.iCASEID=r.ICASEID
	    where i.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.CASEID#"> AND i.siTPINS=0
</CFQUERY>

<CFIF Attributes.GCOID EQ 1512247 AND BitAnd(q_trx.iEFFFLAG,32) EQ 0>
	<CFLOCATION URL="#request.webroot#index.cfm?fusebox=MTRroot&fuseaction=dsp_clmheader&caseid=#Attributes.caseid#&tpins=#Attributes.tpins#&#Request.MToken#" ADDTOKEN="no">
</CFIF>

<CFIF Attributes.GCOID EQ 1512247 AND (Attributes.TRIGGER EQ "CLMPAYREQ" OR Attributes.TRIGGER EQ "CLMPAYCAN")>
	<CFSET INSGCOID=Attributes.GCOID>
<CFELSE>
	<CFSET INSGCOID=#request.ds.co[q_trx.inscoid].gcoid#>
</CFIF>

<CFSET Current=request.ds.FN.SVCdtDBtoLOC(q_trx.CurrentDate,-1,"STD","HH:MM")>
<CFSET AuthDate=request.ds.FN.SVCdtDBtoLOC(q_trx.dtAUTH,-1,"STD","HH:MM")>

<CFIF Current IS AuthDate>
	<CFSET AuthFlag=1>
<CFELSE>
	<CFSET AuthFlag=0>
</CFIF>	
<!--- <cfdump var = #attributes#><cfabort> --->
<CFIF INSGCOID IS 1510007 AND attributes.TRIGGER IS NOT "">
	<CFOUTPUT>
		<script>
		var iCASEID = #attributes.CASEID#;
		var iAuthFlag = #AuthFlag#;
		var iReason = #attributes.REASON#;
		var mToken = '#Request.MToken#';
		var vaStatCode = "#attributes.StatCode#";
		var vaTRIGGER = "#attributes.TRIGGER#";
		var CLMID = "#attributes.CLMID#";

		
		window.onbeforeunload = function(event) {
		event.returnValue = "";
		};
	
		$("body").css("cursor", "wait");
		JSVCPageDisable(document,true);
		SVCnote("<p align=center>" +JSVClang("Contacting MIC, please wait for a moment",39530) +"... <br><img class = 'loader' style=vertical-align:middle src='"+request.approot+"services/images/loading-anim.gif'><br><button class='btnOK'>OK</button></p></p>",'popup_note');

		$(document).ready(function(){
			$(".loader").hide();
			$(".btnOK").click(function(){
				$(".btnOK").hide();
				$(".loader").show();
			});
		});

		$.ajax({
		  type: "POST",
		  url: "#Request.webroot#index.cfm?fusebox=SVCInt_redirect&fuseaction=dsp_sendWebSVC_CLM_Realtime_Redirect&"+mToken,
		  dataType: "json",
		  data: { iCASEID:iCASEID,iAuthFlag:iAuthFlag,iReason:iReason,vaStatCode:vaStatCode,vaTRIGGER:vaTRIGGER,CLMID:CLMID},
		  timeout:45000,
		  error: function(request, status, error) {
				window.onbeforeunload = null
				$.ajax({
						type: "POST",
						url: "#Request.webroot#index.cfm?fusebox=SVCInt_redirect&fuseaction=dsp_ErrorHandle_MIC&"+mToken,
						data: { iCASEID:iCASEID,iAuthFlag:iAuthFlag,iReason:iReason,vaStatCode:vaStatCode,vaTRIGGER:vaTRIGGER,CLMID:CLMID},
						timeout:45000
					})
				alert(JSVClang('Integration Fail, Please check and try again',43012));			
                location.href="#request.webroot#index.cfm?fusebox=MTRinsurer&fuseaction=dsp_clmheader&caseid=#Attributes.CASEID#&tpins=#Attributes.TPINS#&" +mToken ;     
            }
		})
		.done(
			function(msg)
			{	if(msg.STATUS != true)
				{	
					$.ajax({
						type: "POST",
						url: "#Request.webroot#index.cfm?fusebox=SVCInt_redirect&fuseaction=dsp_ErrorHandle_MIC&"+mToken,
						data: { iCASEID:iCASEID,iAuthFlag:iAuthFlag,iReason:iReason,vaStatCode:vaStatCode,vaTRIGGER:vaTRIGGER,CLMID:CLMID},
						timeout:45000
					})
					alert(JSVClang('Integration Fail, Please check and try again',43012));	
				}
				//console.log (mToken);
				window.onbeforeunload = null
				location.href="#request.webroot#index.cfm?fusebox=MTRinsurer&fuseaction=dsp_clmheader&caseid=#Attributes.CASEID#&tpins=#Attributes.TPINS#&" +mToken ;
			}
			)
	</CFOUTPUT>
	</script>
<CFELSEIF INSGCOID IS 1512247 AND attributes.TRIGGER IS NOT "">
	<CFOUTPUT>
		<script>
		var iCASEID = #attributes.CASEID#;
		var iAuthFlag = #AuthFlag#;
		var iReason = #attributes.REASON#;
		var mToken = '#Request.MToken#';
		var vaStatCode = "#attributes.StatCode#";
		var vaTRIGGER = "#attributes.TRIGGER#";
		var CLMID = "#attributes.CLMID#";
		var REQID="#attributes.REQID#";
		window.onbeforeunload = function(event) {
		event.returnValue = "";
		};
	
		$("body").css("cursor", "wait");
		JSVCPageDisable(document,true);
		SVCnote("<p align=center>" +JSVClang("Contacting Bao Viet, please wait for a moment",0) +"... <br><img style=vertical-align:middle src='"+request.approot+"services/images/loading-anim.gif'></p></p>",'popup_note');z

		/**$(document).ready(function(){
			$(".loader").hide();
			$(".btnOK").click(function(){
				$(".btnOK").hide();
				$(".loader").show();
			});
		});**/

		$.ajax({
		  type: "POST",
		  url: "#Request.webroot#index.cfm?fusebox=SVCInt_redirect&fuseaction=dsp_sendWebSVC_CLM_Realtime_Redirect_BV&"+mToken,
		  data: { iCASEID:iCASEID,iAuthFlag:iAuthFlag,iReason:iReason,vaStatCode:vaStatCode,vaTRIGGER:vaTRIGGER,CLMID:CLMID,REQID:REQID},
		  timeout:90000,
		  error: function(request, status, error) {
            	window.onbeforeunload = null
                alert(JSVClang('Integration Fail, Please check and try again',43012));
                location.href="#request.webroot#index.cfm?fusebox=MTRinsurer&fuseaction=dsp_clmheader&caseid=#Attributes.CASEID#&tpins=#Attributes.TPINS#&" +mToken ;     
            }
		})
		.done(
			function(msg)
			{
				//console.log (mToken);
				window.onbeforeunload = null
				location.href="#request.webroot#index.cfm?fusebox=MTRinsurer&fuseaction=dsp_clmheader&caseid=#Attributes.CASEID#&tpins=#Attributes.TPINS#&" +mToken ;
			}
		)
	</CFOUTPUT>
	</script>
</CFIF>

 <cfabort> <!---To abort the cfreturn in insurer/index.cfm --->
