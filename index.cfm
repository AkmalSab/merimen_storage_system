<!---CFTRY>
<!--- index.cfm of application root is special case - takes care of FUSEBOX too --->
<CFSET Attributes.CLMLOCK=""><CFSET BITTEST=2><CFSET CLMLOCKED=2>
<CFIF Attributes.CLMLOCK IS "" AND BITTEST GT 0 AND BitAnd(CLMLOCKED,BITTEST) GT 0>
	gaga
	<CFABORT>
</CFIF>
Also note that CFINCLUDE apps_global moved to application.cfm - no sense to call it every time we CFMODULE --->
<cfparam NAME="attributes.FUSEBOX" DEFAULT="">
<cfparam NAME="attributes.FUSEACTION" DEFAULT="">
<!--- If user preferred language not set, then set default language based on locale --->
<!--- <cfif request.inSession IS 0 AND attributes.FUSEACTION eq ""
		AND ListFind("7,15,17,11",Application.APPLOCID)>
	<cfset Request.DS.FN.SVClangSet("",5)><!--- Similar settings in \CustomTags\settoken.cfm and \index.cfm --->
</cfif> --->

<cfif isDefined("Attributes.UID") AND NOT StructKeyExists(SESSION,"SSO_UID") AND Attributes.FUSEACTION NEQ "act_login">
	<!--- Check if needed to recreate session, else show timeout error --->
	<cfmodule template="#Request.SSOPATH#?FUSEBOX=MRMRoot&ENVIRONMENT=1&MODE=2&#REQUEST.MTOKEN#">
</cfif>

<CFIF IsDefined("session.vars") AND StructKeyExists(session.vars,"LOGIN2FA") AND SESSION.VARS.LOGIN2FA IS 0>
	<cfif NOT(IsDefined("Request.FROMINTERGRATION") AND Request.FROMINTERGRATION EQ 1)
		AND NOT((attributes.FUSEBOX IS "MTRsec" AND ListFind("act_login,act_logout",attributes.FUSEACTION) GT 0)
		OR (attributes.FUSEBOX IS "MTRroot" AND ListFind("dsp_subscriberhelp",attributes.FUSEACTION) GT 0)
		OR (StructKeyExists(session.vars,"LOGINTYPE") AND listFindNoCase("1,2",SESSION.VARS.LOGINTYPE) GT 0)
		OR (attributes.FUSEBOX IS "MTRadmin" AND ListFind("dsp_csbar",attributes.FUSEACTION) GT 0)
		OR ListFind("SVCTwoFA,SVCQR,SVCsec",attributes.FUSEBOX) GT 0)>
			<cfset REQUEST.DS.FN.SVCChk2FA(1,1)>
			<cfexit method = "exitTemplate">
	</cfif>
</CFIF>

<!--- <CFIF request.inSession IS 1 AND SESSION.VARS.ORGTYPE IS "D" AND Left(Attributes.FUSEACTION,4) IS "act_" AND NOT(Attributes.FUSEACTION IS "act_logout" OR Attributes.FUSEACTION IS "act_setlogin" OR Attributes.FUSEACTION IS "act_2FAvalidation")>
	<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="740W">
	<CFIF CanWrite IS 1>
		<CFTHROW TYPE="EX_SECFAILED" ErrorCode="CANNOTWRITE" ExtendedInfo="You are denied from making any changes to the system.">
	</CFIF>
</CFIF> --->

<cfswitch EXPRESSION=#attributes.fusebox#>
    <cfcase VALUE="MTRroot,APProot">
        <cfparam NAME="attributes.FUSEACTION" DEFAULT="">
        <cfswitch EXPRESSION=#attributes.fuseaction#>
            <cfcase VALUE="dsp_clmheader">
                <cfinvoke component="claims.index" method="dsp_clmheader" ArgumentCollection=#Attributes#>
            </cfcase>
            <cfdefaultcase>
                <cfinvoke component="claims.index" method="dsp_login" ArgumentCollection=#Attributes#>

            </cfdefaultcase>
        </cfswitch>
    </cfcase>
    <cfdefaultcase>
        <cfinvoke component="index" method="dsp_login" ArgumentCollection=#Attributes#>
    </cfdefaultcase>
</cfswitch>
<!---CFCATCH><CFIF StructKeyExists(CFCATCH,"ERRORCODE")><CFSET REQUEST.CFERR_ERRORCODE=CFCATCH.ERRORCODE></CFIF><CFIF StructKeyExists(CFCATCH,"EXTENDEDINFO")><CFSET REQUEST.CFERR_EXTENDEDINFO=CFCATCH.EXTENDEDINFO></CFIF><CFRETHROW></CFCATCH>
</CFTRY--->