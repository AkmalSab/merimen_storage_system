<CFSET Request.DS.FN.SVCsessionChk()>

<CFPARAM NAME=Attributes.DOMAINID DEFAULT="9">
<cfparam name="attributes.CMTNOTID" type=numeric default=0>
<cfparam name="attributes.ChkCoID" type=numeric default=0>
<cfparam name="attributes.ChkOrgType" type=string default="">
<cfparam name="attributes.ChkStatus" type=string default="">

<cfif StructKeyExists(SESSION.VARS,"ORGTYPE")><CFSET Caller.orgtype = SESSION.VARS.ORGTYPE></cfif>
<cfif StructKeyExists(SESSION.VARS,"ORGID")><CFSET Caller.orgid = SESSION.VARS.ORGID></cfif>
<cfif StructKeyExists(SESSION.VARS,"ORGNAME")><CFSET Caller.orgname = SESSION.VARS.ORGNAME></cfif>
<cfif StructKeyExists(SESSION.VARS,"SUBCOTYPEID")><CFSET Caller.orgsubcotype = SESSION.VARS.SUBCOTYPEID></cfif>

<CFIF SESSION.VARS.CHILDCOACCESS IS 1 AND StructKeyExists(Request.DS.CO,SESSION.VARS.ORGID) AND StructKeyExists(Request.DS.CO[SESSION.VARS.ORGID],"CHCOLIST")>
	<CFSET CHILDLIST=Request.DS.CO[SESSION.VARS.ORGID].CHCOLIST>
<CFELSE>
	<CFSET CHILDLIST=SESSION.VARS.ORGID>
</CFIF>

<!--- <CFIF SESSION.VARS.CHILDCOACCESS IS 1>
	<cfquery datasource=#Request.MTRDSN# name=q_co>
	SELECT icoid FROM SEC0005 with (nolock) WHERE igcoid=(SELECT igcoid FROM SEC0005 with (nolock) WHERE icoid=<cfqueryparam value="#SESSION.VARS.ORGID#" cfsqltype="CF_SQL_INTEGER">)
	</cfquery>
	<cfset CHILDLIST="">
	<cfif q_co.recordcount GT 0>
		<cfset CHILDLIST=#valuelist(q_co.icoid)#>
	</cfif>
<CFELSE>
	<CFSET CHILDLIST=SESSION.VARS.ORGID>
</CFIF> --->

<!---CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="26R,27R,28R">
<CFIF CanRead IS 0>
	<CFSET Childlist=SESSION.VARS.ORGID>
<CFELSE>
	<CFSET Childlist=SESSION.VARS.CHCOLIST>
</CFIF--->
<!--- Check organization type --->
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
<cfif IsDefined("attributes.CMTNOTID") AND attributes.CMTNOTID GT 0>
	<cfif caller.orgtype IS ""><!--- annoymous, without login --->

		<cfif IsDefined("attributes.DOMAINID") AND attributes.DOMAINID EQ 9>
			<cfquery datasource=#Request.MTRDSN# name=q_co>
			SELECT iINSCOID, iCOID,siPROCESSSTATUS,vaUUID FROM CMT0001 with (nolock) WHERE icmtnotid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.CMTNOTID#"> AND (icoid=0 or iinscoid=69 or iinscoid=67)
 			UNION
			SELECT iINSCOID, iCOID,siPROCESSSTATUS,vaUUID FROM CMT0001_pro with (nolock) WHERE icmtnotid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.CMTNOTID#"> AND (icoid=0 or iinscoid=69 or iinscoid=67)
			</cfquery>
		<cfelseif IsDefined("attributes.DOMAINID") AND attributes.DOMAINID EQ 1>
			<cfquery datasource=#Request.MTRDSN# name=q_co>
			SELECT iinscoid=iINSGCOID,icoid,siPROCESSSTATUS=sicstat,vaUUID FROM trx0008 with (nolock) 
			WHERE icaseid=<cfqueryparam cfsqltype="cf_sql_integer" value=#attributes.CMTNOTID#>
			</cfquery>
		</cfif>
		<cfif NOT(q_co.recordcount IS 1)><CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCASE" EXTENDEDINFO="Invalid claim notification">
		<cfelse>
			<cfif NOT IsDefined("caller.coid")><cfset caller.coid=""></cfif>
			<cfif NOT IsDefined("caller.insgcoid")><cfset caller.insgcoid=#request.ds.co[q_co.iINSCOID].gcoid#></cfif>
			<cfif NOT IsDefined("caller.casestatus")><cfset caller.casestatus=#q_co.siPROCESSSTATUS#></cfif>
		    <cfset caseuuid=q_co.vaUUID>
		</cfif>
	<cfelseif caller.orgtype IS "L" OR caller.orgtype IS "EA" OR caller.orgtype IS "G" OR (caller.orgtype IS "P" AND Caller.orgsubcotype IS 2) OR (caller.orgtype IS "P" AND Caller.orgsubcotype IS 16)><!--- agent / broker / corp client / agency call centre --->
		<cfif IsDefined("attributes.DOMAINID") AND attributes.DOMAINID EQ 9>
			<cfquery datasource=#Request.MTRDSN# name=q_co>
			SELECT iINSCOID, iCOID,siPROCESSSTATUS,vaUUID FROM CMT0001 with (nolock) WHERE icmtnotid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.CMTNOTID#">
			</cfquery>
	        <cfset caseuuid=q_co.vaUUID>
		<cfelseif IsDefined("attributes.DOMAINID") AND attributes.DOMAINID EQ 1>
			<cfquery datasource=#Request.MTRDSN# name=q_co>
			SELECT iinscoid=iINSGCOID,icoid,siPROCESSSTATUS=sicstat,vaUUID FROM trx0008 with (nolock) 
			WHERE icaseid=<cfqueryparam cfsqltype="cf_sql_integer" value=#attributes.CMTNOTID#>
			</cfquery>
	        <cfset caseuuid=q_co.vaUUID>
		</cfif>		
		<cfif q_co.recordcount IS 1>
			<cfif NOT IsDefined("caller.coid")><cfset caller.coid=#q_co.icoid#></cfif>
			<cfif NOT IsDefined("caller.insgcoid")><cfset caller.insgcoid=#request.ds.co[q_co.iINSCOID].gcoid#></cfif>
			<cfif NOT IsDefined("caller.casestatus")><cfset caller.casestatus=#q_co.siPROCESSSTATUS#></cfif>
		<cfelse>
			<cfquery datasource=#Request.MTRDSN# name=q_co1>
			SELECT iINSCOID, iCOID,siPROCESSSTATUS,vaUUID FROM CMT0001_pro with (nolock) WHERE icmtnotid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.CMTNOTID#">
			</cfquery>
			<cfif NOT IsDefined("caller.coid")><cfset caller.coid=#q_co1.icoid#></cfif>
			<cfif NOT IsDefined("caller.insgcoid")><cfset caller.insgcoid=#request.ds.co[q_co1.iINSCOID].gcoid#></cfif>
			<cfif NOT IsDefined("caller.casestatus")><cfset caller.casestatus=#q_co1.siPROCESSSTATUS#></cfif>
			<cfset caseuuid=#q_co1.vaUUID#>
		</cfif>
		<!--- <cfdump var=#session.vars#> vs <cfdump var=#case_uuid#> <cfabort> --->
<!--- 		<cfset caller.PROCESSSTATUS=#q_co.siPROCESSSTATUS#> --->
	<cfelseif caller.orgtype IS "I">
		<cfif IsDefined("attributes.DOMAINID") AND attributes.DOMAINID EQ 9>
			<cfquery datasource=#Request.MTRDSN# name=q_co>
			SELECT iINSCOID,siPROCESSSTATUS,vaUUID FROM CMT0001 with (nolock) WHERE icmtnotid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.CMTNOTID#">
			</cfquery>
	        <cfset caseuuid=q_co.vaUUID>
		<cfelseif IsDefined("attributes.DOMAINID") AND attributes.DOMAINID EQ 1>
			<cfquery datasource=#Request.MTRDSN# name=q_co>
			SELECT iinscoid=iINSGCOID,siPROCESSSTATUS=sicstat FROM trx0008 with (nolock) 
			WHERE icaseid=<cfqueryparam cfsqltype="cf_sql_integer" value=#attributes.CMTNOTID#>
			</cfquery>
	        <cfset caseuuid=q_co.vaUUID>
		</cfif>	
		<cfif q_co.recordcount IS 1>
			<cfif NOT IsDefined("caller.coid")><cfset caller.coid=#q_co.iINSCOID#></cfif>
			<cfif NOT IsDefined("caller.insgcoid")><cfset caller.insgcoid=#request.ds.co[q_co.iINSCOID].gcoid#></cfif>
			<cfif NOT IsDefined("caller.casestatus")><cfset caller.casestatus=#q_co.siPROCESSSTATUS#></cfif>
		<cfelse>
			<cfquery datasource=#Request.MTRDSN# name=q_co1>
			SELECT iINSCOID,siPROCESSSTATUS,vaUUID FROM CMT0001_pro with (nolock) WHERE icmtnotid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.CMTNOTID#">
			</cfquery>
			<cfif NOT IsDefined("caller.coid")><cfset caller.coid=#q_co1.iINSCOID#></cfif>
			<cfif NOT IsDefined("caller.insgcoid")><cfset caller.insgcoid=#request.ds.co[q_co1.iINSCOID].gcoid#></cfif>
			<cfif NOT IsDefined("caller.casestatus")><cfset caller.casestatus=#q_co1.siPROCESSSTATUS#></cfif>
			<cfset caseuuid=#q_co1.vaUUID#>
		</cfif>
	</cfif>
	<cfif Caller.ORGTYPE IS NOT "D">
		<CFIF Attributes.ChkCoID IS 1>
			<cfif (caller.coid IS 0 OR caller.coid IS "") AND session.vars.gcoid IS 1137>
				<!--- UUID check --->
				<cfif LEN(SESSION.VARS.CASEUUID) GT 0 AND Isdefined("caseuuid") AND StructKeyExists(SESSION.VARS,"CASECMTNOTID") AND SESSION.VARS.CASECMTNOTID GT 0>
					<cfif SESSION.VARS.CASEUUID NEQ caseuuid>
						<CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCASE">
					</cfif>
					<cfif SESSION.VARS.CASECMTNOTID NEQ attributes.CMTNOTID>
						<CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCASE">
					</cfif>
				<cfelse>
					<CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCASE">
				</cfif>
			<cfelse>
				<!--- can access any company in childlist --->
				<cfset found=0>
				<cfloop index="coid" list=#caller.coid#>
					<CFIF Find(",#coid#,",",#childlist#,") is not 0>
						<cfset found=1><cfbreak>
					</CFIF>
				</cfloop>
				<cfif found IS 0><CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCO"></cfif>
			</cfif>
		</CFIF>
	</cfif>
	<cfif Len(Attributes.ChkStatus) GT 0>
		<cfset Attributes.ChkStatus=",#Attributes.ChkStatus#,">
		<!--- For notification claims --->
		<cfif IsDefined("attributes.DOMAINID") AND attributes.DOMAINID EQ 9>
		<cfset state=CALLER.casestatus>
			<cfif	Find(",~#Caller.orgtype##state#,",Attributes.ChkStatus) GT 0 OR
					Find(",~#state#,",Attributes.ChkStatus) GT 0 OR
					(Find(",#state#,",Attributes.ChkStatus) LTE 0 AND
					Find(",#Caller.orgtype##state#,",Attributes.ChkStatus) LTE 0 AND
					Find(",#Caller.orgtype#,",Attributes.ChkStatus) LTE 0)>
				<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCSTAT">
			</cfif>
		</cfif>
	</cfif>
</cfif>
<cfif Isdefined("attributes.CHKPORTALTYPE") AND attributes.CHKPORTALTYPE NEQ "">
	<!--- value : RETAIL --->
	<cfif attributes.CHKPORTALTYPE IS "RETAIL">
		<cfif NOT(SESSION.VARS.GCOID IS 1137 AND SESSION.VARS.USERID IS 1)>
			<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADPARAM" EXTENDEDINFO="Invalid Page Processing">
		</cfif>
	</cfif>
</cfif>
<!--- default base currency ID --->
<cfif NOT Isdefined("BASECURRENCYID")><cfset BASECURRENCYID=#request.ds.locales[session.vars.locid].currencyID#><cfset RATELOCALPERBASE=1></cfif>
<cfset temp=#request.DS.FN.SVCCurrencyGenRequestVars(BASECURRENCYID,RATELOCALPERBASE)#>