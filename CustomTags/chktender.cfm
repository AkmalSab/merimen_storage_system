<CFSET Request.DS.FN.SVCsessionChk()>
<!--- <CFPARAM name="Attributes.itender" default=0> --->
<CFPARAM name="Attributes.ChkCoID" default=0>
<cfparam name="Attributes.ChkOrgType" default="">
<cfparam name="Attributes.ChkStatus" default="">
<CFIF Attributes.ChkCoID IS ""><CFSET Attributes.ChkCoID=1></CFIF>

<CFSET Caller.orgtype = SESSION.VARS.ORGTYPE>
<CFSET Caller.orgid = SESSION.VARS.ORGID>
<!---CFSET Caller.usrname = SESSION.VARS.USERID--->
<CFSET Caller.orgname = SESSION.VARS.ORGNAME>
<CFIF SESSION.VARS.CHILDCOACCESS IS 1 AND StructKeyExists(Request.DS.CO,SESSION.VARS.ORGID) AND StructKeyExists(Request.DS.CO[SESSION.VARS.ORGID],"CHCOLIST")>
	<CFSET CHILDLIST=Request.DS.CO[SESSION.VARS.ORGID].CHCOLIST>
<CFELSE>
	<CFSET CHILDLIST=SESSION.VARS.ORGID>
</CFIF>
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

<cfset CLMGROUPMASK=0>
<cfif BITAND(SESSION.VARS.CLMTYPEACCMASK,#request.ds.clmtypecls['MTR']#) GT 0><cfset CLMGROUPMASK=BITOR(CLMGROUPMASK,1)></cfif>
<cfif BITAND(SESSION.VARS.CLMTYPEACCMASK,#request.ds.clmtypecls['NM']#) GT 0><cfset CLMGROUPMASK=BITOR(CLMGROUPMASK,2)></cfif>

<cfif isdefined("attributes.itender")>	
	<!--- if caller.coid is not defined (in the case of orgtype R), means that all repairers in the tender can view the page --->
	<!--- <cfif not isdefined("caller.coid")> --->
		<cfif caller.orgtype is "I">
			<cfquery datasource=#Request.MTRDSN# name=q_basictenderreg>
			select itender, icoid, siretender, sitenderstat, iorigcoid, vaclmno, varefno, sitendertype
			from trx0070 WITH (NOLOCK) where itender=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.itender#">
			</cfquery>
			<cfif NOT Isdefined("caller.coid")><cfset caller.CoID=Valuelist(q_basictenderreg.icoid)></cfif>
			<cfset caller.casestatus=#q_basictenderreg.sitenderstat#>
			<cfset INSGCOID=#request.ds.co[q_basictenderreg.icoid].gcoid#>
			<cfif INSGCOID IS 64>
				<!--- CST(64) Customization #11863 [MY] TMIM e-Tender - Access control for non motor users --->
				<cfif q_basictenderreg.varefno IS "NM"><!--- non motor claim --->
					<cfif BITAND(CLMGROUPMASK,2) NEQ 2><!--- no nonmotor access --->
						<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
					</cfif>
				<cfelse><!--- motor claim --->
					<cfif BITAND(CLMGROUPMASK,1) NEQ 1><!--- no motor access --->
						<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
					</cfif>
				</cfif>
			</cfif>
			<!--- to check tender case access based on user permission (#39665) --->
			<cfif q_basictenderreg.sitendertype GT 0 AND NOT(LISTFIND(request.ds.mtrfn.MTRGetTenderTypeIDByPerm(),q_basictenderreg.sitendertype) GT 0)>
				<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO" Extendedinfo="Tender Type Access">
			</cfif>
 		<!--- allan : tender adjuster module --->
		<cfelseif caller.orgtype is "A"><!--- allan : adjuster --->
			<cfquery datasource=#Request.MTRDSN# name=q_basictenderreg>
			select itender, icoid=iadjcoid, siadjtenderstat
			from trx0070 WITH (NOLOCK) where itender=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.itender#">
			</cfquery>
			<cfif NOT Isdefined("caller.coid")><cfset caller.CoID=Valuelist(q_basictenderreg.icoid)></cfif>
			<cfset caller.casestatus=#q_basictenderreg.siadjtenderstat#>
		<!--- allan : tender adjuster module END --->
		<cfelseif caller.orgtype is "R">
			<cfquery datasource=#Request.MTRDSN# name=q_basictenderreg>
			select a.itender, a.siretender, a.sitenderstat, a.iorigcoid, b.icoid, b.sibidstatus
			from trx0070 a WITH (NOLOCK), trx0071 b WITH (NOLOCK)
			where a.itender=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.itender#"> and a.itender=b.itender
			<cfif IsDefined("caller.coid")>AND b.icoid=<cfqueryparam value="#caller.coid#" cfsqltype="CF_SQL_INTEGER"></cfif>
			</cfquery>
			<cfif NOT Isdefined("caller.coid")>
				<cfset caller.CoID=Valuelist(q_basictenderreg.icoid)>
				<cfset caller.casestatus=Valuelist(q_basictenderreg.sibidstatus)>
			<cfelse>
				<cfset caller.casestatus=#q_basictenderreg.sibidstatus#>		
			</cfif>
		<cfelse>
			<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
		</cfif>
	<!--- </cfif> --->
<!--- 	<cfoutput>#childlist# vs #caller.coid#</cfoutput><cfabort> --->
	<cfif Caller.ORGTYPE IS NOT "D">
		<CFIF Attributes.ChkCoID IS 1>
		<!--- can access any company in childlist --->
			<cfset found=0>
			<cfloop index="coid" list=#caller.coid#>
				<CFIF Find(",#coid#,",",#childlist#,") is not 0>
					<cfset found=1><cfbreak>
				</CFIF>
			</cfloop>
			<cfif found IS 0><CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCO"></cfif>
		<CFELSEIF Attributes.ChkCoID IS 2>
<!--- 		<!--- can only access own company --->
			<cfif LISTFIND(caller.CoID, #Caller.OrgID#) EQ 0 ><CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCO" extendedinfo="Not Allow to Access Other Branches"></cfif> --->
			<cfset found=0>
			<cfloop index="coid" list=#caller.coid#>
				<CFIF Find(",#coid#,",",#childlist#,") is not 0>
					<cfset found=1><cfbreak>
				</CFIF>
			</cfloop>
			<cfif found IS 0><CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCO"></cfif>
		<cfelseif Attributes.ChkCOID IS 3>
			<!--- Allow if GCOID same (only for Adj and Ins) --->
			<cfif caller.coid IS "" OR caller.coid LTE 0><cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO"></cfif>
			<!--- Any company in childlist can access --->
			<cfif Find(",#caller.coid#,",",#childlist#,") GT 0>
			<cfelse>
				<cfif NOT((Caller.ORGTYPE IS "I") AND Request.DS.CO[caller.coid].GCOID IS SESSION.VARS.GCOID)>
					<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO">
				<cfelse>
					<cfset Caller.NOTCHILDCO=1>
				</cfif>
			</cfif>
		</CFIF>
	</cfif>
	
	<cfif Len(Attributes.ChkStatus) GT 0>
		<cfset Attributes.ChkStatus=",#Attributes.ChkStatus#,">
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
<!--- default base currency ID --->
<cfif NOT Isdefined("BASECURRENCYID")><cfset BASECURRENCYID=#request.ds.locales[session.vars.locid].currencyID#><cfset RATELOCALPERBASE=1></cfif>
<cfset temp=#request.DS.FN.SVCCurrencyGenRequestVars(BASECURRENCYID,RATELOCALPERBASE)#>