<!---
FILENAME : CLAIMS/root/dsp_login.cfm
DESCRIPTION :
Generate the login page (first page upon entry).

INPUT/ATTR: UserID - Pre-fill UserID field in login [ for login retries ].
RetryID - The no of tries for displaying error message.

OUTPUT : None.

CREATED BY : Andrew
CREATED ON : 12 Oct 2002

REVISION HISTORY
BY          ON          REMARKS
=========   ==========  ======================================================================================
--->

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
<CFSET APPNAME=Application.ApplicationName>
<CFSET APPLOCID=Application.APPLOCID>

<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\MTRHEADER.cfm" nolayout>
<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCADDFILE.cfm" FNAME="SVCLOGIN">


<cfoutput>
	<script>
		var retryid = #ARGUMENTS.retryid#;
		var userid = "";
		<cfset currenttime="#DateFormat(now(),'mm/dd/yyyy')# #TimeFormat(now(),'HH:mm:ss')#">
		<cfset nonce=ToBase64(currenttime&Hash(currenttime&"boo$ga56"))><!--- that is our private key --->
	</script>
</cfoutput>
<cfoutput>
	<div style="padding:16px">
		<table cellpadding=0 cellspacing=0 border=0>
			<tr>
				<td width=28% valign=top>
					<table cellpadding=0 cellspacing=0 width=100% border=0>
						<tr>
							<td valign=top>
								<!--- Login Box --->
								<script>SkinBorderBegin(11,null,"100%","")</script>
								<br>
								<script>
									<!--- <CFIF GIARMC>var JSGIARMC = #GIARMC#;</CFIF> --->
									JSVCDoLogin("#nonce#",5*60*1000,"fusebox=itk&fuseaction=act_login");
								</script>
								<br style="line-height:16px">
								<script>SkinBorderEnd(11);</script>
								<br style="line-height:5px">
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
</cfoutput>

