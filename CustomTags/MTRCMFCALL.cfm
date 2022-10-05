<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCDISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">
<!--- <CFSET CASEID = Attributes.CaseID> --->

<CFIF Attributes.CaseID GT 0>
	<CFSET CoType = Attributes.COTYPE>
	<CFSET GCOID = Attributes.GCOID>
	<CFIF GCOID is 4>
		<CFSET GCOID = 57>
	</CFIF>	
	<CFSET CMFClmTypeMask=Val(Request.DS.FN.SVCgetExtAttrLogic("COADMIN",0,"COATTR381",10,GCOID))>
	<CFIF Attributes.Type IS 2>	
		<CFSET Stages = "REPEST">
	<CFELSEIF Attributes.Type IS 3>
		<CFSET Stages = "ADJEST">
	<CFELSEIF Attributes.Type IS 4>
		<CFSET Stages = "INSAUTH">
	<CFELSE>
		<CFSET Stages = "INCOMING">	
	</CFIF>

	<CFQUERY NAME=q_snapitem DATASOURCE=#Application.MTRDSN#>
	SELECT 

	[MeriemenCASEID] = i.imaincaseid,
	--START policy

	[InsurerHostedID]=ICO.iCOUNTRYID,
	[InsurerName]=ICO.vaCONAME,
	[InsurerCode]=ICO.iGCOID,

	[PolicyNo]=R.vaPOLNO,
	[policyCoverage]=R.siPOLICYCOVER,
	[PolEffDate]=isnull(convert(varchar, R.dtPOLICYFR, 121),'1900-01-01'),
	[PolEndDate]=isnull(convert(varchar, R.dtPOLICYTO, 121),'1900-01-01'),
	[SumInsured]=I.mnSUMINSURED,
	--END policy

	--START vehicle
	[VehRegNo]=CASE WHEN LEFT(R.aCLAIMTYPE,2)='TP' THEN R.va3REGNO ELSE R.vaREGNO END,
	[VehEngNo]=BA.vaVDENGNO, 
	[VehChassis]=BA.vaVDCHANO,
	[VehManufacturer]=CR.vaMAN,
	[VehModel]=CR.vaMODEL,
	[VehType]=VTYPE.sivhtypeid,
	[VehColor]=CTYPE.siCOLORID,
	[SeatingCap]=BA.siVDCARRYCAP,
	[CarryingCapacity]=BA.iLOADCAP,
	[OdometerReading]=CAST(BA.iVDODO AS NVARCHAR(50))+' '+CASE WHEN siVDODOUNITS=0 THEN '' ELSE '' END,

		--START condition
		[GeneralCondition]=CASE
		WHEN BA.vaVCGENCON='E' THEN 0--'Excellent'
		WHEN BA.vaVCGENCON='G' THEN 1--'Good'
		WHEN BA.vaVCGENCON='F' THEN 2--'Fair'
		WHEN BA.vaVCGENCON='P' THEN 3--'Poor' 
		END,
		[VehicleStillDriveable]=CASE
		WHEN BA.siVCDRIVEABLE=0 THEN 'N' ELSE 'Y' END,
		[ConditionOfDamage]=CASE
		WHEN BA.siCONDAMAGE=1 THEN 0--'Minor'
		WHEN BA.siCONDAMAGE=2 THEN 1--'Moderate'
		WHEN BA.siCONDAMAGE=3 THEN 2--'Serious'
		WHEN BA.siCONDAMAGE=4 THEN 3--'Very Serious' 
		END,
		--END condition

		--START tyres
		[FrontTyreTreads]=BA.vaVCFLTREAD,
		[RLTyreTreads]=BA.vaVCFRTREAD,
		[FRTyreTreads]=BA.vaVCRLTREAD,
		[RRTyreTreads]=BA.vaVCRRTREAD,
		[SpTyreTread]=BA.siVCSPTREAD,
		--END tyres

	[Marketvalue]=<CFIF Cotype IS 'R'>CR.mnDMKTVALUE
				  <CFELSEIF Cotype IS 'A'>ADJ.mnDMKTVALUE
				  <CFELSE> CA.mnDMKTVALUE
				  </CFIF>,

	--END vehicle


	--START accident
	[CaseID]=I.iCASEID,
	[LossDate]=convert(varchar,  R.dtACCDATE, 121),
	[LossType]=DAM.vacfcode,
	[NatureOfLoss]=CIR.vacfcode,
	[DescAccLoss]=REPLACE(REPLACE(REPLACE(BA.vaCDLOSSDESC, CHAR(13),' '), CHAR(10),' '),'|',''),
	[AccPlace]=BA.vaCDACCPLACE,
	[AccLocType]=LOC.vacfcode,
	[ClaimStatus]=csts.sicstat,
	[ClmTyp]=RTRIM(R.aCLAIMTYPE),
	[ClaimNo]=I.vaCLMNO,

		--START financials
		[InitialEstimation]=R.mnINITIALEST,
		[TotalRsvAmt] = ISNULL(mrsv.mnAMT,CA.mntotall2),
		[TotalPaidAmt]=	CASE WHEN	(SELECT TOTALPAY =SUM(MNPAYAMT) FROM 
									FPAY0002 pay WITH (NOLOCK) 
									LEFT JOIN FPAY0020 pay2 WITH (NOLOCK) ON pay.IREQID=pay2.IREQID
									WHERE pay.iOBJID =I.ICASEID AND PAY.SISTATUS =0) IS NULL THEN ISNULL(CA.mntotall2,0) 
									ELSE 
									(SELECT TOTALPAY =SUM(MNPAYAMT) FROM 
									FPAY0002 pay WITH (NOLOCK) 
									LEFT JOIN FPAY0020 pay2 WITH (NOLOCK) ON pay.IREQID=pay2.IREQID
									WHERE pay.iOBJID =I.ICASEID AND PAY.SISTATUS =0)
									
									END,
		[TotalOSAmt]=ISNULL(ISNULL(mrsv.mnAMT,0)-(SELECT TOTALPAY =SUM(MNPAYAMT) FROM 
									FPAY0002 pay WITH (NOLOCK) 
									LEFT JOIN FPAY0020 pay2 WITH (NOLOCK) ON pay.IREQID=pay2.IREQID
									WHERE pay.iOBJID =I.ICASEID AND PAY.SISTATUS =0),0),
		[ExcessAmt]=ISNULL(I.mnEXCESS,0),
		--END financials

	[TotalLoss]= CASE WHEN I.siOFRTYPE=3 OR CA.siTOTALLOSS=1 OR ADJ.siTOTALLOSS=1 THEN 'Y'ELSE 'N' END,
	[TowingChargest]= CR.mnTOTTOW,

	--END accident

	-- START Insured Details
	[InsuredName]=CASE
	WHEN BA.vaCINAME='' THEN convert(varchar,hashbytes('MD5','EMPTY'),2)
	WHEN BA.vaCINAME=null THEN convert(varchar,hashbytes('MD5','NULL'),2)
	ELSE convert(varchar,hashbytes('MD5',UPPER(REPLACE(REPLACE(REPLACE(REPLACE(
				REPLACE(REPLACE(REPLACE(REPLACE(BA.vaCINAME,'!',''),'@',''),'-',''),'%',''),'^',''),'&',''),'*',''),' ',''))),2)
	END,
	[InsuredType]=CASE
	WHEN R.siCIID1TYPE=1 THEN 'C' 
	ELSE 'I' END,
	[InsuredID]=CASE
	WHEN BA.vaCINRIC='' THEN convert(varchar,hashbytes('MD5','EMPTY'),2)
	WHEN BA.vaCINRIC=null THEN convert(varchar,hashbytes('MD5','NULL'),2)
	ELSE convert(varchar,hashbytes('MD5',UPPER(REPLACE(REPLACE(REPLACE(REPLACE(
				REPLACE(REPLACE(REPLACE(REPLACE(BA.vaCINRIC,'!',''),'@',''),'-',''),'%',''),'^',''),'&',''),'*',''),' ',''))),2)
	END,
	[InsuredMarried]=BA.siCIMARITAL,
	[InsNationality]=CICOUNTRY.icountryid,
	[InsDOB]=CASE
	WHEN BA.dtCIDOB='' THEN convert(varchar,hashbytes('MD5','EMPTY'),2)
	WHEN BA.dtCIDOB=null THEN convert(varchar,hashbytes('MD5','NULL'),2)
	ELSE convert(varchar,hashbytes('MD5',UPPER(REPLACE(REPLACE(REPLACE(REPLACE(
				REPLACE(REPLACE(REPLACE(REPLACE(BA.dtCIDOB,'!',''),'@',''),'-',''),'%',''),'^',''),'&',''),'*',''),' ',''))),2)
	END,
	[InsAdd1]=CASE
	WHEN BA.vaCIADD1='' THEN convert(varchar,hashbytes('MD5','EMPTY'),2)
	WHEN BA.vaCIADD1=null THEN convert(varchar,hashbytes('MD5','NULL'),2)
	ELSE convert(varchar,hashbytes('MD5',UPPER(REPLACE(REPLACE(REPLACE(REPLACE(
				REPLACE(REPLACE(REPLACE(REPLACE(BA.vaCIADD1,'!',''),'@',''),'-',''),'%',''),'^',''),'&',''),'*',''),' ',''))),2)
	END,
	[InsAdd2]=CASE
	WHEN BA.vaCIADD2='' THEN convert(varchar,hashbytes('MD5','EMPTY'),2)
	WHEN BA.vaCIADD2=null THEN convert(varchar,hashbytes('MD5','NULL'),2)
	ELSE convert(varchar,hashbytes('MD5',UPPER(REPLACE(REPLACE(REPLACE(REPLACE(
				REPLACE(REPLACE(REPLACE(REPLACE(BA.vaCIADD2,'!',''),'@',''),'-',''),'%',''),'^',''),'&',''),'*',''),' ',''))),2)
	END,
	[InsCountry]=CICOUNTRY.icountryid,
	[InsState]=CISTATE.istateid,
	[InsCity]=CICITY.icityid,
	[InsPostCode]=BA.vaCIPOSTCODE,
	[InsContact]=CASE
	WHEN BA.vaCIPHONE1='' THEN convert(varchar,hashbytes('MD5','EMPTY'),2)
	WHEN BA.vaCIPHONE1=null THEN convert(varchar,hashbytes('MD5','NULL'),2)
	ELSE convert(varchar,hashbytes('MD5',UPPER(REPLACE(REPLACE(REPLACE(REPLACE(
				REPLACE(REPLACE(REPLACE(REPLACE(BA.vaCIPHONE1,'!',''),'@',''),'-',''),'%',''),'^',''),'&',''),'*',''),' ',''))),2)
	END,
	[InsOccup]=CIOCCU.siOCCUPATION,

		--Insured GST Details
		[GSTReg]=CASE
		WHEN BAB.siInsuredGSTReg=1 THEN 'Y'
		WHEN BAB.siInsuredGSTReg=0 THEN 'N' END,
		[GSTRegNo]=BAB.vaInsuredGstRegNo,
		[ItemUsed]=CASE
		WHEN BAB.siInsuredGstItemUsage=1 THEN 'B'
		WHEN BAB.siInsuredGstItemUsage=2 THEN 'P' END,

	--END Insured

	--START Driver Details
	[DrvName]=CASE
	WHEN BA.vaCDNAME='' THEN convert(varchar,hashbytes('MD5','EMPTY'),2)
	WHEN BA.vaCDNAME=null THEN convert(varchar,hashbytes('MD5','NULL'),2)
	ELSE convert(varchar,hashbytes('MD5',UPPER(REPLACE(REPLACE(REPLACE(REPLACE(
				REPLACE(REPLACE(REPLACE(REPLACE(BA.vaCDNAME,'!',''),'@',''),'-',''),'%',''),'^',''),'&',''),'*',''),' ',''))),2)
	END,
	[DrvID]=CASE
	WHEN BA.vaCDNRIC='' THEN convert(varchar,hashbytes('MD5','EMPTY'),2)
	WHEN BA.vaCDNRIC=null THEN convert(varchar,hashbytes('MD5','NULL'),2)
	ELSE convert(varchar,hashbytes('MD5',UPPER(REPLACE(REPLACE(REPLACE(REPLACE(
				REPLACE(REPLACE(REPLACE(REPLACE(BA.vaCDNRIC,'!',''),'@',''),'-',''),'%',''),'^',''),'&',''),'*',''),' ',''))),2)
	END,
	[DrvDOB]=CASE
	WHEN BA.dtCDDOB='' THEN convert(varchar,hashbytes('MD5','EMPTY'),2)
	WHEN BA.dtCDDOB=null THEN convert(varchar,hashbytes('MD5','NULL'),2)
	ELSE convert(varchar,hashbytes('MD5',UPPER(REPLACE(REPLACE(REPLACE(REPLACE(
				REPLACE(REPLACE(REPLACE(REPLACE(BA.dtCDDOB,'!',''),'@',''),'-',''),'%',''),'^',''),'&',''),'*',''),' ',''))),2)
	END,
	[DrvAdd1]=CASE
	WHEN BA.vaCDADD1='' THEN convert(varchar,hashbytes('MD5','EMPTY'),2)
	WHEN BA.vaCDADD1=null THEN convert(varchar,hashbytes('MD5','NULL'),2)
	ELSE convert(varchar,hashbytes('MD5',UPPER(REPLACE(REPLACE(REPLACE(REPLACE(
				REPLACE(REPLACE(REPLACE(REPLACE(BA.vaCDADD1,'!',''),'@',''),'-',''),'%',''),'^',''),'&',''),'*',''),' ',''))),2)
	END,
	[DrvAdd2]=CASE
	WHEN BA.vaCDADD2='' THEN convert(varchar,hashbytes('MD5','EMPTY'),2)
	WHEN BA.vaCDADD2=null THEN convert(varchar,hashbytes('MD5','NULL'),2)
	ELSE convert(varchar,hashbytes('MD5',UPPER(REPLACE(REPLACE(REPLACE(REPLACE(
				REPLACE(REPLACE(REPLACE(REPLACE(BA.vaCDADD2,'!',''),'@',''),'-',''),'%',''),'^',''),'&',''),'*',''),' ',''))),2)
	END,
	[DrvCountry]=CDCOUNTRY.iCOUNTRYID,
	[DrvState]=CDSTATE.istateid,
	[DrvCity]=CDCITY.iCITYID,
	[DrvPostCode]=BA.vaCDPOSTCODE,
	[DrvContact]=CASE
	WHEN BA.vaCDPHONE1='' THEN convert(varchar,hashbytes('MD5','EMPTY'),2)
	WHEN BA.vaCDPHONE1=null THEN convert(varchar,hashbytes('MD5','NULL'),2)
	ELSE convert(varchar,hashbytes('MD5',UPPER(REPLACE(REPLACE(REPLACE(REPLACE(
				REPLACE(REPLACE(REPLACE(REPLACE(BA.vaCDPHONE1,'!',''),'@',''),'-',''),'%',''),'^',''),'&',''),'*',''),' ',''))),2)
	END,
	[DrvOccup]=CDOCCU.siOCCUPATION,
	[DrvProvLics]=BA.vaDLICENSE,
	[DrvExpYr]=BA.siCDDRVEXP,
	--END Driver Details


	--START Claimant Details
	[ClmVehRegNo]=CASE WHEN LEFT(R.aCLAIMTYPE,2)='TP' THEN R.vaREGNO ELSE R.va3REGNO END,
	[ClmName]=CASE
	WHEN BAB.vaCLAIMANT='' THEN convert(varchar,hashbytes('MD5','EMPTY'),2)
	WHEN BAB.vaCLAIMANT=null THEN convert(varchar,hashbytes('MD5','NULL'),2)
	ELSE convert(varchar,hashbytes('MD5',UPPER(REPLACE(REPLACE(REPLACE(REPLACE(
				REPLACE(REPLACE(REPLACE(REPLACE(BAB.vaCLAIMANT,'!',''),'@',''),'-',''),'%',''),'^',''),'&',''),'*',''),' ',''))),2)
	END,
	[ClmID]=CASE
	WHEN BAB.vaCLMNRIC='' THEN convert(varchar,hashbytes('MD5','EMPTY'),2)
	WHEN BAB.vaCLMNRIC=null THEN convert(varchar,hashbytes('MD5','NULL'),2)
	ELSE convert(varchar,hashbytes('MD5',UPPER(REPLACE(REPLACE(REPLACE(REPLACE(
				REPLACE(REPLACE(REPLACE(REPLACE(BAB.vaCLMNRIC,'!',''),'@',''),'-',''),'%',''),'^',''),'&',''),'*',''),' ',''))),2)
	END,
	[ClmDOB]=CASE
	WHEN BAB.dtCLMDOB='' THEN convert(varchar,hashbytes('MD5','EMPTY'),2)
	WHEN BAB.dtCLMDOB=null THEN convert(varchar,hashbytes('MD5','NULL'),2)
	ELSE convert(varchar,hashbytes('MD5',UPPER(REPLACE(REPLACE(REPLACE(REPLACE(
				REPLACE(REPLACE(REPLACE(REPLACE(BAB.dtCLMDOB,'!',''),'@',''),'-',''),'%',''),'^',''),'&',''),'*',''),' ',''))),2)
	END,

	[ClmAdd1]=CASE
	WHEN BAB.vaCLMADD1='' THEN convert(varchar,hashbytes('MD5','EMPTY'),2)
	WHEN BAB.vaCLMADD1=null THEN convert(varchar,hashbytes('MD5','NULL'),2)
	ELSE convert(varchar,hashbytes('MD5',UPPER(REPLACE(REPLACE(REPLACE(REPLACE(
				REPLACE(REPLACE(REPLACE(REPLACE(BAB.vaCLMADD1,'!',''),'@',''),'-',''),'%',''),'^',''),'&',''),'*',''),' ',''))),2)
	END,
	[ClmAdd2]=CASE
	WHEN BAB.vaCLMADD2='' THEN convert(varchar,hashbytes('MD5','EMPTY'),2)
	WHEN BAB.vaCLMADD2=null THEN convert(varchar,hashbytes('MD5','NULL'),2)
	ELSE convert(varchar,hashbytes('MD5',UPPER(REPLACE(REPLACE(REPLACE(REPLACE(
				REPLACE(REPLACE(REPLACE(REPLACE(BAB.vaCLMADD2,'!',''),'@',''),'-',''),'%',''),'^',''),'&',''),'*',''),' ',''))),2)
	END,
	[ClmCountry]=CMCOUNTRY.icountryid,
	[ClmState]=CMSTATE.istateid,
	[ClmCity]=CMCITY.icityid,
	[ClmContact]=CASE
	WHEN BAB.vaCLMPHONE='' THEN convert(varchar,hashbytes('MD5','EMPTY'),2)
	WHEN BAB.vaCLMPHONE=null THEN convert(varchar,hashbytes('MD5','NULL'),2)
	ELSE convert(varchar,hashbytes('MD5',UPPER(REPLACE(REPLACE(REPLACE(REPLACE(
				REPLACE(REPLACE(REPLACE(REPLACE(BAB.vaCLMPHONE,'!',''),'@',''),'-',''),'%',''),'^',''),'&',''),'*',''),' ',''))),2)
	END,
	[ClmOccup]=CMOCCU.siOCCUPATION,
	[ClmPostCode]=BAB.vaCLMPCODE,

	--END Claimant Details

	--START Hire Purchase Details
	[HirePurchCo]=ISNULL(HPCO.vaFINCONAME,HPCO.vaCONAME),
	[HirePurchAdd1]=REPLACE(REPLACE(REPLACE(HPCO.vaADD1, CHAR(13),' '), CHAR(10),' '),'|',''),
	[HirePurchAdd2]=REPLACE(REPLACE(REPLACE(HPCO.vaADD2, CHAR(13),' '), CHAR(10),' '),'|',''),
	[HirePurchCountry]=HCOCOUNTRY.icountryid,
	[HirePurchState]=HCOSTATE.istateid,
	[HirePurchCity]=HCOCITY.icityid,
	[HirePurchPostCode]=HPCO.vaPOSTCODE,
	[HirePurchNo]=BA.vaVCHPNO,
	[OSAmt]=BA.mnCDHPBAL,
	[EarlySettlement]=BAB.mnEARLYSETTLE,

	--START Workshop Details
	[WrkName]=RCO.vaCONAME+' ('+RCO.vaCOBRNAME+')',
	[WrkContact] =RCO.vaMobileNo,
	[WrkGSTReg]=Case when RCO.bgstregistered = 1 then 'Y' ELSE 'N' END,
	[WkrRegNo]=RCO.vaTAXREGNO,
	[WrkFranType] =Case when I.iEFFFLAG&16=16 OR RCO.siFranchise = 1 then 'Y' ELSE 'N' END,
	[WrkPanelType] =Case when I.iEFFFLAG&2=2 then 'Y' ELSE 'N' END,  
	--Parts Details & labour details

	--Admission
	[DoctorName]=admission.vadocname,
	[HospName]=HOS.vaconame,
	[AdmissionDt]= convert(varchar,admission.dtchkin, 121),

	--PartDetails
	[PartsDiscount] =CA.siPARTDISCPC ,
	[TotalAdjusterEstimate] =Adj.mntotall2,
	[TotalRepairerEstimate] =CR.mntotall2,

	--PoliceDetails
	[PlcRptNo]=BA.vaCDPOLICEREF,
	[PlcRptDt]=convert(varchar, BA.dtCDPOLICERPT, 121),
	[PlcPIAM]=BA.vaCDPOLICEDCODE,

	[TotalLossType] =CASE WHEN i.siOFRTYPE=3 AND i.siTLTYPE=2 THEN 1 /* ATL */
					WHEN i.siOFRTYPE=3 AND i.siTLTYPE=1 THEN 2 /* CTL */
					END,
	[WSRepairType] =CASE WHEN CR.siWSRepair=0 OR CA.siWSRepair=0 OR ADJ.siWSRepair=0 THEN 1 
					WHEN CR.siWSRepair=1 OR CA.siWSRepair=1 OR ADJ.siWSRepair=1 THEN 2
					ELSE Null END

	FROM TRX0008 I WITH (NOLOCK)
	INNER JOIN TRX0001 R WITH (NOLOCK) ON I.iCASEID=R.iCASEID
	--LEFT JOIN TRX0002 A WITH (NOLOCK) ON I.iCASEID=A.iCASEID
	LEFT JOIN SEC0005 ICO WITH (NOLOCK) ON I.iCOID=ICO.iCOID
	LEFT JOIN SEC0005 RCO WITH (NOLOCK) ON RCO.iCOID=R.iCOID
	--LEFT JOIN SEC0005 ACO WITH (NOLOCK) ON ACO.iCOID=A.iCOID
	LEFT JOIN SYS0002 S WITH (NOLOCK) ON S.iSTATEID=RCO.iSTATEID
	LEFT JOIN SYS0003 C WITH (NOLOCK) ON C.iCITYID=RCO.iCITYID
	LEFT JOIN CMT0001 CMT WITH (NOLOCK) ON CMT.iOBJID=R.iCASEID
	--LEFT JOIN TRX0046 TX WITH (NOLOCK) ON TX.iINSCASEID=I.iINSCASEID
	LEFT JOIN TRX0055 BA WITH (NOLOCK) ON BA.iCASEID=R.iCASEID
	LEFT JOIN TRX0055B BAB WITH (NOLOCK) ON BAB.iCASEID=R.iCASEID
	LEFT JOIN TRX0035 CR WITH (NOLOCK) ON CR.iLCASEID=I.iCASEID AND CR.aCOTYPE='R'
	LEFT JOIN TRX0035 CA WITH (NOLOCK) ON CA.iLCASEID=I.iCASEID AND CA.aCOTYPE='I'
	LEFT JOIN TRX0035 Adj WITH (NOLOCK) ON Adj.iLCASEID=I.iCASEID AND Adj.aCOTYPE='A'
	--LEFT JOIN TRX0036 part WITH (NOLOCK) ON I.iCASEID=part.iLCASEID AND part.aCOTYPE='I'
	LEFT JOIN mpartsdb..CAT0021 VTYPE WITH (NOLOCK) ON BA.siVDVHTYPEID=VTYPE.siVHTYPEID
	LEFT JOIN CAT0024 CTYPE WITH (NOLOCK) ON CTYPE.siCOLORID=BA.siVDCOLORID
	LEFT JOIN SYS0003 CICITY WITH (NOLOCK) ON CICITY.iCITYID=BA.iCICITYID
	LEFT JOIN SYS0002 CISTATE WITH (NOLOCK) ON CISTATE.iSTATEID=CICITY.iSTATEID
	LEFT JOIN SYS0005 CICOUNTRY WITH (NOLOCK) ON CICOUNTRY.iCOUNTRYID=CICITY.iLCOUNTRYID
	LEFT JOIN SYS0003 CDCITY WITH (NOLOCK) ON CDCITY.iCITYID=BA.iCDCITYID
	LEFT JOIN SYS0002 CDSTATE WITH (NOLOCK) ON CDSTATE.iSTATEID=CDCITY.iSTATEID
	LEFT JOIN SYS0005 CDCOUNTRY WITH (NOLOCK) ON CDCOUNTRY.iCOUNTRYID=CDCITY.iLCOUNTRYID
	LEFT JOIN SYS0003 CMCITY WITH (NOLOCK) ON CMCITY.iCITYID=BAB.iCLMCITYID
	LEFT JOIN SYS0002 CMSTATE WITH (NOLOCK) ON CMSTATE.iSTATEID=CMCITY.iSTATEID
	LEFT JOIN SYS0005 CMCOUNTRY WITH (NOLOCK) ON CMCOUNTRY.iCOUNTRYID=CMCITY.iLCOUNTRYID
	LEFT JOIN SYS0005 CCOUNTRY WITH (NOLOCK) ON BAB.iCLMNATIONALITYID=CCOUNTRY.iCOUNTRYID
	LEFT JOIN SYS0018 CIOCCU WITH (NOLOCK) ON CIOCCU.siOCCUPATION=BA.siCIOCC
	LEFT JOIN SYS0018 CDOCCU WITH (NOLOCK) ON CDOCCU.siOCCUPATION=BA.siCDOCC
	LEFT JOIN SYS0018 CMOCCU WITH (NOLOCK) ON CMOCCU.siOCCUPATION=BA.siCLMOCC
	LEFT JOIN SEC0005 HPCO WITH (NOLOCK) ON HPCO.iCOID=BA.iCDFINCOID
	LEFT JOIN CAT0026 COLL WITH (NOLOCK) ON COLL.siCOLTYPE=BA.siCDCOLLTYPE
	LEFT JOIN BIZ0025 DAM WITH (NOLOCK) ON DAM.iCOID IN (0) AND DAM.aCFTYPE='DAMTYPE' AND DAM.vaCFCODE=BA.siCDDAMTYPE AND DAM.iCLMTYPEMASK&I.iCLMTYPEMASK>0
	LEFT JOIN BIZ0025 CIR WITH (NOLOCK) ON CIR.iCOID IN (0) AND CIR.aCFTYPE='CIRACT' AND CIR.vaCFCODE=BA.iCDSTDLOSSDESC AND CIR.iCLMTYPEMASK&I.iCLMTYPEMASK>0
	LEFT JOIN BIZ0025 LOC WITH (NOLOCK) ON LOC.iCOID IN (0) AND LOC.aCFTYPE='LOCCLAIM' AND LOC.vaCFCODE=BA.siLOCCLAIM AND LOC.iCLMTYPEMASK&I.iCLMTYPEMASK>0
	LEFT JOIN SYS0003 LSCITY WITH (NOLOCK) ON LSCITY.iCITYID=BA.iCDLOSSCITY
	LEFT JOIN SYS0002 LSSTATE WITH (NOLOCK) ON LSSTATE.iSTATEID=LSCITY.iSTATEID
	LEFT JOIN SYS0005 LSCOUNTRY WITH (NOLOCK) ON LSCOUNTRY.iCOUNTRYID=LSCITY.iLCOUNTRYID
	LEFT JOIN SEC0001 ATTN WITH (NOLOCK) ON ATTN.vaUSID=I.vaATTNBY
	LEFT JOIN BIZ0002 csts WITH (NOLOCK) ON csts.siCSTAT=I.siCSTAT
	LEFT JOIN SYS0005 HCOCOUNTRY WITH (NOLOCK) ON HCOCOUNTRY.iCOUNTRYID=HPCO.iCOUNTRYID
	LEFT JOIN SYS0002 HCOSTATE WITH (NOLOCK) ON HCOSTATE.iSTATEID=HPCO.iSTATEID
	LEFT JOIN SYS0003 HCOCITY WITH (NOLOCK) ON HCOCITY.iCITYID=HPCO.iCITYID
	LEFT JOIN TRX0054 Lrsv WITH (NOLOCK) ON I.iCASEID=Lrsv.iCASEID
	LEFT JOIN CLM0026 Mrsv WITH (NOLOCK) ON Lrsv.iLASTRESVID=Mrsv.iRESVID AND Mrsv.iPURPOSE=1
	--LEFT JOIN FPAY0002 pay WITH (NOLOCK) ON I.iCASEID=pay.iOBJID
	--LEFT JOIN FPAY0020 pay2 WITH (NOLOCK) ON pay.IREQID=pay2.IREQID
	LEFT JOIN TRX0087 admission WITH (NOLOCK) ON admission.iCASEID=I.iCASEID
	LEFT JOIN SEC0005 HOS WITH (NOLOCK) ON HOS.iCOID=admission.iHOSCOID
	WHERE I.iCLMTYPEMASK&<cfqueryparam value="#CMFClmTypeMask#" cfsqltype="CF_SQL_INTEGER">>0
	--LEFT(R.aCLAIMTYPE,2)!='NM' AND R.aCLAIMTYPE in ('OD','OD KFK','WS')
	--AND I.iEFFFLAG&5=5
	AND I.siSTATUS=0 and I.iCASEID = <cfqueryparam value="#Attributes.CaseID#" cfsqltype="CF_SQL_INTEGER">
	</CFQUERY>


	<CFQUERY NAME=mainpart DATASOURCE=#Application.MTRDSN#>

	SELECT
	[actualprice] = p.ffdb,
	[subittedprice]=p.fval,
	[actualpartno]=p.vapartno,
	[sumittedpartno]=p.vapartno,
	[actualdescription]=p.vadesc,
	[submitteddescription]=p.vadesc,
	[SpecialDiscount] =CASE WHEN P.siDISCPC > 0 then isnull(p.siDISCPC/100,0) WHEN P.siDISCPC <> -2 then CA.siSPCDISCPC  ELSE 0 END,
	[Type] = CASE WHEN p.siPTYPE not in (1,2,3,6) THEN Null ELSE p.siPTYPE END,
	[combined]=CASE WHEN S.siCSTAT = 998 then 'Y' WHEN S.iMCASEID = s.iCASEID then 'M' ELSE 'N' END,
	[LabourCost] =CA.mnTOTPAINTMAT + CA.mnTOTPAIntwork + CA.mnTOTLAB,
	[ActualDmgType] =p.vadamcon,
	[TotalPartCost] =CA.mnTOTPARTS + CA.mnTOTPARTSDISC + CA.mnTOTSPCDISC,
	[TotalLabourCost] =CA.mnTOTPAINTMAT + CA.mnTOTPAIntwork + CA.mnTOTLAB,
	[PartsDiscount] =CA.siPARTDISCPC
	FROM TRX0008 I WITH (NOLOCK)
	INNER JOIN TRX0001 R WITH (NOLOCK) ON I.imaincaseid=r.iCASEID--I.iMAINCASEID=R.iMCASEID
	INNER JOIN TRX0001 S WITH (NOLOCK) ON S.iMCASEID=r.iMCASEID
	INNER JOIN TRX0036 P WITH (NOLOCK) ON S.iCASEID=P.ilCASEID and P.aCOTYPE=<cfqueryparam cfsqltype="CF_SQL_CHAR" value="#CoType#">
	LEFT JOIN TRX0035 CA WITH (NOLOCK) ON CA.iLCASEID=s.iCASEID  AND CA.aCOTYPE=<cfqueryparam cfsqltype="CF_SQL_CHAR" value="#CoType#">
	WHERE I.iCLMTYPEMASK&<cfqueryparam value="#CMFClmTypeMask#" cfsqltype="CF_SQL_INTEGER">>0
	--LEFT(R.aCLAIMTYPE,2)!='NM' AND R.aCLAIMTYPE in ('OD','OD KFK','WS')
	--AND I.iEFFFLAG&5=5
	AND I.siSTATUS=0 and S.iMCASEID = s.iCASEID AND I.iCASEID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CaseID#">
	</CFQUERY>


	<CFQUERY NAME=subcases DATASOURCE=#Application.MTRDSN#>
	SELECT distinct s.iCASEID,s.iMCASEID
	FROM TRX0008 I WITH (NOLOCK)
	INNER JOIN TRX0001 R WITH (NOLOCK) ON I.imaincaseid=r.iCASEID--I.iMAINCASEID=R.iMCASEID
	INNER JOIN TRX0001 S WITH (NOLOCK) ON S.iMCASEID=r.iMCASEID
	INNER JOIN TRX0036 P WITH (NOLOCK) ON S.iCASEID=P.ilCASEID and P.aCOTYPE=<cfqueryparam cfsqltype="CF_SQL_CHAR" value="#CoType#">
	LEFT JOIN TRX0035 CA WITH (NOLOCK) ON CA.iLCASEID=s.iCASEID  AND CA.aCOTYPE=<cfqueryparam cfsqltype="CF_SQL_CHAR" value="#CoType#">
	WHERE I.iCLMTYPEMASK&<cfqueryparam value="#CMFClmTypeMask#" cfsqltype="CF_SQL_INTEGER">>0
	--LEFT(R.aCLAIMTYPE,2)!='NM' AND R.aCLAIMTYPE in ('OD','OD KFK','WS')
	--AND I.iEFFFLAG&5=5
	AND I.siSTATUS=0 and S.iMCASEID != s.iCASEID AND I.iCASEID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CaseID#">
	</CFQUERY>

	<CFQUERY NAME=labour DATASOURCE=#Application.MTRDSN#>

	SELECT
	[MeriemenCASEID] = i.imaincaseid,
	[LabourDesc]=l.vaDESC,
	[RepairType]=CASE
	WHEN l.silabtype=0 THEN 'N'--'NEW'
	WHEN l.silabtype=2 THEN 'R' --'REPAIR'
	END,
	[combined]=CASE WHEN S.siCSTAT = 998 then 'Y' WHEN S.iMCASEID = s.iCASEID then 'M' ELSE 'N' END
	FROM TRX0008 I WITH (NOLOCK)
	INNER JOIN TRX0001 R WITH (NOLOCK) ON I.imaincaseid=R.iCASEID
	INNER JOIN TRX0001 S WITH (NOLOCK) ON S.iMCASEID=r.iMCASEID
	<CFIF q_snapitem.InsurerHostedID IS 1>
		INNER JOIN TRX0037 L WITH (NOLOCK) ON S.iCASEID=l.ilCASEID and L.aCOTYPE=<cfqueryparam cfsqltype="CF_SQL_CHAR" value="#CoType#">
	<CFELSEIF q_snapitem.InsurerHostedID IS 7>
		INNER JOIN TRX0039 L WITH (NOLOCK) ON S.iCASEID=l.ilCASEID and L.aCOTYPE=<cfqueryparam cfsqltype="CF_SQL_CHAR" value="#CoType#">
	</CFIF>
	WHERE I.iCLMTYPEMASK&<cfqueryparam value="#CMFClmTypeMask#" cfsqltype="CF_SQL_INTEGER">>0
	--LEFT(R.aCLAIMTYPE,2)!='NM' AND R.aCLAIMTYPE in ('OD','OD KFK','WS')
	--AND I.iEFFFLAG&5=5
	AND I.siSTATUS=0 and  I.iCASEID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CaseID#">

	</CFQUERY>



	<Cfquery NAME=History DATASOURCE=#Application.MTRDSN#>
	SELECT distinct
		[LossDate]=convert(varchar, c.dtACCDATE, 121),
		[PolicyNo]=c.vaPOLNO,
		[VehRegNo]= c.vaREGNO,
		[VehChassis]=BA.vaVDCHANO,
		[VehEngine]=BA.vaVDENGNO,
		[RepQuote]=CASE WHEN c.dtsubmit > 0 THEN 1 ELSE 0 END,
		[OfferPaidAmt]=Ins.mntotall2,
		[ClmTyp]=Rtrim(c.aCLAIMTYPE),
		[ClaimantID]=BAB.vaCLMNRIC,
		[InsuredID]=BA.vaCINRIC,
		[TotalLossType] =CASE WHEN i.siOFRTYPE=3 AND i.siTLTYPE=2 THEN 1 /* ATL */
						WHEN i.siOFRTYPE=3 AND i.siTLTYPE=1 THEN 2 /* CTL */
						ELSE 0 END,
		com.iGCOID 
		FROM FDIR3004 F WITH (NOLOCK)
		INNER JOIN (
		SELECT iOBJID,iSRCHTYPEID,vaSRCH 
		FROM (
		 SELECT *, iROW = ROW_NUMBER() OVER(PARTITION BY iOBJID ORDER BY vaSRCH DESC)
		 FROM FDIR3004 WITH (NOLOCK) 
		 WHERE iSRCHTYPEID = 1 
		) D 
		WHERE iROW = 1 and iOBJID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CaseID#">
		Union
		SELECT iOBJID,iSRCHTYPEID,vaSRCH FROM FDIR3004 ORI WITH (NOLOCK) 
		WHERE iOBJID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CaseID#"> 
		<CFIF q_snapitem.InsurerHostedID IS 1>
			AND	ORI.iSRCHTYPEID in (3,7,8) 
			AND ORI.vaSRCH NOT in 
			('OBSTRUCTED','NIL','TBA','NA','NOTSIGHTEDDUETOOBSTRUCTION','NOTSIGHTED','NOTSHOWN','NOTAVAILABLE','NOTADVISED')
		<CFELSEIF q_snapitem.InsurerHostedID IS 7>
			AND	ORI.iSRCHTYPEID in (7,8)
		</CFIF>
		)SRCH ON SRCH.vaSRCH = F.vaSRCH AND SRCH.iSRCHTYPEID = F.iSRCHTYPEID
		LEFT JOIN TRX0001 c   WITH (NOLOCK)ON F.iOBJID=c.iCASEID
		LEFT JOIN TRX0008 i WITH (NOLOCK) ON i.iCASEID=c.iCASEID
		LEFT JOIN TRX0055 BA WITH (NOLOCK) ON BA.iCASEID=c.iCASEID
		LEFT JOIN TRX0055B BAB WITH (NOLOCK) ON BAB.iCASEID=c.iCASEID
		LEFT JOIN TRX0035 Ins WITH (NOLOCK) ON ins.ilCASEID=c.iCASEID and ins.acoType = 'I'
		LEFT JOIN SEC0005 COM WITH (NOLOCK) ON c.iINSCOID = COM.iCOID

		WHERE I.siSTATUS=0 AND LEFT(c.aCLAIMTYPE,2)!='NM' AND c.aCLAIMTYPE NOT IN ('LU','SC','OD EXW','TP SB') AND F.iOBJID <> <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CaseID#">
	</Cfquery>



	<!--- <cfdump var = #q_snapitem4.RecordCount#> <cfabort> --->
	<CFOUTPUT query="q_snapitem">
		<CFIF InsurerHostedID IS 1>
			<cfset InsurerHosted = "Malaysia">
			<cfset SoapAction = "http://www.posthuma-partners.nl/CMF/Merimen/Pacific/">
			
		<CFELSEIF InsurerHostedID IS 7>
			<cfset InsurerHosted = "Indonesia">
			<cfset SoapAction = "http://www.posthuma-partners.nl/CMF/Merimen/AxaMandiri/">
		</CFIF>
	<Cfsavecontent variable="PP">
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:pp05="#SoapAction#">
	<soap:Header/>
	<soap:Body>
		<pp05:TestBatchFilter>
			<pp05:strXMLinput><![CDATA[<?xml version="1.0" encoding="utf-8"?><Input xmlns="http://www.posthuma-partners.nl/CMF/Merimen" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			  <Stage>#XmlFormat(Stages)#</Stage>
			  <Policy>
			    <InsurerHosted<CFIF InsurerHosted is ""> xsi:nil="true"</CFIF>>#XmlFormat(InsurerHosted)#</InsurerHosted>
			    <InsurerName<CFIF InsurerName is ""> xsi:nil="true"</CFIF>><CFIF InsurerCode IS 4 >The Pacific Insurance Berhad<CFELSE>#XmlFormat(InsurerName)#</CFIF>></InsurerName>
			    <InsurerCode<CFIF InsurerCode is ""> xsi:nil="true"</CFIF>><CFIF InsurerCode IS 4 >57<CFELSE>#XmlFormat(InsurerCode)#</CFIF></InsurerCode>
			    <PolicyNo<CFIF PolicyNo is ""> xsi:nil="true"</CFIF>>#XmlFormat(PolicyNo)#</PolicyNo>
			    <PolicyCoverage<CFIF PolicyCoverage is ""> xsi:nil="true"</CFIF>>#XmlFormat(policyCoverage)#</PolicyCoverage>
			    <PolEffDate<CFIF PolEffDate is ""> xsi:nil="true"</CFIF>>#XmlFormat(DateFormat(PolEffDate,'yyyy-mm-dd'))#</PolEffDate>
			    <PolEndDate<CFIF PolEndDate is ""> xsi:nil="true"</CFIF>>#XmlFormat(DateFormat(PolEndDate,'yyyy-mm-dd'))#</PolEndDate>
			    <SumInsured<CFIF SumInsured is ""> xsi:nil="true"</CFIF>><CFIF suminsured is NOT "">#XmlFormat(NumberFormat(suminsured,"99999.99"))#</CFIF></SumInsured>
			  </Policy>
			  <Vehicle>
			    <VehRegNo<CFIF VehRegNo is ""> xsi:nil="true"</CFIF>>#XmlFormat(VehRegNo)#</VehRegNo>
			    <VehEngNo><CFIF VehEngNo is ""> xsi:nil="true"</CFIF>#XmlFormat(VehEngNo)#</VehEngNo>
			    <VehChassis<CFIF VehChassis is ""> xsi:nil="true"</CFIF>>#XmlFormat(VehChassis)#</VehChassis>
			    <VehManufacturer<CFIF VehManufacturer is ""> xsi:nil="true"</CFIF>>#XmlFormat(VehManufacturer)#</VehManufacturer>
			    <VehModel<CFIF VehModel is ""> xsi:nil="true"</CFIF>>#XmlFormat(VehModel)#</VehModel>
			    <VehType<CFIF VehType is ""> xsi:nil="true"</CFIF>>#XmlFormat(VehType)#</VehType>
			    <VehColor<CFIF VehColor is ""> xsi:nil="true"</CFIF>>#XmlFormat(VehColor)#</VehColor>
			    <SeatingCap<CFIF SeatingCap is ""> xsi:nil="true"</CFIF>>#XmlFormat(SeatingCap)#</SeatingCap>
			    <CarryingCapacity<CFIF CarryingCapacity is ""> xsi:nil="true"</CFIF>>#XmlFormat(CarryingCapacity)#</CarryingCapacity>
			    <OdometerReading<CFIF OdometerReading is ""> xsi:nil="true"</CFIF>>#XmlFormat(OdometerReading)#</OdometerReading>
			    <Condition>
			      <GeneralCondition<CFIF GeneralCondition is ""> xsi:nil="true"</CFIF>>#XmlFormat(GeneralCondition)#</GeneralCondition>
			      <VehicleStillDriveable<CFIF VehicleStillDriveable is ""> xsi:nil="true"</CFIF>>#XmlFormat(VehicleStillDriveable)#</VehicleStillDriveable>
			      <ConditionOfDamage<CFIF ConditionOfDamage is ""> xsi:nil="true"</CFIF>>#XmlFormat(ConditionOfDamage)#</ConditionOfDamage>
			    </Condition>
			    <Tyres>
			      <FrontTyreTreads<CFIF FrontTyreTreads is ""> xsi:nil="true"</CFIF>>#XmlFormat(FrontTyreTreads)#</FrontTyreTreads>
			      <RLTyreTreads<CFIF RLTyreTreads is ""> xsi:nil="true"</CFIF>>#XmlFormat(RLTyreTreads)#</RLTyreTreads>
			      <SpTyreTread<CFIF SpTyreTread is ""> xsi:nil="true"</CFIF>>#XmlFormat(SpTyreTread)#</SpTyreTread>
			      <FRTyreTreads<CFIF FRTyreTreads is ""> xsi:nil="true"</CFIF>>#XmlFormat(FRTyreTreads)#</FRTyreTreads>
			      <RRTyreTreads<CFIF RRTyreTreads is ""> xsi:nil="true"</CFIF>>#XmlFormat(RRTyreTreads)#</RRTyreTreads>   
			    </Tyres>
			    <MarketValue<CFIF MarketValue is ""> xsi:nil="true"</CFIF>><CFIF MarketValue is NOT "">#XmlFormat(NumberFormat(Marketvalue,"99999.99"))#</CFIF></MarketValue>
			  </Vehicle>
			  <Accident>
			    <CaseID<CFIF CaseID is ""> xsi:nil="true"</CFIF>>#XmlFormat(CaseID)#</CaseID>
			    <LossDate<CFIF LossDate is ""> xsi:nil="true"</CFIF>>#XmlFormat(DateFormat(LossDate,"yyyy-MM-dd'T'HH:mm:ss.SSS"))#</LossDate>
			    <LossType<CFIF LossType is ""> xsi:nil="true"</CFIF>>#XmlFormat(LossType)#</LossType>
			    <NatureOfLoss<CFIF NatureOfLoss is ""> xsi:nil="true"</CFIF>>#XmlFormat(NatureOfLoss)#</NatureOfLoss>
			    <DescAccLoss<CFIF DescAccLoss is ""> xsi:nil="true"</CFIF>>#XmlFormat(DescAccLoss)#</DescAccLoss>
			    <AccPlace<CFIF AccPlace is ""> xsi:nil="true"</CFIF>>#XmlFormat(AccPlace)#</AccPlace>
			    <AccLocType<CFIF AccLocType is ""> xsi:nil="true"</CFIF>>#XmlFormat(AccLocType)#</AccLocType>
			    <ClaimStatus<CFIF ClaimStatus is ""> xsi:nil="true"</CFIF>>#XmlFormat(ClaimStatus)#</ClaimStatus>
			    <ClmTyp<CFIF ClmTyp is ""> xsi:nil="true"</CFIF>>#XmlFormat(ClmTyp)#</ClmTyp>
			    <ClaimNo<CFIF ClaimNo is ""> xsi:nil="true"</CFIF>>#XmlFormat(ClaimNo)#</ClaimNo>
			    <Financials>
			      <InitialEstimation<CFIF InitialEstimation is ""> xsi:nil="true"</CFIF>><CFIF InitialEstimation is NOT "">#XmlFormat(NumberFormat(InitialEstimation,"99999.99"))#</CFIF></InitialEstimation>
			      <TotalRsvAmt<CFIF TotalRsvAmt is ""> xsi:nil="true"</CFIF>><CFIF TotalRsvAmt is NOT "">#XmlFormat(NumberFormat(TotalRsvAmt,"99999.99"))#</CFIF></TotalRsvAmt>
			      <TotalPaidAmt<CFIF TotalPaidAmt is ""> xsi:nil="true"</CFIF>><CFIF TotalPaidAmt is NOT "">#XmlFormat(NumberFormat(TotalPaidAmt,"99999.99"))#</CFIF></TotalPaidAmt>
			      <TotalOSAmt<CFIF TotalOSAmt is ""> xsi:nil="true"</CFIF>><CFIF TotalOSAmt is NOT "">#XmlFormat(NumberFormat(TotalOSAmt,"99999.99"))#</CFIF></TotalOSAmt>
			      <ExcessAmt<CFIF ExcessAmt is ""> xsi:nil="true"</CFIF>><CFIF ExcessAmt is NOT "">#XmlFormat(NumberFormat(ExcessAmt,"99999.99"))#</CFIF></ExcessAmt>
			    </Financials>
			    <TotalLoss<CFIF TotalLoss is ""> xsi:nil="true"</CFIF>>#XmlFormat(TotalLoss)#</TotalLoss>
			    <TowingCharges<CFIF TowingChargest is ""> xsi:nil="true"</CFIF>><CFIF TowingChargest is NOT "">#XmlFormat(NumberFormat(TowingChargest,"99999.99"))#</CFIF></TowingCharges>
			    <WSRepairType<CFIF WSRepairType is "" OR ClmTyp is not "WS"> xsi:nil="true"</CFIF>><CFIF ClmTyp is "WS" >#XmlFormat(WSRepairType)#</CFIF></WSRepairType>
			  </Accident>
			  <Insured>
			    <InsuredName<CFIF InsuredName is ""> xsi:nil="true"</CFIF>>#XmlFormat(InsuredName)#</InsuredName>
			    <InsuredType<CFIF InsuredType is ""> xsi:nil="true"</CFIF>>#XmlFormat(InsuredType)#</InsuredType>
			    <InsuredID<CFIF InsuredID is ""> xsi:nil="true"</CFIF>>#XmlFormat(InsuredID)#</InsuredID>
			    <InsuredMarried<CFIF InsuredMarried is ""> xsi:nil="true"</CFIF>>#XmlFormat(InsuredMarried)#</InsuredMarried>
			    <InsNationality<CFIF InsNationality is ""> xsi:nil="true"</CFIF>>#XmlFormat(InsNationality)#</InsNationality>
			    <InsDOB<CFIF InsDOB is ""> xsi:nil="true"</CFIF>>#XmlFormat(InsDOB)#</InsDOB>
			    <InsAdd1<CFIF InsAdd1 is ""> xsi:nil="true"</CFIF>>#XmlFormat(InsAdd1)#</InsAdd1>
			    <InsAdd2<CFIF InsAdd2 is ""> xsi:nil="true"</CFIF>>#XmlFormat(InsAdd2)#</InsAdd2>
			    <InsCountry<CFIF InsCountry is ""> xsi:nil="true"</CFIF>>#XmlFormat(InsCountry)#</InsCountry>
			    <InsState<CFIF InsState is ""> xsi:nil="true"</CFIF>>#XmlFormat(InsState)#</InsState>
			    <InsCity<CFIF InsCity is ""> xsi:nil="true"</CFIF>>#XmlFormat(InsCity)#</InsCity>
			    <InsPostCode<CFIF InsPostCode is ""> xsi:nil="true"</CFIF>>#XmlFormat(InsPostCode)#</InsPostCode>
			    <InsContact<CFIF InsContact is ""> xsi:nil="true"</CFIF>>#XmlFormat(InsContact)#</InsContact>
			    <InsOccup<CFIF InsOccup is ""> xsi:nil="true"</CFIF>>#XmlFormat(InsOccup)#</InsOccup>
			    <GST>
			      <GSTReg<CFIF GSTReg is ""> xsi:nil="true"</CFIF>>#XmlFormat(GSTReg)#</GSTReg>
			      <GSTRegNo<CFIF GSTRegNo is ""> xsi:nil="true"</CFIF>>#XmlFormat(GSTRegNo)#</GSTRegNo>
			      <ItemUsed<CFIF ItemUsed is ""> xsi:nil="true"</CFIF>>#XmlFormat(ItemUsed)#</ItemUsed>
			    </GST>
			  </Insured>
			  <Driver>
			    <DrvName<CFIF DrvName is ""> xsi:nil="true"</CFIF>>#XmlFormat(DrvName)#</DrvName>
			    <DrvID<CFIF DrvID is ""> xsi:nil="true"</CFIF>>#XmlFormat(DrvID)#</DrvID>
			    <DrvDOB><CFIF DrvDOB is ""> xsi:nil="true"</CFIF>>#XmlFormat(DrvDOB)#</DrvDOB>
			    <DrvAdd1<CFIF DrvAdd1 is ""> xsi:nil="true"</CFIF>>#XmlFormat(DrvAdd1)#</DrvAdd1>
			    <DrvAdd2<CFIF DrvAdd2 is ""> xsi:nil="true"</CFIF>>#XmlFormat(DrvAdd2)#</DrvAdd2>
			    <DrvCountry<CFIF DrvCountry is ""> xsi:nil="true"</CFIF>>#XmlFormat(DrvCountry)#</DrvCountry>
			    <DrvState<CFIF DrvState is ""> xsi:nil="true"</CFIF>>#XmlFormat(DrvState)#</DrvState>
			    <DrvCity<CFIF DrvCity is ""> xsi:nil="true"</CFIF>>#XmlFormat(DrvCity)#</DrvCity>
			    <DrvPostCode<CFIF DrvPostCode is ""> xsi:nil="true"</CFIF>>#XmlFormat(DrvPostCode)#</DrvPostCode>
			    <DrvContact<CFIF DrvContact is ""> xsi:nil="true"</CFIF>>#XmlFormat(DrvContact)#</DrvContact>
			    <DrvOccup<CFIF DrvOccup is ""> xsi:nil="true"</CFIF>>#XmlFormat(DrvOccup)#</DrvOccup>
			    <DrvProvLics<CFIF DrvProvLics is ""> xsi:nil="true"</CFIF>>#XmlFormat(DrvProvLics)#</DrvProvLics>
			    <DrvExpYr<CFIF DrvExpYr is ""> xsi:nil="true"</CFIF>>#XmlFormat(DrvExpYr)#</DrvExpYr>
			  </Driver>
			  <Claimants>
			    <Claimant type="main">
			      <ClmVehRegNo<CFIF ClmVehRegNo is ""> xsi:nil="true"</CFIF>>#XmlFormat(ClmVehRegNo)#</ClmVehRegNo>
			      <ClmName<CFIF ClmName is ""> xsi:nil="true"</CFIF>>#XmlFormat(ClmName)#</ClmName>
			      <ClmID<CFIF ClmID is ""> xsi:nil="true"</CFIF>>#XmlFormat(ClmID)#</ClmID>
			      <ClmDOB<CFIF ClmDOB is ""> xsi:nil="true"</CFIF>>#XmlFormat(ClmDOB)#</ClmDOB>
			      <ClmAdd1<CFIF ClmAdd1 is ""> xsi:nil="true"</CFIF>>#XmlFormat(ClmAdd1)#</ClmAdd1>
			      <ClmAdd2<CFIF ClmAdd2 is ""> xsi:nil="true"</CFIF>>#XmlFormat(ClmAdd2)#</ClmAdd2>
			      <ClmCountry<CFIF ClmCountry is ""> xsi:nil="true"</CFIF>>#XmlFormat(ClmCountry)#</ClmCountry>
			      <ClmState<CFIF ClmState is ""> xsi:nil="true"</CFIF>>#XmlFormat(ClmState)#</ClmState>
			      <ClmCity<CFIF ClmCity is ""> xsi:nil="true"</CFIF>>#XmlFormat(ClmCity)#</ClmCity>
			      <ClmPostCode<CFIF ClmPostCode is ""> xsi:nil="true"</CFIF>>#XmlFormat(ClmPostCode)#</ClmPostCode>
			      <ClmContact<CFIF ClmContact is ""> xsi:nil="true"</CFIF>>#XmlFormat(ClmContact)#</ClmContact>
			      <ClmOccup<CFIF ClmOccup is ""> xsi:nil="true"</CFIF>>#XmlFormat(ClmOccup)#</ClmOccup>
			      <Admission>
			        <DoctorName<CFIF DoctorName is ""> xsi:nil="true"</CFIF>>#XmlFormat(DoctorName)#</DoctorName>
			        <HospName<CFIF HospName is ""> xsi:nil="true"</CFIF>>#XmlFormat(HospName)#</HospName>
			        <AdmissionDt<CFIF AdmissionDt is ""> xsi:nil="true"</CFIF>>#XmlFormat(AdmissionDt)#</AdmissionDt>
			      </Admission>
			    </Claimant>
			    <Claimant type="secondary">
				  <ClmVehRegNo xsi:nil="true"></ClmVehRegNo>
			      <ClmName xsi:nil="true"></ClmName>
			      <ClmID xsi:nil="true"></ClmID>
			      <ClmDOB xsi:nil="true"></ClmDOB>
			      <ClmAdd1 xsi:nil="true"></ClmAdd1>
			      <ClmAdd2 xsi:nil="true"></ClmAdd2>
			      <ClmCountry xsi:nil="true"></ClmCountry>
			      <ClmState xsi:nil="true"></ClmState>
			      <ClmCity xsi:nil="true"></ClmCity>
			      <ClmPostCode xsi:nil="true"></ClmPostCode>
			      <ClmContact xsi:nil="true"></ClmContact>
			      <ClmOccup xsi:nil="true"></ClmOccup>
			    </Claimant>
			  </Claimants>
			  <HirePurchase>
			    <HirePurchCo<CFIF HirePurchCo is ""> xsi:nil="true"</CFIF>>#XmlFormat(HirePurchCo)#</HirePurchCo>
			    <HirePurchAdd1<CFIF HirePurchAdd1 is ""> xsi:nil="true"</CFIF>>#XmlFormat(HirePurchAdd1)#</HirePurchAdd1>
			    <HirePurchAdd2<CFIF HirePurchAdd2 is ""> xsi:nil="true"</CFIF>>#XmlFormat(HirePurchAdd2)#</HirePurchAdd2>
			    <HirePurchCountry<CFIF HirePurchCountry is ""> xsi:nil="true"</CFIF>>#XmlFormat(HirePurchCountry)#</HirePurchCountry>
			    <HirePurchState<CFIF HirePurchState is ""> xsi:nil="true"</CFIF>>#XmlFormat(HirePurchState)#</HirePurchState>
			    <HirePurchCity<CFIF HirePurchCity is ""> xsi:nil="true"</CFIF>>#XmlFormat(HirePurchCity)#</HirePurchCity>
			    <HirePurchPostCode<CFIF HirePurchPostCode is ""> xsi:nil="true"</CFIF>>#XmlFormat(HirePurchPostCode)#</HirePurchPostCode>
			    <HirePurchNo<CFIF HirePurchNo is ""> xsi:nil="true"</CFIF>>#XmlFormat(HirePurchNo)#</HirePurchNo>
			    <Financials>
			      <OSAmt<CFIF OSAmt is ""> xsi:nil="true"</CFIF>><CFIF OSAmt is NOT "">#XmlFormat(NumberFormat(OSAmt,"99999.99"))#</CFIF></OSAmt>
			      <EarlySettlement<CFIF EarlySettlement is ""> xsi:nil="true"</CFIF>><CFIF EarlySettlement is NOT "">#XmlFormat(NumberFormat(EarlySettlement,"99999.99"))#</CFIF></EarlySettlement>
			    </Financials>
			  </HirePurchase>
			  <Workshop>
			    <WrkName<CFIF WrkName is ""> xsi:nil="true"</CFIF>>#XmlFormat(WrkName)#</WrkName>
			    <WrkGSTReg<CFIF WrkGSTReg is ""> xsi:nil="true"</CFIF>>#XmlFormat(WrkGSTReg)#</WrkGSTReg>
			    <WkrRegNo<CFIF WkrRegNo is ""> xsi:nil="true"</CFIF>>#XmlFormat(WkrRegNo)#</WkrRegNo>
			    <WrkContact<CFIF WrkContact is ""> xsi:nil="true"</CFIF>>#XmlFormat(WrkContact)#</WrkContact>
			    <WrkFranType<CFIF WrkFranType is ""> xsi:nil="true"</CFIF>>#XmlFormat(WrkFranType)#</WrkFranType>
	 			<WrkPanelType<CFIF WrkPanelType is ""> xsi:nil="true"</CFIF>>#XmlFormat(WrkPanelType)#</WrkPanelType>
			    <LabourParts>
			      <Parts>
			        <main>
			        <CFIF mainpart.RecordCount GT 0>	
			       	  <CFLOOP query="mainpart" startRow = "1" endRow  = "#mainpart.RecordCount#">	
			          <vehpart>
			            <ActualPartsPrice<CFIF mainpart.actualprice is ""> xsi:nil="true"</CFIF>><CFIF mainpart.actualprice is NOT "">#XmlFormat(NumberFormat(mainpart.actualprice,"99999.99"))#</CFIF></ActualPartsPrice>
			            <SubmittedPartsPrice<CFIF mainpart.subittedprice is ""> xsi:nil="true"</CFIF>><CFIF mainpart.subittedprice is NOT "">#XmlFormat(NumberFormat(mainpart.subittedprice,"99999.99"))#</CFIF></SubmittedPartsPrice>
			            <ActualPartsNo<CFIF mainpart.actualpartno is ""> xsi:nil="true"</CFIF>>#XmlFormat(mainpart.actualpartno)#</ActualPartsNo>
			            <SubmittedPartsNo<CFIF mainpart.sumittedpartno is ""> xsi:nil="true"</CFIF>>#XmlFormat(mainpart.sumittedpartno)#</SubmittedPartsNo>
			            <ActualPartsDescription<CFIF mainpart.actualdescription is ""> xsi:nil="true"</CFIF>>#XmlFormat(mainpart.actualdescription)#</ActualPartsDescription>
			            <SubmittedPartsDescription<CFIF mainpart.submitteddescription is ""> xsi:nil="true"</CFIF>>#XmlFormat(mainpart.submitteddescription)#</SubmittedPartsDescription>
			            <SpecialDiscount<CFIF mainpart.SpecialDiscount is ""> xsi:nil="true"</CFIF>><CFIF mainpart.SpecialDiscount is NOT "">#XmlFormat(NumberFormat(mainpart.SpecialDiscount,"99999.99"))#</CFIF></SpecialDiscount>
			            <PartsType<CFIF mainpart.Type is ""> xsi:nil="true"</CFIF>>#XmlFormat(mainpart.Type)#</PartsType>
			            <ActualDmgType<CFIF mainpart.ActualDmgType is ""> xsi:nil="true"</CFIF>>#XmlFormat(mainpart.ActualDmgType)#</ActualDmgType>
			          </vehpart>
			          </CFLOOP>
			         <CFELSE>
			      	  <vehpart>
			            <ActualPartsPrice xsi:nil="true"></ActualPartsPrice>
			            <SubmittedPartsPrice xsi:nil="true"></SubmittedPartsPrice>
			            <ActualPartsNo xsi:nil="true"></ActualPartsNo>
			            <SubmittedPartsNo xsi:nil="true"></SubmittedPartsNo>
			            <ActualPartsDescription xsi:nil="true"></ActualPartsDescription>
			            <SubmittedPartsDescription xsi:nil="true"></SubmittedPartsDescription>
			            <SpecialDiscount xsi:nil="true"></SpecialDiscount>
			            <PartsType xsi:nil="true"></PartsType>
			            <ActualDmgType xsi:nil="true"></ActualDmgType>
			          </vehpart>
			         </CFIF>
			         <CFIF mainpart.RecordCount GT 0> 
			          <LabourCost<CFIF mainpart.LabourCost is ""> xsi:nil="true"</CFIF>><CFIF mainpart.LabourCost is NOT "">#XmlFormat(NumberFormat(mainpart.LabourCost,"99999.99"))#</CFIF></LabourCost>
			         <CFELSE>
			          <LabourCost xsi:nil="true"></LabourCost>	
			         </CFIF>
			        </main>
			        <CFQUERY name="suppCases" dbtype="query">
						SELECT iCASEID FROM subcases WHERE iMCASEID=<cfqueryparam value="#caseid#" cfsqltype="CF_SQL_INTEGER">
					</CFQUERY>
					<CFIF suppCases.RecordCount GT 0>
						<CFLOOP query="suppCases">
							<CFQUERY NAME=subpart DATASOURCE=#Application.MTRDSN#>
								SELECT
								[actualprice] = p.ffdb,
								[subittedprice]=p.fval,
								[actualpartno]=p.vapartno,
								[sumittedpartno]=p.vapartno,
								[actualdescription]=p.vadesc,
								[submitteddescription]=p.vadesc,
								[SpecialDiscount] =CASE WHEN P.siDISCPC > 0 then isnull(p.siDISCPC/100,0) WHEN P.siDISCPC <> -2 then CA.siSPCDISCPC  ELSE 0 END,
								[Type] = CASE WHEN p.siPTYPE not in (1,2,3,6) THEN Null ELSE p.siPTYPE END,
								[Combined]=CASE WHEN S.siCSTAT = 998 then 'Y' WHEN S.iMCASEID = s.iCASEID then 'M' ELSE 'N' END,
								[LabourCost] =CA.mnTOTPAINTMAT + CA.mnTOTPAIntwork + CA.mnTOTLAB,
								[ActualDmgType] =p.vadamcon
								FROM TRX0008 I WITH (NOLOCK)
								INNER JOIN TRX0001 S WITH (NOLOCK) ON S.iCASEID=i.iCASEID
								INNER JOIN TRX0036 P WITH (NOLOCK) ON i.iCASEID=P.ilCASEID and P.aCOTYPE=<cfqueryparam cfsqltype="CF_SQL_CHAR" value="#CoType#">
								LEFT JOIN TRX0035 CA WITH (NOLOCK) ON CA.iLCASEID=p.iLCASEID  AND CA.aCOTYPE=<cfqueryparam cfsqltype="CF_SQL_CHAR" value="#CoType#">
								WHERE i.icaseid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iCASEID#">
							</CFQUERY>
							 <Supp>
			 				 <CFLOOP query="subpart" startRow = "1" endRow  = "#subpart.RecordCount#">
					          <vehpart>
					            <ActualPartsPrice<CFIF subpart.actualprice is ""> xsi:nil="true"</CFIF>><CFIF subpart.actualprice is NOT "">#XmlFormat(NumberFormat(subpart.actualprice,"99999.99"))#</CFIF></ActualPartsPrice>
					            <SubmittedPartsPrice<CFIF subpart.subittedprice is ""> xsi:nil="true"</CFIF>><CFIF subpart.subittedprice is NOT "">#XmlFormat(NumberFormat(subpart.subittedprice,"99999.99"))#</CFIF></SubmittedPartsPrice>
					            <ActualPartsNo<CFIF subpart.actualpartno is ""> xsi:nil="true"</CFIF>>#XmlFormat(subpart.actualpartno)#</ActualPartsNo>
					            <SubmittedPartsNo<CFIF subpart.sumittedpartno is ""> xsi:nil="true"</CFIF>>#XmlFormat(subpart.sumittedpartno)#</SubmittedPartsNo>
					            <ActualPartsDescription<CFIF subpart.actualdescription is ""> xsi:nil="true"</CFIF>>#XmlFormat(subpart.actualdescription)#</ActualPartsDescription>
					            <SubmittedPartsDescription<CFIF subpart.submitteddescription is ""> xsi:nil="true"</CFIF>>#XmlFormat(subpart.submitteddescription)#</SubmittedPartsDescription>
					            <SpecialDiscount<CFIF subpart.SpecialDiscount is ""> xsi:nil="true"</CFIF>><CFIF subpart.SpecialDiscount is NOT "">#XmlFormat(NumberFormat(subpart.SpecialDiscount,"99999.99"))#</CFIF></SpecialDiscount>
					            <PartsType<CFIF subpart.Type is ""> xsi:nil="true"</CFIF>>#XmlFormat(subpart.Type)#</PartsType>
					            <ActualDmgType<CFIF subpart.ActualDmgType is ""> xsi:nil="true"</CFIF>>#XmlFormat(subpart.ActualDmgType)#</ActualDmgType>
					          </vehpart>
					          </CFLOOP>
					          <LabourCost<CFIF subpart.LabourCost is ""> xsi:nil="true"</CFIF>><CFIF subpart.LabourCost is NOT "">#XmlFormat(NumberFormat(subpart.LabourCost,"99999.99"))#</CFIF></LabourCost>
					          <Combined<CFIF subpart.COMBINED is ""> xsi:nil="true"</CFIF>>#XmlFormat(subpart.COMBINED)#</Combined>
			      		  	</Supp>	
						</CFLOOP>
					</CFIF>
			        <TotalAdjusterEstimate<CFIF TotalAdjusterEstimate is ""> xsi:nil="true"</CFIF>><CFIF TotalAdjusterEstimate is NOT "">#XmlFormat(NumberFormat(TotalAdjusterEstimate,"99999.99"))#</CFIF></TotalAdjusterEstimate>
			        <TotalRepairerEstimate<CFIF TotalRepairerEstimate is ""> xsi:nil="true"</CFIF>><CFIF TotalRepairerEstimate is NOT "">#XmlFormat(NumberFormat(TotalRepairerEstimate,"99999.99"))#</CFIF></TotalRepairerEstimate>
			        <TotalLabourCost<CFIF mainpart.TotalLabourCost is ""> xsi:nil="true"</CFIF>><CFIF mainpart.TotalLabourCost is NOT "">#XmlFormat(NumberFormat(mainpart.TotalLabourCost,"99999.99"))#</CFIF></TotalLabourCost>
			        <TotalPartCost<CFIF mainpart.TotalPartCost is ""> xsi:nil="true"</CFIF>><CFIF mainpart.TotalPartCost is NOT "">#XmlFormat(NumberFormat(mainpart.TotalPartCost,"99999.99"))#</CFIF></TotalPartCost>
			      </Parts>
			      <Labours>
			      	<CFLOOP query="labour" startRow = "1" endRow  = "#labour.RecordCount#">
			        <Labour>
			          <LabourDesc<CFIF labour.LabourDesc is ""> xsi:nil="true"</CFIF>>#XmlFormat(labour.LabourDesc)#</LabourDesc>
			          <RepairType<CFIF labour.RepairType is ""> xsi:nil="true"</CFIF>>#XmlFormat(labour.RepairType)#</RepairType>
			        </Labour>
			        </CFLOOP>
			      </Labours>
			      <PartsDiscount<CFIF PartsDiscount is ""> xsi:nil="true"</CFIF>><CFIF PartsDiscount is NOT "">#XmlFormat(NumberFormat(partsdiscount,"99999.99"))#</CFIF></PartsDiscount>
			    </LabourParts>
			  </Workshop>
			  <Police>
			    <PlcRptNo<CFIF PlcRptNo is ""> xsi:nil="true"</CFIF>>#XmlFormat(PlcRptNo)#</PlcRptNo>
			    <PlcRptDt<CFIF PlcRptDt is ""> xsi:nil="true"</CFIF>>#XmlFormat(DateFormat(PlcRptDt,"yyyy-MM-dd'T'HH:mm:ss.SSS"))#</PlcRptDt>
			    <PlcPIAM<CFIF PlcPIAM is ""> xsi:nil="true"</CFIF>>#XmlFormat(PlcPIAM)#</PlcPIAM>
			  </Police>
			  <HistoryOfClaim>
			  	<CFLOOP query="History" startRow = "1" endRow  = "#History.RecordCount#">
			  		<CFIF History.IGCOID EQ q_snapitem.InsurerCode><CFSET Industry = 0><CFELSE><CFSET Industry = 1></CFIF>
			    <Claim>
			       <accidentdate<CFIF History.LossDate is ""> xsi:nil="true"</CFIF>>#XmlFormat(DateFormat(History.LossDate,"yyyy-MM-dd'T'HH:mm:ss.SSS"))#</accidentdate>
			       <PolicyNo<CFIF History.PolicyNo is "" OR Industry EQ 1> xsi:nil="true"</CFIF>><CFIF Industry EQ 0>#XmlFormat(History.PolicyNo)#</CFIF></PolicyNo>
				   <VehRegNo<CFIF History.VehRegNo is ""> xsi:nil="true"</CFIF>>#XmlFormat(History.VehRegNo)#</VehRegNo>
				   <VehChassis<CFIF History.VehChassis is ""> xsi:nil="true"</CFIF>>#XmlFormat(History.VehChassis)#</VehChassis>
				   <VehEngine<CFIF History.VehEngine is ""> xsi:nil="true"</CFIF>>#XmlFormat(History.VehEngine)#</VehEngine>
				   <RepQuote<CFIF History.RepQuote is "" OR Industry EQ 1> xsi:nil="true"</CFIF>><CFIF Industry EQ 0>#XmlFormat(History.RepQuote)#</CFIF></RepQuote>
				   <OfferPaidAmt<CFIF History.OfferPaidAmt is "" OR Industry EQ 1> xsi:nil="true"</CFIF>><CFIF History.OfferPaidAmt is NOT "" AND Industry EQ 0>#XmlFormat(NumberFormat(History.OfferPaidAmt,"99999.99"))#</CFIF></OfferPaidAmt>
				   <Industry<CFIF Industry is ""> xsi:nil="true"</CFIF>>#XmlFormat(Industry)#</Industry>
				   <ClmTyp<CFIF History.ClmTyp is ""> xsi:nil="true"</CFIF>>#XmlFormat(History.ClmTyp)#</ClmTyp>
				   <ClaimantID<CFIF History.ClaimantID is "" OR Industry EQ 1> xsi:nil="true"</CFIF>><CFIF Industry EQ 0>#XmlFormat(History.ClaimantID)#</CFIF></ClaimantID>
				   <InsuredID<CFIF History.InsuredID is "" OR Industry EQ 1> xsi:nil="true"</CFIF>><CFIF Industry EQ 0>#XmlFormat(History.InsuredID)#</CFIF></InsuredID>
				   <TotalLossType<CFIF History.TotalLossType is ""> xsi:nil="true"</CFIF>>#XmlFormat(History.TotalLossType)#</TotalLossType>
			    </Claim>
				</CFLOOP>
			  </HistoryOfClaim>
			</Input>]]></pp05:strXMLinput>
      <pp05:strTestBatchRunIDNR>1</pp05:strTestBatchRunIDNR>
    </pp05:TestBatchFilter>
  </soap:Body>
</soap:Envelope>
	</Cfsavecontent>
	<!--- <cfdump var = #PP#><cfabort> --->
	</CFOUTPUT><!--- </CFIF> --->


<!--- Create Message before Call CMF --->
<cfstoredproc PROCEDURE='SSPTRXCMF' DATASOURCE=#Request.SVCDSN# RETURNCODE=YES>
	<CFPROCPARAM TYPE=IN DBVARNAME=@ai_option VALUE=1 CFSQLTYPE=CF_SQL_INTEGER>
	<CFPROCPARAM TYPE=IN DBVARNAME=@ai_icaseid VALUE=#Attributes.CaseID# CFSQLTYPE=CF_SQL_INTEGER>
	<CFPROCPARAM TYPE=IN DBVARNAME=@ai_icmfid NULL=YES CFSQLTYPE=CF_SQL_INTEGER>
	<CFPROCPARAM TYPE=IN DBVARNAME=@ai_icrtby VALUE=1 CFSQLTYPE=CF_SQL_INTEGER>
	<CFPROCPARAM TYPE=IN DBVARNAME=@adt_dtcrton NULL=YES CFSQLTYPE=CF_SQL_TIMESTAMP>
	<CFPROCPARAM TYPE=IN DBVARNAME=@ai_siSTATUS VALUE=0 CFSQLTYPE=CF_SQL_SMALLINT>
	<CFPROCPARAM TYPE=IN DBVARNAME=@ava_ORIGXML VALUE="#PP#" CFSQLTYPE=CF_SQL_NVARCHAR>
	<CFPROCPARAM TYPE=IN DBVARNAME=@ava_vaERR1 NULL=YES CFSQLTYPE=CF_SQL_NVARCHAR>
	<CFPROCPARAM TYPE=IN DBVARNAME=@ava_vaERR2 NULL=YES CFSQLTYPE=CF_SQL_NVARCHAR>
	<CFPROCPARAM TYPE=IN DBVARNAME=@ava_vaERR3 NULL=YES CFSQLTYPE=CF_SQL_NVARCHAR>
	<CFPROCPARAM TYPE=IN DBVARNAME=@ai_stage VALUE=#Attributes.Type# CFSQLTYPE=CF_SQL_INTEGER>
	<CFPROCPARAM TYPE=IN DBVARNAME=@ai_iadvise VALUE="-1" CFSQLTYPE=CF_SQL_INTEGER><!--- -1 mean haven receive data from CMF	 --->
</cfstoredproc>
<CFSET returncode=CFSTOREDPROC.StatusCode>
<CFIF returncode LT 0>
	<cfthrow TYPE=EX_DBERROR ErrorCode="CMF_insert(#returncode#)">
</CFIF>

<CFSET Advice = "">
<CFSET companyid = "">
<CFSET accidentid = "">
<CFSET accidentdate = "">
<CFSET ppcustomerid = "">
<CFSET cmfversion = "">
<CFSET calculationdatetime = "">
<CFSET error1 = "">
<CFSET error2 = "">
<CFSET expectedvalues = "">
<CFSET quantiles = "">
<CFSET code = "">
<CFSET description = "">
<CFSET version = "">
<CFSET score = "">
<CFSET scorerepairshop = "">
<CFSET minimumadvicelevel = "">
<CFSET expected_Tcost = "">
<CFSET expected_Bcost = "">
<CFSET quantiles_Tcost = "">
<CFSET quantiles_Bcost = "">
<CFSET type = "">
<CFSET PP_URL = "">

<CFIF q_snapitem.InsurerHostedID IS 1>
	<CFIF APPLICATION.DB_MODE NEQ "PROD" OR Request.MTRDSN NEQ "mymotor_prod">
		<CFIF GCOID IS 57>
			<CFSET PP_URL = "http://10.2.1.82/CMF_Merimen_PA_T/Merimen_PA_Filter.asmx"><!--- http://10.2.1.82/CMF_WS_Merimen_T/Merimen_PA_Filter.asmx --->
		<CFELSEIF GCOID IS 67>
			<CFSET PP_URL = "http://10.2.1.82/CMF_Merimen_RHB_T/Merimen_RHB_Filter.asmx">
		</CFIF>		
	<CFELSE>
		<CFIF GCOID IS 57>
			<CFSET PP_URL = "http://10.2.1.88/CMF_Merimen_PA_P/Merimen_PA_Filter.asmx"><!--- http://10.2.1.88/CMF_WS_Merimen_T/Merimen_PA_Filter.asmx --->
		<CFELSEIF GCOID IS 67>
			<CFSET PP_URL = "http://10.2.1.88/CMF_Merimen_RHB_P/Merimen_RHB_Filter.asmx">
		</CFIF>
	</CFIF>
<CFELSEIF q_snapitem.InsurerHostedID IS 7>
	<CFIF APPLICATION.DB_MODE NEQ "PROD">
		<CFSET PP_URL = "http://10.100.2.88/CMF_Merimen_AM_T/Merimen_AM_Filter.asmx">
	<CFELSE>
		<CFSET PP_URL = "http://10.100.2.88/CMF_Merimen_AM_P/Merimen_AM_Filter.asmx">
	</CFIF>
</CFIF>		

<Cfhttp URL=#PP_URL# Result="result" Method="post" Timeout=60>
  <Cfhttpparam Type="XML" value="#pp#">
</Cfhttp>


<!--- Return Message from CMF --->
	<CFIF IsDefined("result.Filecontent")>
		<CFIF result.Filecontent is "Connection Failure">
			<cfstoredproc PROCEDURE='SSPTRXCMF' DATASOURCE=#Request.SVCDSN# RETURNCODE=YES>
				<CFPROCPARAM TYPE=IN DBVARNAME=@ai_option VALUE=0 CFSQLTYPE=CF_SQL_INTEGER>
				<CFPROCPARAM TYPE=IN DBVARNAME=@ai_icaseid VALUE=#Attributes.CaseID# CFSQLTYPE=CF_SQL_INTEGER>
				<CFPROCPARAM TYPE=IN DBVARNAME=@ai_icmfid  NULL=YES CFSQLTYPE=CF_SQL_INTEGER>
				<CFPROCPARAM TYPE=IN DBVARNAME=@ai_icrtby VALUE=1 CFSQLTYPE=CF_SQL_INTEGER>
				<CFPROCPARAM TYPE=IN DBVARNAME=@adt_dtcrton NULL=YES CFSQLTYPE=CF_SQL_TIMESTAMP>
				<CFPROCPARAM TYPE=IN DBVARNAME=@ai_siSTATUS VALUE=0 CFSQLTYPE=CF_SQL_SMALLINT>
				<CFPROCPARAM TYPE=IN DBVARNAME=@ava_ORIGXML NULL=YES CFSQLTYPE=CF_SQL_NVARCHAR>
				<CFPROCPARAM TYPE=IN DBVARNAME=@ava_vaERR1 VALUE=#result.Filecontent# CFSQLTYPE=CF_SQL_NVARCHAR>
				<CFPROCPARAM TYPE=IN DBVARNAME=@ava_vaERR2 NULL=YES CFSQLTYPE=CF_SQL_NVARCHAR>
				<CFPROCPARAM TYPE=IN DBVARNAME=@ava_vaERR3 NULL=YES CFSQLTYPE=CF_SQL_NVARCHAR>
				<CFPROCPARAM TYPE=IN DBVARNAME=@ai_stage VALUE=#Attributes.Type# CFSQLTYPE=CF_SQL_INTEGER>
				<CFPROCPARAM TYPE=IN DBVARNAME=@ai_iadvise VALUE="-999" CFSQLTYPE=CF_SQL_INTEGER>
			</cfstoredproc>
			<CFSET returncode=CFSTOREDPROC.StatusCode>
			<CFIF returncode LT 0>
				<cfthrow TYPE=EX_DBERROR ErrorCode="CMF_update(#returncode#)">
			</CFIF>
			<cfexit>
		</CFIF>
		<CFSET xmldom=XmlParse(result.Filecontent)>
		<CFIF IsDefined("xmldom.Envelope.body.TestBatchFilterResponse.TestBatchFilterResult.xmltext")>
			<CFSET xmldom=XmlParse(xmldom.Envelope.body.TestBatchFilterResponse.TestBatchFilterResult.xmltext)>
			<CFIF IsDefined("xmldom.output")>	
				<CFIF IsDefined("xmldom.output.error.xmltext") OR IsDefined("xmldom.output.error.error.xmltext")>
					<CFSET error1 = #xmldom.output.error.xmltext#>
					<CFSET error2 = #xmldom.output.error.error.xmltext#>

						<cfstoredproc PROCEDURE='SSPTRXCMF' DATASOURCE=#Request.SVCDSN# RETURNCODE=YES>
							<CFPROCPARAM TYPE=IN DBVARNAME=@ai_option VALUE=0 CFSQLTYPE=CF_SQL_INTEGER>
							<CFPROCPARAM TYPE=IN DBVARNAME=@ai_icaseid VALUE=#Attributes.CaseID# CFSQLTYPE=CF_SQL_INTEGER>
							<CFPROCPARAM TYPE=IN DBVARNAME=@ai_icmfid  NULL=YES CFSQLTYPE=CF_SQL_INTEGER>
							<CFPROCPARAM TYPE=IN DBVARNAME=@ai_icrtby VALUE=1 CFSQLTYPE=CF_SQL_INTEGER>
							<CFPROCPARAM TYPE=IN DBVARNAME=@adt_dtcrton NULL=YES CFSQLTYPE=CF_SQL_TIMESTAMP>
							<CFPROCPARAM TYPE=IN DBVARNAME=@ai_siSTATUS VALUE=0 CFSQLTYPE=CF_SQL_SMALLINT>
							<CFPROCPARAM TYPE=IN DBVARNAME=@ava_ORIGXML NULL=YES CFSQLTYPE=CF_SQL_NVARCHAR>
							<CFPROCPARAM TYPE=IN DBVARNAME=@ava_vaERR1 VALUE=#error1# CFSQLTYPE=CF_SQL_NVARCHAR>
							<CFPROCPARAM TYPE=IN DBVARNAME=@ava_vaERR2 VALUE=#error2# CFSQLTYPE=CF_SQL_NVARCHAR>
							<CFPROCPARAM TYPE=IN DBVARNAME=@ava_vaERR3 VALUE=#xmldom# CFSQLTYPE=CF_SQL_NVARCHAR>
							<CFPROCPARAM TYPE=IN DBVARNAME=@ai_stage VALUE=#Attributes.Type# CFSQLTYPE=CF_SQL_INTEGER>
							<CFPROCPARAM TYPE=IN DBVARNAME=@ai_iadvise VALUE="-998" CFSQLTYPE=CF_SQL_INTEGER>
						</cfstoredproc>
						<CFSET returncode=CFSTOREDPROC.StatusCode>
						<CFIF returncode LT 0>
							<cfthrow TYPE=EX_DBERROR ErrorCode="CMF_update(#returncode#)">
						</CFIF>
					<cfexit>
				<CFELSE>
					<CFIF IsDefined("xmldom.output")>
						<!--- <cfdump var = #xmldom#><cfabort>	 --->
						<!--- advice --->
						<CFIF IsDefined("xmldom.output.advice.xmltext")>
							<CFSET Advice = #xmldom.output.advice.xmltext#>
						</CFIF>	
						<!--- statisticalfilter --->
						<CFIF IsDefined("xmldom.output.companyid.xmltext")>
							<CFSET companyid = #xmldom.output.companyid.xmltext#>
						</CFIF>	
						<CFIF IsDefined("xmldom.output.accidentid.xmltext")>
							<CFSET accidentid = #xmldom.output.accidentid.xmltext#>
						</CFIF>	
						<CFIF LEN(companyid) GT 0>
							<CFQUERY NAME=trx_coname DATASOURCE=#Request.MTRDSN#>
								SELECT vaCONAME FROM SEC0005 with (NOLOCK) WHERE iCOID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#companyid#">
							</CFQUERY>
						</CFIF>
						<CFIF LEN(accidentid) GT 0>
							<CFQUERY NAME=trx_cmfid DATASOURCE=#Request.MTRDSN#>
								SELECT TOP 1 ICMFID FROM CMF0001 with (NOLOCK) WHERE iCASEID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#accidentid#"> order by ICMFID desc
							</CFQUERY>
						</CFIF>
						<CFIF IsDefined("xmldom.output.cmfversion.xmltext")>
							<CFSET cmfversion = #xmldom.output.cmfversion.xmltext#>
						</CFIF>
						<CFIF IsDefined("xmldom.output.calculationdatetime.xmltext")>
							<CFSET calculationdatetime = #xmldom.output.calculationdatetime.xmltext#>
						</CFIF>
					</CFIF>
					<CFIF IsDefined("xmldom.output.statisticalfilter")>
						<CFIF IsDefined("xmldom.output.statisticalfilter.expectedvalues.totalcosts.xmltext")>
							<CFSET expected_Tcost = #xmldom.output.statisticalfilter.expectedvalues.totalcosts.xmltext#>
						</CFIF>
						<CFIF IsDefined("xmldom.output.statisticalfilter.expectedvalues.totalcosts_benchmark.xmltext")>
							<CFSET expected_Bcost = #xmldom.output.statisticalfilter.expectedvalues.totalcosts_benchmark.xmltext#>
						</CFIF>
						<CFIF IsDefined("xmldom.output.statisticalfilter.quantiles.totalcosts.xmltext")>
							<CFSET quantiles_Tcost = #xmldom.output.statisticalfilter.quantiles.totalcosts.xmltext#>
						</CFIF>
						<CFIF IsDefined("xmldom.output.statisticalfilter.quantiles.totalcosts_benchmark.xmltext")>
							<CFSET quantiles_Bcost = #xmldom.output.statisticalfilter.quantiles.totalcosts_benchmark.xmltext#>
						</CFIF>
						<CFIF IsDefined("xmldom.output.statisticalfilter.quantiles.totallabourcosts.xmltext")> <!--- New output XML ---> 
							<CFSET quantiles_totallabourcost = #xmldom.output.statisticalfilter.quantiles.totallabourcosts.xmltext#>
						</CFIF>	
						<CFIF IsDefined("xmldom.output.statisticalfilter.quantiles.totalpartscosts.xmltext")>	
							<CFSET quantiles_totalpartscost = #xmldom.output.statisticalfilter.quantiles.totalpartscosts.xmltext#>
						</CFIF>	
						<CFIF IsDefined("xmldom.output.statisticalfilter.expectedvalues.totallabourcosts.xmltext")>
							<CFSET expected_totallabourcost = #xmldom.output.statisticalfilter.expectedvalues.totallabourcosts.xmltext#>
						</CFIF>	
						<CFIF IsDefined("xmldom.output.statisticalfilter.expectedvalues.totalpartscosts.xmltext")>	
							<CFSET expected_totalpartscost = #xmldom.output.statisticalfilter.expectedvalues.totalpartscosts.xmltext#>
						</CFIF>
						<CFIF IsDefined("xmldom.output.statisticalfilter.expectedvalues.windscreenprice.xmltext")>
							<CFSET expected_WSprice = #xmldom.output.statisticalfilter.expectedvalues.windscreenprice.xmltext#>
						</CFIF>	
						<CFIF IsDefined("xmldom.output.statisticalfilter.quantiles.windscreenprice.xmltext")>	
							<CFSET quantiles_WSprice = #xmldom.output.statisticalfilter.quantiles.windscreenprice.xmltext#>
						</CFIF>
						<CFIF IsDefined("xmldom.output.statisticalfilter.expectedvalues.windscreenprice_benchmark.xmltext")>
							<CFSET expected_BM_WSprice = #xmldom.output.statisticalfilter.expectedvalues.windscreenprice_benchmark.xmltext#>
						</CFIF>	
						<CFIF IsDefined("xmldom.output.statisticalfilter.quantiles.windscreenprice_benchmark.xmltext")>	
							<CFSET quantiles_BM_WSprice = #xmldom.output.statisticalfilter.quantiles.windscreenprice_benchmark.xmltext#>
						</CFIF>
						<CFIF IsDefined("xmldom.output.statisticalfilter.expectedvalues.totalpartscosts_benchmark.xmltext")>	
							<CFSET expected_BM_Partsprice = #xmldom.output.statisticalfilter.expectedvalues.totalpartscosts_benchmark.xmltext#>
						</CFIF>	
						<CFIF IsDefined("xmldom.output.statisticalfilter.quantiles.totalpartscosts_benchmark.xmltext")>	
							<CFSET quantiles_BM_Partsprice = #xmldom.output.statisticalfilter.quantiles.totalpartscosts_benchmark.xmltext#>
						</CFIF>			
					</CFIF>
						<cfstoredproc PROCEDURE='SSPTRXCMF' DATASOURCE=#Request.SVCDSN# RETURNCODE=YES>
						<CFPROCPARAM TYPE=IN DBVARNAME=@ai_option VALUE=2 CFSQLTYPE=CF_SQL_INTEGER>
							<CFPROCPARAM TYPE=IN DBVARNAME=@ai_icaseid VALUE=#Attributes.CaseID# CFSQLTYPE=CF_SQL_INTEGER>
						<CFPROCPARAM TYPE=IN DBVARNAME=@ai_icmfid  VALUE=#trx_cmfid.ICMFID# CFSQLTYPE=CF_SQL_INTEGER>
						<CFPROCPARAM TYPE=IN DBVARNAME=@ai_icrtby VALUE=1 CFSQLTYPE=CF_SQL_INTEGER>
						<CFPROCPARAM TYPE=IN DBVARNAME=@adt_dtcrton NULL=YES CFSQLTYPE=CF_SQL_TIMESTAMP>
						<CFPROCPARAM TYPE=IN DBVARNAME=@ai_siSTATUS VALUE=0 CFSQLTYPE=CF_SQL_SMALLINT>
						<CFPROCPARAM TYPE=IN DBVARNAME=@ava_ORIGXML NULL=YES CFSQLTYPE=CF_SQL_NVARCHAR>
						<CFPROCPARAM TYPE=IN DBVARNAME=@ava_vaERR1 NULL=YES CFSQLTYPE=CF_SQL_NVARCHAR>
						<CFPROCPARAM TYPE=IN DBVARNAME=@ava_vaERR2 NULL=YES CFSQLTYPE=CF_SQL_NVARCHAR>
						<CFPROCPARAM TYPE=IN DBVARNAME=@ava_vaERR3 NULL=YES CFSQLTYPE=CF_SQL_NVARCHAR>	
							<CFPROCPARAM TYPE=IN DBVARNAME=@ai_stage VALUE=#Attributes.Type# CFSQLTYPE=CF_SQL_INTEGER>
						<CFIF IsDefined("xmldom.output.advice.xmltext")>
							<CFPROCPARAM TYPE=IN DBVARNAME=@ai_iadvise VALUE=#Advice# CFSQLTYPE=CF_SQL_INTEGER>
						<CFELSE>
							<CFPROCPARAM TYPE=IN DBVARNAME=@ai_iadvise NULL=YES CFSQLTYPE=CF_SQL_INTEGER>
						</CFIF>	
						<CFIF IsDefined("xmldom.output.companyid.xmltext")>
							<CFPROCPARAM TYPE=IN DBVARNAME=@as_vacomname VALUE=#trx_coname.vaCONAME# CFSQLTYPE=CF_SQL_VARCHAR>
							<CFPROCPARAM TYPE=IN DBVARNAME=@ai_icoid VALUE=#companyid# CFSQLTYPE=CF_SQL_INTEGER>
						<CFELSE>
							<CFPROCPARAM TYPE=IN DBVARNAME=@as_vacomname NULL=YES CFSQLTYPE=CF_SQL_VARCHAR>
							<CFPROCPARAM TYPE=IN DBVARNAME=@ai_icoid NULL=YES CFSQLTYPE=CF_SQL_INTEGER>
						</CFIF>	
						<CFIF IsDefined("xmldom.output.accidentid.xmltext") AND Len(accidentid) GT 0>
							<CFPROCPARAM TYPE=IN DBVARNAME=@ai_iaccid VALUE=#accidentid# CFSQLTYPE=CF_SQL_INTEGER>
						<CFELSE>
							<CFPROCPARAM TYPE=IN DBVARNAME=@ai_iaccid NULL=YES CFSQLTYPE=CF_SQL_INTEGER>	
						</CFIF>
						<CFIF IsDefined("xmldom.output.statisticalfilter.expectedvalues.totalcosts.xmltext") AND Len(expected_Tcost) GT 0>
							<CFPROCPARAM TYPE=IN DBVARNAME=@amn_Etotalcost VALUE=#expected_Tcost# CFSQLTYPE=CF_SQL_MONEY>
						<CFELSE>
							<CFPROCPARAM TYPE=IN DBVARNAME=@amn_Etotalcost NULL=YES CFSQLTYPE=CF_SQL_MONEY>	
						</CFIF>
						<CFIF IsDefined("xmldom.output.statisticalfilter.expectedvalues.totalcosts_benchmark.xmltext") AND Len(expected_Bcost) GT 0 >
							<CFPROCPARAM TYPE=IN DBVARNAME=@amn_Ebenchmark VALUE=#expected_Bcost# CFSQLTYPE=CF_SQL_MONEY>
						<CFELSE>
							<CFPROCPARAM TYPE=IN DBVARNAME=@amn_Ebenchmark NULL=YES CFSQLTYPE=CF_SQL_MONEY>
						</CFIF>
						<CFIF IsDefined("xmldom.output.statisticalfilter.quantiles.totalcosts.xmltext") AND Len(quantiles_Tcost) GT 0>
							<CFPROCPARAM TYPE=IN DBVARNAME=@amn_QEtotalcost VALUE=#quantiles_Tcost# CFSQLTYPE=CF_SQL_FLOAT>
						<CFELSE>
							<CFPROCPARAM TYPE=IN DBVARNAME=@amn_QEtotalcost NULL=YES CFSQLTYPE=CF_SQL_FLOAT>
						</CFIF>
						<CFIF IsDefined("xmldom.output.statisticalfilter.quantiles.totalcosts_benchmark.xmltext") AND Len(quantiles_Bcost) GT 0>
							<CFPROCPARAM TYPE=IN DBVARNAME=@amn_Qbenchmark VALUE=#quantiles_Bcost# CFSQLTYPE=CF_SQL_FLOAT>
						<CFELSE>
							<CFPROCPARAM TYPE=IN DBVARNAME=@amn_Qbenchmark NULL=YES CFSQLTYPE=CF_SQL_FLOAT>	
						</CFIF>
						<CFIF IsDefined("xmldom.output.statisticalfilter.expectedvalues.totallabourcosts.xmltext") AND Len(expected_totallabourcost) GT 0>
							<CFPROCPARAM TYPE=IN DBVARNAME=@amn_Etotallabourcost VALUE=#expected_totallabourcost# CFSQLTYPE=CF_SQL_MONEY>
						<CFELSE>
							<CFPROCPARAM TYPE=IN DBVARNAME=@amn_Etotallabourcost  NULL=YES CFSQLTYPE=CF_SQL_MONEY>	
						</CFIF>		
						<CFIF IsDefined("xmldom.output.statisticalfilter.expectedvalues.totalpartscosts.xmltext") AND Len(expected_totalpartscost) GT 0>	
							<CFPROCPARAM TYPE=IN DBVARNAME=@amn_Etotalpartscost VALUE=#expected_totalpartscost# CFSQLTYPE=CF_SQL_MONEY>
						<CFELSE>
							<CFPROCPARAM TYPE=IN DBVARNAME=@amn_Etotalpartscost  NULL=YES CFSQLTYPE=CF_SQL_MONEY>	
						</CFIF>		
						<CFIF IsDefined("xmldom.output.statisticalfilter.expectedvalues.windscreenprice.xmltext") AND Len(expected_WSprice) GT 0>	
							<CFPROCPARAM TYPE=IN DBVARNAME=@amn_EWSprice VALUE=#expected_WSprice# CFSQLTYPE=CF_SQL_MONEY>
						<CFELSE>
							<CFPROCPARAM TYPE=IN DBVARNAME=@amn_EWSprice  NULL=YES CFSQLTYPE=CF_SQL_MONEY>	
						</CFIF>				
						<CFIF IsDefined("xmldom.output.statisticalfilter.quantiles.totallabourcosts.xmltext") AND Len(quantiles_totallabourcost) GT 0>		
							<CFPROCPARAM TYPE=IN DBVARNAME=@af_Qtotallabourcost VALUE=#quantiles_totallabourcost# CFSQLTYPE=CF_SQL_FLOAT>
						<CFELSE>
							<CFPROCPARAM TYPE=IN DBVARNAME=@af_Qtotallabourcost  NULL=YES CFSQLTYPE=CF_SQL_FLOAT>
						</CFIF>		
						<CFIF IsDefined("xmldom.output.statisticalfilter.quantiles.totalpartscosts.xmltext") AND Len(quantiles_totalpartscost) GT 0>	
							<CFPROCPARAM TYPE=IN DBVARNAME=@af_Qtotalpartscost VALUE=#quantiles_totalpartscost# CFSQLTYPE=CF_SQL_FLOAT>
						<CFELSE>
							<CFPROCPARAM TYPE=IN DBVARNAME=@af_Qtotalpartscost  NULL=YES CFSQLTYPE=CF_SQL_FLOAT>
						</CFIF>	
						<CFIF IsDefined("xmldom.output.statisticalfilter.quantiles.windscreenprice.xmltext") AND Len(quantiles_WSprice) GT 0>	
							<CFPROCPARAM TYPE=IN DBVARNAME=@af_QWSprice VALUE=#quantiles_WSprice# CFSQLTYPE=CF_SQL_MONEY>
						<CFELSE>
							<CFPROCPARAM TYPE=IN DBVARNAME=@af_QWSprice  NULL=YES CFSQLTYPE=CF_SQL_FLOAT>	
						</CFIF>	
						<CFIF IsDefined("xmldom.output.statisticalfilter.expectedvalues.windscreenprice_benchmark.xmltext") AND Len(expected_BM_WSprice) GT 0>	
							<CFPROCPARAM TYPE=IN DBVARNAME=@amn_EbenchmarkWSPrice VALUE=#expected_BM_WSprice# CFSQLTYPE=CF_SQL_MONEY>
						<CFELSE>
							<CFPROCPARAM TYPE=IN DBVARNAME=@amn_EbenchmarkWSPrice  NULL=YES CFSQLTYPE=CF_SQL_MONEY>
						</CFIF>	
						<CFIF IsDefined("xmldom.output.statisticalfilter.quantiles.windscreenprice_benchmark.xmltext") AND Len(quantiles_BM_WSprice) GT 0>	
							<CFPROCPARAM TYPE=IN DBVARNAME=@af_QbenchmarkWSPrice  VALUE=#quantiles_BM_WSprice# CFSQLTYPE=CF_SQL_FLOAT>
						<CFELSE>
							<CFPROCPARAM TYPE=IN DBVARNAME=@af_QbenchmarkWSPrice   NULL=YES CFSQLTYPE=CF_SQL_FLOAT>	
						</CFIF>
						<CFIF IsDefined("xmldom.output.statisticalfilter.expectedvalues.totalpartscosts_benchmark.xmltext") AND Len(expected_BM_Partsprice) GT 0>	
							<CFPROCPARAM TYPE=IN DBVARNAME=@amn_Ebenchmarktotalpartscosts VALUE=#expected_BM_Partsprice# CFSQLTYPE=CF_SQL_MONEY>
						<CFELSE>
							<CFPROCPARAM TYPE=IN DBVARNAME=@amn_Ebenchmarktotalpartscosts  NULL=YES CFSQLTYPE=CF_SQL_MONEY>
						</CFIF>	
						<CFIF IsDefined("xmldom.output.statisticalfilter.quantiles.totalpartscosts_benchmark.xmltext") AND Len(quantiles_BM_Partsprice) GT 0>	
							<CFPROCPARAM TYPE=IN DBVARNAME=@af_Qbenchmarktotalpartscosts  VALUE=#quantiles_BM_Partsprice# CFSQLTYPE=CF_SQL_FLOAT>
						<CFELSE>
							<CFPROCPARAM TYPE=IN DBVARNAME=@af_Qbenchmarktotalpartscosts   NULL=YES CFSQLTYPE=CF_SQL_FLOAT>	
						</CFIF>			
					</cfstoredproc>
						<CFSET returncode=CFSTOREDPROC.StatusCode>
						<CFIF returncode LT 0>
						<cfthrow TYPE=EX_DBERROR ErrorCode="CMF_update(#returncode#)">
						</CFIF>

					<!--- technicalfilter --->
					<CFIF IsDefined("xmldom.output.technicalfilter")>
						<CFIF IsDefined("xmldom.output.technicalfilter.violation")>
							<CFSET violation_count = #xmldom.output.technicalfilter.violation#>
							<CFLOOP array="#violation_count#" index="thisNode">
								<CFSET code = #thisNode.code.XmlText#>
							  	<CFSET description = #thisNode.description.XmlText#>
								<CFSET version = #thisNode.version.XmlText#>
								<CFSET score = #thisNode.score.XmlText#>
								<CFSET scorerepairshop = #thisNode.scorerepairshop.XmlText#>
								<CFSET minimumadvicelevel = #thisNode.minimumadvicelevel.XmlText#>

								<cfstoredproc PROCEDURE='SSPTRXCMF' DATASOURCE=#Request.SVCDSN# RETURNCODE=YES>
									<CFPROCPARAM TYPE=IN DBVARNAME=@ai_option VALUE=3 CFSQLTYPE=CF_SQL_INTEGER>
									<CFPROCPARAM TYPE=IN DBVARNAME=@ai_icaseid VALUE=#Attributes.CaseID# CFSQLTYPE=CF_SQL_INTEGER>
									<CFPROCPARAM TYPE=IN DBVARNAME=@ai_icmfid  VALUE=#trx_cmfid.ICMFID# CFSQLTYPE=CF_SQL_INTEGER>
									<CFPROCPARAM TYPE=IN DBVARNAME=@ai_icrtby VALUE=1 CFSQLTYPE=CF_SQL_INTEGER>
									<CFPROCPARAM TYPE=IN DBVARNAME=@adt_dtcrton NULL=YES CFSQLTYPE=CF_SQL_TIMESTAMP>
									<CFPROCPARAM TYPE=IN DBVARNAME=@ai_siSTATUS VALUE=0 CFSQLTYPE=CF_SQL_SMALLINT>
									<CFPROCPARAM TYPE=IN DBVARNAME=@ava_ORIGXML NULL=YES CFSQLTYPE=CF_SQL_NVARCHAR>
									<CFPROCPARAM TYPE=IN DBVARNAME=@ava_vaERR1 NULL=YES CFSQLTYPE=CF_SQL_NVARCHAR>
									<CFPROCPARAM TYPE=IN DBVARNAME=@ava_vaERR2 NULL=YES CFSQLTYPE=CF_SQL_NVARCHAR>
									<CFPROCPARAM TYPE=IN DBVARNAME=@ava_vaERR3 NULL=YES CFSQLTYPE=CF_SQL_NVARCHAR>
									<CFPROCPARAM TYPE=IN DBVARNAME=@ai_stage NULL=YES CFSQLTYPE=CF_SQL_INTEGER>
									<CFPROCPARAM TYPE=IN DBVARNAME=@ai_iadvise NULL=YES CFSQLTYPE=CF_SQL_INTEGER>
									<CFPROCPARAM TYPE=IN DBVARNAME=@as_vacomname NULL=YES CFSQLTYPE=CF_SQL_VARCHAR>
									<CFPROCPARAM TYPE=IN DBVARNAME=@ai_icoid NULL=YES CFSQLTYPE=CF_SQL_INTEGER>
									<CFPROCPARAM TYPE=IN DBVARNAME=@ai_iaccid NULL=YES CFSQLTYPE=CF_SQL_INTEGER>
									<CFPROCPARAM TYPE=IN DBVARNAME=@amn_Etotalcost NULL=YES CFSQLTYPE=CF_SQL_MONEY>
									<CFPROCPARAM TYPE=IN DBVARNAME=@amn_Ebenchmark NULL=YES CFSQLTYPE=CF_SQL_MONEY>
									<CFPROCPARAM TYPE=IN DBVARNAME=@amn_QEtotalcost NULL=YES CFSQLTYPE=CF_SQL_FLOAT>
									<CFPROCPARAM TYPE=IN DBVARNAME=@amn_Qbenchmark NULL=YES CFSQLTYPE=CF_SQL_FLOAT>
									<CFPROCPARAM TYPE=IN DBVARNAME=@amn_Etotallabourcost  NULL=YES CFSQLTYPE=CF_SQL_MONEY>
									<CFPROCPARAM TYPE=IN DBVARNAME=@amn_Etotalpartscost  NULL=YES CFSQLTYPE=CF_SQL_MONEY>
									<CFPROCPARAM TYPE=IN DBVARNAME=@amn_EWSprice  NULL=YES CFSQLTYPE=CF_SQL_MONEY>
									<CFPROCPARAM TYPE=IN DBVARNAME=@af_Qtotallabourcost  NULL=YES CFSQLTYPE=CF_SQL_FLOAT>
									<CFPROCPARAM TYPE=IN DBVARNAME=@af_Qtotalpartscost  NULL=YES CFSQLTYPE=CF_SQL_FLOAT>
									<CFPROCPARAM TYPE=IN DBVARNAME=@af_QWSprice  NULL=YES CFSQLTYPE=CF_SQL_FLOAT>
									<CFPROCPARAM TYPE=IN DBVARNAME=@amn_EbenchmarkMWSPrice  NULL=YES CFSQLTYPE=CF_SQL_MONEY>
									<CFPROCPARAM TYPE=IN DBVARNAME=@af_QbenchmarkWSPrice   NULL=YES CFSQLTYPE=CF_SQL_FLOAT>
									<CFPROCPARAM TYPE=IN DBVARNAME=@amn_Ebenchmarktotalpartscosts  NULL=YES CFSQLTYPE=CF_SQL_MONEY>
									<CFPROCPARAM TYPE=IN DBVARNAME=@af_Qbenchmarktotalpartscosts   NULL=YES CFSQLTYPE=CF_SQL_FLOAT>		
									<CFPROCPARAM TYPE=IN DBVARNAME=@ava_vacode VALUE=#code# CFSQLTYPE=CF_SQL_NVARCHAR>
									<CFPROCPARAM TYPE=IN DBVARNAME=@ava_vadesc VALUE=#description# CFSQLTYPE=CF_SQL_NVARCHAR>
									<CFPROCPARAM TYPE=IN DBVARNAME=@ai_iversion VALUE=#version# CFSQLTYPE=CF_SQL_INTEGER>
									<CFPROCPARAM TYPE=IN DBVARNAME=@ai_iscore VALUE=#score# CFSQLTYPE=CF_SQL_INTEGER>
									<CFPROCPARAM TYPE=IN DBVARNAME=@ai_irepscore VALUE=#scorerepairshop# CFSQLTYPE=CF_SQL_INTEGER>
									<CFPROCPARAM TYPE=IN DBVARNAME=@ai_iminadlevel VALUE=#minimumadvicelevel# CFSQLTYPE=CF_SQL_INTEGER>							
								</cfstoredproc>
								<CFSET returncode=CFSTOREDPROC.StatusCode>
								<CFIF returncode LT 0>
									<cfthrow TYPE=EX_DBERROR ErrorCode="CMF_update(#returncode#)">
								</CFIF>
							</CFLOOP>	
						</CFIF>									
					</CFIF>
				</CFIF>
			</CFIF>				
		</CFIF>		
	</CFIF>	
<CFELSE>
	 <CFTHROW TYPE="EX_DBERROR" ErrorCode="No Case Found (#Attributes.CaseID#)">
</CFIF>
