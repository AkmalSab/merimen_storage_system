<cfif NOT(IsDefined("session.vars.orgtype"))>
	<CFSET Request.DS.FN.SVCRequestIpChk()>
<cfelse>
	<CFSET Request.DS.FN.SVCsessionChk()>
</cfif>
<!--- attributes:
DOCTYPE : INV : Invitation letter, BID : Bid Letter, AWD = award letter, TOW = tow authorisation letter
MODE : GETDOC : Get document file, WRITEDOC : write document file, GETLOC = get tender's file loc ID
iTENDER : tender ID
iRETENDER : retender of TENDER ID
IBIDID : Bid ID of tender ID / list of BID ID of tender ID (separated with comma ",")
QRY_BIDDER: query provided with "ibidid" and "siretender"
FILELOCID : file location ID
REPCOID : repairer COID ( for BID letter / AWD letter )

MNBID : bid amount (for BID letter)
LTRCONTENT : custom letter for TOW
ACTCOSECPOS : awarded person (for AWD letter)

--->
<cfparam name="attributes.VARMODRESULT" type="string" default="MODRESULT">

<CFIF NOT(IsDefined("attributes.FILELOCID") AND attributes.FILELOCID GT 0)>
	<!--- get FILELOCID --->
	<CFSET TENDER_DOCCLASSID=14>
	<CFSET TENDER_DOMAINID=2>
	<cfstoredproc PROCEDURE="sspFDOCGetDefFilelocID" DATASOURCE=#Request.SVCDSN# RETURNCODE=YES>
		<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER NULL=YES DBVARNAME=@ai_docid>
		<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER NULL=YES DBVARNAME=@ai_docdefid>
		<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#TENDER_DOMAINID# DBVARNAME=@ai_domainid>
		<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#TENDER_DOCCLASSID# DBVARNAME=@ai_docclassid>
	</cfstoredproc>
	<cfset Returncode=CFSTOREDPROC.STATUSCODE>
	<cfif Returncode LTE 0>
		<cfthrow TYPE="EX_DBERROR" ErrorCode="MTR/I/TEN/GENTENLTR1(#returncode#)">
	</cfif>
	<cfset attributes.FILELOCID=#returncode#>
</cfif>
<cfset GENDOCID="">
<cfif NOT(attributes.MODE IS "GETLOC")>
	<!--- get filelocpath --->
	<cfstoredproc PROCEDURE="sspFDOCGetDocPath" DATASOURCE=#Request.SVCDSN# RETURNCODE=YES>
		<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER value=#attributes.FILELOCID# DBVARNAME=@iFILELOCID>
		<CFPROCRESULT resultset=1 NAME=q_row>
	</cfstoredproc>
	<cfif CFSTOREDPROC.STATUSCODE LT 0><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid FILELOCID"></cfif>
	<cfif q_row.recordcount GT 0><cfset FILE_APPEND=#q_row.VAAPPEND#></cfif>
	<cfif FILE_APPEND IS ""><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid FILE_APPEND"></cfif>

	<CFIF attributes.DOCTYPE IS "INV">
		<!--- invitation letter --->
		<!--- 	<cfif NOT(IsDefined("attributes.BIDID") AND attributes.BIDID NEQ "")><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid INV-BIDID"></cfif> --->
		<cfif attributes.MODE IS "WRITEDOC">
			<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid MODE-INV-WRITEDOC">
<!---- ************** invitation letter will not generated now. this mode is no longer in use ...
			<cfif NOT(IsDefined("attributes.QRY_BIDDER") AND IsDefined("attributes.QRY_BIDDER.IBIDID") AND IsDefined("attributes.QRY_BIDDER.siretender"))><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid Parameter INV-WRITEDOC"></cfif>
			<cfloop query="attributes.QRY_BIDDER">
				<!--- FILE_APPEND with ".... TFW\" --->
				<cfset TENDER_FILENAME="#FILE_APPEND#INV#attributes.iTENDER#RET#attributes.QRY_BIDDER.siretender#B#attributes.QRY_BIDDER.IBIDID#">
				<cfset TENDER_TEMPLATEPATH="#Request.logpath#index.cfm">
	<!--- 			<cfdump var="tender_filename : #TENDER_FILENAME#"><br>
				<cfdump var="tender_filename : #TENDER_TEMPLATEPATH#">
				<cfabort> --->
				<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCgenfile.cfm" templatename=#TENDER_TEMPLATEPATH# fusebox=MTRinsureretender fuseaction=gen_printinvletter itender=#attributes.itender# ibidid=#attributes.QRY_BIDDER.ibidid# usepseudo=0 genfile=1 fpath=#TENDER_FILENAME# fext="htm">
			</cfloop>
************ ---->
		<cfelseif attributes.MODE IS "GETDOC">
			<cfif NOT(IsDefined("attributes.IBIDID") AND attributes.iBIDID GT 0 AND isDefined("attributes.iRETENDER") AND attributes.iretender GTE 0)><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid Parameter INV-GETDOC"></cfif>
			<cfset TENDER_FILENAME="#FILE_APPEND#INV#attributes.iTENDER#RET#attributes.iRETENDER#B#attributes.IBIDID#">
			<!--- <cfset TENDER_TEMPLATEPATH="#Request.logpath#index.cfm"> --->
			<cfif FileExists("#TENDER_FILENAME#.htm")>
		 		<cffile action="read" file="#TENDER_FILENAME#.htm" variable="FILEVAR" charset="UTF-8">
				<cfcontent reset="yes"><cfoutput>#FILEVAR#</cfoutput>
				<!--- <CFINCLUDE template="#getpath#TFW/INV#attributes.itender#RET#q_retender.retender#B#attributes.ibidid#.htm"> --->
			<cfelse>
				<cfif session.vars.locid IS 1 AND attributes.FILELOCID IS 101><!--- malaysia, pointing on the old path, refer to G$ --->
					<!--- cfset getpath="/HTMReport_Old/">
					<cfset TENDER_FILENAME="#ExpandPath("#getpath#")#TFW/INV#attributes.iTENDER#RET#attributes.iRETENDER#B#attributes.IBIDID#" --->
					<!--- <cfset TENDER_FILENAME="\\10.1.1.28\G$\OldReports\Production\TFW/INV#attributes.iTENDER#RET#attributes.iRETENDER#B#attributes.IBIDID#"> --->
					<cfset TENDER_FILENAME="#FILE_APPEND#INV#attributes.iTENDER#RET#attributes.iRETENDER#B#attributes.IBIDID#">
					<cfif FileExists("#TENDER_FILENAME#.htm")>
				 		<cffile action="read" file="#TENDER_FILENAME#.htm" variable="FILEVAR" charset="UTF-8">
						<cfcontent reset="yes"><cfoutput>#FILEVAR#</cfoutput>
					<cfelse>
						<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid File INV-GETDOC (OLD)">
					</cfif>
				<cfelse>
					<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid File INV-GETDOC">
				</cfif>
			</cfif>
		<cfelse>
			<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid MODE-INV">
		</cfif>
	<CFELSEIF attributes.DOCTYPE IS "BID">
		<!--- tenderer's bid letter --->
		<cfif attributes.MODE IS "WRITEDOC">
<!---- ************** V1 : last revision on 07/08/2012
			<cfif NOT(IsDefined("attributes.repcoid") AND attributes.repcoid GT 0 AND isDefined("attributes.iRETENDER") AND attributes.iretender GTE 0 AND IsDefined("attributes.itender") AND attributes.itender GT 0)><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid Parameter BID-WRITEDOC"></cfif>
			<cfif NOT(IsDefined("attributes.MNBID") AND attributes.MNBID NEQ "")><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid Parameter BID-WRITEDOC-BID"></cfif>
			<!--- FILE_APPEND with ".... TFW\" --->
			<cfset TENDER_FILENAME="#FILE_APPEND#BID#attributes.iTENDER#RET#attributes.iRETENDER#B#attributes.repcoid#">
			<cfset TENDER_TEMPLATEPATH="#Request.logpath#index.cfm">
			<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCgenfile.cfm" templatename=#TENDER_TEMPLATEPATH# fusebox=MTRrepaireretender fuseaction=gen_printbidletter itender=#attributes.itender# repcoid=#attributes.repcoid# mnbid=#attributes.MNBID# doprint=1 fpath=#TENDER_FILENAME# fext="htm">
************ ---->
			<cfif NOT(IsDefined("attributes.repcoid") AND attributes.repcoid GT 0 AND IsDefined("attributes.itender") AND attributes.itender GT 0)><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid Parameter BID-WRITEDOC1"></cfif>
			<cfif NOT(IsDefined("attributes.MNBID") AND attributes.MNBID NEQ "")><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid Parameter BID-WRITEDOC2"></cfif>
			<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCOBJSEC.cfm" DOMAINID=2 OBJID=#Attributes.itender# corole=0 VARMODRESULT=MODRESULT><!--- get modresult.corole --->
			<CFSAVECONTENT VARIABLE="BIDCONTENT"><CFMODULE template="#Request.logpath#index.cfm" fusebox="MTRrepaireretender" fuseaction="gen_printbidletter" itender=#attributes.itender# repcoid=#attributes.repcoid# mnbid=#attributes.MNBID# doprint=1></CFSAVECONTENT>
			<CFMODULE template="#Request.logpath#index.cfm" FUSEBOX=SVCdoc FUSEACTION=ACT_DOCEDIT NOHEADER
				DOMAINID=2 OBJID=#attributes.itender# LINKID=#attributes.itender# CRTCOROLE=#modresult.corole# DOCDEFID=983
				DOCSTAT=3 CONTENT=#BIDCONTENT# BCO_FLAGMODE="OVERRIDE" BCOREAD=0 BCOCONTROL=0 >				
			<CFSET GENDOCID=MODRESULT.DOCID>
		<cfelseif attributes.MODE IS "GETDOC">
			<cfif NOT(IsDefined("attributes.repcoid") AND attributes.repcoid GT 0  AND isDefined("attributes.iRETENDER") AND attributes.iretender GTE 0 AND IsDefined("attributes.itender") AND attributes.itender GT 0)><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid Parameter BID-GETDOC"></cfif>
			<cfset TENDER_FILENAME="#FILE_APPEND#BID#attributes.iTENDER#RET#attributes.iRETENDER#B#attributes.repcoid#">
			<!--- <cfset TENDER_TEMPLATEPATH="#Request.logpath#index.cfm"> --->
			<cfif FileExists("#TENDER_FILENAME#.htm")>
		 		<cffile action="read" file="#TENDER_FILENAME#.htm" variable="FILEVAR" charset="UTF-8">
				<cfcontent reset="yes"><cfoutput>#FILEVAR#</cfoutput>
			<cfelse>
				<cfif session.vars.locid IS 1 AND attributes.FILELOCID IS 101><!--- malaysia, pointing on the old path, refer to G$ --->
					<!--- cfset getpath="/HTMReport_Old/">
					<cfset TENDER_FILENAME="#ExpandPath("#getpath#")#TFW/BID#attributes.iTENDER#RET#attributes.iRETENDER#B#attributes.repcoid#" --->
					<!--- <cfset TENDER_FILENAME="\\10.1.1.28\G$\OldReports\Production\TFW/BID#attributes.iTENDER#RET#attributes.iRETENDER#B#attributes.repcoid#"> --->
					<cfset TENDER_FILENAME="#FILE_APPEND#BID#attributes.iTENDER#RET#attributes.iRETENDER#B#attributes.repcoid#">
					<cfif FileExists("#TENDER_FILENAME#.htm")>
				 		<cffile action="read" file="#TENDER_FILENAME#.htm" variable="FILEVAR" charset="UTF-8">
						<cfcontent reset="yes"><cfoutput>#FILEVAR#</cfoutput>
					<cfelse>
						<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid File BID-GETDOC (OLD)">
					</cfif>
				<cfelse>
					<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid File BID-GETDOC">
				</cfif>
			</cfif>
		<cfelse>
			<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid MODE-BID">
		</cfif>
	<CFELSEIF attributes.DOCTYPE IS "AWD">
		<!--- award letter --->
		<cfif attributes.MODE IS "WRITEDOC">
<!---- ************** V1 : last revision on 07/08/2012
			<cfif NOT(isDefined("attributes.iBIDID") AND attributes.iBIDID GT 0 AND IsDefined("attributes.itender") AND attributes.itender GT 0)><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid Parameter AWD-WRITEDOC"></cfif>
			<!--- FILE_APPEND with ".... TFW\" --->
			<cfset TENDER_FILENAME="#FILE_APPEND#AWA#attributes.iTENDER#B#attributes.iBIDID#">
			<cfset TENDER_TEMPLATEPATH="#Request.logpath#index.cfm">
			<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCgenfile.cfm" templatename=#TENDER_TEMPLATEPATH# fusebox=MTRinsureretender fuseaction=gen_printawardletter itender=#attributes.itender# finalized=1 fpath=#TENDER_FILENAME# fext="htm">
************ ---->
			<cfif NOT(IsDefined("attributes.itender") AND attributes.itender GT 0 AND IsDefined("attributes.ACTCOSECPOS") AND attributes.ACTCOSECPOS GTE 0)><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid Parameter AWD-WRITEDOC"></cfif>
			<cfquery datasource=#Request.MTRDSN# name=q_tenawd>
			SELECT icoid,siadjtenderstat,iadjcoid FROM TRX0070 a with (nolock) WHERE a.itender=<cfqueryparam cfsqltype="cf_sql_integer" value=#attributes.itender#>
			</cfquery>
			<CFSAVECONTENT VARIABLE="AWDCONTENT"><CFMODULE template="#Request.logpath#index.cfm" fusebox="MTRInsureretender" fuseaction="gen_printawardletter" itender=#attributes.itender# finalized=1></CFSAVECONTENT>
			<cfif Not(isdefined("session.vars.orgtype")) OR (isdefined("session.vars.orgtype") AND session.vars.orgtype IS "D")>
				<CFMODULE template="#Request.logpath#index.cfm" FUSEBOX=SVCdoc FUSEACTION=ACT_DOCEDIT NOHEADER
					DOMAINID=2 OBJID=#attributes.itender# LINKID=#attributes.itender# CRTCOROLE=2 DOCDEFID=981 CRTCOID=#q_tenawd.icoid#
					DOCSTAT=3 CONTENT=#AWDCONTENT# USID=1>
			<cfelse>
				<CFMODULE template="#Request.logpath#index.cfm" FUSEBOX=SVCdoc FUSEACTION=ACT_DOCEDIT NOHEADER
					DOMAINID=2 OBJID=#attributes.itender# LINKID=#attributes.itender# CRTCOROLE=2 DOCDEFID=981 CRTCOID=#q_tenawd.icoid#
					DOCSTAT=3 CONTENT=#AWDCONTENT#>
			</cfif>
			<CFSET GENDOCID=MODRESULT.DOCID>
			<cfif attributes.ACTCOSECPOS GT 0>
				<!--- grant doc to selected winner --->
				<cfstoredproc PROCEDURE="sspFDOCSetExtSec" DATASOURCE=#Request.SVCDSN# RETURNCODE=YES>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@IDOCID value=#GENDOCID#>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@ICOSECPOS value=#attributes.ACTCOSECPOS#>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@siACCTYPE value=1>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_usid value=1>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@IDOMAINID value=2>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@IOBJID value=#attributes.itender#>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@actCOROLE NULL="YES">
				</cfstoredproc>
				<cfset Returncode=CFSTOREDPROC.STATUSCODE>
				<cfif Returncode LT 0>
					<cfthrow TYPE="EX_DBERROR" ErrorCode="MTR/I/TEN/AWDWRITEDOC(#returncode#)">
				</cfif>
			</cfif>
			<cfif q_tenawd.iadjcoid GT 0 AND q_tenawd.siadjtenderstat IS 50>
				<!--- grant doc to adjuster --->
				<cfstoredproc PROCEDURE="sspFDOCSetSec" DATASOURCE=#Request.SVCDSN# RETURNCODE=YES>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_docid value=#GENDOCID#>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_usid value=1>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_actcorole NULL="YES">
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_bitmask value=4>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_bitset value=4>
				</cfstoredproc>
				<cfset Returncode=CFSTOREDPROC.STATUSCODE>
				<cfif Returncode LT 0>
					<cfthrow TYPE="EX_DBERROR" ErrorCode="MTR/I/TEN/AWDWRITEDOC-ADJ(#returncode#)">
				</cfif>
			</cfif>
		<cfelseif attributes.MODE IS "GETDOC">
			<!--- get the file via the old framework --->
			<cfif NOT(isDefined("attributes.iBIDID") AND attributes.iBIDID GT 0 AND IsDefined("attributes.itender") AND attributes.itender GT 0)><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid Parameter AWD-GETDOC"></cfif>
			<cfset TENDER_FILENAME="#FILE_APPEND#AWA#attributes.iTENDER#B#attributes.iBIDID#">
			<!--- <cfset TENDER_TEMPLATEPATH="#Request.logpath#index.cfm"> --->
			<cfif FileExists("#TENDER_FILENAME#.htm")>
		 		<cffile action="read" file="#TENDER_FILENAME#.htm" variable="FILEVAR" charset="UTF-8">
				<cfcontent reset="yes"><cfoutput>#FILEVAR#</cfoutput>
			<cfelse>
				<cfif session.vars.locid IS 1 AND attributes.FILELOCID IS 101><!--- malaysia, pointing on the old path, refer to G$ --->
					<!--- cfset getpath="/HTMReport_Old/">
					<cfset TENDER_FILENAME="#ExpandPath("#getpath#")#TFW/AWA#attributes.iTENDER#B#attributes.iBIDID#" --->
					<!--- <cfset TENDER_FILENAME="\\10.1.1.28\G$\OldReports\Production\TFW/AWA#attributes.iTENDER#B#attributes.iBIDID#"> --->
					<cfset TENDER_FILENAME="#FILE_APPEND#AWA#attributes.iTENDER#B#attributes.iBIDID#">
					<cfif FileExists("#TENDER_FILENAME#.htm")>
				 		<cffile action="read" file="#TENDER_FILENAME#.htm" variable="FILEVAR" charset="UTF-8">
						<cfcontent reset="yes"><cfoutput>#FILEVAR#</cfoutput>
					<cfelse>
						<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid File AWD-GETDOC (OLD)">
					</cfif>
				<cfelse>
					<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid File AWD-GETDOC">
				</cfif>
			</cfif>
		<cfelse>
			<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid MODE-AWD">
		</cfif>
	<CFELSEIF attributes.DOCTYPE IS "TOW">
		<!--- tow authorisation letter --->
		<cfif attributes.MODE IS "WRITEDOC">
<!---- ************** V1 : last revision on 07/08/2012
			<cfif NOT(IsDefined("attributes.itender") AND attributes.itender GT 0)><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid Parameter TOW-WRITEDOC"></cfif>
			<!--- FILE_APPEND with ".... TFW\" --->
			<cfset TENDER_FILENAME="#FILE_APPEND#TOW#attributes.iTENDER#">
			<cfset TENDER_TEMPLATEPATH="#Request.logpath#index.cfm">
			<!--- CST(49): AXA's signature replacement with specific code --->
			<cfif IsDefined("attributes.LTRCONTENT") AND attributes.LTRCONTENT NEQ "">
                <cfset attributes.LTRCONTENT=#REReplace(attributes.LTRCONTENT,"<!--{PUBLISH}","","ALL")#>
                <cfset attributes.LTRCONTENT=#REReplace(attributes.LTRCONTENT,"{/PUBLISH}-->","","ALL")#>
                <cfset attributes.LTRCONTENT=#REReplace(attributes.LTRCONTENT,"<!--{PREVIEW}-->(.*?)<!--{/PREVIEW}-->","","ALL")#>
                <cfset attributes.LTRCONTENT=#REReplace(attributes.LTRCONTENT,"{{MRM_GETDATE_LONG}}","#request.ds.fn.svcdtdbtoloc(NOW(),0,'dd mmmm yyyy')#","ALL")#>
				<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCgenfile.cfm" LTRCONTENT=#attributes.LTRCONTENT# itender=#attributes.itender# fpath=#TENDER_FILENAME# fext="htm">
			<cfelse>
				<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCgenfile.cfm" templatename=#TENDER_TEMPLATEPATH# fusebox=MTRinsureretender fuseaction=gen_printtowauth itender=#attributes.itender# mode="generate" fpath=#TENDER_FILENAME# fext="htm">
			</cfif>
************ ---->
			<cfif NOT(IsDefined("attributes.itender") AND attributes.itender GT 0 AND IsDefined("attributes.ACTCOSECPOS") AND attributes.ACTCOSECPOS GTE 0)><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid Parameter TOW-WRITEDOC"></cfif>
			<cfif NOT(isdefined("attributes.LTRCONTENT"))>
				<CFSAVECONTENT VARIABLE="TOWCONTENT"><CFMODULE template="#Request.logpath#index.cfm" fusebox="MTRInsureretender" fuseaction="gen_printtowauth" itender=#attributes.itender# mode="generate"></CFSAVECONTENT>
			<cfelse>
				<CFSAVECONTENT VARIABLE="TOWCONTENT"><CFMODULE template="#Request.logpath#index.cfm" fusebox="MTRInsureretender" fuseaction="gen_printtowauth" itender=#attributes.itender# LTRCONTENT=#attributes.LTRCONTENT# mode="generate"></CFSAVECONTENT>
			</cfif>
			<cfquery datasource=#Request.MTRDSN# name=q_tentow>
			SELECT icoid, sitendertype FROM TRX0070 a with (nolock) WHERE a.itender=<cfqueryparam cfsqltype="cf_sql_integer" value=#attributes.itender#>
			</cfquery>
			<cfif q_tentow.sitendertype IS 11><cfset usedocdefid=990><cfelse><cfset usedocdefid=982></cfif>
			<cfif Not(isdefined("session.vars.orgtype")) OR (isdefined("session.vars.orgtype") AND session.vars.orgtype IS "D")> <!--- Follow award --->
				<CFMODULE template="#Request.logpath#index.cfm" FUSEBOX=SVCdoc FUSEACTION=ACT_DOCEDIT NOHEADER
					DOMAINID=2 OBJID=#attributes.itender# LINKID=#attributes.itender# CRTCOROLE=2 DOCDEFID=#usedocdefid#
					DOCSTAT=3 CONTENT=#TOWCONTENT# CRTCOID=#q_tentow.iCOID# USID=1>
			<cfelse>
				<CFMODULE template="#Request.logpath#index.cfm" FUSEBOX=SVCdoc FUSEACTION=ACT_DOCEDIT NOHEADER
					DOMAINID=2 OBJID=#attributes.itender# LINKID=#attributes.itender# CRTCOROLE=2 DOCDEFID=#usedocdefid#
					DOCSTAT=3 CONTENT=#TOWCONTENT#>
			</cfif>
			<CFSET GENDOCID=MODRESULT.DOCID>
			<cfif attributes.ACTCOSECPOS GT 0>
				<!--- grant doc to original workshop --->
				<cfstoredproc PROCEDURE="sspFDOCSetSec" DATASOURCE=#Request.SVCDSN# RETURNCODE=YES>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_docid value=#GENDOCID#>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_usid value=1>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_actcorole value=2>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_bitmask value=8>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_bitset value=8>
				</cfstoredproc>
				<cfset Returncode=CFSTOREDPROC.STATUSCODE>
				<cfif Returncode LT 0>
					<cfthrow TYPE="EX_DBERROR" ErrorCode="MTR/I/TEN/TOWWRITEDOC2(#returncode#)">
				</cfif>
				<!--- grant doc to selected winner --->
				<cfstoredproc PROCEDURE="sspFDOCSetExtSec" DATASOURCE=#Request.SVCDSN# RETURNCODE=YES>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@IDOCID value=#GENDOCID#>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@ICOSECPOS value=#attributes.ACTCOSECPOS#>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@siACCTYPE value=1>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_usid value=1>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@IDOMAINID value=2>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@IOBJID value=#attributes.itender#>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@actCOROLE NULL="YES">
				</cfstoredproc>
				<cfset Returncode=CFSTOREDPROC.STATUSCODE>
				<cfif Returncode LT 0>
					<cfthrow TYPE="EX_DBERROR" ErrorCode="MTR/I/TEN/TOWWRITEDOC1(#returncode#)">
				</cfif>
			</cfif>
		<cfelseif attributes.MODE IS "GETDOC">
			<cfif NOT(IsDefined("attributes.itender") AND attributes.itender GT 0)><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid Parameter TOW-GETDOC"></cfif>
			<cfset TENDER_FILENAME="#FILE_APPEND#TOW#attributes.iTENDER#">
			<!--- <cfset TENDER_TEMPLATEPATH="#Request.logpath#index.cfm"> --->
			<cfif FileExists("#TENDER_FILENAME#.htm")>
		 		<cffile action="read" file="#TENDER_FILENAME#.htm" variable="FILEVAR" charset="UTF-8">
				<cfcontent reset="yes"><cfoutput>#FILEVAR#</cfoutput>
			<cfelse>
				<cfif session.vars.locid IS 1 AND attributes.FILELOCID IS 101><!--- malaysia, pointing on the old path, refer to G$ --->
					<!--- cfset getpath="/HTMReport_Old/">
					<cfset TENDER_FILENAME="#ExpandPath("#getpath#")#TFW/TOW#attributes.iTENDER#" --->
					<!--- <cfset TENDER_FILENAME="\\10.1.1.28\G$\OldReports\Production\TFW/TOW#attributes.iTENDER#"> --->
					<cfset TENDER_FILENAME="#FILE_APPEND#TOW#attributes.iTENDER#">
					<cfif FileExists("#TENDER_FILENAME#.htm")>
				 		<cffile action="read" file="#TENDER_FILENAME#.htm" variable="FILEVAR" charset="UTF-8">
						<cfcontent reset="yes"><cfoutput>#FILEVAR#</cfoutput>
					<cfelse>
						<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid File TOW-GETDOC (OLD)">
					</cfif>
				<cfelse>
					<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid File TOW-GETDOC">
				</cfif>
			</cfif>
		<cfelse>
			<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid MODE-TOW">
		</cfif>
	<CFELSEIF attributes.DOCTYPE IS "DV">
		<!--- DV letter --->
		<cfif attributes.MODE IS "WRITEDOC">
<!---- ************** V1 : last revision on 07/08/2012
			<cfif NOT(isDefined("attributes.iBIDID") AND attributes.iBIDID GT 0 AND IsDefined("attributes.itender") AND attributes.itender GT 0)><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid Parameter AWD-WRITEDOC"></cfif>
			<!--- FILE_APPEND with ".... TFW\" --->
			<cfset TENDER_FILENAME="#FILE_APPEND#AWA#attributes.iTENDER#B#attributes.iBIDID#">
			<cfset TENDER_TEMPLATEPATH="#Request.logpath#index.cfm">
			<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCgenfile.cfm" templatename=#TENDER_TEMPLATEPATH# fusebox=MTRinsureretender fuseaction=gen_printawardletter itender=#attributes.itender# finalized=1 fpath=#TENDER_FILENAME# fext="htm">
************ ---->
			<cfif NOT(IsDefined("attributes.itender") AND attributes.itender GT 0 AND IsDefined("attributes.ACTCOSECPOS") AND attributes.ACTCOSECPOS GTE 0)><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid Parameter DV-WRITEDOC"></cfif>
			<cfquery datasource=#Request.MTRDSN# name=q_tenawd>
			SELECT icoid,siadjtenderstat,iadjcoid FROM TRX0070 a with (nolock) WHERE a.itender=<cfqueryparam cfsqltype="cf_sql_integer" value=#attributes.itender#>
			</cfquery>
			<CFSAVECONTENT VARIABLE="DVCONTENT"><CFMODULE template="#Request.logpath#index.cfm" fusebox="MTRInsureretender" fuseaction="gen_printDVletter" itender=#attributes.itender#></CFSAVECONTENT>
			<cfif Not(isdefined("session.vars.orgtype")) OR (isdefined("session.vars.orgtype") AND session.vars.orgtype IS "D")>
				<CFMODULE template="#Request.logpath#index.cfm" FUSEBOX=SVCdoc FUSEACTION=ACT_DOCEDIT NOHEADER
					DOMAINID=2 OBJID=#attributes.itender# LINKID=#attributes.itender# CRTCOROLE=2 DOCDEFID=1201371 CRTCOID=#q_tenawd.icoid#
					DOCSTAT=3 CONTENT=#DVCONTENT# USID=1>
			<cfelse>
				<CFMODULE template="#Request.logpath#index.cfm" FUSEBOX=SVCdoc FUSEACTION=ACT_DOCEDIT NOHEADER
					DOMAINID=2 OBJID=#attributes.itender# LINKID=#attributes.itender# CRTCOROLE=2 DOCDEFID=1201371 CRTCOID=#q_tenawd.icoid#
					DOCSTAT=3 CONTENT=#DVCONTENT#>
			</cfif>
			<CFSET GENDOCID=MODRESULT.DOCID>
			<cfif attributes.ACTCOSECPOS GT 0>
				<!--- grant doc to selected winner --->
				<cfstoredproc PROCEDURE="sspFDOCSetExtSec" DATASOURCE=#Request.SVCDSN# RETURNCODE=YES>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@IDOCID value=#GENDOCID#>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@ICOSECPOS value=#attributes.ACTCOSECPOS#>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@siACCTYPE value=1>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_usid value=1>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@IDOMAINID value=2>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@IOBJID value=#attributes.itender#>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@actCOROLE NULL="YES">
				</cfstoredproc>
				<cfset Returncode=CFSTOREDPROC.STATUSCODE>
				<cfif Returncode LT 0>
					<cfthrow TYPE="EX_DBERROR" ErrorCode="MTR/I/TEN/DVWRITEDOC(#returncode#)">
				</cfif>
			</cfif>
			<cfif q_tenawd.iadjcoid GT 0 AND q_tenawd.siadjtenderstat IS 50>
				<!--- grant doc to adjuster --->
				<cfstoredproc PROCEDURE="sspFDOCSetSec" DATASOURCE=#Request.SVCDSN# RETURNCODE=YES>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_docid value=#GENDOCID#>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_usid value=1>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_actcorole NULL="YES">
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_bitmask value=4>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_bitset value=4>
				</cfstoredproc>
				<cfset Returncode=CFSTOREDPROC.STATUSCODE>
				<cfif Returncode LT 0>
					<cfthrow TYPE="EX_DBERROR" ErrorCode="MTR/I/TEN/DVWRITEDOC-ADJ(#returncode#)">
				</cfif>
			</cfif>
		<cfelseif attributes.MODE IS "GETDOC">
			<!--- get the file via the old framework --->
			<cfif NOT(isDefined("attributes.iBIDID") AND attributes.iBIDID GT 0 AND IsDefined("attributes.itender") AND attributes.itender GT 0)><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid Parameter DV-GETDOC"></cfif>
			<cfset TENDER_FILENAME="#FILE_APPEND#AWA#attributes.iTENDER#B#attributes.iBIDID#">
			<!--- <cfset TENDER_TEMPLATEPATH="#Request.logpath#index.cfm"> --->
			<cfif FileExists("#TENDER_FILENAME#.htm")>
		 		<cffile action="read" file="#TENDER_FILENAME#.htm" variable="FILEVAR" charset="UTF-8">
				<cfcontent reset="yes"><cfoutput>#FILEVAR#</cfoutput>
			<cfelse>
				<cfif session.vars.locid IS 1 AND attributes.FILELOCID IS 101><!--- malaysia, pointing on the old path, refer to G$ --->
					<!--- cfset getpath="/HTMReport_Old/">
					<cfset TENDER_FILENAME="#ExpandPath("#getpath#")#TFW/AWA#attributes.iTENDER#B#attributes.iBIDID#" --->
					<!--- <cfset TENDER_FILENAME="\\10.1.1.28\G$\OldReports\Production\TFW/AWA#attributes.iTENDER#B#attributes.iBIDID#"> --->
					<cfset TENDER_FILENAME="#FILE_APPEND#AWA#attributes.iTENDER#B#attributes.iBIDID#">
					<cfif FileExists("#TENDER_FILENAME#.htm")>
				 		<cffile action="read" file="#TENDER_FILENAME#.htm" variable="FILEVAR" charset="UTF-8">
						<cfcontent reset="yes"><cfoutput>#FILEVAR#</cfoutput>
					<cfelse>
						<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid File DV-GETDOC (OLD)">
					</cfif>
				<cfelse>
					<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid File DV-GETDOC">
				</cfif>
			</cfif>
		<cfelse>
			<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid MODE-DV">
		</cfif>
	<!--- Tax Invoice --->
	<CFELSEIF attributes.DOCTYPE IS "TAX">
		<cfif attributes.MODE IS "WRITEDOC">
			<cfif NOT(IsDefined("attributes.itender") AND attributes.itender GT 0 AND IsDefined("attributes.ACTCOSECPOS") AND attributes.ACTCOSECPOS GTE 0)><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid Parameter TAX-WRITEDOC"></cfif>
			<cfif NOT(isdefined("attributes.LTRCONTENT"))><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid Parameter TAX-LTRCONTENT"></cfif>
			<CFMODULE template="#Request.logpath#index.cfm" FUSEBOX=SVCdoc FUSEACTION=ACT_DOCEDIT NOHEADER
				DOMAINID=2 OBJID=#attributes.itender# LINKID=#attributes.itender# CRTCOROLE=2 DOCDEFID=985
				DOCSTAT=3 CONTENT=#attributes.LTRCONTENT#>
			<CFSET GENDOCID=MODRESULT.DOCID>
			<cfif attributes.ACTCOSECPOS GT 0>
				<!--- grant doc to original workshop --->
				<!---
				<cfstoredproc PROCEDURE="sspFDOCSetSec" DATASOURCE=#Request.SVCDSN# RETURNCODE=YES>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_docid value=#GENDOCID#>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_usid value=1>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_actcorole value=2>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_bitmask value=8>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_bitset value=8>
				</cfstoredproc>
				<cfset Returncode=CFSTOREDPROC.STATUSCODE>
				<cfif Returncode LT 0>
					<cfthrow TYPE="EX_DBERROR" ErrorCode="MTR/I/TEN/TAXWRITEDOC2(#returncode#)">
				</cfif>
				 --->
				<!--- grant doc to selected winner --->
				<cfstoredproc PROCEDURE="sspFDOCSetExtSec" DATASOURCE=#Request.SVCDSN# RETURNCODE=YES>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@IDOCID value=#GENDOCID#>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@ICOSECPOS value=#attributes.ACTCOSECPOS#>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@siACCTYPE value=1>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_usid value=1>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@IDOMAINID value=2>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@IOBJID value=#attributes.itender#>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@actCOROLE NULL="YES">
				</cfstoredproc>
				<cfset Returncode=CFSTOREDPROC.STATUSCODE>
				<cfif Returncode LT 0>
					<cfthrow TYPE="EX_DBERROR" ErrorCode="MTR/I/TEN/TAXWRITEDOC1(#returncode#)">
				</cfif>
			</cfif>
		<cfelseif attributes.MODE IS "GETDOC">
			<cfif NOT(IsDefined("attributes.itender") AND attributes.itender GT 0)><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid Parameter TAX-GETDOC"></cfif>
			<cfset TENDER_FILENAME="#FILE_APPEND#TAX#attributes.iTENDER#">
			<!--- <cfset TENDER_TEMPLATEPATH="#Request.logpath#index.cfm"> --->
			<cfif FileExists("#TENDER_FILENAME#.htm")>
		 		<cffile action="read" file="#TENDER_FILENAME#.htm" variable="FILEVAR" charset="UTF-8">
				<cfcontent reset="yes"><cfoutput>#FILEVAR#</cfoutput>
			<cfelse>
				<cfif session.vars.locid IS 1 AND attributes.FILELOCID IS 101><!--- malaysia, pointing on the old path, refer to G$ --->
					<!--- cfset getpath="/HTMReport_Old/">
					<cfset TENDER_FILENAME="#ExpandPath("#getpath#")#TFW/TAX#attributes.iTENDER#" --->
					<!--- <cfset TENDER_FILENAME="\\10.1.1.28\G$\OldReports\Production\TFW/TAX#attributes.iTENDER#"> --->
					<cfset TENDER_FILENAME="#FILE_APPEND#TAX#attributes.iTENDER#">
					<cfif FileExists("#TENDER_FILENAME#.htm")>
				 		<cffile action="read" file="#TENDER_FILENAME#.htm" variable="FILEVAR" charset="UTF-8">
						<cfcontent reset="yes"><cfoutput>#FILEVAR#</cfoutput>
					<cfelse>
						<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid File TAX-GETDOC (OLD)">
					</cfif>
				<cfelse>
					<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid File TAX-GETDOC">
				</cfif>
			</cfif>
		<cfelse>
			<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid MODE-TAX">
		</cfif>
	<!--- Tax credit note --->
	<CFELSEIF attributes.DOCTYPE IS "TAXCRNOTE">
		<cfif attributes.MODE IS "WRITEDOC">
			<cfif NOT(IsDefined("attributes.itender") AND attributes.itender GT 0 AND IsDefined("attributes.ACTCOSECPOS") AND attributes.ACTCOSECPOS GTE 0)><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid Parameter TAXCRNOTE-WRITEDOC"></cfif>
			<cfif NOT(isdefined("attributes.LTRCONTENT"))><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid Parameter TAXCRNOTE-LTRCONTENT"></cfif>
			<cfif Not(isdefined("session.vars.orgtype")) OR (isdefined("session.vars.orgtype") AND session.vars.orgtype IS "D")>
				<CFMODULE template="#Request.logpath#index.cfm" FUSEBOX=SVCdoc FUSEACTION=ACT_DOCEDIT NOHEADER
					DOMAINID=2 OBJID=#attributes.itender# LINKID=#attributes.itender# CRTCOROLE=2 DOCDEFID=986
					DOCSTAT=3 CONTENT=#attributes.LTRCONTENT# USID=1>
			<cfelse>
				<CFMODULE template="#Request.logpath#index.cfm" FUSEBOX=SVCdoc FUSEACTION=ACT_DOCEDIT NOHEADER
					DOMAINID=2 OBJID=#attributes.itender# LINKID=#attributes.itender# CRTCOROLE=2 DOCDEFID=986
					DOCSTAT=3 CONTENT=#attributes.LTRCONTENT#>
			</cfif>
			<CFSET GENDOCID=MODRESULT.DOCID>
			<cfif attributes.ACTCOSECPOS GT 0>
				<!--- grant doc to original workshop --->
				<!---
				<cfstoredproc PROCEDURE="sspFDOCSetSec" DATASOURCE=#Request.SVCDSN# RETURNCODE=YES>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_docid value=#GENDOCID#>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_usid value=1>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_actcorole value=2>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_bitmask value=8>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_bitset value=8>
				</cfstoredproc>
				<cfset Returncode=CFSTOREDPROC.STATUSCODE>
				<cfif Returncode LT 0>
					<cfthrow TYPE="EX_DBERROR" ErrorCode="MTR/I/TEN/TAXWRITEDOC2(#returncode#)">
				</cfif>
				 --->
				<!--- grant doc to selected winner --->
				<cfstoredproc PROCEDURE="sspFDOCSetExtSec" DATASOURCE=#Request.SVCDSN# RETURNCODE=YES>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@IDOCID value=#GENDOCID#>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@ICOSECPOS value=#attributes.ACTCOSECPOS#>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@siACCTYPE value=1>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@i_usid value=1>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@IDOMAINID value=2>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@IOBJID value=#attributes.itender#>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER DBVARNAME=@actCOROLE NULL="YES">
				</cfstoredproc>
				<cfset Returncode=CFSTOREDPROC.STATUSCODE>
				<cfif Returncode LT 0>
					<cfthrow TYPE="EX_DBERROR" ErrorCode="MTR/I/TEN/TAXCRNOTE-WRITEDOC1(#returncode#)">
				</cfif>
			</cfif>
		<cfelseif attributes.MODE IS "GETDOC">
			<cfif NOT(IsDefined("attributes.itender") AND attributes.itender GT 0)><cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid Parameter TAXCRNOTE-GETDOC"></cfif>
			<cfset TENDER_FILENAME="#FILE_APPEND#TAX#attributes.iTENDER#">
			<!--- <cfset TENDER_TEMPLATEPATH="#Request.logpath#index.cfm"> --->
			<cfif FileExists("#TENDER_FILENAME#.htm")>
		 		<cffile action="read" file="#TENDER_FILENAME#.htm" variable="FILEVAR" charset="UTF-8">
				<cfcontent reset="yes"><cfoutput>#FILEVAR#</cfoutput>
			<cfelse>
				<cfif session.vars.locid IS 1 AND attributes.FILELOCID IS 101><!--- malaysia, pointing on the old path, refer to G$ --->
					<!--- cfset getpath="/HTMReport_Old/">
					<cfset TENDER_FILENAME="#ExpandPath("#getpath#")#TFW/TAX#attributes.iTENDER#" --->
					<!--- <cfset TENDER_FILENAME="\\10.1.1.28\G$\OldReports\Production\TFW/TAX#attributes.iTENDER#"> --->
					<cfset TENDER_FILENAME="#FILE_APPEND#TAX#attributes.iTENDER#">
					<cfif FileExists("#TENDER_FILENAME#.htm")>
				 		<cffile action="read" file="#TENDER_FILENAME#.htm" variable="FILEVAR" charset="UTF-8">
						<cfcontent reset="yes"><cfoutput>#FILEVAR#</cfoutput>
					<cfelse>
						<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid File TAXCRNOTE-GETDOC (OLD)">
					</cfif>
				<cfelse>
					<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid File TAXCRNOTE-GETDOC">
				</cfif>
			</cfif>
		<cfelse>
			<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid MODE-TAXCRNOTE">
		</cfif>
	<CFELSE>
		<cfthrow TYPE=EX_SECFAILED ErrorCode="BADPARAM" ExtendedInfo="Invalid TAXCRNOTE-DOCTYPE">
	</cfif>
</cfif>

<!--- return value --->
<cfset "Caller.#Attributes.VARMODRESULT#.FILELOCID"=#attributes.FILELOCID#>
<cfset "Caller.#Attributes.VARMODRESULT#.DOCID"=#GENDOCID#>
