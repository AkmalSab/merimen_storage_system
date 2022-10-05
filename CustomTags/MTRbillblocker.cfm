<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCDISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">
<CFPARAM NAME=Attributes.COID type=numeric>
<CFPARAM NAME=Attributes.DOMAINID type=numeric>
<CFPARAM NAME=Attributes.OBJID type=numeric>
<CFPARAM NAME=Attributes.BLOCKMODE type=numeric default=0><!--- 1:Display warning, 2:Block action by throwing error --->
<!--- Note: Returns Caller.BILL_BLOCKRESULT --->

<cfset LOCID=SESSION.VARS.LOCID>
<cfset ORGTYPE=SESSION.VARS.ORGTYPE>

<cfif NOT(LOCID IS 7 AND (ORGTYPE IS "R" OR ORGTYPE IS "S"))>
    <CFEXIT METHOD=EXITTEMPLATE>
</cfif>
<cfif ORGTYPE IS "R">
    <cfquery name=q_co datasource=#Request.MTRDSN#>
    SELECT siFRANCHISE=IsNull(a.siFRANCHISE,0)
    FROM SEC0005 a WITH (NOLOCK)
    WHERE a.iCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.COID#"> AND a.siCOTYPEID=1
    </cfquery>
    <cfif q_co.recordcount IS 0>
        <CFTHROW TYPE=EX_DBERROR ErrorCode="BADPARAM" ExtendedInfo="Repairer not found">
    </cfif>
    <cfif q_co.siFRANCHISE IS 1>
        <CFEXIT METHOD=EXITTEMPLATE><!--- Exclude franchise rep --->
    </cfif>
</cfif>

<cfif Attributes.DOMAINID IS 1>
    <cfquery name=q_trx datasource=#Request.MTRDSN#>
    SELECT CHKDATE=dbo.fSVCdtDBShift(IsNull(a.dtlasttransferred,a.dtCRTON),<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#LOCID#">)
    FROM TRX0001 a WITH (NOLOCK)
    WHERE a.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.OBJID#">
    </cfquery>
    <cfif q_trx.recordcount IS 0>
        <CFTHROW TYPE=EX_DBERROR ErrorCode="BADPARAM" ExtendedInfo="Case not found">
    </cfif>
    <cfset CHKDATE=q_trx.CHKDATE>
<cfelseif Attributes.DOMAINID IS 6>
    <cfquery name=q_trx datasource=#Request.MTRDSN#>
    SELECT CHKDATE=dbo.fSVCdtDBShift(a.dtFINALON),<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#LOCID#">)
    FROM TRX0001 a WITH (NOLOCK)
    WHERE a.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.OBJID#">
    </cfquery>
    <cfif q_trx.recordcount IS 0>
        <CFTHROW TYPE=EX_DBERROR ErrorCode="BADPARAM" ExtendedInfo="Case not found">
    </cfif>
    <cfset CHKDATE=q_trx.CHKDATE>
<cfelse>
    <cfquery name=q_trx datasource=#Request.MTRDSN#>
    SELECT CHKDATE=dbo.fSVCdtDBShift(getdate()),<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#LOCID#">)
    </cfquery>
    <cfset CHKDATE=q_trx.CHKDATE>
</cfif>

<cfset BLOCK_RESULT=0>
<cfquery name=q_acc datasource=#Request.MTRDSN#>
SELECT a.iACCID,a.siBLOCKEFFECT
FROM FBIL0008 a WITH (NOLOCK)
    INNER JOIN FBIL0009 b WITH (NOLOCK) ON b.iACCID=a.iACCID
WHERE b.iCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.COID#">
    AND a.siBILLMODEID=1 AND a.iACCTYPE=1 AND a.iLOCID=<cfqueryparam value="#LOCID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfif q_acc.RecordCount IS 0>
    <cfset BLOCK_RESULT=1><!--- Prepaid account not created --->
<cfelseif q_acc.RecordCount IS 1>
    <cfif NOT(q_acc.siBLOCKEFFECT IS 1)>
        <CFEXIT METHOD=EXITTEMPLATE><!--- Account configured not to block --->
    <cfelse>
        <cfquery name=q_trx2 datasource=#Request.MTRDSN#>
        SELECT iPAYID,iDEDUCTPAYID
        FROM FBIL0022 WITH (NOLOCK)
        WHERE iACCID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#q_acc.iACCID#"> AND siYEAR=<cfqueryparam cfsqltype="CF_SQL_SMALLINT" value="#DatePart("yyyy",CHKDATE)#"> AND siMONTH=<cfqueryparam cfsqltype="CF_SQL_SMALLINT" value="#DatePart("m",CHKDATE)#">
        </cfquery>
        <cfif q_trx2.RecordCount IS 0>
            <cfset BLOCK_RESULT=2><!--- No subs fee topup --->
        <cfelseif q_trx2.RecordCount GT 0 AND ListLen(ValueList(q_trx2.iDEDUCTPAYID)) IS 0>
            <cfset BLOCK_RESULT=3><!--- Got subs fee topup but deduction bill is not authorized yet --->
        </cfif>
    </cfif>
</cfif>
<cfset Caller.BILL_BLOCKRESULT=BLOCK_RESULT>

<cfif BLOCK_RESULT GT 0 AND Attributes.BLOCKMODE IS 2>
    <cfif BLOCK_RESULT IS 1>
        <CFTHROW TYPE=EX_SECFAILED ErrorCode="BADCASE" ExtendedInfo="Prepaid account not created">
    <cfelseif BLOCK_RESULT IS 2>
        <CFTHROW TYPE=EX_SECFAILED ErrorCode="BADCASE" ExtendedInfo="Subscription Fee not paid for the period of #DatePart("yyyy",CHKDATE)#-#DatePart("m",CHKDATE)#">
    <cfelseif BLOCK_RESULT IS 3>
        <CFTHROW TYPE=EX_SECFAILED ErrorCode="BADCASE" ExtendedInfo="Deduction bill is not authorized yet for the period of #DatePart("yyyy",CHKDATE)#-#DatePart("m",CHKDATE)#">
    </cfif>
<cfelseif BLOCK_RESULT GT 0 AND Attributes.BLOCKMODE IS 1>
    <CFOUTPUT>
	<blockquote class=clsColorMsg style="font-size:100%;padding:5px">
    <cfif BLOCK_RESULT IS 1>
		Prepaid account not active. Please inform Merimen to setup your prepaid account.
    <cfelseif BLOCK_RESULT IS 2>
		Sistem kami menunjukkan bahwa Status Langganan untuk Bulan <u>#MonthAsString(DatePart("m",CHKDATE))# #DatePart("yyyy",CHKDATE)#</u> belum terbayarkan.<br><br>
		Mohon dapat melakukan proses pembayaran dahulu. Silahkan klik tombol ini untuk melakukan pembayaran
        <input type="button" class="clsButton2" value="#Server.SVClang("Topup",0)#" style="font-size:9px;padding-bottom:2px;" onclick="document.location.href='#request.webroot#index.cfm?fusebox=SVCbill&fuseaction=dsp_topupCreate_ID&accid=#q_acc.iACCID#&#request.mtoken#'">
    <cfelseif BLOCK_RESULT IS 3>
		Deduction bill is not authorized yet for the period of #DatePart("yyyy",CHKDATE)#-#DatePart("m",CHKDATE)#
    </cfif>
	</blockquote>
    </CFOUTPUT>
</cfif>