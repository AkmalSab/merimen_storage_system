<!---
FILENAME : claim/sec/act_login.cfm
DESCRIPTION :

attributes.USERID
attributes.PMD5
attributes.NONCE

INPUT/ATTR:

INPUT/FORM:

OUTPUT :

CREATED BY :
CREATED ON :

REVISION HISTORY

BY          ON          REMARKS
=========   ==========  ======================================================================================
--->
<cfparam name="Attributes.UID" default="">
<cfparam name="Attributes.SESSIONSTORE" default="0">
<cfparam name="Attributes.USERID" default="">
<cfparam name="FORM.hpwd" default="">
<cfparam name="Attributes.REDIRFUSEBOX" default="">
<cfparam name="Attributes.REDIRFUSEACTION" default="">
<cfparam name="Attributes.USER" default="0" type="integer">
<cfparam name="Attributes.ACT" default="" type="string">
<cfparam name="Attributes.BOX" default="" type="string">

<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCDISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">
<CFIF NOT (ATTRIBUTES.SESSIONSTORE GT 0)>
	<CFIF Not(IsDefined("FORM.sleUserName") AND IsDefined("FORM.slePassword") AND IsDefined("FORM.nonce"))>
		<CFLOCATION URL="#request.webroot#index.cfm?#Request.MToken#&retryid=8&rid=#RandRange(1000000,9999999)#" ADDTOKEN="no">
		<CFEXIT METHOD=EXITTEMPLATE>
	</CFIF>
	<cfset attributes.USERID=form.sleUserName>
	<cfset attributes.PMD5=form.slePassword>
	<cfif isdefined("form.sleNRIC")>
		<cfset attributes.LOGINNRIC=form.sleNRIC>
	<cfelse>
		<cfset attributes.LOGINNRIC="">
	</cfif>
	<cfset attributes.nonce=form.nonce>
	<cfset attributes.hpwd=form.hpwd>
</cfif>

<!--- START For support usage --->
<cfif attributes.BOX NEQ "" AND attributes.ACT NEQ "" AND attributes.USER GT 0 AND attributes.USER NEQ 0 AND findNoCase('$',Attributes.USERID) IS 0>
	<cfquery name="CHK_USER_CO" datasource="#Request.RPTDSN#">
		SELECT TOP 1 COTYPE=1,iUSID,vaUSID,iCOID FROM SEC0001 WITH (NOLOCK) WHERE vaUSID=<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#Attributes.USERID#"> AND iCOID=<cfqueryparam cfsqltype="cf_sql_integer" value="1"> AND siSTATUS=<cfqueryparam cfsqltype="cf_sql_smallint" value="0">
		UNION
		SELECT TOP 1 COTYPE=2,iUSID,vaUSID,iCOID FROM SEC0001 WITH (NOLOCK) WHERE iUSID=<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.USER#"> AND siSTATUS=<cfqueryparam cfsqltype="cf_sql_smallint" value="0">
		ORDER BY COTYPE ASC
	</cfquery>

	<cfset isMRM=false>
	<cfif CHK_USER_CO.RecordCount GT 0>
		<cfloop query="CHK_USER_CO">
			<cfif iCOID IS 1 AND vaUSID NEQ "" AND iUSID NEQ Attributes.USER>
				<cfset isMRM=true>
			<cfelseif isMRM AND iCOID NEQ 1>
				<cfset attributes.USERID=attributes.USERID&"$"&vaUSID>
			</cfif>
		</cfloop>
	</cfif>
</cfif>
<!--- END For support usage --->

<!---OUTPUT:TRUE--->
<cfmodule TEMPLATE="#request.apppath#services/index.cfm" FUSEBOX=SVCsec FUSEACTION=act_login ATTRIBUTECOLLECTION=#ATTRIBUTES#>
<CFSET PREFBR=MODRESULT.VARS.PREFBR>

<!--- Prudential customization --->
<!--- CST(1342),CST(3062): Prudential wants to have special IAMCSO flag --->
<CFIF (MODRESULT.VARS.GCOID IS 1342 OR MODRESULT.VARS.GCOID IS 3062)>
	<CFSET userperm=ArrayToList(MODRESULT.VARS.PLIST,",")>
	<cfset iamcso=0>
	<cfif ListFind(userperm,57) GT 0 AND ListFind(userperm,43) GT 0>
		<cfset iamcso=1>
		<cfloop list=#userperm# index=a>
			<cfif NOT(a IS 57 OR a IS 43) AND ListFind(Request.DS.PERMGRP[10].PLIST,a) GT 0>
				<cfset iamcso=0><cfbreak>
			</cfif>
		</cfloop>
	</cfif>
	<CFIF iamcso GT 0>
		<cflock SCOPE="Session" Type="Exclusive" TimeOut=60>
		<cfset StructInsert(SESSION.VARS,"IAMCSO",iamcso,TRUE)>
		</cflock>
	</CFIF>
</CFIF>

<!---Enforce SSL --->
<CFIF StructKeyExists(REQUEST.DS,"ENFORCESSL") AND StructKeyExists(SESSION.VARS,"GCOID") AND listfindnocase(REQUEST.DS.ENFORCESSL,SESSION.VARS.GCOID) GT 0>
	<cflock SCOPE="Session" Type="Exclusive" TimeOut=60>
	<CFSET StructInsert(SESSION.VARS,"HTTPS",1,true)>
	</cflock>
</CFIF>

<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\SETTOKEN.cfm">
<CFIF Not(Request.InSession)>
	<cfthrow TYPE="EX_SECFAILED" ErrorCode="NOLOGIN">
<CFELSE>
	<CFSET COTYPEID=SESSION.VARS.COTYPEID>
</CFIF>
<CFIF PREFBR IS NOT "">
	<CFSET PREFBR="&BR=#PREFBR#">
</CFIF>
<CFSET hloc="">
<cfif COTYPEID IS 1>
	<cfquery NAME=q_trx datasource=#Request.MTRDSN#>
		SELECT iBITDATASRC,SITEID=ISNULL(iMRCSITEID,0) 
		FROM SEC0005 WITH (NOLOCK) 
		WHERE iCOID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.VARS.ORGID#">
	</cfquery>
	<cfif q_trx.recordcount LTE 0>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADPARAM">
	</cfif>
	<cfif q_trx.SITEID GT 0 AND BitAnd(q_trx.iBITDATASRC,2) NEQ 2>
		<cfset hloc="index.cfm?fusebox=MTRsec&fuseaction=dsp_mrcagree&">
	</cfif>
</cfif>
<cfif SESSION.VARS.LOCID IS 5 AND (COTYPEID IS 1 OR COTYPEID IS 3)>
	<cfquery NAME=q_trx datasource=#Request.MTRDSN#>
	SELECT iROWID FROM TRX0108 WITH (NOLOCK) WHERE iGCOID=<cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.VARS.GCOID#">
	</cfquery>
	<cfif q_trx.RecordCount IS 0>
		<cfset hloc="index.cfm?fusebox=MTRsec&fuseaction=dsp_mbztransfer&">
	</cfif>
</cfif>
<cfif SESSION.VARS.LOCID IS 7 AND (COTYPEID IS 1 OR COTYPEID IS 9)>
	<cfquery NAME=q_chk datasource=#Request.MTRDSN#>
		SELECT [PremiumChat]=dbo.fBILPremiumChat(<cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.VARS.ORGID#">)
	</cfquery>
	<cfif q_chk.RecordCount GT 0>
		<cflock SCOPE="Session" Type="Exclusive" TimeOut=60>
			<cfset StructInsert(SESSION.VARS,"PREMIUMCHAT",q_chk.PremiumChat,TRUE)>
		</cflock>
	</cfif>
</cfif>

<cfquery NAME=q_sec datasource=#Request.MTRDSN#>
	SELECT b.iPWDSTRENGTHMASK, [iSECURITYFLAG]=ISNULL(u.iSECURITYFLAG,0) 
	FROM SEC0005 a WITH (NOLOCK) 
	LEFT JOIN SEC0005 b WITH (NOLOCK) ON a.iGCOID = b.iCOID
	INNER JOIN SEC0001 u WITH (NOLOCK) ON u.iCOID = a.iCOID
	WHERE a.iCOID=<cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.VARS.ORGID#">
	AND u.vaUSID = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#SESSION.VARS.USERID#">
</cfquery>

<CFIF q_sec.RecordCount GT 0 AND BitAnd(q_sec.iPWDSTRENGTHMASK,8192)>
	<cfset SESSION.VARS.LOGIN2FA=0>
</CFIF>

<!--- MY: Exclude Impersonation mode --->
<CFIF SESSION.VARS.LOCID IS 1
	AND NOT(StructKeyExists(SESSION.VARS,"MMUSERID"))>

	<CFMODULE TEMPLATE="#request.apppath#services/CustomTags/SVCchkgrp.cfm" GrpList="6013W">

	<CFIF IsDefined("session.vars") AND StructKeyExists(session.vars,"LOGIN2FA") AND SESSION.VARS.LOGIN2FA IS 0>
		<cfif CANREAD EQ 0>
			<cfif NOT(IsDefined("Request.FROMINTERGRATION") AND Request.FROMINTERGRATION EQ 1)>
				<cfset REQUEST.DS.FN.SVCChk2FA(1,1)>
			</cfif>
		<cfelse>
			<cfset SESSION.VARS.LOGIN2FA = 1>
		</cfif>			
	<CFELSE>
		<CFIF NOT(IsDefined("SESSION.VARS.MMUSERID") AND SESSION.VARS.MMUSERID IS NOT "")>
			<!--- PDPA Agreement --->
			<CFSTOREDPROC PROCEDURE="sspFSECCheckAuditAgreement" DATASOURCE=#Request.SVCDSN# RETURNCODE="YES">
			<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#SESSION.VARS.USID# DBVARNAME=@ai_usid>
			<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_VARCHAR VALUE="MY_PDPA_2014" DBVARNAME=@as_agreetypelogicname>
			<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=11 DBVARNAME=@ai_bydomainid>
			<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#SESSION.VARS.USID# DBVARNAME=@ai_byobjid>
			</CFSTOREDPROC>
			<CFSET returncode = CFSTOREDPROC.StatusCode>
			<CFIF returncode LT 0>
				<CFTHROW TYPE=EX_DBERROR ErrorCode="FSEC/CHECKAUDITAGREEMENT(#returncode#)">
			</CFIF>
			<CFIF returncode LTE 0>
				<cfset hloc="index.cfm?fusebox=SVCsec&fuseaction=dsp_pdpa_agree"&PREFBR&"&">
			</CFIF>
		</CFIF>
	</CFIF>

	
</CFIF>
<CFIF hloc IS "">
	<cfif LEN(Attributes.REDIRFUSEBOX) GT 0 and LEN(Attributes.REDIRFUSEACTION) GT 0>
		<cfmodule template="redirecthandler.cfm" AttributeCollection="#Attributes#">
		<!---<cfset hloc="index.cfm?fusebox=#attributes.redirfusebox#&fuseaction=#attributes.redirfuseaction#&">--->
	<cfelse>
		<cfset hloc="index.cfm?fusebox=MTRroot&fuseaction=dsp_home"&PREFBR&"&">
	</cfif>
</CFIF>

<!--- START Check for existing session if there is any --->
<cfif attributes.BOX NEQ "" AND attributes.ACT NEQ "" AND attributes.USER GT 0 AND attributes.USER IS SESSION.VARS.USID>
	<cfset redURL="#request.webroot#index.cfm?fusebox=#attributes.BOX#&fuseaction=#attributes.ACT#&#Request.MToken#">
	<cfif isDefined("Attributes.extParam")>
		<cfset redURL&=toString(toBinary(extParam))>
	</cfif>
	<!--- resume from last session --->
	<cflocation url="#redURL#">
</cfif>
<!--- END Check for existing session if there is any --->


<!--- <cfmodule template="#request.apppath#mrm_merge/merimen/index.cfm" FUSEBOX="MRMRoot" FUSEACTION="session_management" sessionid="#SESSION.SESSIONID#" MODE=1 sessiontoken="#SESSION.CFTOKEN#" cfid="#SESSION.CFID#" MODRESULT=SESS_VAR ENVIRONMENT="#ENVIRONMENT#"> --->

<CFIF IsDefined("MODRESULT.SESSION_LOGOUT") AND MODRESULT.SESSION_LOGOUT IS 1>
	<!--- Pop-up session collision message --->
	<CFSET LOC="#HLOC#lastlogon=#modresult.lastlogon#&lastlogout=#modresult.lastlogout#">
	<CFLOCATION URL="#request.webroot#index.cfm?fusebox=SVCsec&fuseaction=dsp_sesslogout_msg&redirect=#UrlEncodedFormat(LOC)#&#Request.MToken#" ADDTOKEN="no">
<cfelse>
	<CFLOCATION URL="#request.webroot##HLOC##Request.MToken#&wel=1" ADDTOKEN="no">
</CFIF>
