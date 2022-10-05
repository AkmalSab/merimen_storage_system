<cfsilent><!---CFSET Caller.secstatus=1--->
<cfparam name="Attributes.ExtID" default="">
<cfparam name="Attributes.CaseID" default="">
<cfparam name="Attributes.DomainID" default="1">
<cfparam name="Attributes.ChkOrgType" default="">
<cfparam name="Attributes.COID" default="">
<cfparam name="Attributes.COROLE" default="">
<cfparam name="Attributes.ChkCoID" default=0>
<cfparam name="Attributes.ChkStatus" default="">
<cfparam name="Attributes.ChkPEdit" default=0>
<cfparam name="Attributes.TPVIEW" default=0>
<cfparam name="Attributes.NOCOOKIE" default=0>
<cfparam name="Attributes.LIMITCODE" default="CLM">
<cfparam name="Attributes.SETBASECURRONLY" default="0"><!--- set as 1 if only interested in setting currency related details #23609 --->
<cfparam name="Attributes.ALLOWSUPP" default=0>

<CFSET Request.DS.FN.SVCsessionChk()>

<cfif Attributes.CHKCOID IS "on"><cfset Attributes.ChkCoID=1></cfif>
<cfif Attributes.CHKPEdit IS "on"><cfset Attributes.CHKPEdit=1></cfif>
<!---cfif Attributes.ChkCoID><cfset Attributes.ChkCoID=1></cfif--->
<cfif Attributes.TPVIEW IS ""><cfset Attributes.TPVIEW=1></cfif>
<!---CFIF Not IsDefined("SESSION.VARS") OR StructIsEmpty(Session.vars)--->
<cfif NOT StructKeyExists(Attributes,"CLMLOCK")>
	<cfif IsDefined("SESSION.VARS.LOGINTYPE") AND Session.VARS.LOGINTYPE GT 0>
		<cfset Attributes.CLMLOCK="">
	<cfelse>
		<cfset Attributes.CLMLOCK=0>
	</cfif>
</cfif>
<cfset BRACCESSLIST = "">
<cfset ADDITIONALJOIN = "">
<cfset ADDITIONALCLAUSE = "">
<!--- Check if client IP matches the session to prevent session stealing --->
<!---<CFIF SESSION.VARS.CLIADDR IS NOT "#CGI.REMOTE_ADDR#,#CGI.REMOTE_HOST#,#CGI.REMOTE_USER#">
	<CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCLI">
</cfif>--->

<!---cfif IsDefined("URL.USID")>
	<cfif URL.USID IS NOT SESSION.VARS.USID>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="USRMISMATCH">
	</cfif>
<cfelse>
	<cfthrow TYPE="EX_SECFAILED" ErrorCode="USRMISMATCH">
</cfif>
<CFIF StructKeyExists(SESSION.VARS,"IP") AND SESSION.VARS.IP IS NOT CGI.REMOTE_ADDR>
	<CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCLI">
</cfif--->

<!---CFIF IsDefined("Attributes.IsAdmin")>
	<CFIF Not IsDefined("SESSION.VARS.ADMIN")>
		<CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCO">
	</CFIF>
<CFELSE>
	<CFIF IsDefined("SESSION.VARS.ADMIN")>
		<CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCO">
	</CFIF>
</cfif--->
<!---CFSET Request.DS.FN.SVCsessionChk()--->
<!---cfif Attributes.NOCOOKIE IS 0>
	<!--- MIKE:Temporarily commented to allow multiple user accounts login in a single computer --->
	<!---cfif IsDefined("COOKIE.MACID")>
		<cfif Not IsDefined("SESSION.VARS.MACID") OR (SESSION.VARS.MACID IS NOT COOKIE.MACID)>
			<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCLI">
		</cfif>
	<cfelse>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCLI">
	</cfif--->
</cfif--->


<!---CFIF IsDefined("ATTRIBUTES.DEVIMPORGTYPE")	and SESSION.VARS.ORGTYPE IS "D">
	<CFSET Caller.orgtype = Attributes.DevImpOrgType>
	<CFIF Caller.orgtype IS "R">
		<CFSET Caller.cotypeid = 1>
		<CFQUERY name="q_cinfo" datasource=#Request.MTRDSN# maxrows=1>
		SELECT ORGNAME=b.vaCONAME+' ('+b.vaCOBRNAME+')',COID=b.iCOID FROM TRX0001 a WITH (NOLOCK),SEC0005 b WITH (NOLOCK) WHERE a.iCASEID=<cfqueryparam value="#Attributes.CaseID#" cfsqltype="CF_SQL_INTEGER"> AND a.iCOID=b.iCOID
		</CFQUERY>
	<CFELSEIF Caller.orgtype IS "I">
		<CFSET Caller.cotypeid = 2>
		<CFQUERY name="q_cinfo" datasource=#Request.MTRDSN# maxrows=1>
		SELECT ORGNAME=b.vaCONAME+' ('+b.vaCOBRNAME+')',COID=b.iCOID FROM TRX0008 a WITH (NOLOCK),SEC0005 b WITH (NOLOCK) WHERE a.iCASEID=<cfqueryparam value="#Attributes.CaseID#" cfsqltype="CF_SQL_INTEGER"> AND a.iCOID=b.iCOID AND a.siTPINS=0
		</CFQUERY>
	<CFELSEIF Caller.orgtype IS "A">
		<CFSET Caller.cotypeid = 3>
		<CFQUERY name="q_cinfo" datasource=#Request.MTRDSN# maxrows=1>
		SELECT ORGNAME=b.vaCONAME+' ('+b.vaCOBRNAME+')',COID=b.iCOID FROM TRX0002 a WITH (NOLOCK),SEC0005 b WITH (NOLOCK) WHERE a.iCASEID=<cfqueryparam value="#Attributes.CaseID#" cfsqltype="CF_SQL_INTEGER"> AND a.iCOID=b.iCOID
		</CFQUERY>
	<CFELSEIF Caller.orgtype IS "P">
		<CFSET Caller.cotypeid = 5>
		<CFQUERY name="q_cinfo" datasource=#Request.MTRDSN# maxrows=1>
		SELECT ORGNAME=b.vaCONAME+' ('+b.vaCOBRNAME+')',COID=b.iCOID FROM TRX0061 a WITH (NOLOCK),SEC0005 b WITH (NOLOCK) WHERE a.iCASEID=<cfqueryparam value="#Attributes.CaseID#" cfsqltype="CF_SQL_INTEGER"> AND a.iCOID=b.iCOID
		</CFQUERY>
	<CFELSE><CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCO">
	</cfif>
	<CFOUTPUT query="q_cinfo"><CFSET Caller.orgid = COID>
	<CFSET Caller.orgname = ORGNAME>
	</cfoutput>
	<!--- For the time being ... --->
	<cfset Childlist = "">
	<cfset Caller.Usrname = SESSION.VARS.USERID>
<CFELSE--->
	<cfset Caller.orgtype = SESSION.VARS.ORGTYPE>
	<cfset Caller.orgid = SESSION.VARS.ORGID>
	<cfset Caller.orgname = SESSION.VARS.ORGNAME>
	<cfif SESSION.VARS.CHILDCOACCESS IS 1 AND StructKeyExists(Request.DS.CO,SESSION.VARS.ORGID) AND StructKeyExists(Request.DS.CO[SESSION.VARS.ORGID],"CHCOLIST")>
		<cfset CHILDLIST=Request.DS.CO[SESSION.VARS.ORGID].CHCOLIST>
	<cfelse>
		<cfset CHILDLIST=SESSION.VARS.ORGID>
	</cfif>
	<!---cf_chkgrp GrpList="26R,27R,28R">
	<CFIF CanRead IS 0>
		<CFSET Childlist=SESSION.VARS.ORGID>
	<CFELSE>
		<CFSET Childlist=SESSION.VARS.CHCOLIST>
	</CFIF--->
	<cfset curuserid = SESSION.VARS.USERID>
	<!---CFIF IsDefined("SESSION.VARS.MAILLIST")>
		<CFSET Caller.maillist = SESSION.VARS.MAILLIST>
	</cfif--->
<!---/CFIF--->
<!--- Check organization type --->
<cfif Attributes.ChkOrgType IS NOT "">
	<cfset Attributes.ChkOrgType=","&Attributes.ChkOrgType&",">
	<cfif Len(Caller.OrgType) GT 0>
		<cfif Find(",#Caller.Orgtype#,",Attributes.ChkOrgType) LTE 0>
			<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
		</cfif>
	<cfelse>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
	</cfif>
</cfif>

<!--- For Cotype=P, check if need to ChkPEdit, and check if associated with a repairer --->
<CFIF Caller.ORGTYPE IS "P">
	<CFSET GCOID=SESSION.VARS.GCOID>
	<CFSET PASC_CLAIM=0>
	<!--- For P make sure associated with repairer group --->
	<CFIF StructKeyExists(Request.DS.CO[GCOID],"PASCCOID")>
		<CFSET PASCCOID=Request.DS.CO[GCOID].PASCCOID>
		<CFSET PASCCOTYPEID=Request.DS.CO[GCOID].PASCCOTYPEID>
		<CFIF PASCCOTYPEID IS 1>
			<CFSET PASC_CLAIM=1>
		</CFIF>
	<CFELSEIF StructKeyExists(Request.DS.CO[GCOID],"SUBCOTYPE") AND Request.DS.CO[GCOID].SUBCOTYPE IS 8>
		<CFSET PASC_CLAIM=1>
		<CFSET PASCCOID=0>
		<CFSET PASCCOTYPEID=0>
	<CFELSE>
		<CFSET PASCCOID=0>
		<CFSET PASCCOTYPEID=0>
	</CFIF>
	<!--- <CFIF PASC_CLAIM IS 0 AND Attributes.ChkPEdit IS 1>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCASE" ExtendedInfo="No authority to create/edit">
	</CFIF> --->
	<CFSET Caller.PASCCOID=PASCCOID>
	<CFSET Caller.PASCCOTYPEID=PASCCOTYPEID>
	<CFSET Caller.PASC_CLAIM=PASC_CLAIM>
</CFIF>

<!--- Check case exists --->
<cfif Attributes.CASEID IS NOT "">
	<CFIF Not IsNumeric(Attributes.CASEID)>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCASE" ExtendedInfo="Invalid CaseID format">
	</CFIF>
	<CFIF Attributes.ExtID IS NOT "" AND Not IsNumeric(Attributes.ExtID)>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCASE" ExtendedInfo="Invalid ID format">
	</CFIF>
	<cfif Caller.orgtype IS "P" OR Caller.orgtype IS "G" OR Caller.orgtype IS "GR" OR Caller.orgtype IS "L" OR Caller.orgtype IS "EA">
		<CFIF Attributes.ExtID IS NOT "" AND Attributes.ExtID IS NOT 0>
			<cfset queryclause = "b.iCASEID=#Attributes.CaseID# AND b.iASCCASEID=#Attributes.ExtID#">
		<CFELSE>
			<cfset queryclause = "b.iCASEID=#Attributes.CaseID# AND b.iCOID IN (#childlist#)">
		</CFIF>
	<cfelseif caller.orgtype IS "A">
		<CFIF Attributes.ExtID IS NOT "" AND Attributes.ExtID IS NOT 0>
			<cfset queryclause = "a.iCASEID=#Attributes.CaseID# AND a.iADJCASEID=#Attributes.ExtID#">
		<CFELSE>
			<cfset queryclause = "a.iCASEID=#Attributes.CaseID#">
		</CFIF>
	<cfelseif caller.orgtype IS "I">
		<CFIF Attributes.ExtID IS NOT "" AND Attributes.ExtID IS NOT 0 AND attributes.DOMAINID IS 1>
			<cfset queryclause = "a.iCASEID=#Attributes.CaseID# AND a.iINSCASEID=#Attributes.ExtID#">
		<CFELSE>
			<cfset queryclause = "a.iCASEID=#Attributes.CaseID#">
		</CFIF>
	<cfelseif caller.orgtype IS "S" AND Attributes.DomainID IS 6><!--- <!--- #24583: [MY] Esource - Activate Associated Mail feature  ---> --->
		<CFIF Attributes.ExtID IS NOT "" AND Attributes.ExtID IS NOT 0>
			<cfset queryclause = "a.iCASEID=#Attributes.CaseID# AND b.iESID=#Attributes.ExtID#">
		<CFELSE>
			<cfset queryclause = "a.iCASEID=#Attributes.CaseID#">
		</CFIF>
	<CFELSE>
		<cfset queryclause = "a.iCASEID=#Attributes.CaseID#">
	</cfif>
	<cfset doquery = 1>
<cfelseif Attributes.ExtID IS NOT "">
	<CFIF Not IsNumeric(Attributes.ExtID)>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCASE" ExtendedInfo="Invalid ID format">
	</CFIF>
	<cfif Caller.orgtype IS "R">
		<cfset queryclause = "a.iCASEID=#Attributes.ExtID#">
	<cfelseif Caller.orgtype IS "A">
		<cfset queryclause = "a.iADJCASEID=#Attributes.ExtID#">
	<cfelseif Caller.orgtype IS "P" OR Caller.orgtype IS "G" OR Caller.orgtype IS "GR" OR Caller.orgtype IS "L" OR Caller.orgtype IS "EA">
		<cfset queryclause = "b.iCASEID=#Attributes.ExtID# AND b.iCOID IN (#childlist#)">
	<cfelseif Caller.orgtype IS "S">
		<cfset queryclause = "b.iESID=#Attributes.ExtID#"><!--- #24583: [MY] Esource - Activate Associated Mail feature  --->
	<cfelse>
		<cfset queryclause = "a.iINSCASEID=#Attributes.ExtID#">
	</cfif>
	<cfset doquery = 1>
<cfelse>
	<cfset doquery = 0>
</cfif>

<cfif doquery IS 1>

	<cfif SESSION.VARS.GCOID IS 640000>
		<cfset ADDITIONALJOIN = "INNER JOIN FSSO_0001 SSO_MAPPING WITH (NOLOCK) ON SSO_MAPPING.iCOID = b.iCOID AND SSO_MAPPING.siSTATUS = 0">
		<cfset ADDITIONALCLAUSE = "SSO_MAPPING.iUSID = #SESSION.VARS.USID#">
	</cfif>

	<cfif Caller.orgtype IS "R">
		<!--- @CFLintIgnore CFQUERYPARAM_REQ --->
		<cfquery name="q_caseinfo" datasource=#Request.MTRDSN#>
		SELECT dMCASEID=CASE WHEN a.iPCASEID>0 THEN a.iPCASEID ELSE a.iCASEID END,a.siOWNFLAG,a.siCRTOWNFLAG,aCLAIMTYPE=RTrim(a.aCLAIMTYPE),a.iCLMTYPEMASK,iSUBCLMTYPEMASK=ISNULL(a.iSUBCLMTYPEMASK,0),
		<!---cfif IsDefined("Attributes.GETINFOSTR")>a.vaREGNO,a.vaINSUREDNAME,</cfif--->
		extid=a.iCASEID,a.iCASEID,a.iCOID,CSTAT=a.siCSTAT,siDTLCRT=IsNull(a.siDTLCRT,0),iCLMLOCKED=IsNull(a.iCLMLOCKED,0),
		a.iBASECURRID, a.nRATELOCALPERBASE, <!--- a.iTERMCURRID, a.nRATETERMPERBASE, ---> a.ilocid,a.iINSCOID
		FROM TRX0001 a WITH (NOLOCK) WHERE <!--- @CFIGNORESQL_S --->#queryclause#<!--- @CFIGNORESQL_E ---> AND a.siSTATUS=0
		</cfquery>
	<cfelseif Caller.orgtype IS "S" AND Attributes.ExtID IS NOT "" AND Attributes.ExtID GT 0 AND Attributes.DomainID IS 6>
		<!--- @CFLintIgnore CFQUERYPARAM_REQ --->
		<cfquery name="q_caseinfo" datasource=#Request.MTRDSN#>
		SELECT dMCASEID=CASE WHEN a.iPCASEID>0 THEN a.iPCASEID ELSE a.iCASEID END,a.siOWNFLAG,a.siCRTOWNFLAG,aCLAIMTYPE=RTrim(a.aCLAIMTYPE),a.iCLMTYPEMASK,iSUBCLMTYPEMASK=ISNULL(a.iSUBCLMTYPEMASK,0),
		extid=b.iESID,a.iCASEID,a.iCOID,CSTAT=a.siCSTAT,siDTLCRT=IsNull(a.siDTLCRT,0),iCLMLOCKED=IsNull(a.iCLMLOCKED,0),
		a.iBASECURRID, a.nRATELOCALPERBASE,  a.ilocid,a.iINSCOID
		FROM TRX0001 a WITH (NOLOCK) LEFT JOIN ESC0001 b WITH (NOLOCK) on b.iDOMAINID=1 AND a.iCASEID=b.iOBJID
		WHERE <!--- @CFIGNORESQL_S --->#queryclause#<!--- @CFIGNORESQL_E ---> AND a.siSTATUS=0
		</cfquery>
	<cfelseif Caller.orgtype IS "A">
		<!--- @CFLintIgnore CFQUERYPARAM_REQ --->
		<cfquery name="q_caseinfo" datasource=#Request.MTRDSN#>
		SELECT dMCASEID=CASE WHEN b.iPCASEID>0 THEN b.iPCASEID ELSE a.iCASEID END,b.siOWNFLAG,b.siCRTOWNFLAG,aCLAIMTYPE=RTrim(b.aCLAIMTYPE),a.iCLMTYPEMASK,iSUBCLMTYPEMASK=ISNULL(b.iSUBCLMTYPEMASK,0),
		<!---cfif IsDefined("Attributes.GETINFOSTR")>b.vaREGNO,b.vaINSUREDNAME,</cfif--->
		<cfif IsDefined("Attributes.GetCaseUser")>a.vaMGRNAME,a.vaADJNAME,a.vaASSNAME,</cfif>
		extid=a.iADJCASEID,a.iCASEID,a.iCOID,a.iINPCOID,CSTAT=a.siCSTAT,siDTLCRT=IsNull(a.siDTLCRT,0),iCLMLOCKED=IsNull(b.iCLMLOCKED,0),
		b.iBASECURRID, b.nRATELOCALPERBASE, <!--- b.iTERMCURRID, b.nRATETERMPERBASE, ---> b.ilocid,b.iINSCOID
		,iADJROLETYPE=IsNull(a.iADJROLETYPE,1),a.aEST_COTYPE,a.iMULTIASSIGN,PADJCASEID=IsNull(NullIf(a.iPADJCASEID,0),a.iADJCASEID)
		FROM TRX0002 a WITH (NOLOCK),TRX0001 b WITH (NOLOCK) WHERE <!--- @CFIGNORESQL_S --->#queryclause#<!--- @CFIGNORESQL_E ---> AND a.siSTATUS=0 AND a.iCASEID=b.iCASEID AND ISNULL(a.siEMCS,0)!=1
		</cfquery>
	<cfelseif Caller.orgtype IS "I">
		<!--- @CFLintIgnore CFQUERYPARAM_REQ --->
		<cfquery name="q_caseinfo" datasource=#Request.MTRDSN#>
			<cfif attributes.tpview IS 1>
			SELECT dMCASEID=CASE WHEN b.iPCASEID>0 THEN b.iPCASEID ELSE b.iCASEID END,b.siOWNFLAG,b.siCRTOWNFLAG,aCLAIMTYPE=RTrim(b.aCLAIMTYPE),iSUBCLMTYPEMASK=ISNULL(b.iSUBCLMTYPEMASK,0),siDTLCRT=IsNull(a.siDTLCRT,0),
			<!---cfif IsDefined("Attributes.GETINFOSTR")>b.vaREGNO,b.vaINSUREDNAME,</cfif--->
			<cfif StructKeyExists(Attributes,"GetCaseUser")>a.vaASSNAME,a.vaOWNER,a.vaMGRNAME,a.vaINADJNAME,</cfif>
			extid=a.iINSCASEID,a.iCASEID,iCOID=IsNull(t.iCOID,a.i3inscoid),CSTAT=IsNull(t.siCSTAT,a.siCSTAT),TPKFKSTAT=IsNull(a.iTPKFKSTAT,0),iCLMLOCKED=IsNull(b.iCLMLOCKED,0),a.iCLMTYPEMASK,
			b.iBASECURRID, b.nRATELOCALPERBASE, <!--- b.iTERMCURRID, b.nRATETERMPERBASE, ---> b.ilocid,b.iINSCOID
			FROM TRX0008 a WITH (NOLOCK) LEFT JOIN TRX0008 t WITH (NOLOCK) ON a.iMAINCASEID=t.iCASEID AND t.siTPINS=1,TRX0001 b WITH (NOLOCK)
			WHERE <!--- @CFIGNORESQL_S --->#queryclause#<!--- @CFIGNORESQL_E ---> AND a.siTPINS=0 AND a.siSTATUS=0 AND a.iCASEID=b.iCASEID
			<cfelseif attributes.tpview IS 2>
			SELECT dMCASEID=CASE WHEN b.iPCASEID>0 THEN b.iPCASEID ELSE b.iCASEID END,b.siOWNFLAG,b.siCRTOWNFLAG,aCLAIMTYPE=RTrim(b.aCLAIMTYPE),iSUBCLMTYPEMASK=ISNULL(b.iSUBCLMTYPEMASK,0),siDTLCRT=IsNull(a.siDTLCRT,0),iCLMLOCKED=IsNull(b.iCLMLOCKED,0),
			<!---cfif IsDefined("Attributes.GETINFOSTR")>b.vaREGNO,b.vaINSUREDNAME,</cfif--->
			<cfif StructKeyExists(Attributes,"GetCaseUser")>a.vaASSNAME,a.vaOWNER,a.vaMGRNAME,a.vaINADJNAME,</cfif>
			extid=a.iINSCASEID,a.iCASEID,
			iCOID=a.iCOID,CSTAT=a.siCSTAT,iCOID3=a.i3INSCOID,CSTAT3=IsNull(t.siCSTAT,a.siCSTAT),TPKFKSTAT=IsNull(a.iTPKFKSTAT,0),a.iCLMTYPEMASK,
			b.iBASECURRID, b.nRATELOCALPERBASE, <!--- b.iTERMCURRID, b.nRATETERMPERBASE, ---> b.ilocid,b.iINSCOID
			FROM TRX0008 a WITH (NOLOCK) LEFT JOIN TRX0008 t WITH (NOLOCK) ON a.iMAINCASEID=t.iCASEID AND t.siTPINS=1,TRX0001 b WITH (NOLOCK)
			WHERE <!--- @CFIGNORESQL_S --->#queryclause#<!--- @CFIGNORESQL_E ---> AND a.siTPINS=0 AND a.siSTATUS=0 AND a.iCASEID=b.iCASEID
			<cfelse>
			SELECT dMCASEID=CASE WHEN b.iPCASEID>0 THEN b.iPCASEID ELSE a.iCASEID END,b.siOWNFLAG,b.siCRTOWNFLAG,aCLAIMTYPE=RTrim(b.aCLAIMTYPE),iSUBCLMTYPEMASK=ISNULL(b.iSUBCLMTYPEMASK,0),siDTLCRT=IsNull(a.siDTLCRT,0),iCLMLOCKED=IsNull(b.iCLMLOCKED&2,0),
			<!---cfif IsDefined("Attributes.GETINFOSTR")>b.vaREGNO,b.vaINSUREDNAME,</cfif--->
			<cfif StructKeyExists(Attributes,"GetCaseUser")>a.vaASSNAME,a.vaOWNER,a.vaMGRNAME,a.vaINADJNAME,</cfif>
			extid=a.iINSCASEID,a.iCASEID,a.iCOID,CSTAT=a.siCSTAT,TPKFKSTAT=IsNull(a.iTPKFKSTAT,0),a.iCLMTYPEMASK,
			b.iBASECURRID, b.nRATELOCALPERBASE, <!--- b.iTERMCURRID, b.nRATETERMPERBASE, ---> b.ilocid,b.iINSCOID
			FROM TRX0008 a WITH (NOLOCK),TRX0001 b WITH (NOLOCK) WHERE <!--- @CFIGNORESQL_S --->#queryclause#<!--- @CFIGNORESQL_E ---> AND a.siTPINS=0 AND a.siSTATUS=0 AND a.iCASEID=b.iCASEID
			</cfif>
		</cfquery>
		<cfquery name="q_braccesslist" datasource=#Request.MTRDSN#>
		select iCOID from TRX_BRACCESS with (NOLOCK) where iCASEID=<cfqueryparam cfsqltype="cf_sql_integer" value="#Attributes.CaseID#">
		</cfquery>
		<cfif q_braccesslist.recordCount gt 0>
			<cfset braccesslist = valuelist(q_braccesslist.iCOID)>
		</cfif>
	<cfelseif Caller.orgtype IS "P" OR Caller.orgtype IS "G" OR Caller.orgtype IS "GR" OR Caller.orgtype IS "L" OR Caller.orgtype IS "EA">
		<!--- @CFLintIgnore CFQUERYPARAM_REQ --->
		<cfquery name="q_caseinfo" datasource=#Request.MTRDSN# maxrows=1>
		SELECT dMCASEID=CASE WHEN a.iPCASEID>0 THEN a.iPCASEID ELSE a.iCASEID END,a.siOWNFLAG,a.siCRTOWNFLAG,aCLAIMTYPE=RTrim(a.aCLAIMTYPE),iSUBCLMTYPEMASK=ISNULL(a.iSUBCLMTYPEMASK,0),iCLMLOCKED=0,
		<!---cfif IsDefined("Attributes.GETINFOSTR")>a.vaREGNO,a.vaINSUREDNAME,</cfif--->
		extid=b.iASCCASEID,a.iCASEID,b.iCOID,CSTAT=IsNull(b.siCSTAT,a.siCSTAT),siDTLCRT=IsNull(a.siDTLCRT,0),b.iCOROLE,iCLMTYPEMASK=NULL,
		a.iBASECURRID, a.nRATELOCALPERBASE, <!--- a.iTERMCURRID, a.nRATETERMPERBASE, ---> a.ilocid,a.iINSCOID
		FROM TRX0061 b WITH (NOLOCK)
			<!--- @CFIGNORESQL_S --->#ADDITIONALJOIN#<!--- @CFIGNORESQL_E --->
			,TRX0001 a WITH (NOLOCK) 
		WHERE <!--- @CFIGNORESQL_S --->#queryclause#<!--- @CFIGNORESQL_E ---> AND a.siSTATUS=0 AND a.iCASEID=b.iCASEID
		<CFIF Attributes.COROLE IS NOT "" AND Attributes.COROLE IS NOT 0>
				AND b.iCOROLE=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.COROLE#">
		</CFIF>
		<CFIF ADDITIONALCLAUSE NEQ "">
			AND <!--- @CFIGNORESQL_S --->#ADDITIONALCLAUSE#<!--- @CFIGNORESQL_E --->
		</CFIF>
		</cfquery>
		<cfif q_caseinfo.recordcount IS 0>
			<!--- @CFLintIgnore CFQUERYPARAM_REQ --->
			<cfquery name="q_caseinfo" datasource=#Request.MTRDSN# maxrows=1>
			SELECT dMCASEID=CASE WHEN a.iPCASEID>0 THEN a.iPCASEID ELSE a.iCASEID END,a.siOWNFLAG,a.siCRTOWNFLAG,aCLAIMTYPE=RTrim(a.aCLAIMTYPE),iSUBCLMTYPEMASK=ISNULL(a.iSUBCLMTYPEMASK,0),
			<!---cfif IsDefined("Attributes.GETINFOSTR")>a.vaREGNO,a.vaINSUREDNAME,</cfif--->
			extid=b.iASCCASEID,a.iCASEID,b.iCOID,CSTAT=IsNull(b.siCSTAT,a.siCSTAT),siDTLCRT=IsNull(a.siDTLCRT,0),b.iCOROLE,iCLMTYPEMASK=NULL,
			a.iBASECURRID, a.nRATELOCALPERBASE, <!--- a.iTERMCURRID, a.nRATETERMPERBASE, ---> a.ilocid,a.iINSCOID
			FROM TRX0061 b WITH (NOLOCK),TRX0001 a WITH (NOLOCK) WHERE <!--- @CFIGNORESQL_S --->#queryclause#<!--- @CFIGNORESQL_E ---> AND a.siSTATUS=0 AND a.iPCASEID=b.iCASEID
			</cfquery>
		</cfif>
	<cfelse>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
	</cfif>

	<cfset CASELOCID=q_caseinfo.ilocid>
	<cfif q_caseinfo.RecordCount IS NOT 1>
		<CFIF Attributes.EXTID neq "" and Attributes.EXTID GT 0>
    	<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags/CHKARCHIVE.cfm" CASEID="#Attributes.CASEID#" CHKCASE=1 EXTID=#Attributes.EXTID#>
		<CFELSE>
			<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags/CHKARCHIVE.cfm" CASEID="#Attributes.CASEID#" CHKCASE=1>
		</CFIF>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCASE">
	</cfif>
	<cfoutput query="q_caseinfo">
	<cfif StructKeyExists(Attributes,"NoSupp") AND Attributes.ALLOWSUPP IS 0 AND dMCASEID IS NOT iCASEID AND attributes.SETBASECURRONLY neq 1>
		<!--- Disable supplementaries --->
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCASE" EXTENDEDINFO="Action not allowed for supplementaries">
	</cfif>

	<CFSET CLMTYPEMASK=iCLMTYPEMASK>
	<cfset caller.extid = EXTID>
	<cfset Caller.CASEID = iCASEID>
	<cfset Caller.MCASEID = dMCASEID>
	<cfset Caller.CLMFLOW=Left(aCLAIMTYPE,2)>
	<cfset Caller.claimtype = aCLAIMTYPE>
	<cfset Caller.SUBCLMTYPEMASK = iSUBCLMTYPEMASK>
	<cfset Caller.ownflag = siOWNFLAG>
	<cfset Caller.crtownflag = siCRTOWNFLAG>
	<CFIF Caller.ORGTYPE IS "P" AND siOWNFLAG IS 1 AND PASC_CLAIM GT 0 AND PASCCOID IS 0>
		<CFSET PASC_CLAIM=0>
		<CFSET Caller.PASC_CLAIM=0>
	</CFIF>
	<cfif iBASECURRID NEQ "">
		<cfset BASECURRENCYID=#iBASECURRID#>
		<cfset RATELOCALPERBASE=#nRATELOCALPERBASE#>
	<cfelse>
		<cfset BASECURRENCYID=request.ds.locales[ilocid].currencyID>
		<cfset RATELOCALPERBASE=1>
	</cfif>
	<!--- additional caller variable that will be used by the page which called this chkcase cfm --->
<!--- 	<cfset caller.CASEBASECURRENCYID=#BASECURRENCYID#>
	<cfset caller.CASETERMCURRENCYID=#TERMCURRENCYID#>
	<cfset caller.CASEEXCRATETERMPERBASE=#EXCRATETERMPERBASE#><!--- from term to base currency ---> --->
	<!--- <cfset request.BASECURRENCY=Request.DS.FN.SVCgetCurr(BASECURRENCYID)> --->
<!--- 	<cfset caller.TERMCURRENCY=Request.DS.FN.SVCgetCurr(TERMCURRENCYID)>
	<cfset caller.TERMCURRENCY.RATEBASEPERTERM=99999.999999> --->
	<!--- to stamp this : Request.DS.FN.SVCgetCurr(CASETERMCURRENCYID) --->

	<cfset Caller.dtlcrt = siDTLCRT>
	<cfset cINSGCOID=0>
	<cfif iINSCOID GT 0 AND structKeyExists(Request.DS.CO,iINSCOID)>
		<cfset cINSGCOID=Request.DS.CO[iINSCOID].GCOID>
	</cfif>
	<cfset Caller.INSGCOID = cINSGCOID>

	<cfif Caller.orgtype IS "A">
		<cfset BITTEST=4>
		<CFSET Caller.CASE_COROLE=4>
		<cfif StructKeyExists(Attributes,"GetCaseUser")>
			<cfif CompareNoCase(Trim(vaADJNAME),curuserid) IS 0 OR CompareNoCase(Trim(vaMGRNAME),curuserid) IS 0>
				<cfset Caller.CaseUser = 2>
			<cfelseif vaADJNAME IS "">
				<cfset Caller.CaseUser = 1>
			<cfelse>
				<cfset Caller.CaseUser = 0>
			</cfif>
			<cfif vaASSNAME IS "">
				<cfset Caller.CaseAssoc = 1>
			<cfelseif CompareNoCase(Trim(vaASSNAME),curuserid) IS 0>
				<cfset Caller.CaseAssoc = 2>
			<cfelse>
				<cfset Caller.CaseAssoc = 0>
			</cfif>
		</cfif>
		<cfif Attributes.COID IS "">
			<cfset Attributes.COID=iCOID>
			<cfset Caller.COID=iCOID>
		</cfif>
		<cfset Caller.casestatus = CSTAT>
		<CFSET StrMA=Request.DS.MTRFN.fMultiAssign2(Caller.CASEID,Caller.EXTID,Caller.ORGTYPE)>
  		<CFIF BitAnd(StrMA.MultiFlag,1) IS 1 AND CASELOCID IS 11><!--- #24862 only for TH --->
			<cfif cINSGCOID IS 1100001><!--- TH MSI --->
				<cfset Caller.eSurvey=1>
			<cfelse>
   				<cfset Caller.eSurvey=2>
			</cfif>
  		<cfelseif BitAnd(StrMA.MultiFlag,1) IS 1 AND (LISTFIND("7",CASELOCID) OR (CASELOCID IS 15 AND NOT(cINSGCOID IS 1510001 OR cINSGCOID IS 1510007)))>
   			<cfset Caller.eSurvey=1>
  		<cfelseif BitAnd(StrMA.MultiFlag,3) IS 3 AND NOT(iADJROLETYPE IS 1 OR iADJROLETYPE IS 6)><!--- Multi adj with estimate and not "Adjuster" role --->
   			<cfset Caller.eSurvey=1>
  		<CFELSE>
   			<cfset Caller.eSurvey=0>
  		</CFIF>
		<cfset Caller.EST_COTYPE=Trim(aEST_COTYPE)>
		<cfset Caller.ADJROLETYPE=iADJROLETYPE>
		<cfset Caller.MULTIASSIGN=iMULTIASSIGN>
		<cfset Caller.PADJCASEID=PADJCASEID><!--- this returned parent ADJCASEID is slightly different, if parent not found will return current ADJCASEID --->
	<cfelseif Caller.orgtype IS "I">
		<cfif Attributes.COID IS "">
			<cfset Attributes.COID=iCOID>
			<cfset Caller.COID=iCOID>
		</cfif>
		<cfset BITTEST=2>
		<CFSET Caller.CASE_COROLE=2>
		<cfset Caller.casestatus = CSTAT>
		<cfset Caller.tpins=0>
		<cfif Attributes.TPVIEW IS 1>
			<cfset Caller.tpins=1>
			<cfset BITTEST=8>
			<CFSET Caller.CASE_COROLE=8>
		<cfelseif Attributes.TPVIEW IS 2>
			<!--- Autodetect --->
			<CFSET GCOID=SESSION.VARS.GCOID>
			<cfif iCOID3 GT 0 AND (iCOID IS 0 OR GCOID IS NOT Request.DS.CO[iCOID].GCOID) AND GCOID IS Request.DS.CO[iCOID3].GCOID>
				<cfset Attributes.COID=iCOID3>
				<cfset Caller.coid = iCOID3>
				<cfset Caller.casestatus = CSTAT3>
				<cfset Caller.tpins=1>
				<cfset BITTEST=8>
				<CFSET Caller.CASE_COROLE=8>
			</cfif>
		</cfif>
		<cfset caller.tpkfkstat= TPKFKSTAT>
		<cfif StructKeyExists(Attributes,"GetCaseUser")>
			<cfif vaASSNAME IS "">
				<cfset Caller.CaseAssoc=1>
			<cfelseif CompareNoCase(Trim(vaASSNAME),curuserid) IS 0>
				<cfset Caller.CaseAssoc=2>
			<cfelse>
				<cfset Caller.CaseAssoc=0>
			</cfif>
			<cfif vaMGRNAME IS "">
				<cfset Caller.CaseMgr=1>
			<cfelseif CompareNoCase(Trim(vaMGRNAME),curuserid) IS 0>
				<cfset Caller.CaseMgr=2>
			<cfelse>
				<cfset Caller.CaseMgr=0>
			</cfif>
			<cfif vaOWNER IS "">
				<cfset Caller.CasePIC=1>
			<cfelseif CompareNoCase(Trim(vaOWNER),curuserid) IS 0>
				<cfset Caller.CasePIC=2>
			<cfelse>
				<cfset Caller.CasePIC=0>
			</cfif>
			<cfif vaINADJNAME IS "">
				<cfset Caller.CaseInAdj=1>
			<cfelseif CompareNoCase(Trim(vaINADJNAME),curuserid) IS 0>
				<cfset Caller.CaseInAdj=2>
			<cfelse>
				<cfset Caller.CaseInAdj=0>
			</cfif>
		</cfif>
	<cfelse>
		<cfif Caller.orgtype IS "R">
			<cfset BITTEST=1>
			<CFSET Caller.CASE_COROLE=1>
			<CFIF Caller.OWNFLAG IS NOT 1>
				<!--- Added Andrew 24 nov 2011 to prevent security loophole --->
				<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
			</CFIF>
		<cfelseif Caller.orgtype IS "S">
			<cfset BITTEST=32>
			<CFSET Caller.CASE_COROLE=32>
			<CFIF Caller.OWNFLAG IS NOT 1>
				<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
			</CFIF>
		<cfelse>
			<cfset BITTEST=0>
			<CFSET Caller.CASE_COROLE=iCOROLE>
		</cfif>
		<cfif Attributes.COID IS "">
			<cfset Attributes.COID=iCOID>
			<cfset Caller.COID=iCOID>
		</cfif>
		<cfset Caller.casestatus = CSTAT>
		<!---cfset Caller.fileno = FILENO--->
	</cfif>
	<!--- Check for lock access --->
	<cfif (Attributes.CLMLOCK IS 0 OR Attributes.CLMLOCK IS 1) AND attributes.SETBASECURRONLY neq 1>
		<cfif dMCASEID IS NOT iCASEID>
			<cfquery name="q_pcaseinfo" datasource=#Request.MTRDSN#>
			SELECT iCLMLOCKED=IsNull(iCLMLOCKED,0) FROM TRX0001 WITH (NOLOCK) WHERE iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#dmcaseid#">
			</cfquery>
			<cfset CLMLOCKED=q_pcaseinfo.iCLMLOCKED>
		<cfelse>
			<cfset CLMLOCKED=iCLMLOCKED>
		</cfif>
		<cfif Attributes.CLMLOCK IS 0 AND BITTEST GT 0 AND BitAnd(CLMLOCKED,BITTEST) GT 0>
			<cfthrow TYPE="EX_SECFAILED" ErrorCode="CASELOCKED" EXTENDEDINFO="CLMLOCK:(#Attributes.CLMLOCK#)">
		<cfelseif Attributes.CLMLOCK IS 1 AND BITTEST GT 0 AND BitAnd(CLMLOCKED,BITTEST) IS 0>
			<cfthrow TYPE="EX_SECFAILED" ErrorCode="CASEUNLOCKED" EXTENDEDINFO="CLMUNLOCK:(#Attributes.CLMLOCK#)">
		</cfif>
	</cfif>
	</cfoutput>
</cfif>

<CFIF attributes.SETBASECURRONLY neq 1><!--- Skip whole section if interested in setting base currency only --->
<!--- Check company access --->
<cfif Caller.ORGTYPE IS NOT "D">
	<cfif Attributes.CHKCOID IS 1>
		<cfif Attributes.COID IS "SESSION">
			<cfset Attributes.COID=SESSION.VARS.ORGID>
		</cfif>
		<!--- Any company in childlist can access --->
		<CFIF Caller.ORGTYPE IS "I" AND Attributes.TPVIEW GT 0 AND Caller.TPINS IS 1>
			<CFIF SESSION.VARS.GCOID IS NOT Request.DS.CO[Caller.COID].GCOID>
				<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
			</CFIF>
		<cfelseif Find(","&Attributes.COID&",",","&childlist&",") GT 0>
			<!---CFIF Attributes.TPVIEW IS 1 AND caller.caseid IS caller.mcaseid><!--- AND BitAnd(q_caseinfo.TPKFKSTAT,1) IS 0--->
				<!--- No TP security authorization --->
				<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
			</CFIF--->
		<cfelseif Caller.ORGTYPE IS "I" AND Find(","&SESSION.VARS.ORGID&",",","&braccesslist&",") GT 0>
			<cfset REQUEST.BRRESTRICT=1>
		<cfelse>
			<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
		</cfif>
	<cfelseif Attributes.ChkCOID IS 2>
		<cfif Attributes.COID IS NOT Caller.ORGID>
			<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
		</cfif>
	<cfelseif Attributes.ChkCOID IS 3>
		<!--- Allow if GCOID same (only for Adj and Ins) --->
		<cfif Attributes.COID IS "" OR Attributes.COID LTE 0>
				<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
		<cfelseif Attributes.COID IS "SESSION">
			<cfset Attributes.COID=SESSION.VARS.ORGID>
		</cfif>
		<!--- Any company in childlist can access --->
		<CFIF Caller.ORGTYPE IS "I" AND Attributes.TPVIEW GT 0 AND Caller.TPINS IS 1>
			<CFIF SESSION.VARS.GCOID IS NOT Request.DS.CO[Caller.COID].GCOID>
				<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
			</CFIF>
		<cfelseif Find(","&Attributes.COID&",",","&childlist&",") GT 0>
			<!---CFIF Attributes.TPVIEW IS 1 AND caller.caseid IS caller.mcaseid><!--- AND BitAnd(q_caseinfo.TPKFKSTAT,1) IS 0--->
				<!--- No TP security authorization --->
				<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
			</CFIF--->
		<cfelseif Caller.ORGTYPE IS "I" AND Find(","&SESSION.VARS.ORGID&",",","&braccesslist&",") GT 0>
			<cfset REQUEST.BRRESTRICT=1>
		<cfelse>
			<cfif NOT((Caller.ORGTYPE IS "I" OR Caller.ORGTYPE IS "A") AND Request.DS.CO[Attributes.COID].GCOID IS SESSION.VARS.GCOID)>
				<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
			<cfelse>
				<cfset Caller.NOTCHILDCO=1>
			</cfif>
		</cfif>
	</cfif>
</cfif>

<cfif doquery IS 1>
	<!--- specific validation based on policy group rules --->
	<!--- cfset allowacc_polgrp=1>
	<cfif IsDefined("SESSION.VARS.POLGRP")>
		<CFSET accresult=Request.DS.MTRFN.MTRgetUserCasePolGrpAcc(attributes.LIMITCODE,session.vars.usid,attributes.caseid,Caller.TPINS,0,0,0,0)>
		<CFIF accresult.acc IS 0><cfset allowacc_polgrp=0>
			<!--- cfthrow TYPE="EX_SECFAILED" ErrorCode="CANNOTREAD" EXTENDEDINFO="#Server.SVClang("No access to specific case - please contact your administrator",0)#" --->
		</cfif>
	</cfif --->

	<!--- Check claimtype access --->
	<cfif CLMTYPEMASK IS NOT "" AND BitAnd(SESSION.VARS.CLMTYPEACCMASK,CLMTYPEMASK) IS 0 AND Caller.orgtype NEQ "S">
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="CANNOTREAD" EXTENDEDINFO="#Server.SVClang("No access to {0} claimtype - please contact your administrator",5591,0,"#Caller.Claimtype#")#">
	</cfif>
	<!--- Check status --->
	<cfif Len(Attributes.ChkStatus) GT 0>
		<cfset Attributes.ChkStatus=","&Attributes.ChkStatus&",">
		<cfset state=CALLER.casestatus>
		<cfif	Find(",~#Caller.orgtype##state#,",Attributes.ChkStatus) GT 0 OR
				Find(",~#state#,",Attributes.ChkStatus) GT 0 OR
				(Find(",#state#,",Attributes.ChkStatus) LTE 0 AND
				Find(",#Caller.orgtype##state#,",Attributes.ChkStatus) LTE 0 AND
				Find(",#Caller.orgtype#,",Attributes.ChkStatus) LTE 0)>
			<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCSTAT">
		</cfif>
	</cfif>
</CFIF>
<cfif Caller.ORGTYPE IS "I" AND Attributes.CaseID NEQ "" AND SESSION.VARS.GCOID IS 49 AND Caller.CLMFLOW IS "NM">
	<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="54R">
    <cfif canread IS 0>
		<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\chklabel.cfm" CASEID=#attributes.caseid#><!--- return CALLER.CASELABEL --->
		<cfset USERID=SESSION.VARS.USERID>
		<!--- do checking whether is PIC/manager IC? --->
		<cfquery NAME=q_trx DATASOURCE=#Request.MTRDSN#>
		SELECT iCASEID FROM TRX0008 a WITH (NOLOCK) WHERE
		a.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CASEID#"> AND
		(a.vaOWNER=<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#USERID#"> OR a.vaMGRNAME=<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#USERID#"> OR a.vaASSNAME=<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#USERID#"> OR a.vaINADJNAME=<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#USERID#"> OR a.vaSUPNAME=<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#USERID#">)
		</cfquery>
		<cfif q_trx.recordcount IS 0 AND LISTFIND(CASELABEL,27) GT 0><CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" grplist="65R" ChkRead=1></cfif>
    </cfif>
</cfif>
<cfif Caller.ORGTYPE IS "I" AND Attributes.CaseID NEQ "" AND SESSION.VARS.GCOID IS 70 AND Caller.CLMFLOW IS NOT "NM">
	<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\chklabel.cfm" CASEID=#attributes.caseid#><!--- return CALLER.CASELABEL --->
	<cfset USERID=SESSION.VARS.USERID>
	<!--- do checking whether is PIC/manager IC? --->
	<cfquery NAME=q_trx DATASOURCE=#Request.MTRDSN#>
	SELECT iCASEID FROM TRX0008 a WITH (NOLOCK) WHERE
	a.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CASEID#"> AND
	(a.vaOWNER=<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#USERID#"> OR a.vaMGRNAME=<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#USERID#"> OR a.vaINADJNAME=<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#USERID#">)
	</cfquery>
	<cfif q_trx.recordcount IS 0 AND LISTFIND(CASELABEL,518) GT 0><cfthrow TYPE="EX_SECFAILED" ErrorCode="CANNOTREAD" ExtendedInfo="Confidential Claims !!!"></cfif>
</cfif>
<!--- RESTRICTED USER CHECKING --->
<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCchkrestrictuser.cfm" COID=#session.vars.gcoid# PERMGRPID=10 PARAM='CASEID' PARAMVAL=#Attributes.CaseID# VARUSERLIST=USERLIST>
<CFIF USERLIST.ID NEQ "">
	<CFIF ListFind(USERLIST.ID,#session.vars.usid#,',') gt 0>
		<!---  <cfdump var="#session.vars.usid#"> --->
	<CFELSE>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="CANNOTREAD" ExtendedInfo="Restricted User Only !!!">
	</CFIF>
</CFIF>
</CFIF><!--- end of attributes.SETBASECURRONLY neq 1 --->
</cfsilent>

<!--- default base currency ID --->
<cfif NOT Isdefined("BASECURRENCYID")><cfset BASECURRENCYID=#request.ds.locales[session.vars.locid].currencyID#><cfset RATELOCALPERBASE=1></cfif>
<!---=<cfdump var=#BASECURRENCYID#>=--->
<cfset NUMREFORMAT="">
<cfif doquery IS 1 AND (CASELOCID IS 7 OR CASELOCID IS 16) AND Caller.CLMFLOW IS "NM"><!--- non-motor claim should reformat the figure in 2DP for INDO --->
	<cfset NUMREFORMAT="-|.|2|,|3|2">
</cfif>
<!--- should be displayed out from cfslient as it contains JS script --->
<!--- BASECURRENCYID=<cfdump var=#BASECURRENCYID#>,RATELOCALPERBASE=<cfdump var=#RATELOCALPERBASE#>,NUMREFORMAT=<cfdump var=#NUMREFORMAT#> --->
<cfset temp=#request.DS.FN.SVCCurrencyGenRequestVars(BASECURRENCYID,RATELOCALPERBASE,NUMREFORMAT)#>
