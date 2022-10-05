<CFPARAM name="Attributes.irepcardid" default=0>
<CFPARAM name="Attributes.ChkCoID" default=0>
<CFIF Attributes.ChkCoID IS ""><CFSET Attributes.ChkCoID=1></CFIF>
<CFSET Request.DS.FN.SVCsessionChk()>

<!---CFIF Not IsDefined("SESSION.VARS.USERID")>
	<CFTHROW TYPE="EX_SECFAILED" ErrorCode="NOLOGIN">
</cfif--->
<CFSET Caller.orgtype = SESSION.VARS.ORGTYPE>
<CFSET Caller.orgid = SESSION.VARS.ORGID>
<!---CFSET Caller.usrname = SESSION.VARS.USERID--->
<CFSET Caller.orgname = SESSION.VARS.ORGNAME>
<!--- <CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="26R,27R,28R">
<CFIF CanRead IS 0>
	<CFSET Childlist=SESSION.VARS.ORGID>
<CFELSE>
	<CFSET Childlist=SESSION.VARS.CHCOLIST>
</CFIF> --->
<CFIF SESSION.VARS.CHILDCOACCESS IS 1 AND StructKeyExists(Request.DS.CO,SESSION.VARS.ORGID) AND StructKeyExists(Request.DS.CO[SESSION.VARS.ORGID],"CHCOLIST")>
	<CFSET CHILDLIST=Request.DS.CO[SESSION.VARS.ORGID].CHCOLIST>
<CFELSE>
	<CFSET CHILDLIST=SESSION.VARS.ORGID>
</CFIF>
<CFset caller.canwrite=0><CFset caller.canread=0>

<cfif StructKeyExists(Attributes,"irepcardid")>
	<cfquery datasource=#Request.MTRDSN# name=q_basicrepcard>
		select a.irepaircardid, a.icoid, a.sistatus,a.iinscoid,sitype=isnull(a.sitype,0), r.iBASECURRID, r.nRATELOCALPERBASE, ilocid=isNULL(r.ilocid, <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.vars.locid#">)
		from rep0001 a WITH (NOLOCK)
		LEFT JOIN trx0001 r with (nolock) ON r.irepaircardid=a.irepaircardid
		where a.irepaircardid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.irepcardid#">
	</cfquery>
	<cfif q_basicrepcard.recordcount IS 0>
		<CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCASE" ExtendedInfo="Not found">
	</CFIF>

	<cfoutput query="q_basicrepcard">
		<cfif iBASECURRID NEQ "">
			<cfset BASECURRENCYID=#iBASECURRID#>
			<cfset RATELOCALPERBASE=#nRATELOCALPERBASE#>
		<cfelse>
			<cfset BASECURRENCYID=request.ds.locales[ilocid].currencyID>
			<cfset RATELOCALPERBASE=1>
		</cfif>
	</cfoutput>

	<cfif caller.orgtype is "R">
		<cfset caller.CoID=q_basicrepcard.icoid>
		<CFset caller.canwrite=1><CFset caller.canread=1>
	<cfelseif caller.orgtype is "I">
		<!---CFIF q_basicrepcard.sitype IS NOT 1 AND q_basicrepcard.sitype IS NOT 0> <!--- Thing - Repair and Service cards --->
			<CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCO">
		</CFIF--->
		<cfset caller.CoID=q_basicrepcard.iinscoid>
		<CFset caller.canread=1>
		<!--- Service Card or Philippines can write --->
		<CFIF (q_basicrepcard.sitype IS 1 OR SESSION.VARS.LOCID IS 10)><CFSET caller.canwrite=1></CFIF>
	<CFELSE>
		<CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCO">
	</cfif>
	<CFIF Attributes.ChkCoID IS 1>
	<!--- can access any company in childlist --->
		<cfset found=0>
		<!--- <cfloop index="coid" list=#caller.coid#> --->
			<CFIF Find(",#caller.coid#,",",#childlist#,") is not 0>
				<cfset found=1>
			</CFIF>
		<!--- </cfloop> --->
		<cfif found is 0>
			<cfif NOT ListFind(Request.DS.CO[SESSION.VARS.GCOID].GCOLIST,SESSION.VARS.ORGID)>
				<CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCO">
			</cfif>
			<cfif Caller.ORGTYPE IS "I">
				<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="60R">
				<CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCO" ExtendedInfo="No Enquiry (Groupwide) permission">
			</cfif>
		</cfif>
	<CFELSEIF Attributes.ChkCoID IS 2>
	<!--- can only access own company --->
		<cfset found=0>
		<!--- <cfloop index="coid" list=#caller.coid#> --->
			<CFIF caller.coid IS NOT Caller.OrgID>
				<cfset found=1>
			</cfif>
		<!--- </cfloop> --->
		<cfif found is 0><CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCO"></cfif>
	</CFIF>
</cfif>

<!--- default base currency ID --->
<cfif NOT Isdefined("BASECURRENCYID")><cfset BASECURRENCYID=#request.ds.locales[session.vars.locid].currencyID#><cfset RATELOCALPERBASE=1></cfif>
<cfset temp=#request.DS.FN.SVCCurrencyGenRequestVars(BASECURRENCYID,RATELOCALPERBASE)#>