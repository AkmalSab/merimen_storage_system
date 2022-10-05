<!--- 
Gets the list of child companies applicable. Takes into
consideration URL.BR for branch filtering.

Attributes:
BR: Branch-list (from URL)
DEFBR: If DEFBR=1 and BR not found, by default take ORGID*, otherwise ORGID only
ShowSelector: Shows BR selector if exist and not 0

Return Values : 
Caller.Colist: List of all child COIDs applicable
---><cfsilent>
<CFPARAM NAME=Attributes.USEPANELLIST DEFAULT=0>
<CFPARAM NAME=Attributes.USECONAME DEFAULT=0>

<cfif Not IsDefined("SESSION.VARS.ORGID")>
	<cfthrow TYPE="EX_SECFAILED" ErrorCode="NOLOGIN">
</cfif>
<cfset orgid=SESSION.VARS.ORGID><cfset DEFBRCODE=orgid><CFSET BRLISTSTR="">
<!---CFIF orgid IS 3556>
	<!--- Hardcode to USEPANELLIST and refresh list dynamically for now. This whole section should be moved to setappvars --->
	<CFSET Attributes.USEPANELLIST=1>
	<CFSET PNLLIST="3556,"&Request.DS.CO[1424].CHCOLIST&","&Request.DS.CO[587].CHCOLIST>
	<CFSET PNLLIST_JS=PNLLIST>
	<CFSET PNLLISTSTR=",#orgid#,'All',0">
	<CFLOOP LIST=#Request.DS.CO[1424].CHCOLIST# INDEX=idx><CFSET CO=Request.DS.CO[idx]><CFSET PNLLISTSTR=PNLLISTSTR&",#idx#,'#JSStringFormat(CO.COBRNAME)#',#CO.HIERARCHY+1#"></CFLOOP>
	<CFLOOP LIST=#Request.DS.CO[587].CHCOLIST# INDEX=idx><CFSET CO=Request.DS.CO[idx]><CFSET PNLLISTSTR=PNLLISTSTR&",#idx#,'#JSStringFormat(CO.COBRNAME)#',#CO.HIERARCHY+1#"></CFLOOP>
	<CFQUERY NAME=q_pnl DATASOURCE=#Request.MTRDSN#>
	SELECT a.iPNLCOID,CONAME=b.vaCONAME+' ('+b.vaCOBRNAME+')'
	FROM TRX0030 a WITH (NOLOCK),SEC0005 b WHERE a.iCOID=<cfqueryparam value="#orgid#" cfsqltype="CF_SQL_INTEGER"> AND a.siPNLSTAT=1 AND a.siSTATUS=0 AND a.iPNLCOID=b.iCOID
	</CFQUERY>
	<CFSET PNLSTRUCT=StructNew()>
	<CFIF q_pnl.recordcount GT 0>
		<CFSET PNLLIST_JS=ListAppend(PNLLIST_JS,"PNL")>
		<CFSET PNLLISTSTR=ListAppend(PNLLISTSTR,"'PNL','Panel',1")>
		<CFLOOP query=q_pnl><CFSET StructInsert(PNLSTRUCT,iPNLCOID,CONAME)><CFSET PNLLIST_JS=ListAppend(PNLLIST_JS,"P"&iPNLCOID)><CFSET PNLLIST=ListAppend(PNLLIST,iPNLCOID)><CFSET PNLLISTSTR=ListAppend(PNLLISTSTR,"'P#iPNLCOID#','#JSStringFormat(CONAME)#',2")></CFLOOP>
	</CFIF>
	<CFSET Request.DS.CO[3556].PNLSTRUCT=PNLSTRUCT>
	<CFSET Request.DS.CO[3556].PNLLIST=PNLLIST>
	<CFSET Request.DS.CO[3556].PNLLIST_JS=PNLLIST_JS>
	<CFSET Request.DS.CO[3556].PNLLISTSTR=PNLLISTSTR>
</CFIF--->
<cfscript>
    TheObject = createObject("component", "#Request.APPPATHCFC#claims.cfc.WSfunctions");
</cfscript>
<cfset SSORESULT = "">
<cfset SSOID = "">
<cfif SESSION.VARS.ORGID IS 640000>
	<cfquery name="get_sso_dtls" datasource="#Request.MTRDSN#">
		SELECT vaSSOUSID FROM SEC0001 A WITH (NOLOCK)
		INNER JOIN FSSO_USER B WITH (NOLOCK) ON A.iUSID=B.iUSID
		WHERE A.iCOID = <cfqueryparam value="#SESSION.VARS.ORGID#" cfsqltype="CF_SQL_INTEGER"> AND A.vaUSID = <cfqueryparam value="#SESSION.VARS.USERID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfset SSOID = #get_sso_dtls.vaSSOUSID#>
	
	<cfif SSOID NEQ "">
		<cfset SSORESULT = TheObject.BRANCHLOGINACCESS("#SSOID#")>
	</cfif>
</cfif>

<cfif SSORESULT IS NOT "">
	<cfset resultxml = XMLParse(SSORESULT)>
	<cfset xmlrecord = resultxml.RESULT>
	<cfset COIDLIST = xmlrecord.COID.XmlText>
	<CFIF #RIGHT(COIDLIST,1)# IS ",">
		<CFSET COIDLIST = LEFT(COIDLIST,(LEN(COIDLIST)-1))>
	</CFIF>
</cfif>

<CFSET PNLLIST_ACTIVE=0>
<CFIF Attributes.USEPANELLIST IS 1>
	<CFIF StructKeyExists(Request.DS.CO,orgid) AND StructKeyExists(Request.DS.CO[orgid],"PNLLIST")>
		<cfif IsDefined("Attributes.DEFBR") AND Attributes.DEFBR IS 1>
			<cfset DEFBRCODE=ORGID&"*">
		</cfif>
		<CFSET PNLLIST_ACTIVE=1>
		<cfset EFFCHCOLIST=Request.DS.CO[orgid].PNLLIST>
		<cfset EFFCHCOLIST_JS=Request.DS.CO[orgid].PNLLIST_JS>
		<cfset BRLISTSTR=Request.DS.CO[orgid].PNLLISTSTR>
		<cfset PNLSTRUCT=Request.DS.CO[orgid].PNLSTRUCT>
	<CFELSE>
		<cfset CALLER.COLIST=orgid>
		<cfset CALLER.COLISTNAME="">
		<cfexit METHOD=EXITTEMPLATE>
	</CFIF>
<CFELSE>
	<cfif SESSION.VARS.CHILDCOACCESS IS 1 AND StructKeyExists(Request.DS.CO,orgid) AND StructKeyExists(Request.DS.CO[orgid],"CHCOLIST")>
		<cfif IsDefined("Attributes.DEFBR") AND Attributes.DEFBR IS 1>
			<cfset DEFBRCODE=ORGID&"*">
		</cfif>
		<cfset EFFCHCOLIST=Request.DS.CO[orgid].CHCOLIST>
		<cfset EFFCHCOLIST_JS=EFFCHCOLIST>
		<cfif EFFCHCOLIST IS orgid>
			<cfset CALLER.COLIST=orgid>
			<cfset CALLER.COLISTNAME="">
			<cfexit METHOD=EXITTEMPLATE>
		</cfif>
	<cfelse>
		<cfif SSORESULT IS NOT "">
			<cfset CALLER.COLIST=COIDLIST>
			<cfset CALLER.COLISTNAME="">
		<cfelse>
			<cfset CALLER.COLIST=orgid>
			<cfset CALLER.COLISTNAME="">
			<cfexit METHOD=EXITTEMPLATE>
		</cfif>
	</cfif>
</CFIF>

<cfif Request.DS.FN.SVCGetCGIAttr(CGI.QUERY_STRING,"BR") NEQ "">
	<cfset BR=TRIM(REReplace(URLDecode(Request.DS.FN.SVCGetCGIAttr(CGI.QUERY_STRING,'BR')), "[^0-9,*-]", "", "all"))>

	<!--- <cfif BR IS "">
		<cfset BR=DEFBRCODE>
	<cfelse>
		<!--- list check start --->
		<cfif ListLen(BR) GT 0>
			<cfloop list="#BR#" index="i">
				<cfif #Request.DS.CO[REReplace(i, "[^\w\sa-zA-Z_]", "", "ALL")].GCOID# NEQ SESSION.VARS.GCOID>						
				</cfif>
			</cfloop>
		</cfif>
		<!--- list check end --->
	</cfif> --->

<cfelse>
	<cfset BR=DEFBRCODE>
</cfif>

<!--- <cfif StructKeyExists(URL,"BR")>
	<cfset BR=Trim(URL.BR)>
	<cfif BR IS ""><cfset BR=DEFBRCODE></cfif>
<cfelse>
	<cfset BR=DEFBRCODE>
</cfif> --->
<!---
	KEYS
	----
	Let say user selected: HQ*,IPOH,MELAKA-

	CALLER.COLISTNAME = SELCODISP = Cleaned & checked string for DISPLAY of branch selection, e.g. HQ*,IPOH,MELAKA-
	CALLER.COLIST = SELCOLIST = Cleaned & checked list of all COIDs in branch selection e.g. 4,25,123,456,675,2341,1233
		(SELCOSTRUCT = Temporary struct to generate SELCOLIST, just to check and remove if COID is specified twice)
	CALLER.SELCOLIST_JS	= Same like SELCOLIST, but keep tracks of if any of the COID is a Panel selection e.g.
					4,25,123,P456,P675,2341,1233. Used in JS to highlight the checkbox

--->

<!--- START #39239: [MY] TMIM - Motor - Agent Module - SSO Web Service URL and authentication --->
<cfif SSORESULT IS NOT "">
	<cfset resultxml = XMLParse(SSORESULT)>
	<cfset xmlrecord = resultxml.RESULT>
	<cfset COIDLIST = xmlrecord.COID.XmlText>
	<cfset filteredList = "">
	<CFIF #RIGHT(COIDLIST,1)# IS ",">
		<CFSET COIDLIST = LEFT(COIDLIST,(LEN(COIDLIST)-1))>
		<cfif findNoCase('-',BR) GT 0>
			<cfloop list="#COIDLIST#" index="i">
				<cfif NOT listContains(BR,i&"-") GT 0>
					<cfset filteredList = listAppend(filteredList,i)>
				</cfif>
			</cfloop>
		<cfelseif findNoCase(',',BR) GT 0>
			<cfloop list="#COIDLIST#" index="i">
				<cfif listContains(BR,i) GT 0>
					<cfset filteredList = listAppend(filteredList,i)>
				</cfif>
			</cfloop>
		<cfelseif listLen(BR) IS 1 and listContains(COIDLIST,BR) GT 0>
			<cfset filteredList = BR>
		<cfelse>
			<cfset filteredList = COIDLIST>
		</cfif>
		<CFSET BR = filteredList>
		<CFSET EFFCHCOLIST_JS = COIDLIST>
		<CFSET SELCOLIST_JS="">
	</CFIF>
	<CFSET Attributes.USECONAME = 1>
</cfif>
<!--- END #39239: [MY] TMIM - Motor - Agent Module - SSO Web Service URL and authentication --->

<CFSET suffix="">
<CFSET SELCODISPLIST="">

<cfif BR IS ORGID>
	<!--- For efficiency - these are the most common configs --->
	<cfset SELCODISP=Request.DS.CO[ORGID].COBRNAME>
	<cfset SELCOLIST=ORGID><CFSET SELCOLIST_JS=SELCOLIST>
	<cfset CALLER.COLIST=ORGID>
	<cfset CALLER.COLISTNAME=SELCODISP>
<cfelseif BR IS ORGID&"*">
	<!--- For efficiency - these are the most common configs --->
	<cfset SELCODISP=Request.DS.CO[ORGID].COBRNAME&"*">
	<CFSET suffix="*">
	<cfset SELCOLIST=EFFCHCOLIST><CFSET SELCOLIST_JS=EFFCHCOLIST_JS>
	<cfset CALLER.COLIST=SELCOLIST>
	<cfset CALLER.COLISTNAME=SELCODISP>
<cfelseif BR IS ORGID&"-">
	<!--- For efficiency - these are the most common configs --->
	<cfset SELCODISP=Request.DS.CO[ORGID].COBRNAME&"-">
	<CFSET suffix="-">
	<cfset SELCOLIST=ListRest(EFFCHCOLIST)><CFSET SELCOLIST_JS=ListRest(EFFCHCOLIST_JS)>
	<cfset CALLER.COLIST=SELCOLIST>
	<cfset CALLER.COLISTNAME=SELCODISP>
<cfelse>
	<CFSET SELCOSTRUCT=StructNew()><CFSET SELCOLIST_JS=""><cfset SELCODISP="">
	<cfloop LIST=#BR# INDEX=idx>
	<cfif Len(idx) GT 0>
		<CFSET toadd=""><CFSET toadd_js="">
		<cfset mrk=Right(idx,1)>
		<cfif (mrk IS "*" OR mrk IS "-")>
			<cfset idx=Left(idx,Len(idx)-1)>
		<cfelse>
			<cfset mrk="">
		</cfif>
		<CFIF idx IS "PNL">
			<!---	The key PNL is special it denotes adding all in the panelstruct.
					PNL* = PNL- since PNL alone does not mean anything
				 --->
			<CFIF PNLLIST_ACTIVE IS 1 AND (mrk IS "*" OR mrk IS "-")>
				<cfset SELCODISP=ListAppend(SELCODISP,"PNL*")>
				<CFSET SELCOLIST_JS=ListAppend(SELCOLIST_JS,"PNL")>
				<CFLOOP collection=#PNLSTRUCT# item=i2>
					<CFIF Not StructKeyExists(SELCOSTRUCT,i2)>
						<CFSET SELCOSTRUCT[i2]=1>
						<CFSET SELCOLIST_JS=ListAppend(SELCOLIST_JS,"P"&i2)>
					</CFIF>
				</CFLOOP>
			</CFIF>
		<CFELSEIF ListFind(EFFCHCOLIST_JS,idx) GT 0>
			<!--- Below important: it is also a security check and cannot be moved to js --->
			<CFIF Left(idx,1) IS "P">
				<CFIF PNLLIST_ACTIVE IS 1 AND Len(idx) GT 1>
					<CFSET idx=Right(idx,Len(idx)-1)>
					<CFIF StructKeyExists(PNLSTRUCT,idx) AND Not StructKeyExists(SELCOSTRUCT,idx)>
						<CFSET SELCOSTRUCT[idx]=1>
						<CFSET SELCOLIST_JS=ListAppend(SELCOLIST_JS,"P"&idx)>
						<cfset SELCODISP=ListAppend(SELCODISP,PNLSTRUCT[idx])>
					</CFIF>
				</CFIF>
			<CFELSEIF StructKeyExists(Request.DS.CO,idx)>
				<CFIF mrk IS "">
					<CFIF Not StructKeyExists(SELCOSTRUCT,idx)>
						<CFSET SELCOSTRUCT[idx]=1>
						<CFSET SELCOLIST_JS=ListAppend(SELCOLIST_JS,idx)>
						<cfset SELCODISP=ListAppend(SELCODISP,Request.DS.CO[idx].COBRNAME)>
						<CFSET SELCODISPLIST=ListAppend(SELCODISPLIST,Request.DS.CO[idx].CONAME)>
					</CFIF>
				<cfelseif mrk IS "*" OR mrk IS "-">
					<CFIF mrk IS "*">
						<cfset toadd=Request.DS.CO[idx].CHCOLIST>
					<CFELSE>
						<cfset toadd=ListRest(Request.DS.CO[idx].CHCOLIST)>
					</CFIF>
					<cfset SELCODISP=ListAppend(SELCODISP,Request.DS.CO[idx].COBRNAME&mrk)>
					<CFSET SELCODISPLIST=ListAppend(SELCODISPLIST,Request.DS.CO[idx].CONAME&mrk)>
					<CFLOOP LIST="#toadd#" INDEX=i2>
						<CFIF Not StructKeyExists(SELCOSTRUCT,i2)>
							<CFSET SELCOSTRUCT[i2]=1>
							<CFSET SELCOLIST_JS=ListAppend(SELCOLIST_JS,i2)>
						</CFIF>
					</CFLOOP>
				</cfif>
			</CFIF>
		</CFIF>
	</cfif>
	</cfloop>
	<CFSET SELCOLIST=StructKeyList(SELCOSTRUCT)>
	<CFIF SELCOLIST IS "">
		<cfset CALLER.COLIST=ORGID>
		<CFSET SELCODISP=Request.DS.CO[ORGID].COBRNAME>
		<cfset CALLER.COLISTNAME=SELCODISP>
	<CFELSE>
		<cfset CALLER.COLIST=SELCOLIST>
		<cfset CALLER.COLISTNAME=SELCODISP>
	</CFIF>
</cfif>

<CFIF Attributes.USECONAME IS 1>
	<CFIF LEN(SELCODISPLIST) GT 0>
		<cfset SELCODISP=SELCODISPLIST>
	<CFELSE>
		<cfset SELCODISP=Request.DS.CO[ORGID].CONAME&suffix>
	</CFIF>
</CFIF>

<cfparam NAME=Attributes.ShowSelector DEFAULT=0>
</cfsilent>
<cfif Attributes.SHOWSELECTOR IS NOT 0>
	<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCADDFILE.cfm" FNAME="SVCCOSELECTOR">
	<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCADDFILE.cfm" FNAME="SVCTAB">
	<script>
	<CFOUTPUT>var SVCobjclms=new SVCCOSelector("SVCobjclms","MTRCOContextMenu",request.webroot+"common/","70ex",
		<CFIF BRLISTSTR IS NOT "">
			new Array(0#BRLISTSTR#),
		<CFELSE>
			new Array(0<CFLOOP LIST=#EFFCHCOLIST_JS# INDEX=idx><CFSET CO=Request.DS.CO[idx]>,#idx#,<CFIF Attributes.USECONAME IS 0>'#JSStringFormat(CO.COBRNAME)#'<CFELSE>'#JSStringFormat(CO.CONAME)#'</CFIF>,#CO.HIERARCHY#</CFLOOP>),
		</CFIF>
		',#selcolist_js#,','#JSStringFormat(BR)#','#JSStringFormat(DEFBRCODE)#','#JSStringFormat(SELCODISP)#'
		<!--- Start #33126 kofam --->
		<CFIF SESSION.VARS.LOCID IS 11 AND SESSION.vars.ORGTYPE IS 'G'>
		,null,null,'#Server.SVClang("Select Agent")#','#Server.SVClang("Confirm",8708)#','#Server.SVClang("AIG GROUP")#','800px'
		<!--- End #33126 kofam --->
		<CFELSEIF SSORESULT IS NOT "">,null,null,null,null,'Companies',null,1</CFIF>
		);
	</CFOUTPUT>
	</script>
</cfif>