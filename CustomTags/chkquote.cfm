<cfsilent>
<cfparam name="Attributes.COID" default="">
<cfparam name="Attributes.ESID" default="">
<cfparam name="Attributes.ChkOrgType" default="">
<cfparam name="Attributes.ChkCoID" default=0>
<cfparam name="Attributes.ChkStatus" default="">
<cfparam name="Attributes.NOCOOKIE" default=1>
<cfparam name="Attributes.ChkMain" default=0>
<cfif Attributes.CHKCOID IS "on"><cfset Attributes.ChkCoID=1></cfif>
<CFSET Request.DS.FN.SVCsessionChk()>
<!---cfif NOT IsDefined("SESSION.VARS.USERID")>
	<cfthrow TYPE="EX_SECFAILED" ErrorCode="NOLOGIN">
</cfif>
<cfif IsDefined("URL.USID")>
	<cfif URL.USID IS NOT SESSION.VARS.USID>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="USRMISMATCH">
	</cfif>
<cfelse>
	<cfthrow TYPE="EX_SECFAILED" ErrorCode="USRMISMATCH">
</cfif>
<cfif Attributes.NOCOOKIE IS 0>
	<!--- To allow multiple user accounts login in a single computer --->
	<cfif IsDefined("COOKIE.MACID")>
		<cfif NOT IsDefined("SESSION.VARS.MACID") OR (SESSION.VARS.MACID IS NOT COOKIE.MACID)>
			<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCLI">
		</cfif>
	<cfelse>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCLI">
	</cfif>
</cfif--->
<cfset Caller.ORGTYPE=SESSION.VARS.ORGTYPE>
<cfswitch expression="#Caller.ORGTYPE#">
	<cfcase value="I">
		<cfset Caller.ORGROLE="1">
	</cfcase>
	<cfcase value="S">
		<cfset Caller.ORGROLE="2">
	</cfcase>
	<cfcase value="R">
		<cfset Caller.ORGROLE="4">
	</cfcase>
	<cfdefaultcase>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO" ExtendedInfo="Invalid COROLE">
	</cfdefaultcase>
</cfswitch>
<cfset Caller.ORGID=SESSION.VARS.ORGID>
<cfset Caller.ORGNAME=SESSION.VARS.ORGNAME>
<cfif SESSION.VARS.CHILDCOACCESS IS 1 AND StructKeyExists(Request.DS.CO,SESSION.VARS.ORGID) AND StructKeyExists(Request.DS.CO[SESSION.VARS.ORGID],"CHCOLIST")>
	<cfset CHILDLIST=Request.DS.CO[SESSION.VARS.ORGID].CHCOLIST>
<cfelse>
	<cfset CHILDLIST=SESSION.VARS.ORGID>
</cfif>
<cfif Attributes.ChkOrgType IS NOT "">
	<cfset Attributes.ChkOrgType=",#Attributes.ChkOrgType#,">
	<cfif Len(Caller.OrgType) GT 0>
		<cfif Find(",#Caller.Orgtype#,",Attributes.ChkOrgType) LTE 0>
			<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
		</cfif>
	<cfelse>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
	</cfif>
</cfif>
<!--- Check case exists --->
<cfif Attributes.ESID IS NOT "">
	<CFIF NOT IsNumeric(Attributes.ESID)>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCASE" ExtendedInfo="Invalid ESID format">
	</CFIF>
	<cfset doquery=1>
<cfelse>
	<cfset doquery=0>
</cfif>

<cfif doquery IS 1>
	<cfif Caller.ORGTYPE IS "S">
		<cfquery name="q_caseinfo" datasource=#Request.MTRDSN#>
		SELECT a.iESID,COID=a.iSCOID,CSTAT=a.siESSTAT,i.iMAINCASEID,ESFLAG=a.iESFLAG,a.iMESID,a.siATTENDED, r.iBASECURRID, r.nRATELOCALPERBASE, r.ilocid
		FROM ESC0001 a WITH (NOLOCK)
		INNER JOIN TRX0008 i WITH (NOLOCK) ON i.iCASEID=a.iOBJID AND a.iDOMAINID=1
		INNER JOIN TRX0001 r with (nolock) ON r.icaseid=i.icaseid
		WHERE a.iESID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.ESID#"> AND a.iSCOID IN (<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CHILDLIST#" list="yes">)
		<cfif Attributes.ChkMain IS 1>
			AND a.iMESID=a.iESID
		</cfif>
		AND a.siSTATUS=0 AND ISNULL(a.siEMCS,0)!=1
		</cfquery>
	<cfelseif Caller.ORGTYPE IS "I">
		<cfquery name="q_caseinfo" datasource=#Request.MTRDSN#>
		SELECT a.iESID,COID=i.iCOID,CSTAT=a.siESSTAT,i.iMAINCASEID,ESFLAG=a.iESFLAG,a.iMESID,a.siATTENDED, r.iBASECURRID, r.nRATELOCALPERBASE, r.ilocid
		FROM ESC0001 a WITH (NOLOCK)
			INNER JOIN TRX0008 i WITH (NOLOCK) ON i.iCASEID=a.iOBJID AND a.iDOMAINID=1
			INNER JOIN TRX0001 r with (nolock) ON r.icaseid=i.icaseid
		WHERE a.iESID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.ESID#"> AND i.iCOID IN (<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CHILDLIST#" list="yes">)
		<cfif Attributes.ChkMain IS 1>
			AND a.iMESID=a.iESID
		</cfif>
		AND a.siSTATUS=0
		</cfquery>
	<cfelseif Caller.ORGTYPE IS "R">
		<cfquery name="q_caseinfo" datasource=#Request.MTRDSN#>
		SELECT a.iESID,COID=r.iCOID,CSTAT=a.siESSTAT,iMAINCASEID=r.iMCASEID,ESFLAG=a.iESFLAG,a.iMESID,a.siATTENDED, r.iBASECURRID, r.nRATELOCALPERBASE, r.ilocid
		FROM ESC0001 a WITH (NOLOCK)
			INNER JOIN TRX0001 r WITH (NOLOCK) ON r.iCASEID=a.iOBJID AND a.iDOMAINID=1
		WHERE a.iESID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.ESID#"> AND r.iCOID IN (<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CHILDLIST#" list="yes">)
		<cfif Attributes.ChkMain IS 1>
			AND a.iMESID=a.iESID
		</cfif>
		AND a.siSTATUS=0
		</cfquery>
	<cfelse>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
	</cfif>
	<cfif q_caseinfo.RecordCount IS NOT 1>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCASE">
	</cfif>
	<cfoutput query="q_caseinfo">
		<cfset Caller.ESID=iESID>
		<cfset Caller.MESID=iMESID>
		<cfif Attributes.COID IS "">
			<cfset Attributes.COID=COID>
			<cfset Caller.COID=COID>
		</cfif>
		<cfset Caller.CASESTATUS=CSTAT>
		<cfset Caller.MCASEID=iMAINCASEID>
		<cfset Caller.ESFLAG=ESFLAG>
		<cfset Caller.AttendedFlag=siATTENDED>
		
		<cfif iBASECURRID NEQ "">
			<cfset BASECURRENCYID=#iBASECURRID#>
			<cfset RATELOCALPERBASE=#nRATELOCALPERBASE#>
		<cfelse>
			<cfset BASECURRENCYID=request.ds.locales[ilocid].currencyID>
			<cfset RATELOCALPERBASE=1>
		</cfif>
	</cfoutput>
	<!--- Check status --->
	<cfif Len(Attributes.ChkStatus) GT 0>
		<cfset Attributes.ChkStatus=",#Attributes.ChkStatus#,">
		<cfset state=Caller.CASESTATUS>
		<cfif	Find(",~#Caller.ORGTYPE##state#,",Attributes.ChkStatus) GT 0 OR
				Find(",~#state#,",Attributes.ChkStatus) GT 0 OR
				(Find(",#state#,",Attributes.ChkStatus) LTE 0 AND
				Find(",#Caller.ORGTYPE##state#,",Attributes.ChkStatus) LTE 0 AND
				Find(",#Caller.ORGTYPE#,",Attributes.ChkStatus) LTE 0)>
			<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCSTAT">
		</cfif>
	</cfif>
</cfif>
<!--- Check company access --->
<cfif Caller.ORGTYPE IS NOT "D">
	<cfif Attributes.CHKCOID IS 1>
		<cfif Attributes.COID IS "SESSION">
			<cfset Attributes.COID=SESSION.VARS.ORGID>
		</cfif>
		<!--- Any company in childlist can access --->
		<cfif Find(",#Attributes.COID#,",",#CHILDLIST#,") GT 0>
		<cfelse>
			<!--- Mike: Bad Child Co access friendly message --->
			<cfif SESSION.VARS.CHILDCOACCESS IS 0>
				<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO" ExtendedInfo="Invalid Access or No Child Company Access">
			<cfelse>
				<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
			</cfif>
		</cfif>
	<cfelseif Attributes.ChkCOID IS 2>
		<cfif Attributes.COID IS NOT Caller.ORGID>
			<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
		</cfif>
	<cfelseif Attributes.ChkCOID IS 3>
		<!--- Allow if GCOID same --->
		<cfif Attributes.COID IS "" OR Attributes.COID LTE 0>
			<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
		<cfelseif Attributes.COID IS "SESSION">
			<cfset Attributes.COID=SESSION.VARS.ORGID>
		</cfif>
		<!--- Any company in childlist can access --->
		<cfif Find(",#Attributes.COID#,",",#childlist#,") GT 0>
		<cfelse>
			<!---cfif NOT((Caller.ORGTYPE IS "S") AND Request.DS.CO[Attributes.COID].GCOID IS SESSION.VARS.GCOID)>
				<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
			<cfelse>
				<cfset Caller.NOTCHILDCO=1>
			</cfif--->
		</cfif>
	</cfif>
</cfif>

<!--- default base currency ID --->
<cfif NOT Isdefined("BASECURRENCYID")><cfset BASECURRENCYID=#request.ds.locales[session.vars.locid].currencyID#><cfset RATELOCALPERBASE=1></cfif>
<cfset temp=#request.DS.FN.SVCCurrencyGenRequestVars(BASECURRENCYID,RATELOCALPERBASE)#>
</cfsilent>