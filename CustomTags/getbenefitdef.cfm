<!--- params:
mode ("CLAIM")*, caseid or clmid* : get available benefits according to criteria of caseid/clmid
mode ("CMT")*, caseid or clmid* : get available benefits based on selected benefits from CLMID

* - required
"CLAIM" - CLMID/CASEID, "CMT" - Claimant

[return]

return struct with combination of packages-benefits-plans

.PKGLIST = the list of packages
.PKG[ID]:
	.DEF
	.LIST_BEN = list of all benefits
	.BEN = {}
	
.PKG[ID].BEN[ID]:
	.DEF
	.LIST_PLAN - list of all plans as per BEN
	.PLAN = {}
	
.PKG[ID].BEN[ID].PLAN[ID]:
	.DEF
	.CRITERIA:
---->
<!--- <cfsilent> --->

<!--- attributes.module
"CLAIM" : require attributes BCID, CLMTYPEMASK, COID
"CLAIMANT" : require attributes BCID, CMTID
--->
<cfparam NAME=Attributes.MODRESULT DEFAULT=MODRESULT>
<cfparam name="attributes.module" default="CLAIM">
<cfparam name="attributes.BCID" default=0>
<cfparam name="attributes.CLMTYPEMASK" default=0>
<cfparam name="attributes.SUBCLMTYPEMASK" default=-1>
<cfparam name="attributes.COID" default=0>
<cfparam name="attributes.cmtid" default=0>
<cfif isdefined("session.vars")>
	<cfparam name="attributes.ORGTYPE" default=#session.vars.orgtype#>
<cfelse>
	<cfparam name="attributes.ORGTYPE" default="">
</cfif>

<cfif attributes.BCID IS ""><cfset attributes.BCID=0></cfif>

<cfif attributes.module IS "CLAIM">
	<cfif NOT(attributes.BCID GTE 0 AND attributes.clmtypemask NEQ "" AND attributes.COID GTE 0)>
		<CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADPARAM" EXTENDEDINFO="INS/GETBENEFITDEF/1">
	</cfif>
<cfelseif attributes.module IS "CLAIMANT">
	<!--- <cfif NOT(attributes.BCID GT 0 AND attributes.CMTID GT 0)> --->
	<cfif NOT(attributes.BCID GT 0)>
		<CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADPARAM" EXTENDEDINFO="INS/GETBENEFITDEF/2">
	</cfif>
<cfelse>
	<CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADPARAM" EXTENDEDINFO="INS/GETBENEFITDEF/3 (Invalid Module)">
</cfif>

<cfset pkgselected="">
<cfif attributes.BCID GT 0>
	<CFQUERY name="q_trx" datasource=#Request.MTRDSN#>
	selecT ipkgid from trx_ben with (nolock) where ibcid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.bcid#">
	</cfquery>
	<cfif q_trx.ipkgid GT 0><cfset pkgselected=#q_trx.ipkgid#></cfif>
</cfif>
	

<!--- filter_planid --->
<cfif attributes.module IS "CLAIM">
	<cfset filter_clmtypemask=0>
	<cfset filter_subclmtypemask=-1>
	<cfif attributes.clmtypemask GT 0><cfset filter_clmtypemask=#attributes.clmtypemask#></cfif>
	<cfif attributes.subclmtypemask GT 0><cfset filter_subclmtypemask=#attributes.SUBCLMTYPEMASK#></cfif>
	<!--- require attributes: coid, clmid, filter_clmtypemask --->	
	<!--- currently filtered with clmtypemask --->
	<CFQUERY name="q_trx" datasource=#Request.MTRDSN#>
	SELECT iPLANID from BIZ_BENPLANCFG with (nolock)
	WHERE icoid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.coid#"> AND ((iclmtypemask&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#filter_clmtypemask#">)>0)
	<cfif filter_subclmtypemask GTE 0>
		AND ((isubclmtypemask&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#filter_subclmtypemask#">)>0)
	</cfif>
	</cfquery>
	<cfset filter_planid="">
	<cfif q_trx.recordcount GT 0><cfset filter_planid=#ListRemoveDuplicates(valuelist(q_trx.iPLANID))#></cfif>
<cfelseif attributes.module IS "CLAIMANT"><!--- get from claim --->
	<CFQUERY name="q_trx" datasource=#Request.MTRDSN#>
	selecT iPLANID from TRX_BENCVG with (nolock)
	WHERE iBCID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.BCID#"> and icmtid=0 AND sistatus=0
	</cfquery>
	<cfset filter_planid="">
	<cfif q_trx.recordcount GT 0><cfset filter_planid=#ListRemoveDuplicates(valuelist(q_trx.iPLANID))#></cfif>
</cfif>

<!--- query on benefits --->
<CFQUERY name="q_trx" datasource=#Request.MTRDSN#>
SELECT 
/*pkg*/
pkgname=pkg.vapkgname, pkgid=pkg.ipkgid, pkgcode=pkg.vapkgcode, 
rulesetname=pkg.varulesetname, pkgdteffective=pkg.dteffective,
/*ben*/
benid=ben.ibenid, benname=ben.vabenname, bencode=ben.vabencode, rulevarname=ben.vaRULEVARNAME,
bendefid=bd.ibendefid, bendefcode=bd.vabencode, benallowselectorgtype=ben.vaALLOWSELECTORGTYPE,
/*plan*/
planid=bp.iplanid, planname=bp.vaplanname, plancode=bp.vaplancode,
plancvgamt=CASE WHEN a.iBCID IS NOT NULL AND a.sistatus=0 THEN a.mnCVGAMT ELSE bp.mnCVGAMT END, 
plancvgday=CASE WHEN a.iBCID IS NOT NULL AND a.sistatus=0 THEN a.fcvgday ELSE bp.fcvgday END,
/* plan id behaviour */
plancvgamt_enable=ISNULL(ben.sienable_cvgamt,0),
plancvgamt_name=CASE WHEN LEN(ben.vaname_cvgamt)>0 THEN ben.vaname_cvgamt ELSE NULL END,
plancvgday_enable=ISNULL(ben.sienable_cvgday,0), 
plancvgday_name=CASE WHEN LEN(ben.vaname_cvgday)>0 THEN ben.vaname_cvgday ELSE NULL END,
/* sistatus */
<cfif attributes.module IS "CLAIMANT">
selected=case when (c.icmtid>0 AND c.sistatus=0) THEN 1 ELSE 0 END,
<cfelse>
selected=case when (a.sistatus=0 AND a.iplanid=bp.iplanid) THEN 1 ELSE 0 END,
</cfif>
<cfif attributes.module IS "CLAIMANT">
selectedben=case when (c.icmtid>0 AND c.sistatus=0) THEN 1 ELSE 0 END,
<cfelse>
selectedben=case when (a.sistatus=0) THEN 1 ELSE 0 END,
</cfif> 
status=case when (pkg.sistatus=0 AND ben.sistatus=0 AND bd.sistatus=0 AND bp.sistatus=0) THEN 0 ELSE 1 END,
pkgstatus=case when pkg.sistatus=0 then 0 else 1 end,
benstatus=case when ben.sistatus=0 then 0 else 1 end,
planstatus=case when bp.sistatus=0 then 0 else 1 end
from biz_benpkg pkg with (nolock)
JOIN biz_bencvg ben with (nolock) ON pkg.ipkgid=ben.ipkgid
JOIN biz_bendef bd with (nolock) ON bd.ibendefid=ben.ibendefid
JOIN biz_benplan bp with (nolock) ON bp.ibenid=ben.ibenid
LEFT JOIN trx_bencvg a with (nolock) ON a.iBCID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.BCID#"> and a.icmtid=0 and a.ibenid=bp.ibenid/* and a.iplanid=bp.iplanid */
LEFT JOIN trx_bencvg c with (nolock) ON a.iBCID=c.iBCID AND c.iCMTID=<cfif attributes.CMTID GT 0><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.CMTID#"><cfelse>-1</cfif> and a.ibenid=c.ibenid
where pkg.icoid=<cfqueryparam value="#attributes.coid#" cfsqltype="CF_SQL_INTEGER">
AND ((a.sistatus=0) OR (pkg.sistatus=0 AND ben.sistatus=0 AND bd.sistatus=0 AND bp.sistatus=0 
<cfif isdefined("filter_planid") AND LEN(filter_planid) GT 0>AND bp.iplanid IN (<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#filter_planid#" list="yes">)</cfif>) )
<!--- refilter based on vaALLOWSELECTORGTYPE if applicable --->
AND (
	ISNULL(ben.vaALLOWSELECTORGTYPE,'')=''
	OR 
	(ISNULL(ben.vaALLOWSELECTORGTYPE,'')<>'' AND <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value=",#attributes.ORGTYPE#,"> LIKE '%,'+ben.vaALLOWSELECTORGTYPE+',%')
)
ORDER BY pkg.ipkgid, ben.ibenid, bp.iplanid
</cfquery>
<!--- <cfdump var=#q_trx#> --->
<cfset root=""><!--- <cfset pkgselected=""> ---><cfset benselected="">
<cfif q_trx.recordcount GT 0>
	<cfset root=structnew()>
	<cfset root.PKGLIST="">
	<cfset root.PKG=structnew()>
	<cfoutput query="q_trx" group="pkgid">
		<cfset root.PKGLIST=listappend(root.PKGLIST,pkgid)>
		<!--- <cfif selected IS 1>
			<cfset pkgselected=#pkgid#>
		</cfif> --->
		<cfset root.PKG[pkgid]=structnew()>
		<cfset root.PKG[pkgid].name=#q_trx.pkgname#><cfset root.PKG[pkgid].code=#q_trx.pkgcode#><cfset root.PKG[pkgid].rulesetname=#q_trx.rulesetname#>
		<cfset root.PKG[pkgid].dteff=#q_trx.pkgdteffective#>
		<cfset root.PKG[pkgid].BENLIST="">
		<cfset root.PKG[pkgid].BEN=structnew()>
		<cfset root.PKG[pkgid].STATUS=#q_trx.pkgstatus#>
		<cfoutput group="benid">
			<cfset root.PKG[pkgid].BEN[benid]=structnew()>
			<cfset root.PKG[pkgid].BEN[benid].name=#q_trx.benname#>
			<cfset root.PKG[pkgid].BEN[benid].code=#q_trx.bencode#>
			<cfset root.PKG[pkgid].BEN[benid].defcode=#q_trx.bendefcode#>
			<cfset root.PKG[pkgid].BEN[benid].rulevarname=#q_trx.rulevarname#>
			<cfset root.PKG[pkgid].BEN[benid].PLANLIST="">
			<cfset root.PKG[pkgid].BEN[benid].PLAN=structnew()>
			<cfset root.PKG[pkgid].BEN[benid].STATUS=#q_trx.benstatus#>
			
			<cfset root.PKG[pkgid].BEN[benid].enable_cvg_amt=#q_trx.plancvgamt_enable#>
			<cfset root.PKG[pkgid].BEN[benid].name_cvg_amt=#q_trx.plancvgamt_name#>
			<cfset root.PKG[pkgid].BEN[benid].enable_cvg_day=#q_trx.plancvgday_enable#>
			<cfset root.PKG[pkgid].BEN[benid].name_day_name=#q_trx.plancvgday_name#>
			
			<cfoutput>				
				<cfif SELECTEDBEN IS 1 AND LISTFIND(benselected,#benid#) IS 0>
					<cfset benselected=listappend(benselected,#benid#)>
				</cfif>
				<cfset root.PKG[pkgid].BEN[benid].PLANLIST=listappend(root.PKG[pkgid].BEN[benid].PLANLIST,planid)>
				<cfset root.PKG[pkgid].BEN[benid].PLAN[planid]=structnew()>
				<cfset root.PKG[pkgid].BEN[benid].PLAN[planid].name=#q_trx.planname#>
				<cfset root.PKG[pkgid].BEN[benid].PLAN[planid].code=#q_trx.plancode#>
				<cfset root.PKG[pkgid].BEN[benid].PLAN[planid].cvg_amt=#q_trx.plancvgamt#>
				<cfset root.PKG[pkgid].BEN[benid].PLAN[planid].cvg_day=#q_trx.plancvgday#>
				<cfset root.PKG[pkgid].BEN[benid].PLAN[planid].STATUS=#q_trx.planstatus#>
			</cfoutput>
		</cfoutput>
	</cfoutput>
</cfif>
<cfif Attributes.MODRESULT IS NOT "" AND (Not IsDefined("Caller.#ATTRIBUTES.MODRESULT#") OR Not IsStruct(Evaluate("Caller.#Attributes.MODRESULT#")))>
	<cfset "Caller.#ATTRIBUTES.MODRESULT#"=StructNew()>
</cfif>
<!--- <Cfdump var=#q_trx#> .. 
<cfdump var=#root#>...  --->
<cfset "Caller.#ATTRIBUTES.MODRESULT#.RESULTQUERY"=#q_trx#>
<cfset "Caller.#ATTRIBUTES.MODRESULT#.RESULTSTRUCT"=#root#>
<cfset "Caller.#ATTRIBUTES.MODRESULT#.PKGSELECTED"=#pkgselected#>
<cfset "Caller.#ATTRIBUTES.MODRESULT#.BENSELECTED"=#benselected#>
<!--- </cfsilent> --->