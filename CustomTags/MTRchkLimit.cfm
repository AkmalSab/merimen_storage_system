<!--- Attributes:CHKTYPE (ADJ=AdjMandate,INS(default)=InsMandate),CASEID,TPINS,USID,DISPRESULT,MODRESULT,LOCID,INSGCOID --->
<cfparam NAME=Attributes.CASEID DEFAULT=0>
<cfparam NAME=Attributes.TPINS DEFAULT=0>
<cfparam NAME=Attributes.USID DEFAULT=#SESSION.VARS.USID#>
<cfparam NAME=Attributes.DISPRESULT DEFAULT=1> <!--- Instantly display blockquote with results --->
<cfparam NAME=Attributes.MODRESULT DEFAULT=MODRESULT>
<cfparam NAME=Attributes.LOCID DEFAULT=0>
<cfparam NAME=Attributes.INSGCOID DEFAULT=0>
<cfparam NAME=Attributes.CHKTYPE DEFAULT="INS">
<cfparam NAME=Attributes.LIMITCODE DEFAULT="CLM">
<cfparam NAME=Attributes.MANDATEAMT type=string DEFAULT="">
<cfparam NAME=Attributes.MANDATEAMT2 type=string DEFAULT="">
<cfparam NAME=Attributes.EXTID type=numeric DEFAULT=0>
<cfparam NAME=Attributes.HIDESTR type=string DEFAULT="">

<!--- attributes.LIMITCODE :
CLM : claim offer's approval limit
RSV : reserve approval limit
PAY : payment approval limit
RPI : repair pending instruction approval limit
--->
<!--- CHKPARAM1: Additional info struct to determine/differentiate type of checking required.
			For CHKTYPE=ADJ: RPTTYPE=1 (Report Submit Type) --->
<CFIF Not(StructKeyExists(Attributes,"CHKPARAM") AND IsStruct(Attributes.CHKPARAM))>
	<CFSET Attributes.CHKPARAM=StructNew()>
</CFIF>
<CFIF Attributes.INSGCOID IS 0 OR Attributes.LOCID IS 0>
	<CFQUERY NAME=q_getcaseinfo DATASOURCE=#Request.MTRDSN#>
	SELECT a.iLOCID,a.iINSCOID
	FROM TRX0001 a WITH (NOLOCK)
	WHERE a.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CASEID#">
	</CFQUERY>
	<CFIF q_getcaseinfo.recordcount IS NOT 1>
		<cfthrow TYPE=EX_SECFAILED ErrorCode="BADCASE" ExtendedInfo="MTRchklimit-no repairer dtls">
	</CFIF>
	<CFSET Attributes.INSGCOID=Request.DS.CO[q_getcaseinfo.iINSCOID].GCOID>
	<CFSET Attributes.LOCID=q_getcaseinfo.iLOCID>
</CFIF>
<CFSET LOCALE=Request.DS.LOCALES[Attributes.LOCID]>
<CFSET FN=Request.DS.FN>
<CFSET resultstr=""><CFSET limit_amt=""><CFSET claim_amt="">
<CFIF Attributes.CHKTYPE IS "INS">
	<!--- INS mandate checking (for approval) --->
	<!--- result: 0=cannot approve (reason given), 1=can approve(no reason str given) --->
	<CFSET result=1><CFSET li_mandate = 0>
	<!--- <CFMODULE TEMPLATE="#Request.LOGPATH#CustomTags\GETATTR.cfm" ATTRID=36 ID=#Attributes.INSGCOID#> --->
	<CFSET AttrValue=Request.DS.FN.SVCgetExtAttrLogic("COADMIN",0,"COATTR36",10,Attributes.INSGCOID)>
	<CFIF AttrValue IS NOT "" AND AttrValue GT 0>
		<CFSET li_mandate = AttrValue>
	</CFIF>
	
	<!--- to check whether amount mandate were given, most probably happening for insurer's direct offer made by the adjuster. if amount mandate applied, amount approval will be referred to authorised mandate given by the adj --->
	<CFQUERY NAME="q_case" DATASOURCE=#Request.MTRDSN#>
	SELECT a.mnAUTHMANDATE,CLMID=ISNULL(a.ilCLMID,0), a.vaMGRNAME,a.vaOWNER,a.vaINADJNAME, a.iCOID, a.siOFRTYPE, r.aCLAIMTYPE,
		iINSCLASSID=IsNull(a.iINSCLASSID,0),iINSPOLID=IsNull(a.iINSPOLID,0),iINSBUSID=IsNull(a.iINSBUSID,0),iCLMTYPEMASK=IsNull(a.iCLMTYPEMASK,0),
		c.siCLMREGAUTO,isTL=CASE WHEN ISNULL(a.siOFRTYPE,0)=3 THEN 1 ELSE 0 END, MCASEID=a.imaincaseid, r.nRATELOCALPERBASE
	FROM TRX0008 a WITH (NOLOCK)
		JOIN TRX0001 r with (nolock) ON r.iCASEID=a.iCASEID
		LEFT JOIN TRX0035 d with (nolock) ON d.ilCASEID=r.iCASEID AND d.aCOTYPE='I'
		LEFT JOIN TRX0054 cr WITH (NOLOCK) ON cr.iCASEID=a.iCASEID AND cr.aCOTYPE='I'
		LEFT JOIN CLM0001 c WITH (NOLOCK) ON c.iCLMID=a.iLCLMID
	WHERE a.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CASEID#"> AND a.siTPINS=<cfqueryparam cfsqltype="CF_SQL_SMALLINT" value="#Attributes.TPINS#">
	</cfquery>
	<cfset PICUSID="">
	<cfif q_case.vaOWNER NEQ "">
		<cfquery NAME="q_pic" DATASOURCE=#Request.MTRDSN#>
		SELECT PICUSID=iusid FROM SEC0001 with (nolock) WHERE vaUSID=<cfqueryparam value="#q_case.vaOWNER#" cfsqltype="CF_SQL_NVARCHAR">
		</cfquery>
		<cfset PICUSID=#q_pic.PICUSID#>
	</cfif>
	<cfset MCASEID=#q_case.MCASEID#>
	<cfset CLMID=#q_case.CLMID#>
	<cfset insauthmandate=0><cfif q_case.mnAUTHMANDATE NEQ ""><cfset insauthmandate=1></cfif>
	<!--- get the offer limit type --->
	<cfset li_offerlimit_type=0>
	<CFSET AttrValue=Request.DS.FN.SVCgetExtAttrLogic("COADMIN",0,"COATTR764",10,Attributes.INSGCOID)>
	<CFIF AttrValue IS NOT "" AND AttrValue GT 0><cfset li_offerlimit_type=#AttrValue#></cfif>
	<cfif li_offerlimit_type IS 1 AND CLMID IS 0><!--- claim is not registered yet, should refer to its own individual claim case --->
		<cfset li_offerlimit_type=0><!--- reset back to default setting --->
	</cfif>

	<cfset li_filtercase=0>
	<CFSET AttrValue=Request.DS.FN.SVCgetExtAttrLogic("COADMIN",0,"COATTR-APPROVLIMIT_FIL",10,Attributes.INSGCOID)>
	<CFIF AttrValue IS NOT "" AND AttrValue GT 0><cfset li_filtercase=#AttrValue#></CFIF>
	<CFIF li_filtercase GT 1>
		<CFQUERY NAME=q_linkedcase DATASOURCE=#Request.MTRDSN#>
			SELECT DISTINCT c.iCASEID
			FROM TRX0008 a WITH (NOLOCK)
			INNER JOIN CLM0004 b ON b.ICLMID=a.iLCLMID
			INNER JOIN TRX0008 c ON c.iCASEID=b.ICASEID AND c.iINSCLASSID=a.iINSCLASSID 
			<CFIF BitAnd(li_filtercase,4) GT 0>AND c.iINSPOLID=a.iINSPOLID</CFIF>
			<CFIF BitAnd(li_filtercase,8) GT 0>AND c.iINSBUSID=a.iINSBUSID</CFIF>
			WHERE a.iCASEID=<cfqueryparam value="#attributes.CASEID#" cfsqltype="CF_SQL_INTEGER">
		</CFQUERY>
	<CFELSE>
		<CFQUERY NAME=q_linkedcase DATASOURCE=#Request.MTRDSN#>
			SELECT a.iCASEID
			FROM CLM0004 a WITH (NOLOCK)
			WHERE a.iCLMID=<cfqueryparam value="#CLMID#" cfsqltype="CF_SQL_INTEGER">
		</CFQUERY>
	</CFIF>

	<CFQUERY NAME=q_trx DATASOURCE=#Request.MTRDSN#>
	SELECT AwardAmt=SUM(AwardAmt),
		ResvAmt=SUM(ResvAmt),
		labamt=SUM(labamt),
		totalamt=SUM(totalamt),
		OfferGross=SUM(OfferGross),
		clmtotdeduct=SUM(clmtotdeduct),
		bttramt=SUM(bttramt),
		settlenett=SUM(settlenett),
		totesparts=SUM(totesparts),
		udrinsuredamt=SUM(udrinsuredamt),
		depramt=SUM(depramt),
		LIABLEPC=SUM(LIABLEPC),
		mnTOTGROSS=SUM(mnTOTGROSS)
	FROM
	(
		SELECT 	
			<CFIF Attributes.INSGCOID IS 200005><!--- in local currency --->
				AwardAmt=IsNull((SELECT mnAWARD FROM TRX0070 WITH (NOLOCK) WHERE iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CASEID#"> AND siSTATUS=0 AND dtAWARDON IS NOT NULL),0),
			<cfelse>
				AwardAmt=cast(NULL as money), 
			</CFIF>
			<CFIF li_mandate IS 4><!--- in local currency --->
				ResvAmt=CASE WHEN cr.iRESVTYPE IN (2,3) THEN (SELECT SUM(sr.mnAMT) FROM CLM0026 sr WITH (NOLOCK) WHERE sr.iRESVID=cr.iLASTRESVID AND sr.iPURPOSE=1)
							ELSE (SELECT crsv.mnRESERVECLM FROM CLM0001 cr WITH (NOLOCK),CLM0005 crsv WITH (NOLOCK) WHERE cr.iCLMID=a.iLCLMID AND a.iLCLMID>0 AND crsv.iCLMID=a.iLCLMID AND cr.iCLMRESVID=crsv.iCLMRESVID) END,
				<!--- ResvAmt=(SELECT crsv.mnRESERVECLM FROM CLM0001 cr WITH (NOLOCK),CLM0005 crsv WITH (NOLOCK) WHERE cr.iCLMID=a.iLCLMID AND a.iLCLMID>0 AND crsv.iCLMID=a.iLCLMID AND cr.iCLMRESVID=crsv.iCLMRESVID), --->
			<cfelse>
				ResvAmt=cast(NULL as money), 
			</CFIF>
			labamt=IsNull(d.mnTOTLAB,0)+IsNull(d.mnTOTPAINTWORK,0)-IsNull(d.mnTOTLABDISC,0),
			totalamt=IsNull(a.mnCLMTOTINS,0),
			<!--- Gross offer for OD/TP standardized --->
			OfferGross=IsNull(a.mnCLMTOTINS,0)+IsNull(a.mnCLMTOTDEDUCT,0)+IsNull(mnITC_DITC,0)-IsNull(d.mnSTAMPDUTY,0)-IsNull(a.mnTOTVAT,0)+IsNull(d.mnSALVAGE,0)+IsNull(d.mnUNDERINSUREDAMT,0)+IsNull(d.mnDEXCESS,0)+IsNull(d.mnD2F,0),
			clmtotdeduct=IsNull(a.mnCLMTOTDEDUCT,0),
			bttramt=IsNull(d.mnBTTRAMT,0),
			settlenett=d.mnSETTLENETT,
			totesparts=CASE WHEN a.iESOURCEFLAG&9=9 THEN IsNull(a.mnTOTESPARTS,0) ELSE 0 END,
			<!---udrinsuredamt=Round(convert(money,CASE WHEN IsNull(d.siDUNDERINSURED,0)=1 THEN IsNull(d.mnTOTALL2,0) - convert(money,IsNull(d.mnTOTALL2,0)*(convert(float,d.mnDSUMINSURED)/convert(float,d.mnDMKTVALUE))) ELSE 0 END),<cfqueryparam cfsqltype="CF_SQL_DECIMAL" value="#LOCALE.CURRROUNDDP#">)--->
			udrinsuredamt=IsNull(d.mnUNDERINSUREDAMT,0),
			depramt=isnull(mnDEPRAMT,0),
			LIABLEPC=d.nLIABLEPC,
			mnTOTGROSS=ISNULL(a.mnTOTGROSS,0)
		FROM TRX0008 a WITH (NOLOCK)
			INNER JOIN TRX0001 r with (nolock) ON r.iCASEID=a.iCASEID
			LEFT JOIN TRX0035 d with (nolock) ON d.ilCASEID=r.iCASEID AND d.aCOTYPE='I'
			LEFT JOIN TRX0054 cr WITH (NOLOCK) ON cr.iCASEID=a.iCASEID AND cr.aCOTYPE='I'
		WHERE
			<cfif li_offerlimit_type IS 1>
				<!--- sum per claim folder --->
				<CFSET CASEID_LIST="#MCASEID#">
				<CFSET CASEID_LIST=ListAppend(CASEID_LIST,ValueList(q_linkedcase.iCASEID))>
				a.iMAINCASEID IN (<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CASEID_LIST#" list="yes">)
			<cfelse>
				<!--- per claim subfolder --->
				a.iMAINCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#MCASEID#">
			</cfif>
			AND a.siTPINS=<cfqueryparam cfsqltype="CF_SQL_SMALLINT" value="#Attributes.TPINS#">
			<CFIF BitAnd(li_filtercase,1) EQ 0>
			<!--- #35864: Include approved main+supp only, or current caseid (not yet approved) --->
			AND (a.dtAUTH IS NOT NULL OR a.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.CASEID#">)
			</CFIF>
	) z
	</CFQUERY>
	<CFIF q_trx.recordcount IS NOT 1>
		<cfthrow TYPE=EX_SECFAILED ErrorCode="BADCASE" ExtendedInfo="MTRchklimit-no insurer offer dtls">
	</CFIF>

	<CFSET CLMTYPE=Trim(q_case.aCLAIMTYPE)>

	<Cfif Attributes.INSGCOID IS 200036>
		<Cfif (q_case.siCLMREGAUTO Neq "" AND BitAnd(q_case.siCLMREGAUTO,1) GT 0) OR (LISTFINDNOCASE("NM LB,NM WC",CLMTYPE))><CFSET li_mandate = 1></Cfif>
	</Cfif>
	
	<!--- convert from base currency to local currency for approval limit verification. [ResvAmt] should be ignore from conversion, [mnAUTHMANDATE] is local currency, no conversion required if -ve --->
	<cfset therate=""><cfif q_case.nRATELOCALPERBASE NEQ ""><cfset therate=#q_case.nRATELOCALPERBASE#></cfif>
	<!--- Temp fix for Allianz, error fix during check limit in FIC screen --->
	<cfif Attributes.INSGCOID eq 35 AND left(CLMTYPE,2) EQ "NM" AND therate eq "">
		<cfset therate = 1>
	</cfif>
	<!--- some module require batch processing that may not initiatise the request.basecurrency variable --->
	<cfset q_trx=#request.DS.FN.SVCCurrencyQueryBaseToLocal(q_trx,"AwardAmt,labamt,totalamt,OfferGross,clmtotdeduct,bttramt,settlenett,totesparts,udrinsuredamt,depramt,LIABLEPC,mnTOTGROSS","",therate)#>
	<cfset q_case=#request.DS.FN.SVCCurrencyQueryBaseToLocal(q_case,"mnAUTHMANDATE","mnAUTHMANDATE")#>
		
	<CFSET accresult=Request.DS.MTRFN.MTRgetUserCasePolGrpAcc(attributes.LIMITCODE,Attributes.USID,0,0,q_case.iCLMTYPEMASK,q_case.iINSCLASSID,q_case.iINSPOLID,q_case.iINSBUSID,q_case.isTL)>
	<CFIF accresult.acc IS 1>
		<CFIF insauthmandate IS 1><!--- amount as base, ins auth mandate is set --->
			<CFSET limit_amt=#q_case.mnAUTHMANDATE#>
		<CFELSE>
			<CFSET limit_amt=accresult.limit>
		</CFIF>
		<cfset accresult_limitamt=#limit_amt#><!--- to keep the actual limit produced from MTRgetUserCasePolGrpAcc --->
	<CFELSE>
		<CFSET limit_amt=0>
		<cfset accresult_limitamt=0>
	</CFIF>
	<CFIF limit_amt IS -1>
		<CFSET limitstr=Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)&Server.SVClang("Unlimited",2025)>
	<CFELSE>
		<CFSET limitstr=Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)&FN.SVCNum(limit_amt)>
	</CFIF>
	
	<CFIF (Attributes.INSGCOID IS 700479 AND SESSION.VARS.ORGID IS 700479) AND (Left(CLMTYPE,2) IS "OD" OR CLMTYPE IS "TP")>
		<!--- CST(700479):Indrapura rules, apply to HQ users only --->
		<CFIF CLMTYPE IS "TP">
			<!--- TP: Only managers can approve, based on total --->
			<CFSET claim_amt=q_trx.totalamt>
			<CFIF UCase(SESSION.VARS.USERID) IS NOT UCase(Trim(q_case.vaMGRNAME))>
				<CFSET resultstr="#Server.SVClang("Only Managers can approve this claim",7718)# [#Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(claim_amt)#]">
			</CFIF>
		<CFELSE>
			<!--- OD: Managers can approve, based on total, surveyors+PIC can approve, based on labour --->
			<CFIF UCase(SESSION.VARS.USERID) IS UCase(Trim(q_case.vaMGRNAME))>
				<CFSET claim_amt=q_trx.totalamt+q_trx.clmtotdeduct+q_trx.totesparts>
			<CFELSEIF UCase(SESSION.VARS.USERID) IS UCase(Trim(q_case.vaOWNER)) OR UCase(SESSION.VARS.USERID) IS UCase(Trim(q_case.vaINADJNAME))>
				<CFSET claim_amt=q_trx.labamt+q_trx.clmtotdeduct>
				<CFIF limit_amt IS 0>
					<CFSET resultstr=Server.SVClang("You do not have any approval limit",7719)>
				<CFELSEIF NOT(limit_amt IS -1 OR limit_amt GTE claim_amt)>
					<CFSET resultstr="#Server.SVClang("The labour amount exceeds your approval limit",7720)# [#Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(claim_amt)# -> #limitstr#]">
				</CFIF>
				<!--- Only Manager can approve if more than 5 parts with amount >=50,000 --->
				<CFQUERY NAME=q_chk DATASOURCE=#Request.MTRDSN#>
				SELECT cnt=COUNT(*) FROM TRX0036 a WITH (NOLOCK)
				WHERE a.iLCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CASEID#"> AND a.aCOTYPE='I' AND a.siPINS=0 AND a.iQUANTITY>0 AND a.fVAL>=50000
				</CFQUERY>
				<CFIF q_chk.cnt GT 5 AND UCase(SESSION.VARS.USERID) IS NOT UCase(Trim(q_case.vaMGRNAME))>
					<CFSET resultstr=Server.SVClang("Only Manager can approve this claim (more than 5 parts with gross amount >=50,000)",7721)>
				</CFIF>
			<CFELSE>
				<CFSET resultstr=Server.SVClang("Only Manager, PIC or Surveyor can approve this claim",7722)>
			</CFIF>
		</CFIF>
		<CFIF resultstr IS "">
			<CFIF limit_amt IS 0>
				<CFSET resultstr=Server.SVClang("You do not have any approval limit",7719)>
			<CFELSEIF NOT(limit_amt IS -1 OR Val(limit_amt) GTE Val(claim_amt))>
				<CFSET resultstr="#Server.SVClang("The claim amount exceeds your approval limit",7470)# [#Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(claim_amt)# -> #limitstr#]">
			</CFIF>
		</CFIF>
	<CFELSEIF Attributes.INSGCOID IS 700051 AND (Left(CLMTYPE,2) IS "OD" OR CLMTYPE IS "TP" OR CLMTYPE IS "TP PD" OR CLMTYPE IS "TP BI" OR CLMTYPE IS "TF")>
		<!--- CST(700051):indo MSIG rules, amount to verify based on repairer's est amount + supplier amount --->
		<cfquery NAME=q_trx DATASOURCE=#Request.MTRDSN#>
		SELECT TOTAMT=IsNull(e.mnTOTCLM,0)
		FROM TRX0008 a with (nolock)
			INNER JOIN TRX0035 e with (nolock) on e.iLCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CASEID#"> AND e.aCOTYPE='R'
		WHERE a.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.caseid#"> AND a.siTPINS=0
		</CFQUERY>
		<CFIF q_trx.recordcount IS NOT 1>
			<cfthrow TYPE=EX_SECFAILED ErrorCode="BADCASE" ExtendedInfo="MTRchklimit-multiple offer provided.">
		</CFIF>
		
		<cfquery NAME=q_trx2 DATASOURCE=#Request.MTRDSN#>
		SELECT TOTPO=IsNull(SUM(s.mnTOTQUOTE),0)
		FROM TRX0008 a with (nolock)
			INNER JOIN ESC0001 s with (nolock) on s.idomainid=1 and s.iobjid=a.iCASEID AND s.dtpoaccept is not null
		WHERE a.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.caseid#"> AND a.siTPINS=0
		</CFQUERY>
		
		<cfset claim_amt=q_trx.TOTAMT+q_trx2.TOTPO>
		<cfset claim_amt=#request.DS.FN.SVCCurrencyBaseToLocal(claim_amt)#>
		
		<CFIF resultstr IS "">
			<CFIF limit_amt IS 0>
				<CFSET resultstr=Server.SVClang("You do not have any approval limit",7719)>
			<CFELSEIF NOT(limit_amt IS -1 OR limit_amt GTE claim_amt)>
				<CFSET resultstr="#Server.SVClang("Sum of repairer's estimate amount and supplier's offer amount exceeds your approval limit",10055)# [#Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(claim_amt)# (Repairer=#Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(q_trx.TOTAMT)#, Supplier=#Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(q_trx2.TOTPO)#) -> #limitstr#]">
			</CFIF>
		</CFIF>
	<CFELSEIF Attributes.INSGCOID IS 1000001 AND Left(CLMTYPE,2) IS NOT "NM"> <!--- #37853 --->
		<CFQUERY name="q_LinkedCase" datasource="#Request.MTRDSN#">
			SELECT sumLinkedCase=SUM(ins.mnCLMTOTINS)
			FROM TRX0001 a WITH(NOLOCK)
			INNER JOIN TRX0008 ins WITH(NOLOCK) on ins.iCASEID = a.iCASEID
			WHERE <CFIF CLMID GT 0>ins.iLCLMID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CLMID#"><CFELSE>ins.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.caseid#"></CFIF> AND a.siSTATUS=0 
			GROUP BY ins.iLCLMID
		</CFQUERY>
		<cfif q_LinkedCase.sumLinkedCase GT limit_amt>
			<CFSET resultstr="The claim amount exceeds your approval limit.">
		</cfif>
	<CFELSEIF li_mandate IS 4>
		<CFSET claim_amt=q_trx.ResvAmt>
		<CFIF claim_amt IS "">
			<CFSET resultstr=Server.SVClang("The claim reserve is not keyed in yet",6951)>
		<CFELSEIF limit_amt IS 0>
			<CFSET resultstr=Server.SVClang("You do not have any approval limit",7719)>
		<CFELSEIF NOT(limit_amt IS -1 OR limit_amt GTE claim_amt)>
			<CFSET resultstr="#Server.SVClang("The claim reserve exceeds your approval limit",6953)# [#Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(claim_amt)# -> #limitstr#]">
		</CFIF>
	<CFELSE>
		<CFIF q_trx.settlenett IS NOT "">
			<!--- If got GSS, use that --->
			<CFSET claim_amt=q_trx.settlenett>
		<CFELSE>
			<CFIF Attributes.INSGCOID IS 200005 AND q_case.siOFRTYPE IS 3>
				<CFSET claim_amt=q_trx.totalamt-q_trx.awardamt>
			<CFELSEIF Attributes.INSGCOID IS 49 AND Left(CLMTYPE,2) IS "NM"><!--- CST(49): axa's all NM --->
				<CFSET claim_amt=q_trx.totalamt+q_trx.clmtotdeduct>
			<CFELSEIF Attributes.INSGCOID IS 50 AND CLMTYPE IS "NM FR"><!--- CST(50): Jerneh's NM FR --->
				<CFSET claim_amt=q_trx.totalamt+q_trx.clmtotdeduct>
			<CFELSEIF (Attributes.INSGCOID IS 37 OR attributes.INSGCOID IS 1101192) AND Left(CLMTYPE,2) IS "NM"><!--- CST(37): MPIB's all NM --->
				<CFSET claim_amt=q_trx.totalamt+q_trx.clmtotdeduct>
			<cfelseif Attributes.INSGCOID is 61 and Left(CLMTYPE,2) is "NM"> <!--- #25843 Edwin --->
				<CFSET claim_amt=q_trx.OfferGross>
			<CFELSEIF Left(CLMTYPE,2) IS "NM" AND q_case.siOFRTYPE IS 7>
				<CFIF q_trx.LIABLEPC IS "">
					<CFSET liability=100>
				<CFELSE>
					<CFSET liability=q_trx.LIABLEPC>
				</CFIF>
				<CFSET claim_amt1=val(val(q_trx.mnTOTGROSS)+val(q_trx.depramt))>
				<cfset claim_amt2=request.ds.fn.SVCnumDBround(claim_amt1*(liability/100),2)>
				<cfset claim_amt=claim_amt2+val(q_trx.clmtotdeduct)>
			<CFELSEIF li_mandate IS 1>
				<!--- 1:Gross --->
				<CFSET claim_amt=q_trx.OfferGross>
			<CFELSEIF li_mandate IS 2>
				<!--- 2:Nett --->
				<CFSET claim_amt=q_trx.totalamt+q_trx.clmtotdeduct>
			<CFELSEIF li_mandate IS 3>
				<!--- 3:Gross+Betterment --->
				<CFSET claim_amt=q_trx.OfferGross+q_trx.bttramt>
			<CFELSEIF li_mandate IS 5>
				<!--- 5:Gross-UnderInsured --->
				<!---CFSET claim_amt=q_trx.OfferGross-q_trx.udrinsuredamt--->
				<!--- Commented off: Gross-UnderInsured does not make sense now because the Gross already excludes UnderInsured --->
				<CFSET claim_amt=q_trx.OfferGross>
			<CFELSE>
				<!--- 0:Nett+eSource (default) --->
				<CFSET claim_amt=val(q_trx.totalamt)+val(q_trx.clmtotdeduct)+val(q_trx.totesparts)>
			</CFIF>
		</CFIF>
		<CFIF limit_amt IS 0>
			<CFSET resultstr=Server.SVClang("You do not have any approval limit",7719)>
		<CFELSEIF NOT(limit_amt IS -1 OR Val(limit_amt) GTE Val(claim_amt))>
			<CFSET resultstr="#Server.SVClang("The claim amount exceeds your approval limit",7470)# [#Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(claim_amt)# -> #limitstr#]">
		</CFIF>
	</CFIF>
	
	<!--- ********* BEGIN custom rules for company with CHKTYPE="INS" ********* --->
	<!--- #21923 Edwin --->
	<cfif Attributes.INSGCOID IS 700527 AND CLMTYPE IS "NM MC" AND PICUSID GT 0>
		<CFSET PICLIMITRESULT=Request.DS.MTRFN.MTRgetUserCasePolGrpAcc("CLM",PICUSID,MCASEID,0)>
		<!--- <CFIF (PICUSID EQ Attributes.USID OR PICLIMITRESULT.LIMIT GTE accresult_limitamt )> --->
		<CFIF NOT( PICUSID NEQ Attributes.USID AND (accresult_limitamt EQ -1 OR (PICLIMITRESULT.LIMIT GTE 0 AND accresult_limitamt GT PICLIMITRESULT.LIMIT) ) )>
			<CFSET resultstr=listappend(resultstr,"Approval should be not the same PIC with have the less/same Limit authority","|")>
		</CFIF>
	</cfif>
	<!--- ********* END OF custom rules for company with CHKTYPE="INS" ********* --->
	<CFIF resultstr IS ""><CFSET result=1><CFELSE><CFSET result=0></CFIF>
<CFELSEIF Attributes.CHKTYPE IS "ADJ">
	<!--- ADJ mandate checking (for ins.auth only) --->
	<!--- result (bit) 1=no mandate given,2=can ask for mandate,4=exceeded mandate --->
	<cfquery NAME=q_trx DATASOURCE=#Request.MTRDSN#>
	SELECT a.iCOID,ADJOFRAUTH=IsNull(a.iADJOFRAUTH,0),TOTAMT=IsNull(e.mnTOTALL2,0),MAXMANDATE=COALESCE(a.mnMAXMANDATE,0),
		NETTAMT=IsNull(e.mnTOTCLM,0)+IsNull(e.mnTOTDEDUCT,0),CLMTYPE=r.aCLAIMTYPE,a.dtADJOFRVRFON,r.iMCASEID,r.ICLMTYPEMASK,siOFRDTL=ISNULL(r.siOFRDTL,0),
		iADJOFR=IsNull(c.iADJOFR,0),g.siTPSETTLETYPE
	FROM TRX0001 r WITH (NOLOCK)
		INNER JOIN TRX0002 a WITH (NOLOCK) ON a.iCASEID=r.iCASEID
			LEFT JOIN TRX0035 e WITH (NOLOCK) ON e.iLCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CASEID#"> AND e.aCOTYPE='A'
		INNER JOIN TRX0008 c WITH (NOLOCK) ON c.iCASEID=r.iCASEID AND c.siTPINS=0
			LEFT JOIN TRX0088 g WITH (NOLOCK) ON g.iCASEID=r.iMCASEID and g.iCOURTID = c.iMAINCOURTID
	WHERE r.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.caseid#">
	<cfif Attributes.EXTID GT 0>
		AND a.iADJCASEID=<cfqueryparam value="#Attributes.EXTID#" cfsqltype="CF_SQL_INTEGER">
	<cfelse>
		AND a.iADJCASEID=c.iMAIN_ADJCASEID
	</cfif>
	</CFQUERY>
	<CFIF q_trx.recordcount IS NOT 1>
		<cfthrow TYPE=EX_SECFAILED ErrorCode="BADCASE" ExtendedInfo="MTRchklimit-no adj offer dtls">
	</CFIF>
	<!--- convert from base currency to local currency for approval limit verification. [MAXMANDATE] will be ignore if -ve --->
	<cfset q_trx=#request.DS.FN.SVCCurrencyQueryBaseToLocal(q_trx,"TOTAMT,MAXMANDATE,NETTAMT","MAXMANDATE")#>
	
	<CFSET accresult=Request.DS.MTRFN.MTRgetUserCasePolGrpAcc(attributes.LIMITCODE,Attributes.USID,0,0,q_trx.iCLMTYPEMASK,0,0,0)>
	<CFIF accresult.acc IS 1>
		<CFSET limit_amt=accresult.limit>
	<CFELSE>
		<CFSET limit_amt=0>
	</CFIF>
	<CFIF limit_amt IS -1>
		<CFSET limitstr=Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)&Server.SVClang("Unlimited",2025)>
	<CFELSE>
		<CFSET limitstr=Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)&FN.SVCNum(limit_amt)>
	</CFIF>

	<!--- If Supplementary: Check for previous amounts and add it --->
	<CFSET CLMTYPE=Trim(q_trx.CLMTYPE)><!--- CFSET limit_amt=q_trx.MAXMANDATE --->
	<CFSET ADJOFRAUTH=q_trx.ADJOFRAUTH>
	<CFSET ADJOFRFLAG=q_trx.iADJOFR>
	<CFSET ADJGCOID=Request.DS.CO[q_trx.iCOID].GCOID>
	<CFSET ADJOFRVRFON=q_trx.dtADJOFRVRFON>
	<CFSET NETTAMT=q_trx.NETTAMT>
	<CFSET TOTAMT=q_trx.TOTAMT>
	<CFSET OFRDTL=q_trx.siOFRDTL>
	<CFIF Attributes.CASEID IS NOT q_trx.iMCASEID>
		<cfquery NAME=q_supp DATASOURCE=#Request.MTRDSN#>
		SELECT TOTAMT_PREV=Sum(b.mnTOTALL2),NETTAMT_PREV=Sum(IsNull(b.mnTOTCLM,0)+IsNull(b.mnTOTDEDUCT,0))
		FROM TRX0002 a WITH (NOLOCK),
			TRX0035 b WITH (NOLOCK),
			TRX0002 c WITH (NOLOCK)
				INNER JOIN TRX0008 i WITH (NOLOCK) ON c.iCASEID=i.iCASEID AND c.iADJCASEID=i.iMAIN_ADJCASEID
		WHERE b.iMCASEID=<cfqueryparam value="#q_trx.iMCASEID#" cfsqltype="CF_SQL_INTEGER"> AND c.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CASEID#">
			AND a.iCASEID=b.iLCASEID AND b.aCOTYPE='A' AND a.dtINSSBMT IS NOT NULL AND a.dtINSSBMT<IsNull(c.dtINSSBMT,getdate())
		</cfquery>
		<!--- convert from base currency to local currency for approval limit verification --->
		<cfset q_supp=#request.DS.FN.SVCCurrencyQueryBaseToLocal(q_supp,"TOTAMT_PREV,NETTAMT_PREV")#>
		<CFSET TOTAMT=TOTAMT+Val(q_supp.TOTAMT_PREV)>
		<CFSET NETTAMT=NETTAMT+Val(q_supp.NETTAMT_PREV)>
	</CFIF>
	<!--- Sg-AIG/Sg-Etiqa --->
	<CFIF Attributes.LOCID EQ 2 AND CLMTYPE IS "TP">
		<CFSET claim_amt=NETTAMT>
		<CFSET li_mandate=1>
	<CFELSE>
		<CFSET claim_amt=TOTAMT>
		<CFSET li_mandate=0>
	</CFIF>

	<CFSET result=0>

	<CFIF StructKeyExists(Attributes.CHKPARAM,"RPTTYPE") AND Attributes.CHKPARAM.RPTTYPE IS NOT "">
		<CFSET RptType=Attributes.CHKPARAM.RPTTYPE>
	<CFELSE>
		<CFSET RptType=4>
	</CFIF>

	<CFSET Chk_Personal_Limit=0>
	<CFIF RptType IS 4>
		<CFSET Chk_Personal_Limit=1>
	<CFELSE>
		<CFMODULE TEMPLATE="#Request.LOGPATH#CustomTags\GETATTR.cfm" ATTRID=83 ID=#ADJGCOID#>
		<CFIF AttrValue IS NOT "" AND IsNumeric(AttrValue) AND BitAnd(AttrValue,1) IS 1>
			<CFSET Chk_Personal_Limit=1>
		</CFIF>
	</CFIF>

	<CFIF Chk_Personal_Limit IS 1 AND NOT(limit_amt IS -1 OR Val(limit_amt) GTE Val(claim_amt))>
		<CFSET result=4>
		<CFSET resultstr=resultstr&"<br>#Server.SVClang("The claim amount exceeds your approval limit",7470)# [#Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(claim_amt)# -> #limitstr#]">
	<CFELSEIF RptType IS 4>
		<cfif BitAnd(ADJOFRAUTH,1) IS 0>
			<CFSET result=1>
			<CFSET resultstr="Mandate not given for direct offer.">
		<cfelse>
			<CFSET limit_amt=q_trx.MAXMANDATE><!--- limit_amt as MAX mandate for following check --->
			<CFSET result=2>
			<cfif BitAnd(ADJOFRAUTH,8) IS 8>
				<CFSET result=BitOr(result,1+16)>
				<CFSET resultstr=Server.SVClang("The insurer has withdrawn allowing adjuster authorizing offer directly on their behalf.",5922)>
			<CFELSEIF BitAnd(ADJOFRAUTH,4) IS 4>
				<CFSET result=BitOr(result,1+16)>
				<CFSET resultstr=Server.SVClang("The insurer has given adjuster a maximum mandate of {0} to authorize directly on their behalf,<br>but the adjuster has disabled direct offer mode.",5923,0,"#Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(limit_amt)#")>
			<cfelseif (claim_amt GT limit_amt)
					AND NOT(q_trx.siTPSETTLETYPE IS 1 OR BitAnd(ADJOFRFLAG,512))><!--- Exclude check for Litigated case --->
				<CFSET result=BitOr(result,1)>
				<CFSET resultstr=Server.SVClang("Adjuster recommendation {0} exceeds max mandate of {1} given by the insurer for direct offer.",5924,0,"#Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(claim_amt)#","#Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(limit_amt)#")>
				<CFIF BitAnd(result,1) GT 0 AND BitAnd(ADJOFRAUTH,16+12) IS 16>
					<CFSET resultstr=resultstr&"<br>#Server.SVClang("Adjuster must seek a new mandate from insurer.",7556)#">
				</CFIF>
			<!--- CUSTOM CODE START --->
			<cfelseif Attributes.INSGCOID IS 200798 AND limit_amt GT 30000 AND claim_amt NEQ limit_amt>
				<CFSET result=BitOr(result,1)>
				<CFSET resultstr="#Request.DS.CO[Attributes.INSGCOID].CONAME#: Adj Offer amount must equal to Mandate amount if >30K">
			<!--- CUSTOM CODE END --->
			<cfelseif ADJOFRVRFON IS "" AND NOT(OFRDTL GT 0 AND BITAND(OFRDTL,64) GT 0) AND BitAnd(ADJOFRAUTH,1024) IS 0>
				<CFSET result=BitOr(result,1+8)>
				<CFIF ListFind(Attributes.HIDESTR,"ADJ_NOTVERIFIED") EQ 0>
					<CFSET resultstr=Server.SVClang("Adjuster Letter/DV not verified.",7557)>
				</CFIF>
			</CFIF>
			<CFIF BitAnd(result,1) GT 0 AND BitAnd(ADJOFRAUTH,16+12) IS 16>
				<!--- If not disabled by ins./adj. and ext. adj processing mode, then must seek mandate/cannot submit adj. rpt direct --->
				<CFSET result=BitOr(result,4)>
			</CFIF>
		</CFIF>
	</CFIF>
	<CFSET limit_amt=q_trx.MAXMANDATE>
<CFELSEIF Attributes.CHKTYPE IS "SOL-MD"><!--- Solicitor Mandate --->
    <CFQUERY NAME=q_trx DATASOURCE=#Request.MTRDSN#>
    SELECT a.iCLMTYPEMASK,iINSCLASSID=ISNULL(a.iINSCLASSID,0),iINSPOLID=ISNULL(a.iINSPOLID,0),iINSBUSID=ISNULL(a.iINSBUSID,0),
		mnMAXMANDATE=IsNull(b.mnMAXMANDATE,0),mnMDLEGALCOST=IsNull(b.mnMDLEGALCOST,0),mnTOTPARTS=IsNull(c.mnTOTPARTS,0),
		iSOLOFRAUTH=IsNull(a.iSOLOFRAUTH,0),b.mnMAXSETTLE,c.iRULESETID
	FROM TRX0008 a WITH (NOLOCK)
		INNER JOIN TRX0061 b WITH (NOLOCK) ON a.iCASEID=b.iCASEID AND b.iCOROLE=512
		LEFT JOIN TRX0035 c WITH (NOLOCK) ON c.iLCASEID=a.iCASEID AND c.aCOTYPE='I'
    WHERE a.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CASEID#"> AND a.siTPINS=<cfqueryparam cfsqltype="CF_SQL_SMALLINT" value="#Attributes.TPINS#">
	</CFQUERY>
    <CFIF q_trx.recordcount IS NOT 1>
        <cfthrow TYPE=EX_SECFAILED ErrorCode="BADCASE" ExtendedInfo="MTRchklimit-no solicitor offer dtls">
    </CFIF>
	<!--- convert from base currency to local currency for approval limit verification. [mnMAXMANDATE] will be ignore if -ve --->
	<cfset q_trx=#request.DS.FN.SVCCurrencyQueryBaseToLocal(q_trx,"mnMAXMANDATE,mnMDLEGALCOST,mnTOTPARTS,mnMAXSETTLE","mnMAXMANDATE")#>
	
    <CFSET accresult=Request.DS.MTRFN.MTRgetUserCasePolGrpAcc(attributes.LIMITCODE,Attributes.USID,0,0,q_trx.iCLMTYPEMASK,q_trx.iINSCLASSID,q_trx.iINSPOLID,q_trx.iINSBUSID)>
	<CFIF accresult.acc IS 1>
        <cfset limit_amt=accresult.limit>
    <CFELSE>
        <CFSET limit_amt=0>
    </CFIF>
    <CFIF limit_amt IS -1>
        <CFSET limitstr=Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)&Server.SVClang("Unlimited",2025)>
    <CFELSE>
        <CFSET limitstr=Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)&FN.SVCNum(limit_amt)>
    </CFIF>
	<cfset claim_amt=q_trx.mnTOTPARTS>
	<cfset mandate_amt=Attributes.MANDATEAMT>
	<cfif Attributes.MANDATEAMT2 IS NOT "">
		<cfset mandate_amt+=Attributes.MANDATEAMT2>
	</cfif>
	<cfif BitAnd(q_trx.iSOLOFRAUTH,2)>
		<cfif q_trx.mnMAXSETTLE GT 0 AND mandate_amt GT q_trx.mnMAXSETTLE>
			<CFSET resultstr="Total mandate amount has exceeded max settlement amount [#Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(mandate_amt)# -> #Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(q_trx.mnMAXSETTLE)#]">
		<cfelseif q_trx.iRULESETID GT 0 AND claim_amt GT 0 AND Attributes.MANDATEAMT GT claim_amt>
			<CFSET resultstr="Mandate amount has exceeded total worksheet amount [#Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(Attributes.MANDATEAMT)# -> #Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(claim_amt)#]">
		</cfif>
	<cfelse>
		<cfif NOT(limit_amt IS -1 OR limit_amt GTE mandate_amt)>
			<CFSET resultstr="Total mandate amount has exceeded your approval limit [#Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(mandate_amt)# -> #limitstr#]">
		</cfif>
	</cfif>
    <CFSET result=0>
    <cfset li_mandate=0>
<CFELSEIF Attributes.CHKTYPE IS "SOL-AP"><!--- Solicitor Approval Limit check --->
    <CFQUERY NAME=q_trx DATASOURCE=#Request.MTRDSN#>
    SELECT a.iCLMTYPEMASK,iINSCLASSID=ISNULL(a.iINSCLASSID,0),iINSPOLID=ISNULL(a.iINSPOLID,0),iINSBUSID=ISNULL(a.iINSBUSID,0),
		mnMAXMANDATE=IsNull(b.mnMAXMANDATE,0),mnMDLEGALCOST=IsNull(b.mnMDLEGALCOST,0),mnTOTPARTS=IsNull(c.mnTOTPARTS,0),
		iSOLOFRAUTH=IsNull(a.iSOLOFRAUTH,0),b.mnMAXSETTLE
	FROM TRX0008 a WITH (NOLOCK)
		INNER JOIN TRX0061 b WITH (NOLOCK) ON a.iCASEID=b.iCASEID AND b.iCOROLE=512
		LEFT JOIN TRX0035 c WITH (NOLOCK) ON c.iLCASEID=a.iCASEID AND c.aCOTYPE='I'
    WHERE a.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CASEID#"> AND a.siTPINS=<cfqueryparam cfsqltype="CF_SQL_SMALLINT" value="#Attributes.TPINS#">
	</CFQUERY>
	<!--- convert from base currency to local currency for approval limit verification. [mnMAXMANDATE] will be ignore if -ve --->
	<cfset q_trx=#request.DS.FN.SVCCurrencyQueryBaseToLocal(q_trx,"mnMAXMANDATE,mnMDLEGALCOST,mnTOTPARTS,mnMAXSETTLE","mnMAXMANDATE")#>
	
    <CFIF q_trx.recordcount IS NOT 1>
        <cfthrow TYPE=EX_SECFAILED ErrorCode="BADCASE" ExtendedInfo="MTRchklimit-no solicitor offer dtls">
    </CFIF>
    <CFSET accresult=Request.DS.MTRFN.MTRgetUserCasePolGrpAcc(attributes.LIMITCODE,Attributes.USID,0,0,q_trx.iCLMTYPEMASK,q_trx.iINSCLASSID,q_trx.iINSPOLID,q_trx.iINSBUSID)>
	<CFIF accresult.acc IS 1>
        <cfset limit_amt=accresult.limit>
    <CFELSE>
        <CFSET limit_amt=0>
    </CFIF>
    <CFIF limit_amt IS -1>
        <CFSET limitstr=Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)&Server.SVClang("Unlimited",2025)>
    <CFELSE>
        <CFSET limitstr=Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)&FN.SVCNum(limit_amt)>
    </CFIF>
	<cfset claim_amt=q_trx.mnTOTPARTS>
	<cfset mandate_amt=Attributes.MANDATEAMT>
	<cfif NOT(limit_amt IS -1 OR limit_amt GTE mandate_amt)>
		<CFSET resultstr="Amount has exceeded your approval limit [#Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(mandate_amt)# -> #limitstr#]">
	</cfif>
    <CFSET result=0>
    <cfset li_mandate=0>
<CFELSEIF Attributes.CHKTYPE IS "ADJ-MD"><!--- Adjuster Mandate (new style) --->
    <CFQUERY NAME=q_trx DATASOURCE=#Request.MTRDSN#>
    SELECT a.iCLMTYPEMASK,iINSCLASSID=ISNULL(a.iINSCLASSID,0),iINSPOLID=ISNULL(a.iINSPOLID,0),iINSBUSID=ISNULL(a.iINSBUSID,0),
		mnMAXMANDATE=IsNull(b.mnMAXMANDATE,0),mnMDLEGALCOST=IsNull(b.mnMDLEGALCOST,0),mnTOTPARTS=IsNull(c.mnTOTPARTS,0),
		iADJOFRAUTH=IsNull(b.iADJOFRAUTH,0),b.mnMAXSETTLE
	FROM TRX0008 a WITH (NOLOCK)
		INNER JOIN TRX0002 b WITH (NOLOCK) ON a.iCASEID=b.iCASEID
		LEFT JOIN TRX0035 c WITH (NOLOCK) ON c.iLCASEID=a.iCASEID AND c.aCOTYPE='I'
    WHERE a.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CASEID#"> AND a.siTPINS=<cfqueryparam cfsqltype="CF_SQL_SMALLINT" value="#Attributes.TPINS#">
	<cfif Attributes.EXTID GT 0>
		AND b.iADJCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.EXTID#">
	<cfelse>
		AND b.iADJCASEID=a.iMAIN_ADJCASEID
	</cfif>
	</CFQUERY>
	<!--- convert from base currency to local currency for approval limit verification. [mnMAXMANDATE] will be ignore if -ve --->
	<cfset q_trx=#request.DS.FN.SVCCurrencyQueryBaseToLocal(q_trx,"mnMAXMANDATE,mnMDLEGALCOST,mnTOTPARTS,mnMAXSETTLE","mnMAXMANDATE")#>
	
    <CFIF q_trx.recordcount IS NOT 1>
        <cfthrow TYPE=EX_SECFAILED ErrorCode="BADCASE" ExtendedInfo="MTRchklimit-no adj offer dtls">
    </CFIF>
    <CFSET accresult=Request.DS.MTRFN.MTRgetUserCasePolGrpAcc(attributes.LIMITCODE,Attributes.USID,0,0,q_trx.iCLMTYPEMASK,q_trx.iINSCLASSID,q_trx.iINSPOLID,q_trx.iINSBUSID)>
	<CFIF accresult.acc IS 1>
        <cfset limit_amt=accresult.limit>
    <CFELSE>
        <CFSET limit_amt=0>
    </CFIF>
    <CFIF limit_amt IS -1>
        <CFSET limitstr=Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)&Server.SVClang("Unlimited",2025)>
    <CFELSE>
        <CFSET limitstr=Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)&FN.SVCNum(limit_amt)>
    </CFIF>
	<cfset claim_amt=q_trx.mnTOTPARTS>
	<cfset mandate_amt=Attributes.MANDATEAMT>
	<cfif Attributes.MANDATEAMT2 IS NOT "">
		<cfset mandate_amt+=Attributes.MANDATEAMT2>
	</cfif>
	<cfif BitAnd(q_trx.iADJOFRAUTH,1)>
		<cfif q_trx.mnMAXSETTLE GT 0 AND mandate_amt GT q_trx.mnMAXSETTLE>
			<CFSET resultstr="Total mandate amount has exceeded max settlement amount [#Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(mandate_amt)# -> #Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(q_trx.mnMAXSETTLE)#]">
		<cfelseif claim_amt GT 0 AND Attributes.MANDATEAMT GT claim_amt>
			<CFSET resultstr="Mandate amount has exceeded total worksheet amount [#Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(Attributes.MANDATEAMT)# -> #Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(claim_amt)#]">
		</cfif>
	<cfelse>
		<cfif NOT(limit_amt IS -1 OR limit_amt GTE mandate_amt)>
			<CFSET resultstr="Total mandate amount has exceeded your approval limit [#Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(mandate_amt)# -> #limitstr#]">
		</cfif>
	</cfif>
    <CFSET result=0>
    <cfset li_mandate=0>
<CFELSEIF Attributes.CHKTYPE IS "ADJ-AP"><!--- Adjuster Approval Limit check (new style) --->
    <CFQUERY NAME=q_trx DATASOURCE=#Request.MTRDSN#>
    SELECT a.iCLMTYPEMASK,iINSCLASSID=ISNULL(a.iINSCLASSID,0),iINSPOLID=ISNULL(a.iINSPOLID,0),iINSBUSID=ISNULL(a.iINSBUSID,0),
		mnMAXMANDATE=IsNull(b.mnMAXMANDATE,0),mnMDLEGALCOST=IsNull(b.mnMDLEGALCOST,0),mnTOTPARTS=IsNull(c.mnTOTPARTS,0),
		iADJOFRAUTH=IsNull(b.iADJOFRAUTH,0),b.mnMAXSETTLE
	FROM TRX0008 a WITH (NOLOCK)
		INNER JOIN TRX0002 b WITH (NOLOCK) ON a.iCASEID=b.iCASEID
		LEFT JOIN TRX0035 c WITH (NOLOCK) ON c.iLCASEID=a.iCASEID AND c.aCOTYPE='I'
    WHERE a.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CASEID#"> AND a.siTPINS=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.TPINS#">
	<cfif Attributes.EXTID GT 0>
		AND b.iADJCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.EXTID#">
	<cfelse>
		AND b.iADJCASEID=a.iMAIN_ADJCASEID
	</cfif>
	</CFQUERY>
	<!--- convert from base currency to local currency for approval limit verification. [mnMAXMANDATE] will be ignore if -ve --->
	<cfset q_trx=#request.DS.FN.SVCCurrencyQueryBaseToLocal(q_trx,"mnMAXMANDATE,mnMDLEGALCOST,mnTOTPARTS,mnMAXSETTLE","mnMAXMANDATE")#>
	
    <CFIF q_trx.recordcount IS NOT 1>
        <cfthrow TYPE=EX_SECFAILED ErrorCode="BADCASE" ExtendedInfo="MTRchklimit-no adj offer dtls">
    </CFIF>
    <CFSET accresult=Request.DS.MTRFN.MTRgetUserCasePolGrpAcc(attributes.LIMITCODE,Attributes.USID,0,0,q_trx.iCLMTYPEMASK,q_trx.iINSCLASSID,q_trx.iINSPOLID,q_trx.iINSBUSID)>
	<CFIF accresult.acc IS 1>
        <cfset limit_amt=accresult.limit>
    <CFELSE>
        <CFSET limit_amt=0>
    </CFIF>
    <CFIF limit_amt IS -1>
        <CFSET limitstr=Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)&Server.SVClang("Unlimited",2025)>
    <CFELSE>
        <CFSET limitstr=Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)&FN.SVCNum(limit_amt)>
    </CFIF>
	<cfset claim_amt=q_trx.mnTOTPARTS>
	<cfset mandate_amt=Attributes.MANDATEAMT>
	<cfif NOT(limit_amt IS -1 OR limit_amt GTE mandate_amt)>
		<CFSET resultstr="Amount has exceeded your approval limit [#Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)##FN.SVCNum(mandate_amt)# -> #limitstr#]">
	</cfif>
    <CFSET result=0>
    <cfset li_mandate=0>
<CFELSE>
	<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="MTRchklimit-invalid CHKTYPE (#Attributes.CHKTYPE#)">
</CFIF>
<CFIF Attributes.DISPRESULT IS 1 AND resultstr IS NOT "">
	<CFOUTPUT><blockquote class=clsColorMsg><br>#resultstr#<br><br></blockquote></CFOUTPUT>
</CFIF>
<cfif Attributes.MODRESULT IS NOT "" AND (Not IsDefined("Caller.#ATTRIBUTES.MODRESULT#") OR Not IsStruct(Evaluate("Caller.#Attributes.MODRESULT#")))>
	<cfset "Caller.#ATTRIBUTES.MODRESULT#"=StructNew()>
</cfif>
<cfset "Caller.#ATTRIBUTES.MODRESULT#.claim_amt"=claim_amt>
<cfset "Caller.#ATTRIBUTES.MODRESULT#.limit_amt"=limit_amt>
<cfset "Caller.#ATTRIBUTES.MODRESULT#.mandatetype"=li_mandate>
<cfset "Caller.#ATTRIBUTES.MODRESULT#.result"=result>
<cfset "Caller.#ATTRIBUTES.MODRESULT#.resultstr"=resultstr>
