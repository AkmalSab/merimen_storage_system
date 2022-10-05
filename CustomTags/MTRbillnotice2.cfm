<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCDISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">
<cfif NOT(structKeyExists(SESSION,"VARS") AND structKeyExists(SESSION.VARS,"LOCID"))>
    <CFEXIT METHOD=EXITTEMPLATE>
</cfif>

<cfset LOCID=SESSION.VARS.LOCID>
<cfset ORGTYPE=SESSION.VARS.ORGTYPE>
<cfset COID=SESSION.VARS.ORGID>
<cfset FN=Request.DS.FN>

<cfif NOT(LOCID IS 7 AND (ORGTYPE IS "R" OR ORGTYPE IS "S" OR ORGTYPE IS "A"))>
    <CFEXIT METHOD=EXITTEMPLATE>
</cfif>

<cfif ORGTYPE IS "R" OR ORGTYPE IS "A">
    <cfquery name=q_co datasource=#Request.MTRDSN#>
    SELECT siFRANCHISE=IsNull(a.siFRANCHISE,0),a.siCOTYPEID,iSUBCOTYPEFLAG=IsNull(a.iSUBCOTYPEFLAG,0)
    FROM SEC0005 a WITH (NOLOCK)
    WHERE a.iCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#COID#">
    </cfquery>
    <cfif q_co.siCOTYPEID IS 1 AND q_co.siFRANCHISE IS 1>
        <CFEXIT METHOD=EXITTEMPLATE><!--- Exclude franchise rep --->
    </cfif>
    <cfif q_co.siCOTYPEID IS 3 AND BitAnd(q_co.iSUBCOTYPEFLAG,8+32) GT 0>
        <CFEXIT METHOD=EXITTEMPLATE><!--- Exclude surveyor & internal surveyor --->
    </cfif>
</cfif>

<cfquery name=q_acc datasource=#Request.MTRDSN#>
DECLARE @ldt_curdate datetime=dbo.fSVCdtDBShift(getdate(),<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#LOCID#">)
DECLARE @lsi_year smallint=DatePart(yyyy,@ldt_curdate)
DECLARE @lsi_month smallint=DatePart(m,@ldt_curdate)

SELECT b.iACCID,b.vaACCNAME,ACCTYPE=c.vaDESC,b.mnCRDLIMIT,b.mnBALANCE,
    CURACTIVE=CASE WHEN d.iDEDUCTPAYID IS NOT NULL THEN 1 ELSE 0 END,d.siYEAR,d.siMONTH
FROM FBIL0008 b WITH (NOLOCK)
    INNER JOIN FBIL0009 a WITH (NOLOCK) ON b.iACCID=a.iACCID
    INNER JOIN FBILB0008 c WITH (NOLOCK) ON c.iACCTYPE=b.iACCTYPE
    LEFT JOIN FBIL0022 d WITH (NOLOCK) ON d.iACCID=b.iACCID AND siYEAR=@lsi_year AND siMONTH=@lsi_month AND iDEDUCTPAYID IS NOT NULL
WHERE a.iCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#COID#"> AND b.siBILLMODEID=1
    AND b.siACCSTAT=0
ORDER BY b.iACCTYPE
</cfquery>
<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCURLBACK.cfm" new>
<CFOUTPUT>
<cfloop query=q_acc>
<div style="font-size:120%;text-align:center;padding:3px">
    Ada <b style="<cfif q_acc.mnBALANCE LE 0>color:red</cfif>">#FN.SVCnum(q_acc.mnBALANCE)#</b> poin kredit di akun <u>#q_acc.ACCTYPE#</u> perusahaan anda.
    <cfif q_acc.CURACTIVE IS 1>Status Langganan #MonthAsString(q_acc.siMONTH)# #q_acc.siYEAR# sudah aktif.</cfif> Rincian status <a href="javascript:document.location.href='#request.webroot#index.cfm?fusebox=SVCbill&fuseaction=dsp_account&accid=#q_acc.iACCID#&#request.mtoken#'">klik disini</a>.
    <input type="button" class="clsButton2" value="#Server.SVClang("Topup",0)#" style="font-size:80%" onclick="document.location.href='#request.webroot#index.cfm?fusebox=SVCbill&fuseaction=dsp_topupCreate_ID&accid=#q_acc.iACCID#&#newurlback#&#request.mtoken#'">
</div>
</cfloop>
</CFOUTPUT>