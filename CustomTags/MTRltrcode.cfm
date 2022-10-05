<!--- Attributes:content --->
<cfparam NAME=Attributes.content DEFAULT="">
<cfparam NAME=Attributes.MODRESULT DEFAULT="MODRESULT">
<cfparam name=attributes.caseid default=0>
<cfparam name=attributes.actflag default=0><!--- bit 1 : get the running number for DVNONMT (DV no for non-motor) --->
<cfparam name=attributes.usid default=#session.vars.usid#>
<cfif NOT(attributes.caseid GT 0)>
	<CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADPARAM">
</cfif>

<CFQUERY NAME=q_trx DATASOURCE=#Request.MTRDSN#>
SELECT a.icoid, a.vaDVCHRNO, claimtype=RTRIM(b.aclaimtype), a.vaMGRNAME, a.vaOWNER
FROM trx0008 a with (nolock) join trx0001 b with (nolock) on a.icaseid=b.icaseid
where a.icaseid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.caseid#">
</CFQUERY>
<cfif q_trx.recordcount IS 0>
	<CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCASE">
</cfif>
<cfset THIS_DVCHRNO=#q_trx.vaDVCHRNO#>
<cfset THIS_INSGCOID=#request.ds.co[q_trx.icoid].gcoid#>
<cfset claimtype=#q_trx.claimtype#>
<cfset clmflow=left(q_trx.claimtype,2)>

<!--- get the current user identity --->
<CFQUERY NAME=q_usr DATASOURCE=#Request.MTRDSN#>
SELECT vausname, vaDEPT, vadesignation,vasiglogo FROM SEC0001 with (nolock)
WHERE iusid=<cfqueryparam cfsqltype="cf_sql_integer" value=#attributes.usid#>
</CFQUERY>
<cfif q_usr.recordcount IS 0>
	<CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCASE">
</cfif>

<CFQUERY NAME=q_mgr DATASOURCE=#Request.MTRDSN#>
SELECT vausname, vaDEPT, vadesignation,vasiglogo FROM SEC0001 with (nolock)
WHERE vaUSID=<cfqueryparam value="#q_trx.vaMGRNAME#" cfsqltype="CF_SQL_NVARCHAR">
</CFQUERY>
<CFQUERY NAME=q_pic DATASOURCE=#Request.MTRDSN#>
SELECT vausname, vaDEPT, vadesignation,vasiglogo FROM SEC0001 with (nolock)
WHERE vaUSID=<cfqueryparam value="#q_trx.vaOWNER#" cfsqltype="CF_SQL_NVARCHAR">
</CFQUERY>

<cfif attributes.actflag GT 0 AND BITAND(attributes.actflag,1) IS 1 AND TRIM(THIS_DVCHRNO) IS "">
	<cfif NOT(clmflow IS "NM")>
		<CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADPARAM">
	</cfif>
	<CFSTOREDPROC PROCEDURE="sspFSYSReserveRunningID" DATASOURCE=#Request.MTRDSN# RETURNCODE=YES>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#THIS_INSGCOID# DBVARNAME=@ai_coid>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_VARCHAR VALUE="DVNONMT" DBVARNAME=@aa_raname>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE="#attributes.usid#" DBVARNAME=@ai_usid>
		<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_VARCHAR VARIABLE="THIS_DVCHRNO" VALUE="" DBVARNAME=@as_reserved>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=1 DBVARNAME=@ai_domainid>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#attributes.caseid# DBVARNAME=@ai_objid>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_VARCHAR VALUE="" DBVARNAME=@as_remarks>
	</CFSTOREDPROC>
	<cfset returncode=CFSTOREDPROC.StatusCode>
	<cfif returncode LT 0>
		<cfthrow TYPE=EX_DBERROR ErrorCode="MTRLTRCODE1(#returncode#)">
	</cfif>
</cfif>

<cfif attributes.actflag GT 0 AND BITAND(attributes.actflag,2) IS 2>
	<!--- CY #23774: [PH] Malayan - update and show ARR no. while save on Edit Offer Letter/DV screen --->
	<cfstoredproc PROCEDURE="sspUpdateLOANumber" DATASOURCE=#Request.MTRDSN# RETURNCODE="YES">
		<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#Attributes.caseid# DBVARNAME=@ai_caseid>
		<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=1 DBVARNAME=@ai_mode>
		<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#session.vars.usid# DBVARNAME=@ai_usid>
	</cfstoredproc>
	<cfset RETROWS=CFSTOREDPROC.STATUSCODE>
	<cfif RETROWS LT 0>
	    <cfthrow TYPE="EX_DBERROR" ErrorCode="ERROR - LOA NUMBER(#RETROWS#)">
	</cfif>
	<CFQUERY NAME=q_trx2 DATASOURCE=#Request.MTRDSN#>
		SELECT vaARRNO FROM TRX0046 a WITH (NOLOCK) INNER JOIN TRX0008 b WITH (NOLOCK) on a.iINSCASEID=b.iINSCASEID WHERE b.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.caseid#">
	</CFQUERY>
</cfif>

<!--- check signature replacement with specific code --->
<cfset Attributes.content=#REReplace(Attributes.content,"<!--{PUBLISH}","","ALL")#>
<cfset Attributes.content=#REReplace(Attributes.content,"{/PUBLISH}-->","","ALL")#>
<cfset Attributes.content=#REReplace(Attributes.content,"<!--{PREVIEW}-->(.*?)<!--{/PREVIEW}-->","","ALL")#>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_GETDATE_LONG}}","#request.ds.fn.svcdtdbtoloc(NOW(),0,'LONG')#","ALL")#>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_GETDATE_DDMMMMYYYY}}","#request.ds.fn.svcdtdbtoloc(NOW(),0,'dd mmmm yyyy')#","ALL")#>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_GETTIME_12TFTIME}}","#request.ds.fn.svcdtdbtoloc(NOW(),0,'','tt hh:mm')#","ALL")#>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_DVNO}}","#htmleditformat(THIS_DVCHRNO)#","ALL")#>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_CURUSER_NAME}}","#htmleditformat(q_usr.vausname)#","ALL")#>
<cfsavecontent variable="content_curuser_sign"><cfoutput><cfif q_usr.recordcount GT 0 AND q_usr.vasiglogo NEQ ""><IMG SRC="#request.webroot#MSupport/sign/#q_usr.vasiglogo#" vspace=10 height="40px"><cfelse><br><br><br><br></cfif></cfoutput></cfsavecontent>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_CURUSER_SIGN}}","#content_curuser_sign#","ALL")#>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_CURUSER_DESG}}","#htmleditformat(q_usr.vadesignation)#","ALL")#>
<cfsavecontent variable="content_curuser_desgdept"><cfoutput><cfif q_usr.vadesignation NEQ "">#q_usr.vadesignation# - </cfif><cfif q_usr.vaDEPT NEQ "">#q_usr.vaDEPT#<cfelse>Claims Department</cfif></cfoutput></cfsavecontent>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_CURUSER_DESGDEPT}}","#htmleditformat(content_curuser_desgdept)#","ALL")#>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_CURUSER_DEPARTMT}}","#htmleditformat(q_usr.vaDEPT)#","ALL")#>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_MGR_NAME}}","#htmleditformat(q_mgr.vausname)#","ALL")#>
<cfsavecontent variable="content_mgr_sign"><cfoutput><cfif q_mgr.recordcount GT 0 AND q_mgr.vasiglogo NEQ ""><IMG SRC="#request.webroot#MSupport/sign/#q_mgr.vasiglogo#" vspace=10 height="40px"><cfelse><br><br><br><br></cfif></cfoutput></cfsavecontent>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_MGR_SIGN}}","#content_mgr_sign#","ALL")#>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_MGR_DESG}}","#htmleditformat(q_mgr.vadesignation)#","ALL")#>
<cfsavecontent variable="content_mgr_desgdept"><cfif q_mgr.vadesignation NEQ "">#q_mgr.vadesignation# - </cfif><cfif q_mgr.vaDEPT NEQ "">#q_mgr.vaDEPT#<cfelse>Claims Department</cfif></cfsavecontent>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_MGR_DESGDEPT}}","#htmleditformat(content_mgr_desgdept)#","ALL")#>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_MGR_DEPARTMT}}","#htmleditformat(q_mgr.vaDEPT)#","ALL")#>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_PIC_NAME}}","#htmleditformat(q_pic.vausname)#","ALL")#>
<cfsavecontent variable="content_PIC_sign"><cfoutput><cfif q_pic.recordcount GT 0 AND q_pic.vasiglogo NEQ ""><IMG SRC="#request.webroot#MSupport/sign/#q_pic.vasiglogo#" vspace=10 height="40px"><cfelse><br><br><br><br></cfif></cfoutput></cfsavecontent>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_PIC_SIGN}}","#content_PIC_sign#","ALL")#>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_PIC_DESG}}","#htmleditformat(q_pic.vadesignation)#","ALL")#>
<cfsavecontent variable="content_PIC_desgdept"><cfif q_pic.vadesignation NEQ "">#q_pic.vadesignation# - </cfif><cfif q_pic.vaDEPT NEQ "">#q_pic.vaDEPT#<cfelse>Claims Department</cfif></cfsavecontent>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_PIC_DESGDEPT}}","#htmleditformat(content_PIC_desgdept)#","ALL")#>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_PIC_DEPARTMT}}","#htmleditformat(q_pic.vaDEPT)#","ALL")#>
<cfif attributes.actflag GT 0 AND BITAND(attributes.actflag,2) IS 2 AND q_trx2.recordcount GT 0 AND q_trx2.vaARRNO NEQ "">
	<!--- CY #23774: [PH] Malayan - update and show ARR no. while save on Edit Offer Letter/DV screen --->
	<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_ARRNO}}","#htmleditformat(q_trx2.vaARRNO)#","ALL")#>
</cfif>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_GETDATE_DD}}","#request.ds.fn.svcdtdbtoloc(NOW(),0,'dd')#","ALL")#>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_GETDATE_MM}}","#request.ds.fn.svcdtdbtoloc(NOW(),0,'mm')#","ALL")#>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_GETDATE_YYYY}}","#request.ds.fn.svcdtdbtoloc(NOW(),0,'yyyy')#","ALL")#>

<CFIF FindNoCase("{{MRM_medExpCertRunNo}}",Attributes.content)>
	<CFSET CURRUNNO = Request.DS.MTRFN.MTRSompoMedExpCertRunNo(Attributes.caseid,"NEW_RUNNO")>
	<cfset Attributes.content = REReplace(Attributes.content,"{{MRM_medExpCertRunNo}}","#htmleditformat(CURRUNNO)#","ALL")>
</CFIF>

<!---start #36806 --->
<CFIF THIS_INSGCOID IS 1101213 AND LISTFIND("DEV,UAT",Application.DB_MODE)>
    <cfset str = ArrayNew(1)>
    <cfset str[1]="sttl_mapinfo"/>
    <cfset str[2]="sttl_numtothai1"/>
    <cfset str[3]="sttl_numtothai2"/>
    <cfset str[4]="paymt_numtothai_todeduct"/>
	<cfset str[5]="numtothai"/>

    <cfloop from="1" to="#ArrayLen(str)#" index="i">            
        <cfif find('class="#str[i]#"',#Attributes.content#)>
        	<cfset infospan = REMatch('(?s)<span[^>]+class="#str[i]#"[^>]*>(.+?)</span>', Attributes.content)[1]>
        	<!--- remove span tags --->
            <cfset infofromspan=ReReplaceNoCase(#infospan#,"<[^>]*>","","ALL")>

            <!--- convert amount to thai words --->
            <cfif find("numtothai",#str[i]#)>
                <!--- remove blank space --->
                <cfset numtothai=ReReplaceNoCase(#infofromspan#," ","","ALL")>
				<cfset numtothaiNumOrig = rematch("[0-9]+(,[0-9]{3})*(\.[0-9]+)*",numtothai)>
				<CFIF ArrayLen(numtothaiNumOrig) GT 0>
					<cfset numtothaiNum = ReReplaceNoCase(numtothaiNumOrig[1],",","","ALL")>
					<cfset numtothaiNumOrig = numtothaiNumOrig[1]>
				<CFELSE>
					<cfset numtothaiNum = "">
					<cfset numtothaiNumOrig = infofromspan>
				</CFIF>
				<!--- num to thai words --->
				<cfsavecontent variable="thaiwords">
					<cfoutput><cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCMAKENUMBERWORDS.cfm" VALUE="#val(numtothaiNum)#" LANG=LLTHAI></cfoutput>
				</cfsavecontent>
                <cfset thaiwords=ReReplaceNoCase(#thaiwords#," ","","ALL")>
                <cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_#str[i]#}}","#thaiwords#","ALL")#>
				<cfset Attributes.content=#REReplace(Attributes.content,infospan,"#numtothaiNumOrig# ","ALL")#>
            </cfif>

            <!--- map info to display ---> 
            <cfif find("mapinfo",#str[i]#)>
                <cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_sttl_mapinfo}}",infofromspan,"ALL")#>
            </cfif>

            <cfif find("paymt_numtothai_todeduct",#str[i]#)>
                <cfset paymt_bededucted = REMatch('(?s)<span[^>]+class="paymt_bededucted"[^>]*>(.+?)</span>', Attributes.content)[1]>
                <!--- remove span tags --->
                <cfset paymt_bededucted=ReReplaceNoCase(#paymt_bededucted#,"<[^>]*>","","ALL")>
                <!--- remove comma --->
                <cfset paymt_bededucted=ReReplaceNoCase(#paymt_bededucted#,",","","ALL")>
                <!--- remove &nbsp; --->
                <cfset paymt_todeduct=ReReplaceNoCase(#infofromspan#,"&nbsp;","","ALL")>
                <cfset paymt_bededucted=ReReplaceNoCase(#paymt_bededucted#,"&nbsp;","","ALL")>

                <cfif IsNumeric(paymt_todeduct) and IsNumeric(paymt_bededucted)>
                	<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_paymt_deductresult}}","#Request.DS.FN.SVCNum(paymt_todeduct-paymt_bededucted)#","ALL")#>
                <cfelse>
                	<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_paymt_deductresult}}","…………………….…","ALL")#>
                </cfif>
            </cfif> 
        </cfif>
    </cfloop>
</CFIF>
<!---end #36806 --->

<!---cfif THIS_INSGCOID IS 37 AND clmflow IS "NM" OR (THIS_INSGCOID IS 1000615)>
<cfsavecontent variable="signarea"><cfoutput><cfif q_usr.recordcount GT 0 AND q_usr.vasiglogo NEQ ""><IMG SRC="#request.webroot#MSupport/sign/#q_usr.vasiglogo#" vspace=10 height="40px"><cfelse><br><br><br><br></cfif></cfoutput></cfsavecontent>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_CURUSER_SIGN}}","#signarea#","ALL")#>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_CURUSER_DESGDEPT}}","#htmleditformat(q_usr.vadesignation)#","ALL")#>
<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_CURUSER_DEPARTMT}}","#htmleditformat(q_usr.vaDEPT)#","ALL")#>
<cfif THIS_INSGCOID IS 1000615 AND #mgrname# NEQ ''>
	<cfsavecontent variable="signareamgr"><cfoutput><cfif q_mgr.recordcount GT 0 AND q_mgr.vasiglogo NEQ ""><IMG SRC="#request.webroot#MSupport/sign/#q_mgr.vasiglogo#" vspace=10 height="40px"><cfelse><br><br><br><br></cfif></cfoutput></cfsavecontent>
	<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_MGR_NAME}}","#htmleditformat(q_mgr.vausname)#","ALL")#>
	<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_MGR_SIGN}}","#signareamgr#","ALL")#>
	<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_MGR_DESGDEPT}}","#htmleditformat(q_mgr.vadesignation)#","ALL")#>
	<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_MGR_DEPARTMT}}","#htmleditformat(q_mgr.vaDEPT)#","ALL")#>
</cfif>
</cfif>
<cfif THIS_INSGCOID IS 32 AND clmflow IS "NM">
	<!--- custom code for BSI's NM letter/dv --->
	<cfoutput>
	<cfsavecontent variable="thisvar"><cfif q_usr.vadesignation NEQ "">#q_usr.vadesignation# - </cfif><cfif q_usr.vaDEPT NEQ "">#q_usr.vaDEPT#<cfelse>Claims Department</cfif></cfsavecontent>
	</cfoutput>
	<cfset Attributes.content=#REReplace(Attributes.content,"{{MRM_CURUSER_DESGDEPT}}","#htmleditformat(thisvar)#","ALL")#>
</cfif--->

<cfset "Caller.#ATTRIBUTES.MODRESULT#.content"=Attributes.content>
<cfset "Caller.#ATTRIBUTES.MODRESULT#.DVCHRNO"=#THIS_DVCHRNO#>