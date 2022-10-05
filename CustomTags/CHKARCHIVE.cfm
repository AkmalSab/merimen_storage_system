<cfparam name="Attributes.CaseID" default="">
<cfparam name="Attributes.CHKCASE" default="0">
<cfparam name="Attributes.EXTID" default="0">
<cfparam name="Attributes.CHKTENDER" default="0">
<cfparam name="Attributes.CUSTSERVICE" default="0">

<!--- <cfparam name="Attributes.DisplaySummary" default="0"> --->
<CFIF NOT structKeyExists(Application, "MTRARCDSN")>
  <CFEXIT>
</CFIF>

<CFSET INSTANT = 0>
<CFIF Attributes.CUSTSERVICE eq 1 or (structKeyExists(Application, "ARCH_RESTORE") and Application.ARCH_RESTORE eq 1)>
  <CFSET INSTANT = 1>
</CFIF>

<style>
.clearfix:after {
    clear: both;
    content: "";
    display: block;
    height: 0;
}

.archive-container {
	width: 866px;
	margin: 0 auto;
  border: 0px solid yellow;
  margin-bottom:3em;
  background-color: #e0e0e0;
  -webkit-box-shadow: 0px 3px 10px 0px #b5b5b5;  /* Safari 3-4, iOS 4.0.2 - 4.2, Android 2.3+ */
  -moz-box-shadow:    0px 3px 10px 0px #b5b5b5;  /* Firefox 3.5 - 3.6 */
  box-shadow:         0px 3px 10px 0px #b5b5b5;  /* Opera 10.5, IE 9, Firefox 4+, Chrome 6+, iOS 5 */
}

.archive-container-processing {
	width: 741px;
	margin: 0 auto;
  border: 0px solid yellow;
  margin-bottom:3em;
  background-color: #f54444;
  -webkit-box-shadow: 0px 3px 10px 0px #b5b5b5;  /* Safari 3-4, iOS 4.0.2 - 4.2, Android 2.3+ */
  -moz-box-shadow:    0px 3px 10px 0px #b5b5b5;  /* Firefox 3.5 - 3.6 */
  box-shadow:         0px 3px 10px 0px #b5b5b5;  /* Opera 10.5, IE 9, Firefox 4+, Chrome 6+, iOS 5 */
}


/* Breadcrups CSS */

.arrow-steps .step {
	text-align: center;
	color: #666;
	cursor: default;
	margin: 0 0px;
	padding: 15px 10px 15px 15px;
	min-width: 100px;
  height: 80px;
	float: left;
	position: relative;
	background-color: #d9e3f7;
	-webkit-user-select: none;
	-moz-user-select: none;
	-ms-user-select: none;
	user-select: none;
  transition: background-color 0.2s ease;
}

.arrow-steps .step:after,
.arrow-steps .step:before {
	content: " ";
	position: absolute;
	top: 0;
	right: -40px;
	width: 0;
	height: 0;
	border-top: 55px solid transparent;
	border-bottom: 55px solid transparent;
	border-left: 53px solid #d9e3f7;
	z-index: 1;
  transition: border-color 0.2s ease;
}

.arrow-steps .step:before {
	right: auto;
	left: 0;
	border-left: 0px solid #fff;
	z-index: 1;
}

.arrow-steps .step:first-child:before {
	border: none;
}

.arrow-steps .step:first-child {
	border-top-left-radius: 4px;
	border-bottom-left-radius: 4px;
}

.arrow-steps .step span {
	position: relative;
}

.arrow-steps .step span:before {
	opacity: 0;
	content: "✔";
	position: absolute;
	top: -2px;
	left: -10px;
}

.arrow-steps .step.first {
	color: #fff;
	background-color: #F2BE0A;
  	width:100px;
}

.arrow-steps .step.first:after {
	border-left: 40px solid #F2BE0A;
}

.arrow-steps .step.second {
  background-color: #F54444;
  width:450px;
  text-align: left;
}

.arrow-steps .step.second div {
  font-weight:bold;
  font-size:16px;
  letter-spacing: 0.8px;
	color: #fff;
  padding-left:5ex;
}

.arrow-steps .step.second.email div {
  padding-top:3px;
  margin-bottom:-3px;
}
.arrow-steps .step.second.noemail > div {
  padding-top:10px;
}

.arrow-steps .step.second:after {
	border-left: 40px solid #F54444;
}
.arrow-steps .step.second.email div#smaller {
  font-weight:normal;
  font-size:14px;
  color:#fff;
  margin-top:1em;
  letter-spacing: 0px;
  line-height:2.5ex;
  padding-left:6ex;
}
.arrow-steps .step.second.noemail div#smaller, .arrow-steps .step.processing div#smaller {
  font-weight:normal;
  font-size:14px;
  color:#fff;
  margin-top:0.5em;
  letter-spacing: 0px;
  line-height:2.5ex;
  padding-left:6ex;
}


.arrow-steps .step.third {
	color: #000;
	background-color: #DBDBDB;
  width:220px;
  padding-left:6ex;
}

.arrow-steps .step.third:after {
	border-left: 0px solid #DBDBDB;
}



.arrow-steps .step.processing {
  text-align:left;
	color: #000;
	background-color: #F54444;
  width:570px;
  padding-left:6ex;
}


.arrow-steps .step.processing div {
  font-weight:bold;
  font-size:16px;
  letter-spacing: 0.8px;
	color: #fff;
  padding-left:5ex;
}

.arrow-steps .step.processing > div {
  padding-top:6px;
}
.arrow-steps .step.processing:after {
	border-left: 0px solid #F54444;
}

.bannerbutton {
  font-size:14px;
  background-color: #0F9D58;
  border:1px solid #c0c0c0;
  letter-spacing: 1px;
  cursor:pointer;
  color:#fff;
  font-weight:bold;
  padding:5px 15px;
}

.bannerbutton.email {
  margin-top:3px;
}
.bannerbutton.noemail{
  margin-top:23px;
}

.banneremail {
    font-size: 14px;
    letter-spacing: -0.5px;
    margin: 5px 0px 5px 0px;
    border-bottom: 1px solid #c0c0c0;
    border-top: 0px solid black;
    border-right: 0px solid black;
    border-left: 0px solid black;
    padding-top:5px;
    padding-bottom:3px;
    text-align:center;
}
</style>

<CFIF val(attributes.CASEID) gt 0>
  <CFQUERY name="q_chkarchive" datasource="#Request.MTRDSN#">
    select a.iARCHID,a.iCASEID,a.iARCHSTAT,b.iUSID from ARCH_MAIN a WITH (NOLOCK)
      left join ARCH_RESTORE_QUEUE b with (NOLOCK) on a.iCASEID = b.iCASEID
        and b.iUSID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.vars.USID#">
        and b.siPROCESSED = 0
    WHERE a.ICASEID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CASEID#">
  </CFQUERY>
  <CFIF q_chkarchive.recordCount eq 0 or q_chkarchive.iARCHSTAT eq 0>
    <CFSET CALLER.ARCCASE_RESTORED = -1>
    <CFEXIT>
  </CFIF>
  <CFIF q_chkarchive.iUSID eq ""><CFSET PROCESSING = false><CFELSE><CFSET PROCESSING = true></CFIF>

  <CFIF q_chkarchive.iARCHSTAT eq 1><!--- currently in archive --->
    <!--- restoration --->
    <CFIF structKeyExists(form,"restcaseid") and form.restcaseid neq "">

      <CFIF INSTANT eq 1>
        <cfstoredproc PROCEDURE="sspArchRestore" DATASOURCE="#Request.MTRDSN#" RETURNCODE=YES>
		<CFIF application.DB_MODE eq "PROD" and application.DB_COUNTRY eq "MY">
			<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_VARCHAR VALUE="mymotor_prod2" DBVARNAME=@as_sourcedb>
		<CFELSE>
    		<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_VARCHAR VALUE="#Request.MTRDSN#" DBVARNAME=@as_sourcedb>
		</CFIF>
        <cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_VARCHAR VALUE="#Application.MTRARCDSN#" DBVARNAME=@as_targetdb>
        <cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_VARCHAR VALUE="#Attributes.CASEID#" DBVARNAME=@as_caseidlist>
        <cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=1 DBVARNAME=@ai_restore>				
		<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=0 DBVARNAME=@asi_batch>
		<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=0 DBVARNAME=@ai_debug>
		<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#session.vars.USID# DBVARNAME=@ai_usid>
        </cfstoredproc>
        <cfset SPRESULT=CFSTOREDPROC.StatusCode>
        <cfif SPRESULT LT 0>
            <cfthrow TYPE="EX_RESTOREARC" ErrorCode="REST/CHKARCHIVE(#Attributes.CASEID#/#SPRESULT#)">
        </cfif>
        <CFSET CALLER.ARCCASE_RESTORED = 1>
        <CFSET CALLER.ARCCASE_ID = q_chkarchive.iARCHID>
		<CFIF session.vars.orgtype eq "D">
        	<CFEXIT>
		<CFELSE>
			<CFLOCATION URL="#request.webroot#index.cfm?#CGI.QUERY_STRING#" addtoken=no>
		</CFIF>
      <CFELSE>
        <CFIF NOT PROCESSING>
          <CFQUERY name="q_chkRestoring" DATASOURCE="#REQUEST.MTRDSN#">
            INSERT INTO ARCH_RESTORE_QUEUE(iCASEID,iARCHID,iUSID,dtCRTON,vaEMAILNOTIFY,siPROCESSED)
            VALUES(<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CASEID#">,
                  <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#q_chkarchive.iARCHID#">,
                  <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.vars.USID#">,
                  getdate(),
                  <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.email#">,
                  0)
          </CFQUERY>
          <CFSET PROCESSING = true>
        </CFIF>
      </CFIF>
    </CFIF>

    <br>
    <cfoutput>
    <script>AddOnloadCode("MrmPreprocessForm()");
      function archDoRestore() {
        var obj = document.getElementById('restore');
        if(FormVerify(obj))
        {
          obj.submit();
        }
        return false;
      }
    </script>
    <form id="restore" name="restore" action="#request.webroot#index.cfm?#CGI.QUERY_STRING#" method="post" autocomplete="off">
    <div class="archive-container<CFIF PROCESSING>-processing</cfif>">
      <div class="wrapper">
        <div class="arrow-steps clearfix">
            <div class="step current first"><span><img src="#request.approot#services/images/file-archive-icon.png" style="height:80px"></span></div>

          <CFIF NOT PROCESSING>
            <div class="step second<cfif INSTANT eq 1> noemail<CFELSE> email</CFIF>">
              <CFIF attributes.CHKTENDER eq 1>
              <div>THE CLAIMS SUBFOLDER IS ARCHIVED</div>
              <CFELSE>
              <div>THIS CASE IS CURRENTLY ARCHIVED</div>
              </CFIF>
              <div id=smaller>Kindly confirm that you would like to restore this case<cfif INSTANT eq 0>.
              <br>An e-mail notification will be sent to you once it is ready</cfif>.</div>
            </div>
            <div class="step third">
              <div>
                  <CFIF INSTANT eq 0>
                    <CFQUERY name="q_getusr" datasource="#REQUEST.MTRDSN#">
                        select vaemail from sec0001 with (nolock) where iusid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.vars.usid#">
                    </CFQUERY>
                    <input type="text" class="banneremail"  name="email" id="email" value="#q_getusr.vaemail#" autocomplete="off" CHKREQUIRED CHKNAME="E-mail" onblur="JSVCDoEmail(this,1,0,1);DoReq(this);" placeholder="Your E-mail Address">
                  </CFIF>
                  <input type="hidden" name="restcaseid" id="restcaseid" value="#Attributes.CASEID#">
                  <button type=button class="bannerbutton<cfif INSTANT eq 1> noemail<CFELSE> email</CFIF>" onClick="archDoRestore();">Confirm To Restore</button>
              </div>
            </div>
          <CFELSE>
            <div class="step processing noemail">
              <div>THIS CASE IS CURRENTLY ARCHIVED</div>
              <div id=smaller>You have already requested for this case to be restored. <br>An e-mail notification will be sent to you once it is ready for vieweing.</div>
            </div>
          </CFIF>

        </div>
      </div>
    </div>
    </form>
    </cfoutput>

    <CFSET CALLER.ARCCASE_RESTORED = 0>
    <CFSET CALLER.ARCCASE_ID = q_chkarchive.iARCHID>

    <!--- Called from ChkCase. Display summary and prompt to restore. --->
    <CFIF Attributes.CHKCASE eq 1 and q_chkarchive.iARCHSTAT eq 1>
      <cfmodule TEMPLATE="#Request.logpath#index.cfm" FUSEBOX=MTRclaim FUSEACTION=DSP_CLMARCH CASEID=#attributes.caseid# COTYPE=#SESSION.VARS.ORGTYPE# NOHEADER CLMHEADER=1 ARCHID=#q_chkarchive.iARCHID# EXTID=#Attributes.EXTID#>
      <CFABORT>
    </CFIF>

  </CFIF><!--- end if q_chkarchive.iARCHSTAT eq 1 --->
</CFIF>
