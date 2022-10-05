<!---
Generates application static variables that is available from the database
that is DEPLOYMENT INDEPENDENT. Variables specific to the deployment
environment (request.webroot, dsn, etc.) should be set in CF_SETENV, which is called
from this tag exclusively.

Only run if Application.SetVars=0 and no one started it (locked) yet.
If successful, it will write the cache variables to the next available
datastore (if current used is DS1, then write to DS2, else write to DS1)
and set Application.* environment variables.

Parameters: None
--->
<cfsilent>
<!---cfmodule TEMPLATE="DISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#"--->
<cflock SCOPE=Application Type=Exclusive TimeOut=600>
<cfif Not IsDefined("Application.SetVars") OR Application.SetVars IS 0>
<cfmodule TEMPLATE="MTRSETENV.cfm">
<cfset CURDSN=CURAPPLICATION.MTRDSN>
<cfset CATDSN=CURAPPLICATION.MTRCATDSN>
<CFIF IsDefined("CURAPPLICATION.MICDSN")>
	<cfset MICDSN=CURAPPLICATION.MICDSN>
<CFELSE>
	<cfset MICDSN="">
</CFIF>

<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT DB_APP=dbo.fGetDBSettings('APP'),DB_COUNTRY=dbo.fGetDBSettings('COUNTRY'),DB_MODE=dbo.fGetDBSettings('MODE')
</cfquery>
<CFSET CURApplication.DB_APP=q_trx.DB_APP>
<CFSET CURApplication.DB_COUNTRY=q_trx.DB_COUNTRY>
<CFSET CURApplication.DB_MODE=q_trx.DB_MODE>

<!--- begin shiu: enforce country specification for coid:1137 --->
<!---cfquery name="qry_1137" datasource="#CURDSN#">
declare @li_city int
declare @li_state int
declare @li_country int
declare @li_currentCountry int

select @li_currentCountry = icountryid from SEC0005 where icoid = 1137

if(@li_currentCountry != <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CURAPPLICATION.APPLOCID#">)
begin
    select top 1
        @li_city = cities.iCITYID
        ,@li_state = cities.iSTATEID
        ,@li_country = cities.iLCOUNTRYID
    from sys0003 cities
    inner join sys0002 states on states.iSTATEID = cities.iSTATEID
    where iCOUNTRYID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CURAPPLICATION.APPLOCID#">
    order by states.iSTATEID

    update sec0005 set
    iCITYID = @li_city
    ,iSTATEID = @li_state
    ,iCOUNTRYID = @li_country
    where icoid = 1137
end
</cfquery--->

<!--- end   shiu: enforce country specification for coid:1137 --->

<cfset DS=StructNew()>

<cfif IsDefined("CURAPPLICATION.APPPATH")>
	<CFIF Not IsDefined("CURAPPLICATION.APPPATHcfc")>
		<!--- Figure out APPPATHcfc from APPPPATH by converting / and \ to . and removing leading . --->
		<CFIF IsDefined("CURAPPLICATION.CFPREFIX")>
			<CFSET APPPATHcfc=Trim(CURAPPLICATION.CFPREFIX)&Trim(CURAPPLICATION.APPPATH)>
		<CFELSE>
			<CFSET APPPATHcfc=Trim(CURAPPLICATION.APPPATH)>
		</CFIF>
		<CFSET APPPATHcfc=REReplace(APPPATHcfc,"[\\/]",".","ALL")>
		<CFSET APPPATHcfc=Replace(APPPATHcfc,"..",".","ALL")>
		<CFIF APPPATHcfc IS "" OR APPPATHcfc IS ".">
			<CFSET APPPATHcfc="">
		<CFELSEIF Left(APPPATHcfc,1) IS ".">
			<CFSET APPPATHcfc=Right(APPPATHcfc,Len(APPPATHcfc)-1)>
		</CFIF>
		<CFIF APPPATHcfc IS NOT "" AND Right(APPPATHcfc,1) IS NOT ".">
			<CFSET APPPATHcfc=APPPATHcfc&".">
		</CFIF>
		<CFSET CURAPPLICATION.APPPATHcfc=APPPATHcfc>
	</CFIF>
	<cfloop LIST=#StructKeyList(CURAPPLICATION)# INDEX=IDX>
		<cfset StructInsert(Application,idx,StructFind(CURAPPLICATION,idx),true)>
	</cfloop>
	<cfmodule TEMPLATE="#CURAPPLICATION.CFPREFIX##CURAPPLICATION.APPPATH#services/CustomTags/SVCcffunctions.cfm" DS=#DS#>
	<cfmodule TEMPLATE="MTRcffunctions.cfm" DS=#DS#>
</cfif>

<!--- Esource part availability --->
<!---
<!--- Moved to LOCALES as per #24798 --->
<cfset esptype=StructNew()>

<cfset StructInsert(esptype,0,"Ready Stock")>
<cfset StructInsert(esptype,1,"Empty")>
<cfset StructInsert(esptype,2,"Indent")>

<cfset esptype_LID=StructNew()>
<cfset StructInsert(ESPTYPE_LID,0,"9836")>
<cfset StructInsert(ESPTYPE_LID,1,"9837")>
<cfset StructInsert(ESPTYPE_LID,2,"9838")>


 --->

<!--- Esource statuses --->
<cfset esstat=StructNew()>
<cfset StructInsert(esstat,-99,"Exceptional Failure")>
<cfset StructInsert(esstat,0,"Auction in Stasis")>
<cfset StructInsert(esstat,10,"RFQ Sent for ESourcing")>
<cfset StructInsert(esstat,20,"RFQ Accepted for ESourcing")>
<cfset StructInsert(esstat,30,"ESource Suspended")>
<cfset StructInsert(esstat,40,"ESource Withdrawn")>
<cfset StructInsert(esstat,50,"ESource in Progress")>
<cfset StructInsert(esstat,60,"ESource Completed")>
<cfset StructInsert(esstat,70,"Pending PO Confirmation")>
<cfset StructInsert(esstat,80,"Pending Acceptance of PO by Supplier")>
<cfset StructInsert(esstat,90,"PO Accepted by Supplier")>
<cfset StructInsert(esstat,99,"PO Rejected by Supplier")>
<cfset StructInsert(esstat,100,"ESource Completed")>
<cfset StructInsert(esstat,999,"Closed")>
<cfset esstat_LID=StructNew()>
<cfset StructInsert(ESSTAT_LID,-99,"25061")>
<cfset StructInsert(ESSTAT_LID,0,"25065")>
<cfset StructInsert(ESSTAT_LID,10,"25064")>
<cfset StructInsert(ESSTAT_LID,20,"25063")>
<cfset StructInsert(ESSTAT_LID,30,"25066")>
<cfset StructInsert(ESSTAT_LID,40,"25067")>
<cfset StructInsert(ESSTAT_LID,50,"25072")>
<cfset StructInsert(ESSTAT_LID,60,"25070")>
<cfset StructInsert(ESSTAT_LID,70,"25068")>
<cfset StructInsert(ESSTAT_LID,80,"25069")>
<cfset StructInsert(ESSTAT_LID,90,"25062")>
<cfset StructInsert(ESSTAT_LID,99,"25071")>
<cfset StructInsert(ESSTAT_LID,100,"25070")>
<cfset StructInsert(ESSTAT_LID,999,"9495")>

<!--- claimant notification status --->
<cfset cmtstat=StructNew()>
<cfset StructInsert(cmtstat,-1,"Pending Notification Submission")>
<cfset StructInsert(cmtstat,0,"Pending Notification Approval")>
<cfset StructInsert(cmtstat,1,"Activated Claim Notification")>
<cfset StructInsert(cmtstat,2,"Rejected Claim Notification")>
<cfset StructInsert(cmtstat,999,"Claim Notification (Cancelled)")>
<cfset cmtstat_LID=StructNew()>
<cfset StructInsert(CMTSTAT_LID,-1,"7705")>
<cfset StructInsert(CMTSTAT_LID,0,"7704")>
<cfset StructInsert(CMTSTAT_LID,1,"7708")>
<cfset StructInsert(CMTSTAT_LID,2,"7709")>
<cfset StructInsert(CMTSTAT_LID,999,"8383")>

<!--- Etender statuses, trx0070.sitenderstat --->
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT siETISTAT, ETDESC=vaDESC,iLID=isNULL(iLID,0) FROM BIZ0081 WITH (NOLOCK) WHERE sistatus=0 ORDER BY siETISID
</cfquery>
<cfset etstat=StructNew()>
<cfset etstat_LID=StructNew()>
<cfoutput query=q_trx>
	<cfset StructInsert(etstat,#siETISTAT#,"#ETDESC#")>
	<cfset StructInsert(etstat_LID,#siETISTAT#,"#iLID#")>
</cfoutput>

<!--- Update docs:
		DS.FDOC_CLASSES{iDOCCLASSID:DESC,DEFPRINTPAGES,ALLOWCRTMANAGE}  ...(iDOCCLASSID),
		DS.FDOC_DOCDEFS{iDOCDEFID:DOCCLASSID,DESC,SHORTCAT,STATUS} ...(iDOCDEFID),
		DS_FDOC_DOMDOCS{iDOMAINID:{iDOCDEFID:BCRREAD,BCRCREATE,BCRCONTROL,BCRJOINREVOKE}} ...(iDOMAINID,iDOCDEFID)
	 --->
<CFSET DS.FN.SVCUpdateDS_Docs(DS,CURDSN)>

<!--- Etender type --->
<cfset ettype=StructNew()>
<cfset ETTYPE_LID=StructNew()>
<cfset ettypelist="">
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT iTENDERTYPE, vaTENDERTYPE, iLID=isNULL(iLID,0) FROM biz0080 WITH (NOLOCK) ORDER BY iTENDERTYPE
</cfquery>
<cfloop query="q_trx">
	<cfset ettypelist=listappend(ettypelist,q_trx.itendertype)>
	<cfset StructInsert(ettype,q_trx.iTENDERTYPE,q_trx.vaTENDERTYPE)>
	<cfset StructInsert(ETTYPE_LID,q_trx.iTENDERTYPE,q_trx.iLID)>
</cfloop>

<!--- Etender statuses, trx0070.sitenderstat (for adjuster) : allan --->
<cfset etadjstat=StructNew()>
<cfset etadjstat_LID=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT siETASTAT, ETDESC=vaDESC,iLID=isNULL(iLID,0) FROM BIZ0083 WITH (NOLOCK) WHERE sistatus=0 ORDER BY siETASID
</cfquery>
<cfloop query="q_trx">
	<cfset StructInsert(etadjstat,q_trx.siETASTAT,q_trx.ETDESC)>
	<cfset StructInsert(ETADJSTAT_LID,q_trx.siETASTAT,q_trx.iLID)>
</cfloop>

<!--- Etender Repairer Bid statuses, trx0071.sibidstatus --->
<cfset etbidstat=StructNew()>
<cfset StructInsert(etbidstat,10,"New Tender (Under Preparation)")>
<cfset StructInsert(etbidstat,15,"Pending Adjuster Report")>
<cfset StructInsert(etbidstat,20,"Pending Initiation")>
<cfset StructInsert(etbidstat,30,"Pending Bid")>
<cfset StructInsert(etbidstat,35,"Pending Closing")>
<cfset StructInsert(etbidstat,37,"Pending Re-Bid")>
<cfset StructInsert(etbidstat,38,"Pending Re-Bid Closing")>
<cfset StructInsert(etbidstat,40,"Pending Award Decision")>
<cfset StructInsert(etbidstat,50,"Awarded (Pending Release)")>
<cfset StructInsert(etbidstat,55,"Not Awarded")>
<cfset StructInsert(etbidstat,900,"Suspended")>
<cfset StructInsert(etbidstat,999,"Closed")>
<cfset ETBIDSTAT_LID=StructNew()>
<cfset StructInsert(ETBIDSTAT_LID,10,"25081")>
<cfset StructInsert(ETBIDSTAT_LID,15,"25085")>
<cfset StructInsert(ETBIDSTAT_LID,20,"25080")>
<cfset StructInsert(ETBIDSTAT_LID,30,"25082")>
<cfset StructInsert(ETBIDSTAT_LID,35,"25084")>
<cfset StructInsert(ETBIDSTAT_LID,37,"25086")>
<cfset StructInsert(ETBIDSTAT_LID,38,"25088")>
<cfset StructInsert(ETBIDSTAT_LID,40,"25083")>
<cfset StructInsert(ETBIDSTAT_LID,50,"25087")>
<cfset StructInsert(ETBIDSTAT_LID,55,"9780")>
<cfset StructInsert(ETBIDSTAT_LID,900,"12796")>
<cfset StructInsert(ETBIDSTAT_LID,999,"9495")>

<!--- Claim integration statuses --->
<cfset clmintstat=StructNew()>
<cfset StructInsert(clmintstat,10,"Active Pending Registration")>
<cfset StructInsert(clmintstat,15,"Pending Reserve Update")>
<cfset StructInsert(clmintstat,20,"Registration Sent Pending Reply")>
<cfset StructInsert(clmintstat,25,"Notification Failed")>
<cfset StructInsert(clmintstat,30,"Registration Failed")>
<cfset StructInsert(clmintstat,40,"Claim Reserve Sent Pending Reply")>
<cfset StructInsert(clmintstat,50,"Pending Claim Alert Message")>
<!---cfset StructInsert(clmintstat,60,"Pending Subfolder Reserve Allocation")--->
<cfset StructInsert(clmintstat,100,"Successful Registration")>
<cfset StructInsert(clmintstat,110,"Rejected Payment")>
<cfset StructInsert(clmintstat,120,"Approved Payment Sent Pending Authorization")>
<cfset StructInsert(clmintstat,130,"Fail Agent Update")>
<cfset StructInsert(clmintstat,140,"Success Agent Update")>
<cfset clmintstat_LID=StructNew()>
<cfset StructInsert(CLMINTSTAT_LID,10,"25074")>
<cfset StructInsert(CLMINTSTAT_LID,15,"25077")>
<cfset StructInsert(CLMINTSTAT_LID,20,"25073")>
<cfset StructInsert(CLMINTSTAT_LID,25,"30048")>
<cfset StructInsert(CLMINTSTAT_LID,30,"25075")>
<cfset StructInsert(CLMINTSTAT_LID,40,"25076")>
<cfset StructInsert(CLMINTSTAT_LID,50,"25079")>
<cfset StructInsert(CLMINTSTAT_LID,100,"25078")>
<cfset StructInsert(CLMINTSTAT_LID,110,"0")>
<cfset StructInsert(CLMINTSTAT_LID,120,"0")>
<cfset StructInsert(CLMINTSTAT_LID,130,"0")>
<cfset StructInsert(CLMINTSTAT_LID,140,"0")>

<!--- Recovery/ Subrogation Workflow Status --->
<cfset recstat=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
	select iSTAT=ITSKSTATID,STAT=a.VATSKSTATLOGICNAME,vaDESC=a.VATSKSTATDESC,iLID=IsNull(a.iLID,0)
	FROM FTSK1006 a WITH (NOLOCK) WHERE a.siSTATUS=0 and a.ITSKRULEGRPID=(SELECT ITSKRULEGRPID FROM FTSK1005 where VATSKRULEGRPLOGICNAME = 'RECOVERYFLOW')
	ORDER BY a.IORDER
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(recstat,STAT,iSTAT)>
    <cfset StructInsert(recstat,iSTAT,vaDESC)>
    <cfset StructInsert(recstat,"LID_#iSTAT#",iLID)>
</cfoutput>

<!--- Search Type --->
<cfset multisearchType=StructNew()>
<cfquery NAME=q_stype DATASOURCE=#CURDSN#>
	select iSRCHTYPEID,vaSRCHNAME from FDIR3001 WHERE iDOMAINID=1 and siSTATUS=0
</cfquery>
<cfoutput query=q_stype>
	<cfset StructInsert(multisearchType,iSRCHTYPEID,vaSRCHNAME)>
</cfoutput>

<!--- File Review Status --->
<cfset frstat=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select STAT=a.iFILEREVIEWSTAT,a.vaDESC,iLID=IsNull(a.iLID,0)
FROM FILEREVIEW_STATUS a WITH (NOLOCK) WHERE a.siSTATUS=0
ORDER BY a.vaDESC
</cfquery>
<cfoutput query=q_trx>
    <cfset StructInsert(frstat,STAT,vaDESC)>
    <cfset StructInsert(frstat,"LID_#STAT#",iLID)>
</cfoutput>


<!--- Repairer statuses --->
<cfset rstat=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select STAT=a.siCSTAT,a.vaDESC,iLID=IsNull(a.iLID,0)
FROM BIZ0001 a WITH (NOLOCK) WHERE a.siSTATUS=0
ORDER BY a.siRSID
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(rstat,STAT,vaDESC)>
	<cfset StructInsert(rstat,"LID_#STAT#",iLID)>
</cfoutput>

<!--- Insurer statuses --->
<cfset istat=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select STAT=a.siCSTAT,a.vaDESC,iLID=IsNull(a.iLID,0)
FROM BIZ0002 a WITH (NOLOCK) WHERE a.siSTATUS=0
ORDER BY a.siISID
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(istat,STAT,vaDESC)>
	<cfset StructInsert(istat,"LID_#STAT#",iLID)>
</cfoutput>

<!--- Adjuster statuses --->
<cfset astat=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select STAT=a.siCSTAT,a.vaDESC,iLID=IsNull(a.iLID,0)
FROM BIZ0003 a WITH (NOLOCK) WHERE a.siSTATUS=0
ORDER BY a.siASID
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(astat,STAT,vaDESC)>
	<cfset StructInsert(astat,"LID_#STAT#",iLID)>
</cfoutput>

<!--- Supplier statuses --->
<cfset sstat=StructNew()>
<cfset bstat=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select STAT=a.siCSTAT,a.vaDESC,a.vaDESCB,iLID=isNULL(a.iLID,0)
FROM BIZ0104 a WITH (NOLOCK) WHERE a.siSTATUS=0
ORDER BY a.siSSID
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(sstat,STAT,vaDESC)>
	<cfset StructInsert(sstat,"LID_#STAT#",iLID)>
</cfoutput>
<cfoutput query=q_trx>
	<cfset StructInsert(bstat,STAT,vaDESCB)>
	<cfset StructInsert(bstat,"LID_#STAT#",iLID)>
</cfoutput>

<!--- payment REQGRP status --->
<cfset paygstat=structnew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select STAT=siGSTAT, vaDESC FROM fpay0030 with (nolock)
ORDER BY siGSTAT
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(paygstat,STAT,vaDESC)>
</cfoutput>

<!--- DMS statuses --->
<cfset dmsstat=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select STAT=a.siCSTAT,a.vaDESC
FROM BIZ0105 a WITH (NOLOCK) WHERE a.siSTATUS=0
ORDER BY a.siSSID
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(dmsstat,STAT,vaDESC)>
</cfoutput>

<!--- Insurer statuses --->
<cfset sasstat=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select STAT=a.siCSTAT,a.vaDESC
FROM BIZ0106 a WITH (NOLOCK) WHERE a.siSTATUS=0
ORDER BY a.siSSID
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(sasstat,STAT,vaDESC)>
</cfoutput>

<!--- ARC application statuses --->
<cfset arcappstat=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select STAT=a.siAPPSTAT,a.vaDESC
FROM ARC_APP_STATUS_DEF a WITH (NOLOCK) WHERE a.siSTATUS=0
ORDER BY a.siAPPSTAT
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(arcappstat,STAT,vaDESC)>
</cfoutput>

<!--- Parts Grouping --->
<cfset pgrp=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CATDSN#>
SELECT igroupid=a.iPGRPID/1000000,a.vaPGRPDESC,iLID=IsNull(a.iLID,0) FROM PDB0002 a WITH (NOLOCK) WHERE a.siSTATUS=0
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(pgrp,igroupid,vaPGRPDESC)>
	<cfset StructInsert(pgrp,"LID_#igroupid#",iLID)>
</cfoutput>
<cfset psc=ArrayNew(1)>
<cfquery NAME=q_trx DATASOURCE=#CATDSN#>
SELECT a.IPSCID,a.VAPSCDESC FROM PDB0001 a WITH (NOLOCK) WHERE a.siSTATUS=0
</cfquery>
<cfoutput query=q_trx>
	<cfset psc[iPSCID]=StructNew()>
	<cfset psc[iPSCID].PSCNAME=vaPSCDESC>
	<cfquery NAME=q_trx2 DATASOURCE=#CATDSN#>
	SELECT igroupid=a.iPGRPID/1000000 FROM PDB0002 a WITH (NOLOCK) WHERE a.siSTATUS=0 AND a.iPSCIDMASK & POWER(2,<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#IPSCID#">-1) <> 0
	</cfquery>
	<cfset psc[iPSCID].PGRPLIST=ValueList(q_trx2.igroupid)>
</cfoutput>

<!--- Paint type --->
<cfset patype=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CATDSN#>
select a.iPATYPEID,a.vaDESC,iLID=IsNull(a.iLID,0) from CAT0010 a WITH (NOLOCK)
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(patype,ipatypeid,vaDESC)>
	<cfset StructInsert(patype,"LID_#ipatypeid#",iLID)>
</cfoutput>
<cfquery NAME=q_trx DATASOURCE=#CATDSN#>
select a.iPATYPEID from CAT0010 a WITH (NOLOCK) WHERE siSTATUS=0 ORDER BY a.vaDESC
</cfquery>
<cfset patypelist=ValueList(q_trx.iPATYPEID)>

<!--- Vehicle Type --->
<cfset vhtype=StructNew()>
<cfset vhtypeshort=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CATDSN#>
select a.siVHTYPEID,a.vaDESC,a.vaSHORTDESC from CAT0021 a WITH (NOLOCK)
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(vhtype,sivhtypeid,vaDESC)>
	<cfset StructInsert(vhtypeshort,sivhtypeid,vaSHORTDESC)>
</cfoutput>
<cfquery NAME=q_trx DATASOURCE=#CATDSN#>
select a.siVHTYPEID from CAT0021 a WITH (NOLOCK) WHERE a.siSTATUS=0 ORDER BY a.vaDESC
</cfquery>
<cfset vhtypelist=ValueList(q_trx.siVHTYPEID)>
<cfquery name=q_itm datasource=#CATDSN#>
SELECT ID=a.iTRANSTYPE,DSC=a.vaDESC,SHORTDSC=a.vaSHORTDESC
FROM PDB0031 a WITH (NOLOCK)
</cfquery>
<cfset STRSHORT=StructNew()><cfset STR=StructNew()><cfloop query=q_itm><cfset StructInsert(STRSHORT,ID,SHORTDSC)><cfset StructInsert(STR,ID,DSC)></cfloop>
<cfset TRANSTYPE=STR><cfset TRANSTYPESHORT=STRSHORT>
<cfquery name=q_itm datasource=#CATDSN#>
SELECT ID=a.iFUELTYPE,DSC=a.vaDESC,SHORTDSC=a.vaSHORTDESC
FROM PDB0032 a WITH (NOLOCK)
</cfquery>
<cfset STRSHORT=StructNew()>
<cfset STR=StructNew()><cfloop query=q_itm><cfset StructInsert(STRSHORT,ID,SHORTDSC)><cfset StructInsert(STR,ID,DSC)></cfloop>
<cfset FUELTYPE=STR><cfset FUELTYPESHORT=STRSHORT>
<cfquery name=q_itm datasource=#CATDSN#>
SELECT ID=a.iASPITYPE,DSC=a.vaDESC,SHORTDSC=a.vaSHORTDESC
FROM PDB0033 a WITH (NOLOCK)
</cfquery>
<cfset STR=StructNew()><cfloop query=q_itm><cfset StructInsert(STR,ID,DSC)></cfloop>
<cfset ASPITYPE=STR>
<cfquery name=q_itm datasource=#CATDSN#>
SELECT ID=a.iENGCONFIG,DSC=a.vaDESC,SHORTDSC=a.vaSHORTDESC
FROM PDB0034 a WITH (NOLOCK)
</cfquery>
<cfset STR=StructNew()><cfloop query=q_itm><cfset StructInsert(STR,ID,DSC)></cfloop>
<cfset ENGCONFIG=STR>
<cfquery name=q_itm datasource=#CATDSN#>
SELECT ID=a.iENGCONFIG
FROM PDB0034 a WITH (NOLOCK) WHERE a.siSTATUS=0
ORDER BY a.vaDESC
</cfquery>
<cfset ENGCONFIGLIST=ValueList(q_itm.ID)>

<!--- License Class --->
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select vaCFDESC, vaCFCODE, iLID, icoid, sistatus
FROM biz0025 with (nolock) WHERE acftype='DRVLICLS'
ORDER BY icoid, vaCFCODE
</cfquery>
<cfset drvlicls=StructNew()>
<cfset drvliclslist=StructNew()>
<cfoutput query="q_trx" group="icoid">
	<cfset StructInsert(drvliclslist,icoid,StructNew())>
	<cfset drvliclslist[icoid]="">
	<cfoutput>
		<cfif q_trx.sistatus IS 0>
			<cfset drvliclslist[icoid]=LISTAPPEND(drvliclslist[icoid],vaCFCODE)>
		</cfif>
		<cfset StructInsert(drvlicls,vaCFCODE,vaCFDESC)>
	</cfoutput>
</cfoutput>

<!--- Vehicle Color --->
<cfset vhcolor=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT a.siCOLORID,a.vaDESC,iLID=IsNull(a.iLID,0) FROM CAT0024 a WITH (NOLOCK)
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(vhcolor,sicolorid,vaDESC)>
	<cfset StructInsert(vhcolor,"LID_#sicolorid#",iLID)>
</cfoutput>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT a.siCOLORID FROM CAT0024 a WITH (NOLOCK) WHERE a.siSTATUS=0 ORDER BY a.siORDER, a.vaDESC
</cfquery>
<cfset vhcolorlist=ValueList(q_trx.siCOLORID)>

<!--- Damage Conditions --->
<cfset damcon=StructNew()><CFSET damconlist1lang=""><CFSET damconlist2lang=""><CFSET damconlist1="">
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT a.siDAMCONID,a.iDAMMASK,a.vaDESC,iLID=isNULL(a.iLID,0) from CAT0017 a WITH (NOLOCK) WHERE a.siSTATUS=0 ORDER BY a.vaDESC
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(damcon,siDAMCONID,vaDESC)>
	<CFIF BitAnd(iDAMMASK,1) IS 1><cfset damconlist1lang=ListAppend(damconlist1lang,siDAMCONID&"|""+JSVClang("""&vaDESC&""","&iLID&")+""","|")></CFIF>
	<CFIF BitAnd(iDAMMASK,2) IS 2><cfset damconlist2lang=ListAppend(damconlist2lang,siDAMCONID&"|""+JSVClang("""&vaDESC&""","&iLID&")+""","|")></CFIF>
	<CFIF BitAnd(iDAMMASK,1) IS 1><cfset damconlist1=ListAppend(damconlist1,siDAMCONID&"|"&vaDESC,"|")></CFIF>
</cfoutput>

<!--- Vehicle Manufacturers --->
<cfset vhman=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CATDSN#>
SELECT a.iMANID,a.vaMAN FROM CAT0002 a WITH (NOLOCK)
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(vhman,iMANID,Trim(vaMAN))>
</cfoutput>

<!--- Collision With --->
<cfset COLLTYPE=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT a.siCOLTYPE,a.vaDESC,iLID=IsNull(a.iLID,0) FROM CAT0026 a WITH (NOLOCK)
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(COLLTYPE,sicoltype,vaDESC)>
	<cfset StructInsert(COLLTYPE,"LID_#sicoltype#",iLID)>
</cfoutput>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT a.siCOLTYPE FROM CAT0026 a WITH (NOLOCK) ORDER BY a.vaDESC
</cfquery>
<cfset COLLTYPElist=ValueList(q_trx.siCOLTYPE)>

<!--- Occupation --->
<cfset occupation=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT ID=a.siOCCUPATION,vaDESC=a.vaDESC,iLID=IsNull(a.iLID,0) FROM SYS0018 a WITH (NOLOCK)
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(OCCUPATION,ID,vaDESC)>
	<cfset StructInsert(OCCUPATION,"LID_#ID#",iLID)>
</cfoutput>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT ID=a.siOCCUPATION, igcoid , iselector=ct.iclmtypemask
FROM SYSB0018 a WITH (NOLOCK) JOIN SYS0018 b with (nolock) ON a.siOCCUPATION=b.siOCCUPATION
LEFT JOIN CLMD0010 ct WITH (NOLOCK) ON a.iselector&ct.iclmtypemask>0
WHERE a.siSTATUS=0 ORDER BY a.igcoid, ct.vaclmtype, b.vaDESC
</cfquery>

<!--- <cfset occupationlist=ValueList(q_trx.ID)> --->
<cfset occupationlist=StructNew()>
<cfoutput query="q_trx" group="igcoid">
<!--- 	<cfif igcoid IS 0>
		<cfset StructInsert(occupationlist,"list",StructNew())>
		<cfset nodestr=occupationlist[igcoid]>
	<cfelse> --->
		<cfset StructInsert(occupationlist,igcoid,StructNew())>
		<cfset nodestr=occupationlist[igcoid]>
<!--- 	</cfif> --->
	<cfoutput group="iselector">
		<cfif iselector IS "">
			<cfset StructInsert(nodestr,"list","")>
			<cfset nodestr=nodestr>
		<cfelse>
			<cfset StructInsert(nodestr,"iselector",StructNew())>
			<cfset StructInsert(nodestr.iselector,"#iselector#",StructNew())>
			<cfset StructInsert(nodestr.iselector[iselector],"list","")>
			<cfset nodestr=nodestr.iselector[iselector]>
		</cfif>
		<cfset itmlist="">
		<cfoutput>
			<cfset itmlist=listappend(itmlist,q_trx.ID)>
		</cfoutput>
		<cfset nodestr.list="#itmlist#">
	</cfoutput>
</cfoutput>

<!--- PARS Start --->
<!--- Quarter stat --->
<CFSET QuarterStat = StructNew()>
<cfquery NAME="q_trx" DATASOURCE="#CURDSN#">
SELECT STAT = a.siQSTAT, a.vaDESC
FROM BIZ4001 a WITH (NOLOCK)
WHERE a.siSTATUS = 0
ORDER BY a.siQSTAT
</cfquery>
<cfoutput query="q_trx">
	<cfset StructInsert(QuarterStat, STAT, vaDESC)>
</cfoutput>
<CFSET DS.QuarterStat = QuarterStat>

<!--- Application PIAM stat --->
<CFSET PIAMCStat = StructNew()>
<cfquery NAME="q_trx" DATASOURCE="#CURDSN#">
SELECT STAT = a.siPCSTAT, a.vaDESC
FROM BIZ4002 a WITH (NOLOCK)
WHERE a.siSTATUS = 0
ORDER BY a.siPCSTAT
</cfquery>
<cfoutput query="q_trx">
	<cfset StructInsert(PIAMCStat, STAT, vaDESC)>
</cfoutput>
<CFSET DS.PIAMCStat = PIAMCStat>

<!--- Applicant stat --->
<CFSET APPLCStat = StructNew()>
<cfquery NAME="q_trx" DATASOURCE="#CURDSN#">
SELECT STAT = a.siAPPLCSTAT, a.vaDESC
FROM BIZ4003 a WITH (NOLOCK)
WHERE a.siSTATUS = 0
ORDER BY a.siAPPLCSTAT
</cfquery>
<cfoutput query="q_trx">
	<cfset StructInsert(APPLCStat, STAT, vaDESC)>
</cfoutput>
<CFSET DS.APPLCStat = APPLCStat>

<CFSET PARSADJCStat = StructNew()>
<cfquery NAME="q_trx" DATASOURCE="#CURDSN#">
SELECT STAT = a.siACSTAT, a.vaDESC
FROM BIZ4004 a WITH (NOLOCK)
WHERE a.siSTATUS = 0
ORDER BY a.siACSTAT
</cfquery>
<cfoutput query="q_trx">
	<cfset StructInsert(PARSADJCStat, STAT, vaDESC)>
</cfoutput>
<CFSET DS.PARSADJCStat = PARSADJCStat>

<!--- Veto Reason --->
<CFSET VetoReason = StructNew()>
<cfquery NAME="q_trx" DATASOURCE="#CURDSN#">
SELECT a.vaCFCODE, a.vaCFDESC
FROM BIZ0025 a WITH (NOLOCK) WHERE a.iCOID=0 AND a.aCFTYPE = 'PARSVETO' AND a.siSTATUS=0
ORDER BY a.vaCFCODE
</cfquery>
<cfoutput query="q_trx">
	<cfset StructInsert(VetoReason, vaCFCODE, vaCFDESC)>
</cfoutput>
<CFSET DS.PARSVetoReason = VetoReason>
<!--- PARS End --->

<!--- ESProgrammes --->
<cfset pes=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT iESPROGRAM,vaDESC,siESTYPE FROM BIZ0030 a WITH (NOLOCK) WHERE a.siSTATUS=0
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(pes,iESPROGRAM,vaDESC)>
</cfoutput>

<cfset rpttype=ArrayNew(1)>
<cfset rpttype[1]="Adjuster Immediate Advice">
<cfset rpttype[2]="Adjuster Preliminary Report">
<cfset rpttype[3]="Adjuster Status Report">
<cfset rpttype[4]="Adjuster Final Report">
<cfset rpttype[5]="Adjuster Supplementary Report">
<cfset rpttype[6]="Adjuster Draft Final Report">
<cfset rpttype[11]="Initial Opinion">
<cfset rpttype[14]="Opinion Report">
<cfset rpttype[15]="Revised Opinion">
<!--- START #26730# --->
<cfset rpttype[20]="Adjuster Progress Report">
<cfset rpttype[21]="Adjuster Draft Final Report">
<cfset rpttype[22]="Adjuster Final Progress Report">
<!--- END #26730# --->

<cfset RPTTYPE_LID=ArrayNew(1)>
<cfset RPTTYPE_LID[1]="10384">
<cfset RPTTYPE_LID[2]="10385">
<cfset RPTTYPE_LID[3]="10386">
<cfset RPTTYPE_LID[4]="10387">
<cfset RPTTYPE_LID[5]="23228">
<cfset RPTTYPE_LID[6]="23229">
<cfset RPTTYPE_LID[11]="23287">
<cfset RPTTYPE_LID[14]="7873">
<cfset RPTTYPE_LID[15]="23288">
<cfset RPTTYPE_LID[20]="0">
<cfset RPTTYPE_LID[21]="0">
<cfset RPTTYPE_LID[22]="0">

<cfset rpttypeshort=ArrayNew(1)>
<cfset rpttypeshort[1]="Imm.Adv">
<cfset rpttypeshort[2]="Prelim">
<cfset rpttypeshort[3]="Status">
<cfset rpttypeshort[4]="Final">
<cfset rpttypeshort[5]="Supp">
<cfset rpttypeshort[6]="Draft Final">
<cfset rpttypeshort[11]="Init.Opinion">
<cfset rpttypeshort[14]="Opinion.Rpt">
<cfset rpttypeshort[15]="Rev.Opinion">
<cfset rpttypeshort[20]="Adj.Progress Rpt">
<cfset rpttypeshort[21]="Adj.Draft Final Rpt">
<cfset rpttypeshort[22]="Adj.Final Progress Rpt">
<cfset RPTTYPESHORT_LID=ArrayNew(1)>
<cfset RPTTYPESHORT_LID[1]="26516">
<cfset RPTTYPESHORT_LID[2]="9471">
<cfset RPTTYPESHORT_LID[3]="1352">
<cfset RPTTYPESHORT_LID[4]="9473">
<cfset RPTTYPESHORT_LID[5]="1354">
<cfset RPTTYPESHORT_LID[6]="26517">
<cfset RPTTYPESHORT_LID[11]="26518">
<cfset RPTTYPESHORT_LID[14]="26519">
<cfset RPTTYPESHORT_LID[15]="26520">
<cfset RPTTYPESHORT_LID[20]="0">
<cfset RPTTYPESHORT_LID[21]="0">
<cfset RPTTYPESHORT_LID[22]="0">

<!--- Standard Parts Remarks --->
<cfset partremarks=ArrayNew(1)>
<cfset partremarks[1]="Repair">
<cfset partremarks[2]="Serviceable">
<cfset partremarks[3]="To Check">
<cfset partremarks[4]="Old Damage">
<cfset partremarks[5]="Inconsistent">
<cfset partremarks[6]="See Remarks">
<cfset partremarks[7]="To Supply">
<cfset partremarks[8]="Supplying">
<cfset partremarks[9]="Reuse">
<cfset partremarks[10]="Readjust">
<cfset partremarks[11]="Repaint">
<cfset partremarks[12]="Optional">
<cfset partremarks[13]="Refurbish">
<cfset partremarks[14]="To Clean">
<cfset partremarks[15]="Accessory">
<cfset partremarks[16]="C/W Unit">
<cfset partremarks[17]="Repeat">
<cfset partremarks[18]="Repolish">
<cfset partremarks[19]="C/W Cabin Assy">
<cfset partremarks[20]="Owner`s A/C">
<cfset partremarks[21]="To Be Supplied">
<cfset partremarks[22]="Refit">
<cfset partremarks[23]="Fraud Others">
<cfset partremarks[24]="Not covered">
<cfset partremarks[25]="Exceed Limit">
<cfset partremarks[26]="Other than the above">
<!---cfset partremarks[21]="Refit"--->
<cfset PARTREMARKS_LID=ArrayNew(1)>
<cfset PARTREMARKS_LID[1]="5851">
<cfset PARTREMARKS_LID[2]="26499">
<cfset PARTREMARKS_LID[3]="26500">
<cfset PARTREMARKS_LID[4]="26501">
<cfset PARTREMARKS_LID[5]="10314">
<cfset PARTREMARKS_LID[6]="26502">
<cfset PARTREMARKS_LID[7]="18327">
<cfset PARTREMARKS_LID[8]="18328">
<cfset PARTREMARKS_LID[9]="26503">
<cfset PARTREMARKS_LID[10]="26504">
<cfset PARTREMARKS_LID[11]="26505">
<cfset PARTREMARKS_LID[12]="25779">
<cfset PARTREMARKS_LID[13]="26506">
<cfset PARTREMARKS_LID[14]="26507">
<cfset PARTREMARKS_LID[15]="18410">
<cfset PARTREMARKS_LID[16]="26508">
<cfset PARTREMARKS_LID[17]="26509">
<cfset PARTREMARKS_LID[18]="26510">
<cfset PARTREMARKS_LID[19]="26511">
<cfset PARTREMARKS_LID[20]="26512">
<cfset PARTREMARKS_LID[21]="26513">
<cfset PARTREMARKS_LID[22]="26514">
<cfset PARTREMARKS_LID[23]="26515">
<cfset PARTREMARKS_LID[24]="29577">
<cfset PARTREMARKS_LID[25]="0">
<cfset PARTREMARKS_LID[26]="0">
<!--- Circumstances of acct --->
<cfset catype=StructNew()>
<cfset catypemask=StructNew()>
<cfset catype_LID=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT a.vaCFCODE,a.vaCFDESC,a.iCLMTYPEMASK,iLID=isNULL(a.iLID,0)
FROM BIZ0025 a WITH (NOLOCK) WHERE a.iCOID=0 AND a.aCFTYPE='CIRACT' AND a.siSTATUS=0
AND CONVERT(int,vaCFCODE)<1000
ORDER BY a.vaCFDESC
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(catype,vaCFCODE,vaCFDESC)>
	<cfset StructInsert(catypemask,vaCFCODE,iCLMTYPEMASK)>
	<cfset StructInsert(catype_LID,vaCFCODE,iLID)>
</cfoutput>
<cfset catypelist=ValueList(q_trx.vaCFCODE)>

<!--- Circumstances of acct for marine transit --->
<cfset catype2=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT a.vaCFCODE,a.vaCFDESC
FROM BIZ0025 a WITH (NOLOCK) WHERE a.iCOID=0 AND a.aCFTYPE='CIRACT' AND a.siSTATUS=0
AND CONVERT(int,vaCFCODE)<1000
AND iCLMTYPEMASK&64>0
ORDER BY a.vaCFDESC
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(catype2,vaCFCODE,vaCFDESC)>
</cfoutput>
<cfset catype2list=ValueList(q_trx.vaCFCODE)>

<!--- Type of Accident for SAS module --->
<cfset catype_SAS=StructNew()>
<cfquery name=q_trx datasource=#CURDSN#>
SELECT a.vaCFCODE,a.vaCFDESC,a.iCLMTYPEMASK,iLID=isNULL(a.iLID,0)
FROM BIZ0025 a WITH (NOLOCK) WHERE a.iCOID=0 AND a.aCFTYPE='CIRACT_SAS' AND a.siSTATUS=0
ORDER BY a.vaCFDESC
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(catype_SAS,vaCFCODE,{ DSC=vaCFDESC,MASK=iCLMTYPEMASK,LID=iLID })>
</cfoutput>
<cfset catype_SAS_list=ValueList(q_trx.vaCFCODE)>

<cfset policedist=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.vaCFCODE,a.vaCFDESC
from BIZ0025 a WITH (NOLOCK) WHERE a.iCOID=0 AND a.aCFTYPE='POLICEC' AND a.sistatus=0
ORDER BY a.vaCFDESC
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(policedist,vaCFCODE,vaCFDESC)>
</cfoutput>
<cfset policedistlist=ValueList(q_trx.vaCFCODE)>

<CFIF MICDSN IS NOT "">
	<cfquery NAME=q_trx DATASOURCE=#MICDSN#><!--- taken from Merimen IC21 --->
	SELECT vaportname FROM fzmar_ports with (nolock) WHERE sitype=1 and sistatus=0
	</cfquery>
	<cfset portloclist=ValueList(q_trx.vaportname)>
<CFELSE>
	<CFSET portloclist="">
</CFIF>

<cfset risktype=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.vaCFCODE,a.vaCFDESC, a.ICLMTYPEMASK
from BIZ0025 a WITH (NOLOCK) WHERE a.iCOID=0 AND a.aCFTYPE='RISKTYPE' AND a.sistatus=0
ORDER BY a.vaCFDESC
</cfquery>
<cfoutput query=q_trx>
	<cfset temp=StructNew()>
	<cfset StructInsert(temp,"desc",vaCFDESC)>
	<cfset StructInsert(temp,"clmtypemask",ICLMTYPEMASK)>
	<cfset StructInsert(risktype,vaCFCODE,temp)>
</cfoutput>
<cfset risktypelist=ValueList(q_trx.vaCFCODE)>

<!--- 37153 --->
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.icoid,a.vaCFCODE,a.vaCFMAPCODE,a.vaCFDESC,a.ICLMTYPEMASK
from BIZ0025 a WITH (NOLOCK) WHERE /*a.iCOID=0 AND*/ a.aCFTYPE='RISKTYPE' AND a.sistatus=0
ORDER BY a.icoid, a.vaCFDESC
</cfquery>

<cfset risktypecoid=StructNew()>
<cfset risktypecoidlist=StructNew()>

<cfloop query="q_trx">
	<cfif NOT StructKeyExists(risktypecoid,vacfcode)>
		<cfset StructInsert(risktypecoid,vacfcode,StructNew())>
		<cfset StructInsert(risktypecoid[vacfcode],"name",vaCFDESC)>
		<cfset StructInsert(risktypecoid[vacfcode],"clmtypemask",ICLMTYPEMASK)>
	</cfif>

	<cfif NOT StructKeyExists(risktypecoidlist,icoid)>
		<cfset StructInsert(risktypecoidlist,icoid,StructNew())>
	</cfif>

	<cfif NOT StructKeyExists(risktypecoidlist[icoid],ICLMTYPEMASK)>
		<cfset StructInsert(risktypecoidlist[icoid],ICLMTYPEMASK,"#vaCFCODE#")>
	<cfelse>
		<cfset StructUpdate(risktypecoidlist[icoid],ICLMTYPEMASK,listAppend(risktypecoidlist[icoid][ICLMTYPEMASK], vaCFCODE))>
	</cfif>
</cfloop>
<!--- 37153 --->

<cfset protectequip=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.vaCFCODE,a.vaCFDESC, a.ICLMTYPEMASK
from BIZ0025 a WITH (NOLOCK) WHERE a.iCOID=0 AND a.aCFTYPE='PTEQUIP' AND a.sistatus=0
ORDER BY a.vaCFDESC
</cfquery>
<cfoutput query=q_trx>
	<cfset temp=StructNew()>
	<cfset StructInsert(temp,"desc",vaCFDESC)>
	<cfset StructInsert(temp,"clmtypemask",ICLMTYPEMASK)>
	<cfset StructInsert(protectequip,vaCFCODE,temp)>
</cfoutput>
<cfset protectequiplist=ValueList(q_trx.vaCFCODE)>

<!--- Customization #13122 : TH MSIG - important claim reason --->
<cfset impclmrsn=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.vaCFCODE,a.vaCFDESC, a.ICLMTYPEMASK
from BIZ0025 a WITH (NOLOCK) WHERE a.iCOID=0 AND a.aCFTYPE='IMPCLMRS' AND a.sistatus=0
ORDER BY a.vaCFDESC
</cfquery>
<cfoutput query=q_trx>
	<cfset temp=StructNew()>
	<cfset StructInsert(temp,"desc",vaCFDESC)>
	<cfset StructInsert(temp,"clmtypemask",ICLMTYPEMASK)>
	<cfset StructInsert(impclmrsn,vaCFCODE,temp)>
</cfoutput>
<cfset impclmrsnlist=ValueList(q_trx.vaCFCODE)>

<cfset tppditm=StructNew()>
<cfset tppditmlist=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.ICOID, a.vaCFCODE,a.vaCFDESC, a.ICLMTYPEMASK
from BIZ0025 a WITH (NOLOCK) WHERE a.aCFTYPE='TPPDITM' AND a.sistatus=0
ORDER BY ICOID, CASE WHEN UPPER(vaCFDESC)='OTHERS' THEN 999 ELSE 0 END, a.vaCFDESC
</cfquery>
<cfoutput query=q_trx>
	<cfif NOT StructKeyExists(tppditm,ICOID)>
		<cfset StructInsert(tppditm,icoid,StructNew())>
	</cfif>
	<cfset temp_node=StructNew()>
	<cfset StructInsert(temp_node,"desc",vaCFDESC)>
	<cfset StructInsert(temp_node,"clmtypemask",ICLMTYPEMASK)>
	<cfset StructInsert(tppditm[icoid],vaCFCODE,temp_node)>
	<cfif NOT StructKeyExists(tppditmlist,ICOID)>
		<cfset StructInsert(tppditmlist,icoid,"")>
	</cfif>
	<cfset tppditmlist[icoid]=#LISTAPPEND(tppditmlist[icoid],vaCFCODE)#>
</cfoutput>

<cfset distribchannel=StructNew()>
<cfset distribchannellist=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select ord=case when vaCFDESC<>'Others' then 0 else 1 end, a.ICOID, a.vaCFCODE,a.vaCFDESC, a.ICLMTYPEMASK
from BIZ0025 a WITH (NOLOCK) WHERE a.aCFTYPE='DISTRCHN' and sistatus=0
ORDER BY ord,a.vaCFDESC
</cfquery>
<cfoutput query=q_trx>
	<cfset temp=StructNew()>
	<cfset StructInsert(temp,"desc",vaCFDESC)>
	<cfset StructInsert(temp,"clmtypemask",ICLMTYPEMASK)>
	<cfset StructInsert(distribchannel,vaCFCODE,temp)>
	<cfif StructKeyExists(distribchannellist,"#ICOID#")>
		<cfset distribchannellist[ICOID]=#LISTAPPEND(distribchannellist[ICOID],vaCFCODE)#>
	<cfelse>
		<cfset StructInsert(distribchannellist,ICOID,vaCFCODE)>
	</cfif>
</cfoutput>

<cfset inwardtype=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.ICOID, a.vaCFCODE,a.vaCFDESC, a.ICLMTYPEMASK
from BIZ0025 a WITH (NOLOCK) WHERE a.aCFTYPE='INWARDTYPE'
ORDER BY a.vaCFDESC
</cfquery>
<cfoutput query=q_trx>
	<cfset temp=StructNew()>
	<cfset StructInsert(temp,"desc",vaCFDESC)>
	<cfset StructInsert(temp,"clmtypemask",ICLMTYPEMASK)>
	<cfset StructInsert(inwardtype,vaCFCODE,temp)>
</cfoutput>
<cfset inwardtypelist=ValueList(q_trx.vaCFCODE)>

<cfset tenderlosstype=StructNew()>
<cfset tenderlosstypelist=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.ICOID, a.vaCFCODE,a.vaCFDESC, a.ICLMTYPEMASK
from BIZ0025 a WITH (NOLOCK) WHERE a.aCFTYPE='TDLOSSTYPE'
ORDER BY a.vaCFDESC
</cfquery>
<cfoutput query=q_trx>
	<cfset temp=StructNew()>
	<cfset StructInsert(temp,"desc",vaCFDESC)>
	<!--- <cfset StructInsert(temp,"clmtypemask",ICLMTYPEMASK)> --->
	<cfset StructInsert(tenderlosstype,vaCFCODE,temp)>
	<cfif StructKeyExists(tenderlosstypelist,"#ICOID#")>
		<cfset tenderlosstypelist[ICOID]=#LISTAPPEND(tenderlosstypelist[ICOID],vaCFCODE)#>
	<cfelse>
		<cfset StructInsert(tenderlosstypelist,ICOID,vaCFCODE)>
	</cfif>
</cfoutput>

<cfset tendertypeclm=StructNew()>
<cfset tendertypeclmlist=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.ICOID, a.vaCFCODE,a.vaCFDESC, a.ICLMTYPEMASK
from BIZ0025 a WITH (NOLOCK) WHERE a.aCFTYPE='TDTYPECLM'
ORDER BY a.vaCFDESC
</cfquery>
<cfoutput query=q_trx>
	<cfset temp=StructNew()>
	<cfset StructInsert(temp,"desc",vaCFDESC)>
	<!--- <cfset StructInsert(temp,"clmtypemask",ICLMTYPEMASK)> --->
	<cfset StructInsert(tendertypeclm,vaCFCODE,temp)>
	<cfif StructKeyExists(tendertypeclmlist,"#ICOID#")>
		<cfset tendertypeclmlist[ICOID]=#LISTAPPEND(tendertypeclmlist[ICOID],vaCFCODE)#>
	<cfelse>
		<cfset StructInsert(tendertypeclmlist,ICOID,vaCFCODE)>
	</cfif>
</cfoutput>

<cfset injdiag=StructNew()>
<cfset injdiaglist=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.ICOID,a.vaCFCODE,a.vaCFDESC, a.ICLMTYPEMASK, a.sistatus, a.vacfmapcode
from BIZ0025 a WITH (NOLOCK) WHERE a.aCFTYPE='INJDIAG'
ORDER BY a.ICOID,a.vaCFDESC
</cfquery>
<cfoutput query=q_trx>
	<cfset temp=StructNew()>
	<cfset StructInsert(temp,"desc",vaCFDESC)>
	<cfset StructInsert(temp,"icd",vacfmapcode)>
	<cfset StructInsert(temp,"clmtypemask",ICLMTYPEMASK)>
	<cfset StructInsert(injdiag,vaCFCODE,temp)>
	<cfif sistatus IS 0>
		<cfif StructKeyExists(injdiaglist,"#ICOID#")>
			<cfset injdiaglist[ICOID]=#LISTAPPEND(injdiaglist[ICOID],vaCFCODE)#>
		<cfelse>
			<cfset StructInsert(injdiaglist,ICOID,vaCFCODE)>
		</cfif>
	</cfif>
</cfoutput>

<cfset injcpt=StructNew()>
<cfset injcptlist=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.ICOID,a.vaCFCODE,a.vaCFDESC, a.ICLMTYPEMASK, a.sistatus, a.vacfmapcode, a.vacfmapcode2
from BIZ0025 a WITH (NOLOCK) WHERE a.aCFTYPE='CPT'
ORDER BY a.ICOID,a.vaCFDESC
</cfquery>
<cfoutput query=q_trx>
	<cfset temp=StructNew()>
	<cfset StructInsert(temp,"desc",vaCFDESC)>
	<cfset StructInsert(temp,"code1",vacfmapcode)>
	<cfset StructInsert(temp,"code2",vacfmapcode2)>
	<cfset StructInsert(temp,"clmtypemask",ICLMTYPEMASK)>
	<cfset StructInsert(injcpt,vaCFCODE,temp)>
	<cfif sistatus IS 0>
		<cfif StructKeyExists(injcptlist,"#ICOID#")>
			<cfset injcptlist[ICOID]=#LISTAPPEND(injcptlist[ICOID],vaCFCODE)#>
		<cfelse>
			<cfset StructInsert(injcptlist,ICOID,vaCFCODE)>
		</cfif>
	</cfif>
</cfoutput>

<cfset injuredclass=StructNew()>
<cfset injuredclasslist=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.ICOID,a.vaCFCODE,a.vaCFDESC, a.ICLMTYPEMASK, a.sistatus
from BIZ0025 a WITH (NOLOCK) WHERE a.aCFTYPE='INJDCLS'
ORDER BY a.ICOID,a.vaCFDESC
</cfquery>
<cfoutput query=q_trx>
	<cfset temp=StructNew()>
	<cfset StructInsert(temp,"desc",vaCFDESC)>
	<cfset StructInsert(temp,"clmtypemask",ICLMTYPEMASK)>
	<cfset StructInsert(injuredclass,vaCFCODE,temp)>
	<cfif sistatus IS 0>
		<cfif StructKeyExists(injuredclasslist,"#ICOID#")>
			<cfset injuredclasslist[ICOID]=#LISTAPPEND(injuredclasslist[ICOID],vaCFCODE)#>
		<cfelse>
			<cfset StructInsert(injuredclasslist,ICOID,vaCFCODE)>
		</cfif>
	</cfif>
</cfoutput>

<cfset CONVEYTYPE=StructNew()>
<cfset CONVEYTYPELIST=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.ICOID,a.vaCFCODE,a.vaCFDESC, a.ICLMTYPEMASK, a.sistatus, a.ilid
from BIZ0025 a WITH (NOLOCK) WHERE a.aCFTYPE='CONVEYTYPE'
ORDER BY a.ICOID,CASE WHEN vaCFDESC='OTHERS' OR vaCFDESC='OTHER' THEN 1 ELSE 0 END, a.vaCFDESC
</cfquery>
<cfoutput query=q_trx>
	<cfset temp=StructNew()>
	<cfset StructInsert(temp,"desc",vaCFDESC)>
	<cfset StructInsert(temp,"clmtypemask",ICLMTYPEMASK)>
	<cfset StructInsert(temp,"lid",ilid)>
	<cfset StructInsert(CONVEYTYPE,vaCFCODE,temp)>
	<cfif sistatus IS 0>
		<cfif StructKeyExists(CONVEYTYPELIST,"#ICOID#")>
			<cfset CONVEYTYPELIST[ICOID]=#LISTAPPEND(CONVEYTYPELIST[ICOID],vaCFCODE)#>
		<cfelse>
			<cfset StructInsert(CONVEYTYPELIST,ICOID,vaCFCODE)>
		</cfif>
	</cfif>
</cfoutput>

<!---
<cfset typeofclm=StructNew()>
<cfoutput query=q_trx>
	<cfset temp=StructNew()>
	<cfset StructInsert(temp,"desc",vaCFDESC)>
	<cfset StructInsert(temp,"clmtypemask",ICLMTYPEMASK)>
	<cfset StructInsert(typeofclm,vaCFCODE,temp)>
</cfoutput>
<cfset typeofclmlist=ValueList(q_trx.vaCFCODE)>
--->

<!--- structure
1. general list ..
request.ds.typeofclm[claimtype]
request.ds.typeofclm[claimtype].typeclm[999]='xxxxx'
request.ds.typeofclm[claimtype].list='1,2,3,4,5'

2. specific list for coid ...
request.ds.typeofclm[claimtype].coid[coid]
request.ds.typeofclm[claimtype].coid[coid].typeclm[]='xxxxx'
request.ds.typeofclm[claimtype].coid[coid].list='1,2,3,4,5'
--->

<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT iLID=ISNULL(iLID,0), icoid,vacfcode,vacfdesc,iclmtypemask,claimtype=rtrim(vaclmtype), vacfmapcode, valogicname, vacfmapcode3, vacfmapcode4 FROM (
/* PA / Medical */
select iLID=ISNULL(b.iLID,0), b.icoid,b.vacfcode,b.vacfdesc,a.iclmtypemask,a.vaclmtype, b.vacfmapcode, b.valogicname, b.vacfmapcode3, b.vacfmapcode4 from clmd0010 a
JOIN biz0025 b ON b.iclmtypemask&a.iclmtypemask=a.iclmtypemask and b.acftype='TYPECLM' and b.sistatus=0
UNION
/* travel */
select iLID=ISNULL(d.iLID,0), d.icoid,d.vacfcode,d.vacfdesc,c.iclmtypemask,c.vaclmtype, d.vacfmapcode, d.valogicname, d.vacfmapcode3, d.vacfmapcode4 from clmd0010 c
JOIN biz0025 d ON d.iclmtypemask&c.iclmtypemask=c.iclmtypemask and d.acftype='TYCLMTRV' and d.sistatus=0
UNION
/* Fire 39441*/
select iLID=ISNULL(FRb.iLID,0), FRb.icoid,FRb.vacfcode,FRb.vacfdesc,FRa.iclmtypemask,FRa.vaclmtype, FRb.vacfmapcode, FRb.valogicname, FRb.vacfmapcode3, FRb.vacfmapcode4 from clmd0010 FRa
JOIN biz0025 FRb ON FRb.iclmtypemask&FRa.iclmtypemask=FRa.iclmtypemask and FRb.acftype='TYPECLMFR' and FRb.sistatus=0
UNION
/* NM MSC Miscellaneous 39441*/
select iLID=ISNULL(MSCb.iLID,0), MSCb.icoid,MSCb.vacfcode,MSCb.vacfdesc,MSCa.iclmtypemask,MSCa.vaclmtype, MSCb.vacfmapcode, MSCb.valogicname, MSCb.vacfmapcode3, MSCb.vacfmapcode4 from clmd0010 MSCa
JOIN biz0025 MSCb ON MSCb.iclmtypemask&MSCa.iclmtypemask=MSCa.iclmtypemask and MSCb.acftype='TYPECLMMSC' and MSCb.sistatus=0
UNION
/* NM HS Healthcare  41639*/
select iLID=ISNULL(MSCb.iLID,0), MSCb.icoid,MSCb.vacfcode,MSCb.vacfdesc,MSCa.iclmtypemask,MSCa.vaclmtype, MSCb.vacfmapcode, MSCb.valogicname, MSCb.vacfmapcode3, MSCb.vacfmapcode4 from clmd0010 MSCa
JOIN biz0025 MSCb ON MSCb.iclmtypemask&MSCa.iclmtypemask=MSCa.iclmtypemask and MSCb.acftype='TYPECLMHS' and MSCb.sistatus=0
) z order by claimtype, icoid, vacfdesc
</cfquery>

<cfset typeofclm=StructNew()>
<cfoutput query="q_trx" group="claimtype">
	<cfset StructInsert(typeofclm,claimtype,StructNew())>
	<cfoutput group="icoid">
		<cfif q_trx.icoid IS 0><!--- general list --->
			<!--- 			<cfif NOT StructKeyExists(typeofclm[claimtype],"typeclm")> --->
				<cfset StructInsert(typeofclm[claimtype],"typeclm",StructNew())>
			<!--- 			</cfif> --->
			<cfset typeofclmlist="">
			<cfoutput>
				<!--- item is here ... --->
				<cfif NOT StructKeyExists(typeofclm[claimtype].typeclm,vacfcode)>
					<cfset StructInsert(typeofclm[claimtype].typeclm,vacfcode,StructNew())>
					<cfset StructInsert(typeofclm[claimtype].typeclm[vacfcode],"name","#vacfdesc#")>
					<cfset StructInsert(typeofclm[claimtype].typeclm[vacfcode],"lid","#iLID#")>
					<cfset StructInsert(typeofclm[claimtype].typeclm[vacfcode],"mapcode","#vacfmapcode#")>
					<cfset StructInsert(typeofclm[claimtype].typeclm[vacfcode],"mapcodeid","#vacfmapcode3#")> <!--- 37153 --->
					<cfset StructInsert(typeofclm[claimtype].typeclm[vacfcode],"mapcodeidbit","#vacfmapcode4#")> <!--- 37153 --->
					<cfset typeofclmlist=listappend(typeofclmlist,"#vacfcode#")>
				</cfif>
			</cfoutput>
			<cfset StructInsert(typeofclm[claimtype],"list","#typeofclmlist#")>
		<cfelse><!--- specific coid --->
			<cfif NOT StructKeyExists(typeofclm[claimtype],"coid")>
				<cfset StructInsert(typeofclm[claimtype],"coid",StructNew())>
			</cfif>
			<!--- as per coid ... --->
			<cfif NOT StructKeyExists(typeofclm[claimtype].coid,q_trx.icoid)>
				<cfset StructInsert(typeofclm[claimtype].coid,q_trx.icoid,StructNew())>
			</cfif>
			<!--- new struct for typeclm --->
			<cfset StructInsert(typeofclm[claimtype].coid[q_trx.icoid],"typeclm",StructNew())>
			<cfset typeofclmlist="">
			<cfoutput>
				<!--- item is here ... --->
				<cfif NOT StructKeyExists(typeofclm[claimtype].coid[q_trx.icoid].typeclm,vacfcode)>
					<!--- <cfset StructInsert(typeofclm[claimtype].coid[q_trx.icoid].typeclm,vacfcode,"#vacfdesc#")> --->
					<cfset StructInsert(typeofclm[claimtype].coid[q_trx.icoid].typeclm,vacfcode,StructNew())>
					<cfset StructInsert(typeofclm[claimtype].coid[q_trx.icoid].typeclm[vacfcode],"name","#vacfdesc#")>
					<cfset StructInsert(typeofclm[claimtype].coid[q_trx.icoid].typeclm[vacfcode],"lid","#iLID#")>
					<cfset StructInsert(typeofclm[claimtype].coid[q_trx.icoid].typeclm[vacfcode],"mapcode","#vacfmapcode#")>
					<cfset StructInsert(typeofclm[claimtype].coid[q_trx.icoid].typeclm[vacfcode],"logicname","#valogicname#")>
					<cfset StructInsert(typeofclm[claimtype].coid[q_trx.icoid].typeclm[vacfcode],"mapcodeid","#vacfmapcode3#")> <!--- 37153 --->
					<cfset StructInsert(typeofclm[claimtype].coid[q_trx.icoid].typeclm[vacfcode],"mapcodeidbit","#vacfmapcode4#")> <!--- 37153 --->
					<cfset typeofclmlist=listappend(typeofclmlist,"#vacfcode#")>
				</cfif>
			</cfoutput>
			<cfset StructInsert(typeofclm[claimtype].coid[q_trx.icoid],"list","#typeofclmlist#")>
		</cfif>
	</cfoutput>
</cfoutput>

<!--- new method of type of claim selection --->
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT iLID=ISNULL(iLID,0),icoid,vacfcode,vacfdesc,iclmtypemask, vacfmapcode
FROM BIZ0025 a with (nolock)
WHERE a.aCFTYPE='TYPECLM' and a.sistatus=0
ORDER BY a.icoid, a.aCFTYPE, a.vacfdesc, cast(a.vaCFCODE as integer)
</cfquery>
<cfset typeclmbycoid=StructNew()>
<cfoutput query="q_trx">
	<cfif NOT StructKeyExists(typeclmbycoid,q_trx.icoid)>
		<cfset StructInsert(typeclmbycoid,icoid,StructNew())>
		<cfset typeclmbycoid[icoid].typeclm=StructNew()>
		<cfset typeclmbycoid[icoid].list="">
	</cfif>
	<cfif NOT StructKeyExists(typeclmbycoid[icoid].typeclm,vacfcode)>
		<cfset StructInsert(typeclmbycoid[icoid].typeclm,vacfcode,StructNew())>
		<cfset typeclmbycoid[icoid].typeclm[vacfcode].name=#vacfdesc#>
		<cfset typeclmbycoid[icoid].typeclm[vacfcode].lid=#iLID#>
		<cfset typeclmbycoid[icoid].typeclm[vacfcode].mapcode=#vacfmapcode#>
		<cfset typeclmbycoid[icoid].typeclm[vacfcode].clmtypemask=#iclmtypemask#>
		<cfset typeclmbycoid[icoid].list=listappend(typeclmbycoid[icoid].list,vacfcode)>
	</cfif>
</cfoutput>

<!--- extension type from type of claim (sompo SG) --->
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.icoid, a.vaCFCODE,a.vaCFDESC,a.ICLMTYPEMASK,iLID=IsNull(a.iLID,0)
from BIZ0025 a WITH (NOLOCK) WHERE /*a.iCOID=0 AND*/ a.aCFTYPE='TYPECLMEXT' AND a.sistatus=0
ORDER BY a.icoid, a.vaCFCODE
</cfquery>

<cfset typeclmext=StructNew()>
<cfset typeclmextlist=StructNew()><!--- list of idx --->
<cfoutput query="q_trx">
	<cfif NOT StructKeyExists(typeclmext,vacfcode)>
		<cfset StructInsert(typeclmext,vacfcode,StructNew())>
		<cfset StructInsert(typeclmext[vacfcode],"name",vaCFDESC)>
		<cfset StructInsert(typeclmext[vacfcode],"clmtypemask",ICLMTYPEMASK)>
		<cfset StructInsert(typeclmext[vacfcode],"LID",iLID)>
	</cfif>
	<cfif NOT StructKeyExists(typeclmextlist,icoid)>
		<cfset StructInsert(typeclmextlist,icoid,"#vacfcode#")>
	<cfelse>
		<cfset temp=StructUpdate(typeclmextlist,icoid,listappend(typeclmextlist[icoid],vacfcode))>
	</cfif>
</cfoutput>

<!--- Start #32447 kofam --->
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.icoid,a.vaCFCODE,a.vaCFMAPCODE,a.vaCFDESC,a.ICLMTYPEMASK
from BIZ0025 a WITH (NOLOCK) WHERE /*a.iCOID=0 AND*/ a.aCFTYPE='WCRSNINCPOL' AND a.sistatus=0
ORDER BY a.icoid, CONVERT(INT,a.vaCFCODE), a.vaCFDESC
</cfquery>

<cfset wcrsnincpol=StructNew()>
<cfset wcrsnincpollist=StructNew()>

<cfloop query="q_trx">
	<cfif NOT StructKeyExists(wcrsnincpol,vacfcode)>
		<cfset StructInsert(wcrsnincpol,vacfcode,StructNew())>
		<cfset StructInsert(wcrsnincpol[vacfcode],"clmtypemask",ICLMTYPEMASK)>
		<cfset StructInsert(wcrsnincpol[vacfcode],"name",vaCFDESC)>
		<cfset StructInsert(wcrsnincpol[vacfcode],"value",vaCFMAPCODE)>
	</cfif>
	<cfif NOT StructKeyExists(wcrsnincpollist,icoid)>
		<cfset StructInsert(wcrsnincpollist,icoid,"#vaCFCODE#")>
	<cfelse>
		<cfset StructUpdate(wcrsnincpollist,icoid,listappend(wcrsnincpollist[icoid],vaCFCODE))>
	</cfif>
</cfloop>

<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.icoid,a.vaCFCODE,a.vaCFMAPCODE,a.vaCFDESC,a.ICLMTYPEMASK
from BIZ0025 a WITH (NOLOCK) WHERE /*a.iCOID=0 AND*/ a.aCFTYPE='WCINADMRSN' AND a.sistatus=0
ORDER BY a.icoid, CONVERT(INT,a.vaCFCODE), a.vaCFDESC
</cfquery>

<cfset wcinadmrsn=StructNew()>
<cfset wcinadmrsnlist=StructNew()>

<cfloop query="q_trx">
	<cfif NOT StructKeyExists(wcinadmrsn,vacfcode)>
		<cfset StructInsert(wcinadmrsn,vacfcode,StructNew())>
		<cfset StructInsert(wcinadmrsn[vacfcode],"clmtypemask",ICLMTYPEMASK)>
		<cfset StructInsert(wcinadmrsn[vacfcode],"name",vaCFDESC)>
		<cfset StructInsert(wcinadmrsn[vacfcode],"value",vaCFMAPCODE)>
	</cfif>
	<cfif NOT StructKeyExists(wcinadmrsnlist,icoid)>
		<cfset StructInsert(wcinadmrsnlist,icoid,"#vaCFCODE#")>
	<cfelse>
		<cfset StructUpdate(wcinadmrsnlist,icoid,listappend(wcinadmrsnlist[icoid],vaCFCODE))>
	</cfif>
</cfloop>

<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.icoid,a.vaCFCODE,a.vaCFMAPCODE,a.vaCFDESC,a.ICLMTYPEMASK
from BIZ0025 a WITH (NOLOCK) WHERE /*a.iCOID=0 AND*/ a.aCFTYPE='WCINJTYPE' AND a.sistatus=0
ORDER BY a.icoid, CONVERT(INT,a.vaCFCODE), a.vaCFDESC
</cfquery>

<cfset wcinjtype=StructNew()>
<cfset wcinjtypelist=StructNew()>

<cfloop query="q_trx">
	<cfif NOT StructKeyExists(wcinjtype,vacfcode)>
		<cfset StructInsert(wcinjtype,vacfcode,StructNew())>
		<cfset StructInsert(wcinjtype[vacfcode],"clmtypemask",ICLMTYPEMASK)>
		<cfset StructInsert(wcinjtype[vacfcode],"name",vaCFDESC)>
		<cfset StructInsert(wcinjtype[vacfcode],"value",vaCFMAPCODE)>
	</cfif>
	<cfif NOT StructKeyExists(wcinjtypelist,icoid)>
		<cfset StructInsert(wcinjtypelist,icoid,"#vaCFCODE#")>
	<cfelse>
		<cfset StructUpdate(wcinjtypelist,icoid,listappend(wcinjtypelist[icoid],vaCFCODE))>
	</cfif>
</cfloop>

<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.icoid,a.vaCFCODE,a.vaCFMAPCODE,a.vaCFDESC,a.ICLMTYPEMASK
from BIZ0025 a WITH (NOLOCK) WHERE /*a.iCOID=0 AND*/ a.aCFTYPE='WCBODYTYPE' AND a.sistatus=0
ORDER BY a.icoid, CONVERT(INT,a.vaCFCODE), a.vaCFDESC
</cfquery>

<cfset wcbodytype=StructNew()>
<cfset wcbodytypelist=StructNew()>

<cfloop query="q_trx">
	<cfif NOT StructKeyExists(wcbodytype,vacfcode)>
		<cfset StructInsert(wcbodytype,vacfcode,StructNew())>
		<cfset StructInsert(wcbodytype[vacfcode],"clmtypemask",ICLMTYPEMASK)>
		<cfset StructInsert(wcbodytype[vacfcode],"name",vaCFDESC)>
		<cfset StructInsert(wcbodytype[vacfcode],"value",vaCFMAPCODE)>
	</cfif>
	<cfif NOT StructKeyExists(wcbodytypelist,icoid)>
		<cfset StructInsert(wcbodytypelist,icoid,"#vaCFCODE#")>
	<cfelse>
		<cfset StructUpdate(wcbodytypelist,icoid,listappend(wcbodytypelist[icoid],vaCFCODE))>
	</cfif>
</cfloop>

<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.icoid,a.vaCFCODE,a.vaCFMAPCODE,a.vaCFDESC,a.ICLMTYPEMASK
from BIZ0025 a WITH (NOLOCK) WHERE /*a.iCOID=0 AND*/ a.aCFTYPE='WCACCTYPE1' AND a.sistatus=0
ORDER BY a.icoid, CONVERT(INT,a.vaCFCODE), a.vaCFDESC
</cfquery>

<cfset wcacctype=StructNew()>
<cfset wcacctypelist=StructNew()>

<cfloop query="q_trx">
	<cfif NOT StructKeyExists(wcacctype,vacfcode)>
		<cfset StructInsert(wcacctype,vacfcode,StructNew())>
		<cfset StructInsert(wcacctype[vacfcode],"clmtypemask",ICLMTYPEMASK)>
		<cfset StructInsert(wcacctype[vacfcode],"name",vaCFDESC)>
		<cfset StructInsert(wcacctype[vacfcode],"value",vaCFMAPCODE)>
	</cfif>
	<cfif NOT StructKeyExists(wcacctypelist,icoid)>
		<cfset StructInsert(wcacctypelist,icoid,"#vaCFCODE#")>
	<cfelse>
		<cfset StructUpdate(wcacctypelist,icoid,listappend(wcacctypelist[icoid],vaCFCODE))>
	</cfif>
</cfloop>

<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.icoid,a.vaCFCODE,a.vaCFMAPCODE,a.vaCFMAPCODE2,a.vaCFDESC,a.ICLMTYPEMASK
from BIZ0025 a WITH (NOLOCK) WHERE /*a.iCOID=0 AND*/ a.aCFTYPE='WCACCTYPE2' AND a.sistatus=0
ORDER BY a.icoid, CONVERT(INT,a.vaCFCODE), a.vaCFDESC
</cfquery>

<cfset wcacctype2=StructNew()>
<cfset wcacctype2list=StructNew()>
<cfloop query="q_trx">
	<cfif NOT StructKeyExists(wcacctype2,vacfcode)>
		<cfset StructInsert(wcacctype2,vacfcode,StructNew())>
		<cfset StructInsert(wcacctype2[vacfcode],"clmtypemask",ICLMTYPEMASK)>
		<cfset StructInsert(wcacctype2[vacfcode],"name",vaCFDESC)>
		<cfset StructInsert(wcacctype2[vacfcode],"group",vaCFMAPCODE)>
		<cfset StructInsert(wcacctype2[vacfcode],"value",vaCFMAPCODE2)>
	</cfif>
	<cfif NOT StructKeyExists(wcacctype2list,icoid)>
		<cfset StructInsert(wcacctype2list,icoid,"#vaCFCODE#")>
	<cfelse>
		<cfset StructUpdate(wcacctype2list,icoid,listappend(wcacctype2list[icoid],vacfcode))>
	</cfif>
</cfloop>

<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.icoid,a.vaCFCODE,a.vaCFMAPCODE,a.vaCFDESC,a.ICLMTYPEMASK
from BIZ0025 a WITH (NOLOCK) WHERE /*a.iCOID=0 AND*/ a.aCFTYPE='WCACCAGNT1' AND a.sistatus=0
ORDER BY a.icoid, CONVERT(INT,a.vaCFCODE), a.vaCFDESC
</cfquery>

<cfset wcaccagnt=StructNew()>
<cfset wcaccagntlist=StructNew()>
<cfloop query="q_trx">
	<cfif NOT StructKeyExists(wcaccagnt,vacfcode)>
		<cfset StructInsert(wcaccagnt,vacfcode,StructNew())>
		<cfset StructInsert(wcaccagnt[vacfcode],"clmtypemask",ICLMTYPEMASK)>
		<cfset StructInsert(wcaccagnt[vacfcode],"name",vaCFDESC)>
		<cfset StructInsert(wcaccagnt[vacfcode],"value",vaCFMAPCODE)>
	</cfif>
	<cfif NOT StructKeyExists(wcaccagntlist,icoid)>
		<cfset StructInsert(wcaccagntlist,icoid,"#vaCFCODE#")>
	<cfelse>
		<cfset StructUpdate(wcaccagntlist,icoid,listappend(wcaccagntlist[icoid],vacfcode))>
	</cfif>
</cfloop>

<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.icoid,a.vaCFCODE,a.vaCFMAPCODE,a.vaCFMAPCODE2,a.vaCFDESC,a.ICLMTYPEMASK
from BIZ0025 a WITH (NOLOCK) WHERE /*a.iCOID=0 AND*/ a.aCFTYPE='WCACCAGNT2' AND a.sistatus=0
ORDER BY a.icoid, CONVERT(INT,a.vaCFCODE), a.vaCFDESC
</cfquery>

<cfset wcaccagnt2=StructNew()>
<cfset wcaccagnt2list=StructNew()>
<cfloop query="q_trx">
	<cfif NOT StructKeyExists(wcaccagnt2,vacfcode)>
		<cfset StructInsert(wcaccagnt2,vacfcode,StructNew())>
		<cfset StructInsert(wcaccagnt2[vacfcode],"clmtypemask",ICLMTYPEMASK)>
		<cfset StructInsert(wcaccagnt2[vacfcode],"name",vaCFDESC)>
		<cfset StructInsert(wcaccagnt2[vacfcode],"group",vaCFMAPCODE)>
		<cfset StructInsert(wcaccagnt2[vacfcode],"value",vaCFMAPCODE2)>
	</cfif>
	<cfif NOT StructKeyExists(wcaccagnt2list,icoid)>
		<cfset StructInsert(wcaccagnt2list,icoid,"#vaCFCODE#")>
	<cfelse>
		<cfset StructUpdate(wcaccagnt2list,icoid,listappend(wcaccagnt2list[icoid],vacfcode))>
	</cfif>
</cfloop>

<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.icoid,a.vaCFCODE,a.vaCFMAPCODE,a.vaCFDESC,a.ICLMTYPEMASK
from BIZ0025 a WITH (NOLOCK) WHERE /*a.iCOID=0 AND*/ a.aCFTYPE='WCNTFOCCDSS' AND a.sistatus=0
ORDER BY a.icoid, CONVERT(INT,a.vaCFCODE), a.vaCFDESC
</cfquery>

<cfset wcntfdoccdss=StructNew()>
<cfset wcntfdoccdsslist=StructNew()>
<cfloop query="q_trx">
	<cfif NOT StructKeyExists(wcntfdoccdss,vacfcode)>
		<cfset StructInsert(wcntfdoccdss,vacfcode,StructNew())>
		<cfset StructInsert(wcntfdoccdss[vacfcode],"clmtypemask",ICLMTYPEMASK)>
		<cfset StructInsert(wcntfdoccdss[vacfcode],"name",vaCFDESC)>
		<cfset StructInsert(wcntfdoccdss[vacfcode],"value",vaCFMAPCODE)>
	</cfif>
	<cfif NOT StructKeyExists(wcntfdoccdsslist,icoid)>
		<cfset StructInsert(wcntfdoccdsslist,icoid,"#vaCFCODE#")>
	<cfelse>
		<cfset StructUpdate(wcntfdoccdsslist,icoid,listappend(wcntfdoccdsslist[icoid],vacfcode))>
	</cfif>
</cfloop>
<!--- End #32447 kofam --->

<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.icoid, a.vaCFCODE,a.vaCFDESC,a.ICLMTYPEMASK,iLID=IsNull(a.iLID,0)
from BIZ0025 a WITH (NOLOCK) WHERE /*a.iCOID=0 AND*/ a.aCFTYPE='LOCCLAIM' AND a.sistatus=0
ORDER BY a.icoid, a.vaCFDESC
</cfquery>

<!---

<cfoutput query=q_trx>
	<cfset temp=StructNew()>
	<cfset StructInsert(temp,"desc",vaCFDESC)>
	<cfset StructInsert(temp,"clmtypemask",ICLMTYPEMASK)>
	<cfset StructInsert(temp,"LID",iLID)>
	<cfset StructInsert(locclaim,vaCFCODE,temp)>
</cfoutput>
<cfset locclaimlist=ValueList(q_trx.vaCFCODE)>
 --->

<!---
locclaim[999].desc ...where 999 is the index of the locclaimid
			 .clmtypemask
			 .lid
locclaim.list[999] ... where 999 is the coid
--->
<cfset locclaim=StructNew()>
<cfset locclaimlist=StructNew()><!--- list of idx --->
<cfoutput query="q_trx">
	<cfif NOT StructKeyExists(locclaim,vacfcode)>
		<cfset StructInsert(locclaim,vacfcode,StructNew())>
		<cfset StructInsert(locclaim[vacfcode],"desc",vaCFDESC)>
		<cfset StructInsert(locclaim[vacfcode],"clmtypemask",ICLMTYPEMASK)>
		<cfset StructInsert(locclaim[vacfcode],"LID",iLID)>
	</cfif>
	<cfif NOT StructKeyExists(locclaimlist,icoid)>
		<cfset StructInsert(locclaimlist,icoid,"#vacfcode#")>
	<cfelse>
		<cfset temp=StructUpdate(locclaimlist,icoid,listappend(locclaimlist[icoid],vacfcode))>
	</cfif>
</cfoutput>

<CFQUERY NAME=q_clmtype DATASOURCE=#CURDSN#>
SELECT a.iCLMTYPEMASK,a.vaCLMTYPE,a.vaCLMTYPEDISP,a.vaCLMNAME,a.iSUBCLMTYPEMASK,a.vaSUPERCLS FROM CLMD0010 a WITH (NOLOCK) WHERE a.siSTATUS=0
ORDER BY a.vaSUPERCLS,a.vaCLMTYPEDISP
<!---ORDER BY a.iCLMTYPEMASK--->
</CFQUERY>
<CFQUERY NAME=q_clmtypeleft2 DATASOURCE=#CURDSN#>
SELECT iCLMTYPEMASK=SUM(a.iCLMTYPEMASK),vaCLMTYPE=LEFT(vaCLMTYPE,2) FROM CLMD0010 a WITH (NOLOCK) WHERE a.siSTATUS=0
GROUP BY LEFT(vaCLMTYPE,2)
</CFQUERY>
<cfset clmtype=StructNew()>
<cfset clmtypenames=StructNew()>
<cfset clmtypenameslookup=StructNew()>
<cfset clmtypelong=StructNew()>
<CFSET clmtypelist=ValueList(q_clmtype.iCLMTYPEMASK)>
<CFSET clmtypereverse=StructNew()>
<CFSET clmtypereverselefttwo=StructNew()>
<CFSET clmtypesubmask=StructNew()>
<CFSET clmtypecls=StructNew()>
<CFOUTPUT query=q_clmtype>
	<cfset StructInsert(clmtype,iCLMTYPEMASK,Trim(vaCLMTYPE))>
	<cfset StructInsert(clmtypereverse,Trim(vaCLMTYPE),iCLMTYPEMASK)>
	<cfset StructInsert(clmtypenames,iCLMTYPEMASK,Trim(vaCLMTYPEDISP))>
	<cfset StructInsert(clmtypenameslookup,Trim(vaCLMTYPE),Trim(vaCLMTYPEDISP))>
	<cfset StructInsert(clmtypelong,iCLMTYPEMASK,Trim(vaCLMNAME))>
	<cfset StructInsert(clmtypesubmask,iCLMTYPEMASK,iSUBCLMTYPEMASK)>
	<cfif NOT structKeyExists(clmtypecls,vaSUPERCLS)><cfset StructInsert(clmtypecls,vaSUPERCLS,0)></cfif>
	<cfset temp=StructUpdate(clmtypecls,vaSUPERCLS,val(clmtypecls[vaSUPERCLS]+iCLMTYPEMASK))>
</CFOUTPUT>
<CFOUTPUT query=q_clmtypeleft2>
	<cfset StructInsert(clmtypereverselefttwo,Trim(vaCLMTYPE),iCLMTYPEMASK)>
</CFOUTPUT>

<CFQUERY NAME=q_subclmtype DATASOURCE=#CURDSN#>
SELECT a.iSUBCLMTYPEMASK, a.vaSUBCLMNAME FROM CLMD0011 a WITH (NOLOCK) WHERE sistatus=0 ORDER BY iSUBCLMTYPEMASK
</CFQUERY>
<cfset subclmtypelist=ValueList(q_subclmtype.iSUBCLMTYPEMASK)>
<cfset subclmtype=StructNew()>
<CFOUTPUT query=q_subclmtype>
	<cfset StructInsert(subclmtype,iSUBCLMTYPEMASK,Trim(vaSUBCLMNAME))>
</CFOUTPUT>

<cfset repstage=StructNew()>
<!---cfstoredproc PROCEDURE="sspREPGetRepairStages" DATASOURCE=#CURDSN# RETURNCODE=YES>
<cfprocparam TYPE=IN NULL=YES DBVARNAME=@ai_langid VALUE=0 CFSQLTYPE=CF_SQL_INTEGER>
<cfprocresult NAME=qry_repairstages RESULTSET=1>
</cfstoredproc>
<cfset SPRESULT=CFSTOREDPROC.StatusCode>
<cfif SPRESULT LT 0>
	<cfthrow TYPE="EX_DBERROR" ErrorCode="RepMgmt/GetRepairStages(#SPRESULT#)">
</cfif--->
<CFQUERY NAME=qry_repairstages DATASOURCE=#CURDSN#>
SELECT a.iREPSTAGEID,a.vaREPSTAGEDESC,a.iREPSTAGESEQ,iLID=IsNull(a.iLID,0)
FROM REP0010 a WITH (NOLOCK) WHERE a.iGCOID=0 AND a.vaREPSTAGEDESC IS NOT NULL
ORDER BY CASE WHEN a.iREPSTAGESEQ IS NULL THEN 99999 ELSE a.iREPSTAGESEQ END,a.iREPSTAGEID
</CFQUERY>
<CFOUTPUT query=qry_repairstages>
	<CFSET StructInsert(repstage,iREPSTAGEID,StructNew())>
	<CFSET o=StructFind(repstage,iREPSTAGEID)>
	<CFSET StructInsert(o,"DSC",vaREPSTAGEDESC)>
	<CFSET StructInsert(o,"LID",iLID)>
	<CFSET StructInsert(o,"PC",iREPSTAGESEQ)>
</CFOUTPUT>
<CFSET repstagelist=ValueList(qry_repairstages.iREPSTAGEID)>
<!---cfset clmtype=StructNew()>
<cfset StructInsert(clmtype,1,"OD")>
<cfset StructInsert(clmtype,2,"TP")>
<cfset StructInsert(clmtype,4,"WS")>
<cfset StructInsert(clmtype,8,"OD KFK")>
<cfset StructInsert(clmtype,16,"TF")>
<cfset StructInsert(clmtype,32,"OD TFR")>
<cfset StructInsert(clmtype,64,"OD MNT")>
<cfset StructInsert(clmtype,128,"OD GRG")>
<cfset StructInsert(clmtype,256,"OD TAC")>
<cfset StructInsert(clmtype,512,"OD EXW")>
<!---
<CFSET StructInsert(clmtype,256,"TD")>
<CFSET StructInsert(clmtype,512,"TB")>
<CFSET StructInsert(clmtype,1024,"FR")>
<CFSET StructInsert(clmtype,2048,"FC")>
<CFSET StructInsert(clmtype,4096,"LB")>
<CFSET StructInsert(clmtype,8192,"MC")>
<CFSET StructInsert(clmtype,16384,"MD")>
<CFSET StructInsert(clmtype,32768,"NM")>
<CFSET StructInsert(clmtype,65536,"PA")>--->
<cfset clmtypenames=StructNew()>
<cfset StructInsert(clmtypenames,1,"OD")>
<cfset StructInsert(clmtypenames,2,"TP")>
<cfset StructInsert(clmtypenames,4,"WS")>
<cfset StructInsert(clmtypenames,8,"OD KFK")>
<cfset StructInsert(clmtypenames,16,"TF")>
<cfset StructInsert(clmtypenames,32,"OD TFR")>
<cfset StructInsert(clmtypenames,64,"MNT")>
<cfset StructInsert(clmtypenames,128,"GRG")>
<cfset StructInsert(clmtypenames,256,"OD TAC")>
<cfset StructInsert(clmtypenames,512,"EXW")>

<!---
<CFSET StructInsert(clmtypenames,256,"TD")>
<CFSET StructInsert(clmtypenames,512,"TB")>
<CFSET StructInsert(clmtypenames,1024,"FR")>
<CFSET StructInsert(clmtypenames,2048,"FC")>
<CFSET StructInsert(clmtypenames,4096,"LB")>
<CFSET StructInsert(clmtypenames,8192,"MC")>
<CFSET StructInsert(clmtypenames,16384,"MD")>
<CFSET StructInsert(clmtypenames,32768,"NM")>
<CFSET StructInsert(clmtypenames,65536,"PA")>--->
<cfset clmtypelong=StructNew()>
<cfset StructInsert(clmtypelong,1,"Own Damage")>
<cfset StructInsert(clmtypelong,2,"Third Party")>
<cfset StructInsert(clmtypelong,4,"Windscreen")>
<cfset StructInsert(clmtypelong,8,"Own Damage KFK")>
<cfset StructInsert(clmtypelong,16,"Theft")>
<cfset StructInsert(clmtypelong,32,"OD Theft Recovered")>
<cfset StructInsert(clmtypelong,64,"Marine Transit")>
<cfset StructInsert(clmtypelong,128,"Garage")>
<cfset StructInsert(clmtypelong,256,"OD Theft of Accessories")>
<cfset StructInsert(clmtypelong,512,"Extended Warranty")--->

<!---
<CFSET StructInsert(clmtypelong,256,"Third Party Property Damage")>
<CFSET StructInsert(clmtypelong,512,"Third Party Bodily Injury")>
<CFSET StructInsert(clmtypelong,1024,"Fire")>
<CFSET StructInsert(clmtypelong,2048,"FC")>
<CFSET StructInsert(clmtypelong,4096,"LB")>
<CFSET StructInsert(clmtypelong,8192,"MC")>
<CFSET StructInsert(clmtypelong,16384,"MD")>
<CFSET StructInsert(clmtypelong,32768,"Misc Non-Motor")>
<CFSET StructInsert(clmtypelong,65536,"Personal Accident")>--->

<cfset co=StructNew()>
<cfset DS.MTRFN.MTRcovar_DSUpdate(DS:#DS#,DSN:#CURDSN#)>
<!---cfset DS.MTRFN.MTRcovar_DSUpdate_Faster(DS:#DS#,DSN:#CURDSN#)--->

<cfset StructInsert(DS,"ESSTAT",esstat)>
<cfset StructInsert(DS,"ESSTAT_LID",esstat_LID)>
<cfset StructInsert(DS,"REPSTAGE",repstage)>
<cfset StructInsert(DS,"REPSTAGELIST",repstagelist)>
<cfset StructInsert(DS,"CLMTYPE",clmtype)>
<cfset StructInsert(DS,"CLMTYPEREVERSE",clmtypereverse)>
<cfset StructInsert(DS,"CLMTYPEREVERSELEFTTWO",clmtypereverselefttwo)>
<cfset StructInsert(DS,"CLMTYPELIST",clmtypelist)>
<cfset StructInsert(DS,"CLMTYPENAMES",clmtypenames)>
<cfset StructInsert(DS,"CLMTYPENAMESLOOKUP",clmtypenameslookup)>
<cfset StructInsert(DS,"CLMTYPELONG",clmtypelong)>
<cfset StructInsert(DS,"CLMTYPESUBMASK",clmtypesubmask)>
<cfset StructInsert(DS,"CLMTYPECLS",clmtypecls)>
<cfset StructInsert(DS,"SUBCLMTYPE",subclmtype)>
<cfset StructInsert(DS,"SUBCLMTYPELIST",subclmtypelist)>
<cfset StructInsert(DS,"CLMINTSTAT",clmintstat)>
<cfset StructInsert(DS,"CLMINTSTAT_LID",clmintstat_LID)>
<cfset StructInsert(DS,"CMTSTAT",cmtstat)>
<cfset StructInsert(DS,"CMTSTAT_LID",cmtstat_LID)>
<cfset StructInsert(DS,"ETSTAT",etstat)>
<cfset StructInsert(DS,"ETSTAT_LID",etstat_LID)>
<cfset StructInsert(DS,"ETTYPE",ettype)>
<cfset StructInsert(DS,"ETTYPELIST",ettypelist)>
<cfset StructInsert(DS,"ETTYPE_LID",ettype_LID)>
<cfset StructInsert(DS,"ETADJSTAT",etadjstat)>
<cfset StructInsert(DS,"ETADJSTAT_LID",etadjstat_LID)>
<cfset StructInsert(DS,"ETBIDSTAT",etbidstat)>
<cfset StructInsert(DS,"ETBIDSTAT_LID",etbidstat_LID)>
<cfset StructInsert(DS,"RSTAT",rstat)>
<cfset StructInsert(DS,"ISTAT",istat)>
<cfset StructInsert(DS,"ASTAT",astat)>
<cfset StructInsert(DS,"SSTAT",sstat)>
<cfset StructInsert(DS,"BSTAT",bstat)>
<cfset StructInsert(DS,"PAYGSTAT",PAYGSTAT)>
<cfset StructInsert(DS,"DMSSTAT",dmsstat)>
<cfset StructInsert(DS,"SASSTAT",sasstat)>
<cfset StructInsert(DS,"ARCAPPSTAT",arcappstat)>
<cfset StructInsert(DS,"PGRP",pgrp)>
<cfset StructInsert(DS,"PATYPE",patype)>
<cfset StructInsert(DS,"PATYPELIST",patypelist)>
<cfset StructInsert(DS,"VHTYPE",vhtype)>
<cfset StructInsert(DS,"VHTYPESHORT",vhtypeshort)>
<cfset StructInsert(DS,"TRANSTYPE",transtype)>
<cfset StructInsert(DS,"TRANSTYPESHORT",transtypeshort)>
<cfset StructInsert(DS,"FUELTYPE",fueltype)>
<cfset StructInsert(DS,"FUELTYPESHORT",fueltypeshort)>
<cfset StructInsert(DS,"ASPITYPE",aspitype)>
<cfset StructInsert(DS,"ENGCONFIG",engconfig)>
<cfset StructInsert(DS,"ENGCONFIGLIST",engconfiglist)>
<cfset StructInsert(DS,"VHTYPELIST",vhtypelist)>
<cfset StructInsert(DS,"FRSTAT",frstat)>
<cfset StructInsert(DS,"RECSTAT",recstat)>
<CFSET StructInsert(DS,"SEARCHTYPE",multisearchType)>

<!---custom company list to enforce SSL (No Cologicname for tokio) : MOVE TO COMPANY SETTINGS IN FUTURE--->
<!---CFIF (StructKeyExists(Application,"APPDEVMODE") and application.appdevmode EQ 1) or (StructKeyExists(Application,"DB_MODE") and StructKeyExists(Application,"DB_COUNTRY") and application.DB_MODE eq "UAT" and application.DB_COUNTRY eq "MY") or CGI.HTTP_HOST eq "192.168.1.231">
	<CFSET StructInsert(DS,"ENFORCESSL","")>
<CFELSE>
	<CFSET StructInsert(DS,"ENFORCESSL","64")>
</CFIF--->
<!--- Simplified the above condition and make it DEV friendly: SSL for MY PROD/TRAIN, exclude STAGE --->
<CFIF CURApplication.DB_COUNTRY IS "MY" AND (CURApplication.DB_MODE IS "PROD" OR CURApplication.DB_MODE IS "TRAIN") AND NOT(CGI.HTTP_HOST IS "192.168.1.48")>
	<CFSET StructInsert(DS,"ENFORCESSL","64")>
<CFELSE>
	<CFSET StructInsert(DS,"ENFORCESSL","")>
</CFIF>

<cfset DS.VHMAN=vhman>
<cfset DS.VHCOLOR=vhcolor>
<cfset DS.VHCOLORLIST=vhcolorlist>
<cfset DS.DRVLICLS=drvlicls>
<cfset DS.DRVLICLSLIST=drvliclslist>
<cfset DS.DAMCON=damcon>
<cfset DS.DAMCONLIST1LANG=damconlist1lang>
<cfset DS.DAMCONLIST2LANG=damconlist2lang>
<cfset DS.DAMCONLIST1=damconlist1>
<cfset DS.COLLTYPE=COLLTYPE>
<cfset DS.COLLTYPELIST=COLLTYPElist>
<cfset DS.OCCUPATION=occupation>
<cfset DS.OCCUPATIONLIST=occupationlist>
<cfset DS.ESPROGRAMS=pes>
<cfset DS.PSC=psc>
<cfset DS.CATYPE=catype>
<cfset DS.CATYPEMASK=catypemask>
<cfset DS.CATYPE_LID=catype_lid>
<cfset DS.CATYPELIST=catypelist>
<cfset DS.CATYPE2=catype2>
<cfset DS.CATYPE2LIST=catype2list>
<cfset DS.CATYPE_SAS=catype_SAS>
<cfset DS.CATYPE_SAS_LIST=catype_SAS_list>
<cfset DS.POLICEDIST=policedist>
<cfset DS.POLICEDISTLIST=policedistlist>
<cfset DS.PORTLOCLIST=portloclist>
<cfset DS.RISKTYPE=risktype>
<cfset DS.RISKTYPECOID=risktypecoid> <!--- 37153 --->
<cfset DS.RISKTYPELIST=risktypelist>
<cfset DS.RISKTYPECOIDLIST=risktypecoidlist> <!--- 37153 --->
<cfset DS.INWARDTYPE=inwardtype>
<cfset DS.INWARDTYPELIST=inwardtypelist>
<cfset DS.PROTECTEQUIP=protectequip>
<cfset DS.PROTECTEQUIPLIST=protectequiplist>
<cfset DS.impclmrsn=impclmrsn>
<cfset DS.impclmrsnlist=impclmrsnlist>
<cfset DS.DISTRIBCHANNEL=distribchannel>
<cfset DS.DISTRIBCHANNELLIST=distribchannellist>
<cfset DS.TENDERLOSSTYPE=tenderlosstype>
<cfset DS.TENDERLOSSTYPELIST=tenderlosstypelist>
<cfset DS.TENDERTYPECLM=tendertypeclm>
<cfset DS.TENDERTYPECLMLIST=tendertypeclmlist>
<cfset DS.tppditm=tppditm>
<cfset DS.tppditmlist=tppditmlist>
<cfset DS.INJDIAG=injdiag>
<cfset DS.INJDIAGLIST=injdiaglist>
<cfset DS.INJCPT=INJCPT>
<cfset DS.INJCPTLIST=INJCPTLIST>
<cfset DS.INJUREDCLASS=injuredclass>
<cfset DS.INJUREDCLASSLIST=injuredclasslist>
<cfset DS.CONVEYTYPE=CONVEYTYPE>
<cfset DS.CONVEYTYPELIST=CONVEYTYPELIST>
<cfset DS.TYPEOFCLM=typeofclm>
<cfset DS.TYPECLMBYCOID=typeclmbycoid>
<!--- <cfset DS.TYPEOFCLMLIST=typeofclmlist> --->
<cfset DS.typeclmext=typeclmext>
<cfset DS.typeclmextlist=typeclmextlist>
<cfset DS.locclaim=locclaim>
<cfset DS.locclaimlist=locclaimlist>
<cfset DS.PARTREMARKS=partremarks>
<cfset DS.PARTREMARKS_LID=partremarks_LID>
<cfset DS.RPTTYPE=rpttype>
<cfset DS.RPTTYPE_LID=rpttype_LID>
<cfset DS.RPTTYPESHORT=rpttypeshort>
<cfset DS.RPTTYPESHORT_LID=rpttypeshort_LID>
<cfset DS.LIMITCODELIST="CLM,RSV,PAY">
<!---cfset DS.CO=co--->
<CFSET DS.GLOBAL_GRPDOMLIST="31,201,203">
<!---CFSET DS.INSCOLIST=inscolist--->
<cfset DS.PATYPE=patype>
<cfset DS.PATYPELIST=patypelist>
<!---
<cfset DS.ESPTYPE=esptype>
<cfset DS.ESPTYPE_LID=esptype_lid>
 --->
<!--- Countries, States & Cities --->

<!--- Start #32447 kofam --->
<cfset DS.wcrsnincpol=wcrsnincpol>
<cfset DS.wcrsnincpollist=wcrsnincpollist>
<cfset DS.wcinadmrsn=wcinadmrsn>
<cfset DS.wcinadmrsnlist=wcinadmrsnlist>
<cfset DS.wcinjtype=wcinjtype>
<cfset DS.wcinjtypelist=wcinjtypelist>
<cfset DS.wcbodytype=wcbodytype>
<cfset DS.wcbodytypelist=wcbodytypelist>
<cfset DS.wcacctype=wcacctype>
<cfset DS.wcacctypelist=wcacctypelist>
<cfset DS.wcacctype2=wcacctype2>
<cfset DS.wcacctype2list=wcacctype2list>
<cfset DS.wcaccagnt=wcaccagnt>
<cfset DS.wcaccagntlist=wcaccagntlist>
<cfset DS.wcaccagnt2=wcaccagnt2>
<cfset DS.wcaccagnt2list=wcaccagnt2list>
<cfset DS.wcntfdoccdss=wcntfdoccdss>
<cfset DS.wcntfdoccdsslist=wcntfdoccdsslist>
<!--- End #32447 kofam --->

<cfquery NAME=q_countries DATASOURCE=#CURDSN#>
SELECT a.iCOUNTRYID,a.vaDESC,a.vaISOCODE3,a.sistatus FROM SYS0005 a WITH (NOLOCK) ORDER BY a.vaDESC
</cfquery>
<!--- cfset DS.COUNTRIES=ArrayNew(1) --->
<cfset DS.COUNTRIES=StructNew()>
<cfset COUNTRYLIST="">
<cfoutput query=q_countries>
	<!--- cfset DS.COUNTRIES[iCOUNTRYID]=StructNew()>
	<cfset DS.COUNTRIES[iCOUNTRYID].NAME=vaDESC>
	<cfset DS.COUNTRIES[iCOUNTRYID].CODE=vaISOCODE3>
	<cfset DS.COUNTRIES[iCOUNTRYID].AdjCoList=ValueList(q_ins.iCOID) --->

	<cfset temp=StructNew()>
	<cfset StructInsert(temp,"NAME",vaDESC)>
	<cfset StructInsert(temp,"CODE",vaISOCODE3)>
	<cfquery NAME=q_ins DATASOURCE=#CURDSN#>
	SELECT a.iCOID FROM SEC0005 a WITH (NOLOCK) WHERE a.iPROPCOID=a.iCOID AND a.siCOTYPEID=2 AND a.siSTATUS=0 AND a.siACCEPTCASE=1 AND a.iCOUNTRYID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iCOUNTRYID#">
	ORDER BY a.vaCONAME
	</cfquery>
	<cfset StructInsert(temp,"InsCoList",#ValueList(q_ins.iCOID)#)>
	<cfquery NAME=q_ins DATASOURCE=#CURDSN#>
	SELECT a.iCOID FROM SEC0005 a WITH (NOLOCK) WHERE a.iPROPCOID=a.iCOID AND a.siCOTYPEID=3 AND a.siSTATUS=0 AND a.siACCEPTCASE=1 AND a.iCOUNTRYID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iCOUNTRYID#">
	ORDER BY a.vaCONAME
	</cfquery>
	<cfset StructInsert(temp,"AdjCoList",#ValueList(q_ins.iCOID)#)>
	<cfset StructInsert(DS.COUNTRIES,iCOUNTRYID,temp)>

	<cfif sistatus IS 0><cfset COUNTRYLIST=listappend(COUNTRYLIST,#iCOUNTRYID#)></cfif>
</cfoutput>
<cfset StructInsert(DS,"COUNTRYLIST",COUNTRYLIST)>

<cfquery NAME=q_states DATASOURCE=#CURDSN#>
SELECT a.iSTATEID,a.vaDESC,a.vaDESCLOCAL,a.iCOUNTRYID FROM SYS0002 a WITH (NOLOCK)
</cfquery>
<cfset DS.STATES=ArrayNew(1)>
<cfset DS.STATECOUNTRY=ArrayNew(1)>
<cfset DS.STATELOCAL=ArrayNew(1)>
<cfoutput query=q_states>
	<cfset DS.STATES[iSTATEID]=vaDESC>
	<cfset DS.STATECOUNTRY[iSTATEID]=iCOUNTRYID>
	<cfset DS.STATELOCAL[iSTATEID]=vaDESCLOCAL>
</cfoutput>
<cfquery NAME=q_cities DATASOURCE=#CURDSN#>
SELECT a.iCITYID,a.iSTATEID,a.vaDESC FROM SYS0003 a WITH (NOLOCK)
</cfquery>
<cfset DS.CITIES=ArrayNew(1)>
<cfset DS.CITYSTATE=ArrayNew(1)>
<cfoutput query=q_cities>
	<cfset DS.CITIES[iCITYID]=vaDESC>
	<cfset DS.CITYSTATE[iCITYID]=iSTATEID>
</cfoutput>

<cfquery NAME=q_backend DATASOURCE=#CURDSN#>
SELECT a.iGCOID,a.iBACKEND,a.vaBACKENDNAME FROM FOBJB3014 a WITH (NOLOCK)
ORDER BY a.iGCOID
</cfquery>
<cfloop query=q_backend>
	<cfif StructKeyExists(DS.CO,iGCOID)>
		<cfif NOT StructKeyExists(DS.CO[iGCOID],"BACKEND")>
			<cfset StructInsert(DS.CO[iGCOID],"BACKEND",StructNew())>
		</cfif>
		<cfset StructInsert(DS.CO[iGCOID].BACKEND,iBACKEND,Trim(vaBACKENDNAME))>
	</cfif>
</cfloop>


<cfquery NAME=q_lcls DATASOURCE=#CATDSN#>
SELECT a.iLCLSID,a.vaDESC FROM PDL0008 a WITH (NOLOCK)
WHERE a.siSTATUS=0
ORDER BY a.iLCLSID DESC
</cfquery>
<cfset DS.LCLSNAME=StructNew()>
<CFLOOP query=q_lcls><CFSET StructInsert(DS.LCLSNAME,iLCLSID,Trim(vaDESC))></CFLOOP>

<!--- Repairers with Profile, icoid only --->
<!---
<CFSET ProfileCOArr=ArrayNew(1)>
<cfoutput query=q_profile>
	<cfset ProfileCOArr[currentrow]=icoid>
</cfoutput>
<CFSET DS.ProfileCOArr=ProfileCOArr--->
<!--- Set Locales --->

<!--- for now only SG uses this --->
<!--- augmented company: insurer type ONLY --->
<cfquery name="qry_augco" datasource="#CURDSN#">
    select iCOID
        , iCITYID  , iSTATEID   , iCOUNTRYID , siCOTYPEID
        , vaCONAME , vaCOBRNAME , vaCOREGNO  , vaADD1     , vaADD2
        , aTELNO   , aFAXNO     , vaPOSTCODE , vaEMAIL    , iCOFLAG
        , iLOCID   , vaADD3
    from sec0025
    where
        (sicotypeid = 18 and icoid in (405001,405002,405000) )
    union
    select iCOID
        , iCITYID  , iSTATEID   , iCOUNTRYID , siCOTYPEID
        , vaCONAME , vaCOBRNAME , vaCOREGNO  , vaADD1     , vaADD2
        , aTELNO   , aFAXNO     , vaPOSTCODE , vaEMAIL    , iCOFLAG
        , iLOCID   , vaADD3
    from sec0005
    where
    icoid in (
         27
        ,29
        ,32
        ,34
        ,35
        ,37
        ,38
        ,40
        ,41
        ,44
        ,46
        ,49
        ,50
        ,57
        ,64
        ,67
        ,69
        ,70
        ,72
        ,7651
        ,378
        ,1672
        ,1673
        ,1674
        ,1675
        ,1676
        ,1677
        ,1678
        ,1679
        ,1680
        ,1713
        ,2622
        ,3060
        ,7412
        ,18206
    )
</cfquery>

<cfset DS.AUGCO=StructNew()>
<cfloop query="qry_augco">
    <cfif NOT structKeyExists(DS.AUGCO,iCOID)>
        <cfset DS.AUGCO[iCOID] = StructNew()>
    </cfif>
    <cfset DS.AUGCO[iCOID].CITYID    = qry_augco.iCITYID   >
    <cfset DS.AUGCO[iCOID].STATEID   = qry_augco.iSTATEID  >
    <cfset DS.AUGCO[iCOID].COUNTRYID = qry_augco.iCOUNTRYID>
    <cfset DS.AUGCO[iCOID].COTYPEID  = qry_augco.siCOTYPEID >
    <cfset DS.AUGCO[iCOID].CONAME    = qry_augco.vaCONAME   >
    <cfset DS.AUGCO[iCOID].COBRNAME  = qry_augco.vaCOBRNAME >
    <cfset DS.AUGCO[iCOID].ADD1      = qry_augco.vaADD1     >
    <cfset DS.AUGCO[iCOID].ADD2      = qry_augco.vaADD2     >
    <cfset DS.AUGCO[iCOID].TELNO     = qry_augco.aTELNO    >
    <cfset DS.AUGCO[iCOID].FAXNO     = qry_augco.aFAXNO    >
    <cfset DS.AUGCO[iCOID].POSTCODE  = qry_augco.vaPOSTCODE >
    <cfset DS.AUGCO[iCOID].EMAIL     = qry_augco.vaEMAIL    >
    <cfset DS.AUGCO[iCOID].LOCID     = qry_augco.iLOCID    >
    <cfset DS.AUGCO[iCOID].ADD3      = qry_augco.vaADD3     >
</cfloop>

<cfset DS.LOCALES=StructNew()>
<cfquery NAME=q_countries DATASOURCE=#CURDSN#>
SELECT a.ILOCID,a.VALOCNAME,a.VACURRENCY,a.VACURRENCYINTL,a.VACURRENCYFORMAT,a.VACURRENCYNAME,a.VAROADAUTH,
	a.NTIMEZONE,a.VADTFORMAT,a.VADTFORMATLONG,a.VADTFORMATSHORT,a.VATMFORMAT, a.vaPOLICERPTNAME, a.vaLOSSTYPENAME,
	a.iPDBLOCID,a.iPDBPSCID,a.IPDBESTFLAG, a.vaDRIVERNAME,a.mnKFKMANDATE,a.iKFKREPLYDAYS,a.vaEXCESSNAME,
	a.vaVATTAXNAME,a.iVATTAXFLAG,a.vaSVCTAXNAME,a.nSVCTAXPC,a.nVATTAXPC,a.vaHPHONEPREFIXLIST,a.vaHPHONEPATTERN,a.iDEFCOUNTRYID,a.mnDEFTOWING,a.vaBTTRRATE,a.vaIDDEF,a.vaPIAMNAME,a.vaREPCARDSTAGESLIST,a.vaLOCSHORTCODE,a.siVCTREADUNIT,
	a.vaSTAMPDUTYNAME,a.nSTAMPDUTYPC,a.iCurrencyID,a.vaSVCTAXPCLIST,a.vaVATTAXPCLIST
	,iLID_VACURRENCY=isNULL(b.iLID_VACURRENCY,0),iLID_VACURRENCYNAME=isNULL(b.iLID_VACURRENCYNAME,0),iLID_VAROADAUTH=isNULL(b.iLID_VAROADAUTH,0),iLID_vaPOLICERPTNAME=isNULL(b.iLID_vaPOLICERPTNAME,0),iLID_vaLOSSTYPENAME=isNULL(b.iLID_vaLOSSTYPENAME,0),iLID_vaDRIVERNAME=isNULL(b.iLID_vaDRIVERNAME,0),iLID_vaEXCESSNAME=isNULL(b.iLID_vaEXCESSNAME,0),iLID_vaVATTAXNAME=isNULL(b.iLID_vaVATTAXNAME,0),iLID_vaSVCTAXNAME=isNULL(b.iLID_vaSVCTAXNAME,0),iLID_vaPIAMNAME=isNULL(b.iLID_vaPIAMNAME,0),iLID_vaSTAMPDUTYNAME=isNULL(b.iLID_vaSTAMPDUTYNAME,0)
	,a.siUNICODE
FROM SYS0009 a WITH (NOLOCK) LEFT JOIN SYS0009_LID b WITH (NOLOCK) on a.iLOCID=b.iLOCID
</cfquery>
<cfoutput query=q_countries>
	<cfset DS.LOCALES[ILOCID]=StructNew()>
	<cfset DS.LOCALES[ILOCID].NAME=vaLOCNAME>
	<cfset DS.LOCALES[ILOCID].LOCSHORTCODE=vaLOCSHORTCODE>
	<cfset DS.LOCALES[ILOCID].Currency=vaCURRENCY>
	<cfset DS.LOCALES[ILOCID].CurrencyIntl=vaCURRENCYINTL>
	<cfset DS.LOCALES[ILOCID].CurrencyFormat=vaCURRENCYFORMAT>
	<cfset DS.LOCALES[ILOCID].CurrencyFull=vaCURRENCYNAME>
	<cfset DS.LOCALES[ILOCID].RoadAuth=vaROADAUTH>
	<cfset DS.LOCALES[ILOCID].TIMEZONE=nTIMEZONE>
	<cfset DS.LOCALES[ILOCID].DTFORMAT=vaDTFORMAT>
	<cfset DS.LOCALES[ILOCID].DTFORMATLONG=vaDTFORMATLONG>
	<cfset DS.LOCALES[ILOCID].DTFORMATSHORT=vaDTFORMATSHORT>
	<cfset DS.LOCALES[ILOCID].TMFORMAT=vaTMFORMAT>
	<cfset DS.LOCALES[ILOCID].PoliceRptName=vaPOLICERPTNAME>
	<cfset DS.LOCALES[ILOCID].LossTypeName=vaLOSSTYPENAME>
	<cfset DS.LOCALES[ILOCID].PDBLOCID=iPDBLOCID>
	<cfset DS.LOCALES[ILOCID].PDBPSCID=iPDBPSCID>
	<cfset DS.LOCALES[ILOCID].PDBESTFLAG=iPDBESTFLAG>
	<cfset DS.LOCALES[ILOCID].DriverName=vaDRIVERNAME>
	<cfset DS.LOCALES[ILOCID].KFKREPLYDAYS=iKFKREPLYDAYS>
	<cfset DS.LOCALES[ILOCID].KFKMANDATE=mnKFKMANDATE>
	<cfset DS.LOCALES[ILOCID].EXCESSNAME=vaEXCESSNAME>
	<cfset DS.LOCALES[ILOCID].VATTAXNAME=Trim(vaVATTAXNAME)>
	<cfset DS.LOCALES[ILOCID].SVCTAXNAME=Trim(vaSVCTAXNAME)>
	<cfset DS.LOCALES[ILOCID].STAMPDUTYNAME=Trim(vaSTAMPDUTYNAME)>
	<cfset DS.LOCALES[ILOCID].SVCTAXPC=nSVCTAXPC>
	<cfset DS.LOCALES[ILOCID].VATTAXPC=nVATTAXPC>
	<cfset DS.LOCALES[ILOCID].SVCTAXPCLIST=vaSVCTAXPCLIST>
	<cfset DS.LOCALES[ILOCID].VATTAXPCLIST=vaVATTAXPCLIST>
	<cfset DS.LOCALES[ILOCID].STAMPDUTYPC=nSTAMPDUTYPC>
	<cfset DS.LOCALES[ILOCID].VATTAXFLAG=iVATTAXFLAG>
	<cfset DS.LOCALES[ILOCID].VCTREADUNIT=siVCTREADUNIT>
	<cfset DS.LOCALES[ILOCID].HPHONEPREFIXLIST=ListSort(Trim(vaHPHONEPREFIXLIST),"numeric")>
	<cfset DS.LOCALES[ILOCID].HPHONEPATTERN=Trim(vaHPHONEPATTERN)>
	<cfset DS.LOCALES[ILOCID].DEFCOUNTRYID=iDEFCOUNTRYID>
	<cfset DS.LOCALES[ILOCID].DEFTOWING=mnDEFTOWING>
	<cfset DS.LOCALES[ILOCID].BTTRRATE=vaBTTRRATE>
	<cfset DS.LOCALES[ILOCID].IDDEF=vaIDDEF>
	<cfset DS.LOCALES[ILOCID].PIAMNAME=vaPIAMNAME>
	<cfset DS.LOCALES[ILOCID].CURRENCYID=iCurrencyID>
	<cfset DS.LOCALES[ILOCID].UNICODE=siUNICODE>

	<!--- Language LIDs --->
	<cfset DS.LOCALES[ILOCID].SVCTAXNAME_LID=iLID_vaSVCTAXNAME>
	<cfset DS.LOCALES[ILOCID].VATTAXNAME_LID=iLID_vaVATTAXNAME>
	<cfset DS.LOCALES[ILOCID].EXCESSNAME_LID=iLID_vaEXCESSNAME>
	<cfset DS.LOCALES[ILOCID].DRIVERNAME_LID=iLID_vaDRIVERNAME>
	<cfset DS.LOCALES[ILOCID].LOSSTYPENAME_LID=iLID_vaLOSSTYPENAME>
	<cfset DS.LOCALES[ILOCID].CURRENCY_LID=iLID_VACURRENCY>
	<cfset DS.LOCALES[ILOCID].CURRENCYFULL_LID=iLID_VACURRENCYNAME>
	<cfset DS.LOCALES[ILOCID].ROADAUTH_LID=iLID_VAROADAUTH>
	<cfset DS.LOCALES[ILOCID].POLICERPTNAME_LID=iLID_vaPOLICERPTNAME>
	<cfset DS.LOCALES[ILOCID].PIAMNAME_LID=iLID_vaPIAMNAME>
	<cfset DS.LOCALES[ILOCID].STAMPDUTYNAME_LID=iLID_vaSTAMPDUTYNAME>

	<!---CFIF CURAPPLICATION.APPINSTANCE_SHORTNAME IS "ANDREW-CLM">
		<!--- Temporary for development --->
		<!--- KFKMODE no longer used. Now mark every case --->
		<CFIF ILOCID IS 1>
			<CFSET DS.LOCALES[ILOCID].KFKMODE=2>
		<CFELSEIF ILOCID IS 5>
			<CFSET DS.LOCALES[ILOCID].KFKMODE=1>
		<CFELSE>
			<CFSET DS.LOCALES[ILOCID].KFKMODE=0>
		</CFIF>
	<CFELSE>
		<CFIF ILOCID IS 1 OR ILOCID IS 5>
			<CFSET DS.LOCALES[ILOCID].KFKMODE=1>
		<CFELSE>
			<CFSET DS.LOCALES[ILOCID].KFKMODE=0>
		</CFIF>
	</CFIF---->
	<cfquery NAME=q_ins DATASOURCE=#CURDSN#>
	SELECT a.iCOID FROM SEC0005 a WITH (NOLOCK) WHERE a.iPROPCOID=a.iCOID AND a.siCOTYPEID=2 AND a.siSTATUS=0 AND a.siACCEPTCASE=1 AND a.iLOCID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iLOCID#">
	ORDER BY a.vaCONAME
	</cfquery>
	<cfset DS.LOCALES[ILOCID].InsCoList=ValueList(q_ins.iCOID)>

	<cfif ILOCID IS 2>
        <cfset DS.LOCALES[ILOCID].AugInsCoList=ValueList(qry_augco.iCOID)>
    </cfif>

	<cfif ILOCID IS 10>
		<cfset DS.LOCALES[ILOCID].SYMBOLS={REGNO="Plate No.",INADJNAME="In-house Surveyor",MGRNAME="Claim Approver",LICENSECLS="Restriction Code",CLICENSECLS="Professional Restriction Code",CLICENSECLSNO="Professional License No",CLICENSECLSCOVER="Professional License Period Cover",ASSNAME="Claim Processor"}>
		<!--- Circumstances of Accident/Loss for PH --->
		<cfset DS.LOCALES[ILOCID].CATYPE=StructNew()>
		<cfset DS.LOCALES[ILOCID].CATYPEMASK=StructNew()>
		<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
		SELECT a.vaCFCODE,a.vaCFDESC,a.iCLMTYPEMASK
		FROM BIZ0025 a WITH (NOLOCK) WHERE a.iCOID=0 AND a.aCFTYPE='CIRACT' AND a.siSTATUS=0
		AND (CONVERT(int,vaCFCODE) BETWEEN 10000 AND 10999)
		ORDER BY a.vaCFDESC
		</cfquery>
		<cfset LOCID=ILOCID>
		<cfloop query=q_trx>
			<cfset StructInsert(DS.LOCALES[LOCID].CATYPE,vaCFCODE,vaCFDESC)>
			<cfset StructInsert(DS.LOCALES[LOCID].CATYPEMASK,vaCFCODE,iCLMTYPEMASK)>
		</cfloop>
		<cfset DS.LOCALES[ILOCID].CATYPELIST=ValueList(q_trx.vaCFCODE)>
	<cfelseif ILOCID IS 11>
		<cfset DS.LOCALES[ILOCID].SYMBOLS={EXTADJ="Server.SVClang('Surveyor',17118)"}>
	<cfelseif ILOCID IS 15>
		<cfset DS.LOCALES[ILOCID].SYMBOLS={REGNO="Server.SVClang('Plate No.',18196)"}>
	<cfelse>
		<cfset DS.LOCALES[ILOCID].SYMBOLS={}>
	</cfif>

	<!---added for label framework module--->
	<cfquery name=q_loclabel datasource=#CURDSN#>
		select ilbldefid from fobjb3020 WITH (NOLOCK) where ilocid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iLOCID#"> and siPrivate = 0 and sistatus = 0
	</cfquery>
	<cfset DS.LOCALES[ILOCID].LABELLIST=ValueList(q_loclabel.iLBLDEFID)>
	<CFIF ILOCID IS 7>
		<cfset DS.LOCALES[ILOCID].CURRROUNDDP=0>
		<CFQUERY NAME=q_cosafelist datasource=#CURDSN#>
		SELECT a.iPNLCOID
		FROM TRX0030 a,SEC0005 b
		WHERE a.iCOID=700175 AND a.iPNLCOID=b.iCOID AND b.siCOTYPEID=1 AND a.siPNLTYPE=1 AND a.siPNLSTAT=1 AND a.siSTATUS=0 AND b.siSTATUS=0 AND (b.siSUBSCRIBE&1)=1
		</CFQUERY>
		<CFSET DS.LOCALES[ILOCID].COSAFELIST=ValueList(q_cosafelist.iPNLCOID)>
		<CFQUERY NAME=q_cosafelist datasource=#CURDSN#>
		SELECT a.iPNLCOID
		FROM TRX0030 a,SEC0005 b
		WHERE a.iCOID=700175 AND a.iPNLCOID=b.iCOID AND b.siCOTYPEID=2 AND a.siPNLTYPE=2 AND b.iGCOID=b.iCOID AND a.siPNLSTAT=1 AND a.siSTATUS=0 AND b.siSTATUS=0 AND (b.siSUBSCRIBE&1)=1
		</CFQUERY>
		<CFSET DS.LOCALES[ILOCID].COSAFEINSLIST=ValueList(q_cosafelist.iPNLCOID)>
	<CFELSE>
		<cfset DS.LOCALES[ILOCID].CURRROUNDDP=2>
	</CFIF>
	<cfset DS.LOCALES[ILOCID].REPSTAGELIST=vaREPCARDSTAGESLIST>
	<CFIF ILOCID IS 2 OR ILOCID IS 9>
		<CFSET DS.LOCALES[ILOCID].PARTSYMBOL=ListToArray("S,L,N")>
		<CFSET DS.LOCALES[ILOCID].PARTSHORT=ListToArray("SpcNett,ListItemDisc,NettItemDisc")>
		<CFSET DS.LOCALES[ILOCID].PARTSHORT_LID=ListToArray("28715,28716,28717")>
		<CFSET DS.LOCALES[ILOCID].PARTNAME=ListToArray("Special Nett,List Item Discount,Nett Item Discount")>
		<CFSET DS.LOCALES[ILOCID].PARTLONG=ListToArray("Special Nett,List Item Discount on L Items,Nett Item Discount on N Items")>
	<CFELSEIF BitAnd(iPDBESTFLAG,1) IS 1>
		<CFSET DS.LOCALES[ILOCID].PARTSYMBOL=ListToArray("N,P,S")>
		<CFSET DS.LOCALES[ILOCID].PARTSHORT=ListToArray("Nett,PartTax,SalesTax")>
		<CFSET DS.LOCALES[ILOCID].PARTSHORT_LID=ListToArray("6190,28713,28714")>
		<CFSET DS.LOCALES[ILOCID].PARTNAME=ListToArray("Nett,Part Tax,Sales/Turnover Tax")>
		<CFSET DS.LOCALES[ILOCID].PARTLONG=ListToArray("Nett,Part Tax on P Items,Sales/Turnover Tax on S Items")>
	<!---CFELSE>
		<CFSET DS.LOCALES[ILOCID].PARTSYMBOL=ListToArray("N,P,S")>
		<CFSET DS.LOCALES[ILOCID].PARTSHORT=ListToArray("Nett,PartDisc,SpcDisc")>
		<CFSET DS.LOCALES[ILOCID].PARTNAME=ListToArray("#Server.SVClang("Nett",6190)#,#Server.SVClang("Part Discount",6978)#,#Server.SVClang("Special Discount",6979)#")>
		<CFSET DS.LOCALES[ILOCID].PARTLONG=ListToArray("#Server.SVClang("Nett",6190)#,#Server.SVClang("Part Discount on P Items",6980)#,#Server.SVClang("Special Discount on S Items",6981)#")--->
	<CFELSE>
		<CFSET DS.LOCALES[ILOCID].PARTSYMBOL=ListToArray("N,P,S")>
		<CFSET DS.LOCALES[ILOCID].PARTSHORT=ListToArray("Nett,PartDisc,SpcDisc")>
		<CFSET DS.LOCALES[ILOCID].PARTSHORT_LID=ListToArray("6190,28711,28712")>
		<CFSET DS.LOCALES[ILOCID].PARTNAME=ListToArray("Server.SVClang('Nett',6190)|Server.SVClang('Part Discount',5042)|Server.SVClang('Special Discount',18252)","|")>
		<cfif ILOCID IS 8>
			<CFSET DS.LOCALES[ILOCID].PARTLONG=ListToArray("Nett,Remise sur Pièce en (P),Remise spéciale sur pièce en (S)")>
		<cfelse>
			<CFSET DS.LOCALES[ILOCID].PARTLONG=ListToArray("Server.SVClang('Nett',6190)|Server.SVClang('Part Discount on P Items',18197)|Server.SVClang('Special Discount on S Items',18198)","|")>
		</cfif>
	</CFIF>

	<!--- Esource Part availability --->
	<CFSET DS.LOCALES[ILOCID].ESPTYPE=StructNew()>
	<CFSET DS.LOCALES[ILOCID].ESPTYPE_LID=StructNew()>
	<CFIF ILOCID EQ 1>
		<CFSET StructInsert(DS.LOCALES[ILOCID].ESPTYPE,0,"Ready Stock")>
		<CFSET StructInsert(DS.LOCALES[ILOCID].ESPTYPE,2,"Order Local")>
		<CFSET StructInsert(DS.LOCALES[ILOCID].ESPTYPE,3,"Order Overseas")>
		<CFSET StructInsert(DS.LOCALES[ILOCID].ESPTYPE_LID,0,"9836")>
		<CFSET StructInsert(DS.LOCALES[ILOCID].ESPTYPE_LID,2,"40060")>
		<CFSET StructInsert(DS.LOCALES[ILOCID].ESPTYPE_LID,3,"40061")>
	<CFELSEIF ILOCID EQ 11>
		<CFSET StructInsert(DS.LOCALES[ILOCID].ESPTYPE,0,"Ready Stock")>
		<CFSET StructInsert(DS.LOCALES[ILOCID].ESPTYPE,1,"Empty")>
		<CFSET StructInsert(DS.LOCALES[ILOCID].ESPTYPE,2,"Order Local")>
		<CFSET StructInsert(DS.LOCALES[ILOCID].ESPTYPE,3,"Order Overseas")>
		<CFSET StructInsert(DS.LOCALES[ILOCID].ESPTYPE_LID,0,"9836")>
		<CFSET StructInsert(DS.LOCALES[ILOCID].ESPTYPE_LID,1,"9837")>
		<CFSET StructInsert(DS.LOCALES[ILOCID].ESPTYPE_LID,2,"40060")>
		<CFSET StructInsert(DS.LOCALES[ILOCID].ESPTYPE_LID,3,"40061")>
	<CFELSE>
		<CFSET StructInsert(DS.LOCALES[ILOCID].ESPTYPE,0,"Ready Stock")>
		<CFSET StructInsert(DS.LOCALES[ILOCID].ESPTYPE,1,"Empty")>
		<CFSET StructInsert(DS.LOCALES[ILOCID].ESPTYPE,2,"Indent")>
		<CFSET StructInsert(DS.LOCALES[ILOCID].ESPTYPE_LID,0,"9836")>
		<CFSET StructInsert(DS.LOCALES[ILOCID].ESPTYPE_LID,1,"9837")>
		<CFSET StructInsert(DS.LOCALES[ILOCID].ESPTYPE_LID,2,"9838")>

		<!--- 42851 --->
		<!--- Enable to ID for this cfm, will be filter by iCOID at other cfm --->
		<CFIF ILOCID EQ 7>
			<CFSET StructInsert(DS.LOCALES[ILOCID].ESPTYPE,4,"Order")>
			<CFSET StructInsert(DS.LOCALES[ILOCID].ESPTYPE_LID,4,"9839")>
		</CFIF>
		<!--- 42851 --->
	</CFIF>
</cfoutput>

<!--- Set HEADER AND FOOTER override to MOTOR style --->
<CFSET StructInsert(DS,"SVC_SETTINGS",StructNew())>
<CFSET StructInsert(DS.SVC_SETTINGS,"HEADER","##Request.Logpath##CustomTags/MTRheader.cfm")>
<CFSET StructInsert(DS.SVC_SETTINGS,"FOOTER","##Request.Logpath##CustomTags/MTRfooter.cfm")>
<CFSET StructInsert(DS.SVC_SETTINGS,"MAIL_CUSTOM","MTRmail")>
<CFSET StructInsert(DS.SVC_SETTINGS,"COHEADER","##Request.Logpath##CustomTags/coheader.cfm")>
<CFSET StructInsert(DS.SVC_SETTINGS,"COFOOTER","##Request.Logpath##CustomTags/cofooter.cfm")>
<CFSET StructInsert(DS.SVC_SETTINGS,"COPROFILE_LINK","index.cfm?fusebox=MTRadmin&fuseaction=dsp_coprofile")>
<CFSET StructInsert(DS.SVC_SETTINGS,"UPROFILE_LINK","index.cfm?fusebox=MTRadmin&fuseaction=dsp_userprofile")>
<CFSET StructInsert(DS.SVC_SETTINGS,"HOME_LINK","index.cfm?fusebox=MTRroot&fuseaction=dsp_home")>

<!--- detariff policy type --->
<cfset StructInsert(DS,"DETAFFPOLTYPE",structNew())>
<CFSET StructInsert(DS.DETAFFPOLTYPE,72,[ {desc="Franchise"},{desc="Non-Franchise"} ])>

<!--- Store ID types --->
<CFSET StructInsert(DS,"IDtypes",StructNew())>
<cfquery name=q_labeldtls datasource=#CURDSN#>
SELECT a.iIDTYPEID,a.vaIDNAME,a.vaIDCHKSTR,a.siIDTYPE,iLANGID=isNULL(a.iLANGID,0),a.iCOUNTRYID
FROM FSYS0008 a WITH (NOLOCK)
WHERE a.siSTATUS=0
</cfquery>
<CFOUTPUT query=q_labeldtls>
	<cfset strct=StructNew()>
	<cfset strct.Name=Trim(vaIDNAME)>
	<cfset strct.IdType=Trim(siIDTYPE)>
	<cfset strct.LID=Trim(iLANGID)>
	<CFIF siIDTYPE IS NOT "">
		<cfset strct.IdChkStr=Trim(vaIDCHKSTR)>
	</CFIF>
	<CFIF iCOUNTRYID IS NOT "">
		<cfset strct.CountryID=Trim(iCOUNTRYID)>
	</CFIF>
	<cfset StructInsert(DS.IDtypes,iIDTYPEID,strct)>
</CFOUTPUT>

<CFSET StructInsert(DS,"TSKSTAT",StructNew())>
<cfquery name=q_taskstatus datasource=#CURDSN#>
SELECT a.ITSKSTATID,a.ITSKRULEGRPID,a.VATSKSTATDESC,a.VATSKSTATLOGICNAME,a.SIISCLOSED,a.IORDER,a.siSTATUS,iLID=ISNULL(a.iLID,0)
FROM FTSK1006 a WITH (NOLOCK)
ORDER BY a.IORDER,a.ITSKRULEGRPID,a.SIISCLOSED,a.iTSKSTATID
</cfquery>
<CFLOOP query=q_taskstatus>
	<cfset strct=StructNew()>
	<cfset strct.Name=Trim(VATSKSTATLOGICNAME)>
	<cfset strct.Desc=Trim(VATSKSTATDESC)>
	<cfset strct.TskRuleGrpID=Trim(ITSKRULEGRPID)>
	<cfset strct.LID=TRIM(iLID)>
	<CFIF SIISCLOSED IS "">
		<cfset strct.IsClosed=0>
	<CFELSE>
		<cfset strct.IsClosed=SIISCLOSED>
	</CFIF>
	<cfset StructInsert(DS.TSKSTAT,ITSKSTATID,strct)>
</CFLOOP>

<CFSET StructInsert(DS,"TSKRULEGRP",StructNew())>
<cfquery name=q_taskgrp datasource=#CURDSN#>
SELECT a.ITSKRULEGRPID,a.VATSKRULEGRPDESC,a.VATSKRULEGRPLOGICNAME
FROM FTSK1005 a WITH (NOLOCK)
ORDER BY a.ITSKRULEGRPID
</cfquery>
<CFLOOP query=q_taskgrp>
	<cfset strct=StructNew()>
	<cfset strct.Name=Trim(VATSKRULEGRPLOGICNAME)>
	<cfset strct.Desc=Trim(VATSKRULEGRPDESC)>
	<cfset StatList="">
	<CFSET TSKRULEGRPID=ITSKRULEGRPID>
	<CFLOOP query=q_taskstatus>
		<CFIF siSTATUS IS 0 AND iTSKRULEGRPID IS TSKRULEGRPID>
			<CFSET StatList=ListAppend(StatList,iTSKSTATID,"|")>
		</CFIF>
	</CFLOOP>
	<CFSET strct.StatList=StatList>
	<cfset StructInsert(DS.TSKRULEGRP,ITSKRULEGRPID,strct)>
</CFLOOP>

<!---Struct Label List--->
<cfset objLabels = createObject("component","#CURAPPLICATION.CFPREFIX##CURAPPLICATION.APPPATH#services/cfc/labels")>
<cfset objLabels.init(CURDSN)>
<cfset DS.LABELS = objLabels.resetVars()>

<cfset DS.AIGEntity = [
    "AIG Insurance (Thailand) Public Company Limited / บริษัท เอไอจี ประกันภัย (ประเทศไทย)"
    ,"New Hampshire Insurance Company / บริษัท นิวแฮมพ์เชอร์ อินชัวรันส์"
]>

<!--- migrated to services/cfc/labels.cfc
<cfset DS.LABELS=StructNew()>
<!--- cfset DS.LABELSCO=StructNew() --->
<cfoutput query=q_labeldtls>
	<cfset DS.LABELS[iLBLDEFID]=StructNew()>
	<cfset DS.LABELS[iLBLDEFID].DOMAINID=iDOMAINID>
	<cfset DS.LABELS[iLBLDEFID].LOCID=iLOCID>
	<cfset DS.LABELS[iLBLDEFID].GCOID=ValueList(q_labelsCO.iGCOID)>
	<!--- list of labels based on GCOID --->
	<!--- cfloop list=#ValueList(q_labelsCO.iGCOID)# INDEX=IDX>
		<cfif NOT structKeyExists(DS.LABELSCO,IDX)><cfset DS.LABELSCO[IDX]=""></cfif>
		<cfset DS.LABELSCO[IDX]=LISTAPPEND(DS.LABELSCO[IDX],#iLBLDEFID#)>
	</cfloop --->
	<cfset DS.LABELS[iLBLDEFID].PRIVATE=siPRIVATE>
	<cfset DS.LABELS[iLBLDEFID].COCREATE=bCOCREATE>
	<cfset DS.LABELS[iLBLDEFID].COREAD=bCOREAD>
	<cfset DS.LABELS[iLBLDEFID].COLORTXT=iCOLORTXT>
	<cfset DS.LABELS[iLBLDEFID].COLORBGRND=iCOLORBGRND>
	<cfset DS.LABELS[iLBLDEFID].LBLNAME=vaLBLNAME>
</cfoutput>
--->

<!--- MIKE:Permission list in a given group --->
<cfquery name="q_perm" datasource=#CURDSN#>
SELECT a.iPERMGRPID,c.vaPERMGRPNAME,a.siPGROUP
FROM SEC0003 a WITH (NOLOCK) INNER JOIN SEC0023 c WITH (NOLOCK) ON a.iPERMGRPID=c.iPERMGRPID
WHERE a.siSTATUS=0
ORDER BY a.iPERMGRPID
</cfquery>
<cfset DS.PERMGRP=StructNew()>
<cfoutput query=q_perm group="iPERMGRPID">
	<cfset permlist="">
	<cfoutput><cfset permlist=ListAppend(permlist,siPGROUP)></cfoutput>
	<cfset DS.PERMGRP[iPERMGRPID]=StructNew()>
	<cfset DS.PERMGRP[iPERMGRPID].PLIST=permlist>
	<cfset DS.PERMGRP[iPERMGRPID].GRPNAME=vaPERMGRPNAME>
</cfoutput>

<CFSET DS.INJCLASS={	1={Name="Minor",SubClass="101|Abrasions|102|Bruises|103|Contusion|114|Dislocation|113|Fracture|104|Giddiness/Headache|105|Haemotoma|106|Laceration|107|Loss of Consciousness|115|Others|108|Spasm|109|Sprain|110|Stable Head Injury|116|Stitches|111|Swelling|112|Tenderness"},<!--- Max:116 --->
					2={Name="Major",SubClass="200|Amputation|201|Brain/Spinal Injury|202|Comatose|215|Dislocation|203|Double Vision/Diplopia|214|Fracture|204|Fracture-Amputation|205|Injury to Internal Organs|206|Loss of Smell (permanent)|207|Loss of Hearing (permanent)|208|Loss of Vision (1 eye)|209|Loss of Vision (both eyes)|210|Others|211|Paraplegia|212|Quadriplegia|213|Tetraplegia"},<!--- Max:215 --->
					3={Name="Whiplash Minor",SubClass="300|Neck Muscle Spasm|301|Neck Pain|302|Neck Sprain|303|Neck Strain|304|Neck Tenderness"},
					4={Name="Whiplash Major",SubClass="400|Pure Whiplash"},
					5={Name="Post Traumatic Disorder Syndrome",SubClass="500|Post Traumatic Disorder Syndrome"},
					6={Name="Dental",SubClass="600|Cracked Teeth|601|Fracture|602|Loosen Teeth|603|Missing Teeth"},
					7={Name="Fatal",SubClass="700|Fatal"}}>



<CFSET TPCosts=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT a.iBITTPMASK,a.vaDESC,a.vaCOLSLIST,a.vaFIELDNAME,a.vaCLMTYPELIST,a.vaALLOWLIAB,a.vaALLOWTYPE,a.vaFIELDNAME2
 FROM BIZ0028 a WITH (NOLOCK) WHERE a.siSTATUS=0
ORDER BY a.iORDER
</cfquery>
<CFLOOP query=q_trx>
	<CFSET A=ListToArray(vaCOLSLIST,",")>
	<CFSET T=StructNew()>
	<CFSET T.N=Trim(vaDESC)><CFSET T.C=A[1]>
	<CFIF ArrayLen(A) GTE 3>
		<CFSET T.RD=A[2]><CFSET T.RR=A[3]>
		<CFIF ArrayLen(A) GTE 4>
			<CFSET T.RV=A[4]>
		</CFIF>
	</CFIF>
	<CFSET T.FieldName=UCase(Trim(vaFIELDNAME))>
	<CFSET T.FieldName2=UCase(Trim(vaFIELDNAME2))>
	<CFSET T.ClmTypeList=UCase(Trim(vaCLMTYPELIST))>
	<CFSET T.AllowLiab=UCase(Trim(vaALLOWLIAB))>
	<CFSET T.AllowType=UCase(Trim(vaALLOWTYPE))>
	<CFSET StructInsert(TPCosts,iBITTPMASK,T)>
</CFLOOP>
<CFSET TPCosts.BitMaskList=ValueList(q_trx.iBITTPMASK)>
<CFSET DS.TPCosts=TPCosts>

<!--- Reason IDs --->
<cfset rsnid=StructNew()>
<cfset rsnid_LID=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT siRSNID,vaDESC,iLID FROM BIZ0005 WITH (NOLOCK) WHERE siSTATUS=0
ORDER BY siRSNID
</cfquery>
<cfoutput query=q_trx>
	<cfset StructInsert(rsnid,siRSNID,vaDESC)>
	<cfset StructInsert(rsnid_LID,siRSNID,iLID)>
</cfoutput>
<cfset DS.CLMCLOSERSNID=rsnid>
<cfset DS.CLMCLOSERSNID_LID=rsnid_LID>

<!--- SVC currency formatting --->
<CFQUERY NAME="q_currency" DATASOURCE="#CURDSN#">
SELECT iCurrencyID,vaCURRENCY,vaCURRENCYINTL,vaCURRENCYFORMAT,vaCURRENCYNAME
FROM SYS0029 WITH (NOLOCK)
WHERE siStatus=0
</CFQUERY>
<CFSET DS.CURRENCIES=[]>
<CFOUTPUT query="q_currency">
	<cfset DS.CURRENCIES[iCurrencyID]={Currency=vaCURRENCY,CurrencyIntl=vaCURRENCYINTL,CurrencyFormat=vaCURRENCYFORMAT,CurrencyFull=vaCURRENCYNAME}>
</CFOUTPUT>

<CFQUERY NAME="q_currencylist" DATASOURCE="#CURDSN#">
SELECT iCurrencyID,vaCURRENCY,vaCURRENCYINTL,vaCURRENCYFORMAT,vaCURRENCYNAME
FROM SYS0029 WITH (NOLOCK)
WHERE siStatus=0 ORDER BY vaCURRENCYINTL
</CFQUERY>
<cfset DS.CURRENCYLIST=ValueList(q_currencylist.iCurrencyID)>

<!--- Nature of Loss --->
<cfquery NAME=q_dmgtype DATASOURCE=#CURDSN#>
SELECT a.iCOID,a.iCLMTYPEMASK,a.vaCFCODE,a.vaCFDESC,a.vaLOGICNAME,iLID=IsNull(a.iLID,0),a.vaCFMAPCODE FROM BIZ0025 a WITH (NOLOCK)
WHERE a.aCFTYPE='DAMTYPE' AND a.siSTATUS=0
ORDER BY a.iCOID,a.vaCFDESC
</cfquery>
<CFSET DS.DMGTYPE=q_dmgtype>

<!--- activity log categories --->
<cfquery name="qry_logcat" datasource="#CURDSN#">
    select
        iCAT,siCATTYPE,iGCOID,vaDESC
    from FOBJB3024CAT
    where siSTATUS = 0
</cfquery>
<cfset DS.LOGCAT=qry_logcat>

<!--- begin: cache java loader and classes --->
<cfset paths 	= arrayNew(1)>
<cfset paths[1] = expandPath("#CURAPPLICATION.CFPREFIX##CURAPPLICATION.APPPATH#services/QR/core-2.1.jar")>
<cfset paths[2] = expandPath("#CURAPPLICATION.CFPREFIX##CURAPPLICATION.APPPATH#services/QR/javase-2.1.jar")>
<cfset paths[3] = expandPath("#CURAPPLICATION.CFPREFIX##CURAPPLICATION.APPPATH#services/cfc/lib/UtilSql.jar")>
<cfset paths[4] = expandPath("#CURAPPLICATION.CFPREFIX##CURAPPLICATION.APPPATH#services/cfc/lib/pdfbox-app-2.0.19.jar")>

<cfset ds.loader= createObject("component", "#CURAPPLICATION.CFPREFIX##CURAPPLICATION.APPPATH#services\cfc\Javaloader").init(paths)>
<!--- end  : cache java loader and classes --->

<!--- TPBI 2 module variables is json --->
<cfquery name="qry_dictionary2" datasource="#CATDSN#">
    select maingroup.VACMPCODE as VACMPCODE1, maingroup.VACMP as VACMPMAIN
           , subgroup.VACMPCODE as VACMPCODE2, subgroup.VACMP as VACMPSUB
           , binder.IPGRPID,visual.VAPGRPDESC, binder.VADESCCODE, injuries.VADESC
           , pricelist.ICATID, pricelist.MNMIN, pricelist.MNMAX
    from PDB0002_BI subgroup with (nolock)
    inner join PDB0002_BI maingroup with (nolock) on maingroup.VACMPCODE = subgroup.VAPARENT
    left join PDB0004_BI binder with (nolock) on binder.VACMPCODE = subgroup.VACMPCODE
	    and binder.IPSCID = 9
	    and binder.VAPROJCODE = 'MRM-INJ1'
    left join PDB0002 visual with (nolock) on visual.IPGRPID = binder.IPGRPID
    left join PDB0003 injuries with (nolock) on injuries.VADESCCODE = binder.VADESCCODE
	    and binder.IPSCID = 9
    left join PDB0008_BI pricelist with (nolock) on pricelist.VACMPCODE =binder.VACMPCODE and  pricelist.IPGRPID=binder.IPGRPID and pricelist.VADESCCODE = binder.VADESCCODE
	    and pricelist.ICATID = 31
    order by subgroup.VACMPCODE,injuries.VADESCCODE
</cfquery>
<cfquery name="qry_dictionary" dbtype="query">
    select * from qry_dictionary2 where ipgrpid is not null
</cfquery>
<cfquery name="CMPMAIN" dbtype="query"> select distinct VACMPCODE1,VACMPMAIN from qry_dictionary </cfquery>
<cfquery name="CMPSUB" dbtype="query"> select distinct VACMPCODE1,VACMPCODE2,VACMPSUB from qry_dictionary </cfquery>
<cfquery name="CMPSUB2" dbtype="query"> select distinct VACMPCODE1,VACMPCODE2,VACMPSUB from qry_dictionary2 </cfquery>
<cfquery name="GRP" dbtype="query"> select distinct IPGRPID,VAPGRPDESC from qry_dictionary </cfquery>

<!--- shiu: ToBuild #12830 [MY] AIG - Motor Claims - Data Entry Option for Initial Contact
    begin: initial contact --->
<cfset qinitialcontact = querynew('no,desc')>
<cfset queryaddrow(qinitialcontact)> <cfset querysetcell(qinitialcontact,'no',1)> <cfset querysetcell(qinitialcontact,'desc','Letter- Phone and Email Unsuccessful')>
<cfset queryaddrow(qinitialcontact)> <cfset querysetcell(qinitialcontact,'no',2)> <cfset querysetcell(qinitialcontact,'desc','Letter- No Email or Phone Details'   )>
<cfset queryaddrow(qinitialcontact)> <cfset querysetcell(qinitialcontact,'no',3)> <cfset querysetcell(qinitialcontact,'desc','Letter- Preferred Method of Contact' )>
<cfset queryaddrow(qinitialcontact)> <cfset querysetcell(qinitialcontact,'no',4)> <cfset querysetcell(qinitialcontact,'desc','Email- Phone Unsuccessful'           )>
<cfset queryaddrow(qinitialcontact)> <cfset querysetcell(qinitialcontact,'no',5)> <cfset querysetcell(qinitialcontact,'desc','Email- Preferred Method of Contact'  )>
<cfset queryaddrow(qinitialcontact)> <cfset querysetcell(qinitialcontact,'no',6)> <cfset querysetcell(qinitialcontact,'desc','Phone- Spoke to Contact'             )>
<CFSET StructInsert(DS,"INITIALCONTACT",qinitialcontact)>
<!--- end: initial contact --->


<!--- Store COROLES --->
<CFSET COTYPENAME=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.sicotypeid,a.vadesc,iLID=isNULL(a.iLID,0) FROM sec0006 a WITH (NOLOCK) where a.sistatus=0
ORDER BY a.sicotypeid
</cfquery>
<CFLOOP query=q_trx>
	<CFSET StructInsert(COTYPENAME,"#siCOTYPEID#",{DESC="#Trim(q_trx.vadesc)#",ILID="#Trim(q_trx.iLID)#"})>
</CFLOOP>
<CFSET StructInsert(DS,"COTYPENAME",COTYPENAME)>

<!--- Store COROLES --->
<CFSET COROLES=StructNew()>
<CFSET COROLESByCODE=StructNew()>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
select a.iDOMAINID,a.iCOROLE,a.vaCOROLECODE,a.vaLONGDESC,iLID=isNULL(a.iLID,0) FROM FOBJ3003 a WITH (NOLOCK)
ORDER BY a.iDOMAINID,a.iCOROLE
</cfquery>
<CFLOOP query=q_trx>
	<CFSET StructInsert(COROLES,"#q_trx.iDOMAINID#,#q_trx.iCOROLE#",{CODE="#Trim(q_trx.vaCOROLECODE)#",DESC="#Trim(q_trx.vaLONGDESC)#",LID="#Trim(q_trx.iLID)#"})>
	<CFSET StructInsert(COROLESByCODE,"#q_trx.iDOMAINID#,#Trim(q_trx.vaCOROLECODE)#",{COROLE="#q_trx.iCOROLE#",DESC="#Trim(q_trx.vaLONGDESC)#",LID="#Trim(q_trx.iLID)#"})>
</CFLOOP>
<CFSET StructInsert(DS,"COROLES",COROLES)>
<CFSET StructInsert(DS,"COROLESByCODE",COROLESByCODE)>

<!--- User Roles --->
<CFSET USROLES={}>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT GRP=CAST(a.iDOMAINID AS varchar)+','+CAST(a.iCOROLE AS varchar),a.iUSROLEID,a.vaUSROLECODE,a.vaLONGDESC
FROM FOBJ3004 a WITH (NOLOCK)
ORDER BY GRP,a.iUSROLEID
</cfquery>
<CFOUTPUT query=q_trx group="GRP">
	<CFSET st={}>
	<CFOUTPUT>
		<CFSET st[iUSROLEID]={USROLEID="#iUSROLEID#",CODE="#Trim(vaUSROLECODE)#",DESC="#Trim(vaLONGDESC)#"}>
	</CFOUTPUT>
	<CFSET USROLES[GRP]=st>
</CFOUTPUT>
<CFSET StructInsert(DS,"USROLES",USROLES)>

<CFSET StructInsert(DS,"BOLA_SCENARIO_A","1|1|2|2|3|3|4|4|4A|4A|4B|4B|5|5|5A|5A|5B|5B|6|6|6A|6A|6B|6B|7|7|8|8|8A|8A|9|9|9A|9A|10|10|11A|11A|11B|11B|11C|11C|12|12|12A|12A|13|13|13A|13A|13B|13B|14|14|14A|14A|15|15|16|16|16A|16A|17|17|18|18|19|19|20|20|21|21|22|22|23|23|24|24|24A|24A|24B|24B|25|25|26|26|26A|26A|27|27|28|28|28A|28A|28B|28B|28C|28C|28D|28D|28E|28E|28F|28F|28G|28G|28H|28H|29|29|29A|29A|29B|29B|29C|29C|30|30|31|31|32|32|33|33|34|34|35|35|35A|35A|35B|35B|35C|35C|50-50|50-50|N/A|N/A|")>
<CFSET StructInsert(DS,"BOLA_SCENARIO_B","1|1|2|2|3|3|4|4|4A|4A|4B|4B|5|5|5A|5A|5B|5B|6|6|6A|6A|6B|6B|6C|6C|7|7|8|8|8A|8A|9|9|9A|9A|9B|9B|9C|9C|9D|9D|9E|9E|10|10|10A|10A|10B|10B|11A|11A|11B|11B|11C|11C|11D|11D|12|12|12A|12A|13|13|13A|13A|13B|13B|14|14|14A|14A|15|15|15A|15A|16|16|16A|16A|17|17|18|18|19|19|20|20|21|21|22|22|23|23|24|24|24A|24A|24B|24B|24C|24C|24D|24D|24E|24E|25|25|26|26|26A|26A|26B|26B|27|27|27A|27A|28|28|28A|28A|28B(I)|28B(i)|28B(II)|28B(ii)|28C|28C|28D|28D|28E|28E|28F|28F|28G|28G|28G(I)|28G(i)|28H|28H|28I|28I|28J|28J|28K|28K|28L|28L|28M|28M|29|29|29A|29A|29B|29B|29C|29C|30|30|31|31|31A|31A|32|32|33|33|33A|33A|34|34|35|35|35A|35A|35B|35B|35C(I)|35C(i)|35C(II)|35C(ii)|35D|35D|35E|35E|35F|35F|36|36|36A(I)|36A(i)|36A(II)|36A(ii)|36B|36B|50-50|50-50|N/A|N/A|")>


<!--- Language DS stuff --->
<CFSET DS.FN.SVClangDSUpdate(DS,CURDSN)>

<!--- Client JS appvars --->
<cfif IsDefined("Application.SETVARS_WRITEJS") AND Application.SETVARS_WRITEJS IS 0>
	<!--- SVCappvars --->
	<CFSET CURFILE="#ExpandPath(CURAPPLICATION.CFPREFIX&CURAPPLICATION.SVCPATH)#scripts\SVCappvars.js">
	<CFSET DS.FN.SVCwriteJSappvars(DS,CURDSN,CURFILE)>
	<!--- MTRappvars --->
	<CFOUTPUT><cfsavecontent variable="tmp">
	if(!request.DS) request.DS={};
	request.DS.LANGLIST="#DS.LANGLIST#"; <!--- Available language selection (updated from SVClangDSUpdate) --->
	request.DS.DMGTYPE=#serializeJSON(q_dmgtype)#; <!--- Nature of Loss --->
<!--- begin: variables for TPBI2 --->
	request.DS.rawMain    = #serializeJSON(qry_dictionary, false)#;
	request.DS.rawCmpMain = #serializeJSON(CMPMAIN, false)#;
	request.DS.rawCmpSub  = #serializeJSON(CMPSUB, false)#;
	request.DS.rawCmpSub2  = #serializeJSON(CMPSUB2, false)#;
	request.DS.rawVis     = #serializeJSON(GRP, false)#;
<!--- end: variables for TPBI2 --->
	request.DS.BOLA_SCENARIO_A="#DS.BOLA_SCENARIO_A#";
	request.DS.BOLA_SCENARIO_B="#DS.BOLA_SCENARIO_B#";
	</cfsavecontent></CFOUTPUT>
	<CFSET CURFILE="#ExpandPath(CURAPPLICATION.CFPREFIX&CURAPPLICATION.MTRPATH)#MSupport\unencoded\MTRappvars.js">
	<cffile CHARSET="UTF16" ACTION="write" FILE="#CURFILE#" OUTPUT=#tmp# ADDNEWLINE=NO>
	<cfset Application.SETVARS_WRITEJS=1>
</cfif>

<cfif IsDefined("APPLICATION.CURDS")>
	<cfset APPLICATION.CURDS=APPLICATION.CURDS MOD 2+1>
<cfelse>
	<cfset APPLICATION.CURDS=1>
</cfif>
<cfif Application.CURDS IS 1>
	<cfset Application.DS1=DS>
<cfelse>
	<cfset Application.DS2=DS>
</cfif>
<cfset Application.Setvars=1>
</cfif>
</cflock>
</cfsilent>
