<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\URLBACK.cfm" new>
<cfoutput>
<cfset sysdate=now()>
<cfset newurlback = REReplaceNoCase(newurlback, "%26MOBILE%3D2", "", "ALL")>
<link href="#request.approot#services/scripts/Mobile/css/main.css" rel=stylesheet type=text/css></link>
<body>  
 <nav class="navbar navbar-default navbar-static-top">
      <div class="container-fluid">
        <div class="navbar-header">
          <button type="button" class="pull-left navbar-toggle collapsed" data-toggle="collapse" data-target="##navbar" aria-expanded="false" aria-controls="navbar">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span> 
          </button>
          <a class="navbar-brand" href="##"><img src="common/merimenlogo.png"/>
          </a>
        </div>
        <div id="navbar" class="navbar-collapse collapse">
          <ul class="nav navbar-nav">
            <li class="hidden-xs"><a href="#request.webroot#index.cfm?fusebox=MTRroot&fuseaction=dsp_home&setlogin=0&#Request.MTOKEN#">Main Menu</a></li>
            <li class="active"><a href="#request.webroot#index.cfm?fusebox=MTRroot&fuseaction=dsp_home&setpersonal=0&#Request.MTOKEN#">Claims Home</a></li>
            <li class="hidden-xs"><a href="#request.webroot#index.cfm?fusebox=MTRroot&fuseaction=dsp_home&setpersonal=1&personal=1&#Request.MTOKEN#">Personal-In-Tray</a></li>
            <li class="hidden-xs"><a href="#request.webroot#index.cfm?fusebox=SVCmail&fuseaction=dsp_composemail&mode=0&#Request.MTOKEN#&#newurlback#">Compose Mail</a></li>
        <li class="dropdown hidden-xs">
              <a href="##" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Help <span class="caret"></span></a>
              <ul class="dropdown-menu">
                <li><a href="##">Help Contents</a></li>
                <li><a href="##">Feedback/Requests</a></li>
        <li class="dropdown-submenu">
                    <a href="##" class="dropdown-toggle" data-toggle="dropdown">Language</a>
              <ul class="dropdown-menu">
                <li><a href="##">Bahasa Indonesia</a></li>
                <li><a href="##">English <i class="fa fa-check" aria-hidden="true"></i></a></li>
            </ul>
        </li>
              </ul>
            </li>
      <li><a href="#request.webroot#index.cfm?fusebox=MTRsec&fuseaction=act_logout&#Request.MTOKEN#">Logout</a></li>
          </ul>

      <p class="navbar-text navbar-right login-info"><b>#REQUEST.DS.FN.SVCSanitizeInput(Session.vars.orgname,"JS-NQ")#</b><br/>
      #REQUEST.DS.FN.SVCSanitizeInput(Session.Vars.UserName,"JS-NQ")#<br/>#DateFormat(sysdate,"dd mmm yyyy")# #TimeFormat(sysdate,"hh:mm tt")#</p>
        </div><!--/.nav-collapse -->
      </div>
    </nav>

<div class='container-fluid' id="content">
  <div class="row">
    <div class="col-lg-4 col-lg-offset-8 col-md-6 col-md-offset-6">
      <div class="input-group">
        <div class="input-group-btn">
          <button id="input-search-type-id" type='button' class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" data-value=0>Multi-Search<span class="caret"></span></button>
          <ul id="inputsearchtype" class='dropdown-menu darkred'>
            <li data-value=0><a href='##'>JSVClang("Multi-Search",25461)</a></li>
            <li data-value=1><a href='##'>JSVClang("Vehicle Reg. No.",1534)</a></li>
            <li data-value=2><a href='##'>JSVClang("Ins/Clmt Name",25462)</a></li>
            <li data-value=3><a href='##'>JSVClang("Ins/Clmt NRIC",25463)</a></li>
            <li data-value=4><a href='##'>JSVClang("Ins Claim No",25464)</a></li>
            <li data-value=5><a href='##'>JSVClang("Certificate No",9708)</a></li>
            <li data-value=6><a href='##'>JSVClang("Ins Policy No",25465)</a></li>
            <li data-value=7><a href='##'>JSVClang("Agent/Intermediary Code",25467)</a></li>
            <li data-value=8><a href='##'>JSVClang("RFQ No.",25468):"")</a></li>
            <li data-value=9><a href='##'>JSVClang("Internal File No",6759)</a></li>
            <li data-value=11><a href='##'>JSVClang("Solicitor Own Ref No.",25470)</a></li>
            <li data-value=12><a href='##'>JSVClang("Date of Loss",2919)</a></li>
          </ul>
        </div><!-- /btn-group -->
        <input id = "input-search-name-id" type="text" class="form-control" aria-label="...">
        <span class="input-group-btn">
              <button type="button" class="btn btn-mrm btn-md" id="buttonsearch"><i class="fa fa-search" aria-hidden="true"></i> Go</button>
        </span>
        <div><input type="hidden" id="typeID"></div>
        <div><input type="hidden" id="nameID"></div>
      </div><!-- /input-group -->
    </div><!-- /.col-lg-6 -->
  </div>
</div>
 </body>
</cfoutput>

<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
<script src="#request.approot#services/scripts/mobile/js/ie10-viewport-bug-workaround.js"></script>
<script src="#request.approot#services/scripts/mobile/js/bootstrap.min.js"></script>
   <script>
    $(document).ready(function () {
         $('.navbar-collapse a').click(function (e) {
        $('.navbar-collapse').collapse('toggle');
        });

      $(document).click(function (event) {
        var clickover = $(event.target);
        var $navbar = $(".navbar-collapse");
        var _opened = $navbar.hasClass("in");
        if (_opened === true && !clickover.hasClass("navbar-toggle")) {
          $navbar.collapse('hide');
        }
      });

       $("#selclmtypes").click(function() {
        var checkBoxes = $("input[name=chkclmtype]");
        checkBoxes.prop("checked", !checkBoxes.prop("checked"));
      });

        $(".claim-type-box .dropdown-menu a, .claim-type-box .dropdown-menu .container").click(function(e) {
        e.stopPropagation();
      });

      $(".claim-type-box .dropdown-menu button").click(function (e){
        $(".claim-type-box .dropdown-menu").dropdown("toggle");
      });
    });

   $(function(){
    $(".input-group-btn .dropdown-menu li").click(function(){
        var selText = $(this).children("a").html();
        var selValue = $(this).attr("data-value");
       $(this).parents(".input-group-btn").find(".btn-default").html(selText);
       $(this).parents(".input-group-btn").find(".btn-default").attr("data-value",selValue);
     });
    });

    $("#buttonsearch").click(function() {
        var name = $("#input-search-name-id").val();
        $("#nameID").attr("value",name);
        var type = $("#input-search-type-id").attr("data-value");
        $("#typeID").attr("value",type);

        var selname = document.getElementById("nameID");
        var seltype = document.getElementById("typeID");
        MTRDirSearch(selname,seltype);
     });
    </script>

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