<!--- <cfsilent> --->
<cfparam name="attributes.caseid" default=0><!--- claim's caseid --->
<cfparam NAME=Attributes.MODRESULT DEFAULT=MODRESULT>
<cfparam name="attributes.noaction" default=1>
<cfparam name="attributes.urlback" default="">
<cfif attributes.urlback IS "">
<cfset attributes.urlback="#request.webroot#index.cfm?fusebox=MTRinsurer&fuseaction=dsp_clmheader&caseid=#attributes.caseid#&tpins=0&#Request.MToken#">
</cfif>
<cfset RESULT=1><!--- 1: pass , 0: not pass --->

<CFQUERY name="q_trx" datasource=#Request.MTRDSN#>
SELECT claimtype=RTRIM(a.aclaimtype), inscoid=b.icoid, CLMID=b.ilclmid, c.siVDCARRYCAP, BENPKGID=f.iPKGID, d.iTOWMILE, MCASEID=b.imaincaseid, m.iBCID
FROM TRX0001 a with (nolock)
JOIN TRX0008 b with (nolock) ON a.icaseid=b.icaseid AND b.siTPINS=0
JOIN TRX0008 m with (nolock) ON m.icaseid=b.imaincaseid
LEFT JOIN TRX0055 e with (nolock) ON e.icaseid=a.icaseid
LEFT JOIN CLM0001 c with (nolock) ON b.ilclmid=c.iclmid
<!--- LEFT JOIN TRX_BEN f with (nolock) ON f.iBCID=c.iBCID --->
LEFT JOIN TRX_BEN f with (nolock) ON f.iBCID=m.iBCID
LEFT JOIN TRX0055 d with (nolock) ON a.icaseid=d.icaseid
WHERE a.icaseid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.caseid#">
</CFQUERY>
<cfset CLAIMTYPE=#q_trx.claimtype#> 
<cfset INSGCOID=#request.ds.co[q_trx.inscoid].gcoid#>
<cfset RULESETNAME=""><cfset RULESETID="">
<cfset CLMID=#q_trx.CLMID#>
<cfset BENPKGID=#q_trx.BENPKGID#>
<cfset VDCARRYCAP=#q_trx.siVDCARRYCAP#>
<cfset TOWMILE=#q_trx.iTOWMILE#>
<cfset MCASEID=#q_trx.mcaseid#>
<cfset BCID=#q_trx.iBCID#>

<CFQUERY name="q_clm" datasource=#Request.MTRDSN#>
SELECT RULESETID=a.irulesetid, RULESETNAME=b.vaRULESETNAME
FROM TRX0035 a with (nolock)
JOIN fitr0001 b ON b.irulesetid=a.irulesetid
WHERE a.ilcaseid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.caseid#"> AND a.acotype='I'
</CFQUERY>
<cfif q_clm.recordcount GT 0>
	<cfset RULESETNAME=#q_clm.RULESETNAME#>
	<cfset RULESETID=#q_clm.RULESETID#>
</cfif>

<cfset tloffer="">
<CFIF CLMID GT 0>
	<!--- CLMID can be NULL --->
	<CFQUERY NAME="q_ws_chk" DATASOURCE=#Request.MTRDSN#>
	selecT TOP 1 tloffer=ISNULL(c.mnCLMTOTINS,0)+ISNULL(c.mnCLMTOTDEDUCT,0)
	from clm0001 b with (nolock)
	JOIN trx0008 c with (nolock) ON c.icaseid=b.imaincaseid
	join trx0001 d with (nolock) on d.icaseid=c.icaseid 
	WHERE b.iCLMID=<cfqueryparam value="#CLMID#" cfsqltype="CF_SQL_INTEGER"> AND ((LEFT(d.aclaimtype,2)='OD' AND c.siOFRTYPE=3) OR LEFT(d.aclaimtype,2)='TF' OR (dbo.fODWSChk(RTRIM(d.aCLAIMTYPE),d.iLOCID,c.iINSGCOID)=1 AND c.siOFRTYPE=3) ) and c.dtoffer IS NOT NULL
	order by c.icaseid DESC
	</cfquery>
	<cfif q_ws_chk.recordcount GT 0>
		<cfset tloffer=#q_ws_chk.tloffer#>
	</cfif>
</CFIF>

<cfif CLAIMTYPE IS "LU" AND BCID GT 0 AND (RULESETNAME IS "BSILUGEN" OR RULESETNAME IS "BSILUCIMBAR" OR RULESETNAME IS "LIBERTYEZP")>
	<CFQUERY NAME="q_ws_chk" DATASOURCE=#Request.MTRDSN#>
	select DISTINCT b.iCMTID
	from trx_bencvg b with (nolock) 
	join BIZ_BENCVG z with (nolock) ON b.ibenid=z.ibenid
	where b.iBCID=<cfqueryparam value="#BCID#" cfsqltype="CF_SQL_INTEGER"> AND b.iCMTID>0 AND b.sistatus=0 AND (z.iDEFFLAG&8)>0
	</cfquery>
	<cfset suminj=0><cfif q_ws_chk.recordcount GT 0><cfset suminj=#q_ws_chk.recordcount#></cfif>
	<CFQUERY name="q_case" datasource=#Request.MTRDSN#>
	SELECT ITMID=d.iITMID, ITM_NVAL4=d.NVAL4 /* no of injured */, ITM_NVAL3 = d.NVAL3 /* no of permitted person */, injpersonname=c.vaname, ofrcvgname=e.vaDISPCODE
	FROM trx0095 a with (nolock)
	JOIN trx0085 b with (nolock) ON a.icmtid=b.icmtid
	JOIN FCLT0001 c with (nolock) ON c.icltid=b.icltid
	JOIN FITM0002 d with (nolock) ON d.iitmgrpid=a.iitmgrpid
	JOIN FITR0002 e with (nolock) ON e.iruleid=d.iruleid
	WHERE a.icaseid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.caseid#"> AND e.vaRULEVARNAME IN (
		SELECT vaRULEVARNAME FROM biz_bencvg z with (nolock) WHERE ipkgid=<cfqueryparam value="#BENPKGID#" cfsqltype="CF_SQL_INTEGER"> AND (z.iDEFFLAG&8)>0 AND LEN(vaRULEVARNAME)>0
	)
	</cfquery>
	<cfset list_syncofrluitmid=""><cfset list_caseaffected="">
	<cfloop query="q_case">
		<cfif (q_case.ITM_NVAL4 NEQ suminj) OR (q_case.ITM_NVAL3 NEQ q_trx.siVDCARRYCAP)>
			<cfset list_syncofrluitmid=listappend(list_syncofrluitmid,q_case.ITMID)>		
			<cfset list_caseaffected=listappend(list_caseaffected,"#injpersonname# - #ofrcvgname# (Current total injured: #suminj#, current vehicle seating capacity: #VDCARRYCAP#)","|")>
		</cfif>
	</cfloop>
	
	<!--- verify on PPG and towing --->
	<CFQUERY name="q_case" datasource=#Request.MTRDSN#>
	SELECT injpersonname=c.vaname, ofrcvgname=e.vaDISPCODE, RULEVARNAME=e.vaRULEVARNAME, ITMID=d.iITMID,
	ITM_MNVAL5=d.MNVAL5, /* PPG - TL/TF Offer Amount */	ITM_NVAL3=d.NVAL3 /* TOW - total mileage */
	FROM trx0095 a with (nolock)
	JOIN trx0085 b with (nolock) ON a.icmtid=b.icmtid
	JOIN FCLT0001 c with (nolock) ON c.icltid=b.icltid
	JOIN FITM0002 d with (nolock) ON d.iitmgrpid=a.iitmgrpid
	JOIN FITR0002 e with (nolock) ON e.iruleid=d.iruleid
	WHERE a.icaseid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.caseid#"> AND e.vaRULEVARNAME IN ('LUPPG','LUTOW')
	</cfquery>
	<cfloop query="q_case">
		<cfif RULEVARNAME IS "LUTOW" AND TOWMILE NEQ q_case.ITM_NVAL3>
			<cfset list_syncofrluitmid=listappend(list_syncofrluitmid,q_case.ITMID)>
			<cfset list_caseaffected=listappend(list_caseaffected,"#injpersonname# - #ofrcvgname#","|")>
		<cfelseif RULEVARNAME IS "LUPPG" AND tloffer NEQ "" AND tloffer NEQ q_case.ITM_MNVAL5>
			<cfset list_syncofrluitmid=listappend(list_syncofrluitmid,q_case.ITMID)>
			<cfset list_caseaffected=listappend(list_caseaffected,"#injpersonname# - #ofrcvgname#","|")>
		</cfif>
	</cfloop>
	
	<cfif listlen(list_syncofrluitmid) GT 0><cfset RESULT=0></cfif>

	<!--- <cfdump var="suminj=#suminj#, list_syncofrluitmid=#list_syncofrluitmid#, list_caseaffected=#list_caseaffected#"> --->
	<cfif RESULT IS 0>
		<cfoutput>
		<cfsavecontent variable="MSG">
		System detected the claim offer made is not up-to-date<!--- (current total injured person: #suminj#, current permitted seating capacity: #VDCARRYCAP#) --->.
		<cfif attributes.noaction IS 0>
		<br>Click <input type="button" class="clsButton" value=" Re-calculate " onclick="document.frmVerifyOfrB4Aprv.submit();"> in order to reflect offer amount based on latest criteria provided.<br><br>
		</cfif>
		Affected offer as below:<br>
		<cfif list_caseaffected NEQ "">
			<cfloop list=#list_caseaffected# index="itm" delimiters="|">
				- #itm#<br>
			</cfloop>
		</cfif>
		</cfsavecontent>
		<cfif attributes.noaction IS 0>
			<FORM name="frmVerifyOfrB4Aprv" action="#request.webroot#index.cfm?fusebox=MTRestmain&fuseaction=act_estsyncoffer&caseid=#attributes.caseid#&#Request.MToken#" method=post>
			<input type="hidden" name="mode" value="LUMEDOFR"><input type="hidden" name="sleSyncOfrItmID" value="#list_syncofrluitmid#">
			<input type="hidden" name="urlback" value="#attributes.urlback#">
			<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCchkguid.cfm" START></FORM>
		</cfif>
		</cfoutput>
	</cfif>
</cfif>

<cfif Attributes.MODRESULT IS NOT "" AND (Not IsDefined("Caller.#ATTRIBUTES.MODRESULT#") OR Not IsStruct(Evaluate("Caller.#Attributes.MODRESULT#")))>
	<cfset "Caller.#ATTRIBUTES.MODRESULT#"=StructNew()>
</cfif>
<cfset "Caller.#ATTRIBUTES.MODRESULT#.RESULT"=#RESULT#>
<cfparam name="MSG" default="">
<cfset "Caller.#ATTRIBUTES.MODRESULT#.MSG"=#MSG#>
<!--- </cfsilent> --->