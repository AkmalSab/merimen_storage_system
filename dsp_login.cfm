<!---
FILENAME : CLAIMS/root/dsp_login_mob.cfm
DESCRIPTION :
Generate a mobile responsive login page.

INPUT/ATTR: UserID - Pre-fill UserID field in login [ for login retries ].
RetryID - The no of tries for displaying error message.

OUTPUT : None.

CREATED BY : Zi Qin
CREATED ON : 04 Nov 2016

REVISION HISTORY
BY          ON          REMARKS
=========   ==========  ======================================================================================
--->

<CFIF IsDefined("SESSION.VARS.USID")>
    <CFSET request.inSession=1>
    <cfif StructKeyExists(SESSION.VARS,"HTTPS") AND SESSION.VARS.HTTPS IS 1><!--- For clients requiring HTTPS for all sessions --->
        <CFIF CGI.HTTPS IS NOT "on">
            <CFLOCATION url="https://#CGI.SERVER_NAME##CGI.SCRIPT_NAME#?#CGI.QUERY_STRING#" addtoken=no>
        </CFIF>
    </cfif>		
<CFELSE>
    <CFSET request.inSession=0>
</CFIF>

<cfif IsDefined("SESSION.VARS")>
  <cfif IsDefined("SESSION.VARS.MACID")>
    <cfif Not IsDefined("COOKIE.MACID") OR (SESSION.VARS.MACID IS NOT COOKIE.MACID)>
      <cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCLI">
    </cfif>
  </cfif>
  <cflock SCOPE="Session" Type="Exclusive" TimeOut=60>
    <cfscript>StructClear(session.vars);</cfscript>
  </cflock>
	<CFSET request.inSession=0>
</cfif>

<cfset request.mobile = 2>

<CFSET APPNAME=Application.ApplicationName>
<CFSET APPLOCID=application.APPLOCID>
<!--- If user preferred language not set, then set default language based on locale --->
<cfif APPLOCID IS 7>
	<cfset request.lgid=2>
<cfelseif APPLOCID IS 17>
	<cfset request.lgid = 7>
</cfif>

<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\SETTOKEN.cfm" CLEARSESSION noscript>
<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\MTRHEADER.cfm" nolayout isStandards=1>
<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCADDFILE.cfm" FNAME="SVCLOGIN">

<cfset FN=Request.DS.FN>


<CFIF IsDefined("Arguments.LF")>
	<CFSET Arguments.LF=Request.DS.FN.SVCSanitizeInput(Arguments.LF,'JS-NQ')>
	<cfinclude template="q_colf.cfm"> <!--- to hardcode the logo path and customise the logo style --->
<CFELSE>
	<CFSET Arguments.LF="">
</CFIF>

<!--- ID disable training mode and reset password --->
<cfset disableTrainingMod=0>
<cfset disableForgotPswd=0>
<cfif NOT StructKeyExists(URL,"fuseaction") and Arguments.LF neq "">
<cfif application.APPLOCID IS 7>
<cfif ListFind("UAT,DEV",Application.DB_MODE) OR (Arguments.LF neq "tokopedia" AND ListFind("PROD",Application.DB_MODE))> <!--- #26720 disable PROD --->
<cfset disableTrainingMod=1>
<cfset disableForgotPswd=1>
</cfif> <!--- #26720 disable PROD --->
</cfif>
</cfif>

<script>
<cfoutput>
var retryid = #ARGUMENTS.retryid#;
var userid = "";
<cfset currenttime="#DateFormat(now(),'mm/dd/yyyy')# #TimeFormat(now(),'HH:mm:ss')#">
<cfset nonce=ToBase64(currenttime&Hash(currenttime&"boo$ga56"))>
<CFSET GIARMC=0>
<!--- <CFIF (CGI.HTTP_HOST IS "www.giarmc.org.sg" OR CGI.HTTP_HOST IS "202.157.152.91" OR CGI.HTTP_HOST IS "giauat.merimen.com") AND NOT(REQUEST.DS.MTRFN.DisableSGGIA(1))><cfset GIARMC=1></CFIF> --->
</cfoutput>
</script>

<!--- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries --->
<!--[if lt IE 9]>
<script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
<script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
<![endif]-->
<style>
body{padding:0 40px 20px 30px}
.container-full{margin:10px 10px 10px 10px;width:100%}
.box-corner{color:black;background:#F8F8F8;-moz-border-radius:10px 10px 10px 10px;-webkit-border-radius:10px 10px 10px 10px;border-radius:10px 10px 10px 10px;z-index:10;-webkit-box-shadow:4px 4px 5px 0 rgba(136,136,136,.75);-moz-box-shadow:4px 4px 5px 0 rgba(136,136,136,.75);box-shadow:4px 4px 5px 0 rgba(136,136,136,.75)}
.login{margin-top:-190px;margin-left:15px;padding:25px}
.clsSVCColorError{font-size:12px;}
.login form input[type="text"],.login form input[type="password"] {font-size:10pt;display:inline-block;}
.login-text {font-size:8pt;}
.client-list {margin-top:15px;margin-left:15px;padding-top:20px;}
.header-login{background:<CFIF GIARMC IS 1>#D4641A<CFELSEIF LF neq ''>#ffffff<cfelse>#4477b2</cfif>;padding-left:27%;padding-top:10px;padding-bottom:10px;color:white;<CFIF Arguments.LF eq ''>min-height:151px</cfif>}
.header-login h5,.header-login h3{color:white;<cfif GIARMC eq 0>line-height:.3;</cfif>}
.header-small{background:<CFIF GIARMC IS 1>#FE9900<CFELSE>#779ecb</cfif>;margin-top:2px}
.header-mobile{background:#4477b2}
.header-image{background:<cfif giarmc eq 1>#D4641A<cfelse>#4477b2</cfif>;text-align:right;padding:0;margin:0;right:0;overflow:hidden;min-height:151px}
.announcement{font-size:8.5pt;display:inline-block;padding:0 20px 0 30px}
#headerClient,#headerClient2{text-align:center}
#headerClient h6,#headerClient2 h6{color:#4477b2;font-weight:700}
.carousel{height:auto}
.carousel .item{padding-bottom:20px}
.carousel-inner>.item>h6{color:#4477b2;font-weight:700;text-align:center;margin-top:0}
.carousel-inner>.item>img{position:absolute;top:0;left:0;min-width:100%}
.note{position:relative;width:102%;padding:1em 1.5em;margin:10px auto;color:#000;background:#EFEFEF;overflow:auto}
.note:before{content:"";position:absolute;top:0;right:0;border-width:0 16px 16px 0;border-style:solid;border-color:#fff #fff #999 #999;background:#999;-webkit-box-shadow:0 1px 1px rgba(0,0,0,.3),-1px 1px 1px rgba(0,0,0,.2);-moz-box-shadow:0 1px 1px rgba(0,0,0,.3),-1px 1px 1px rgba(0,0,0,.2);box-shadow:0 1px 1px rgba(0,0,0,.3),-1px 1px 1px rgba(0,0,0,.2);display:block;width:0}
@media (max-width:640px){body{padding-top:0;padding-left:15px;padding-right:35px}.announcement{padding-top:0;margin-top:10px;width:100%}.note{width:118%;margin-left:-30px}}
@media (max-width:360px){ .note{width:124%} }
<cfif arguments.lf neq "">
@media (max-width:549px) 					   { #header-image-<cfoutput>#arguments.lf#</cfoutput> { padding:0px; margin:0px; content:url('<cfoutput>#request.approot#</cfoutput>claims/common/<cfoutput>#logopath_small#</cfoutput>')} }
@media (min-width:550px) and (max-width:768px) { #header-image-<cfoutput>#arguments.lf#</cfoutput> { padding-top:10px; margin:0px; content:url('<cfoutput>#request.approot#</cfoutput>claims/common/<cfoutput>#logopath_small#</cfoutput>')} }
</cfif>
@media (max-width:768px){.login{margin-top:10px;margin-left:0}.client-list{margin-left:0}.announcement{margin-left:0}.header-login{padding-left:30px;font-size:70%}.header-login h5{font-size:170%}.header-login h3{font-size:190%}}
@media (min-width:768px){.carousel-inner>.item>img,.carousel-inner>.item>a>img{max-width:inherit}body{font-family:'Droid Sans',sans-serif;padding-top:20px}.carousel-caption p{margin-bottom:20px;font-size:21px;line-height:1.4}.login{<cfif arguments.lf eq "">margin-top:-192px;<cfelse>margin-top:-132px;</cfif>margin-left:15px}.client-list{margin-left:15px}.header-login{padding-left:40%;font-size:82%}.col-sm-3{width:36%}.col-sm-9{width:64%}.col-sm-8{width:90%}.col-sm-4{width:10%}.header-image>img{visibility:hidden}}
@media (min-width:992px){.header-login h5{font-size:150%}.header-login h3{font-size:170%}.header-login{padding-left:39%;font-size:82%}.header-image>img{visibility:visible}.col-sm-3{width:36%}.col-sm-9{width:64%}.col-sm-8{width:72%}.col-sm-4{width:28%}<cfif GIARMC>.header-login{background:#D4641A url(<cfoutput>#request.apppath#</cfoutput>services/images/masthead2.jpg) 130% 0% no-repeat}</cfif>.header-login h1{font-size:1000%}img#header-image-tokopedia { max-width: 600px; )} #header-image-toyotaPDC { max-width: 600px; max-height: 80px;)}
@media (min-width:1281px){.header-login h5{font-size:170%}.header-login h3{font-size:190%}.header-login{padding-left:27%;font-size:100%}.col-sm-3{width:25%}.col-sm-9{width:75%}.col-sm-8{width:66%}.col-sm-4{width:34%}<cfif GIARMC>.header-login{background:#D4641A url(<cfoutput>#request.apppath#</cfoutput>services/images/masthead2.jpg) 100% 0% no-repeat}</CFIF>img#header-image-tokopedia { max-width: 700px; )}
.clsSVCColorError {padding:1em; text-align:center; border: 2px solid; font-weight:bold;}
.tooltip-inner { max-width: 250px; width: 250px; }
</style>

<cfoutput>
  	<div class="row">
		<CFIF arguments.LF neq ""> <!--- name the image(logo) with LF parameter value or hardcode logo path in q_colf.cfm --->
			<div class="col-sm-12 header-login" align=center>
				<img id="header-image-#arguments.lf#" src='#request.webroot#common/#logopath#' #logostyle#>
			</div>
		<CFELSE>
		    <div class="<cfif GIARMC eq 1>col-sm-12<cfelse>col-sm-8</cfif> header-login">
				<h5>Welcome to</h5><h3><CFIF GIARMC eq 1>GIARMC CENTRALISED<br>DATABASE SYSTEM</span><CFELSE> Merimen Online v15 </CFIF></h3>
				<cfif APPLOCID IS 1>
				Malaysia Edition &copy; 2000-#Year(now())# Merimen<br>Tel: 03-8942 8281, Fax: 03-8942 8318
				<cfelseif APPLOCID IS 2>
				Singapore Edition &copy; 2006-#Year(now())# Merimen<br>Tel: +65-6224 0010, Fax: +65-6224 0030
				<cfelseif APPLOCID IS 4>
				India Edition &copy; 2006-#Year(now())# Merimen<br>Tel: +603-8942 8281, Fax: +603-8942 8318
				<cfelseif APPLOCID IS 6>
				Pakistan Edition &copy; 2006-#Year(now())# Nanjee Merimen<br>Tel: 021-2210986/8, Fax: 021-263 7052
				<cfelseif APPLOCID IS 7>
				Indonesia Edition &copy; 2006-#Year(now())# Merimen<br>Tel: +6221 5010 1563/64 , Fax: +6221 575 0803
				<cfelseif APPLOCID IS 8>
				Algeria Edition &copy; 2006-#Year(now())# Merimen<br>Tel: +603-8942 8281, Fax: +603-8942 8318
				<cfelseif APPLOCID IS 10>
				Philippines Edition &copy; 2006-#Year(now())# Merimen<br> Tel: (+632) 8330-2126 / (+632) 8330-2129 / (+632) 8330-2148
				<cfelseif APPLOCID IS 11>
				Thailand Edition &copy; 2006-#Year(now())# Merimen<br> Tel: (+66) 2105 6357
				<cfelseif APPLOCID IS 13>
				Saudi Arabia Edition &copy; 2006-#Year(now())# Merimen<br>Tel: +603-8942 8281, Fax: +603-8942 8318
				<cfelseif APPLOCID IS 14>
				Hong Kong Edition &copy; 2006-#Year(now())# Merimen<br> Tel: +65-6224 0010, Fax: +65-6224 0030
				<cfelseif APPLOCID IS 15>
				Vietnam Edition &copy; 2006-#Year(now())# Merimen<br> Tel: (+84)8 6255 6845
				<cfelseif APPLOCID IS 16>
				Cambodia Edition &copy; 2006-#Year(now())# Merimen<br> Tel: (+855)
				</cfif>
		    </div>
		    <cfif GIARMC eq 0>
			<div class="col-sm-4 header-image hidden-xs">
				<img src="#request.approot#services/mobile/world.png">
			</div>
			</cfif>
		</CFIF>
  	</div>

  	<div class="row">
	    <div class="col-sm-12 header-small">
		&nbsp;
	    </div>
  	</div>

  	<div class="row">
    	<div class="col-sm-3" style="height:auto">
      		<div class="row">
        		<div align="center" class="col-sm-12 box-corner login">
					<CFIF arguments.LF neq "">
						<!--- nothing --->
					<CFELSE>
						<img src="#request.approot#services/mobile/<cfif NOW() GTE '2021-11-20'>fermionmerimen_sm.png<cfelse>merimenlogo.png</cfif>" style="margin: 3px auto; max-width: 150px; height: auto;" /> <CFIF APPLOCID IS 2 AND GIARMC IS 1><div style="margin:4px 0px -4px 0px"><img src='#request.webroot#common/giarmctoplogo2.png' border=0 align=center></div></CFIF>
					</CFIF>
		        	<br>
					<cfif Len(APPNAME) GT 6 AND Right(APPNAME,6) IS "_train">
					<div align=center style=font-size:120%;color:darkred;font-weight:bold>( Training Mode )</div>
					</cfif>
					<script>
						<!--- <CFIF GIARMC>var JSGIARMC = #GIARMC#;</CFIF> --->
						JSVCDoLogin("#nonce#",5*60*1000,"fusebox=MTRsec&fuseaction=act_login");
						var loc_lgid = 0, tmpText = "";
						if(request.lgid>=0)
							loc_lgid=request.lgid;
						else if(jSVClgid>=0)
							loc_lgid=jSVClgid;
						if(loc_lgid>0)
							if(request.DS.LANG[loc_lgid]!=null && request.DS.LANG[loc_lgid][1003]!=null)
								tmpText=request.DS.LANG[loc_lgid][1003];
						if (tmpText.match(/\{0\}/gi)) {
							var termofuse = "<nobr><a style=font-weight:bold href=\"#Request.Webroot#index.cfm?fusebox=MTRroot&fuseaction=dsp_terms\">"+JSVClang("Terms of Use",1004)+"</a></nobr>";
							document.write("<div align=center><br><div align=left style=width:90%>"+JSVClang("By logging in, you acknowledge that you have read, understood and agreed to our {0}.",1003,0,termofuse)+"</div></div>");
						}
						else
							document.write("<div align=center><br><div align=left style=width:90%>"+JSVClang("By logging in, you acknowledge that you have read, understood and agreed to our",1003)+" <nobr><a style=font-weight:bold href=\"#Request.Webroot#index.cfm?fusebox=MTRroot&fuseaction=dsp_terms\">"+JSVClang("Terms of Use",1004)+"</a>.</nobr></b></div></div>");
						<CFIF Len(APPNAME) GT 6 AND Right(APPNAME,6) IS "_train">
						document.write("<br><br><b style=color:red>"+JSVClang("You are in Training Mode",1005)+".</b><br>"+JSVClang("Click here to return to",1006)+" <a style=font-weight:bold href=\"index.cfm?fusebox=MTRroot&fuseaction=dsp_login&skip_browsertest=1\">"+JSVClang("Live Mode",1007)+"</a>.<br>");
						<CFELSEIF disableTrainingMod eq 0>
						document.write("<br><br>"+JSVClang("Click here to access",1008)+" <a style=font-weight:bold href=\"index.cfm?fusebox=MTRroot&fuseaction=dsp_login&train=1&skip_browsertest=1\">"+JSVClang("Training Mode",1002)+"</a>.");
						</CFIF>
						<CFIF StructKeyExists(Application,"PASSWORDRESET") and Application.PASSWORDRESET eq 1 and disableForgotPswd eq 0>
						document.write("<br><br><a style=font-weight:bold href=\"index.cfm?fusebox=SVCsec&fuseaction=dsp_forgotpass<CFIF Len(APPNAME) GT 6 AND Right(APPNAME,6) IS "_train">&train=1</cfif>\">"+JSVClang("Forgot Password",25089)+"</b></a>.</div>");
						</CFIF>
					</script>
				</div>
  			</div>
    	</div>
  	</div>


</cfoutput>
</body>

<script>
	function carouselNext()
	{
		var myCarousel = $("[id='myCarousel']")
		myCarousel.carousel("next");
	}
	AddOnloadCode("$('input').placeholder({customClass:'my-placeholder'});")
	<cfif GIARMC>
	$(document).ready(function(){
	    $('[data-toggle="tooltip"]').tooltip();
	});
	$('[data-toggle="tooltip"]').tooltip({html:true,
	    'placement': function(tt, trigger) {
	        var $trigger = $(trigger);
	        var windowWidth = $(window).width();

	        var xs = $trigger.attr('data-placement-xs');
	        var sm = $trigger.attr('data-placement-sm');
	        var md = $trigger.attr('data-placement-md');
	        var lg = $trigger.attr('data-placement-lg');
	        var general = $trigger.attr('data-placement');


	        return (windowWidth >= 1200 ? lg : undefined) ||
	            (windowWidth >= 992 ? md : undefined) ||
	            (windowWidth >= 768 ? sm : undefined) ||
	            xs ||
	            general ||
	            "top";
	    }
	});
	</cfif>
</script>


</html>