<!--- <cfsilent> --->
<cfparam name="attributes.BCID" default=""><!--- benefit claim ID --->
<cfparam name="attributes.CASEID" default=""><!--- caseid --->
<cfparam name="attributes.cmtid" default=""><!--- claimmant's cmtid --->
<!--- possible value parsed : 
BCID, BCID + cmtid, CASEID, CASEID + cmtid
--->

<cfparam NAME=Attributes.MODRESULT DEFAULT=MODRESULT>

<!--- return struct with key : CASE_BENID,  CASE_PLANID, CASE_PKGID, PKG
CLMID
CASE_PKGID = pkig id selected
CASE_BENID = list of ben id selected
CASE_BEN[BENID] = {}
	.PLANIDSELECTED = "99"
	.PLAN_CVG_AMT
	.PLAN_CVG_DAY
	
CASE_BENDEFCODE = "XXX,XXX,XXX"
- list of bendefcode for a claim (cmtid)
- used to display mode in claim

CMTIDLIST = "99,99,99" 
- result of list of CMTID for a claim generated

CMT[CMTID] = {}
	.CMT_BENID = list of BENID selected for attributes.CMTID
	.CMT_BEN[BENID] = {}
		.PLANIDSELECTED = "99"
		.PLAN_CVG_AMT
		.PLAN_CVG_DAY
	.CMT_BENDEFCODE = list of bendefcode for a claimant, CLMTID as key

--->
<!--- 

<cfif NOT(attributes.caseid GTE 0 OR attributes.clmid GTE 0)><CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADPARAM" EXTENDEDINFO="CHKBENEFIT/1"></cfif>
<cfset CASE_CLMID=#attributes.clmid#>
<cfif attributes.caseid GT 0>
	<CFQUERY name="q_case" datasource=#Request.MTRDSN# maxrows=1>
	SELECT ilCLMID FROM TRX0008 with (nolock) WHERE iCASEID=<cfqueryparam value="#attributes.caseid#" cfsqltype="CF_SQL_INTEGER"> <cfif attributes.clmid GT 0>AND ilCLMID=<cfqueryparam value="#attributes.clmid#" cfsqltype="CF_SQL_INTEGER"></cfif>
	</CFQUERY>
	<cfif q_case.recordcount IS 0><CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADPARAM" EXTENDEDINFO="CHKBENEFIT/2"></cfif>
	<cfset CASE_CLMID=#q_case.ilCLMID#>
</cfif>
<!--- <cfif NOT(CASE_CLMID GT 0)><CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADPARAM" EXTENDEDINFO="CHKBENEFIT/3"></cfif> --->
<cfif NOT(CASE_CLMID GT 0)><cfset CASE_CLMID=0></cfif>
--->
<cfset CLMID=0>
<cfif attributes.caseid GT 0><!--- get BCID --->
	<cfquery name="q_case" datasource=#Request.MTRDSN#>
	select m.iBCID, m.iLCLMID FROM TRX0008 a with (nolock) JOIN TRX0008 m with (nolock) ON a.imaincaseid=m.icaseid WHERE a.icaseid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.caseid#">
	</cfquery>
	<cfset attributes.BCID=#q_case.iBCID#>
	<cfset CLMID=#q_case.iLCLMID#>
</cfif>
<!--- <cfif CLMID GT 0>
	<cfquery name="q_case" datasource=#Request.MTRDSN#>
	SELECT iBCID FROM CLM0001 with (nolock) WHERE iCLMID=<cfqueryparam value="#CLMID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfset attributes.BCID=#q_case.iBCID#>
</cfif> --->

<cfif NOT(attributes.bcid GTE 0)><cfset attributes.bcid=0></cfif>

<cfquery name="q_case" datasource=#Request.MTRDSN#>
select a.iPKGID,b.vaPKGCODE FROM TRX_BEN a with (nolock) JOIN BIZ_BENPKG b with (nolock) ON a.iPKGID=b.iPKGID
WHERE a.iBCID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.bcid#">
</cfquery>
<!--- <cfif NOT(q_case.recordcount IS 1 AND q_case.iBCID GT 0)><CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADPARAM" EXTENDEDINFO="CHKBENEFIT/1"></cfif> --->
<cfset CASE_PKGID=#q_case.iPKGID#>
<cfset CASE_PKGCODE=#q_case.vaPKGCODE#>

<CFQUERY name="q_trx" datasource=#Request.MTRDSN#>
SELECT a.iBCID,a.iCMTID,a.iPLANID,a.siSTATUS,a.mnCVGAMT,a.fCVGDAY, b.iBENID, b.iPKGID, BENDEFCODE=d.vaBENCODE,
RULEVARNAME=b.vaRULEVARNAME, BENNAME=b.vaBENNAME,BENCVGCODE=b.vaBENCODE
FROM TRX_BENCVG a with (nolock)
JOIN BIZ_BENPLAN c with (nolock) ON a.ibenid=c.ibenid
join BIZ_BENCVG b with (nolock) on c.ibenid=b.ibenid
JOIN BIZ_BENDEF d with (nolock) on b.ibendefid=d.ibendefid
WHERE iBCID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.BCID#"> AND a.sistatus=0 <!--- <cfif attributes.cmtid GT 0>AND iCMTID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.cmtid#"></cfif> --->
ORDER BY a.icmtid, b.ibenid
</CFQUERY>

<!--- get case value --->
<cfquery dbtype="query" name="q_trx_case">
select * FROM q_trx where iBCID=<cfqueryparam value="#attributes.BCID#" cfsqltype="CF_SQL_INTEGER"> AND iCMTID=0 AND sistatus=0
</cfquery>

<cfset result=valuelist(q_trx_case.iBENID)>
<cfset CASE_BENID=""><cfif LEN(result) GT 0><cfset CASE_BENID=#ListRemoveDuplicates(result)#></cfif>
<cfset result=valuelist(q_trx_case.BENDEFCODE)>
<cfset CASE_BENDEFCODE=""><cfif LEN(result) GT 0><cfset CASE_BENDEFCODE=#ListRemoveDuplicates(result)#></cfif>
<cfset result1=valuelist(q_trx_case.BENCVGCODE)>
<cfset CASE_BENCVGCODE=""><cfif LEN(result1) GT 0><cfset CASE_BENCVGCODE=#ListRemoveDuplicates(result1)#></cfif>
<cfset result1=valuelist(q_trx_case.BENNAME)>
<cfset CASE_BENNAME=""><cfif LEN(result1) GT 0><cfset CASE_BENNAME=#ListRemoveDuplicates(result1)#></cfif>
	
<cfset CASE_BEN="">
<cfif q_trx_case.recordcount GT 0>
	<cfset CASE_BEN=structnew()>
	<cfloop query="q_trx_case">
		<!--- get CASE_COVERAGE_PLAN[PLANID] --->
		<cfif NOT StructKeyExists(CASE_BEN,q_trx_case.iBENID)>
			<cfset CASE_BEN[q_trx_case.iBENID]=structnew()>
		</cfif>
		<cfset CASE_BEN[q_trx_case.iBENID].PLANIDSELECTED=#q_trx_case.iPLANID#>
		<cfset CASE_BEN[q_trx_case.iBENID].PLAN_CVG_AMT=#q_trx_case.mnCVGAMT#>
		<cfset CASE_BEN[q_trx_case.iBENID].PLAN_CVG_DAY=#q_trx_case.fCVGDAY#>
		<cfset CASE_BEN[q_trx_case.iBENID].BENNAME=#q_trx_case.BENNAME#>
	</cfloop>
</cfif>

<!--- get claimant's selected benefit (CMT_IDLIST, ALLCMT, CMT) --->
<cfquery dbtype="query" name="q_trx_cmt">
select * FROM q_trx where iBCID=<cfqueryparam value="#attributes.BCID#" cfsqltype="CF_SQL_INTEGER"> <cfif attributes.cmtid GT 0>AND iCMTID=<cfqueryparam value="#attributes.cmtid#" cfsqltype="CF_SQL_INTEGER"><cfelse>AND iCMTID>0</cfif> AND sistatus=0
</cfquery>

<cfset result=valuelist(q_trx_cmt.iCMTID)>
<cfset CMTIDLIST=""><cfif LEN(result) GT 0><cfset CMTIDLIST=#ListRemoveDuplicates(result)#></cfif>
<!--- <cfset CMT=""> ---><cfset ALLCMT ="">
<cfif q_trx_cmt.recordcount GT 0>
	<cfset ALLCMT=structnew()><!--- <cfset CMT=structnew()><cfset CMT.CMT_BENID=""><cfset CMT.CMT_BENID=""> --->
	<cfoutput query="q_trx_cmt" group="icmtid">
		<cfset ALLCMT[q_trx_cmt.iCMTID]=structnew()>
		<cfset ALLCMT[q_trx_cmt.iCMTID].CMT_BENID=""><!--- listing --->
		<cfset ALLCMT[q_trx_cmt.iCMTID].CMT_BEN=structnew()>
		<cfset ALLCMT[q_trx_cmt.iCMTID].CMT_BENDEFCODE=""><!--- listing --->
		<cfset ALLCMT[q_trx_cmt.iCMTID].CMT_RULEVARNAME=""><!--- listing --->
		<cfoutput group="ibenid">
			<cfset ALLCMT[q_trx_cmt.iCMTID].CMT_BENID=#listappend(ALLCMT[q_trx_cmt.iCMTID].CMT_BENID,q_trx_cmt.iBENID)#>
			<cfset ALLCMT[q_trx_cmt.iCMTID].CMT_BENDEFCODE=#listappend(ALLCMT[q_trx_cmt.iCMTID].CMT_BENDEFCODE,q_trx_cmt.BENDEFCODE)#>
			<cfset ALLCMT[q_trx_cmt.iCMTID].CMT_RULEVARNAME=#listappend(ALLCMT[q_trx_cmt.iCMTID].CMT_RULEVARNAME,q_trx_cmt.RULEVARNAME)#>
			<cfset ALLCMT[q_trx_cmt.iCMTID].CMT_BEN[q_trx_cmt.iBENID]=structnew()>
			<cfset ALLCMT[q_trx_cmt.iCMTID].CMT_BEN[q_trx_cmt.iBENID].BENNAME="#q_trx_cmt.BENNAME#">
			<cfset ALLCMT[q_trx_cmt.iCMTID].CMT_BEN[q_trx_cmt.iBENID].PLANIDSELECTED="">
			<cfset ALLCMT[q_trx_cmt.iCMTID].CMT_BEN[q_trx_cmt.iBENID].PLAN_CVG_AMT="">
			<cfset ALLCMT[q_trx_cmt.iCMTID].CMT_BEN[q_trx_cmt.iBENID].PLAN_CVG_DAY="">
			<cfoutput>
				<cfset ALLCMT[q_trx_cmt.iCMTID].CMT_BEN[q_trx_cmt.iBENID].PLANIDSELECTED="#q_trx_cmt.iPLANID#">
				<cfset ALLCMT[q_trx_cmt.iCMTID].CMT_BEN[q_trx_cmt.iBENID].PLAN_CVG_AMT="#q_trx_cmt.mnCVGAMT#">
				<cfset ALLCMT[q_trx_cmt.iCMTID].CMT_BEN[q_trx_cmt.iBENID].PLAN_CVG_DAY="#q_trx_cmt.fCVGDAY#">
			</cfoutput>
		</cfoutput>
	</cfoutput>
</cfif>

<cfif Attributes.MODRESULT IS NOT "" AND (Not IsDefined("Caller.#ATTRIBUTES.MODRESULT#") OR Not IsStruct(Evaluate("Caller.#Attributes.MODRESULT#")))>
	<cfset "Caller.#ATTRIBUTES.MODRESULT#"=StructNew()>
</cfif>
<!--- <cfset "Caller.#ATTRIBUTES.MODRESULT#.CLMID"=CASE_CLMID> --->
<cfset "Caller.#ATTRIBUTES.MODRESULT#.CASE_PKGID"=CASE_PKGID>
<cfset "Caller.#ATTRIBUTES.MODRESULT#.CASE_PKGCODE"=CASE_PKGCODE>
<cfset "Caller.#ATTRIBUTES.MODRESULT#.CASE_BENID"=CASE_BENID>
<cfset "Caller.#ATTRIBUTES.MODRESULT#.CASE_BEN"=CASE_BEN>
<cfset "Caller.#ATTRIBUTES.MODRESULT#.CASE_BENDEFCODE"=CASE_BENDEFCODE>
<cfset "Caller.#ATTRIBUTES.MODRESULT#.CMTIDLIST"=CMTIDLIST>
<cfset "Caller.#ATTRIBUTES.MODRESULT#.CMT"=ALLCMT>
<cfset "Caller.#ATTRIBUTES.MODRESULT#.CASE_BENCVGCODE"=CASE_BENCVGCODE>
<cfset "Caller.#ATTRIBUTES.MODRESULT#.BENNAME"=CASE_BENNAME>
<!--- </cfsilent> --->