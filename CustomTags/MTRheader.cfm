<cfsilent>
	<cfparam NAME=REQUEST.HEADERSHOWN DEFAULT=0>
	<cfif REQUEST.HEADERSHOWN IS 1>
		<cfset CALLER.RSVSHOWFOOTER=0><cfexit METHOD=EXITTEMPLATE>
	</cfif>
	<cfset REQUEST.HEADERSHOWN=1>
	<cfset CALLER.RSVSHOWFOOTER=1>
	<cfset DOSEARCHBOX=0>
	<cfparam name=Attributes.Title default=#Application.APPFULLNAME#>
	<cfparam name=Attributes.IsStandards default="0">
	<cfparam name=APPLOCID default=#Application.APPLOCID#>
<cfif IsDefined("SESSION.VARS.ORGTYPE")>
		<CFSET ORGTYPE=SESSION.VARS.ORGTYPE>
	<!---cfif APPLOCID IS 7>
	<cfif NOT(StructKeyExists(SESSION.VARS,"LGID") AND SESSION.VARS.LGID GTE 0)><!--- If user preferred language not set, then set default language based on locale --->
	<cfset Server.SVClangSet(0,6)>
	</cfif>
</cfif--->
<cfelse>
	<CFSET ORGTYPE="">
	<!---cfif APPLOCID IS 7>
	<cfset Server.SVClangSet(0,6)>
</cfif--->
</cfif>
<cfset flag_thaigagent=0>
<cfif isDefined("session.vars.gcoid")>
	<CFQUERY NAME=q_pnl DATASOURCE=#Request.MTRDSN#>
	SELECT pnl.siPNLTYPE,co.iSUBCOTYPEFLAG,pnl.iCOID
		FROM TRX0030 pnl WITH (NOLOCK)
		JOIN SEC0005 co WITH (NOLOCK) ON co.iCOID=pnl.iPNLCOID
		WHERE pnl.siPNLTYPE=6
		AND PNL.iPNLCOID=<cfqueryparam value="#session.vars.gcoid#" cfsqltype="CF_SQL_INTEGER">
		AND co.iSUBCOTYPEFLAG=4
		AND pnl.iCOID=1100002
	</CFQUERY>
	<cfif q_pnl.recordcount GT 0><cfset flag_thaigagent=1></cfif>
</cfif>

<cfif StructKeyExists(URL,"nolayout") AND URL.nolayout IS NOT 0>
	<CFSET URL.NOLAYOUT=reReplace(URL.NOLAYOUT, "[^0-9]", "", "all")> <!--- Remove anything that is not 0-9 --->
	<cfif URL.NOLAYOUT IS NOT 0>
		<cfset request.nolayout=1>
		<CFSET nolayout=1>
	<cfelse>
		<CFSET nolayout=0>
	</cfif>
<cfelseif StructKeyExists(Attributes,"nolayout")>
	<CFSET Attributes.NOLAYOUT=reReplace(Attributes.NOLAYOUT, "[^0-9]", "", "all")> <!--- Remove anything that is not 0-9 --->
	<cfif Attributes.NOLAYOUT IS NOT 0>
		<cfset request.nolayout=1>
		<CFSET nolayout=1>
	<cfelse>
		<CFSET nolayout=0>
	</cfif>
<cfelse>
	<CFSET nolayout=0>
</cfif>
<cfif StructKeyExists(URL,"NOSEARCHBOX") AND URL.NOSEARCHBOX IS NOT 0>
	<CFSET URL.NOSEARCHBOX=reReplace(URL.NOSEARCHBOX, "[^0-9]", "", "all")> <!--- Remove anything that is not 0-9 --->
	<cfif URL.NOSEARCHBOX IS NOT 0>
		<cfset request.NOSEARCHBOX=1>
		<CFSET NOSEARCHBOX=1>
	<cfelse>
		<CFSET NOSEARCHBOX=0>
	</cfif>
<cfelseif StructKeyExists(Attributes,"NOSEARCHBOX")>
	<CFSET Attributes.NOSEARCHBOX=reReplace(Attributes.NOSEARCHBOX, "[^0-9]", "", "all")> <!--- Remove anything that is not 0-9 --->
	<cfif Attributes.NOSEARCHBOX IS NOT 0>
		<cfset request.NOSEARCHBOX=1>
		<CFSET NOSEARCHBOX=1>
	<cfelse>
		<CFSET NOSEARCHBOX=0>
	</cfif>
<cfelse>
	<CFSET NOSEARCHBOX=0>
</cfif>


<cfset sysdate=now()>
<cfif IsDefined("SESSION.VARS.LOCID")>
	<cfset LOCALE=Request.DS.LOCALES[SESSION.VARS.LOCID]>
	<cfset TZ=LOCALE.TIMEZONE>
	<cfset SHIFT=TZ-APPLICATION.SERVERTIMEZONE>
	<cfif SHIFT IS NOT 0>
		<cfset sysdate=DateAdd("h",SHIFT,sysdate)>
	</cfif>
</cfif>
<cfif ORGTYPE IS NOT "">
	<cfset GCOID=SESSION.VARS.GCOID>
<cfelse>
	<cfset GCOID=0>
</cfif>
<!---<cfset getPageContext().getResponse().reset() /><!---#38708 - Add Cache-control: no-store to response header--->
<cfheader name="Cache-Control"  value="no-store">
<cfheader name="Pragma" value="no-cache">--->
<cfset getPageContext().getResponse().setHeader("Cache-Control","no-cache,no-store")>
</cfsilent><!---DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"--->
<CFOUTPUT>
<CFIF Attributes.isStandards eq 0><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">
<html><head>
<meta http-equiv="X-UA-Compatible" content="IE=7"></CFIF>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8">
<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCADDFILE.cfm" FNAME="JQUERY">
<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCADDFILE.cfm" FNAME="JQUERYUI">
<cfmodule template="#request.apppath#services/CustomTags/SVCADDFILE.cfm" fname="JQUERYUI_CSS">
<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCMobileHeader.cfm">
<title>#Attributes.Title#</title>
<!---link rel="meta" href="http://www.merimen.com.my/labels.xml" type="application/rdf+xml" title="ICRA labels" />
<meta http-equiv="pics-label" content='(pics-1.1
"http://www.icra.org/ratingsv02.html" l
gen true for "http://www.merimen.com.my" r (cz 1 lz 1 nz 1 oz 1 vz 1)
"http://www.rsac.org/ratingsv01.html" l
gen true for "http://www.merimen.com.my" r (n 0 s 0 v 0 l 0))'/--->
<!---cfheader NAME="Content-Type" VALUE="text/html;charset=utf-8"--->
<CFIF APPLOCID IS NOT 5>
	<link rel="icon" type="image/x-icon" href="#request.approot#claims/merimen-icon.ico" />
	<link rel="shortcut icon" href="#request.approot#claims/merimen-icon.ico" type="image/x-icon" />
</CFIF>

<!---meta http-equiv="X-UA-Compatible" content="IE=EmulateIE9"--->
<!---meta http-equiv="X-UA-Compatible" content="IE=5"--->
<cfif Not StructKeyExists(Attributes,"NoCase")>
	<script>
		<!---CFIF StructKeyExists(CALLER,"CASEID") AND CALLER.CASEID GT 0>var jscaseid=#CALLER.CASEID#;</CFIF--->
		var sysdt=new Date(#DatePart("yyyy",sysdate)#,#DatePart("m",sysdate)#-1,#DatePart("d",sysdate)#,#DatePart("h",sysdate)#,#DatePart("n",sysdate)#,#DatePart("s",sysdate)#);
		<cfif ORGTYPE IS NOT "">var jSVCsymbol=#serializeJSON(LOCALE.SYMBOLS)#;</cfif>
	</script>
</cfif>
<cfif not structKeyExists(request,"mobile")>
	<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCADDFILE.cfm" FNAME="SVCCSS">
</cfif>
<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCADDFILE.cfm" FNAME="SVCTAB">
<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCADDFILE.cfm" FNAME="SVCMAIN">
<cfif structKeyExists(Request,"inSession") and Request.inSession>
	<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCADDFILE.cfm" FNAME="HTML2CANVAS">
	<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCADDFILE.cfm" FNAME="SVCFBSCREENSHOT">
</cfif>
<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCADDFILE.cfm" FNAME="SVCAPPVARS">
<cfif NOT IsDefined("Request.NOTOOLBAR")>
	<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\ADDFILE.cfm" FNAME="MTRAPPVARS">
	<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCADDFILE.cfm" FNAME="SVCTOOLBAR">
</cfif>
<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\ADDFILE.cfm" FNAME="MERI">
</head>
<!--- <cfif structKeyExists(request,'mobile') and request.mobile neq 0 and (orgtype is "P" OR orgtype is "G" OR orgtype is "GR" or orgtype IS "L" OR orgtype IS "EA" or orgtype eq "A")>
<CFMODULE TEMPLATE="#Request.LOGPATH#CustomTags\MTRHEADER_mob.cfm">
<cfelse> --->
<body class="clsBody <cfif structKeyExists(request,'mobile') and request.mobile eq 0> unresponsive</cfif>" <cfif APPLOCID IS 17>style="font-size:80%;font-family:Meiryo,Verdana"</cfif> <CFIF Right(Application.ApplicationName,6) IS "_train"> background=#request.webroot#common/training<cfif APPLOCID IS 5>@mbz</cfif>.jpg</CFIF>>
<div class=persistUserData ID=MRMUSERDATA></div><cfif APPLOCID IS 5><div class=clsDocBody></cfif>
<cfif ORGTYPE IS NOT "">
	<cfset LOCID=SESSION.VARS.LOCID>
	<script>JSVCSetLocale(#LOCID#,#Request.DS.FN.SVCSerializeJSON(Request.DS.FN.SVCGetNumFormat(LOCID,LOCALE.CURRENCYID))#,"#LOCALE.DTFORMAT#","#LOCALE.TMFORMAT#","#LOCALE.TIMEZONE#");</script>
</cfif>
<cfif nolayout IS 0 AND ORGTYPE IS NOT "">
	<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="57R">
	<cfset Can_AccessClaim=CanRead>
	<cfif ORGTYPE IS "M">
		<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\ADDFILE.cfm" FNAME="MTRmenumrc">
	<cfelseif ORGTYPE IS "I" AND Can_AccessClaim IS 1>
		<!--- Customization #13341 - [MY] RHB NM - Screen Enhancement (custom upload table)--->
		<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCchkgrp.cfm" GRPLIST="601W">
		<script>var jscoid = <cfoutput>"#session.vars.gcoid#";</cfoutput> var jscanwrite = <cfoutput>"#CANWRITE#";</cfoutput></script>
		<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\ADDFILE.cfm" FNAME="MTRmenuins">
		<CFIF NOSEARCHBOX NEQ 1><CFSET DOSEARCHBOX=1></CFIF>
	<cfelseif ORGTYPE IS "D">
		<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\ADDFILE.cfm" FNAME="MTRmenudev">
	<CFELSEIF ORGTYPE IS "P" AND GCOID IS 2>
		<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\ADDFILE.cfm" FNAME="MTRmenupiam">
	<CFELSEIF ORGTYPE IS "RG">
		<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\ADDFILE.cfm" FNAME="MTRmenurg">
	<cfelse>
		<script>
			var jssubcotypeid = #SESSION.VARS.SUBCOTYPEID#;
			var jsCOTYPEID = #SESSION.VARS.COTYPEID#;
			var jsPnlCOiD = <cfif Q_pnl.recordcount GT 0 AND APPLOCID IS 11 AND ORGTYPE IS "G">#Q_pnl.iCOID#;<CFELSE>0;</cfif>
			var jscoid = <cfoutput>"#session.vars.gcoid#";</cfoutput>
		</script> <!--- #31736 --->

		<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\ADDFILE.cfm" FNAME="MTRmenugen">
		<CFIF ORGTYPE IS "R" OR ORGTYPE IS "A" OR ORGTYPE IS "P" OR ORGTYPE IS "S" OR ORGTYPE IS "G" OR ORGTYPE IS "GR" OR ORGTYPE IS "L" OR ORGTYPE IS "EA">
			<CFIF NOSEARCHBOX NEQ 1><CFSET DOSEARCHBOX=1></CFIF>
		</CFIF>
	</cfif>
	<cfif application.appdevmode eq 1>
		<script>
			var IDX_HLP = -1;
			try{
				for( var i = 0; i < MENU_ITEMS.length; i++)
				{
					if( MENU_ITEMS[i][0] == JSVClang("Help",1090))
					{
						IDX_HLP = i;
					}
				}
				if(IDX_HLP>-1)
					MENU_ITEMS[IDX_HLP].splice(MENU_ITEMS[IDX_HLP].length,0,[<cfif structKeyExists(request,"mobile")>"Classic View"<cfelse>"Responsive View"</cfif>, <cfif structKeyExists(request,"mobile")>document.location.href.replace(/&mobile=2/gi,'')<cfelse>document.location.href + "&mobile=2"</cfif> ]);
			}catch(ex){}
		</script>
	</cfif>
	<script>
        <cfif isDefined("session.sso_uid") and session.sso_uid gt 0>
        var sso_uid = #session.sso_uid#;
        </cfif>
		var menupos = MENU_POS;
		<CFIF flag_thaigagent IS 1>
			menupos = MENU_POS_THAIGAGENT;
		<CFELSEIF structKeyExists(Session,"Vars") and StructKeyExists(SESSION.VARS,"LGID") and session.vars.lgid eq 6>
			menupos = MENU_POS_TH;
		</CFIF>
		new menu (MENU_ITEMS,menupos);<cfif IsDefined("SESSION.VARS.USERID")>MrmGetRecentLink('#SESSION.VARS.USERID#');</cfif>
	</script>
</cfif>
<cfif isDefined("session.sso_uid") and session.sso_uid gt 0 and structKeyExists(request,"mobile") and request.mobile eq 2>
<style>
nav.navbar {
	border: 0;
	border-radius: 0;
}

.navbar-brand img {
  max-width: 100px;
}

@media screen and (min-width: 1280px) {
  .navbar-brand img {
  	max-width: 220px;
  }
}

nav.navbar {
  background-color: ##ff921f;
  color: ##ffffff;
}

.navbar-default .navbar-nav>li>a {
  color: ##ffffff;
}

.navbar-default .navbar-text {
  color: ##ffffff;
}

}
@media screen and (min-width: 768px) {
  .nav.navbar-nav > li {
    border-left: 0;
    border-right: 0;
  }
}

.navbar-nav > li > .dropdown-menu {
	background-color: ##ff921f;
}

</style>
</cfif>
<cfif APPLOCID IS NOT 5>
	<cfif structKeyExists(request,"mobile")>
		<cfif request.mobile eq 1>
		<div id=MRMmaintable class="container-fluid home-panel">
		<cfelse>
		<div id=MRMmaintable class="container-full home-panel">
		</cfif>
	<cfelse>
		<table cellpadding="0" cellspacing="0" border="0" width="100%" height="100%" id=MRMmaintable>
	</cfif>
</cfif>
<cfif nolayout IS 0>
	<cfif APPLOCID IS NOT 5><cfif not (structKeyExists(request,"mobile") and request.mobile eq 2)><tr><td valign="top"></cfif><div class="clsDocBody <CFIF request.ds.fn.SVCGetResp()>row-no-margin</CFIF>"></cfif>
	<CFIF ORGTYPE IS "P" AND GCOID IS 2 AND APPLOCID IS 1>
		<!--- "<td valign=top align='right'><img src='"+request.approot+"services/images/piamcolor.png' BORDER=0 style='margin-right: 30px;'></td>"+ --->
		<!--- 	<cfif ORGTYPE IS NOT ""><div style="height:38px;width:100%;border-bottom:0px solid ##D2F079;background-color:##D2F079">&nbsp;</div><!--- Padding for top menu --->
	</cfif> --->
	<script>
		document.write(
			"<table class=clsNoPrint width=100% cellpadding=0 cellspacing=0 border=0 style='background-color:white;'>"+
			"<tr>"+
			"<td valign=top width=75%><img src='"+request.approot+"services/images/piamfinal2.png' BORDER=0 style='margin-right: 70px; margin-left: 5px; margin-top: 3px;'></td>"+
			"<td valign=top nowrap='nowrap' width=25%>"
			);
		<cfif ORGTYPE IS NOT "">
			displayLoginUserInfo("<div style='color:black;padding:2 5 0 0;' align=left><b>#REQUEST.DS.FN.SVCSanitizeInput(Session.vars.orgname,"JS-NQ")#</b><br>#REQUEST.DS.FN.SVCSanitizeInput(Session.Vars.UserName,"JS-NQ")#<br>#DateFormat(sysdate,"dd mmm yyyy")# #TimeFormat(sysdate,"hh:mm tt")#</div>");
		</cfif>
		drawToolbarComplete();
	</script>
	<style>
		.m0l0iout {
			font-family: Verdana;
			font-size: 8pt;
			font-weight: bold;
			text-decoration: none;
			padding:2px;
			margin: 2px 0 0 8px;
			color: black;
			text-align:center;
		}
	</style>
	<cfif ORGTYPE IS NOT ""><div style="height:25px;width:100%;border-bottom:1px solid black;background-color:white;">&nbsp;</div><!--- Padding for top menu ---></cfif>
<CFELSE>
	<script>
		var logostyle=null;
		var logoname='';
		<CFIF isDefined("SESSION.VARS.ORGTYPE") AND SESSION.VARS.ORGTYPE IS "G" AND isDefined("SESSION.VARS.LOCID") AND SESSION.VARS.LOCID IS 11 AND IsDefined("SESSION.VARS.SUBCOTYPEID") AND SESSION.VARS.SUBCOTYPEID IS 4 AND IsDefined("SESSION.VARS.COTYPEID") AND SESSION.VARS.COTYPEID IS 6 AND q_pnl.iCOID IS 1100002>
			logostyle = "style='margin-top:7px;margin-left:7px'";
		</CFIF>

		<cfif isDefined("session.sso_uid") and session.sso_uid gt 0 and structKeyExists(request,"mobile") and request.mobile eq 2>
			logoname='merimen-logo-white.png';
		<cfelseif APPLOCID IS 2 AND NOT(REQUEST.DS.MTRFN.DisableSGGIA(1))>
			logoname='merimentopleft-gia3.gif';
		<cfelseif GCOID IS 1424 OR GCOID IS 3556>
			logoname='merimentopleft-proton.gif';
		<CFELSEIF structKeyExists(request,"mobile") and request.mobile eq 2>
			logoname='fermionmerimen1_mob.png';
			logostyle="style='height: 25px !important; box-sizing:unset;'";
		<cfelseif isDefined("SESSION.VARS.ORGTYPE") AND SESSION.VARS.ORGTYPE IS "G" AND isDefined("SESSION.VARS.LOCID") AND SESSION.VARS.LOCID IS 11 AND IsDefined("SESSION.VARS.SUBCOTYPEID") AND SESSION.VARS.SUBCOTYPEID IS 4 AND IsDefined("SESSION.VARS.COTYPEID") AND SESSION.VARS.COTYPEID IS 6 AND q_pnl.iCOID IS 1100002>
			logoname='AIG_r_w.png';
		<cfelse>
			logoname='fermionmerimen1_sm.png';
			logostyle="style='height: 33px; padding: 8px 16px 18px 16px; box-sizing:unset;'";
 		</cfif>

		<!--- For DEMO: Replace logo file here, leave blank on param 1 for default merimen logo --->
		<cfif APPLOCID IS NOT 5>drawToolbar(logoname,null,logostyle);</cfif>
		<cfif isdefined("flag_thaigagent") AND flag_thaigagent IS 1 AND isDefined("SESSION.VARS.ORGTYPE") AND SESSION.VARS.ORGTYPE IS "G" AND isDefined("SESSION.VARS.LOCID") AND SESSION.VARS.LOCID IS 11 AND IsDefined("SESSION.VARS.SUBCOTYPEID") AND SESSION.VARS.SUBCOTYPEID IS 4 AND IsDefined("SESSION.VARS.COTYPEID") AND SESSION.VARS.COTYPEID IS 6>displayLoginUserInfo("<cfif not (structKeyExists(request,"mobile") and request.mobile eq 2)><div style='color:<cfif APPLOCID IS 5>black<cfelse>white</cfif>;padding:2 5 0 0; float:right;' align=left></cfif><b>#REQUEST.DS.FN.SVCSanitizeInput(Session.vars.orgname,"JS-NQ")#</b><br>#REQUEST.DS.FN.SVCSanitizeInput(Session.Vars.UserName,"JS-NQ")#<br>#DateFormat(sysdate,"dd mmm yyyy")# #TimeFormat(sysdate,"hh:mm tt")#<cfif not (structKeyExists(request,"mobile") and request.mobile eq 2)></div></cfif><div align=right><a href="+request.webroot+"index.cfm?fusebox=SVCsec&fuseaction=act_setlang&lcode=th&"+request.mtoken+"><img src='"+request.approot+"services/images/TH_Flag.png' BORDER=0 style='margin-right: 10px; width: 20px%; height: 20px'></a><a href="+request.webroot+"index.cfm?fusebox=SVCsec&fuseaction=act_setlang&lcode=en&"+request.mtoken+"><img src='"+request.approot+"services/images/EN_flag.png' BORDER=0 style='margin-right: 10px; width: 20px%; height: 20px'></a></div>");
		<cfelseif ORGTYPE IS NOT "">displayLoginUserInfo("<cfif not (structKeyExists(request,"mobile") and request.mobile eq 2)><div style='color:<cfif APPLOCID IS 5>black<cfelse>white</cfif>;padding:2 5 0 0;  float:right;' align=left></cfif><b>#REQUEST.DS.FN.SVCSanitizeInput(Session.vars.orgname,"JS-NQ")#</b><br>#REQUEST.DS.FN.SVCSanitizeInput(Session.Vars.UserName,"JS-NQ")#<br>#DateFormat(sysdate,"dd mmm yyyy")# #TimeFormat(sysdate,"hh:mm tt")#<cfif not (structKeyExists(request,"mobile") and request.mobile eq 2)></div></cfif>");</cfif>
		drawToolbarComplete();
	</script>
	<cfif not (structKeyExists(request,"mobile") and request.mobile eq 2)><cfif ORGTYPE IS NOT ""><div class="clsTopMenu">&nbsp;</div><!--- Padding for top menu ---></cfif></cfif>
</CFIF>
<!--- show PARS logo --->
<CFIF (ORGTYPE IS "R" OR ORGTYPE IS "A") AND SESSION.VARS.SETLOGIN IS 7 AND APPLOCID IS 1>
	<div style="height:65px;width:100%;background-color:white;padding-left: 5px; border-bottom: 1px solid black;">&nbsp;<img src='#Request.APPROOT#services/images/piamfinal2.png' BORDER=0></div>
</CFIF>
<cfmodule TEMPLATE="#request.logpath#CustomTags/MTRbillnotice2.cfm">
<script>
	<CFIF DOSEARCHBOX IS 1>
		<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\MTRclmtype.cfm">
		try { MTRGenSearch('#orgtype#',<cfif StructKeyExists(URL,"SRCHTYPE") AND URL.SRCHTYPE GT 0>#URL.SRCHTYPE#<cfelse><!---cfif ORGTYPE IS "G">2<!--- Ins/Clmt Name ---><cfelseif ORGTYPE IS "S">8<!--- RFQ No. ---><cfelseif CLMTYPEMASK IS 8192><cfif ORGTYPE IS "A">2<!--- Ins/Clmt Name ---><cfelseif ORGTYPE IS "I">4<!--- Clm No ---></cfif><cfelse>null</cfif--->null</cfif>,#GCOID#,<cfif StructKeyExists(URL,"SRCH") AND Trim(URL.SRCH) IS NOT "">"#JSStringFormat(URL.SRCH)#"<cfelse>null</cfif>,#CLMTYPEMASK#) } catch(e) {};
	</CFIF>
	try	{ JSVCDoBackWarning() } catch(e) {};
</script>
<cfif APPLOCID IS NOT 5></div><cfif not (structKeyExists(request,"mobile") and request.mobile eq 2)></td></tr></cfif><cfelse><br clear=all><h5 align=center style='padding:2px;border:1px solid red'>Case not found? <a href=javascript:JSVCopenWin('http://202.190.197.53/claims/index.cfm')>Click here</a> to access old cases created before 3rd April 09.</h5></cfif>
</cfif>
<cfif APPLOCID IS NOT 5><cfif not structKeyExists(request,"mobile")><tr><td valign="top" width="100%" height="100%"><cfif nolayout IS 0><br></cfif></cfif><div class=clsDocBody<cfif not structKeyExists(request,"mobile")> style="min-height:100%;height:100%"</cfif>></cfif>
<CFIF ORGTYPE IS "D" AND nolayout IS 0 AND (SESSION.VARS.SETLOGIN IS 1 OR SESSION.VARS.SETLOGIN IS 3)>
<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="10R">
<cfif CanRead IS 1>
	<CFIF StructKeyExists(URL,"DEV_CSBAR_SRCH")>
		<cfmodule TEMPLATE="#Request.logpath#index.cfm" FUSEBOX=MTRadmin FUSEACTION=dsp_csbar DEV_CSBAR_SRCH=#URL.DEV_CSBAR_SRCH#>
	<CFELSE>
		<cfmodule TEMPLATE="#Request.logpath#index.cfm" FUSEBOX=MTRadmin FUSEACTION=dsp_csbar>
	</CFIF>
</cfif>
<!--- </CFIF> --->
</CFIF>

<!--- 41913 session timeout alert --->
<cfif (structKeyExists(Application,"TIMEOUTALERT") AND APPLICATION.TIMEOUTALERT EQ 1) AND IsDefined("SESSION.VARS.USID") AND SESSION.VARS.USID NEQ ''>
	<script src="CustomTags/jquery_easy_session_timeout.js"></script>
	<script type="text/javascript">
		$(document).ready(function($) 
		{
			var minsTimeout = 15; //expired in xx mins
			var secondsTimeout = minsTimeout * 60; //convert to seconds
			$.jq_easy_session_timeout(
			{	    
				inactivityDialogDuration: 60,
				maxInactivitySeconds: secondsTimeout,	     
				inactivityLogoutUrl:'#request.webroot#index.cfm?fusebox=MTRsec&fuseaction=act_logout&#Request.MToken#',
				manualLogoutUrl:'#request.webroot#index.cfm?fusebox=MTRsec&fuseaction=act_logout&#Request.MToken#',
				manualStayLoggedInUrl:function () {
					$.ajax({
						url: "<cfoutput>#request.webroot#index.cfm?fusebox=MTRroot&fuseaction=act_ChkSession</cfoutput>",
						method: "POST",
						success: function(e) { console.log('Session extended'); }
					});
				},
			});

		});
	</script>
</cfif>
</CFOUTPUT>
<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVClivechat.cfm">