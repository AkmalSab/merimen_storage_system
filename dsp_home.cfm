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
<cfif IsDefined("URL.NEXTLOC")>
	<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\SETTOKEN.cfm" NONEXTLOC>
	<CFLOCATION URL="#URL.NEXTLOC#&#REQUEST.MTOKEN#" ADDTOKEN="no">
</cfif>

<!--- #25461 START--->
<cfif IsDefined("SESSION.VARS.GCOID")>
	<cfif NOT(IsDefined("SESSION.VARS.SETLOGIN") AND SESSION.VARS.SETLOGIN is 9)>
		<cfif SESSION.VARS.GCOID EQ 706183>
			<cfquery NAME=upd_setlogin DATASOURCE=#Request.MTRDSN#>
			UPDATE sec0001 SET siSETLOGIN=9
			WHERE iCOID=<cfqueryparam value="#session.vars.GCOID#" cfsqltype="CF_SQL_NVARCHAR">
			and iUSID=<cfqueryparam value="#session.vars.USID#" cfsqltype="CF_SQL_INTEGER">
			and siROLE=27
			</cfquery>
			<cflock SCOPE="SESSION" Type="Exclusive" TimeOut=60>
				<CFIF NOT StructKeyExists(SESSION.VARS,"SETLOGIN")>
					<CFSET StructInsert(SESSION.VARS,"SETLOGIN",9)>
				<CFELSE>
					<CFSET StructUpdate(SESSION.VARS,"SETLOGIN",9)>
				</CFIF>
			</CFLOCK>
		</cfif>
	</cfif>
</cfif>
<cfif IsDefined("SESSION.VARS.SETLOGIN")>
	<cfset setlogin=SESSION.VARS.SETLOGIN>
<cfelse>
	<cfset setlogin=0>
</cfif>

<cfif setlogin is 9> <!--- Login to Customer Portal --->
	<cfquery NAME=q_cls DATASOURCE=#Request.MTRDSN#>
	SELECT TOP 1 cologo=a.vaLOGO,a.iLOCID,a.iGCOID,a.vaCOLOGICNAME,b.iBNCID,
	CASE WHEN b.iINSCOID IS NULL THEN b.iCOID ELSE b.iINSCOID END AS iINSCOID
	FROM sec0005 a WITH (NOLOCK)
	JOIN BIZ2017 b WITH (NOLOCK) ON a.iCOID=b.iCOID
	where a.iCOID=a.iGCOID and a.iCOID=<cfqueryparam value="#session.vars.GCOID#" cfsqltype="CF_SQL_NVARCHAR">
	</cfquery>
	<cfset langtag = "">
	<cfif q_cls.recordcount GT 0>
		<cfoutput query=q_cls>
		<cfif iLOCID eq 7><cfset langtag = "&lang=ID"></cfif>
		<CFLOCATION url="#request.webroot#index.cfm?fusebox=MTRcmt&fuseaction=dsp_claimantdtls_corp&INSCOID=#iINSCOID#&BNCID=#iBNCID#&MOBILE=1#langtag#&#Request.MToken#" ADDTOKEN="no">
		</cfoutput>
	</cfif>
</cfif>
<!--- #25461 END--->
<cfif IsDefined("SESSION.VARS.ORGTYPE")>
	<cfset orgtype = SESSION.VARS.ORGTYPE>
	<cfif orgtype is "R">
		<cfset Attributes.fusebox="MTRrepairer">
	<cfelseif orgtype is "I">
		<cfset Attributes.fusebox="MTRinsurer">
	<cfelseif orgtype is "A">
		<cfset Attributes.fusebox="MTRadjuster">
	<cfelseif orgtype is "D">
		<cfset Attributes.fusebox="MTRdev">
	<cfelseif orgtype is "P" OR orgtype is "G" OR orgtype is "GR" or orgtype IS "L" OR orgtype IS "EA">
		<cfset Attributes.fusebox="MTRother">
	<cfelseif orgtype is "S">
		<cfset Attributes.fusebox="MTRsupplier">
	<cfelseif orgtype is "M">
		<cfset Attributes.fusebox="MTRcpc">
	<cfelseif orgtype is "RG">
		<cfset Attributes.fusebox="MTRregulator">
	<cfelse>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="Unidentified Company Type">
	</cfif>
	<cfset Attributes.Fuseaction="dsp_main">
	<cfparam Name=Attributes.SETLOGIN DEFAULT="">
	<cfparam Name=Attributes.SETPERSONAL DEFAULT="">
	<CFIF ISDEFINED("SESSION.VARS.SETPERSONAL") AND ISDEFINED("SESSION.VARS.USID") AND Attributes.SETPERSONAL NEQ "" AND Attributes.SETPERSONAL NEQ SESSION.VARS.SETPERSONAL>
		<cflock SCOPE=SESSION Type=Exclusive TimeOut=60>
			<CFSET SESSION.VARS.SETPERSONAL=Attributes.SETPERSONAL>
		</CFLOCK>
		<cfset Attributes.Personal=Attributes.SETPERSONAL>
		<!--- @CFLintIgnore CFQUERYPARAM_REQ --->
		<CFQUERY NAME=q_trx DATASOURCE=#Application.MTRDSN#>
		UPDATE SEC0001 SET siSETLOGIN=(siSETLOGIN % 10) + #SESSION.VARS.SETPERSONAL * 1000# WHERE iUSID=<cfqueryparam cfsqltype="cf_sql_integer" value="#session.vars.usid#">
		</CFQUERY>
	<CFELSEIF ISDEFINED("SESSION.VARS.SETPERSONAL")>
		<CFSET Attributes.SETPERSONAL=SESSION.VARS.SETPERSONAL>
		<cfset Attributes.Personal=SESSION.VARS.SETPERSONAL>
	</CFIF>
	<cfmodule TEMPLATE="#request.logpath#index.cfm" AttributeCollection=#Attributes#>
	<!---cfif IsDefined("Attributes.LASTLOGON")>
		<cfmodule TEMPLATE="#request.logpath#index.cfm" FUSEBOX=#Attributes.Fusebox# LASTLOGON=#Attributes.LASTLOGON# FUSEACTION=dsp_main SETLOGIN="#Attributes.SETLOGIN#">
	<cfelse>
		<cfmodule TEMPLATE="#request.logpath#index.cfm" FUSEBOX=#Attributes.Fusebox# FUSEACTION=dsp_main SETLOGIN="#Attributes.SETLOGIN#">
	</cfif--->
	<!--- Sets default language here --->
	<!---<cfif NOT IsDefined("SESSION.VARS.LANGSET")>
		<cfset SESSION.VARS.LANGSET=1>
		<cfif SESSION.VARS.LOCID IS 7><!--- Indonesia --->
			<cfmodule TEMPLATE="#request.logpath#index.cfm" FUSEBOX=MTRroot FUSEACTION=act_setlanguage LANG=2 REFERRER="#CGI.SCRIPT_NAME#?#CGI.QUERY_STRING#">
		</cfif>
	</cfif>--->
<cfelse>
	<cfthrow TYPE="EX_SECFAILED" ErrorCode="NOLOGIN">
</cfif>
