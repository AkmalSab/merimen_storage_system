<CFSET Attributes.DS.MTRFN=StructNew()>

<cffunction name="MTRGenJSPolicyClass" description="get worksheet configuration for respective caseid" access="public" output="yes">
	<cfargument name="CLMCOID" type="numeric">
	<cfargument name="clmtypemask" type="numeric" default=-1>
	<cfset var CLMGCOID=#Request.ds.co[arguments.CLMCOID].gcoid#>

	<cfquery name="q_polclass" datasource="#Request.MTRDSN#">
	SELECT a.iINSCLASSID,CLSCODE=a.vaCODE,POLCODE=b.vaPOLCODE,BUSCODE=c.vaBUSCODE,a.vaINSCLASSNAME,a.vaINSLOGICNAME,CSTAT=a.siSTATUS,b.iPOLID,b.vaPOLNAME,b.vaPOLLOGICNAME,PSTAT=b.siSTATUS,c.IBUSID,c.vaBUSNAME,c.vaBUSLOGICNAME,BSTAT=c.siSTATUS,CCLMTYPEMASK=a.iCLMTYPEMASK,PCLMTYPEMASK=b.iCLMTYPEMASK,BCLMTYPEMASK=c.iCLMTYPEMASK
	FROM BIZ2010 a WITH (NOLOCK)
	LEFT JOIN BIZ2011 b WITH (NOLOCK) ON a.iINSCLASSID=b.iINSCLASSID AND b.iclmtypemask&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.clmtypemask#"><>0 AND b.sistatus=0
	LEFT JOIN BIZ2012 c WITH (NOLOCK) ON b.iPOLID=c.iPOLID AND c.iclmtypemask&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.clmtypemask#"><>0 AND c.sistatus=0
	WHERE a.iCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CLMGCOID#"> and a.sistatus = 0 and a.iclmtypemask&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.clmtypemask#"><>0
	<!--- CST(3060) filter whether it's insurance/takaful--->
	<cfif Request.ds.co[CLMCOID].GCOID IS 3060>
		<cfif BITAND(Request.ds.co[CLMCOID].SUBCOTYPE,1) NEQ 0><!--- takaful --->
		AND a.vaCODE='ETB'
		<CFELSE><!---takaful --->
		AND a.vaCODE='EIB'
		</cfif>
	</cfif>
	ORDER BY CASE WHEN ISNULL(a.vaCODE,'')='' THEN 1 ELSE 0 END,a.vaCODE,a.vaINSCLASSNAME,
		CASE WHEN ISNULL(b.vaPOLCODE,'')='' THEN 1 ELSE 0 END,b.vaPOLCODE,b.vaPOLNAME,
		CASE WHEN ISNULL(c.vaBUSCODE,'')='' THEN 1 ELSE 0 END,c.vaBUSCODE,c.vaBUSNAME
	</cfquery>
	<!--- script>polclass=[<cfoutput query=q_polclass group="iINSCLASSID">[<cfset idC=iINSCLASSID>#iINSCLASSID#,"<cfif CLSCODE NEQ "">#CLSCODE# - </cfif>#vaINSCLASSNAME#","#vaINSLOGICNAME#",#CSTAT#,[<cfoutput group="iPOLID"><cfif idC IS iINSCLASSID AND iPOLID IS NOT "">[<cfset idP=iPOLID>#iPOLID#,"<cfif POLCODE NEQ "">#POLCODE# - </cfif>#vaPOLNAME#","#vaPOLLOGICNAME#",#PSTAT#,[<cfoutput group="iBUSID"><cfif idP IS iPOLID AND iBUSID IS NOT "">[#iBUSID#,"<cfif BUSCODE NEQ "">#BUSCODE# - </cfif>#vaBUSNAME#","#vaBUSLOGICNAME#",#BSTAT#],</cfif></cfoutput>],],</cfif></cfoutput>],],</cfoutput>];</script --->
	<script>polclass=[<cfoutput query=q_polclass group="iINSCLASSID">[<cfset idC=iINSCLASSID>#iINSCLASSID#,"<cfif CLSCODE NEQ "">#CLSCODE# - </cfif>#JSStringFormat(vaINSCLASSNAME)#","#vaINSLOGICNAME#",#CSTAT#,#cclmtypemask#,[<cfoutput group="iPOLID"><cfif idC IS iINSCLASSID AND iPOLID IS NOT "">[<cfset idP=iPOLID>#iPOLID#,"<cfif POLCODE NEQ "">#POLCODE# - </cfif>#JSStringFormat(vaPOLNAME)#","#vaPOLLOGICNAME#",#PSTAT#,#pclmtypemask#,[<cfoutput group="iBUSID"><cfif idP IS iPOLID AND iBUSID IS NOT "">[#iBUSID#,"<cfif BUSCODE NEQ "">#BUSCODE# - </cfif>#JSStringFormat(vaBUSNAME)#","#vaBUSLOGICNAME#",#BSTAT#,#bclmtypemask#],</cfif></cfoutput>],],</cfif></cfoutput>],],</cfoutput>];</script>
	<cfreturn>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRGenJSPolicyClass=MTRGenJSPolicyClass>

<cffunction name="MTRGetItmGrpID" description="get worksheet configuration for respective caseid" access="public" returntype="struct" output="no">
	<cfargument name="CUR_CASEID" required="true" type="string">
	<cfargument name="CUR_COTYPE" required="true" type="string">
	<cfargument name="CUR_USID" required="true" type="numeric">
	<cfargument name="PROPERTY_MODE" required="false" type="numeric" default=0>
	<cfset var multiws="">
	<!--- return rsID, cur_rsID, cur_igID and cur_currID --->

	<CFSTOREDPROC PROCEDURE="sspESTItmGetRuleset" DATASOURCE=#REQUEST.MTRDSN# RETURNCODE=YES>
	<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#CUR_CASEID# DBVARNAME=@ai_caseid>
	<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_CHAR VALUE=#CUR_COTYPE# DBVARNAME=@aa_cotype>
	<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#CUR_USID# DBVARNAME=@ai_usid>
	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_INTEGER VARIABLE=rsID VALUE=0 DBVARNAME=@ai_rulesetid><!--- ruleid based on latest condition defined --->
    <CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_VARCHAR VARIABLE=rsNAME VALUE="" DBVARNAME=@as_rulesetname>
	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_INTEGER VARIABLE=func_rsID VALUE=0 DBVARNAME=@ai_cur_rulesetid>
	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_INTEGER VARIABLE=func_igID VALUE=0 DBVARNAME=@ai_cur_itmgrpid>
	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_INTEGER VARIABLE=func_currID VALUE=0 DBVARNAME=@ai_cur_currencyid>
	<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_VARCHAR VARIABLE=func_rsNAME VALUE="" DBVARNAME=@as_cur_rulesetname>
	<!--- allan: this param is not required, but has specify VN TP PD to respective rulesetname instead of relying on this param: CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#PROPERTY_MODE# DBVARNAME=@ai_property_mode --->
	</cfstoredproc>
	<cfif CFSTOREDPROC.STATUSCODE LT 0>
		<cfthrow TYPE="EX_DBERROR" ErrorCode="EST/GETRULESET(#CFSTOREDPROC.STATUSCODE#)">
	</cfif>
	<!--- #23426 Enable Multi worksheet --->
	<!--- 23426 disable multi worksheet --->
	<cfif (claimtype IS "LU" OR claimtype IS "TP BI" OR claimtype is "BI" OR PROPERTY_MODE IS 1 OR (LOCID IS 1 AND CLAIMTYPE IS "NM TR") OR (LOCID IS 2 AND (CLAIMTYPE IS "NM PA" OR CLAIMTYPE IS "NM HS" OR CLAIMTYPE IS "NM TR"))) AND (func_igID IS "" OR func_igID IS 0)>
		<cfset multiws=1>
	<cfelse>
		<cfset multiws=0>
	</cfif>

	<cfif NOT(func_currID GT 0)>
		<cfif isdefined("request.BASECURRENCY.CURRENCYID") AND request.BASECURRENCY.CURRENCYID GT 0>
			<Cfset func_currID=#request.BASECURRENCY.CURRENCYID#>
		<cfelse>
			<cfset func_currID=#request.ds.locales[session.vars.locid].currencyID#>
		</cfif>
	</cfif>

	<cfset returnvalue=structNew()>
	<cfset returnvalue.rsID=#rsID#>
	<cfset returnvalue.rsNAME=#rsNAME#>
	<cfset returnvalue.cur_rsID=#func_rsID#>
	<cfif multiws is 1>
		<cfset returnvalue.cur_igID=-1><!--- unknown, require to retrieve from trx0095 --->
	<cfelse>
		<cfset returnvalue.cur_igID=#func_igID#>
	</cfif>
	<cfset returnvalue.cur_currID=#func_currID#>
	<cfset returnvalue.cur_rsname=#func_rsNAME#>
	<cfset returnvalue.multiws=#multiws#>
	<cfreturn returnvalue>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRGetItmGrpID=MTRGetItmGrpID>

<cffunction name="MTRGenConveyanceOpt" description="Show Conveyance Options" access="public" returntype="any" output="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="value" type="string" default="">
	<cfargument name="claimtypemask" type="string" required="true">
	<!--- <cfargument name="subclmtypemask" type="string" default="">
	<cfargument name="logicname" type="string" default=""> --->
<!--- 	<cfargument name="domainid" type="string" default="">
	<cfargument name="objid" type="string" default="">
	<cfargument name="display" type="numeric" default=0> --->
	<cfset var locid=#request.ds.co[INSGCOID].locid#>
	<cfset var LOCALE=Request.DS.LOCALES[LOCID]>
	<cfif StructKeyExists(request.ds.CONVEYTYPELIST, INSGCOID)>
		<cfset var CONVEYTYPELISTING=#request.ds.CONVEYTYPELIST[INSGCOID]#>
	<cfelse>
		<cfset var CONVEYTYPELISTING=#request.ds.CONVEYTYPELIST[0]#>
	</cfif>
	<script>document.write(JSVCgenOptions("<CFLOOP INDEX=idx LIST="#CONVEYTYPELISTING#"><cfif BITAND(request.ds.CONVEYTYPE[idx].clmtypemask,arguments.claimtypemask) NEQ 0><cfset T=request.ds.CONVEYTYPE[idx]><cfif T.LID IS ""><cfset T.LID=0></cfif>#idx#|#Server.SVClang(T.desc,T.LID)#|</cfif></CFLOOP>","|","#value#",null,1));</script>
	<cfreturn>
	<!--- MTRGenConveyanceOpt(insgcoid,value,claimtypemask) --->
</cffunction>
<cfset Attributes.DS.MTRFN.MTRGenConveyanceOpt=MTRGenConveyanceOpt>

<cffunction name="MTRGenOptCirAct" description="Show options of cirumstance of accident" access="public" returntype="any" output="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="value" type="string" default="">
	<cfargument name="claimtypemask" type="string" required="true">
	<cfargument name="subclmtypemask" type="string" default="">
	<cfargument name="logicname" type="string" default="">
	<cfargument name="domainid" type="string" default="">
	<cfargument name="objid" type="string" default="">
	<cfargument name="display" type="numeric" default=0>
	<cfset var locid=#request.ds.co[INSGCOID].locid#>
	<cfset var LOCALE=Request.DS.LOCALES[LOCID]>
	<cfset var USECLMTYPEMASK=#claimtypemask#>
	<cfif structkeyexists(Request.DS.CLMTYPE,USECLMTYPEMASK)><!--- only single claim type --->
		<cfset var CLAIMTYPE=#Request.DS.CLMTYPE[USECLMTYPEMASK]#><cfset var CLMFLOW=#LEFT(CLAIMTYPE,2)#>
	<cfelse><!--- multi claim type selection --->
		<cfset var CLAIMTYPE=""><cfset var CLMFLOW="">
	</cfif>
	<cfif SUBCLMTYPEMASK GT 0>
		<cfif BITAND(SUBCLMTYPEMASK,1) GT 0><cfset USECLMTYPEMASK=BitOr(USECLMTYPEMASK,request.ds.clmtypereverse["NM FR"])></cfif>
		<cfif BITAND(SUBCLMTYPEMASK,2) GT 0><cfset USECLMTYPEMASK=BitOr(USECLMTYPEMASK,request.ds.clmtypereverse["NM PA"])></cfif>
	</cfif>
<!--- 	<cfset var CLMGROUPMASK=0>
	<cfif BITAND(USECLMTYPEMASK,#request.ds.clmtypecls['MTR']#) GT 0><cfset CLMGROUPMASK=BITOR(CLMGROUPMASK,1)></cfif>
	<cfif BITAND(USECLMTYPEMASK,#request.ds.clmtypecls['NM']#) GT 0><cfset CLMGROUPMASK=BITOR(CLMGROUPMASK,2)></cfif> --->
	<!--- <cfset var USECLMTYPEMASK=request.ds.clmtypereverse["#CLAIMTYPE#"]> --->
	<cfset var q_ciract={}>
	<cfif display IS 0>
		<OPTION value=""></OPTION>
	</cfif>
	<cfif StructKeyExists(LOCALE,"CATYPELIST") AND INSGCOID IS NOT 1000152><!---#25673--->
		<script>document.write(JSVCgenOptions("<CFLOOP INDEX=idx LIST="#LOCALE.CATYPELIST#"><cfif BITAND(LOCALE.CATYPEMASK[idx],USECLMTYPEMASK) GT 0>#idx#|#LOCALE.CATYPE[idx]#|</cfif></CFLOOP>","|","#value#"));</script>
	<cfelse>
		<CFIF (INSGCOID IS 700014 OR INSGCOID IS 200005 OR INSGCOID IS 29) AND Left(CLAIMTYPE,2) IS NOT "NM">
			<!---#23458: [TH] AIG - CreateClaim, AddFeature,UpdateClaim Integration--->
			<!--- Chartis --->
			<!---CFIF (IsDefined("Application.APPDEVMODE") AND Application.APPDEVMODE IS 1)
				OR (Left(Application.APPINSTANCE_SHORTNAME,3) IS "UAT")--->
				<!--- ONECLAIM --->
				<cfquery NAME=q_ciract DATASOURCE=#Request.MTRDSN#>
				SELECT vaCFCODE,vaCFDESC,iCLMTYPEMASK,iLID=isnull(ilid,0) FROM BIZ0025 WITH (NOLOCK) WHERE
				iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#USECLMTYPEMASK#"><>0 AND iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='CIRACT'
				AND vaCFMAPCODE2='OC' AND SISTATUS=0
				ORDER BY vaCFDESC
				</CFQUERY>
				<script>document.write(JSVCgenOptions("<CFLOOP query=q_ciract><cfif BITAND(iCLMTYPEMASK,USECLMTYPEMASK) GT 0>#vaCFCODE#|#Server.SVClang(vaCFDESC,iLID)#|</cfif></CFLOOP>","|","#value#"));</script>
			<!---CFELSE>
				<!--- AEGIS2 --->
				<CFIF INSGCOID IS 700014>
					<script>document.write(JSVCgenOptions("<CFLOOP query=q_ciract><cfif BITAND(iCLMTYPEMASK,USECLMTYPEMASK) GT 0>#vaCFCODE#|#vaCFDESC#|</cfif></CFLOOP>","|","#value#"));</script>
				<CFELSE>
					<script>document.write(JSVCgenOptions("<CFLOOP INDEX=idx LIST="#request.ds.catypelist#"><cfif BITAND(#request.ds.catypemask[idx]#,#USECLMTYPEMASK#) GT 0>#idx#|#request.ds.catype[idx]#|</cfif></CFLOOP>","|","#value#"));</script>
				</CFIF>
			</CFIF--->
		<CFELSEIF INSGCOID IS 1101177>
			<cfquery NAME=q_ciract DATASOURCE=#Request.MTRDSN#>
				SELECT vaCFCODE,vaCFDESC,iCLMTYPEMASK,iLID=isnull(ilid,0) FROM BIZ0025 WITH (NOLOCK) WHERE
				iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#USECLMTYPEMASK#"><>0 AND iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='CIRACT'
				<CFIF logicname NEQ "">
					<CFIF logicname EQ "VVC">
						AND vaCFMAPCODE LIKE 'A%'
					<CFELSE>
						AND vaCFMAPCODE LIKE 'T%'
					</CFIF>
				</CFIF>
				ORDER BY vaCFDESC
			</CFQUERY>
			<cfif display IS 1>
				<CFIF ArrayFind(q_ciract["vaCFCODE"], value) GT 0>
					#q_ciract["vaCFDESC"][ArrayFind(q_ciract["vaCFCODE"], value)]#
				</CFIF>
			<cfelse>
				<script>document.write(JSVCgenOptions("<CFLOOP query=q_ciract><cfif BITAND(iCLMTYPEMASK,USECLMTYPEMASK) GT 0>#vaCFCODE#|#Server.SVClang(vaCFDESC,iLID)#|</cfif></CFLOOP>","|","#value#"));</script>
			</cfif>
		<Cfelseif INSGCOID IS 700051>
			<Cfquery NAME=q_ciract DATASOURCE=#Request.MTRDSN#>
				SELECT vaCFCODE,vaCFDESC,iCLMTYPEMASK,iLID=isnull(ilid,0) FROM BIZ0025 WITH (NOLOCK) WHERE
				iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#USECLMTYPEMASK#"><>0 AND iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='CIRACT'
				ORDER BY CASE WHEN LEFT(vaCFDESC,5)='[SAP]' THEN 1 ELSE dtCRTON END
			</Cfquery>
			<cfif display eq 0>
			<script>document.write(JSVCgenOptions("<CFLOOP query=q_ciract><cfif BITAND(iCLMTYPEMASK,USECLMTYPEMASK) GT 0>#vaCFCODE#|#Server.SVClang(vaCFDESC,iLID)#|</cfif></CFLOOP>","|","#value#"));</script>

			<cfelseif display eq 1>
				<cfloop query=q_ciract>
					<cfif vaCFCODE eq value>#Server.SVClang(q_ciract.vaCFDESC,q_ciract.iLID)#</cfif></cfloop>
			</cfif>
		<cfelseif INSGCOID IS 700527 AND BITAND(USECLMTYPEMASK,2097152)>
			<Cfquery NAME="q_ciract" DATASOURCE=#Request.MTRDSN#>
				SELECT vaCFCODE, vaCFDESC, iLID=ISNULL(iLID,0),vaCFMAPCODE FROM BIZ0025 WITH (NOLOCK) WHERE iCOID=<cfqueryparam value="#arguments.INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='CIRACT'
				AND siSTATUS=0 AND ICLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#request.ds.clmtypereverse[CLAIMTYPE]#"><>0
				ORDER by vaCFDESC ASC
			</Cfquery>
			<script>document.write(JSVCgenOptions("<CFLOOP query="q_ciract">#q_ciract.vaCFCODE#|#Server.SVClang(q_ciract.vaCFDESC,q_ciract.iLID)#  - ( #q_ciract.vaCFMAPCODE# )|</CFLOOP>","|","#value#"));</script>
		<cfelseif (INSGCOID IS 700088 AND CLAIMTYPE IS "NM TR") OR INSGCOID IS 703035 OR (INSGCOID IS 700527 AND bitAnd(USECLMTYPEMASK, 2097152) LTE 0) OR ((INSGCOID IS 37 OR INSGCOID IS 1101192 OR INSGCOID IS 3060 OR INSGCOID IS 1600001 OR INSGCOID IS 200035) AND CLMFLOW IS "NM") OR (INSGCOID IS 50 AND (CLAIMTYPE IS "NM PA" OR CLAIMTYPE IS "NM TR" OR CLAIMTYPE IS "NM FR")) OR ((INSGCOID IS 200045 OR INSGCOID IS 200043) AND CLAIMTYPE IS "NM WC") OR INSGCOID IS 1100001 OR INSGCOID IS 72 OR (INSGCOID IS 69 AND CLMFLOW IS NOT "NM") OR (INSGCOID IS 3060 AND (CLAIMTYPE IS "WS" OR CLMFLOW IS "OD" OR CLAIMTYPE IS "TF" OR CLMFLOW IS "TP"))>
			<!--- custom CIRACT --->
			<cfif domainid IS 1 AND objid GT 0>
				<CFSTOREDPROC PROCEDURE="sspTRXClmGetDefList" DATASOURCE=#REQUEST.MTRDSN# RETURNCODE=YES>
				<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#Attributes.CASEID# DBVARNAME=@ai_caseid>
				<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_CHAR VALUE="CIRACT" DBVARNAME=@aa_CFTYPE>
				<CFPROCRESULT NAME='q_ciract' Resultset=1>
				</cfstoredproc>
				<cfif CFSTOREDPROC.STATUSCODE LT 0>
					<cfthrow TYPE="EX_DBERROR" ErrorCode="EST/GETDEFLIST(#CFSTOREDPROC.STATUSCODE#)">
				</cfif>
			<cfelse>
				<cfquery NAME=q_ciract DATASOURCE=#Request.MTRDSN#>
				SELECT vaCFCODE,vaCFDESC,iCLMTYPEMASK,valogicname FROM BIZ0025 WITH (NOLOCK)
				WHERE iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#USECLMTYPEMASK#"><>0 AND iCOID=<cfqueryparam value="#insgcoid#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='CIRACT'
				<cfif logicname NEQ "">AND ISNULL(valogicname,'')<>'' AND valogicname=<cfqueryparam cfsqltype="CF_SQL_NVARCHAR" value="#logicname#"><cfelse>AND ISNULL(valogicname,'')=''</cfif>
				AND siSTATUS=0
				ORDER BY vaCFDESC
				</cfquery>
			</cfif>
			<cfif display IS 1>
				<CFIF ArrayFind(q_ciract["vaCFCODE"], value) GT 0>
					#q_ciract["vaCFDESC"][ArrayFind(q_ciract["vaCFCODE"], value)]#
				</CFIF>
			<cfelse>
				<script>document.write(JSVCgenOptions("<CFLOOP query=q_ciract><cfif BITAND(iCLMTYPEMASK,USECLMTYPEMASK) GT 0>#vaCFCODE#|#vaCFDESC#|</cfif></CFLOOP>","|","#value#"));</script>
			</cfif>
		<cfelseif (listFindNoCase("70,9616", INSGCOID) GT 0 AND CLAIMTYPE IS "LU")>
			<cfquery NAME=q_ciract DATASOURCE=#Request.MTRDSN#>
				SELECT vaCFCODE,vaCFDESC,iCLMTYPEMASK FROM BIZ0025 WITH (NOLOCK) WHERE
				iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#USECLMTYPEMASK#"><>0 AND iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='CIRACT' AND siSTATUS=0
				<cfif logicname NEQ "">
					AND vaLOGICNAME=<cfqueryparam cfsqltype="CF_SQL_NVARCHAR" value="#logicname#">
				<cfelse>
					AND iCLMTYPEMASK!=262144
				</cfif>
				ORDER BY vaCFDESC
			</CFQUERY>
			<script>document.write(JSVCgenOptions("<CFLOOP query=q_ciract><cfif BITAND(iCLMTYPEMASK,USECLMTYPEMASK) GT 0>#vaCFCODE#|#vaCFDESC#|</cfif></CFLOOP>","|","#value#"));</script>
		<CFELSEIF (listFindNoCase("69", INSGCOID) GT 0 AND CLAIMTYPE IS "NM PA") OR (listFindNoCase("49", INSGCOID) GT 0 AND CLAIMTYPE IS "NM TR")>
			<!--- 24865 & 25327--->
			<cfquery NAME=q_ciract DATASOURCE=#Request.MTRDSN#>
				SELECT vaCFCODE,vaCFDESC,iCLMTYPEMASK FROM BIZ0025 WITH (NOLOCK) WHERE
				iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#USECLMTYPEMASK#"><>0 AND aCFTYPE='CIRACT' AND siSTATUS=0
				<cfif logicname NEQ "">
					AND iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER">
					AND vaLOGICNAME=<cfqueryparam cfsqltype="CF_SQL_NVARCHAR" value="#logicname#">
				<cfelse>
					AND iCOID=0
					AND vaLOGICNAME IS NULL
				</cfif>
				ORDER BY vaCFDESC
			</CFQUERY>
			<script>document.write(JSVCgenOptions("<CFLOOP query=q_ciract><cfif BITAND(iCLMTYPEMASK,USECLMTYPEMASK) GT 0>#vaCFCODE#|#vaCFDESC#|</cfif></CFLOOP>","|","#value#"));</script>
		<cfelseif ListFind("32,70,57,704532,200036",INSGCOID) AND CLMFLOW NEQ "NM">
			<cfquery NAME=q_ciract DATASOURCE=#Request.MTRDSN#>
				SELECT vaCFCODE,vaCFDESC,iCLMTYPEMASK FROM BIZ0025 WITH (NOLOCK) WHERE
				iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#USECLMTYPEMASK#"><>0 AND iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='CIRACT'
				ORDER BY vaCFDESC
			</CFQUERY>
			<script>document.write(JSVCgenOptions("<CFLOOP query=q_ciract><cfif BITAND(iCLMTYPEMASK,USECLMTYPEMASK) GT 0>#vaCFCODE#|#vaCFDESC#|</cfif></CFLOOP>","|","#value#"));</script>
		<cfelseif (ListFind("7651",INSGCOID) AND ListFindNoCase("UAT,DEV",Application.DB_MODE))
				OR (ListFind("7651",INSGCOID) AND ListFindNoCase("PROD",Application.DB_MODE) AND datediff("d","2017-07-22", now()) GTE 0)> <!--- Production Rollout Checking --->
			<cfquery NAME=q_ciract DATASOURCE=#Request.MTRDSN#>
				SELECT vaCFCODE,vaCFDESC,iCLMTYPEMASK FROM BIZ0025 WITH (NOLOCK) WHERE
				iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#USECLMTYPEMASK#"><>0 AND iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='CIRACT' AND siSTATUS=0
				ORDER BY vaCFDESC
			</CFQUERY>
			<script>document.write(JSVCgenOptions("<CFLOOP query=q_ciract><cfif BITAND(iCLMTYPEMASK,USECLMTYPEMASK) GT 0>#vaCFCODE#|#vaCFDESC#|</cfif></CFLOOP>","|","#value#"));</script>
		<cfelseif INSGCOID IS 61 AND LEFT(CLAIMTYPE,2) EQ "NM">
			<cfquery NAME=q_ciract DATASOURCE=#Request.MTRDSN#>
				SELECT vaCFCODE,vaCFDESC,iCLMTYPEMASK FROM BIZ0025 WITH (NOLOCK) WHERE
				iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#USECLMTYPEMASK#"><>0 AND iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='CIRACT' AND siSTATUS=0
				ORDER BY vaCFDESC
			</CFQUERY>
			<script>document.write(JSVCgenOptions("<CFLOOP query=q_ciract><cfif BITAND(iCLMTYPEMASK,USECLMTYPEMASK) GT 0>#vaCFCODE#|#vaCFDESC#|</cfif></CFLOOP>","|","#value#"));</script>
		<cfelseif INSGCOID IS 1100002 AND Left(CLAIMTYPE,2) IS NOT "NM">
			<!---#23458: [TH] AIG - CreateClaim, AddFeature,UpdateClaim Integration--->
			<cfquery NAME=q_ciract DATASOURCE=#Request.MTRDSN#>
				SELECT vaCFCODE,vaCFDESC,iCLMTYPEMASK FROM BIZ0025 WITH (NOLOCK) WHERE
				iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#USECLMTYPEMASK#"><>0 AND iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='CIRACT' AND siSTATUS=0
				ORDER BY vaCFDESC asc
			</CFQUERY>
			<cfif display EQ 1>
				<CFIF ArrayFind(q_ciract["vaCFCODE"], value) GT 0>
					#q_ciract["vaCFDESC"][ArrayFind(q_ciract["vaCFCODE"], value)]#
				</CFIF>
			<cfelse>
				<script>document.write(JSVCgenOptions("<CFLOOP query=q_ciract><cfif BITAND(iCLMTYPEMASK,USECLMTYPEMASK) GT 0>#vaCFCODE#|#vaCFDESC#|</cfif></CFLOOP>","|","#value#"));</script>
			</cfif>
		<cfelseif INSGCOID IS 64 AND Left(CLAIMTYPE,2) IS NOT "NM">
			<!---#28147--->
			<cfquery NAME=q_ciract DATASOURCE=#Request.MTRDSN#>
				SELECT vaCFCODE,vaCFDESC,iCLMTYPEMASK FROM BIZ0025 WITH (NOLOCK) WHERE
				iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#USECLMTYPEMASK#"><>0 AND iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='CIRACT' AND siSTATUS=0
				ORDER BY vaCFDESC asc
			</CFQUERY>
			<script>document.write(JSVCgenOptions("<CFLOOP query=q_ciract><cfif BITAND(iCLMTYPEMASK,USECLMTYPEMASK) GT 0>#vaCFCODE#|#vaCFDESC#|</cfif></CFLOOP>","|","#value#"));</script>
		<cfelseif INSGCOID IS 1000152 AND (Left(CLAIMTYPE,2) IS NOT "NM" OR CLAIMTYPE IS 'NM PA')><!---#30869---><!---#34377--->
			<!---#25673--->
			<cfquery NAME=q_ciract DATASOURCE=#Request.MTRDSN#>
				SELECT vaCFCODE,vaCFDESC,iCLMTYPEMASK FROM BIZ0025 WITH (NOLOCK) WHERE
				iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#USECLMTYPEMASK#"><>0 AND iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='CIRACT' AND siSTATUS=0
				ORDER BY vaCFDESC asc
			</CFQUERY>
			<script>document.write(JSVCgenOptions("<CFLOOP query=q_ciract><cfif BITAND(iCLMTYPEMASK,USECLMTYPEMASK) GT 0>#vaCFCODE#|#vaCFDESC#|</cfif></CFLOOP>","|","#value#"));</script>
		<cfelseif INSGCOID IS 1512247> <!--- #34318 kofam --->
			<cfset LangID=0>
			<cfif isDefined("SESSION.VARS.LGID")>
				<cfset LangID=SESSION.VARS.LGID>
			</cfif>
			<cfquery NAME=q_ciract DATASOURCE=#Request.MTRDSN#>
				SELECT a.vaCFCODE,a.vaCFDESC,a.iCLMTYPEMASK,iLID=ISNULL(a.iLID,0) FROM BIZ0025 a WITH (NOLOCK) LEFT JOIN translation.dbo.LNG0003 b WITH (NOLOCK) on b.iLID=a.iLID AND b.siLANGID=<cfqueryparam value="#LangID#" cfsqltype="CF_SQL_INTEGER"> WHERE a.iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#USECLMTYPEMASK#"><>0 AND a.iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND a.aCFTYPE='CIRACT' AND a.SISTATUS=0
				ORDER BY ISNULL(b.vaTEXT,a.vaCFDESC) asc
				</CFQUERY>
			<script>document.write(JSVCgenOptions("<CFLOOP query=q_ciract><cfif BITAND(iCLMTYPEMASK,USECLMTYPEMASK) GT 0>#vaCFCODE#|#Server.SVClang(vaCFDESC,iLID)#|</cfif></CFLOOP>","|","#value#"));</script>
		<cfelseif INSGCOID IS 200036 AND CLAIMTYPE IS 'NM MH'>
			<cfquery NAME=q_ciract DATASOURCE=#Request.MTRDSN#>
				SELECT vaCFCODE,vaCFDESC,iCLMTYPEMASK 
				FROM BIZ0025 WITH (NOLOCK) 
				WHERE iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#USECLMTYPEMASK#"> <> 0 
				AND iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> 
				AND aCFTYPE='CIRACT' 
				AND siSTATUS=0
				ORDER BY vaCFDESC asc
			</CFQUERY>
			<script>document.write(JSVCgenOptions("<CFLOOP query=q_ciract><cfif BITAND(iCLMTYPEMASK,USECLMTYPEMASK) GT 0>#vaCFCODE#|#vaCFDESC#|</cfif></CFLOOP>","|","#value#"));</script>
		<cfelseif INSGCOID IS 50 AND Left(CLAIMTYPE,2) IS NOT "NM">
			<cfquery NAME=q_ciract DATASOURCE=#Request.MTRDSN#>
				SELECT vaCFCODE,vaCFDESC,iCLMTYPEMASK 
				FROM BIZ0025 WITH (NOLOCK) 
				WHERE iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#USECLMTYPEMASK#"> <> 0 
				AND iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> 
				AND aCFTYPE='CIRACT' 
				AND siSTATUS=0
				ORDER BY vaCFDESC asc
			</CFQUERY>
			<script>document.write(JSVCgenOptions("<CFLOOP query=q_ciract><cfif BITAND(iCLMTYPEMASK,USECLMTYPEMASK) GT 0>#vaCFCODE#|#vaCFDESC#|</cfif></CFLOOP>","|","#value#"));</script>
		<cfelse>
			<script>document.write(JSVCgenOptions("<CFLOOP INDEX=idx LIST="#request.ds.catypelist#"><cfif BITAND(#request.ds.catypemask[idx]#,#USECLMTYPEMASK#) GT 0>#idx#|#Server.SVClang(request.ds.catype[idx],request.ds.catype_LID[idx])#|</cfif></CFLOOP>","|","#value#"));</script>
		</cfif>
	</cfif>
	<!--- cfif CLAIMTYPE IS "NM PA" OR CLAIMTYPE IS "NM HS">
		<script>document.write(JSVCgenOptions("<CFLOOP INDEX=idx LIST="#request.ds.catype3list#">#idx#|#request.ds.CATYPE3[idx]#|</CFLOOP>","|","#value#"));</script>
	<cfelseif CLAIMTYPE IS NOT "OD MNT">
		<script>document.write(JSVCgenOptions("<CFLOOP INDEX=idx LIST="#request.ds.catypelist#">#idx#|#request.ds.CATYPE[idx]#|</CFLOOP>","|","#value#"));</script>
	<cfelse>
		<script>document.write(JSVCgenOptions("<CFLOOP INDEX=idx LIST="#request.ds.catype2list#">#idx#|#request.ds.CATYPE2[idx]#|</CFLOOP>","|","#value#"));</script>
	</cfif--->
	<cfreturn>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRGenOptCirAct=MTRGenOptCirAct>

<cffunction name="MTRGenWSDESC" description="Show options of Worksheet Description" access="public" returntype="any" output="true">	
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="selvalue" type="string" default="">
	<cfargument name="claimtype" type="string" required="true">
	<cfargument name="subclmtypemask" type="string" default="">
	<cfargument name="mapcode" type="string" default="">
	<cfargument name="logicname" type="string" default="">
	<cfset var USECLMTYPEMASK=#request.ds.clmtypereverse[claimtype]#>	
	<cfif SUBCLMTYPEMASK GT 0>
		<cfif BITAND(SUBCLMTYPEMASK,1) GT 0><cfset USECLMTYPEMASK=BitOr(USECLMTYPEMASK,request.ds.clmtypereverse["NM FR"])></cfif>
		<cfif BITAND(SUBCLMTYPEMASK,2) GT 0><cfset USECLMTYPEMASK=BitOr(USECLMTYPEMASK,request.ds.clmtypereverse["NM PA"])></cfif>
	</cfif>
	<cfquery NAME=q_wsdesc DATASOURCE=#Request.MTRDSN#>
		SELECT vaCFCODE,vaCFDESC,vaCFMAPCODE 
		FROM BIZ0025 WITH (NOLOCK) WHERE
		iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#USECLMTYPEMASK#"><>0 
		AND iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> 
		AND aCFTYPE='WSITMDESC' AND vaLOGICNAME=<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#logicname#">
		<CFIF mapcode NEQ "">
			AND vaCFMAPCODE=<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#mapcode#">
		</CFIF> 
		AND SISTATUS=0
		ORDER BY vaCFDESC
	</CFQUERY>

	<CFSET var Ret=StructNew()>
	<CFSET Ret.q_wsdesc=q_wsdesc>
	<CFOUTPUT QUERY="q_wsdesc">
		<cfset Ret.codedesc[vaCFCODE]=vaCFDESC>
	</CFOUTPUT>
<cfreturn Ret>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRGenWSDESC=MTRGenWSDESC>

<cffunction name="MTRGenWSRemark" description="Show options of Worksheet Remark" access="public" returntype="any" output="true">	
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="selvalue" type="string" default="">
	<cfargument name="claimtype" type="string" required="true">
	<cfargument name="subclmtypemask" type="string" default="">
	<cfargument name="mapcode" type="string" default="">
	<cfargument name="logicname" type="string" default="">
	<cfset var USECLMTYPEMASK=#request.ds.clmtypereverse[claimtype]#>	
	<cfif SUBCLMTYPEMASK GT 0>
		<cfif BITAND(SUBCLMTYPEMASK,1) GT 0><cfset USECLMTYPEMASK=BitOr(USECLMTYPEMASK,request.ds.clmtypereverse["NM FR"])></cfif>
		<cfif BITAND(SUBCLMTYPEMASK,2) GT 0><cfset USECLMTYPEMASK=BitOr(USECLMTYPEMASK,request.ds.clmtypereverse["NM PA"])></cfif>
	</cfif>
	<cfquery NAME=q_wsrem DATASOURCE=#Request.MTRDSN#>
		SELECT vaCFCODE,vaCFDESC,vaCFMAPCODE 
		FROM BIZ0025 WITH (NOLOCK) WHERE
		iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#USECLMTYPEMASK#"><>0 
		AND iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> 
		AND aCFTYPE='WSITMREMARK' AND vaLOGICNAME=<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#logicname#"> 
		AND SISTATUS=0
		ORDER BY vaCFDESC
	</CFQUERY>
	<CFSET var Ret=StructNew()>
	<CFSET Ret.q_wsrem=q_wsrem>
	<CFOUTPUT QUERY="q_wsrem">
		<cfset Ret.codedesc[vaCFCODE]=vaCFDESC>
	</CFOUTPUT>
<cfreturn Ret>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRGenWSRemark=MTRGenWSRemark>

<cffunction name="MTRMOMStatReqField" description="get the list of required/mandatory fields" acces="public" returntype="any" output="true">
	<cfargument name="statuscode" type="string" default="">
	<cfargument name="fieldname" type="string" default="">
	<cfargument name="colname" type="string" default="">

	<cfquery name="q_allreqfield" DATASOURCE=#Request.MTRDSN#>
		SELECT RptColNm,RptColVal,UIFieldNm,ReqStatList FROM SGWICA_MOMSTATUS_REQFIELD st WITH (NOLOCK) WHERE sistatus=0
		<CFIF Arguments.statuscode neq ""> AND ','+ReqStatList+',' like <cfqueryparam value="%,#Arguments.statuscode#,%" cfsqltype="cf_sql_nvarchar"></CFIF>
		<CFIF Arguments.fieldname neq ""> AND TRIM(RptColNm)=<cfqueryparam value="#Arguments.fieldname#" cfsqltype="cf_sql_nvarchar"></CFIF>
		<CFIF Arguments.colname neq ""> AND TRIM(RptColVal)=<cfqueryparam value="#Arguments.colname#" cfsqltype="cf_sql_nvarchar"></CFIF>
	</cfquery>

	<!--- START GET BY MOM STATUS CODE --->
	<CFSET MOMStatus=StructNew()>
	<CFSET MOMRptField=StructNew()>

	<cfset MOMStatAll=StructNew()>
	<cfset MOMStatAll.RptColNmList = "">
	<cfset MOMStatAll.RptColValList = "">
	<cfset MOMStatAll.UIFieldNmList = "">

	<CFSET COLID=0>
	<cfoutput query="q_allreqfield">
		<CFSET COLID=COLID+1><CFSET ID="">

		<cfset MOMReportField=StructNew()>
		<cfset MOMReportField.RptColNm = "#RptColNm#">
		<cfset MOMReportField.RptColVal = "#RptColVal#">
		<cfset MOMReportField.UIFieldNmList = "#UIFieldNm#">
		<cfset MOMReportField.StatusList = "#ReqStatList#">
		<cfset MOMRptField[COLID]=MOMReportField>

		<CFIF listfindnocase(ReqStatList,"2002")>
			<CFSET ID="2002">
			<cfif NOT StructKeyExists(MOMStatus,ID)>
				<cfset MOMStatCode=StructNew()>
				<cfset MOMStatCode.RptColNmList = "">
				<cfset MOMStatCode.RptColValList = "">
				<cfset MOMStatCode.UIFieldNmList = "">
				<cfset MOMStatus[ID]=MOMStatCode>
			</CFIF>
			<cfset MOMStatus[ID]["RptColNmList"] = MOMStatus[ID]["RptColNmList"]&"#RptColNm#,">
			<cfset MOMStatus[ID]["RptColValList"] = MOMStatus[ID]["RptColValList"]&"#RptColVal#,">
			<cfset MOMStatus[ID]["UIFieldNmList"] = MOMStatus[ID]["UIFieldNmList"]&"#UIFieldNm#,">
		</CFIF>
		<CFIF listfindnocase(ReqStatList,"2003")>
			<CFSET ID="2003">
			<cfif NOT StructKeyExists(MOMStatus,ID)>
				<cfset MOMStatCode=StructNew()>
				<cfset MOMStatCode.RptColNmList = "">
				<cfset MOMStatCode.RptColValList = "">
				<cfset MOMStatCode.UIFieldNmList = "">
				<cfset MOMStatus[ID]=MOMStatCode>
			</CFIF>
			<cfset MOMStatus[ID]["RptColNmList"] = MOMStatus[ID]["RptColNmList"]&"#RptColNm#,">
			<cfset MOMStatus[ID]["RptColValList"] = MOMStatus[ID]["RptColValList"]&"#RptColVal#,">
			<cfset MOMStatus[ID]["UIFieldNmList"] = MOMStatus[ID]["UIFieldNmList"]&"#UIFieldNm#,">
		</CFIF>
		<CFIF listfindnocase(ReqStatList,"2004")>
			<CFSET ID="2004">
			<cfif NOT StructKeyExists(MOMStatus,ID)>
				<cfset MOMStatCode=StructNew()>
				<cfset MOMStatCode.RptColNmList = "">
				<cfset MOMStatCode.RptColValList = "">
				<cfset MOMStatCode.UIFieldNmList = "">
				<cfset MOMStatus[ID]=MOMStatCode>
			</CFIF>
			<cfset MOMStatus[ID]["RptColNmList"] = MOMStatus[ID]["RptColNmList"]&"#RptColNm#,">
			<cfset MOMStatus[ID]["RptColValList"] = MOMStatus[ID]["RptColValList"]&"#RptColVal#,">
			<cfset MOMStatus[ID]["UIFieldNmList"] = MOMStatus[ID]["UIFieldNmList"]&"#UIFieldNm#,">
		</CFIF>
		<CFIF listfindnocase(ReqStatList,"2005")>
			<CFSET ID="2005">
			<cfif NOT StructKeyExists(MOMStatus,ID)>
				<cfset MOMStatCode=StructNew()>
				<cfset MOMStatCode.RptColNmList = "">
				<cfset MOMStatCode.RptColValList = "">
				<cfset MOMStatCode.UIFieldNmList = "">
				<cfset MOMStatus[ID]=MOMStatCode>
			</CFIF>
			<cfset MOMStatus[ID]["RptColNmList"] = MOMStatus[ID]["RptColNmList"]&"#RptColNm#,">
			<cfset MOMStatus[ID]["RptColValList"] = MOMStatus[ID]["RptColValList"]&"#RptColVal#,">
			<cfset MOMStatus[ID]["UIFieldNmList"] = MOMStatus[ID]["UIFieldNmList"]&"#UIFieldNm#,">
		</CFIF>
		<CFIF listfindnocase(ReqStatList,"2006")>
			<CFSET ID="2006">
			<cfif NOT StructKeyExists(MOMStatus,ID)>
				<cfset MOMStatCode=StructNew()>
				<cfset MOMStatCode.RptColNmList = "">
				<cfset MOMStatCode.RptColValList = "">
				<cfset MOMStatCode.UIFieldNmList = "">
				<cfset MOMStatus[ID]=MOMStatCode>
			</CFIF>
			<cfset MOMStatus[ID]["RptColNmList"] = MOMStatus[ID]["RptColNmList"]&"#RptColNm#,">
			<cfset MOMStatus[ID]["RptColValList"] = MOMStatus[ID]["RptColValList"]&"#RptColVal#,">
			<cfset MOMStatus[ID]["UIFieldNmList"] = MOMStatus[ID]["UIFieldNmList"]&"#UIFieldNm#,">
		</CFIF>
		<CFIF listfindnocase(ReqStatList,"2007")>
			<CFSET ID="2007">
			<cfif NOT StructKeyExists(MOMStatus,ID)>
				<cfset MOMStatCode=StructNew()>
				<cfset MOMStatCode.RptColNmList = "">
				<cfset MOMStatCode.RptColValList = "">
				<cfset MOMStatCode.UIFieldNmList = "">
				<cfset MOMStatus[ID]=MOMStatCode>
			</CFIF>
			<cfset MOMStatus[ID]["RptColNmList"] = MOMStatus[ID]["RptColNmList"]&"#RptColNm#,">
			<cfset MOMStatus[ID]["RptColValList"] = MOMStatus[ID]["RptColValList"]&"#RptColVal#,">
			<cfset MOMStatus[ID]["UIFieldNmList"] = MOMStatus[ID]["UIFieldNmList"]&"#UIFieldNm#,">
		</CFIF>
		<CFIF listfindnocase(ReqStatList,"2008")>
			<CFSET ID="2008">
			<cfif NOT StructKeyExists(MOMStatus,ID)>
				<cfset MOMStatCode=StructNew()>
				<cfset MOMStatCode.RptColNmList = "">
				<cfset MOMStatCode.RptColValList = "">
				<cfset MOMStatCode.UIFieldNmList = "">
				<cfset MOMStatus[ID]=MOMStatCode>
			</CFIF>
			<cfset MOMStatus[ID]["RptColNmList"] = MOMStatus[ID]["RptColNmList"]&"#RptColNm#,">
			<cfset MOMStatus[ID]["RptColValList"] = MOMStatus[ID]["RptColValList"]&"#RptColVal#,">
			<cfset MOMStatus[ID]["UIFieldNmList"] = MOMStatus[ID]["UIFieldNmList"]&"#UIFieldNm#,">
		</CFIF>
		<CFIF listfindnocase(ReqStatList,"2009")>
			<CFSET ID="2009">
			<cfif NOT StructKeyExists(MOMStatus,ID)>
				<cfset MOMStatCode=StructNew()>
				<cfset MOMStatCode.RptColNmList = "">
				<cfset MOMStatCode.RptColValList = "">
				<cfset MOMStatCode.UIFieldNmList = "">
				<cfset MOMStatus[ID]=MOMStatCode>
			</CFIF>
			<cfset MOMStatus[ID]["RptColNmList"] = MOMStatus[ID]["RptColNmList"]&"#RptColNm#,">
			<cfset MOMStatus[ID]["RptColValList"] = MOMStatus[ID]["RptColValList"]&"#RptColVal#,">
			<cfset MOMStatus[ID]["UIFieldNmList"] = MOMStatus[ID]["UIFieldNmList"]&"#UIFieldNm#,">
		</CFIF>
		<CFIF listfindnocase(ReqStatList,"2010")>
			<CFSET ID="2010">
			<cfif NOT StructKeyExists(MOMStatus,ID)>
				<cfset MOMStatCode=StructNew()>
				<cfset MOMStatCode.RptColNmList = "">
				<cfset MOMStatCode.RptColValList = "">
				<cfset MOMStatCode.UIFieldNmList = "">
				<cfset MOMStatus[ID]=MOMStatCode>
			</CFIF>
			<cfset MOMStatus[ID]["RptColNmList"] = MOMStatus[ID]["RptColNmList"]&"#RptColNm#,">
			<cfset MOMStatus[ID]["RptColValList"] = MOMStatus[ID]["RptColValList"]&"#RptColVal#,">
			<cfset MOMStatus[ID]["UIFieldNmList"] = MOMStatus[ID]["UIFieldNmList"]&"#UIFieldNm#,">
		</CFIF>
		<CFIF listfindnocase(ReqStatList,"2011")>
			<CFSET ID="2011">
			<cfif NOT StructKeyExists(MOMStatus,ID)>
				<cfset MOMStatCode=StructNew()>
				<cfset MOMStatCode.RptColNmList = "">
				<cfset MOMStatCode.RptColValList = "">
				<cfset MOMStatCode.UIFieldNmList = "">
				<cfset MOMStatus[ID]=MOMStatCode>
			</CFIF>
			<cfset MOMStatus[ID]["RptColNmList"] = MOMStatus[ID]["RptColNmList"]&"#RptColNm#,">
			<cfset MOMStatus[ID]["RptColValList"] = MOMStatus[ID]["RptColValList"]&"#RptColVal#,">
			<cfset MOMStatus[ID]["UIFieldNmList"] = MOMStatus[ID]["UIFieldNmList"]&"#UIFieldNm#,">
		</CFIF>

		<cfset MOMStatAll.RptColNmList = MOMStatAll.RptColNmList&"#RptColNm#,">
		<cfset MOMStatAll.RptColValList = MOMStatAll.RptColValList&"#RptColVal#,">
		<cfset MOMStatAll.UIFieldNmList = MOMStatAll.UIFieldNmList&"#UIFieldNm#,">
		<cfset MOMStatus["ALL"]=MOMStatAll>

	</cfoutput>
	<CFSET results={MOMStatus=#MOMStatus#,ReportField=#MOMRptField#}>
	<CFRETURN results>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRMOMStatReqField=MTRMOMStatReqField>

<cffunction name="MTRGenOptDamType" description="Show options of Damage/Loss Type" access="public" returntype="any" output="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="value" type="string" default="">
	<cfargument name="claimtypemask" type="string" required="true">
	<cfargument name="subclmtypemask" type="string" default="">
	<cfargument name="logicname" type="string" default="">
	<cfargument name="display" type="numeric" default=0>
	<cfset var USECLMTYPEMASK=#claimtypemask#>
	<cfif structkeyexists(Request.DS.CLMTYPE,USECLMTYPEMASK)><!--- only single claim type --->
		<cfset var CLAIMTYPE=#Request.DS.CLMTYPE[USECLMTYPEMASK]#><cfset var CLMFLOW=#LEFT(CLAIMTYPE,2)#>
	<cfelse><!--- multi claim type selection --->
		<cfset var CLAIMTYPE=""><cfset var CLMFLOW="">
	</cfif>
	<cfset var DAMTYPEUSEGCOID=0>
	<cfset var siCDDAMTYPE=#value#>
	<cfif SUBCLMTYPEMASK GT 0>
		<cfif BITAND(SUBCLMTYPEMASK,1) GT 0><cfset USECLMTYPEMASK=BitOr(USECLMTYPEMASK,request.ds.clmtypereverse["NM FR"])></cfif>
		<cfif BITAND(SUBCLMTYPEMASK,2) GT 0><cfset USECLMTYPEMASK=BitOr(USECLMTYPEMASK,request.ds.clmtypereverse["NM PA"])></cfif>
	</cfif>
	<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\ADDFILE.cfm" FNAME="MTRappvars">
	<cfif NOT(INSGCOID IS 50 AND CLMFLOW IS "NM" AND LOGICNAME IS "")>
		<cfif (INSGCOID IS 50 AND (CLAIMTYPE IS "NM FR" OR CLAIMTYPE IS "NM PA" OR CLAIMTYPE IS "NM TR"))
			OR (CLMFLOW IS "NM" AND (INSGCOID IS 37 OR INSGCOID IS 1101192 OR INSGCOID IS 1713)) OR ((CLAIMTYPE IS 'TF' OR CLAIMTYPE IS 'TP BI') AND INSGCOID IS 700001)
			OR (CLAIMTYPE IS "NM WC" AND (INSGCOID IS 200045 OR INSGCOID IS 200043))
			OR (CLAIMTYPE IS "OD MNT" AND INSGCOID IS 700051)
			OR ListFind("1000152,700491,701593,700088,700004,700467,700519,700479,700456,701677,701651,700527,700504,700505,700498,702933,703035,700513,1100001,700456,700495,703734,1500001,1510010,72",INSGCOID)
			OR (ListFind("700480,700469,700498,704145,704714,700170,700051,707644",INSGCOID))
			OR (ListFind("700488",INSGCOID) AND (Application.DB_MODE IS "UAT" OR Application.DB_MODE IS "DEV"))
			OR (BITAND(USECLMTYPEMASK,22807) GT 0 AND INSGCOID IS 1000830) <!--- Customization #20909 YN --->
			OR (INSGCOID IS 61 AND CLMFLOW IS "NM")
			<!---OR (INSGCOID IS 46 AND (CLMFLOW IS 'OD' OR CLMFLOW IS 'WS' OR CLMFLOW IS 'TF' OR CLMFLOW IS 'TP')) <!--- #25051 lssoh--->--->
			OR (INSGCOID IS 704788)
			OR (INSGCOID IS 1000615)
			OR INSGCOID IS 200005>
			<CFIF NOT (INSGCOID IS 1000152 AND CLAIMTYPE EQ "NM FR" AND listfindnocase("DEV,UAT", application.DB_MODE) GT 0)><!--- 41309 --->
			<cfset DAMTYPEUSEGCOID=INSGCOID>
			</CFIF>
		</cfif>
		<CFIF display neq 1>
		<OPTION value=""></OPTION>
		</CFIF>
		<!--- ID-Allianz: Retain old values (clmtypemask=0) --->
		<cfif DAMTYPEUSEGCOID IS 700088 AND IsNumeric(siCDDAMTYPE) AND siCDDAMTYPE GE 0 AND siCDDAMTYPE LE 21 AND display EQ 0>
			<script>document.write(JSVCgenOptions(MTRnatureList("#DAMTYPEUSEGCOID#",null,"#siCDDAMTYPE#",""),"|","#siCDDAMTYPE#",null,1));</script>
		</cfif>
		<!---MSIG--->
		<cfif DAMTYPEUSEGCOID IS 700051 and (display eq 0 or display eq 1)>
			<Cfquery NAME="q_nol" DATASOURCE=#Request.MTRDSN#>
				SELECT vaCFCODE, vaCFDESC, iLID=ISNULL(iLID,0) FROM BIZ0025 WITH (NOLOCK) WHERE iCOID=<cfqueryparam value="#arguments.INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='DAMTYPE'
				AND siSTATUS=0 AND ICLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#request.ds.clmtypereverse[CLAIMTYPE]#"><>0
				<CFIF display neq 1>
				AND ICLMTYPEMASK<>CASE WHEN <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#request.ds.clmtypereverse[CLAIMTYPE]#">=64 THEN -1 ELSE 999 END
				</CFIF>
				ORDER BY CASE WHEN LEFT(vaCFDESC,5)='[SAP]' THEN 1 ELSE dtCRTON END
			</Cfquery>

			<cfif display eq 0>
				<script>document.write(JSVCgenOptions("<CFLOOP query="q_nol">#q_nol.vaCFCODE#|#Server.SVClang(q_nol.vaCFDESC,q_nol.iLID)#|</CFLOOP>","|","#siCDDAMTYPE#"));</script>

			<cfelseif display eq 1>
				<cfloop query=q_nol>
					<cfif vaCFCODE eq value> #Server.SVClang(q_nol.vaCFDESC,q_nol.iLID)#</cfif></cfloop>
			</cfif>

		<cfelseif DAMTYPEUSEGCOID IS 700527 AND BITAND(USECLMTYPEMASK,2097152) AND display EQ 0>
			<Cfquery NAME="q_nol" DATASOURCE=#Request.MTRDSN#>
				SELECT vaCFCODE, vaCFDESC, iLID=ISNULL(iLID,0),vaCFMAPCODE FROM BIZ0025 WITH (NOLOCK) WHERE iCOID=<cfqueryparam value="#arguments.INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='DAMTYPE'
				AND siSTATUS=0 AND ICLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#request.ds.clmtypereverse[CLAIMTYPE]#"><>0
				ORDER by vaCFDESC ASC
			</Cfquery>
			<script>document.write(JSVCgenOptions("<CFLOOP query="q_nol">#q_nol.vaCFCODE#|#Server.SVClang(q_nol.vaCFDESC,q_nol.iLID)#  - ( #q_nol.vaCFMAPCODE# )|</CFLOOP>","|","#siCDDAMTYPE#"));</script>
		<cfelseif CLAIMTYPE IS "TF" AND (DAMTYPEUSEGCOID IS 1500001 OR DAMTYPEUSEGCOID IS 1510010) AND siCDDAMTYPE IS "" AND display EQ 0>
			<script>document.write(JSVCgenOptions(MTRnatureList("#DAMTYPEUSEGCOID#",#USECLMTYPEMASK#,null,""),"|","2",null,1));</script>
		<cfelseif INSGCOID IS 1100002 AND Left(CLAIMTYPE,2) IS NOT "NM">
			<!---#23458: [TH] AIG - CreateClaim, AddFeature,UpdateClaim Integration--->
			<cfquery NAME=q_nol DATASOURCE=#Request.MTRDSN#>
				SELECT vaCFCODE,vaCFDESC,iLID=ISNULL(iLID,0),iCLMTYPEMASK FROM BIZ0025 WITH (NOLOCK) WHERE
				iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#USECLMTYPEMASK#"><>0 AND iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='DAMTYPE' AND siSTATUS=0
				ORDER BY vaCFDESC asc
			</CFQUERY>
			<script>document.write(JSVCgenOptions("<CFLOOP query="q_nol">#q_nol.vaCFCODE#|#Server.SVClang(q_nol.vaCFDESC,q_nol.iLID)#|</CFLOOP>","|","#siCDDAMTYPE#"));</script>
		<!---<cfelseif (INSGCOID IS 46 AND (CLMFLOW IS 'OD' OR CLMFLOW IS 'WS' OR CLMFLOW IS 'TF' OR CLMFLOW IS 'TP'))>	<!--- #25051 lssoh--->
			<script>document.write(JSVCgenOptions("<CFLOOP query="q_nol">#q_nol.vaCFCODE#|#Server.SVClang(q_nol.vaCFDESC,q_nol.iLID)#|</CFLOOP>","|","#siCDDAMTYPE#"));</script>--->
		<cfelseif DAMTYPEUSEGCOID IS 704788>
			<script>document.write(JSVCgenOptions(MTRnatureList("#DAMTYPEUSEGCOID#",#USECLMTYPEMASK#,null,"<cfif INSGCOID IS 704788>#LOGICNAME#</cfif>"),"|","#siCDDAMTYPE#",null,1));</script>
		<!--- Start #492 - No selection for Damage / Loss Type (Block Rollout #26825) kofam --->
		<!--- revert #26825 done by ziv 
		<cfelseif INSGCOID IS 29 AND (CLAIMTYPE eq 'NM FR' OR CLAIMTYPE eq 'NM ENG') AND listfindnocase("TRAIN,PROD", application.DB_MODE) EQ 0>
			<cfquery NAME=q_nol DATASOURCE=#Request.MTRDSN#>
				SELECT vaCFCODE,vaCFDESC,iLID=ISNULL(iLID,0),iCLMTYPEMASK FROM BIZ0025 WITH (NOLOCK) WHERE
				iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='DAMTYPE' AND siSTATUS=0
				ORDER BY vaCFDESC asc
			</CFQUERY>
			<script>document.write(JSVCgenOptions("<CFLOOP query="q_nol">#q_nol.vaCFCODE#|#Server.SVClang(q_nol.vaCFDESC,q_nol.iLID)#|</CFLOOP>","|","#siCDDAMTYPE#"));</script>
		--->
		<!--- End #492 kofam --->
		<cfelseif (INSGCOID IS 1000615)>	<!---#28167--->
			<cfquery NAME=q_nol DATASOURCE=#Request.MTRDSN#>
				SELECT vaCFCODE, vaDESC = vaCFMAPCODE + '-' + vaCFDESC,iLID=ISNULL(iLID,0),iCLMTYPEMASK FROM BIZ0025 WITH (NOLOCK) WHERE
				iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='NOLCODE' AND siSTATUS=0
				ORDER BY vaCFCODE asc
			</CFQUERY>
			<script>document.write(JSVCgenOptions("<CFLOOP query="q_nol">#q_nol.vaCFCODE#|#Server.SVClang(q_nol.vaDESC,q_nol.iLID)#|</CFLOOP>","|","#siCDDAMTYPE#"));</script>
		<CFELSEIF INSGCOID IS 64 AND CLMFLOW IS "NM">		<!---#29628--->
			<Cfquery NAME="q_ISMCODE" DATASOURCE=#Request.MTRDSN#>
				SELECT DSC=a.vaCFCODE+': '+a.vaCFDESC,vaCFCODE
				FROM BIZ0025 a WITH (NOLOCK)
				JOIN TRX0054 b ON a.vaCFCODE = b.vaNATURELOSS1
				WHERE a.iCOID=64 AND a.aCFTYPE='TMIM_LOSS_CODE'
				AND a.siSTATUS=0 AND b.iCASEID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CASEID#">
			</Cfquery>
			<option value=#q_ISMCODE.vaCFCODE# SELECTED>#q_ISMCODE.DSC#</option>
		<cfelseif INSGCOID IS 1512247>	<!---#34318 kofam--->
			<cfset LangID=0>
			<cfif isDefined("SESSION.VARS.LGID")>
				<cfset LangID=SESSION.VARS.LGID>
			</cfif>
			<cfquery NAME=q_nol DATASOURCE=#Request.MTRDSN#>
				SELECT a.vaCFCODE,vaDESC=a.vaCFDESC,iLID=ISNULL(a.iLID,0),a.iCLMTYPEMASK FROM BIZ0025 a WITH (NOLOCK)
				LEFT JOIN translation.dbo.LNG0003 b WITH (NOLOCK) on b.iLID=a.iLID AND b.siLANGID=<cfqueryparam value="#LangID#" cfsqltype="CF_SQL_INTEGER"> WHERE a.iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND a.aCFTYPE='DAMTYPE' AND a.siSTATUS=0
				ORDER BY ISNULL(b.vaTEXT,a.vaCFDESC) asc
			</CFQUERY>
			<script>document.write(JSVCgenOptions("<CFLOOP query="q_nol">#q_nol.vaCFCODE#|#Server.SVClang(q_nol.vaDESC,q_nol.iLID)#|</CFLOOP>","|","#siCDDAMTYPE#"));</script>
		<cfelse>
			<cfif display EQ 0>
				<script>document.write(JSVCgenOptions(MTRnatureList("#DAMTYPEUSEGCOID#",#USECLMTYPEMASK#,null,"<cfif INSGCOID IS 50>#LOGICNAME#</cfif>"),"|","#siCDDAMTYPE#",null,1));</script>
			<cfelse>
				#Request.DS.DMGTYPE["vaCFDESC"][ArrayFind(Request.DS.DMGTYPE["vaCFCODE"], siCDDAMTYPE)]#
			</cfif>
		</cfif>
	</cfif>
	<cfreturn>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRGenOptDamType=MTRGenOptDamType>

<cffunction name="MTRPopDrvLicenseClass" description="Populate the field for Driver's License Class" access="public" returntype="struct">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="name" type="string" required="true">
	<cfargument name="value" type="string" require="false" default="">
	<cfset var q_get={}><cfset var fieldtype="">
	<cfoutput>
	<cfsavecontent variable="thelabel">#request.ds.FN.SVCsymbol("LICENSECLS","#Server.SVClang("License Classes",1193)#")#</cfsavecontent>
	<CFIF structkeyexists(request.ds.drvliclslist,arguments.insgcoid)>
		<cfset usegcoid=#arguments.insgcoid#>
	<cfelse><!--- general --->
		<cfset usegcoid=0>
	</cfif>
	<cfsavecontent variable="thefield">
	<cfif usegcoid GT 0>
		<cfif arguments.insgcoid IS 1100001 OR arguments.insgcoid IS 1101177>
			<cfif LISTLEN(request.ds.drvliclslist[usegcoid]) GT 1>
			<select id="#arguments.name#" name="#arguments.name#"  VALUE="#HTMLEditFormat(arguments.value)#") onblur="DoReq(this)">
				<option value=""></option>
				<cfloop list=#request.ds.drvliclslist[usegcoid]# index="a"><!--- chkDCLClass --->
					<option value="#a#"<CFIF arguments.value IS a> SELECTED</CFIF> >#request.ds.drvlicls[a]#</option>
				</cfloop>
			</select>
			</cfif>
			<cfset fieldtype="SELECT">
		<cfelse>
			<cfif arguments.value IS "" OR NOT IsNumeric(arguments.value)><cfset arguments.value=0></cfif>
			<cfif LISTLEN(request.ds.drvliclslist[usegcoid]) GT 1>
				<input type="hidden" name="#arguments.name#" value=0>
				<cfloop list=#request.ds.drvliclslist[usegcoid]# index="a"><!--- chkDCLClass --->
					<label><input name="#arguments.name#" type="checkbox" value="#a#" <CFIF BitAnd(arguments.value,a) GT 0> checked</CFIF> >#request.ds.drvlicls[a]#</label>
				</cfloop>
			</cfif>
			<cfset fieldtype="CHECKBOX">
		</cfif>
	<cfelse>
		<!--- <input id="#arguments.name#" name="#arguments.name#" maxlength=10 size=12 style=text-transform:uppercase VALUE="#HTMLEditFormat(arguments.value)#")> --->
		<input id="#arguments.name#" name="#arguments.name#" maxlength=35 size=37 style=text-transform:uppercase VALUE="#HTMLEditFormat(arguments.value)#" onblur="DoReq(this)">
		<cfset fieldtype="TEXT">
	</cfif>
	</cfsavecontent>
	</cfoutput>
	<CFSET results={label="#thelabel#",field="#thefield#",type="#fieldtype#"}>
	<CFRETURN results>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRPopDrvLicenseClass=MTRPopDrvLicenseClass>

<!---cffunction name="MTRPopVHRegState" description="Populate the disable for field of Vehicle Registration of State/Province" access="public" returntype="struct">
	<cfargument name="name" type="string" required="true">
	<cfargument name="value" type="string" require="false" default="">
	<cfargument name="LOCID" type="numeric" required="true">
	<cfset var q_state={}>
	<cfoutput>
	<cfsavecontent variable="thelabel">
	<CFIF Arguments.LOCID IS 6 OR Arguments.LOCID IS 9>#Server.SVClang("TP's Vehicle Registered Province")#<CFELSEIF Arguments.LOCID IS 11>#Server.SVClang("TP Vehicle Registered Province")#<CFELSE>#Server.SVClang("TP's Vehicle Registered State")#</CFIF>
	</cfsavecontent>

	<cfsavecontent variable="thefield">
	<select ID="#name#" NAME="#name#" onblur="DoReq(this);"><option value=""></option>
	<cfloop query=q_state><option CTRYID="#iCOUNTRYID#" value="#ID#"<CFIF Arguments.value IS q_state.ID> SELECTED</CFIF>>#vaDESC#</cfloop>
	</select>
	</cfsavecontent>
	</cfoutput>
	<CFSET results={label="#thelabel#",field="#thefield#"}>
	<CFRETURN results>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRPopVHRegState=MTRPopVHRegState--->

<cffunction name="MTRSGTOKIOWICA_GetDefaultPaymentEmailContent" description="Get default content of the final payment" access="public" returntype="struct">
	<cfargument name="caseid" type="string" required="true">
	<cfset var q_trx={}>
	<cfquery NAME=q_trx DATASOURCE=#Request.MTRDSN#>
	SELECT inscoid=a.icoid, picusname=own.vausname, b.vaCLMEMAIL, c.vainsuredname, c.vacmtname, c.vapolno, m.vaclmno, c.dtaccdate, inscoid=m.icoid, a.imaincaseid
	FROM TRX0008 a with (nolock)
	JOIN TRX0008 m with (nolock) ON a.imaincaseid=m.icaseid
	JOIN TRX0001 c with (nolock) ON c.icaseid=m.icaseid
	LEFT JOIN SEC0001 own with (nolock) ON a.vaowner=own.vausid
	LEFT JOIN TRX0055b b with (nolock) on a.icaseid=b.icaseid
	WHERE a.icaseid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.caseid#"> AND a.siTPINS=0
	</cfquery>
	<CFSET results={CTXT="",MAILTO=""}>
	<cfif q_trx.recordcount GT 0>
		<cfif q_trx.vaCLMEMAIL IS "NOEMAIL"><cfset mailto=""><cfelse><cfset mailto=#q_trx.vaCLMEMAIL#></cfif>
		<cfsavecontent variable="VX1_CTXT">
		<cfoutput query="q_trx">
		Insured : #htmleditformat(vainsuredname)#<br><br>
		Claim No:   #htmleditformat(vaclmno)#<br><br>
		Policy No:  #htmleditformat(vapolno)#<br><br>
		Injured Person:  #htmleditformat(vacmtname)#<br><br>
		Date of Accident: #request.ds.fn.svcdtdbtoloc(dtaccdate)#<br><br>
		<br>
		Dear Sir/Madam<br><br>
		We refer to the above captioned.<br><br>
		We are pleased to advise that we have processed your claim as per computation sheet attached and the cheque should reach you in about 5 business days.<br><br>
		Thank you for insuring with #request.ds.co[inscoid].coname#.<br>
		<br><br>
		[NB: This mail is sent from a mailer account, please do not reply to this email address.]<br><br>
		Yours sincerely
		<br><br><cfif PICUSERNAME NEQ "">#htmleditformat(PICUSERNAME)#<cfelse>[Claim Officer Name]</cfif>
		<br><br>#request.ds.co[inscoid].coname#
		<br>Company Reg. No. #request.ds.co[inscoid].COREGNO#
		<cfif request.ds.co[inscoid].add1 NEQ ""><br>#request.ds.co[inscoid].add1#</cfif>
		<cfif request.ds.co[inscoid].add2 NEQ ""><br>#request.ds.co[inscoid].add2#</cfif>
		<cfif request.ds.co[inscoid].add3 NEQ ""><br>#request.ds.co[inscoid].add3#</cfif>
		<br>Singapore #request.ds.co[inscoid].postcode#
		<br>TEL: #request.ds.co[inscoid].telno# &nbsp;&nbsp; FAX: #request.ds.co[inscoid].faxno#
		<br>Website: www.tokiomarine.com.sg
		<br><br><br>Please note that all personal information provided to Tokio Marine Insurance Singapore Ltd is subject to the Personal Data Protection Policy Statement posted at www.tokiomarine.com.sg under privacy statement.
		</cfoutput>
		</cfsavecontent>
		<cfif q_trx.imaincaseid NEQ attributes.caseid>
			<cfquery NAME=q_sub DATASOURCE=#Request.MTRDSN#>
			selecT TOP 1 VX3,VX1
			from trx0008 a with (nolock)
			JOIN trx0008 m with (nolock) ON a.imaincaseid=m.imaincaseid
			JOIN FOBJ3025 c with (nolock) ON c.idomid=1 AND m.icaseid=c.iobjid AND c.silogtype=153
			WHERE a.icaseid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.caseid#">
			ORDER BY m.icaseid DESC
			</cfquery>
			<cfif q_sub.recordcount GT 0 AND q_sub.VX3 NEQ ""><cfset MAILTO=#q_sub.VX3#></cfif>
			<cfif q_sub.recordcount GT 0 AND q_sub.VX1 NEQ ""><cfset VX1_CTXT=#q_sub.VX1#></cfif>
		</cfif>
		<CFSET results={CTXT=VX1_CTXT,MAILTO=mailto}>
	</cfif>
	<CFRETURN results>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRSGTOKIOWICA_GetDefaultPaymentEmailContent=MTRSGTOKIOWICA_GetDefaultPaymentEmailContent>

<cffunction name="MTRGetClaimantType" description="Get Claimant Type for claim type" access="public" returntype="string">
	<cfargument name="claimtype" type="string" required="true">
	<cfargument name="subclmtypemask" type="numeric" required="false" default=0>
	<!--- 23426 Add BI as Injured --->
	<cfif CLMTYPE IS "NM TR">
		<cfset cmttype="IC"><!--- injured/claimant --->
	<cfelseif CLMTYPE IS "TP BI" OR CLMTYPE IS "BI" OR CLMTYPE IS "NM HS" OR CLMTYPE IS "NM PA" OR CLMTYPE IS "NM WC" OR (CLMTYPE IS "NM LB" AND subclmtypemask GT 0 AND BITAND(subclmtypemask,2) IS 2)>
		<cfset cmttype="I"><!--- injured --->
	<cfelse>
		<cfset cmttype="C"><!--- claimant --->
	</cfif>
	<cfreturn cmttype>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRGetClaimantType=MTRGetClaimantType>

<cffunction name="MTRGetTypeofClaim" description="Show Lists of selected type of claim" access="public" returntype="string">
	<cfargument name="INSGCOID" type="numeric" required="true">
	<cfargument name="claimtype" type="string" required="true">
	<cfargument name="index" type="numeric" required="true">

	<cfset thelist="">
	<cfif structkeyexists(request.ds.typeofclm,claimtype)>
		<CFIF structkeyexists(request.ds.typeofclm[claimtype],"coid") AND structkeyexists(request.ds.typeofclm[claimtype].coid,INSGCOID)>
			<cfset thistypeofclm_list=request.ds.typeofclm[claimtype].coid[INSGCOID].list>
			<cfset thistypeofclm_obj=request.ds.typeofclm[claimtype].coid[INSGCOID].typeclm>
		<cfelseif structkeyexists(request.ds.typeofclm[claimtype],"list")>
			<cfset thistypeofclm_list=request.ds.typeofclm[claimtype].list>
			<cfset thistypeofclm_obj=request.ds.typeofclm[claimtype].typeclm>
		<cfelse>
			<cfset thistypeofclm_list="">
			<cfset thistypeofclm_obj="">
		</cfif>
		<cfloop list="#thistypeofclm_list#" index="typeclm_idx">
			<cfif BITAND(index,typeclm_idx) GT 0>
				<cfset thelist=LISTAPPEND(thelist,thistypeofclm_obj[typeclm_idx].name,";")>
			</cfif>
		</cfloop>
	</cfif>
	<cfreturn thelist>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRGetTypeofClaim=MTRGetTypeofClaim>

<cffunction name="MTRCmtSetCounter" description="" access="public" returntype="numeric">
	<cfargument name="coid" type="numeric" required="true">
	<cfargument name="type" type="numeric" required="true">

	<cfstoredproc PROCEDURE="sspCMTSetCounter" DATASOURCE=#Request.MTRDSN# RETURNCODE=YES>
	<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#coid# DBVARNAME=@ai_gcoid>
	<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_SMALLINT VALUE=#type# DBVARNAME=@asi_type>
	</cfstoredproc>
	<cfset returncode=CFSTOREDPROC.STATUSCODE>
	<cfif returncode LT 0><cfthrow TYPE="EX_DBERROR" ErrorCode="CF/MTRCmtSetCounter(#returncode#)"></cfif>
	<cfreturn returncode>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRCmtSetCounter=MTRCmtSetCounter>

<cffunction name="MTRGetPolCoverName" description="" access="public" returntype="string" output="no">
	<cfargument name="PolCoverID" type="numeric" required="true">
	<cfargument name="LocID" type="numeric" required="false" default="0">
	<cfargument name="GCOID" type="numeric" required="false" default="0">
	<CFSET var retstr="">
	<CFIF Arguments.LOCID LTE 0>
		<CFSET Arguments.LOCID=SESSION.VARS.LOCID>
	</CFIF>
	<CFIF Arguments.GCOID LTE 0>
		<CFSET Arguments.GCOID=SESSION.VARS.GCOID>
	</CFIF>
	<CFIF Arguments.PolCoverID IS 1>
		<CFIF Arguments.LocID IS 4 OR Arguments.LocID IS 8>
			<CFSET retstr=Server.SVClang("Package",2991)>
		<CFELSEIF Arguments.LocID IS 6 OR Arguments.LocID IS 9>
			<CFSET retstr=Server.SVClang("Private Motor",7027)>
		<CFELSEIF Arguments.LocID is 11 AND NOT(Arguments.GCOID IS 1100002)>
			<CFSET retstr=Server.SVClang("1st Class",17200)>
		<CFELSE>
			<CFSET retstr=Server.SVClang("Comprehensive",2992)>
		</CFIF>

	<CFELSEIF Arguments.PolCoverID IS 2>
		<CFIF Arguments.LocID IS 6 OR Arguments.LocID IS 7
           OR Arguments.LocID IS 9 OR Arguments.LocID IS 2>
            <CFSET retstr=Server.SVClang("Third Party Only",7028)>
		<CFelseIF Arguments.LocID IS 11 AND NOT(Arguments.GCOID IS 1100002)>
            <CFSET retstr=Server.SVClang("3rd Class",17201)>
        <cfelse>
            <CFSET retstr=Server.SVClang("Third Party",1210)>
        </cfif>

	<CFELSEIF Arguments.PolCoverID IS 3>
		<CFSET retstr=Server.SVClang("Act Only",2993)>
	<CFELSEIF Arguments.PolCoverID IS 4>
		<CFSET retstr=Server.SVClang("Trade Plate",2994)>
	<CFELSEIF Arguments.PolCoverID IS 5>
		<CFSET retstr=Server.SVClang("Garage",2936)>
	<CFELSEIF Arguments.PolCoverID IS 6>
		<CFIF Arguments.LocID IS 11 AND NOT(Arguments.GCOID IS 1100002)>
            <CFSET retstr=Server.SVClang("2nd Class",17202)>
		<cfelseif Arguments.LocID IS 14>
			<CFSET retstr=Server.SVCLang("Fix OD",31859)> <!--- #19596 --->
		<cfelseif Arguments.LocID IS 11 AND Arguments.GCOID IS 1100002>
			<CFSET retstr=Server.SVClang("Third Party Fire Theft",37135)>
    <cfelse>
      <CFSET retstr=Server.SVClang("TP, Fire & Theft",6967)>
    </cfif>
    <CFELSEIF Arguments.PolCoverID IS 7>
		<CFSET retstr=Server.SVClang("Comprehensive Premier",31860,-1)>
	<CFELSEIF Arguments.PolCoverID IS 8>
		<CFSET retstr=Server.SVClang("TPFT Premier",31861,-1)>
	<CFELSEIF Arguments.PolCoverID IS 10>
		<CFSET retstr=Server.SVClang("Transit",2995)>
	<CFELSEIF Arguments.PolCoverID IS 12>
		<CFSET retstr=Server.SVClang("Total Loss Only",7029)>
	<CFELSEIF Arguments.PolCoverID IS 13>
		<CFSET retstr=Server.SVClang("Commercial Vehicle",7030)>
	<CFELSEIF Arguments.PolCoverID IS 14>
		<CFSET retstr=Server.SVClang("Motorcycle",1292)>
	<CFELSEIF Arguments.PolCoverID IS 16>
		<CFSET retstr=Server.SVClang("Comprehensive w/o TP",7032)>
	<CFELSEIF Arguments.PolCoverID IS 20>
		<CFSET retstr=Server.SVClang("TLO + TP",9180)>
	<CFELSEIF Arguments.PolCoverID IS 21>
		<CFSET retstr=Server.SVClang("Extended Warranty",5815)>
	<CFELSEIF Arguments.PolCoverID IS 30>
		<!--- #20400 --->
		<CFIF Arguments.GCOID IS 700527>
			<CFSET retstr=Server.SVClang("MOP",31862)>
		<CFELSE>
			<CFSET retstr=Server.SVClang("MOC",9181)>
		</CFIF>

	<CFELSEIF Arguments.PolCoverID IS 31>
		<CFSET retstr=Server.SVClang("Single Voyage",13335)>
	<CFELSEIF Arguments.PolCoverID IS 32 AND Arguments.GCOID NEQ 1100001>
		<CFSET retstr=Server.SVClang("5th Class (3+)",17203)>
	<CFELSEIF Arguments.PolCoverID IS 32 AND Arguments.GCOID EQ 1100001>
		<CFSET retstr=Server.SVClang("5th Class",25242)>
	<CFELSEIF Arguments.PolCoverID IS 33>
		<CFSET retstr=Server.SVClang("5th Class (2+)",17204)>
	<CFELSEIF Arguments.PolCoverID IS 34>
		<CFSET retstr=Server.SVClang("Compulsory",12552)>
	<CFELSEIF Arguments.PolCoverID IS 35>
		<CFSET retstr=Server.SVClang("VTPL",31863)>
	<CFELSEIF Arguments.PolCoverID IS 36>
		<CFIF Arguments.LocID IS 11 AND Arguments.GCOID IS 1100002>
			<CFSET retstr=Server.SVClang("Standalone CTPL",37136)>
		<CFELSE>
			<CFSET retstr=Server.SVClang("CTPL",31864)>
		</CFIF>
	<CFELSEIF Arguments.PolCoverID IS 37>
		<CFSET retstr=Server.SVClang("TPO EcoChoice 3+",37137)>
	<CFELSEIF Arguments.PolCoverID IS 38>
		<CFSET retstr=Server.SVClang("TPFT EcoChoice 2+",37138)>
	<CFELSEIF Arguments.PolCoverID IS 39>
		<CFSET retstr=Server.SVClang("Comprehensive Happy Choice",37139)>
	<CFELSEIF Arguments.PolCoverID IS 40>
		<CFSET retstr=Server.SVClang("Third Party Fire Theft Flat Ra",37140)>
	<CFELSEIF Arguments.PolCoverID IS 41>
		<CFSET retstr=Server.SVClang("TPO Flat Rate",37141)>
	<CFELSEIF Arguments.PolCoverID IS 42>
		<CFSET retstr=Server.SVClang("TPO EcoChoice Extra 3+",37142)>
	<CFELSEIF Arguments.PolCoverID IS 43>
		<CFSET retstr=Server.SVClang("TPFT EcoChoice Extra 2+",37143)>
	<CFELSEIF Arguments.PolCoverID IS 44>
		<CFSET retstr=Server.SVClang("LOU",37144)>
	<CFELSEIF Arguments.PolCoverID IS 49>
		<CFSET retstr=Server.SVClang("Own property Damage",40102)>
	<CFELSEIF Arguments.PolCoverID IS 50>
		<CFSET retstr=Server.SVClang("Driver and Passengers",40103)>
	<CFELSEIF Arguments.PolCoverID IS 51>
		<CFSET retstr=Server.SVClang("Material own damage",40104)>
	<CFELSEIF Arguments.PolCoverID IS 52>
		<CFSET retstr=Server.SVClang("Material own damage of Military vehicles",40105)>
	<CFELSEIF Arguments.PolCoverID IS 74>
		<CFSET retstr=Server.SVClang("TP Cover",48552)>
	<CFELSEIF Arguments.PolCoverID IS 78> <!--- 43850 ziv --->
		<CFSET retstr=Server.SVClang("Stela Wheels - PA",0)>
	<CFELSEIF Arguments.PolCoverID IS 79> <!--- 43850 ziv --->
		<CFSET retstr=Server.SVClang("Stela Wheels - Casualty",0)>
	<CFELSEIF Arguments.PolCoverID IS 81>  
		<CFSET retstr=Server.SVClang("Annual",0)>
	<CFELSEIF Arguments.PolCoverID IS 82>  
		<CFSET retstr=Server.SVClang("Multi-Year",0)>
	<CFELSE>
		<CFSET retstr=Arguments.PolCoverID>
	</CFIF>
	<cfreturn Trim(retstr)>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRGetPolCoverName=MTRGetPolCoverName>
<!--- <cffunction name="MTRGetOccList" returntype="string" output=no><!--- get occupation list --->
	<cfargument name="igcoid" type="numeric" required="false" default=0>
	<cfargument name="clmtype" type="string" required="false" default="">
	<cfif Isdefined("Request.DS.OCCUPATIONLIST")>
		<cfif igcoid NEQ "" AND StructKeyExists(Request.DS.OCCUPATIONLIST,igcoid)>
			<cfif clmtype NEQ "" AND StructKeyExists(Request.DS.OCCUPATIONLIST[igcoid],"clmtype")>
				<cfif clmtype NEQ "" AND StructKeyExists(Request.DS.OCCUPATIONLIST[igcoid].clmtype,clmtype)>
					<cfset returncode=#Request.DS.OCCUPATIONLIST[igcoid].clmtype[clmtype].list#>
				<cfelseif StructKeyExists(Request.DS.OCCUPATIONLIST[igcoid],"list")>
					<cfset returncode=#Request.DS.OCCUPATIONLIST[igcoid].list#>
				<cfelse>
					<cfset returncode="">
				</cfif>
			<cfelseif StructKeyExists(Request.DS.OCCUPATIONLIST[igcoid],"list")><!--- no clmtype provided --->
				<cfset returncode=#Request.DS.OCCUPATIONLIST[igcoid].list#>
			<cfelse>
				<cfset returncode="">
			</cfif>
		<cfelseif StructKeyExists(Request.DS.OCCUPATIONLIST,0) AND StructKeyExists(Request.DS.OCCUPATIONLIST[0],"list")><!--- no clmtype provided --->
			<cfset returncode=#Request.DS.OCCUPATIONLIST[0].list#>
		<cfelse>
			<cfset returncode="">
		</cfif>

		<cfif returncode IS "" AND StructKeyExists(Request.DS.OCCUPATIONLIST,0) AND StructKeyExists(Request.DS.OCCUPATIONLIST[0],"list")>
			<cfset returncode=#Request.DS.OCCUPATIONLIST[0].list#>
		</cfif>
	<cfelse>
		<cfset returncode="">
	</cfif>
	<cfreturn returncode>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRGetOccList=MTRGetOccList> --->

<cffunction name="MTRGenTPCalc" description="" access="public" returntype="struct">
<cfargument name="tpcosts" type="struct" required="true">
<cfargument name="st" type="query" required="true">
<cfargument name="locid" type="string" required="false">
<cfargument name="lang" type="string" required="false">
<cfargument name="curr" type="string" required="true">
<cfargument name="curtot" type="numeric" required="true">
<cfargument name="nliablepc" type="numeric" required="true">
<cfargument name="iliabflag" type="numeric" required="true">
<cfargument name="iliabflagignore" type="numeric" required="false" default=0>
<cfargument name="dispmode" type="numeric" required="true">
<cfargument name="colspan" type="numeric" required="false" default=1>
<cfargument name="colclass" type="string" required="false" default="">
	<CFSET CNT=0>
	<CFIF locid IS ""><CFSET locid=Application.APPLOCID></CFIF>
	<CFSET LOCALE=Request.DS.LOCALES[locid]>
	<CFSET VATTAXNAME=Server.SVClang(LOCALE.VATTAXNAME,LOCALE.VATTAXNAME_LID)>
	<CFIF StructKeyExists(st, "icaseid")><!--- #26423: Modify to change "GST" to "SST" wording --->
		<CFSET CASEID=#st.icaseid#>
		<CFIF request.ds.mtrfn.MTRGSTsupportingConditions(CASEID) AND request.ds.mtrfn.MTRGSTcalcmodel(CASEID) eq "GST">
			<CFIF VATTAXNAME IS "">
				<CFSET VATTAXNAME="GST">
			</CFIF>
		<CFELSEIF request.ds.mtrfn.MTRGSTcalcmodel(CASEID) eq "SST">
			<CFSET VATTAXNAME="SST">
		<CFELSE>
			<CFSET VATTAXNAME="">
		</CFIF>
	<CFELSE>
		<CFIF VATTAXNAME IS "">
			<CFSET VATTAXNAME="GST">
		</CFIF>
	</CFIF>
	<CFSET VATTAXNAME_LP="Including GST"><!--- LONPAC #16271--->
	<CFSET lang=Trim(UCase(lang))>
	<CFIF lang IS "SESSLANG"><CFSET lang=SESSION.VARS.SESSLANG><CFELSEIF lang IS "APPLANG"><CFSET lang=Application.APPLANG></CFIF>
	<CFIF nliablepc IS ""><CFSET nliablepc=100></CFIF>
	<CFIF dispmode IS 4 OR dispmode IS 5 OR dispmode IS 6 OR dispmode IS 7><CFSET costtot = 0></CFIF>
<CFLOOP INDEX=i FROM=0 TO=1>
	<CFLOOP LIST=#tpcosts.BitMaskList# index=b>
		<CFIF BitAnd(b,iliabflagignore) IS 0 AND ((i IS 0 AND BitAnd(iliabflag,b) IS b) OR (i IS 1 AND BitAnd(iliabflag,b) IS 0))>
			<CFSET COLNAME=StructFind(tpcosts,b).c>
			<CFIF COLNAME IS "" OR COLNAME IS "NULL">
				<CFSET amt=Evaluate("st.#StructFind(tpcosts,b).rd#*st.#StructFind(tpcosts,b).rr#")>
			<CFELSE>
				<CFSET amt=Evaluate("st.#colname#")>
			</CFIF>
			<CFIF amt GT 0>
				<CFIF i EQ 0 AND CNT EQ 0>
					<CFIF dispmode IS 4>
					<tr><td valign=baseline<CFIF Len(colclass) GT 0> class="#colclass#"</CFIF><CFIF colspan GT 1> colspan=#colspan#</CFIF>>Liable Costs:</td><td>&nbsp;</td></tr>
					<UL>
					<CFELSEIF dispmode IS 5>
					<CFOUTPUT><tr><td<CFIF Len(colclass) GT 0> class="#colclass#"</CFIF> <CFIF colspan GT 1> colspan=#colspan#</CFIF>>Liable Costs</td><td align=right>&nbsp;</td></tr></CFOUTPUT>
					<CFELSEIF dispmode IS 6>
					<CFOUTPUT><tr><td>&nbsp;</td><td<CFIF Len(colclass) GT 0> class="#colclass#"</CFIF> <CFIF colspan GT 1> colspan=#colspan#</CFIF>>Liable Costs:</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr></CFOUTPUT>
					</CFIF>
				</CFIF>
				<CFSET DSC=StructFind(tpcosts,b).n><!--- Take care of language later --->
				<CFIF b IS 8 AND (LOCID IS 1 OR LOCID IS 5)><CFSET DSC="CART"></CFIF><!--- Override Loss-of-Use for Malaysia --->
				<CFIF dispmode IS 1>
					<CFOUTPUT><tr><td<CFIF Len(colclass) GT 0> class="#colclass#"</CFIF> <CFIF colspan GT 1> colspan=#colspan#</CFIF>>+ #DSC#:</td><td align=right>#curr##FN.SVCNum(amt)#</td><CFIF StructKeyExists(StructFind(tpcosts,b),"RD") AND Evaluate("st.#StructFind(tpcosts,b).rd#") GT 0><td>(#FN.SVCnum(Evaluate("st."&StructFind(tpcosts,b).rd),1)# x #curr##FN.SVCNum(Evaluate("st.#StructFind(tpcosts,b).rr#"))##Server.SVClang("/day",3644)#<CFIF StructKeyExists(StructFind(tpcosts,b),"RV") AND Evaluate("st.#StructFind(tpcosts,b).RV#") GT 0> + #FN.SVCNum(Evaluate("st.#StructFind(tpcosts,b).rv#"))#% #VATTAXNAME#</CFIF>)</td></CFIF></tr></CFOUTPUT>
				<CFELSEIF dispmode IS 2>
					<CFOUTPUT><tr><td<CFIF Len(colclass) GT 0> class="#colclass#"</CFIF> <CFIF colspan GT 1> colspan=#colspan#</CFIF>>+ #DSC#<CFIF StructKeyExists(StructFind(tpcosts,b),"RD") AND Evaluate("st.#StructFind(tpcosts,b).rd#") GT 0> (#FN.SVCnum(Evaluate("st."&StructFind(tpcosts,b).rd),1)# x #curr##FN.SVCNum(Evaluate("st.#StructFind(tpcosts,b).rr#"))##Server.SVClang("/day",3644)#<CFIF StructKeyExists(StructFind(tpcosts,b),"RV") AND Evaluate("st.#StructFind(tpcosts,b).RV#") GT 0> + #FN.SVCNum(Evaluate("st.#StructFind(tpcosts,b).rv#"))#% #VATTAXNAME#</CFIF>)</CFIF> (#curr#)</td><td align=right>#FN.SVCNum(amt)#</td></tr></CFOUTPUT>
				<CFELSEIF dispmode IS 3>
					<CFOUTPUT><tr><td>&nbsp;</td><td<CFIF Len(colclass) GT 0> class="#colclass#"</CFIF> <CFIF colspan GT 1> colspan=#colspan#</CFIF>>#DSC#<CFIF StructKeyExists(StructFind(tpcosts,b),"RD") AND Evaluate("st.#StructFind(tpcosts,b).rd#") GT 0> (#FN.SVCnum(Evaluate("st."&StructFind(tpcosts,b).rd),1)# days x #curr##FN.SVCNum(Evaluate("st.#StructFind(tpcosts,b).rr#"))##Server.SVClang("/day",3644)#<CFIF StructKeyExists(StructFind(tpcosts,b),"RV") AND Evaluate("st.#StructFind(tpcosts,b).RV#") GT 0> + #FN.SVCNum(Evaluate("st.#StructFind(tpcosts,b).rv#"))#% #VATTAXNAME#</CFIF>)</CFIF></td><td align="center">:</td><td>#curr#</td><td align=right>#FN.SVCNum(amt)#</td></tr></CFOUTPUT>
				<CFELSEIF dispmode IS 4>
					<CFOUTPUT><tr><td<CFIF Len(colclass) GT 0> class="#colclass#"</CFIF> <CFIF colspan GT 1> colspan=#colspan#</CFIF>><CFIF i IS 1>+ #DSC#:<CFELSE><LI>#DSC#:</LI></CFIF></td><td align=right>#curr##FN.SVCNum(amt)#</td><CFIF StructKeyExists(StructFind(tpcosts,b),"RD") AND Evaluate("st.#StructFind(tpcosts,b).rd#") GT 0><td>(#FN.SVCnum(Evaluate("st."&StructFind(tpcosts,b).rd),1)# x #curr##FN.SVCNum(Evaluate("st.#StructFind(tpcosts,b).rr#"))##Server.SVClang("/day",3644)#<CFIF StructKeyExists(StructFind(tpcosts,b),"RV") AND Evaluate("st.#StructFind(tpcosts,b).RV#") GT 0> + #FN.SVCNum(Evaluate("st.#StructFind(tpcosts,b).rv#"))#% #VATTAXNAME#</CFIF>)</td></CFIF></tr></CFOUTPUT>
				<CFELSEIF dispmode IS 5>
					<CFOUTPUT><tr><td<CFIF Len(colclass) GT 0> class="#colclass#"</CFIF> <CFIF colspan GT 1> colspan=#colspan#</CFIF>><CFIF i IS 1>+ #DSC#:<CFELSE><LI>#DSC#:</LI></CFIF><CFIF StructKeyExists(StructFind(tpcosts,b),"RD") AND Evaluate("st.#StructFind(tpcosts,b).rd#") GT 0> (#FN.SVCnum(Evaluate("st."&StructFind(tpcosts,b).rd),1)# x #curr##FN.SVCNum(Evaluate("st.#StructFind(tpcosts,b).rr#"))##Server.SVClang("/day",3644)#<CFIF StructKeyExists(StructFind(tpcosts,b),"RV") AND Evaluate("st.#StructFind(tpcosts,b).RV#") GT 0> + #FN.SVCNum(Evaluate("st.#StructFind(tpcosts,b).rv#"))#% #VATTAXNAME#</CFIF>)</CFIF> (#curr#)</td><td align=right>#FN.SVCNum(amt)#</td></tr></CFOUTPUT>
				<CFELSEIF dispmode IS 6>
					<CFOUTPUT><tr><td>&nbsp;</td><td<CFIF Len(colclass) GT 0> class="#colclass#"</CFIF> <CFIF colspan GT 1> colspan=#colspan#</CFIF>><CFIF i IS 1>+ #DSC#:<CFELSE>&nbsp;--&nbsp;#DSC#:</CFIF><CFIF StructKeyExists(StructFind(tpcosts,b),"RD") AND Evaluate("st.#StructFind(tpcosts,b).rd#") GT 0> (#FN.SVCnum(Evaluate("st."&StructFind(tpcosts,b).rd),1)# x #curr##FN.SVCNum(Evaluate("st.#StructFind(tpcosts,b).rr#"))##Server.SVClang("/day",3644)#<CFIF StructKeyExists(StructFind(tpcosts,b),"RV") AND Evaluate("st.#StructFind(tpcosts,b).RV#") GT 0> + #FN.SVCNum(Evaluate("st.#StructFind(tpcosts,b).rv#"))#% #VATTAXNAME#</CFIF>)</CFIF></td><td align="center">:</td><td>#curr#</td><td align=right>#FN.SVCNum(amt)#</td></tr></CFOUTPUT>
				<CFELSEIF dispmode IS 7><!--- LONPAC #16271--->
					<CFOUTPUT><tr><td>&nbsp;</td><td<CFIF Len(colclass) GT 0> class="#colclass#"</CFIF> <CFIF colspan GT 1> colspan=#colspan#</CFIF>>#DSC#<CFIF StructKeyExists(StructFind(tpcosts,b),"RD") AND Evaluate("st.#StructFind(tpcosts,b).rd#") GT 0> (#FN.SVCnum(Evaluate("st."&StructFind(tpcosts,b).rd),1)# x #curr##FN.SVCNum(Evaluate("st.#StructFind(tpcosts,b).rr#"))##Server.SVClang("/day",3644)#)</CFIF></td><td align="center">:</td><td>#curr#</td><td align=right>#FN.SVCNum(amt)#</td><td><!--- <CFIF StructKeyExists(StructFind(tpcosts,b),"GST")> (#VATTAXNAME_LP#)</CFIF><CFIF StructKeyExists(StructFind(tpcosts,b),"RV") AND Evaluate("st.#StructFind(tpcosts,b).RV#") GT 0>(#VATTAXNAME_LP#)</CFIF> --->&nbsp;</td></tr></CFOUTPUT>
				</CFIF>
				<CFIF (dispmode IS 4 OR dispmode IS 5 OR dispmode IS 6) AND i IS 0>
					<CFSET costtot += amt>
				<CFELSE>
					<CFSET curtot=curtot+amt>
				</CFIF>

				<CFSET CNT=CNT+1>
			</CFIF>
		</CFIF>
	</CFLOOP>
	<CFIF dispmode IS 4>
		</UL>
	</CFIF>
	<cfif i IS 0 AND nLIABLEPC IS NOT "" AND nLIABLEPC LT 100>
		<CFIF CNT GT 0>
			<CFIF dispmode IS 3 OR dispmode IS 6 OR dispmode IS 7>
				<CFOUTPUT><tr style=line-height:2px><td>&nbsp;</td><td <CFIF colspan GT 1> colspan=#colspan#</CFIF>>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td style="border-bottom:1px solid black">&nbsp;</td></tr>
				<tr><td width=10%>&nbsp;</td><td <CFIF colspan GT 1> colspan=#colspan#</CFIF>>&nbsp;</td><td align="center">:</td><td>#curr#</td><td align=right><CFIF dispmode IS 3>#FN.SVCNum(CURTOT)#<CFELSE>#FN.SVCNum(costtot)#</CFIF></td><td width=20%></td></tr></CFOUTPUT>
			<CFELSEIF dispmode IS 4 OR dispmode IS 5>
				<CFOUTPUT><tr style=line-height:2px><td<CFIF colspan GT 1> colspan=#colspan#</CFIF>>&nbsp;</td><td style="border-bottom:1px solid black">&nbsp;</td></tr>
				<tr><td<CFIF Len(colclass) GT 0> class="#colclass#"</CFIF><CFIF colspan GT 1> colspan=#colspan#</CFIF>><CFIF dispmode IS 5> (#curr#)</CFIF></td><td align=right><CFIF dispmode IS 4>#curr#</CFIF>#FN.SVCNum(costtot)#</td><td></td></tr></CFOUTPUT>
			<CFELSE>
				<CFOUTPUT><tr style=line-height:2px><td<CFIF colspan GT 1> colspan=#colspan#</CFIF>>&nbsp;</td><td style="border-bottom:1px solid black">&nbsp;</td></tr>
				<tr><td<CFIF Len(colclass) GT 0> class="#colclass#"</CFIF><CFIF colspan GT 1> colspan=#colspan#</CFIF>><CFIF dispmode IS 2> (#curr#)</CFIF></td><td align=right><CFIF dispmode IS 1>#curr#</CFIF>#FN.SVCNum(CURTOT)#</td><td></td></tr></CFOUTPUT>
			</CFIF>
		</CFIF>
		<CFSET CNT=0.5>
		<CFIF dispmode IS 4 OR dispmode IS 5 OR dispmode IS 6>
		<cfset CURTOT+=FN.SVCnumDBround(nLIABLEPC*costtot/100)>
		<CFELSE>
		<cfset CURTOT=FN.SVCnumDBround(nLIABLEPC*CURTOT/100)>
		</CFIF>
		<CFIF dispmode IS 3 OR dispmode IS 7>
			<CFOUTPUT><tr style=line-height:2px><td>&nbsp;</td><td <CFIF colspan GT 1> colspan=#colspan#</CFIF>>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td style="border-bottom:1px solid black">&nbsp;</td></tr>
			<tr><td width=10%>&nbsp;</td><td valign=baseline<CFIF Len(colclass) GT 0> class="#colclass#"</CFIF><CFIF colspan GT 1> colspan=#colspan#</CFIF>>Liable Amount (#FN.SVCNum(nLIABLEPC,2)#%)</td><td align="center">:</td><td>#curr#</td><td align=right>#FN.SVCNum(CURTOT)#</td><td width=20%></td></tr></CFOUTPUT>
		<CFELSEIF dispmode IS 6>
			<CFOUTPUT><tr><td width=10%>&nbsp;</td><td valign=baseline<CFIF Len(colclass) GT 0> class="#colclass#"</CFIF><CFIF colspan GT 1> colspan=#colspan#</CFIF>>+ Liable Costs Amount (#FN.SVCNum(nLIABLEPC,2)#%)</td><td align="center">:</td><td>#curr#</td><td align=right>#FN.SVCNum(nLIABLEPC*costtot/100)#</td><td width=20%></td></tr>
			<tr style=line-height:2px><td>&nbsp;</td><td <CFIF colspan GT 1> colspan=#colspan#</CFIF>>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td style="border-bottom:1px solid black">&nbsp;</td></tr>
			<tr><td width=10%>&nbsp;</td><td valign=baseline<CFIF Len(colclass) GT 0> class="#colclass#"</CFIF><CFIF colspan GT 1> colspan=#colspan#</CFIF>>Gross Offer with Liable Costs</td><td align="center">:</td><td>#curr#</td><td align=right>#FN.SVCNum(CURTOT)#</td><td width=20%></td></tr></CFOUTPUT>
		<CFELSEIF dispmode IS 4 OR dispmode IS 5>
			<CFOUTPUT><tr><td valign=baseline<CFIF Len(colclass) GT 0> class="#colclass#"</CFIF><CFIF colspan GT 1> colspan=#colspan#</CFIF>>+ Liable Costs Amount (#FN.SVCNum(nLIABLEPC,2)#%)<CFIF dispmode IS 5> (#curr#)</CFIF></td><td style=font-weight:bold valign=baseline align=right><CFIF dispmode IS 4>#curr#</CFIF>#FN.SVCNum(nLIABLEPC*costtot/100)#</td></tr>
			<tr style=line-height:2px><td<CFIF colspan GT 1> colspan=#colspan#</CFIF>>&nbsp;</td><td style="border-bottom:1px solid black">&nbsp;</td></tr>
			<tr><td valign=baseline<CFIF Len(colclass) GT 0> class="#colclass#"</CFIF><CFIF colspan GT 1> colspan=#colspan#</CFIF>>Gross Offer with Liable Costs<CFIF dispmode IS 5> (#curr#)</CFIF></td><td style=font-weight:bold valign=baseline align=right><CFIF dispmode IS 4>#curr#</CFIF>#FN.SVCNum(CURTOT)#</td></tr></CFOUTPUT>
		<CFELSE>
			<CFOUTPUT><tr style=line-height:2px><td<CFIF colspan GT 1> colspan=#colspan#</CFIF>>&nbsp;</td><td style="border-bottom:1px solid black">&nbsp;</td></tr>
			<tr><td valign=baseline<CFIF Len(colclass) GT 0> class="#colclass#"</CFIF><CFIF colspan GT 1> colspan=#colspan#</CFIF>>Liable Amount (#FN.SVCNum(nLIABLEPC,2)#%)<CFIF dispmode IS 2> (#curr#)</CFIF></td><td style=font-weight:bold valign=baseline align=right><CFIF dispmode IS 1>#curr#</CFIF>#FN.SVCNum(CURTOT)#</td></tr></CFOUTPUT>
		</CFIF>
	</CFIF>
</CFLOOP>
<CFSET stret=StructNew()>
<CFSET stret.curtot=curtot>
<CFSET stret.cnt=cnt><!--- 0: no output, 0.5:got output but already tallied, just need to close,>=1:got to tally --->
<cfreturn stret>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRGenTPCalc=MTRGenTPCalc>

<cffunction name=MTRGenExcess output=yes>
	<cfargument name=DISPMODE type=numeric default=1><!--- 1:Excess field,2:OR field,4:Gross Claim % + Minimum,8:Excess waive field,16:In-car camera excess waiver,32:NCD excess waiver,64:Examiner Empowerment --->
	<cfargument name=CASEID type="string" default="">
	<cfargument name=CLMID type="string" default="">
	<cfargument name=CLOSETR type=numeric default=1>
	<cfargument name=CHKREQ type=numeric default=3><!--- 1:Excess,2:Incident Cnt --->
	<cfargument name=DISABLE type=numeric default=0><!--- 1:Excess,2:Incident Cnt --->
	<cfargument name=calcexc type=numeric default=0>
	<CFARGUMENT name="WAIVED" type="numeric" default="0"><!--- 1:waived checked, 0:uncheck --->
	<CFARGUMENT name=CUSTOM type="numeric" default="0"><!--- 0: load default layout,1: load custom layout  --->
	<cfargument name=COMPTYPE type=string default=""><!--- R:Repairer,I:Insurer,A:Adjuster --->
	<cfargument name=OVRDEXCNM type=string default=""><!--- overwrite excess name --->
	<cfargument name=nodisplayDXS type=numeric default="0">
	<cfargument name=suppCaseFlag type=numeric default="0">
	<!--- NOTE: Global Parameters - LOCALE,iDXSMODE,DXS,CINCIDENTCNT,siDXSCLMPC,DXSWAIVED --->

	<cfif NOT(isNumeric(CASEID) AND CASEID GT 0)><cfset CASEID=0></cfif>
	<cfif NOT(isNumeric(CLMID) AND CLMID GT 0)><cfset CLMID=0></cfif>
	<input type="hidden" id="preexclist" name="preexclist"  value="">
	<input type="hidden" id="preexcxml" name="preexcxml"  value="">
	<input type="hidden" id="intexclist" name="intexclist"  value="">
	<input type="hidden" id="intexcxml" name="intexcxml"  value="">
	<input type="hidden" id="othexcxml" name="othexcxml"  value="">
	<input type="hidden" id="othexcremlist" name="othexcremlist"  value="">
	<input type="hidden" id="savetot" name="savetot"  value="">
	<cfsilent>
	<cfset VEHUSG=""><cfset _L_INSGCOID=0><!--- Pc 2016-01-22: Renamed INSGCOID to _L_INSGCOID, to avoid override INSGCOID variable of parent module --->
	<cfif CASEID GT 0>
		<cfquery name="q_clm" DATASOURCE=#Request.MTRDSN#>
		SELECT a.icaseid, a.iLCLMID,VEHUSG=IsNull(e.vaVDUSAGE,'Private'),siCarCamExcsWaive,siNCDExcsWaive,siEXAMEMP, a.icoid from trx0008 a
		JOIN trx0055 e ON a.icaseid=e.icaseid
		WHERE a.icaseid IN (select imaincaseid FROM trx0008 where icaseid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CASEID#">) AND a.siTPINS=0
		</cfquery>
		<cfif q_clm.recordcount GT 0>
			<cfset CLMID=#q_clm.iLCLMID#>
			<cfset VEHUSG=#q_clm.VEHUSG#>
			<CFIF suppCaseFlag EQ 0> <!--- use main case id --->
				<cfset CASEID=#q_clm.icaseid#>
			</CFIF>
			<cfset _L_INSGCOID=#request.ds.co[q_clm.icoid].gcoid#>
		</cfif>
	<cfelseif CLMID GT 0>
		<cfquery name="q_clm" DATASOURCE=#Request.MTRDSN#>
		select icoid=IIGCOID from clm0001 with (nolock) WHERE iclmid=<cfqueryparam value="#CLMID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfif q_clm.recordcount GT 0><cfset VEHUSG="Private"><!--- default ---><cfset _L_INSGCOID=#request.ds.co[q_clm.icoid].gcoid#></cfif>
	<cfelse>
		<!--- set default --->
		<cfset CLMID=0><cfset CASEID=0><cfset _L_INSGCOID=0>
	</cfif>
	<!--- vehicle type --->
	<cfif VEHUSG EQ "Private"><cfset fvehtyp=1><cfelseif VEHUSG EQ "Commercial" or VEHUSG EQ "Hire & Reward"><cfset fvehtyp=2><cfelse><cfset fvehtyp=1></cfif>
	<CFSET DISABLEDLIST_info0=ArrayNew(1)><CFSET DISABLEDLIST_info1=ArrayNew(1)>

	<CFQUERY NAME=q_trx2 DATASOURCE=#Request.MTRDSN#>
	SELECT a.siSETTLETYPE, claimtype=RTRIM(a.aclaimtype), rsname=c.varulesetname
	FROM TRX0001 a with (nolock)
	LEFT JOIN TRX0035 b with (nolock) on a.icaseid=b.ilcaseid AND b.acotype='I'
	LEFT JOIN fitr0001 c with (nolock) on c.irulesetid=b.irulesetid
	where a.icaseid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CASEID#">
	</CFQUERY>

	<!--- query to get excess type / default amount from backend --->
	<cfif _L_INSGCOID IS 67 AND q_trx2.rsname IS "MYRHB-HSRMB">
		<CFQUERY NAME=q_excinfo0 DATASOURCE=#Request.MTRDSN#>
			SELECT a.iEXCESSID,a.vaEXCESSDESC,a.mnEXCESSAMT,IsNull(b.mnAMT,0)
			FROM CLM0012 a WITH (NOLOCK) JOIN TRX0008_EXCESS b WITH (NOLOCK) ON (a.iEXCESSID=b.iEXCESSID and b.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CASEID#"> AND a.siSTATUS=0 and b.siSTATUS=0 and b.siTYPE=0)
			WHERE a.vaEXCESSCODE IN ('RHB-GF','RHB-PMD','RHB-PHSSF','RHB-PHDP','RHB-EXS')
			order by CASE WHEN (a.vaEXCESSCODE='RHB-EXS') THEN 1 WHEN (a.vaEXCESSCODE='RHB-GF') THEN 2 WHEN (a.vaEXCESSCODE='RHB-PMD') THEN 3
			WHEN (a.vaEXCESSCODE='RHB-PHSSF') THEN 4 WHEN (a.vaEXCESSCODE='RHB-PHDP') THEN 5 ELSE 999 END
		</CFQUERY>

	<cfelseif CLMID GT 0>
		<CFQUERY NAME=q_excinfo0 DATASOURCE=#Request.MTRDSN#>
		SELECT a.iEXCESSID,a.vaEXCESSDESC,a.mnEXCESSAMT,IsNull(b.mnAMT,0)
		FROM CLM0012 a WITH (NOLOCK) LEFT JOIN  TRX0008_EXCESS b WITH (NOLOCK) ON (a.iEXCESSID=b.iEXCESSID and b.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CASEID#">
		AND a.siSTATUS=0 and b.siSTATUS=0 and b.siTYPE=0)
		WHERE a.iCLMID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CLMID#"> order by a.iEXCESSID asc
		</CFQUERY>

		<CFIF _L_INSGCOID IS 200045>
			<cfquery name=q_disableList0 dbtype=query>
				SELECT iEXCESSID from q_excinfo0 WHERE vaEXCESSDESC IN ('Own damage excess original')
			</cfquery>
			<cfif q_disableList0.recordcount gt 0>
				<CFSET DISABLEDLIST_info0=ListToArray(ValueList(q_disableList0.iEXCESSID))>
			</cfif>
		</CFIF>
	</cfif>

	<!--- query for predefined excess --->
	<!--- Excess list by company. Lisa adding on the hardcode--->
	<cfif CUSTOM EQ 1>

		<!--- voluntary excess only--->
		<cfset showexcessbreakdown = Request.DS.FN.SVCgetExtAttrLogic("COADMIN", 0, "COATTR200", 10, INSGCOID)>
		<CFIF _L_INSGCOID IS 67>
			<!--- CST(200045): tokio marine's predefined excess --->
			<CFQUERY NAME=q_excinfo1 DATASOURCE=#Request.MTRDSN#>
			IF OBJECT_ID('tempdb..##predefexcess') IS NOT NULL
			DROP TABLE tempdb..##predefexcess

			CREATE TABLE tempdb..##predefexcess
			(
				iEXCESSID int not null,
				vaDESC nvarchar(100) not null,
				mnAMT money null
			)
			INSERT INTO tempdb..##predefexcess values (1,'Registration / Admission Fee',null)
			INSERT INTO tempdb..##predefexcess values (2,'Medication charges more than 31 days',null)
			INSERT INTO tempdb..##predefexcess values (3,'Follow up charges under different doctor',null)
			INSERT INTO tempdb..##predefexcess values (4,'Post charges more than 31 days',null)
			INSERT INTO tempdb..##predefexcess values (5,'Pre medication/nursing/procedure charges',null)
			INSERT INTO tempdb..##predefexcess values (6,'Pre consulation more than 1 doctor',null)
			INSERT INTO tempdb..##predefexcess values (7,'GP Fee',null)
			INSERT INTO tempdb..##predefexcess values (8,'Telephone charges',null)

			SELECT a.iEXCESSID,a.vaDESC,a.mnAMT,IsNull(b.mnAMT,0)
			FROM tempdb..##predefexcess a WITH (NOLOCK) LEFT JOIN  TRX0008_EXCESS b WITH (NOLOCK) ON (a.iEXCESSID=b.iEXCESSID and b.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CASEID#">
			AND b.siSTATUS=0 and b.siTYPE=1) order by a.iEXCESSID asc
			</CFQUERY>
		<CFELSEIF INSGCOID IS 1402014>
			<CFQUERY NAME=q_excinfo1 DATASOURCE=#Request.MTRDSN#>
				SELECT a.iEXCESSID,a.vaDESC,a.mnAMT,isNULL(b.mnAMT,0)
				FROM
				(
					values
					(1,'Accidental Damage', null)
					,(2,'Unnamed Driver', null)
					,(3,'Theft', null)
					,(4,'Parking', null)
					,(5,'Inexperienced Driver', null)
					,(6,'Young Driver', null)
				) a (iexcessid,vadesc,mnamt)
				LEFT JOIN TRX0008_EXCESS b WITH (NOLOCK) ON (a.iEXCESSID=b.iEXCESSID and b.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CASEID#">
				AND b.siSTATUS=0 and b.siTYPE=1) order by a.iEXCESSID asc
			</CFQUERY>
		<CFELSEIF INSGCOID IS 200798 AND CLMFLOW eq 'OD'>
			<CFQUERY NAME=q_excinfo1 DATASOURCE=#Request.MTRDSN#>
				SELECT a.iEXCESSID,a.vaDESC,a.mnAMT,isNULL(b.mnAMT,0)
				FROM
				(
					values
					(1,'Basic Excess',500)
					,(2,'Voluntary Excess',0)
					,(3,'Young & Inexperienced Excess',2500)
				) a (iexcessid,vadesc,mnamt)
				LEFT JOIN TRX0008_EXCESS b WITH (NOLOCK) ON (a.iEXCESSID=b.iEXCESSID and b.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CASEID#">
				AND b.siSTATUS=0 and b.siTYPE=1) order by a.iEXCESSID asc
			</CFQUERY>
		<CFELSEIF session.vars.locid IS 10 AND LISTFIND("1000615,1000152", INSGCOID)><!--- #25853: [PH] MAA - Activate Breakdown of Claim Deductible (Excess) Feature --->
			<!--- custom breakdown deduction for TP BI is no longer required  #27748-note20 --->
			<!--- <CFIF q_trx2.claimtype EQ 'TP BI'><!--- #27748  --->
				<CFQUERY NAME=q_excinfo1 DATASOURCE=#Request.MTRDSN#>
						SELECT a.iEXCESSID,a.vaDESC,a.mnAMT,IsNull(b.mnAMT,0),a.nPERCENT,IsNull(b.npercent,0)
						FROM
						(values
							(1,'CTPL Apportionment', null, null)
							,(2,'Philhealth', null, 0)
						)a(iexcessid,vadesc,mnamt,npercent)
						LEFT JOIN  TRX0008_EXCESS b WITH (NOLOCK) ON (a.iEXCESSID=b.iEXCESSID and b.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CASEID#">
						AND b.siSTATUS=0 and b.siTYPE=1) order by a.iEXCESSID asc
				</CFQUERY>
			<CFELSE> --->
				<CFQUERY NAME=q_excinfo1 DATASOURCE=#Request.MTRDSN#>
						SELECT a.iEXCESSID,a.vaDESC,a.mnAMT,IsNull(b.mnAMT,0)
						FROM
						(values
							(1,'Policy Deductible', null)
						)a(iexcessid,vadesc,mnamt)
						LEFT JOIN  TRX0008_EXCESS b WITH (NOLOCK) ON (a.iEXCESSID=b.iEXCESSID and b.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CASEID#">
						AND b.siSTATUS=0 and b.siTYPE=1) order by a.iEXCESSID asc
				</CFQUERY>
			<!--- </CFIF> --->
		<cfelseif showexcessbreakdown eq 1>
			<CFQUERY NAME=q_excinfo1 DATASOURCE=#Request.MTRDSN#>
				SELECT a.iEXCESSID,a.vaDESC,a.mnAMT,IsNull(b.mnAMT,0)
				FROM
				(values
					(1,'Excess', null)
					,(2,'Voluntary Excess', null)
				)a(iexcessid,vadesc,mnamt)
				LEFT JOIN  TRX0008_EXCESS b WITH (NOLOCK) ON (a.iEXCESSID=b.iEXCESSID and b.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CASEID#">
				AND b.siSTATUS=0 and b.siTYPE=1) order by a.iEXCESSID asc
			</CFQUERY>
		</cfif>
	<CFELSE>
		<cfif CLMID GT 0 AND _L_INSGCOID IS 200045>
			<!--- CST(200045): tokio marine's predefined excess --->
			<CFQUERY NAME=q_excinfo1 DATASOURCE=#Request.MTRDSN#>
			IF OBJECT_ID('tempdb..##predefexcess') IS NOT NULL
			DROP TABLE tempdb..##predefexcess

			CREATE TABLE tempdb..##predefexcess
			(
				iEXCESSID int not null,
				vaDESC nvarchar(100) not null,
				mnAMT money not null
			)
			INSERT INTO tempdb..##predefexcess values (1,'Unnamed Drivers (Additional Excess)',500)
			<CFIF fvehtyp EQ 1>
			INSERT INTO tempdb..##predefexcess values (2,'Additional Excess for Young, Elderly or Inexperienced Drivers',3500)
			<CFELSE>
			INSERT INTO tempdb..##predefexcess values (2,'Additional Excess (All Claims) for Work Permit Holders, Young, Elderly or Inexperienced Drivers',2500)
			</CFIF>
			INSERT INTO tempdb..##predefexcess values (3,'Windscreen Excess',100)

			SELECT a.iEXCESSID,a.vaDESC,a.mnAMT,IsNull(b.mnAMT,0)
			FROM tempdb..##predefexcess a WITH (NOLOCK) LEFT JOIN  TRX0008_EXCESS b WITH (NOLOCK) ON (a.iEXCESSID=b.iEXCESSID and b.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CASEID#">
			AND b.siSTATUS=0 and b.siTYPE=1) order by a.iEXCESSID asc
			</CFQUERY>
		<CFELSEIF INSGCOID IS 69 AND q_trx2.claimtype IS "NM HS"> <!--- #20940 --->
			<CFQUERY NAME=q_excinfo1 DATASOURCE=#Request.MTRDSN#>
				IF OBJECT_ID('tempdb..##predefexcess') IS NOT NULL
				DROP TABLE tempdb..##predefexcess

				CREATE TABLE tempdb..##predefexcess
				(
					iEXCESSID int not null,
					vaDESC nvarchar(100) not null,
					mnAMT money null
				)
				INSERT INTO tempdb..##predefexcess values (1,'Co-pay',null)

				SELECT a.iEXCESSID,a.vaDESC,a.mnAMT,IsNull(b.mnAMT,0)
				FROM tempdb..##predefexcess a WITH (NOLOCK) LEFT JOIN  TRX0008_EXCESS b WITH (NOLOCK) ON (a.iEXCESSID=b.iEXCESSID and b.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CASEID#">
				AND b.siSTATUS=0 and b.siTYPE=1) order by a.iEXCESSID asc
			</CFQUERY>
		</cfif>
	</cfif>
	<CFQUERY NAME=q_excinfo2 DATASOURCE=#Request.MTRDSN#>
		SELECT iEXCESSID,vaDESC,mnAMT
		FROM TRX0008_EXCESS WITH (NOLOCK)
		WHERE iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CASEID#"> AND siSTATUS=0 AND siTYPE=2 order by iEXCESSID asc
	</CFQUERY>

	<!--- Disabling INCIDENTCNT and DXS field when DXSMODE!=1
	1 - pass disable value when calling MTRGenExcess | 1:Excess,2:Incident Cnt
	2 - set setDisINCDNTCNTDXS=1 , this will skip JSVCSetDisabledList("INCIDENTCNT,DXS",false); in OnXSChg() from mclm.js
	--->
	<CFIF (COMPTYPE EQ "R" AND _L_INSGCOID EQ 1000001) OR (COMPTYPE EQ "R" AND _L_INSGCOID EQ 7651) OR (_L_INSGCOID EQ 1000152 AND (q_trx2.claimtype EQ 'TP' OR q_trx2.claimtype EQ 'TP PD' OR q_trx2.claimtype EQ 'TP BI') OR _L_INSGCOID EQ 1100002)><!--- #20189 Disabling Excess and Incident Count for BPI/MS on Repairer Screen--->
		<CFSET setDisINCDNTCNTDXS=1>
	<CFELSE>
		<CFSET setDisINCDNTCNTDXS=0>
	</CFIF>

	</cfsilent>
	<cfset FN=Request.DS.FN>

	<CFIF OVRDEXCNM NEQ "">
		<CFSET EXCESSNAME=OVRDEXCNM>
	<CFELSE>
		<CFSET EXCESSNAME=Server.SVClang(LOCALE.EXCESSNAME,LOCALE.EXCESSNAME_LID)>
	</CFIF>
	<tbody id="INSEXCESS">
	<cfset currencyText="#request.DS.FN.CurrencyType()#">
	<cfif locid IS 11>
		<cfset currencyText="#Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)#">
	</cfif>
	<CFIF FN.SVCGetResp()>
		<div><div valign=top>#EXCESSNAME#<cfif BitAnd(DISPMODE,2) IS 0> (<label CURRSYM>#request.DS.FN.CurrencyType()#</label>)</cfif></div><div>
	<CFELSE>
		<tr><td valign=top>#EXCESSNAME#<cfif BitAnd(DISPMODE,2) IS 0> (<label CURRSYM>#currencyText#</label>)</cfif></td><td colspan=<cfif BitAnd(DISPMODE,2) IS 2 AND CLOSETR IS 1>3<cfelse>1</cfif>>
	</CFIF>
	<cfif BitAnd(DISPMODE,128) IS 128>
		#Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)#
		<input name=DXSAmount id=DXSAmount value="" onchange="dxsMSIG(-1);" onblur="JSVCCurr(this)">
		/
		<input name=DXSRate id=DXSRate value="" readonly style="background:silver;">
		=
		<b>#Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)#<span id="DXSDisplay"></span></b>
	</cfif>
	<cfif BitAnd(DISPMODE,4) IS 4>
		<input type=radio name=DXSMODE id=_DSXMODE0 value=0 <cfif BitAnd(iDXSMODE,1) IS 0>checked</cfif> onclick=OnXSChg()>
	</cfif>
	<cfif BitAnd(DISPMODE,1) IS 1>
		<input <cfif nodisplayDXS IS 1>style="display:none;"</cfif> <cfif BitAnd(CHKREQ,1) IS 1>CHKREQUIRED CHKREQUIRED_BAK</cfif> <cfif BitAnd(DISABLE,1) IS 1>DISABLED</cfif> name=DXS id=DXS maxlength=14 onblur="OnXSChg(this);<cfif calcexc IS 1>ClmExc.tallyExcessBreakdown();</cfif>" onfocus="OnXSChg(this);this.select();" value="#FN.SVCNum(DXS)#">
		<cfif calcexc IS 1><input class=clsButton type=button value="#Server.SVClang("Calculate Excess",25336)#" id="DISPMODE1_CALCEXCESS" onclick="ClmExc.clkExcCalcBtn(event,this,#fvehtyp#)"></cfif>
	</cfif>
	<cfif BitAnd(DISPMODE,6) GT 0>
		<input CHKNAME="No of Incidents" <cfif BitAnd(CHKREQ,2) IS 2>CHKREQUIRED</cfif> <cfif BitAnd(DISABLE,2) IS 2>DISABLED</cfif> name=INCIDENTCNT maxlength=3 size=3 onblur=OnXSChg(this) onfocus=OnXSChg(this);this.select() value="<CFIF CINCIDENTCNT GTE 0>#CINCIDENTCNT#</CFIF>"><span> x <b><label CURRSYM>#request.DS.FN.CurrencyType()#<!--- #Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)# ---></label></b>&nbsp;</span><input CHKNAME="#Server.SVClang("Per-Incident Retention",25337)#" <cfif BitAnd(CHKREQ,1) IS 1>CHKREQUIRED</cfif> <cfif BitAnd(DISABLE,1) IS 1>DISABLED</cfif> id=DXS name=DXS maxlength=12 size=12 onblur=OnXSChg(this) onfocus=OnXSChg(this);this.select() value="<CFIF DXS IS NOT "" AND CINCIDENTCNT GT 0>#FN.SVCNum(DXS/CINCIDENTCNT)#</CFIF>"><span style=font-weight:bold> = <label CURRSYM>#request.DS.FN.CurrencyType()#<!--- #Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)# ---></label> <span id=DXSTOT>?</span></span>
		<cfif calcexc IS 1><input class=clsButton type=button value="#Server.SVClang("Calculate",0)# #EXCESSNAME#" onclick="ClmExc.clkExcCalcBtn(event,this,#fvehtyp#,'#EXCESSNAME#')"></cfif>
	</cfif>
	<cfif BitAnd(DISPMODE,4) IS 4>
		<br><input type=radio name=DXSMODE id=_DXSMODE1 value=1 <cfif BitAnd(iDXSMODE,1) IS 1>checked</cfif> onclick=OnXSChg()>
		<input CHKREQUIRED CHKNAME="#Server.SVClang("% of Gross Claim",25338)#" type=text size=6 maxlength=6 name=DXSCLMPC value="<cfif siDXSCLMPC GT 0>#FN.SVCnum(siDXSCLMPC/100,2)#</cfif>" onblur=OnXSChg(this) onfocus=OnXSChg(this);this.select()>#Server.SVClang("% Gross",25339)# = <b><label CURRSYM>#request.DS.FN.CurrencyType()#<!--- #Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)# ---></label> <span id=DXSCLMPCTOT>?</span></b> / #Server.SVClang("Min",10217)# <b><label CURRSYM>#request.DS.FN.CurrencyType()#<!--- #Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)# ---></label></b> <input CHKREQUIRED CHKNAME="Minimum" type=text maxlength=12 name=DXSMIN value="#FN.SVCnum(mnDXSMIN)#" onfocus=OnXSChg(this);this.select() onblur=OnXSChg(this)>
	</cfif>
	<cfif BitAnd(DISPMODE,16) IS 16>
		<br>
		<select id="DXSCARCAMSELECT" CHKNAME="In car camera excess waiver option" name=DXSCARCAMSELECT onChange="JSVCShowHideChk('1,2','DXSCARCAMSELECT','DXSCARCAM','inCarCamDiv',1)" onblur="DoReq(this)" CHKREQUIRED style="margin-top:2px">
			<option></option>
			<option value=2 <CFIF q_clm.siCarCamExcsWaive EQ 2>SELECTED</CFIF>>YES-50%</option>
			<option value=1 <CFIF q_clm.siCarCamExcsWaive EQ 1>SELECTED</CFIF>>YES-100%</option>
			<option value=0 <CFIF q_clm.siCarCamExcsWaive EQ 0>SELECTED</CFIF>>NO</option>
		</select>
		In car camera excess waiver? <CFIF _L_INSGCOID NEQ 200005> <!--- #20173 AIG SG just want the in car camera excess, percentage/indicator only --->
		<span id="inCarCamDiv" style="display:<CFIF LEN(q_clm.siCarCamExcsWaive) LTE 0 OR q_clm.siCarCamExcsWaive EQ 0>none<CFELSE>inline</CFIF>">#Server.SVClang("Amount",1443)# (<label CURRSYM>#request.DS.FN.CurrencyType()#</label>)&nbsp;<INPUT id="DXSCARCAM" name=DXSCARCAM CHKNAME="In car camera excess waiver field" onblur="JSVCCurr(this)" value="#FN.SVCNum(DXSCARCAM)#"></span> 	</CFIF>
	</CFIF>
	<cfif BitAnd(DISPMODE,32) IS 32>
		<br>
		<select id="DXSNCDSELECT" CHKNAME="NCD based Excess waiver" name=DXSNCDSELECT onblur="DoReq(this)" CHKREQUIRED style="margin-top:2px">
			<option></option>
			<option value=2 <CFIF q_clm.siNCDExcsWaive EQ 2>SELECTED</CFIF>>YES-50%</option>
			<option value=1 <CFIF q_clm.siNCDExcsWaive EQ 1>SELECTED</CFIF>>YES-100%</option>
			<option value=0 <CFIF q_clm.siNCDExcsWaive EQ 0>SELECTED</CFIF>>NO</option>
		</select>
		NCD based Excess Waiver (Insured Driving)
	</CFIF>
	<cfif BitAnd(DISPMODE,64) IS 64>
		<br>
		<select id="EXAMEMPSELECT" CHKNAME="Examiner Empowerment" name=EXAMEMPSELECT onChange="JSVCShowHideChk('1','EXAMEMPSELECT','EXAMEMPIN','EXAMEMPSPAN',1)" onblur="DoReq(this);JSVCShowHideChk('1','EXAMEMPSELECT','EXAMEMPIN','EXAMEMPSPAN',1)"  CHKREQUIRED style="margin-top:2px">
			<option></option>
			<option value=1 <CFIF q_clm.siEXAMEMP EQ 1>SELECTED</CFIF>>YES</option>
			<option value=0 <CFIF q_clm.siEXAMEMP EQ 0>SELECTED</CFIF>>NO</option>
		</select>
		Examiner Empowerment
		<span id="EXAMEMPSPAN" style="display:<CFIF LEN(q_clm.siEXAMEMP) LTE 0 OR q_clm.siEXAMEMP EQ 0>none<CFELSE>inline</CFIF>">|#Server.SVClang("Amount",1443)# (<label CURRSYM>#request.DS.FN.CurrencyType()#</label>)&nbsp;<INPUT id="EXAMEMPIN" name=EXAMEMPIN CHKNAME="Examiner Empowerment field" onblur="JSVCCurr(this)" value="#FN.SVCNum(EXMEMP)#"></span>
	</CFIF>
	<cfif BitAnd(DISPMODE,8) IS 8>
		<span id="waiveAmount">
			<input type=hidden value=1 name=DXSWAIVEDEXISTS><br>
			<input type=checkbox 
				value=1 
				id="DXSWAIVEDCHK" 
				onclick="OnXSChg(this);<CFIF _L_INSGCOID EQ 1100001>var obj = JSVCall('DXSWAIVED'), obj2 = JSVCall('DXS'); if(this.checked) obj.value = obj2.value;</CFIF>" 
				<CFIF DXSWAIVED IS NOT "" OR WAIVED EQ 1> checked</CFIF>
				> 
			#Server.SVClang("Waive Amount",10146)# (<label CURRSYM>#request.DS.FN.CurrencyType()#<!--- #Server.SVClang(request.DS.FN.CurrencyType(),LOCALE.CURRENCY_LID)# ---></label>) 
			<input 
				CHKNAME="#Server.SVClang("Waive Amount",10146)#" 
				CHKREQUIRED=obj.previousSibling.previousSibling.checked 
				name=DXSWAIVED 
				onblur=OnXSChg(this) 
				onfocus=OnXSChg(this);this.select() 
				value="#FN.SVCNum(DXSWAIVED)#" 
				<CFIF DXSWAIVED IS "" AND WAIVED EQ 0> DISABLED</CFIF>
				>
		</span>
	</cfif>
	<script>AddOnloadCode("OnXSChg(this,#setDisINCDNTCNTDXS#);");</script>
	<CFIF FN.SVCGetResp()>
		</div><cfif CLOSETR IS 1></div></tbody></cfif>
	<CFELSE>
		</td><cfif CLOSETR IS 1></tr></tbody></cfif>
	</CFIF>
	<cfoutput>
		<script>
		var ClmExc=new cMTR_CLMEXC("ClmExc","#request.DS.FN.CurrencyType()#","#CLMID#"<cfif LEFT(q_trx2.claimtype,2) IS "NM">,"1"<CFELSEIF (q_trx2.claimtype EQ "TP BI" AND _L_INSGCOID EQ 1000615)>,"2"<cfelseif (INSGCOID IS 200798 AND CLMFLOW eq 'OD')>,1<cfelse>,null</cfif><cfif (q_trx2.claimtype EQ "TP BI" AND _L_INSGCOID EQ 1000615) OR (INSGCOID IS 200798 AND CLMFLOW eq 'OD')>,"1"</cfif>);
		var i=ClmExc;
		i.setExcInfo(<cfif Isdefined("q_excinfo0")>#serializeJSON(q_excinfo0)#<cfelse>null</cfif>,<cfif Isdefined("q_excinfo1")>#serializeJSON(q_excinfo1)#<cfelse>null</cfif>,<cfif Isdefined("q_excinfo2")>#serializeJSON(q_excinfo2)#<cfelse>null</cfif>,<cfif Isdefined("DISABLEDLIST_info0") and ArrayLen(DISABLEDLIST_info0) GT 0>#serializeJSON(DISABLEDLIST_info0)#<cfelse>null</cfif>,<cfif Isdefined("DISABLEDLIST_info1") and ArrayLen(DISABLEDLIST_info1) GT 0>#serializeJSON(DISABLEDLIST_info1)#<cfelse>null</cfif>);
	</script>
	</cfoutput>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRGenExcess=MTRGenExcess>

<cffunction name="MTRgetDepcr" output="no" returntype="struct">
<cfargument name="locid" type="numeric">
<cfargument name="bttrrate" type="string">
<cfargument name="jpjregdate" type="any"><!--- Must be in DB time --->
<cfargument name="acctdate" type="any"><!--- Must be in DB time --->
<cfargument name="assemtype" type="any">
<cfargument name="vehmanyear" type="any">
<cfargument name="polstartdate" type="any">
<cfset var manyr="">
<cfset var st=StructNew()>
<cfset FN=Request.DS.FN>
<cfif ((locid IS 1 AND (assemtype IS 1<!---Recon--->
			OR (assemtype IS 2<!---New Import---> AND polstartdate IS NOT "" AND polstartdate GTE "2017-01-01")))
		OR (locid IS 10 AND (assemtype IS 1<!---Recon---> OR assemtype IS 4<!---Rebuilt--->))
	) AND vehmanyear GT 1900>
	<!--- Betterment calculation: Man Yr vs. Accident Date --->
	<CFSET manyr=CreateDate(vehmanyear,1,1)>
	<CFSET st.gmanyr=DateFormat(manyr,"yyyy/mm/dd")>
	<CFSET st.gregdate=FN.SVCdtDBtoLOC(jpjregdate,0,"yyyy/mm/dd")>
	<CFSET st.gaccdate=FN.SVCdtDBtoLOC(acctdate,0,"yyyy/mm/dd")>
	<CFSET st.carmth=FN.SVCmthdiff(st.gmanyr,st.gaccdate)>
	<cfset st.caltype=1>
<cfelse>
	<!--- Betterment calculation: JPJ Reg Date vs. Accident Date --->
	<CFSET st.gmanyr="">
	<CFSET st.gregdate=FN.SVCdtDBtoLOC(jpjregdate,0,"yyyy/mm/dd")>
	<CFSET st.gaccdate=FN.SVCdtDBtoLOC(acctdate,0,"yyyy/mm/dd")>
	<CFSET st.carmth=FN.SVCmthdiff(st.gregdate,st.gaccdate)>
	<cfset st.caltype=0>
</cfif>
<cfif st.carmth GTE 0>
	<CFSET st.perc=FN.SVCcalcdepr(st.carmth,bttrrate)>
	<CFSET st.caryear=FN.SVCNum(st.carmth/12,1)>
<cfelse>
	<cfset st.carmth=-1>
	<cfset st.perc=0>
	<cfset st.caryear=-1>
</cfif>
<cfreturn st>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRgetDepcr=MTRgetDepcr>
<cffunction name="MTRgetUserCasePolGrpAcc" output="no" returntype="struct">
<cfargument name="LIMITCODE" type="string" required="Yes" default="CLM"><!--- CLM, PAY, RSV, RPI --->
<cfargument name="USID" type="numeric" required="Yes"><!--- 0: Assume SESSION.VARS.USID --->
<cfargument name="CASEID" type="numeric" required="Yes"><!--- 0: Below non-req info passed in, do not re-query --->
<cfargument name="TPINS" type="numeric" required="Yes">
<cfargument name="CLMTYPEMASK" type="numeric" required="No" default=0>
<cfargument name="INSCLASSID" type="numeric" required="No" default=0>
<cfargument name="INSPOLID" type="numeric" required="No" default=0>
<cfargument name="INSBUSID" type="numeric" required="No" default=0>
<cfargument name="TOTALLOSS" type="numeric" required="No" default=0>
<cfargument name="EXCLUDEGRPCHECK" type="numeric" required="No" default=0>
<!--- Return results: struct:
		ACC = 1 (Yes), 0 (None/No), -1: Actively deny.
		PolGrpID = The rule caught
		Limit = Approval limit
--->
<CFSET var x=0>
<CFSET var y=0>
<CFSET var grplen=0>
<CFSET var found=0>
<CFSET var INSGCOID=0>
<CFSET var DEF_APPLIMIT=0>
<CFSET var DEF_CLMTYPEACCMASK=0>
<CFSET var results=StructNew()>
<CFSET var POLGRP=0>
<CFSET var POLGRPRULES=0>
<CFSET var polgrplen=0>
<CFIF USID IS 0 OR USID IS SESSION.VARS.USID>
	<CFSET USID=SESSION.VARS.USID>
	<CFSET INSGCOID=SESSION.VARS.GCOID>
	<CFSET DEF_APPLIMIT=SESSION.VARS.APPLIMIT>
	<CFSET DEF_CLMTYPEACCMASK=SESSION.VARS.CLMTYPEACCMASK>
	<CFIF StructKeyExists(SESSION.VARS,"POLGRP") AND StructKeyExists(SESSION.VARS.POLGRP,Arguments.LIMITCODE) AND EXCLUDEGRPCHECK IS 0>
		<CFSET US_POLGRP=SESSION.VARS.POLGRP[Arguments.LIMITCODE]>
		<CFSET US_POLGRP_LIMIT=SESSION.VARS.POLGRP_LIMIT[Arguments.LIMITCODE]>
	<CFELSE><!--- create empty array --->
		<CFSET US_POLGRP=ArrayNew(1)>
		<CFSET US_POLGRP_LIMIT=ArrayNew(1)>
	</CFIF>
<CFELSE>
	<CFQUERY NAME=q_trx2 DATASOURCE=#Request.SVCDSN#>
	SELECT a.iCOID,a.mnAPPLIMIT,a.iCLMTYPEACCMASK FROM SEC0001 a WITH (NOLOCK)
	WHERE a.iUSID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#USID#">
	</CFQUERY>
	<CFIF q_trx2.recordcount IS NOT 1>
		<cfthrow TYPE=EX_SECFAILED ErrorCode="BADCASE" ExtendedInfo="User not found">
	</CFIF>
	<CFSET INSGCOID=Request.DS.CO[q_trx2.iCOID].GCOID>
	<CFSET DEF_APPLIMIT=q_trx2.mnAPPLIMIT>
	<CFSET DEF_CLMTYPEACCMASK=q_trx2.iCLMTYPEACCMASK>

	<CFQUERY NAME=q_trx2 DATASOURCE=#Request.SVCDSN#>
	    SELECT a.iPOLGRPID,a.BRIGHTS,a.mnLIMIT,vaLIMITCODE=UPPER(a.vaLIMITCODE)
	    FROM SEC0018 a WITH (NOLOCK) JOIN BIZ2018 b WITH (NOLOCK) ON a.iPOLGRPID=b.iPOLGRPID
	    WHERE a.iUSID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#USID#"> AND a.siSTATUS=0 AND a.bRIGHTS=1 AND b.sistatus=0 AND a.vaLIMITCODE=<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#LIMITCODE#">
	    ORDER BY ISNULL(b.ipriority,-1), a.iPOLGRPID
	</CFQUERY>
	<CFSET US_POLGRP=ArrayNew(1)>
	<CFSET US_POLGRP_LIMIT=ArrayNew(1)>
	<CFLOOP query=q_trx2>
		<CFIF BRIGHTS GT 0>
			<cfset ARRAYAPPEND(US_POLGRP,iPOLGRPID)>
		<CFELSE>
			<cfset ARRAYAPPEND(US_POLGRP,-1*iPOLGRPID)>
		</CFIF>
		<cfset ARRAYAPPEND(US_POLGRP_LIMIT,mnLIMIT)>
	</cfloop>

	<!---
	<CFSET US_POLGRP=ArrayNew(1)>
	<CFSET US_POLGRP_LIMIT=ArrayNew(1)>
	<CFLOOP query=q_trx2>
		<CFIF BRIGHTS GT 0>
			<CFSET US_POLGRP[q_trx2.currentrow]=iPOLGRPID>
		<CFELSE>
			<CFSET US_POLGRP[q_trx2.currentrow]=-iPOLGRPID>
		</CFIF>
		<CFSET US_POLGRP_LIMIT[q_trx2.currentrow]=mnLIMIT>
	</CFLOOP --->
</CFIF>
<CFIF DEF_APPLIMIT IS ""><CFSET DEF_APPLIMIT=0></CFIF>
<CFIF DEF_CLMTYPEACCMASK IS ""><CFSET DEF_CLMTYPEACCMASK=-1></CFIF>
<CFIF CASEID GT 0>
	<CFQUERY NAME=q_trx2 DATASOURCE=#Request.MTRDSN#>
	SELECT a.iINSCLASSID,a.iINSPOLID,a.iINSBUSID,a.iCLMTYPEMASK
	FROM TRX0008 a WITH (NOLOCK)
	WHERE a.iCASEID=<cfqueryparam value="#CASEID#" cfsqltype="CF_SQL_INTEGER"> AND a.siTPINS=<cfqueryparam value="#TPINS#" cfsqltype="CF_SQL_NUMERIC">
	</CFQUERY>
	<CFIF q_trx2.recordcount IS NOT 1>
		<cfthrow TYPE=EX_SECFAILED ErrorCode="BADCASE" ExtendedInfo="Case not found">
	</CFIF>
	<CFSET INSCLASSID=q_trx2.iINSCLASSID>
	<CFSET INSPOLID=q_trx2.iINSPOLID>
	<CFSET INSBUSID=q_trx2.iINSBUSID>
	<CFSET CLMTYPEMASK=q_trx2.iCLMTYPEMASK>
	<CFIF INSCLASSID IS ""><CFSET INSCLASSID=0></CFIF>
	<CFIF INSPOLID IS ""><CFSET INSPOLID=0></CFIF>
	<CFIF INSBUSID IS ""><CFSET INSBUSID=0></CFIF>
	<CFIF CLMTYPEMASK IS ""><CFSET CLMTYPEMASK=0></CFIF>
</CFIF>
<CFSET grplen=ArrayLen(US_POLGRP)>
<CFIF grplen GT 0>
	<CFLOOP INDEX=X FROM=1 TO=#grplen#>
		<CFIF StructKeyExists(Request.DS.CO[INSGCOID],"POLGRP") AND StructKeyExists(Request.DS.CO[INSGCOID].POLGRP,ABS(US_POLGRP[X]))>
			<CFSET POLGRP=Request.DS.CO[INSGCOID].POLGRP>
			<CFSET POLGRPRULES=StructFind(POLGRP,ABS(US_POLGRP[X])).RULES>
			<CFSET polgrplen=ArrayLen(POLGRPRULES)>
			<CFIF polgrplen GT 0>
				<CFLOOP INDEX=Y FROM=1 TO=#polgrplen#>
					<cfif US_POLGRP[X] LTE 0><cfset ACC=0><cfelse><cfset ACC=1></cfif>
					<CFIF POLGRPRULES[Y].INSCLASSID IS 0>
						<CFIF BitAnd(CLMTYPEMASK,POLGRPRULES[Y].CLMTYPEMASK) IS NOT 0 AND (POLGRPRULES[Y].TOTALLOSS IS -1 OR POLGRPRULES[Y].TOTALLOSS IS Arguments.TOTALLOSS)>
							<CFSET found=1>
							<CFSET results={ACC=#ACC#,PolGrpID=ABS(US_POLGRP[X]),Limit=US_POLGRP_LIMIT[X]}>
							<CFBREAK>
						</CFIF>
					<CFELSEIF POLGRPRULES[Y].POLID IS 0>
						<CFIF (INSCLASSID IS 0 OR POLGRPRULES[Y].INSCLASSID IS INSCLASSID) AND BitAnd(CLMTYPEMASK,POLGRPRULES[Y].CLMTYPEMASK) IS NOT 0 AND (POLGRPRULES[Y].TOTALLOSS IS -1 OR POLGRPRULES[Y].TOTALLOSS IS Arguments.TOTALLOSS)>
							<CFSET found=1>
							<CFSET results={ACC=#ACC#,PolGrpID=ABS(US_POLGRP[X]),Limit=US_POLGRP_LIMIT[X]}>
							<CFBREAK>
						</CFIF>
					<CFELSEIF POLGRPRULES[Y].BUSID IS 0>
						<CFIF	(INSCLASSID IS 0 OR POLGRPRULES[Y].INSCLASSID IS INSCLASSID) AND
								(INSPOLID IS 0 OR POLGRPRULES[Y].POLID IS INSPOLID) AND
								BitAnd(CLMTYPEMASK,POLGRPRULES[Y].CLMTYPEMASK) IS NOT 0 AND (POLGRPRULES[Y].TOTALLOSS IS -1 OR POLGRPRULES[Y].TOTALLOSS IS Arguments.TOTALLOSS)>
							<CFSET found=1>
							<CFSET results={ACC=#ACC#,PolGrpID=ABS(US_POLGRP[X]),Limit=US_POLGRP_LIMIT[X]}>
							<CFBREAK>
						</CFIF>
					<CFELSE>
						<CFIF	(INSCLASSID IS 0 OR POLGRPRULES[Y].INSCLASSID IS INSCLASSID) AND
								(INSPOLID IS 0 OR POLGRPRULES[Y].POLID IS INSPOLID) AND
								(INSBUSID IS 0 OR POLGRPRULES[Y].BUSID IS INSBUSID) AND
								BitAnd(CLMTYPEMASK,POLGRPRULES[Y].CLMTYPEMASK) IS NOT 0 AND (POLGRPRULES[Y].TOTALLOSS IS -1 OR POLGRPRULES[Y].TOTALLOSS IS Arguments.TOTALLOSS)>
							<CFSET found=1>
							<CFSET results={ACC=#ACC#,PolGrpID=ABS(US_POLGRP[X]),Limit=US_POLGRP_LIMIT[X]}>
							<CFBREAK>
						</CFIF>
					</CFIF>
				</CFLOOP>
			</CFIF>
		</CFIF>
		<CFIF found IS 1>
			<CFBREAK>
		</CFIF>
	</CFLOOP>
</CFIF>
<CFIF found IS 0>
	<!--- Default settings --->
	<CFIF BitAnd(CLMTYPEMASK,DEF_CLMTYPEACCMASK) IS NOT 0>
		<CFSET results={ACC=1,PolGrpID=0,Limit=DEF_APPLIMIT}>
	<CFELSE>
		<CFSET results={ACC=0,PolGrpID=0,Limit=0}>
	</CFIF>
</CFIF>
<CFRETURN results>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRgetUserCasePolGrpAcc=MTRgetUserCasePolGrpAcc>

<cffunction name="MTRNMPayChkLimit" output="no" returntype="struct">
	<!--- to identify all payments from affected claims are made within it's user's PAY limit. REQGRPID represents number of related claim --->
	<cfargument name="REQGRPID" type="numeric" required="Yes"><!--- can be multiple REQGRPID in list (not available for time being, or single REQGRPID --->
	<cfargument name="USID" type="numeric" required="Yes"><!--- 0: Assume SESSION.VARS.USID --->
	<cfset var CHKMODE="">
	<!--- e.g.: additional verification
	CHKRSV: to verify whether the claim has enough offer reserve amount to be finalised
	CHKCLMDTL: to verify whether the claim has updated with mandatory fields
	--->
	<cfset var is_ses_usid=0>
	<cfif arguments.USID IS 0><cfset is_ses_usid=1><cfset arguments.USID=#session.vars.USID#></cfif>

	<CFSET var ApprovalLimit=""><cfset var RSV_LIMIT_AMT=""><cfset var PAY_LIMIT_AMT="">
	<cfset var q_trx={}><cfset var q_trx2={}><cfset var cur_caseid=""><cfset var SUM_TOTAL="">
	<cfset var ret_error="">
	<cfset var ret_struct={}>
	<cfset var struct_pay_limit={}>
	<CFSET var LOCALE=Request.DS.LOCALES[session.vars.locid]>
	<cfset var usrismgr=0>
	<cfset var INSGCOID=0>
	<cfif NOT(arguments.REQGRPID GT 0)><cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCASE" ExtendedInfo="REQGRPID not found"></cfif>

	<cfquery name="q_trx" DATASOURCE=#Request.MTRDSN#>
	select igcoid from FPAY0011 with (nolock) where ireqgrpid=<cfqueryparam value="#arguments.REQGRPID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfset INSGCOID=#q_trx.igcoid#>

	<!--- intial checking : to make sure this reqgrpid is belong to the owner of the company --->
	<cfif is_ses_usid IS 1>
		<cfif NOT(INSGCOID GT 0 AND INSGCOID IS session.vars.gcoid AND session.vars.orgtype is "I")>
			<cfset ret_error=listappend(ret_error,"Invalid Case Access.","|")>
		</cfif>
	</cfif>

	<cfif INSGCOID IS 29><!--- additional checking mode --->
		<cfset CHKMODE="CHKRSV,CHKCLMDTL">
	</cfif>

	<cfif ret_error IS "">
		<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm" GrpList="2W,4W">
		<cfif canwrite IS 1><!--- canwrite=1 : the user is manager, can approve any claim as long as the payment is within its limit ; canwrite=0 : the user is PIC, only can approve their PIC claim --->
			<cfset usrismgr=1>
		</cfif>

		<!--- 1. verify payment transaction authority (amount = current payment + existing approved payments) based on user's approval limit , trigger point: upon finalise payment --->
		<cfquery name="q_trx" DATASOURCE=#Request.MTRDSN#>
		select claimno=i.vaclmno, mcaseid=i.imaincaseid, picusid=o.iusid,cur_pay_amt=SUM(ISNULL(c.mnAMT,0))
			from FPAY0011 a with (nolock)
			JOIN FPAY0012 b with (nolock) on a.ireqgrpid=b.ireqgrpid
			JOIN FPAY0002 c with (nolock) on b.idomainid=207 AND c.ireqid=b.iobjid
			JOIN TRX0008 i with (nolock) ON c.idomainid=1 AND c.iobjid=i.icaseid
			LEFT JOIN SEC0001 o with (nolock) ON o.vausid=i.vaowner
			WHERE a.iREQGRPID=<cfqueryparam value="#arguments.REQGRPID#" cfsqltype="CF_SQL_INTEGER"> and c.idomainid=1
		GROUP BY i.vaclmno, i.imaincaseid, o.iusid
		</cfquery>
		<cfset var usidlist=#valuelist(q_trx.picusid)#>
		<cfloop query="q_trx">
			<cfset cur_caseid=q_trx.mcaseid>
			<!--- 1. verify the user (either as the assessment user or manager) has privileges to approve claim payment --->
			<cfif usrismgr IS 0 AND LISTFINDNOCASE(usidlist,arguments.USID) IS 0>
				<cfset ret_error=listappend(ret_error,"Only manager or personnel in-charge to approve this claim.","|")>
			</cfif>
			<!--- identify caseid for respective payid  --->
			<cfif NOT structKeyExists(struct_pay_limit,cur_caseid)>
				<CFSET ApprovalLimit=Request.DS.MTRFN.MTRgetUserCasePolGrpAcc("PAY",arguments.USID,cur_caseid,0)>
				<CFIF ApprovalLimit.ACC GT 0>
					<CFSET PAY_LIMIT_AMT=ApprovalLimit.LIMIT>
					<CFIF Trim(PAY_LIMIT_AMT) IS ""><CFSET PAY_LIMIT_AMT=-1></CFIF>
				<CFELSE>
					<CFSET PAY_LIMIT_AMT=-1>
				</CFIF>
				<cfset Structinsert(struct_pay_limit,cur_caseid,PAY_LIMIT_AMT)>
			<cfelse>
				<cfset PAY_LIMIT_AMT=#struct_pay_limit[cur_caseid]#>
			</cfif>
			<!--- verify --->
			<cfquery name="q_trx2" DATASOURCE=#Request.MTRDSN#>
			select m.vaclmno, m.icaseid, amt=SUM(ISNULL(c.mnAMT,0))
				FROM trx0008 m with (nolock)
				JOIN trx0008 i with (nolock) ON m.icaseid=i.imaincaseid
				JOIN FPAY0002 c with (nolock) ON c.idomainid=1 and c.iobjid=i.icaseid
				JOIN FPAY0012 d with (nolock) ON d.idomainid=207 and d.iobjid=c.ireqid
				JOIN FPAY0011 e with (nolock) ON e.ireqgrpid=d.ireqgrpid
				WHERE m.icaseid=<cfqueryparam value="#cur_caseid#" cfsqltype="CF_SQL_INTEGER">
				AND e.dtAUTH IS NOT NULL AND e.sistatus=0 /* approved pay grp */
			GROUP BY m.vaclmno, m.icaseid
			</cfquery>
			<cfif q_trx2.amt NEQ "">
				<cfset var SUM_TOTAL=evaluate(q_trx2.amt+q_trx.cur_pay_amt)>
			<cfelse>
				<cfset var SUM_TOTAL=evaluate(q_trx.cur_pay_amt)>
			</cfif>
			<cfif NOT(PAY_LIMIT_AMT IS -1 OR PAY_LIMIT_AMT GTE SUM_TOTAL)><!--- not within limit --->
				<cfset ret_error=listappend(ret_error,"Insufficient limit to approve payment for claim no. #q_trx2.vaclmno# (#q_trx2.icaseid#) [Total: #request.DS.FN.CurrencyType()##request.ds.fn.svcnumdbtoloc(SUM_TOTAL)#, Limit: #request.DS.FN.CurrencyType()##request.ds.fn.svcnumdbtoloc(PAY_LIMIT_AMT)#]","|")>
			</cfif>
			<!--- additional verification from MTRNMChkRsvLimit --->
			<cfif LISTFINDNOCASE(CHKMODE,"CHKRSV") GT 0>
				<CFSET ret_struct=Request.DS.MTRFN.MTRNMRsvChkLimit(cur_caseid)>
				<cfif ret_struct.PASS IS 0><cfset ret_error=listappend(ret_error,ret_struct.ERROR,"|")></cfif>
			</cfif>
			<cfif LISTFINDNOCASE(CHKMODE,"CHKCLMDTL") GT 0>
				<cfif q_trx.claimno IS "">
					<cfset ret_error=listappend(ret_error,"Claim No. is not specified.","|")>
				</cfif>
			</cfif>
		</cfloop>
	</cfif>
	<CFSET var results={PASS=0,APPROVAL_AMT=#SUM_TOTAL#,LIMIT_AMT=#PAY_LIMIT_AMT#,ERROR="#ret_error#"}>
	<cfif ret_error IS ""><cfset results.PASS=1></cfif>
	<cfreturn results>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRNMPayChkLimit=MTRNMPayChkLimit>

<cffunction name="MTRNMRsvChkLimit" output="no" returntype="struct">
	<!--- to identify claim is made within PIC's RSV limit --->
	<cfargument name="CASEID" type="numeric" required="Yes">
	<!--- <cfargument name="CHKMODE" type="string" required="no" default=""> --->
	<cfset var q_trx={}><cfset var cur_caseid=""><cfset var SUM_TOTAL="">
	<cfset var ret_error=""><cfset var cur_usid=""><cfset var cur_clmno="">
	<CFSET var ApprovalLimit=""><cfset var RSV_LIMIT_AMT=""><cfset var PAY_LIMIT_AMT="">

	<cfquery name="q_trx" DATASOURCE=#Request.MTRDSN#>
	select USID=b.iusid, m.vaclmno, mcaseid=a.imaincaseid
	FROM TRX0008 a with (nolock)
	JOIN TRX0008 m with (nolock) ON a.imaincaseid=m.icaseid
	JOIN sec0001 b with (nolock) ON m.vaOWNER=b.vausid
	WHERE a.icaseid=<cfqueryparam value="#arguments.CASEID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfset cur_usid=#q_trx.USID#><cfset cur_clmno=#q_trx.vaclmno#><cfset var cur_caseid=#q_trx.mcaseid#>
	<!--- shouldn't throw error when loading screen..
	<cfif cur_usid IS "">
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCSTAT" EXTENDEDINFO="#Server.SVClang("Claim PIC has yet assigned (Claim No. #cur_clmno#).",25495)#">
	</cfif>
	--->
	<cfif cur_usid IS "">
		<cfset ret_error=listappend(ret_error,"Claim PIC is not assigned.","|")>
	<cfelse>
		<CFSET ApprovalLimit=Request.DS.MTRFN.MTRgetUserCasePolGrpAcc("RSV",cur_usid,cur_caseid,0)>
		<CFIF ApprovalLimit.ACC GT 0>
			<CFSET RSV_LIMIT_AMT=ApprovalLimit.LIMIT>
			<CFIF Trim(RSV_LIMIT_AMT) IS ""><CFSET RSV_LIMIT_AMT=-1></CFIF>
		<CFELSE>
			<CFSET RSV_LIMIT_AMT=-1>
		</CFIF>

		<!--- 2. verify claim's total Indemnity Reserve (IDM) & total Expense Reserve (EXP) based on claim PIC's RSV approval limit --->
		<!--- <cfquery name="q_trx" DATASOURCE=#Request.MTRDSN#>
		selecT CVGID=ws.vaCFCODE, ws.vaCFDESC, a.vaRSVTYPE, total_amt=sum(a.mnOFR)
		from TRX_CLMOFR a
		JOIN biz0025 ws ON ws.icoid=29 and ws.aCFTYPE='WSITM' and a.iBENID=cast(ws.vaCFCODE as integer)
		where a.icaseid=46705 and a.sistatus=0
		group by ws.vaCFCODE, a.vaRSVTYPE, ws.vaCFDESC
		</cfquery> --->
		<cfquery name="q_trx" DATASOURCE=#Request.MTRDSN#>
		SELECT a.vaRSVTYPE, total_amt=sum(a.mnOFR)
		FROM TRX_CLMOFR a with (nolock)
		where a.icaseid=<cfqueryparam value="#cur_caseid#" cfsqltype="CF_SQL_INTEGER"> and a.sistatus=0
		group by a.vaRSVTYPE
		</cfquery>
		<cfloop query="q_trx">
			<cfset SUM_TOTAL=#q_trx.total_amt#>
			<cfif NOT(RSV_LIMIT_AMT IS -1 OR RSV_LIMIT_AMT GTE SUM_TOTAL)><!--- not within limit --->
				<cfif q_trx.vaRSVTYPE IS "IDM">
					<cfset ret_error=listappend(ret_error,"Insufficient limit to approve Indemnity Reserve for claim no. #cur_clmno# (#cur_caseid#) [Total: #request.DS.FN.CurrencyType()##request.ds.fn.svcnumdbtoloc(SUM_TOTAL)#, Limit: #request.DS.FN.CurrencyType()##request.ds.fn.svcnumdbtoloc(RSV_LIMIT_AMT)#]","|")>
				<cfelseif q_trx.vaRSVTYPE IS "EXP">
					<cfset ret_error=listappend(ret_error,"Insufficient limit to approve Expenses Reserve for claim no. #cur_clmno# (#cur_caseid#) [Total: #request.DS.FN.CurrencyType()##request.ds.fn.svcnumdbtoloc(SUM_TOTAL)#, Limit: #request.DS.FN.CurrencyType()##request.ds.fn.svcnumdbtoloc(RSV_LIMIT_AMT)#]","|")>
				<cfelse>
					<cfset ret_error=listappend(ret_error,"Insufficient limit to approve #q_trx.vaRSVTYPE# Reserve for claim no. #cur_clmno# (#cur_caseid#) [Total: #request.DS.FN.CurrencyType()##request.ds.fn.svcnumdbtoloc(SUM_TOTAL)#, Limit: #request.DS.FN.CurrencyType()##request.ds.fn.svcnumdbtoloc(RSV_LIMIT_AMT)#]","|")>
				</cfif>
			</cfif>
		</cfloop>
	</cfif>
	<CFSET var results={PASS=0,APPROVAL_AMT=#SUM_TOTAL#,LIMIT_AMT=#RSV_LIMIT_AMT#,ERROR="#ret_error#"}>
	<cfif ret_error IS ""><cfset results.PASS=1></cfif>
	<cfreturn results>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRNMRsvChkLimit=MTRNMRsvChkLimit>

<cffunction name="MTRgetDocsLinkObj" returntype="struct" output="no">
<cfargument name="DOMAINID" type="numeric">
<cfargument name="OBJID" type="numeric">
<cfset var st={LINKDOMID=0,LINKOBJID=0,LINKCOROLE=0,CLMTYPEMASK=0,CLAIMTYPE="",TPKFKSTAT=0,ESOURCEFLAG=0}>
<cfset var q_trx={}>
<CFIF DOMAINID IS 1>
	<CFQUERY NAME=q_trx DATASOURCE=#Request.MTRDSN#>
	SELECT b.iCLMTYPEMASK,a.aCLAIMTYPE,b.iLINKCASEID,TPKFKSTAT=IsNull(b.iTPKFKSTAT,0),ESOURCEFLAG=IsNull(b.iESOURCEFLAG,0)
	FROM TRX0008 b WITH (NOLOCK),TRX0001 a WITH (NOLOCK)
	WHERE b.iCASEID=<cfqueryparam value="#OBJID#" cfsqltype="CF_SQL_INTEGER"> AND b.siTPINS=0 AND a.iCASEID=b.iCASEID
	</cfquery>
	<CFIF q_trx.recordcount IS 1>
		<CFIF q_trx.iLINKCASEID GT 0 AND BitAnd(q_trx.TPKFKSTAT,8192) IS 0>
			<CFSET st.LINKDOMID=1>
			<CFSET st.LINKOBJID=q_trx.iLINKCASEID>
			<cfset st.LINKCOROLE=8>
		</CFIF>
		<CFSET st.CLMTYPEMASK=q_trx.iCLMTYPEMASK>
		<CFSET st.CLAIMTYPE=q_trx.aCLAIMTYPE>
		<CFSET st.TPKFKSTAT=q_trx.TPKFKSTAT>
		<CFSET st.ESOURCEFLAG=q_trx.ESOURCEFLAG>
	</CFIF>
<CFELSEIF DOMAINID IS 6>
	<CFQUERY NAME=q_trx DATASOURCE=#Request.MTRDSN#>
	SELECT CASEID=a.iOBJID FROM ESC0001 a WITH (NOLOCK) WHERE a.iESID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.OBJID#"> AND a.iDOMAINID=1
	</CFQUERY>
	<CFIF q_trx.recordcount IS 1>
		<CFSET st.LINKDOMID=1>
		<CFSET st.LINKOBJID=q_trx.CASEID>
		<cfset st.LINKCOROLE=32>
	</CFIF>
</CFIF>
<cfreturn st>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRgetDocsLinkObj=MTRgetDocsLinkObj>
<cffunction name="MTRESTgetLabColorSign" hint="Returns a struct containing the 'Sign' and 'Color' to use for the labour display." returntype="struct" output="true">
	<cfargument name="ESTLABTYPE" required="true" type="numeric"
		displayname=""
		hint="">
	<cfargument name="IS_NEWTTS" required="true" type="numeric"
		displayname=""
		hint=">0: New TTS, <=0: Not New TTS">
	<cfargument name="LABVAL" required="false" type="any"
		displayname="The labour amount."
		hint="Empty string to denote no value.">
	<cfargument name="LABDB" required="false" type="any"
		displayname="The labour DB amount."
		hint="Empty string to denote no value.">
	<CFSET var Str=StructNew()>
	<CFSET Str.Color="">
	<CFSET Str.Sign="">
	<CFIF BitAnd(Arguments.ESTLABTYPE,8) IS 8>
		<CFIF Arguments.LABVAL IS NOT "">
			<CFSET Str.Sign="*">
		</CFIF>
	<CFELSEIF BitAnd(Arguments.ESTLABTYPE,16) IS 16>
		<CFIF Arguments.IS_NEWTTS GT 0 AND Val(Arguments.LABDB) IS NOT Val(Arguments.LABVAL)>
			<CFSET Str.Sign="*">
		<CFELSEIF Arguments.IS_NEWTTS LTE 0 AND NOT(Arguments.LABDB IS "" AND Arguments.LABVAL IS "")>
			<CFSET Str.Sign="*">
		</CFIF>
	<CFELSEIF BitAnd(Arguments.ESTLABTYPE,16) IS 0>
		<CFIF Val(Arguments.LABDB) IS NOT Val(Arguments.LABVAL)>
			<CFSET Str.Sign="*">
		</CFIF>
		<CFIF Arguments.LABDB IS NOT "">
			<CFIF Val(Arguments.LABVAL) GT Val(Arguments.LABDB)>
				<CFSET Str.Color="darkred">
			<CFELSEIF Val(Arguments.LABVAL) LT Val(Arguments.LABDB)>
				<CFSET Str.Color="darkgreen">
			</CFIF>
		</CFIF>
	</CFIF>
	<CFRETURN Str>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRESTgetLabColorSign=MTRESTgetLabColorSign>
<cffunction name="MTRcheckSubfolderCloseResv" hint="Returns a struct containing 'StrResvExceeded' error-string if RSV limit exceed, or 'StrResvNotBalanced' error-string if reserve not balanced. If no subfolder reserves set, will return blank for both." returntype="struct" output="true">
<cfargument name="CASEID" required="true" type="numeric"
	displayname=""
	hint="">
<CFSET var Str=StructNew()>
<CFSET var CLMREGFLAGS=0>
<CFSET var ApprovalLimitAmt=-1>
<CFSET var ApprovalLimit=0>
<CFSET var q_resv=0>
<CFSET var LastResvID=0>
<CFSET Str.StrResvExceeded="">
<CFSET Str.StrResvNotBalanced="">
<!--- Get claim company and info --->
<CFQUERY NAME=q_resv DATASOURCE=#Request.MTRDSN#>
select b.iLASTRESVID,c.iLCLMID,ic.iGCOID,c.dtCLMREG,c.vaCLMNO
FROM TRX0008 c WITH (NOLOCK)
		INNER JOIN TRX0054 b ON c.iCASEID=b.iCASEID AND b.aCOTYPE='I'
		INNER JOIN SEC0005 ic ON c.iCOID=ic.iCOID
WHERE c.iCASEID=<cfqueryparam value="#Arguments.CASEID#" cfsqltype="CF_SQL_INTEGER"> AND c.siTPINS=0
</CFQUERY>
<CFIF q_resv.recordcount IS 0>
	<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCASE" ExtendedInfo="Item not found">
</CFIF>
<CFSET LastResvID=q_resv.iLASTRESVID>
<CFIF q_resv.iLCLMID IS "" OR q_resv.iLCLMID LTE 0 OR q_resv.iLASTRESVID IS "" OR q_resv.iLASTRESVID IS 0>
	<!--- No subfolder reserves yet --->
	<CFRETURN str>
</CFIF>
<CFIF q_resv.iGCOID IS 200045>
	<!--- CST(200045):Do not apply to M11 cases for TMIS --->
	<CFIF UCase(Left(q_resv.vaCLMNO,3)) IS "M11">
		<CFRETURN str>
	</CFIF>
	<!--- If got payments pending block closing --->
	<CFQUERY NAME=q_paid DATASOURCE=#Request.MTRDSN#>
	IF(EXISTS(SELECT 0 FROM CLM0006 a WITH (NOLOCK)
		WHERE a.iCLMID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#q_resv.iLCLMID#"> AND a.siPAYSTAT=2 AND a.siSTATUS=0))
		SELECT RET=1
	ELSE
		SELECT RET=0;
	</CFQUERY>
	<CFIF q_paid.recordcount GT 0 AND q_paid.RET IS 1>
		<CFSET Str.StrResvExceeded=Str.StrResvExceeded&" There are payments pending.">
	</CFIF>
</CFIF>

<cfset CLMREGFLAGS=Val(request.ds.FN.SVCgetExtAttrLogic("COADMIN",0,"COATTR-CLMREG-FLAGS",10,q_resv.iGCOID))>
<CFIF BitAnd(CLMREGFLAGS,2) IS 2>
	<!--- Check if total subfolder reserve exceeds limits --->
	<CFSET ApprovalLimit=Request.DS.MTRFN.MTRgetUserCasePolGrpAcc("RSV",SESSION.VARS.USID,0,0,-1)>
	<CFIF ApprovalLimit.ACC GT 0>
		<CFSET ApprovalLimitAmt=ApprovalLimit.LIMIT>
		<CFIF Trim(ApprovalLimitAmt) IS "">
			<CFSET ApprovalLimitAmt=-1>
		</CFIF>
	<CFELSE>
		<CFSET ApprovalLimitAmt=-1>
	</CFIF>
	<CFIF ApprovalLimitAmt GTE 0>
		<CFQUERY NAME=q_resv DATASOURCE=#Request.MTRDSN#>
		select AMT=SUM(IsNull(a.mnAMT,0))
		FROM CLM0026 a WITH (NOLOCK)
		WHERE a.iRESVID=<cfqueryparam value="#LastResvID#" cfsqltype="CF_SQL_INTEGER">
		</CFQUERY>
		<CFIF q_resv.recordcount GT 0 AND q_resv.AMT GT ApprovalLimitAmt>
			<CFSET Str.StrResvExceeded=Str.StrResvExceeded&" Subfolder reserve amount (#request.ds.FN.SVCnum(q_resv.AMT)#) greater than your RSV approval limit (#request.ds.FN.SVCnum(ApprovalLimitAmt)#).">
		</CFIF>
	</CFIF>
</CFIF>
<CFIF BitAnd(CLMREGFLAGS,4) IS 4>
	<!--- Check if give warning for subfolder not zerorized --->
	<CFQUERY NAME=q_resv DATASOURCE=#Request.MTRDSN#>
	SELECT a.vaRESVCODE,a.mnAMT FROM dbo.fCLMSubfolderResvBalance(<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Arguments.CASEID#">) a
	</CFQUERY>
	<CFLOOP query=q_resv>
		<CFIF q_resv.mnAMT GT 0 OR q_resv.mnAMT LT 0>
			<CFIF Str.StrResvNotBalanced IS "">
				<CFSET Str.StrResvNotBalanced="WARNING: The following outstanding subfolder reserves will be zerorized: (#HTMLEditFormat(q_resv.vaRESVCODE)#) #Request.DS.FN.SVCnum(q_resv.mnAMT)#">
			<CFELSE>
				<CFSET Str.StrResvNotBalanced=Str.StrResvNotBalanced&", (#HTMLEditFormat(q_resv.vaRESVCODE)#) #Request.DS.FN.SVCnum(q_resv.mnAMT)#">
			</CFIF>
		</CFIF>
	</CFLOOP>
	<CFIF Str.StrResvNotBalanced IS NOT "">
		<CFSET Str.StrResvNotBalanced=Str.StrResvNotBalanced&".">
	</CFIF>
</CFIF>
<CFSET Str.StrResvExceeded=Trim(Str.StrResvExceeded)>
<CFRETURN Str>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRcheckSubfolderCloseResv=MTRcheckSubfolderCloseResv>

<cffunction name="MTRcovar" hint="Returns a struct containing covar as in Request.DS.CO" returntype="struct" output="false">
<cfargument name="COID" required="true" type="numeric"
	displayname="Company ID"
	hint="">
<cfif NOT StructKeyExists(Request.DS.CO,Arguments.COID)>
	<!--- Create covars for newly referenced COID (growing DS.CO) --->
	<cfset Request.DS.MTRFN.MTRcovar_DSUpdate(Arguments.COID)>
</cfif>
<CFRETURN Request.DS.CO[Arguments.COID]>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRcovar=MTRcovar>


<cffunction name="MTRcovar_DSUpdate" hint="Refresh the Request.DS.CO" returntype="any" output="false">
<cfargument name="COID" required="false" type="numeric" default=0
	displayname="Company ID"
	hint="Leave blank to refresh all companies">
<cfargument name="DS" required="false" type="struct" default="#Request.DS#"
	displayname="The DS to update."
	hint="">
<cfargument name="DSN" required="false" type="string" default="#Request.MTRDSN#"
	displayname="The DSN name to use."
	hint="">
<cfset var CURDSN=Arguments.DSN>
<cfset var codtl={}>
<cfif NOT StructKeyExists(DS,"CO")>
	<cfset DS.CO={}>
</cfif>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT TBLSOURCE=0,a.iCOID,iPCOID=IsNull(a.iPCOID,0),iGCOID=IsNull(a.iGCOID,a.iCOID),a.iCOUNTRYID,
a.vaCONAME,a.vaCOBRNAME,a.vaBRANCHCODE,siSUBSCRIBE=IsNull(a.siSUBSCRIBE,0),siHIERARCHY=IsNull(a.siHIERARCHY,0),
siCLMFORM=IsNull(p.siCLMFORM,0),siESOURCE=IsNull(a.siESOURCE,0),a.siCOTYPEID,
a.vaADD1,a.vaADD2,a.vaADD3,a.vaPOSTCODE,a.vaCOREGNO,a.iCITYID,iPROPCOID=IsNull(a.iPROPCOID,a.iCOID),
TELNO=RTrim(a.aTELNO),FAXNO=RTrim(a.aFAXNO),siACCEPTCASE=IsNull(a.siACCEPTCASE,0),siPWORKSHOP=IsNull(p.siPWORKSHOP,0),siPADJUSTER=IsNull(p.siPADJUSTER,0),
siETENDER=IsNull(a.siETENDER,0),siTPCLAIMS=IsNull(p.siTPCLAIMS,0),a.siFRANCHISE,
iSANCTIONFLAG=CASE WHEN IsNull(a.iSANCTIONFLAG,0) & 8=0 THEN IsNull(p.iSANCTIONFLAG,0) ELSE IsNull(a.iSANCTIONFLAG,0) END,
iINTSYNCFLAG=CASE WHEN IsNull(a.iINTSYNCFLAG,0) & 8=0 THEN IsNull(p.iINTSYNCFLAG,0) ELSE IsNull(a.iINTSYNCFLAG,0) END,
p.siSERVICECARDFLAG,p.siECATFLAG,iLOCID=a.iLOCID,PASCCOID=IsNull(a.iPASCCOID,0),PASCCOTYPEID=IsNull(pasc.siCOTYPEID,0),a.iSUBCOTYPEFLAG,a.iCURRENCYID,vaCONAME_TH=lng_TH.vaLANGDATA
FROM SEC0005 a WITH (NOLOCK)
	LEFT OUTER JOIN SEC0005 p WITH (NOLOCK) ON a.iGCOID=p.iCOID
	LEFT JOIN SEC0005 pasc WITH (NOLOCK) ON a.iPASCCOID=pasc.iCOID
	LEFT JOIN FLNG0002 lng_TH ON lng_TH.iUSRLANGDEFID=5 AND lng_TH.siLangId=6 AND lng_TH.iOWNER_DOMAINID=10 AND lng_TH.iOWNER_OBJID=a.iCOID AND lng_TH.siStatus=0
<!--- Refresh specific COID --->
<CFIF Arguments.COID GT 0>
WHERE a.iCOID=<cfqueryparam value="#Arguments.COID#" cfsqltype="CF_SQL_INTEGER">
UNION
SELECT TBLSOURCE=1,a.iCOID,iPCOID=0,iGCOID=a.iCOID,a.iCOUNTRYID,
a.vaCONAME,a.vaCOBRNAME,vaBRANCHCODE='',siSUBSCRIBE=0,siHIERARCHY=0,
siCLMFORM=0,siESOURCE=0,a.siCOTYPEID,
a.vaADD1,a.vaADD2,vaADD3=NULL,a.vaPOSTCODE,a.vaCOREGNO,a.iCITYID,iPROPCOID=a.iCOID,
TELNO=RTrim(a.aTELNO),FAXNO=RTrim(a.aFAXNO),siACCEPTCASE=0,siPWORKSHOP=0,siPADJUSTER=0,
siETENDER=0,siTPCLAIMS=0,siFRANCHISE=0,
iSANCTIONFLAG=0,
iINTSYNCFLAG=0,
siSERVICECARDFLAG=NULL,siECATFLAG=NULL,iLOCID=a.iLOCID,PASCCOID=0,PASCCOTYPEID=0,iSUBCOTYPEFLAG=a.iSUBCOTYPEFLAG,iCURRENCYID=NULL,vaCONAME_TH=NULL
FROM SEC0025 a WITH (NOLOCK)
WHERE a.iCOID=<cfqueryparam value="#Arguments.COID#" cfsqltype="CF_SQL_INTEGER">
<CFELSE>
<!--- Refresh all companies: Only certain cotypeid OR any company which has branches --->
WHERE ((a.siCOTYPEID IN (2,3,5,9,15,17) OR a.iCOID=1137) OR (a.iCOID IN (SELECT DISTINCT iCOID FROM SEC0015 WHERE siHIERARCHY<>0)))
	<!--- HARDCODE temporarily to exclude some heavily added rows due to out of memory error on slow machine! --->
	<!--- Turn off CFIDE monitor/profiling actually help a lot! (KY idea) --->
	<!---cfif Application.DB_MODE IS "DEV" AND Application.APPDEVMODE IS 1 AND Application.APPINSTANCE_SHORTNAME IS "MIKE-CLM">
	AND NOT(a.iLOCID=11 AND a.siCOTYPEID<>2 AND a.vaCONAME NOT LIKE '%BETA%')
	</cfif--->
	<!--- Exclude Finance company/branches from loading into appvars, as they all neither have login nor subscribed. Esp TH has too many finance branches causing overload to CF --->
	AND NOT(a.siCOTYPEID=7)
</CFIF>
</cfquery>
<cfoutput query=q_trx>
	<cfset StructClear(codtl)>
	<cfset StructInsert(codtl,"GCOID",iGCOID)>
	<cfset StructInsert(codtl,"PROPCOID",iPROPCOID)>
	<cfset StructInsert(codtl,"LOCID",iLOCID)>
	<cfset StructInsert(codtl,"ADD1",Trim(vaADD1))>
	<cfset StructInsert(codtl,"ADD2",Trim(vaADD2))>
	<cfset StructInsert(codtl,"ADD3",Trim(vaADD3))>
	<cfset StructInsert(codtl,"POSTCODE",Trim(vaPOSTCODE))>
	<cfset StructInsert(codtl,"COREGNO",Trim(vaCOREGNO))>
	<CFIF siFRANCHISE GT 0>
		<cfset StructInsert(codtl,"FRANCHISE",siFRANCHISE)>
	</CFIF>
	<cfset StructInsert(codtl,"CITYID",iCITYID)>
	<CFIF PASCCOID GT 0>
		<cfset StructInsert(codtl,"PASCCOID",PASCCOID)>
		<cfset StructInsert(codtl,"PASCCOTYPEID",PASCCOTYPEID)>
	</CFIF>
	<cfset StructInsert(codtl,"COTYPEID",siCOTYPEID)>
	<cfset StructInsert(codtl,"SUBSCRIBE",siSUBSCRIBE)>
	<cfset StructInsert(codtl,"COESOURCE",siESOURCE)>
	<cfset StructInsert(codtl,"ETENDER",siETENDER)>
	<cfset StructInsert(codtl,"TELNO",TELNO)>
	<cfset StructInsert(codtl,"TPCLAIMS",siTPCLAIMS)>
	<cfset StructInsert(codtl,"CLMFORM",siCLMFORM)>
	<cfset StructInsert(codtl,"CONAME",Trim(vaCONAME))>
	<cfset StructInsert(codtl,"CONAME_LANG",{ #iLOCID#={DESC=Trim(vaCONAME_TH)} })>
	<cfset StructInsert(codtl,"COBRNAME",Trim(vaCOBRNAME))>
	<cfset StructInsert(codtl,"BRANCHCODE",Trim(vaBRANCHCODE))>
	<cfset StructInsert(codtl,"ACCEPTCASE",siACCEPTCASE)>
	<cfset StructInsert(codtl,"PWORKSHOP",siPWORKSHOP)>
	<cfset StructInsert(codtl,"PADJUSTER",siPADJUSTER)>
	<cfset StructInsert(codtl,"SANCTIONFLAG",iSANCTIONFLAG)>
	<cfset StructInsert(codtl,"INTSYNCFLAG",iINTSYNCFLAG)>
	<cfset StructInsert(codtl,"SVCCARDFLAG",siSERVICECARDFLAG)>
	<cfset StructInsert(codtl,"ECATFLAG",siECATFLAG)>
	<cfset StructInsert(codtl,"FAXNO",FAXNO)>
	<CFSET StructInsert(codtl,"SUBCOTYPE",iSUBCOTYPEFLAG)>
	<CFSET StructInsert(codtl,"CURRENCYID",iCURRENCYID)>
	<cfif ((IGCOID IS iCOID) OR (iPROPCOID IS iCOID)) AND TBLSOURCE EQ 0>
		<cfquery name=q_colabel datasource=#CURDSN#>
			select a.ilbldefid from fobjb3020 a WITH (NOLOCK),FOBJB3022 b WITH (NOLOCK) where b.igcoid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iGCOID#"> and b.siSTATUS=0 AND b.iLBLDEFID=a.iLBLDEFID AND a.siprivate=1 and a.sistatus=0
		</cfquery>
		<cfset StructInsert(codtl,"LABELLIST",ValueList(q_colabel.iLBLDEFID))>

		<CFQUERY name=q_pcls datasource=#CURDSN#>
		SELECT a.iINSCLASSID,a.vaINSCLASSNAME
		FROM BIZ2010 a WITH (NOLOCK)
		WHERE a.iCOID IN (<cfqueryparam cfsqltype="CF_SQL_INTEGER" list="true" value="#IGCOID#">) AND a.siSTATUS=0
		ORDER BY a.vaINSCLASSNAME
		</CFQUERY>
		<CFSET PCLS="">
		<cfif q_pcls.recordcount GT 0>
			<CFSET PCLS=structnew()>
			<CFLOOP query=q_pcls>
				<cfset StructInsert(PCLS,q_pcls.iINSCLASSID,structnew())>
				<cfset StructInsert(PCLS[q_pcls.iINSCLASSID],"name","#q_pcls.vaINSCLASSNAME#")>
				<cfset StructInsert(PCLS[q_pcls.iINSCLASSID],"parentid",0)>
			</CFLOOP>
		</cfif>
		<cfset StructInsert(codtl,"PCLS1",PCLS)>

		<CFQUERY name=q_pcls datasource=#CURDSN#>
		SELECT a.iPOLID,a.iINSCLASSID,a.vaPOLNAME
		FROM BIZ2011 a WITH (NOLOCK)
		WHERE a.iCOID IN (<cfqueryparam cfsqltype="CF_SQL_INTEGER" list="true" value="#IGCOID#">) AND a.siSTATUS=0
		ORDER BY a.iINSCLASSID,a.vaPOLNAME
		</CFQUERY>
		<CFSET PCLS="">
		<cfif q_pcls.recordcount GT 0>
			<CFSET PCLS=structnew()>
			<CFLOOP query=q_pcls>
				<cfset StructInsert(PCLS,q_pcls.iPOLID,structnew())>
				<cfset StructInsert(PCLS[q_pcls.iPOLID],"name","#q_pcls.vaPOLNAME#")>
				<cfset StructInsert(PCLS[q_pcls.iPOLID],"parentid",q_pcls.iINSCLASSID)>
			</CFLOOP>
		</cfif>
		<cfset StructInsert(codtl,"PCLS2",PCLS)>

		<CFQUERY name=q_pcls datasource=#CURDSN#>
		SELECT a.iBUSID,a.iPOLID,a.vaBUSNAME
		FROM BIZ2012 a WITH (NOLOCK)
		WHERE a.iCOID IN (<cfqueryparam cfsqltype="CF_SQL_INTEGER" list="true" value="#IGCOID#">) AND a.siSTATUS=0
		ORDER BY a.iPOLID,a.vaBUSNAME
		</CFQUERY>
		<CFSET PCLS="">
		<cfif q_pcls.recordcount GT 0>
			<CFSET PCLS=structnew()>
			<CFLOOP query=q_pcls>
				<cfset StructInsert(PCLS,q_pcls.iBUSID,structnew())>
				<cfset StructInsert(PCLS[q_pcls.iBUSID],"name","#q_pcls.vaBUSNAME#")>
				<cfset StructInsert(PCLS[q_pcls.iBUSID],"parentid",q_pcls.iPOLID)>
			</CFLOOP>
		</cfif>
		<cfset StructInsert(codtl,"PCLS3",PCLS)>

		<cfset StructInsert(codtl,"COUNTRYID",iCOUNTRYID)>
		<CFIF iLOCID IS 4>
			<cfquery NAME=q_trx2 DATASOURCE=#CURDSN#>
			select a.siREGID,a.vaDESC from BIZ0040 a WITH (NOLOCK) where a.siSTATUS=0 AND a.iGCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iGCOID#">
			</CFQUERY>
			<CFIF q_trx2.recordcount GT 0>
				<CFSET GREGOFF=StructNew()>
				<CFLOOP query=q_trx2><cfset StructInsert(GREGOFF,siREGID,vaDESC)></CFLOOP>
				<cfset StructInsert(codtl,"GREGOFF",GREGOFF)>
			</CFIF>
		</CFIF>
		<cfquery NAME=q_trxgcform DATASOURCE=#CURDSN#>
		SELECT iRACURR FROM FSYSB0024 WITH (NOLOCK) WHERE iCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iGCOID#"> AND aRANAME='GCLMFNO' AND siRAACTIVE=1
		</cfquery>
		<cfif q_trxgcform.recordcount GT 0>
			<cfset StructInsert(codtl,"GCFORM",1)>
		<cfelse>
			<cfset StructInsert(codtl,"GCFORM",0)>
		</cfif>
		<cfquery NAME=q_trxgcform DATASOURCE=#CURDSN#>
		SELECT iRACURR FROM FSYSB0024 WITH (NOLOCK) WHERE iCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iGCOID#"> AND aRANAME='NOTICENO' AND siRAACTIVE=1
		</cfquery>
		<cfif q_trxgcform.recordcount GT 0>
			<cfset StructInsert(codtl,"NOTICEFORM",1)>
		<cfelse>
			<cfset StructInsert(codtl,"NOTICEFORM",0)>
		</cfif>
		<CFSET str=DS.FN.SVCgetExtAttrLogic("COADMIN",0,"COATTR59",10,iGCOID)>
		<CFIF str IS NOT "" AND IsNumeric(str)>
			<cfset StructInsert(codtl,"ESTSALVAGE",Val(str))>
		</CFIF>
		<CFSET str=DS.FN.SVCgetExtAttrLogic("COADMIN",0,"COATTR60",10,iGCOID)>
		<CFIF str IS NOT "" AND IsNumeric(str)>
			<cfset StructInsert(codtl,"CLMFORM_CLMTYPEMASK",Val(str))>
		</CFIF>
		<CFSET str=DS.FN.SVCgetExtAttrLogic("COADMIN",0,"COATTR-TENDERTYPE",10,iGCOID)>
		<CFIF str IS NOT "">
			<cfset StructInsert(codtl,"ETTYPE",str)>
		</CFIF>
		<CFSET str=DS.FN.SVCgetExtAttrLogic("COADMIN",0,"COATTR80",10,iGCOID)>
		<CFIF str IS NOT "" AND IsNumeric(str)>
			<cfset StructInsert(codtl,"ESTFLAG",Val(str))>
		</CFIF>
		<CFSET str=DS.FN.SVCgetExtAttrLogic("COADMIN",0,"COATTR103",10,iGCOID)>
		<CFIF str IS 1>
			<cfset StructInsert(codtl,"COATTR_SVCPAY",Val(str))>
		</CFIF>
		<CFSET str=DS.FN.SVCgetExtAttrLogic("COADMIN",0,"COATTR114",10,iGCOID)>
		<CFIF str IS NOT "" AND IsNumeric(str)>
			<cfset StructInsert(codtl,"ADJRPTFORCEMANDT_CLMTYPEMASK",Val(str))>
		</CFIF>

		<!--- hide tender details --->
		<cfif siCOTYPEID IS 2>
			<CFSET str=DS.FN.SVCgetExtAttrLogic("COADMIN",0,"COATTR53",10,iGCOID)>
			<CFIF str IS NOT "" AND IsNumeric(str)>
				<cfset StructInsert(codtl,"ETHIDEDTL",str)>
			<cfelse>
				<cfset StructInsert(codtl,"ETHIDEDTL",0)>
			</cfif>
		</cfif>

		<!--- Policy group management (insurers and adjuster only) --->
		<CFIF siCOTYPEID IS 2 OR siCOTYPEID IS 3>
			<CFSET POLGRP=StructNew()>
			<cfset POLGRPSEQ="">
			<cfquery NAME=q_trx2 DATASOURCE=#CURDSN#>
			SELECT POLGRPID=a.iPOLGRPID,POLGRPNAME=a.vaDESC, POLGRPREMARKS=a.txremarks
			FROM BIZ2018 a WITH (NOLOCK) WHERE a.igcoid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iGCOID#"> AND a.siSTATUS=0
			ORDER BY ISNULL(iPRIORITY,-1), a.iPOLGRPID
			</CFQUERY>
			<CFLOOP query=q_trx2>
				<CFSET POLGRPDTL=StructNew()>
				<CFSET StructInsert(POLGRPDTL,"NAME",Trim(q_trx2.POLGRPNAME))>
				<CFSET StructInsert(POLGRPDTL,"REMARKS",Trim(q_trx2.POLGRPREMARKS))>
				<cfquery NAME=q_trx3 DATASOURCE=#CURDSN#>
				SELECT a.iPOLGRPDTLID,iPOLCLSLEVEL=IsNull(a.iPOLCLSLEVEL,-1),iINSCLASSID=IsNull(a.iINSCLASSID,0),iPOLID=IsNull(a.iPOLID,0),iBUSID=IsNull(a.iBUSID,0),iCLMTYPEMASK=IsNull(a.iCLMTYPEMASK,0),siTL=ISNULL(a.siTL,-1)
				FROM BIZ2019 a WITH (NOLOCK) WHERE a.iPOLGRPID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#POLGRPID#"> AND a.siSTATUS=0
				ORDER BY IsNull(a.iPOLCLSLEVEL,-1)
				</CFQUERY>
				<CFSET RULES=ArrayNew(1)>
				<CFLOOP query=q_trx3>
					<CFSET RULES[q_trx3.currentrow]={ID=iPOLGRPDTLID,PRIORITY=iPOLCLSLEVEL,INSCLASSID=iINSCLASSID,POLID=iPOLID,BUSID=iBUSID,CLMTYPEMASK=iCLMTYPEMASK,TOTALLOSS=siTL}>
				</CFLOOP>
				<CFSET StructInsert(POLGRPDTL,"RULES",RULES)>
				<CFSET StructInsert(POLGRP,POLGRPID,POLGRPDTL)>
                <CFSET POLGRPSEQ=#LISTAPPEND(POLGRPSEQ,q_trx2.POLGRPID)#>
			</CFLOOP>
			<cfset StructInsert(codtl,"POLGRP",POLGRP)>
			<cfset StructInsert(codtl,"POLGRPSEQ",POLGRPSEQ)>

			<cfquery NAME=q_trx2 DATASOURCE=#CURDSN#>
			SELECT vaLIMITCODE FROM SEC0017 WITH (NOLOCK) WHERE igcoid in (0,<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iGCOID#">) AND siSTATUS=0 and LEN(valimitcode)>0
			ORDER BY CASE WHEN vaLIMITCODE IN ('CLM','RSV','PAY','RPI') THEN 0 ELSE 1 END, vaLIMITCODE
			</CFQUERY>
			<cfset POLGRP_LIMITCODE=#valuelist(q_trx2.valimitcode)#>
			<cfset StructInsert(codtl,"POLGRP_LIMITCODE","#POLGRP_LIMITCODE#")>
		</CFIF>

		<CFIF (IPROPCOID IS iCOID) AND (iGCOID IS NOT iPROPCOID)>
			<!--- Get List of Companies in Group --->
			<cfquery NAME=q_trx2 DATASOURCE=#CURDSN#>
			SELECT a.iCOID,vaCOBRNAME=RTrim(a.vaCOBRNAME) FROM SEC0005 a WITH (NOLOCK) WHERE
			a.iGCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iGCOID#"> AND a.iPROPCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iPROPCOID#"> AND
			a.siCOTYPEID=<cfqueryparam value="#q_trx.sicotypeid#" cfsqltype="CF_SQL_NUMERIC"> AND a.siSTATUS=0
			ORDER BY a.siHIERARCHY,a.vaCOBRNAME
			</cfquery>
			<cfset StructInsert(codtl,"GCOLIST",ValueList(q_trx2.iCOID))>
			<cfset StructInsert(codtl,"GCONAME",ValueList(q_trx2.vaCOBRNAME))>
			<!--- Get List of Companies in Group Accepting Cases --->
			<cfquery NAME=q_trx2 DATASOURCE=#CURDSN#>
			SELECT a.iCOID,vaCOBRNAME=RTrim(a.vaCOBRNAME) FROM SEC0005 a WITH (NOLOCK) WHERE
			a.iGCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iGCOID#"> AND a.iPROPCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iPROPCOID#"> AND
			a.siCOTYPEID=<cfqueryparam value="#q_trx.sicotypeid#" cfsqltype="CF_SQL_NUMERIC"> AND a.siSTATUS=0 AND a.siACCEPTCASE=1
			ORDER BY a.siHIERARCHY,a.vaCOBRNAME
			</cfquery>
			<cfset StructInsert(codtl,"GCLMCOLIST",ValueList(q_trx2.iCOID))>
			<cfset StructInsert(codtl,"GCLMCONAME",ValueList(q_trx2.vaCOBRNAME))>

			<cfquery NAME=q_trx2 DATASOURCE=#CURDSN#>
			SELECT a.iCOID,vaCOBRNAME=RTrim(a.vaCOBRNAME) FROM SEC0005 a WITH (NOLOCK) WHERE
			a.iGCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iGCOID#"> AND a.iPROPCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iPROPCOID#"> AND
			a.siCOTYPEID=<cfqueryparam value="#q_trx.sicotypeid#" cfsqltype="CF_SQL_NUMERIC"> AND a.siSTATUS=0 AND COALESCE(a.siACCEPTCASE,0)>0
			ORDER BY a.siHIERARCHY,a.vaCOBRNAME
			</cfquery>
			<cfset StructInsert(codtl,"GCLMCOACCEPTLIST",ValueList(q_trx2.iCOID))>
			<cfset StructInsert(codtl,"GCLMCOACCEPTNAME",ValueList(q_trx2.vaCOBRNAME))>
		<CFELSE>
			<!--- Get List of Companies in Group --->
			<cfquery NAME=q_trx2 DATASOURCE=#CURDSN#>
			SELECT a.iCOID,vaCOBRNAME=RTrim(a.vaCOBRNAME) FROM SEC0005 a WITH (NOLOCK) WHERE
			a.iGCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iGCOID#"> AND
			a.siCOTYPEID=<cfqueryparam value="#q_trx.sicotypeid#" cfsqltype="CF_SQL_NUMERIC"> AND a.siSTATUS=0
			ORDER BY a.siHIERARCHY,a.vaCOBRNAME
			</cfquery>
			<cfset StructInsert(codtl,"GCOLIST",ValueList(q_trx2.iCOID))>
			<cfset StructInsert(codtl,"GCONAME",ValueList(q_trx2.vaCOBRNAME))>
			<!--- Get List of Companies in Group Accepting Cases --->
			<cfquery NAME=q_trx2 DATASOURCE=#CURDSN#>
			SELECT a.iCOID,vaCOBRNAME=RTrim(a.vaCOBRNAME) FROM SEC0005 a WITH (NOLOCK) WHERE
			a.iGCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iGCOID#"> AND
			a.siCOTYPEID=<cfqueryparam value="#q_trx.sicotypeid#" cfsqltype="CF_SQL_NUMERIC"> AND a.siSTATUS=0 AND a.siACCEPTCASE=1
			ORDER BY a.siHIERARCHY,a.vaCOBRNAME
			</cfquery>
			<cfset StructInsert(codtl,"GCLMCOLIST",ValueList(q_trx2.iCOID))>
			<cfset StructInsert(codtl,"GCLMCONAME",ValueList(q_trx2.vaCOBRNAME))>

			<cfquery NAME=q_trx2 DATASOURCE=#CURDSN#>
			SELECT a.iCOID,vaCOBRNAME=RTrim(a.vaCOBRNAME) FROM SEC0005 a WITH (NOLOCK) WHERE
			a.iGCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iGCOID#"> AND
			a.siCOTYPEID=<cfqueryparam value="#q_trx.sicotypeid#" cfsqltype="CF_SQL_NUMERIC"> AND a.siSTATUS=0 AND COALESCE(a.siACCEPTCASE,0)>0
			ORDER BY a.siHIERARCHY,a.vaCOBRNAME
			</cfquery>
			<cfset StructInsert(codtl,"GCLMCOACCEPTLIST",ValueList(q_trx2.iCOID))>
			<cfset StructInsert(codtl,"GCLMCOACCEPTNAME",ValueList(q_trx2.vaCOBRNAME))>
		</CFIF>

		<!--- List of Mandatory Branch For A Particular State --->
		<cfquery NAME=q_trx2 DATASOURCE=#CURDSN#>
		SELECT a.iSTATEID,a.iBRCOID FROM SYS0017 a WITH (NOLOCK),SEC0005 b WITH (NOLOCK) WHERE a.iMAINCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iCOID#">
		AND a.iBRCOID=b.iCOID
		ORDER BY a.iSTATEID,b.siHIERARCHY,b.vaCOBRNAME
		</cfquery>
		<cfloop QUERY=q_trx2>
			<cfif StructKeyExists(codtl,"INSSTATE#iSTATEID#")>
				<cfset StructUpdate(codtl,"INSSTATE#iSTATEID#",StructFind(codtl,"INSSTATE#iSTATEID#")&","&iBRCOID)>
			<cfelse>
				<cfset StructInsert(codtl,"INSSTATE#iSTATEID#",iBRCOID)>
			</cfif>
		</cfloop>
	</cfif>

	<!--- Get parent list --->
	<cfset PCOLIST=iPCOID><cfset curpcoid=pcolist>
	<cfloop CONDITION="curpcoid GT 0">
		<cfquery NAME=q_trx2 DATASOURCE=#CURDSN#>
		SELECT iPCOID FROM SEC0005 WITH (NOLOCK) WHERE iCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#curpcoid#"> AND iPCOID>0
		</cfquery>
		<cfif q_trx2.recordcount GT 0>
			<cfset curpcoid=q_trx2.iPCOID>
			<CFIF ListFind(pcolist,curpcoid) GT 0>
				<cfthrow TYPE="EX_SECFAILED" ErrorCode="LOOP" ExtendedInfo="LOOP">
			</CFIF>
			<cfset pcolist=pcolist&","&curpcoid>
		<cfelse>
			<cfset curpcoid=0>
		</cfif>
	</cfloop>
	<!--- Get child list --->
	<cfset branches=iCOID>
	<cfset brnamelist=Trim(vaCOBRNAME)>
	<cfquery NAME=q_trx2 DATASOURCE=#CURDSN#>
	SELECT a.iCOID,vaCOBRNAME=RTrim(a.vaCOBRNAME) FROM SEC0005 a WITH (NOLOCK),SEC0015 b WITH (NOLOCK)
	WHERE b.iCOID=<cfqueryparam value="#q_trx.iCOID#" cfsqltype="CF_SQL_INTEGER"> AND a.iCOID=b.iCHCOID AND a.siSTATUS=0 AND
	a.siSUBSCRIBE&1=1 AND a.siCOTYPEID=<cfqueryparam value="#q_trx.sicotypeid#" cfsqltype="CF_SQL_NUMERIC"> AND b.siHIERARCHY>0
	ORDER BY a.iORDER
	</cfquery>
	<cfif q_trx2.recordcount GT 0>
		<cfset branches=branches&","&ValueList(q_trx2.iCOID)>
		<cfset brnamelist=brnamelist&","&ValueList(q_trx2.vaCOBRNAME)>
	</cfif>
	<cfset StructInsert(codtl,"PCOLIST",pcolist)>
	<cfset StructInsert(codtl,"HIERARCHY",siHIERARCHY)>
	<cfset StructInsert(codtl,"CHCOLIST",branches)>
	<cfset StructInsert(codtl,"CHCOBRLIST",brnamelist)>

	<cfif NOT StructKeyExists(DS.CO,iCOID)>
		<cfset StructInsert(DS.CO,iCOID,Duplicate(codtl))>
	<cfelse>
		<cfset DS.CO[iCOID]=Duplicate(codtl)>
	</cfif>
</cfoutput>
<CFRETURN>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRcovar_DSUpdate=MTRcovar_DSUpdate>



<cffunction name="MTRcovar_DSUpdate_Faster" hint="Refresh the Request.DS.CO" returntype="any" output="false">
<cfargument name="COID" required="false" type="numeric" default=0
	displayname="Company ID"
	hint="Leave blank to refresh all companies">
<cfargument name="DS" required="false" type="struct" default="#Request.DS#"
	displayname="The DS to update."
	hint="">
<cfargument name="DSN" required="false" type="string" default="#Request.MTRDSN#"
	displayname="The DSN name to use."
	hint="">
<cfset var CURDSN=Arguments.DSN>
<cfset var codtl={}>
<cfset var pgmarr=arrayNew(1)>
<cfset var coidarr=arrayNew(1)>
<cfif NOT StructKeyExists(DS,"CO")>
	<cfset DS.CO={}>
</cfif>
<cfquery NAME=q_trx DATASOURCE=#CURDSN#>
SELECT TBLSOURCE=0,a.iCOID,iPCOID=IsNull(a.iPCOID,0),iGCOID=IsNull(a.iGCOID,a.iCOID),a.iCOUNTRYID,
a.vaCONAME,a.vaCOBRNAME,a.vaBRANCHCODE,siSUBSCRIBE=IsNull(a.siSUBSCRIBE,0),siHIERARCHY=IsNull(a.siHIERARCHY,0),
siCLMFORM=IsNull(p.siCLMFORM,0),siESOURCE=IsNull(a.siESOURCE,0),a.siCOTYPEID,
a.vaADD1,a.vaADD2,a.vaADD3,a.vaPOSTCODE,a.vaCOREGNO,a.iCITYID,iPROPCOID=IsNull(a.iPROPCOID,a.iCOID),
TELNO=RTrim(a.aTELNO),FAXNO=RTrim(a.aFAXNO),siACCEPTCASE=IsNull(a.siACCEPTCASE,0),siPWORKSHOP=IsNull(p.siPWORKSHOP,0),siPADJUSTER=IsNull(p.siPADJUSTER,0),
siETENDER=IsNull(a.siETENDER,0),siTPCLAIMS=IsNull(p.siTPCLAIMS,0),a.siFRANCHISE,
iSANCTIONFLAG=CASE WHEN IsNull(a.iSANCTIONFLAG,0) & 8=0 THEN IsNull(p.iSANCTIONFLAG,0) ELSE IsNull(a.iSANCTIONFLAG,0) END,
iINTSYNCFLAG=CASE WHEN IsNull(a.iINTSYNCFLAG,0) & 8=0 THEN IsNull(p.iINTSYNCFLAG,0) ELSE IsNull(a.iINTSYNCFLAG,0) END,
p.siSERVICECARDFLAG,p.siECATFLAG,iLOCID=a.iLOCID,PASCCOID=IsNull(a.iPASCCOID,0),PASCCOTYPEID=IsNull(pasc.siCOTYPEID,0),a.iSUBCOTYPEFLAG,a.iCURRENCYID,vaCONAME_TH=lng_TH.vaLANGDATA
<CFIF Arguments.COID EQ 0>
,LABELLIST = COLABEL.LABELLIST, GCFORM_HASVALUE = isNULL(GCFORM.HASVALUE,0), NOTICEFORM_HASVALUE = isNULL(NOTICEFORM.HASVALUE,0)
,GCO.gcolist, GCO.gconame, GCO.gclmcolist, GCO.gclmconame, GCO.gclmcoacceptlist, GCO.gclmcoacceptname
,p_gcolist = GCO2.gcolist, p_gconame = GCO2.gconame, p_gclmcolist = GCO2.gclmcolist, p_gclmconame = GCO2.gclmconame, p_gclmcoacceptlist = GCO2.gclmcoacceptlist, p_gclmcoacceptname = GCO2.gclmcoacceptname
,BRANCHES,BRNAMELIST,PCOLIST
</CFIF>
FROM SEC0005 a WITH (NOLOCK)
	LEFT OUTER JOIN SEC0005 p WITH (NOLOCK) ON a.iGCOID=p.iCOID
	LEFT JOIN SEC0005 pasc WITH (NOLOCK) ON a.iPASCCOID=pasc.iCOID
	LEFT JOIN FLNG0002 lng_TH ON lng_TH.iUSRLANGDEFID=5 AND lng_TH.siLangId=6 AND lng_TH.iOWNER_DOMAINID=10 AND lng_TH.iOWNER_OBJID=a.iCOID AND lng_TH.siStatus=0
<!--- Refresh specific COID --->
<CFIF Arguments.COID GT 0>
WHERE a.iCOID=<cfqueryparam value="#Arguments.COID#" cfsqltype="CF_SQL_INTEGER">
UNION
SELECT TBLSOURCE=1,a.iCOID,iPCOID=0,iGCOID=a.iCOID,a.iCOUNTRYID,
a.vaCONAME,a.vaCOBRNAME,a.vaBRANCHCODE,siSUBSCRIBE=0,siHIERARCHY=0,
siCLMFORM=0,siESOURCE=0,a.siCOTYPEID,
a.vaADD1,a.vaADD2,vaADD3=NULL,a.vaPOSTCODE,a.vaCOREGNO,a.iCITYID,iPROPCOID=a.iCOID,
TELNO=RTrim(a.aTELNO),FAXNO=RTrim(a.aFAXNO),siACCEPTCASE=0,siPWORKSHOP=0,siPADJUSTER=0,
siETENDER=0,siTPCLAIMS=0,siFRANCHISE=0,
iSANCTIONFLAG=0,
iINTSYNCFLAG=0,
siSERVICECARDFLAG=NULL,siECATFLAG=NULL,iLOCID=a.iLOCID,PASCCOID=0,PASCCOTYPEID=0,iSUBCOTYPEFLAG=a.iSUBCOTYPEFLAG,iCURRENCYID=NULL,vaCONAME_TH=NULL
FROM SEC0025 a WITH (NOLOCK)
WHERE a.iCOID=<cfqueryparam value="#Arguments.COID#" cfsqltype="CF_SQL_INTEGER">
<CFELSE>
	LEFT JOIN (
		select DISTINCT C.iGCOID, LABELLIST=STUFF(( select ','+cast(a.ILBLDEFID as varchar) from FOBJB3020 a inner join FOBJB3022 b on a.iLBLDEFID=b.ILBLDEFID
		where b.siSTATUS=0 and a.SIPRIVATE=1 and a.SISTATUS=0 and b.iGCOID=c.iGCOID for xml path(''), ELEMENTS), 1, 1, '')
		FROM FOBJB3022 c where c.sistatus=0
	) COLABEL ON a.iGCOID = COLABEL.iGCOID
	LEFT JOIN (
		SELECT iCOID, HASVALUE=1 FROM FSYSB0024 WITH (NOLOCK) WHERE aRANAME='GCLMFNO' AND siRAACTIVE=1
	) GCFORM ON a.iGCOID = GCFORM.iCOID
	LEFT JOIN (
		SELECT iCOID,HASVALUE=1 FROM FSYSB0024 WITH (NOLOCK) WHERE aRANAME='NOTICENO' AND siRAACTIVE=1
	)  NOTICEFORM ON a.iGCOID = NOTICEFORM.iCOID
	LEFT JOIN (
		select DISTINCT C.iGCOID
		, gcolist=STUFF(( select ','+cast(a.iCOID as varchar) from sec0005 a where a.siSTATUS=0 and a.iGCOID=c.iGCOID order by a.siHIERARCHY, a.vaCOBRNAME for xml path(''), ELEMENTS), 1, 1, '')
		, gconame=dbo.fUNXML(STUFF(( select ','+a.vaCOBRNAME from sec0005 a where a.siSTATUS=0 and a.iGCOID=c.iGCOID order by a.siHIERARCHY, a.vaCOBRNAME for xml path(''), ELEMENTS), 1, 1, ''))
		, gclmcolist=STUFF(( select ','+cast(a.iCOID as varchar) from sec0005 a where a.siSTATUS=0 AND a.siACCEPTCASE=1 and a.iGCOID=c.iGCOID order by a.siHIERARCHY, a.vaCOBRNAME for xml path(''), ELEMENTS), 1, 1, '')
		, gclmconame=dbo.fUNXML(STUFF(( select ','+a.vaCOBRNAME from sec0005 a where a.siSTATUS=0 AND a.siACCEPTCASE=1 and a.iGCOID=c.iGCOID order by a.siHIERARCHY, a.vaCOBRNAME for xml path(''), ELEMENTS), 1, 1, ''))
		, gclmcoacceptlist=STUFF(( select ','+cast(a.iCOID as varchar) from sec0005 a where a.siSTATUS=0 AND COALESCE(a.siACCEPTCASE,0)>0 and a.iGCOID=c.iGCOID order by a.siHIERARCHY, a.vaCOBRNAME for xml path(''), ELEMENTS), 1, 1, '')
		, gclmcoacceptname=dbo.fUNXML(STUFF(( select ','+a.vaCOBRNAME from sec0005 a where a.siSTATUS=0 AND COALESCE(a.siACCEPTCASE,0)>0 and a.iGCOID=c.iGCOID order by a.siHIERARCHY, a.vaCOBRNAME for xml path(''), ELEMENTS), 1, 1, ''))
		, c.sicotypeid
		FROM SEC0005 c WHERE c.siSTATUS=0 and ipcoid=0
	) GCO on GCO.iGCOID=a.iCOID and GCO.sicotypeid = a.sicotypeid
	LEFT JOIN (
		select DISTINCT C.iGCOID
		, gcolist=STUFF(( select ','+cast(a.iCOID as varchar) from sec0005 a where a.siSTATUS=0 and a.iGCOID=c.iGCOID and a.iPROPCOID=c.iPROPCOID order by a.siHIERARCHY, a.vaCOBRNAME for xml path(''), ELEMENTS), 1, 1, '')
		, gconame=dbo.fUNXML(STUFF(( select ','+a.vaCOBRNAME from sec0005 a where a.siSTATUS=0 and a.iGCOID=c.iGCOID and a.iPROPCOID=c.iPROPCOID order by a.siHIERARCHY, a.vaCOBRNAME for xml path(''), ELEMENTS), 1, 1, ''))
		, gclmcolist=STUFF(( select ','+cast(a.iCOID as varchar) from sec0005 a where a.siSTATUS=0 AND a.siACCEPTCASE=1 and a.iGCOID=c.iGCOID and a.iPROPCOID=c.iPROPCOID order by a.siHIERARCHY, a.vaCOBRNAME for xml path(''), ELEMENTS), 1, 1, '')
		, gclmconame=dbo.fUNXML(STUFF(( select ','+a.vaCOBRNAME from sec0005 a where a.siSTATUS=0 AND a.siACCEPTCASE=1 and a.iGCOID=c.iGCOID and a.iPROPCOID=c.iPROPCOID order by a.siHIERARCHY, a.vaCOBRNAME for xml path(''), ELEMENTS), 1, 1, ''))
		, gclmcoacceptlist=STUFF(( select ','+cast(a.iCOID as varchar) from sec0005 a where a.siSTATUS=0 AND COALESCE(a.siACCEPTCASE,0)>0 and a.iGCOID=c.iGCOID and a.iPROPCOID=c.iPROPCOID order by a.siHIERARCHY, a.vaCOBRNAME for xml path(''), ELEMENTS), 1, 1, '')
		, gclmcoacceptname=dbo.fUNXML(STUFF(( select ','+a.vaCOBRNAME from sec0005 a where a.siSTATUS=0 AND COALESCE(a.siACCEPTCASE,0)>0 and a.iGCOID=c.iGCOID and a.iPROPCOID=c.iPROPCOID order by a.siHIERARCHY, a.vaCOBRNAME for xml path(''), ELEMENTS), 1, 1, ''))
		, c.sicotypeid
		, c.icoid
		,c.iPROPCOID
		FROM SEC0005 c WHERE c.siSTATUS=0 and c.IPROPCOID = c.iCOID AND c.iGCOID <> c.iPROPCOID
	) GCO2 on GCO2.iGCOID=a.iCOID and GCO2.sicotypeid = a.sicotypeid and GCO2.iPROPCOID=a.iPROPCOID
	left join (
		SELECT DISTINCT x.iCOID
			,BRANCHES   = STUFF(( select ','+cast(a.icoid as varchar)			   				from SEC0005 a, SEC0015 b where a.siSUBSCRIBE&1=1 and a.iCOID=b.iCHCOID and ((b.siHIERARCHY>0 and a.siSTATUS=0) or (a.iCOID=x.iCOID)) and b.iCOID=x.iCOID and a.sicotypeid = x.sicotypeid order by a.iorder for xml path(''), ELEMENTS), 1, 1, '')
			,BRNAMELIST = dbo.fUNXML(STUFF(( select ','+cast( RTRIM(a.vaCOBRNAME) as varchar) 	from SEC0005 a, SEC0015 b where a.siSUBSCRIBE&1=1 and a.iCOID=b.iCHCOID and ((b.siHIERARCHY>0 and a.siSTATUS=0) or (a.iCOID=x.iCOID)) and b.iCOID=x.iCOID and a.sicotypeid = x.sicotypeid order by a.iorder for xml path(''), ELEMENTS), 1, 1, ''))
			,PCOLIST	= isNULL(STUFF(( select ','+cast( RTRIM(a.iCOID) as varchar) from SEC0005 a, SEC0015 b 			  where a.siSUBSCRIBE&1=1 and a.iCOID=b.iCHCOID and a.siSTATUS=0 and (b.siHIERARCHY<0) and b.iCOID=x.iCOID  order by a.iorder desc for xml path(''), ELEMENTS), 1, 1, ''),0)
		FROM SEC0005 x WITH (NOLOCK) where x.sistatus=0
	) f on f.iCOID = a.iCOID
<!--- Refresh all companies: Only certain cotypeid OR any company which has branches --->
WHERE ((a.siCOTYPEID IN (2,3,5,9,15,17) OR a.iCOID=1137) OR (a.iCOID IN (SELECT DISTINCT iCOID FROM SEC0015 WHERE siHIERARCHY<>0)))
	<!--- HARDCODE temporarily to exclude some heavily added rows due to out of memory error on slow machine! --->
	<!--- Turn off CFIDE monitor/profiling actually help a lot! (KY idea) --->
	<!---cfif Application.DB_MODE IS "DEV" AND Application.APPDEVMODE IS 1 AND Application.APPINSTANCE_SHORTNAME IS "MIKE-CLM">
	AND NOT(a.iLOCID=11 AND a.siCOTYPEID<>2 AND a.vaCONAME NOT LIKE '%BETA%')
	</cfif--->
	<!--- Exclude Finance company/branches from loading into appvars, as they all neither have login nor subscribed. Esp TH has too many finance branches causing overload to CF --->
	AND NOT(a.siCOTYPEID=7)
</CFIF>
</cfquery>
<cfoutput query=q_trx>
	<cfset StructClear(codtl)>
	<cfset StructInsert(codtl,"GCOID",iGCOID)>
	<cfset StructInsert(codtl,"PROPCOID",iPROPCOID)>
	<cfset StructInsert(codtl,"LOCID",iLOCID)>
	<cfset StructInsert(codtl,"ADD1",Trim(vaADD1))>
	<cfset StructInsert(codtl,"ADD2",Trim(vaADD2))>
	<cfset StructInsert(codtl,"ADD3",Trim(vaADD3))>
	<cfset StructInsert(codtl,"POSTCODE",Trim(vaPOSTCODE))>
	<cfset StructInsert(codtl,"COREGNO",Trim(vaCOREGNO))>
	<CFIF siFRANCHISE GT 0>
		<cfset StructInsert(codtl,"FRANCHISE",siFRANCHISE)>
	</CFIF>
	<cfset StructInsert(codtl,"CITYID",iCITYID)>
	<CFIF PASCCOID GT 0>
		<cfset StructInsert(codtl,"PASCCOID",PASCCOID)>
		<cfset StructInsert(codtl,"PASCCOTYPEID",PASCCOTYPEID)>
	</CFIF>
	<cfset StructInsert(codtl,"COTYPEID",siCOTYPEID)>
	<cfset StructInsert(codtl,"SUBSCRIBE",siSUBSCRIBE)>
	<cfset StructInsert(codtl,"COESOURCE",siESOURCE)>
	<cfset StructInsert(codtl,"ETENDER",siETENDER)>
	<cfset StructInsert(codtl,"TELNO",TELNO)>
	<cfset StructInsert(codtl,"TPCLAIMS",siTPCLAIMS)>
	<cfset StructInsert(codtl,"CLMFORM",siCLMFORM)>
	<cfset StructInsert(codtl,"CONAME",Trim(vaCONAME))>
	<cfset StructInsert(codtl,"CONAME_LANG",{ #iLOCID#={DESC=Trim(vaCONAME_TH)} })>
	<cfset StructInsert(codtl,"COBRNAME",Trim(vaCOBRNAME))>
	<cfset StructInsert(codtl,"BRANCHCODE",Trim(vaBRANCHCODE))>
	<cfset StructInsert(codtl,"ACCEPTCASE",siACCEPTCASE)>
	<cfset StructInsert(codtl,"PWORKSHOP",siPWORKSHOP)>
	<cfset StructInsert(codtl,"PADJUSTER",siPADJUSTER)>
	<cfset StructInsert(codtl,"SANCTIONFLAG",iSANCTIONFLAG)>
	<cfset StructInsert(codtl,"INTSYNCFLAG",iINTSYNCFLAG)>
	<cfset StructInsert(codtl,"SVCCARDFLAG",siSERVICECARDFLAG)>
	<cfset StructInsert(codtl,"ECATFLAG",siECATFLAG)>
	<cfset StructInsert(codtl,"FAXNO",FAXNO)>
	<CFSET StructInsert(codtl,"SUBCOTYPE",iSUBCOTYPEFLAG)>
	<CFSET StructInsert(codtl,"CURRENCYID",iCURRENCYID)>

	<cfif ((IGCOID IS iCOID) OR (iPROPCOID IS iCOID)) AND TBLSOURCE EQ 0>

		<cfset StructInsert(codtl,"LABELLIST",LABELLIST)>
		<cfset StructInsert(codtl,"COUNTRYID",iCOUNTRYID)>

		<CFIF iLOCID IS 4>
			<cfquery NAME=q_trx2 DATASOURCE=#CURDSN#>
			select a.siREGID,a.vaDESC from BIZ0040 a WITH (NOLOCK) where a.siSTATUS=0 AND a.iGCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iGCOID#">
			</CFQUERY>
			<CFIF q_trx2.recordcount GT 0>
				<CFSET GREGOFF=StructNew()>
				<CFLOOP query=q_trx2><cfset StructInsert(GREGOFF,siREGID,vaDESC)></CFLOOP>
				<cfset StructInsert(codtl,"GREGOFF",GREGOFF)>
			</CFIF>
		</CFIF>

		<cfset StructInsert(codtl,"GCFORM",GCFORM_HASVALUE)>
		<cfset StructInsert(codtl,"NOTICEFORM",NOTICEFORM_HASVALUE)>

		<cfif sicotypeid is 2>
			<cfset StructInsert(codtl,"ETHIDEDTL",0)>
		</cfif>

		<!--- Policy group management (insurers and adjuster only) --->
		<CFIF siCOTYPEID IS 2 OR siCOTYPEID IS 3>
			<cfset arrayAppend(pgmarr,iGCOID)>
		</CFIF>

		<CFIF (IPROPCOID IS iCOID) AND (iGCOID IS NOT iPROPCOID)>
			<cfset StructInsert(codtl,"GCOLIST",p_gcolist)>
			<cfset StructInsert(codtl,"GCONAME",p_gconame)>
			<cfset StructInsert(codtl,"GCLMCOLIST",p_gclmcolist)>
			<cfset StructInsert(codtl,"GCLMCONAME",p_gclmconame)>
			<cfset StructInsert(codtl,"GCLMCOACCEPTLIST",p_gclmcoacceptlist)>
			<cfset StructInsert(codtl,"GCLMCOACCEPTNAME",p_gclmcoacceptname)>
		<CFELSE>
			<cfset StructInsert(codtl,"GCOLIST",gcolist)>
			<cfset StructInsert(codtl,"GCONAME",gconame)>
			<cfset StructInsert(codtl,"GCLMCOLIST",gclmcolist)>
			<cfset StructInsert(codtl,"GCLMCONAME",gclmconame)>
			<cfset StructInsert(codtl,"GCLMCOACCEPTLIST",gclmcoacceptlist)>
			<cfset StructInsert(codtl,"GCLMCOACCEPTNAME",gclmcoacceptname)>
		</CFIF>

		<cfset arrayAppend(coidarr, iGCOID)>
	</cfif>

	<cfset StructInsert(codtl,"PCOLIST",pcolist)>
	<cfset StructInsert(codtl,"HIERARCHY",siHIERARCHY)>
	<cfset StructInsert(codtl,"CHCOLIST",branches)>
	<cfset StructInsert(codtl,"CHCOBRLIST",brnamelist)>

	<cfif NOT StructKeyExists(DS.CO,iCOID)>
		<cfset StructInsert(DS.CO,iCOID,Duplicate(codtl))>
	<cfelse>
		<cfset DS.CO[iCOID]=Duplicate(codtl)>
	</cfif>
</cfoutput>

<CFIF arrayLen(coidarr) gt 0>
	<!--- COADMIN Extended Attributes --->
	<!--- @CFLintIgnore CFQUERYPARAM_REQ --->
	<CFQUERY NAME="q_coexattr" DATASOURCE="#CURDSN#">
	select a.vafieldlogicname,b.vaattr,b.iOWNOBJID from fsys0012 a with (nolock)
		inner join fsys0013 b with (nolock) on (a.vaATTRTYPE=b.vaATTRTYPE and a.vaattrtype='COADMIN' and a.iATTRID=b.iATTRID and b.iowndomid=10)
		inner join (
			<cfloop from="1" to="#arrayLen(coidarr)#" index="itm">
			select icoid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#coidarr[itm]#"><cfif itm lt arrayLen(coidarr)> union</cfif>
			</cfloop>
		) c on c.icoid = b.iownobjid
	where b.iowndomid=10 and a.sistatus=0 and a.vaFieldLogicName in ('COATTR59', 'COATTR60', 'COATTR80', 'COATTR103','COATTR114','COATTR53')
	order by a.iATTRID, a.vafieldlogicname, b.iOWNOBJID
	</CFQUERY>
	<cfif q_coexattr.recordcount gt 0>
		<cfloop query=q_coexattr>
			<cfif vafieldlogicname eq "COATTR59"><cfset EXTKEYNAME = "ESTSALVAGE">
			<cfelseif vafieldlogicname eq "COATTR60"><cfset EXTKEYNAME = "CLMFORM_CLMTYPEMASK">
			<cfelseif vafieldlogicname eq "COATTR80"><cfset EXTKEYNAME = "ESTFLAG">
			<cfelseif vafieldlogicname eq "COATTR103"><cfset EXTKEYNAME = "COATTR_SVCPAY">
			<cfelseif vafieldlogicname eq "COATTR114"><cfset EXTKEYNAME = "ADJRPTFORCEMANDT_CLMTYPEMASK">
			<cfelseif vafieldlogicname eq "COATTR53"><cfset EXTKEYNAME = "ETHIDEDTL">
			</cfif>

			<cfif vafieldlogicname eq "COATTR103">
				<cfif vaattr is 1>
					<cfset StructInsert(DS.CO[iOWNOBJID],EXTKEYNAME,Val(vaattr))>
				</cfif>
			<cfelseif vafieldlogicname eq "COATTR53">
				<cfif vaattr IS NOT "" AND IsNumeric(vaattr) AND StructKeyExists(DS.CO, iOWNOBJID) AND DS.CO[iOWNOBJID].COTYPEID eq 2 and structKeyExists(DS.CO[iOWNOBJID],EXTKEYNAME)>
					<cfset DS.CO[iOWNOBJID][EXTKEYNAME] = vaattr>
				</cfif>
			<cfelse>
				<cfif vaattr IS NOT "" AND IsNumeric(vaattr)>
					<cfset StructInsert(DS.CO[iOWNOBJID],EXTKEYNAME,Val(vaattr))>
				</cfif>
			</cfif>
		</cfloop>
	</cfif>
	<!--- @CFLintIgnore CFQUERYPARAM_REQ --->
	<CFQUERY name=q_pcls datasource=#CURDSN#>
	SELECT a.iINSCLASSID,a.vaINSCLASSNAME,a.iCOID
	FROM BIZ2010 a WITH (NOLOCK)
		inner join (
			<cfloop from="1" to="#arrayLen(coidarr)#" index="itm">
			select icoid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#coidarr[itm]#"><cfif itm lt arrayLen(coidarr)> union</cfif>
			</cfloop>
		) c on c.icoid = a.iCOID
	WHERE a.siSTATUS=0
	ORDER BY a.iCOID,a.vaINSCLASSNAME
	</CFQUERY>
	<cfif q_pcls.recordcount GT 0>
		<cfoutput query=q_pcls group="icoid">
			<cfset DS.CO[iCOID].PCLS1 = structNew()>
			<cfoutput>
				<cfset StructInsert(DS.CO[iCOID].PCLS1,q_pcls.iINSCLASSID,structnew())>
				<cfset StructInsert(DS.CO[iCOID].PCLS1[q_pcls.iINSCLASSID],"name","#q_pcls.vaINSCLASSNAME#")>
				<cfset StructInsert(DS.CO[iCOID].PCLS1[q_pcls.iINSCLASSID],"parentid",0)>
			</cfoutput>
		</cfoutput>
	</cfif>
	<!--- @CFLintIgnore CFQUERYPARAM_REQ --->
	<CFQUERY name=q_pcls datasource=#CURDSN#>
	SELECT a.iPOLID,a.iINSCLASSID,a.vaPOLNAME,a.iCOID
	FROM BIZ2011 a WITH (NOLOCK)
		inner join (
			<cfloop from="1" to="#arrayLen(coidarr)#" index="itm">
			select icoid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#coidarr[itm]#"><cfif itm lt arrayLen(coidarr)> union</cfif>
			</cfloop>
		) c on c.icoid = a.iCOID
	WHERE a.siSTATUS=0
	ORDER BY a.iCOID,a.iINSCLASSID,a.vaPOLNAME
	</CFQUERY>
	<cfif q_pcls.recordcount GT 0>
		<cfoutput query=q_pcls group="icoid">
			<cfset DS.CO[iCOID].PCLS2 = structNew()>
			<cfoutput>
				<cfset StructInsert(DS.CO[iCOID].PCLS2,q_pcls.iPOLID,structnew())>
				<cfset StructInsert(DS.CO[iCOID].PCLS2[q_pcls.iPOLID],"name","#q_pcls.vaPOLNAME#")>
				<cfset StructInsert(DS.CO[iCOID].PCLS2[q_pcls.iPOLID],"parentid",q_pcls.iINSCLASSID)>
			</cfoutput>
		</cfoutput>
	</cfif>
	<!--- @CFLintIgnore CFQUERYPARAM_REQ --->
	<CFQUERY name=q_pcls datasource=#CURDSN#>
	SELECT a.iBUSID,a.iPOLID,a.vaBUSNAME,a.iCOID
	FROM BIZ2012 a WITH (NOLOCK)
		inner join (
			<cfloop from="1" to="#arrayLen(coidarr)#" index="itm">
			select icoid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#coidarr[itm]#"><cfif itm lt arrayLen(coidarr)> union</cfif>
			</cfloop>
		) c on c.icoid = a.iCOID
	WHERE a.siSTATUS=0
	ORDER BY a.icoid,a.iPOLID,a.vaBUSNAME
	</CFQUERY>
	<cfif q_pcls.recordcount GT 0>
		<cfoutput query=q_pcls group="icoid">
			<cfset DS.CO[iCOID].PCLS3 = structNew()>
			<cfoutput>
				<cfset StructInsert(DS.CO[iCOID].PCLS3,q_pcls.iBUSID,structnew())>
				<cfset StructInsert(DS.CO[iCOID].PCLS3[q_pcls.iBUSID],"name","#q_pcls.vaBUSNAME#")>
				<cfset StructInsert(DS.CO[iCOID].PCLS3[q_pcls.iBUSID],"parentid",q_pcls.iPOLID)>
			</cfoutput>
		</cfoutput>
	</cfif>

	<cfif ArrayLen(pgmarr) gt 0>
		<cfquery NAME=q_polgrp DATASOURCE=#CURDSN#>
		SELECT a.igcoid,POLGRPID=a.iPOLGRPID,POLGRPNAME=a.vaDESC, POLGRPREMARKS=a.txremarks
		,b.iPOLGRPDTLID,iPOLCLSLEVEL=IsNull(b.iPOLCLSLEVEL,-1),iINSCLASSID=IsNull(b.iINSCLASSID,0),iPOLID=IsNull(b.iPOLID,0),iBUSID=IsNull(b.iBUSID,0),iCLMTYPEMASK=IsNull(b.iCLMTYPEMASK,0),siTL=ISNULL(b.siTL,-1)
		FROM BIZ2018 a WITH (NOLOCK) LEFT JOIN BIZ2019 b with (nolock) on b.iPOLGRPID = a.iPOLGRPID
		WHERE b.siSTATUS=0 and a.siSTATUS=0
		ORDER BY a.igcoid, ISNULL(a.iPRIORITY,-1), POLGRPID, IsNull(b.iPOLCLSLEVEL,-1)
		</CFQUERY>
		<cfoutput query="q_polgrp" group="igcoid">
			<cfset DS.CO[igcoid].POLGRP = structNew()>
			<cfset DS.CO[igcoid].POLGRPSEQ = "">
			<cfoutput group="POLGRPID">
				<cfset q_polgrpcount = 0>
				<CFSET RULES=ArrayNew(1)>
				<cfoutput>
					<cfset q_polgrpcount += 1>
					<CFSET RULES[q_polgrpcount]={ID=iPOLGRPDTLID,PRIORITY=iPOLCLSLEVEL,INSCLASSID=iINSCLASSID,POLID=iPOLID,BUSID=iBUSID,CLMTYPEMASK=iCLMTYPEMASK,TOTALLOSS=siTL}>
				</cfoutput>
				<cfset DS.CO[igcoid].POLGRP[POLGRPID] = {NAME=POLGRPNAME, REMARKS=POLGRPREMARKS, RULES=RULES}>
				<cfset DS.CO[igcoid].POLGRPSEQ = listAppend(DS.CO[igcoid].POLGRPSEQ,POLGRPID)>
			</cfoutput>
		</cfoutput>
	</cfif>

	<!--- List of Mandatory Branch For A Particular State --->
	<!--- @CFLintIgnore CFQUERYPARAM_REQ --->
	<cfquery NAME=q_br DATASOURCE=#CURDSN#>
		select distinct z.iSTATEID, z.iMAINCOID, brlist = STUFF(( select ',' + cast(a.iBRCOID as varchar) FROM SYS0017 a WITH (NOLOCK) inner join SEC0005 b WITH (NOLOCK) on a.iBRCOID=b.icoid WHERE a.istateid=z.istateid and a.iMAINCOID=z.iMAINCOID  ORDER BY b.igcoid,a.iSTATEID,b.siHIERARCHY,b.vaCOBRNAME for xml path(''), ELEMENTS), 1, 1, '')
		FROM SYS0017 z inner join SEC0005 y WITH (NOLOCK) on z.iBRCOID=y.icoid
		inner join (
			<cfloop from="1" to="#arrayLen(coidarr)#" index="itm">
			select icoid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#coidarr[itm]#"><cfif itm lt arrayLen(coidarr)> union</cfif>
			</cfloop>
		) c on c.icoid = z.iMAINCOID
		order by imaincoid, iSTATEID
	</cfquery>
	<cfoutput QUERY=q_br>
		<cfset DS.CO[iMAINCOID]["INSSTATE#iSTATEID#"] = brlist>
	</cfoutput>

</CFIF>

<CFRETURN>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRcovar_DSUpdate_Faster=MTRcovar_DSUpdate_Faster>


<!---
Function Note:
1. Used to point TRX0046.sientityname
2. Used for only TH, AIG for now on special request
3. put in the maincase ONLY, else will not retrieve correctly
--->
<cffunction access="public" name="MTREntityName" output=false>
    <cfargument name="mcaseid" required="true">
    <cfset entityname = "">
    <cfquery name="qry_entity" datasource="#request.mtrdsn#">
        select
            sientityname, igcoid
        from trx0008 ins
        inner join sec0005 insco on insco.icoid = ins.icoid
        inner join trx0046 ins2 on ins2.iinscaseid = ins.iinscaseid
        where ins.icaseid =
            <cfqueryparam value=#arguments.mcaseid# CFSQLType = "cf_sql_integer" null="no">
    </cfquery>
    <cfif qry_entity.igcoid eq 1100002>
        <cfif qry_entity.sientityname eq 1 OR qry_entity.sientityname eq 2>
            <cfset entityname = request.ds.AIGentity[qry_entity.sientityname]>
        </cfif>
    </cfif>
    <cfreturn entityname>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTREntityName=MTREntityName>

<cffunction access="public" name="MTRcheckCalcModel" output=false>
    <cfargument name="caseid" required="true">
    <cfargument name="cotype" required="false" default="I"> <!--- default to estimate: insurer offer --->
    <cfquery name="qry_checker" datasource="#request.mtrdsn#">
        select
            claimtype = rep.aclaimtype
            ,insgcoid = insco.igcoid
            ,est.sicalcmodel
        from TRX0001 rep WITH (NOLOCK)
        inner join SEC0005 insco WITH (NOLOCK) on insco.icoid = rep.iinscoid
        left join TRX0035 est WITH (NOLOCK)
            on est.ilcaseid = rep.icaseid
            and est.acotype = <cfqueryparam value="#arguments.cotype#" CFSQLType = "cf_sql_char" null="no" maxlength="4">
        where rep.icaseid = <cfqueryparam value="#arguments.caseid#" CFSQLType = "cf_sql_integer" null="no">
    </cfquery>
    <cfset var _insgcoid = qry_checker.insgcoid>
    <cfset var _calcmodel = qry_checker.sicalcmodel>
    <cfset var _claimtype = trim(qry_checker.claimtype)>

    <cfset var calcmodel = "undefined">

    <!--- ensure company salvage aft GST mode is on and est is already based on it --->
    <cfif bitand(val(Request.DS.FN.SVCgetExtAttrLogic("COADMIN", 0, "COATTR401", 10, _INSGCOID)),1) eq 1
        and (_claimtype eq 'OD'
        OR _claimtype eq 'OD GRG'
        OR _claimtype eq 'OD KFK'
        OR _claimtype eq 'OD TAC'
        OR _claimtype eq 'OD TFR'
        OR _claimtype eq 'OD WS'
        OR _claimtype eq 'WS')>
        <cfif _calcmodel eq 4>
            <cfset calcmodel = 'salvageafterGSTMY'>
        <cfelse>
            <cfset calcmodel = 'salvageafterGSTMYtransition'>
        </cfif>
    </cfif>
    <cfreturn calcmodel>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRcheckCalcModel=MTRcheckCalcModel>

<cffunction access="public" name="UsingAugmentedCo" output=true>
    <cfargument name="discriminator" type="struct" required="true">

    <!--- exit prematurely to prevent error reading struct --->
    <cfset result = false>
    <cfif NOT StructKeyExists(discriminator,"gcoid")
        OR NOT StructKeyExists(discriminator,"KFKStatus")>
        <cfreturn result>
    </cfif>

	<!--- only AXA SG and NON-centralised BOLA cases use this option --->
	<!--- #34504 : open this option for Sg MSI --->
    <cfset result = (discriminator.gcoid eq 200029 or discriminator.gcoid eq 200036)
        and (
            discriminator.KFKStatus eq 0
            OR bitAnd(discriminator.KFKStatus,4096) gt 0
        )>
    <cfreturn result>
</cffunction>

<CFSET Attributes.DS.MTRFN.UsingAugmentedCo=UsingAugmentedCo>

<!--- get original/ complementary set of companies --->
<cffunction access="public" name="GetAugCo" output=false>
    <cfargument name="gcoidTarget" required="true"> <!--- insco-toRetrieve --->
    <cfargument name="gcoid" required="true">       <!--- insco-self --->
    <cfargument name="KFKStatus" required="false" default=-1>

    <cfset co = {}>
    <cfif request.ds.mtrfn.UsingAugmentedCo(arguments) and StructKeyExists(request.ds.augco,arguments.gcoidTarget)>
        <cfset co  = request.ds.augco[arguments.gcoidTarget]>
    <cfelseif StructKeyExists(request.ds.co,arguments.gcoidTarget)>
        <cfset co  = request.ds.co[arguments.gcoidTarget]>
    </cfif>

    <cfif StructIsEmpty(co)>
        <cfthrow type="EX_DBERROR" errorCode="Company NOT exists">
    </cfif>
    <cfreturn co>
</cffunction>

<CFSET Attributes.DS.MTRFN.GetAugCo=GetAugCo>

<cffunction name="MTRGetStructTrans" output="false" hint="Get translation based on Request.DS struct name and the string">
	<cfargument name="structnm">
	<cfargument name="valuematch">
	<cfset var lid = 0>
	<cfset var x = "">

	<cfif structKeyExists(request.ds, structnm)>

		<cfset x = StructFindValue( request.ds[structnm], valuematch )>

		<cfif arraylen(x) gte 1 and structKeyExists(x[1],"owner") and structKeyExists(x[1],"key") and structKeyExists(x[1].owner, "LID_" & x[1].key)><!--- ie paint type (patype) that stores LID_#id# --->
			<cfset lid = x[1].owner["LID_#x[1].key#"]>
		<cfelseif arraylen(x) gte 1 and structKeyExists(x[1],"owner") and structKeyExists(x[1].owner, "ilid")><!--- ie:cotypename that stores iLID as a nested struct {DESC="#Trim(q_trx.vadesc)#",ILID="#Trim(q_trx.iLID)#"} --->
			<cfset lid = x[1].owner.ilid>
		<cfelse>
			<cfset lid = 0>
		</cfif>
	</cfif>

	<cfreturn Server.svclang(valuematch, lid)>

</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGetStructTrans=MTRGetStructTrans>

<cffunction access="public" name="MTRCoPropName" output=false>
    <cfargument name="coid" type="numeric" required="true">
    <cfset coname = "">
    <cfif arguments.coid gt 0>
        <cfquery name="qry_propName" datasource="#request.mtrdsn#">
            select
                coprop.vaconame
            from sec0005 co WITH (NOLOCK)
            inner join sec0005 coprop WITH (NOLOCK) on coprop.icoid = co.iPROPCOID
            where
            co.icoid = <cfqueryparam value="#arguments.coid#" CFSQLType = "cf_sql_integer" null="no">
        </cfquery>
        <cfset coname = qry_propName.vaconame>
    </cfif>
    <cfreturn coname>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRCoPropName=MTRCoPropName>

<cffunction access="public" name="volkswagon18370" output=false>
    <cfargument name="claimtype" required="true">
    <cfargument name="stage" required="true"> <!--- creation,aftercreation ,internalapprv ,estsubmission --->
    <cfargument name="accdate" required="true">

    <cfargument name="invoicedate" required="false">
    <cfargument name="internalApprvdate" required="false"> <!--- compulsory for 2nd internal apprv onwards --->
    <cfargument name="isResubmit" required="false"> <!--- apprv: resubmission ,est: resubmission --->

    <cfargument name="cutoffdate" required="false" default="2016-08-01">
    <cfargument name="ROdate" required="false">

    <cfif arguments.stage eq "aftercreation">
        <cfreturn (session.vars.gcoid eq 30735
        and (arguments.claimtype eq 'OD EXW' OR arguments.claimtype eq 'EXW')
        and datediff('d',arguments.cutoffdate,arguments.accdate) gte 0
        and datediff('d',arguments.cutoffdate,now()) gte 0)>
    </cfif>

    <cfif arguments.stage eq "internalapprv"
        OR arguments.stage eq "estsubmission">

        <cfif arguments.rodate eq ''> <cfset rodate = '2016-07-01'> </cfif>

        <cfif (session.vars.gcoid eq 30735
            and (arguments.claimtype eq 'OD EXW' OR arguments.claimtype eq 'EXW')
            and NOT (
                (datediff('d',arguments.cutoffdate,arguments.accdate) gte 0
                OR datediff('d',arguments.cutoffdate,arguments.ROdate) gte 0)
                and datediff('d',arguments.cutoffdate,now()) gte 0)
            )>
            <cfreturn true>
        </cfif>
    </cfif>

    <cfset var passed = true>
    <cfif session.vars.gcoid eq 30735
        and (arguments.claimtype eq 'OD EXW' OR arguments.claimtype eq 'EXW')
        and (ListFind("UAT,DEV",Application.DB_MODE)?  true: datediff('d',arguments.cutoffdate,now()) gte 0 )>

        <cfif arguments.stage eq "internalApprv" and arguments.isResubmit>
            <cfset var date1 = arguments.internalApprvdate>
        <cfelse>
            <cfset var date1 = arguments.invoicedate>
        </cfif>

        <!--- premature exit due to old case --->
        <cfif date1 eq ''> <cfreturn passed> </cfif>

        <!--- get the difference --->
        <cfset qry_checkdays = {}>
        <cfset qry_checkdays.diff = datediff('d',date1,now())>

        <!--- estimate submission --->
        <cfif arguments.stage eq "estsubmission">
            <cfif arguments.isResubmit>
                <cfset passed = true>
            <cfelse>
                <cfset passed = NOT(qry_checkdays.diff gt 45)>
            </cfif>

        <!--- internal approval --->
        <cfelseif arguments.stage eq "internalApprv">
            <cfif arguments.isResubmit>
                <cfset passed = NOT(qry_checkdays.diff gt 8)>
            <cfelse>
                <cfset passed = NOT(qry_checkdays.diff gt 15)>
            </cfif>

        <!--- creation --->
        <cfelse>
            <cfset passed = NOT(qry_checkdays.diff gt 15) OR datediff('d',arguments.accdate,arguments.cutoffdate) gte 0>
        </cfif>
    </cfif>

    <cfreturn passed>
</cffunction>
<CFSET Attributes.DS.MTRFN.volkswagon18370=volkswagon18370>

<cffunction access="public" name="MTRGetAMGEntity" output=false>
    <cfargument name="coid" type="numeric" required="true">
    <cfset coname = "">
    <cfif arguments.coid gt 0 AND coid NEQ 7651>
        <cfquery name="qry_propName" datasource="#request.mtrdsn#">
            SELECT TOP 1 iCHCOID FROM SEC0015 WHERE iCOID = <cfqueryparam value="#arguments.coid#" CFSQLType = "cf_sql_integer" null="no"> AND iCHCOID <> 7651 AND siHIERARCHY <= 0 ORDER BY siHIERARCHY
        </cfquery>
        <cfset coname = qry_propName.iCHCOID>
	<CFELSEIF coid EQ 7651>
		<CFSET coname = 7651>
    </cfif>
    <cfreturn coname>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGetAMGEntity=MTRGetAMGEntity>

<cffunction access="public" name="MtrReplaceImgPath" output=false>
    <cfargument name="content" type="string" required="true">
	<cfset var path = "">
	<!--- #20482.1 --->
	<cfset arguments.content=REReplaceNoCase(arguments.content,"((src)\=[""']*)[^""'\s/\\]*[/\\]*(#request.approot#claims/index\.cfm\?fusebox=SVCdoc&fuseaction=dsp_docdump&tmpfile=)([^&]*)[^""']*","\1file:///"&Replace(Application.TMPDIR,"\","/","ALL")&"\4"" TODEL=""#Replace(Application.TMPDIR,"\","/","ALL")#\4","ALL")>
	<!--- end of #20482.1 --->
	<cfset arguments.content=REReplaceNoCase(arguments.content,"((src|link)\=[""']*)[^""'\s/\\]*[/\\]*#request.approot#claims(?!/index.cfm)","\1file:///"&Replace(ExpandPath(request.apppath&"claims"),"\","/","ALL"),"ALL")>
	<cfset arguments.content=REReplaceNoCase(arguments.content,"((src|link)\=[""']*)[^""'\s/\\]*[/\\]*#request.approot#services","\1file:///"&Replace(ExpandPath(request.apppath&"services"),"\","/","ALL"),"ALL")>
	<cfset arguments.content=REReplaceNoCase(arguments.content,"((background: url)\([""']*)[^""'\s/\\]*[/\\]*#request.approot#claims(?!/index.cfm)","\1file:///"&Replace(ExpandPath(request.apppath&"claims"),"\","/","ALL"),"ALL")>
	<cfset arguments.content=REReplaceNoCase(arguments.content,"((url)\([""']*)(#request.approot#claims(?!/index.cfm))","\1file:///"&Replace(ExpandPath(request.apppath&"claims"),"\","/","ALL"),"ALL")>
	<CFIF application.db_mode eq "UAT"><cfset path = request.apppath><cfelse><cfset path = request.approot></CFIF>
	<cfset arguments.content=REReplaceNoCase(arguments.content,"((url)\([""']*)(#path#services)","\1file:///"&Replace(ExpandPath(request.apppath&"services"),"\","/","ALL"),"ALL")>
	<cfset arguments.content=REReplaceNoCase(arguments.content,"((src|link)\=[""']*)[^""'\s/\\]*[/\\]*#request.logpath#(?!/index.cfm)","\1file:///"&Replace(ExpandPath(request.apppath&"claims/"),"\","/","ALL"),"ALL")><!--- fail safe --->
	<cfreturn arguments.content>
</cffunction>
<CFSET Attributes.DS.MTRFN.MtrReplaceImgPath=MtrReplaceImgPath>

<cffunction name="MTRGenOptAiType" description="Show A/I Type" access="public" returntype="any" output="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="value" type="string" default="">
	<cfargument name="claimtypemask" type="string" required="true">
	<cfargument name="display" type="numeric" default=0>
	<cfset var q_biz={}>
	<cfquery NAME=q_biz DATASOURCE=#Request.MTRDSN#>
		SELECT vaCFCODE,vaCFDESC,iCLMTYPEMASK,iLID=isnull(iLID,0) FROM BIZ0025 WITH (NOLOCK)
		WHERE iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#claimtypemask#"><>0 AND iCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#INSGCOID#"> AND aCFTYPE='A/I_TYPE'
		AND siSTATUS=0
		ORDER BY vaCFDESC
	</cfquery>
	<CFIF display is 1>
		<CFIF ArrayFind(q_biz["vaCFCODE"], value) GT 0>
			#q_biz["vaCFDESC"][ArrayFind(q_biz["vaCFCODE"], value)]#
		</CFIF>
	<CFELSE>
		<OPTION value=""></OPTION>
		<script>document.write(JSVCgenOptions("<CFLOOP query=q_biz><cfif BITAND(iCLMTYPEMASK,claimtypemask) GT 0>#vaCFCODE#|#Server.SVClang(vaCFDESC,iLID)#|</cfif></CFLOOP>","|","#value#"));</script>
	</CFIF>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGenOptAiType=MTRGenOptAiType>

<cffunction name="MTRGenOptClmConlu" description="Show Claim Conclusion (Party at fault)" access="public" returntype="any" output="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="value" type="string" default="">
	<cfargument name="claimtypemask" type="string" required="true">
	<cfargument name="display" type="numeric" default=0>
	<cfset var q_biz={}>
	<cfquery NAME=q_biz DATASOURCE=#Request.MTRDSN#>
		SELECT vaCFCODE,vaCFDESC,vaCFMAPCODE,iCLMTYPEMASK,iLID=isnull(iLID,0) FROM BIZ0025 WITH (NOLOCK)
		WHERE iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#claimtypemask#"><>0 AND iCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#INSGCOID#"> AND aCFTYPE='CLAIM_CONCLU'
		AND siSTATUS=0
		ORDER BY vaCFDESC
	</cfquery>
	<cfif display IS 1>
		<CFIF ArrayFind(q_biz["vaCFCODE"], value) GT 0>
			#q_biz["vaCFDESC"][ArrayFind(q_biz["vaCFCODE"], value)]#
		</CFIF>
	<cfelse>
		<OPTION value=""></OPTION>
		<CFLOOP query=q_biz>
			<option value=#q_biz.vacfcode# code=#q_biz.vacfmapcode# <cfif value is #q_biz.vacfcode#>selected</cfif>>#q_biz.vacfdesc#</option>
		</CFLOOP>
	</cfif>
	<!---script>document.write(JSVCgenOptions("<CFLOOP query=q_biz><cfif BITAND(iCLMTYPEMASK,claimtypemask) GT 0>#vaCFCODE#|#Server.SVClang(vaCFDESC,iLID)#|</cfif></CFLOOP>","|","#value#"));</script--->
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGenOptClmConlu=MTRGenOptClmConlu>

<cffunction name="MTRGenOptClmLossType" description="Show Loss Type (Cause of loss)" access="public" returntype="any" output="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="value" type="string" default="">
	<cfargument name="claimtypemask" type="string" required="true">
	<cfargument name="display" type="numeric" default=0>
	<cfargument name="logicname" type="string" default="">
	<cfset var q_biz={}>
	<cfquery NAME=q_biz DATASOURCE=#Request.MTRDSN#>
		SELECT vaCFCODE,vaCFDESC,vaCFMAPCODE,iCLMTYPEMASK,iLID=isnull(iLID,0) FROM BIZ0025 WITH (NOLOCK)
		WHERE iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#claimtypemask#"><>0 AND iCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#INSGCOID#"> AND aCFTYPE='TI_LOSS_CODE'
		AND siSTATUS=0
		<CFIF logicname NEQ "">
			<CFIF logicname EQ "VVC">
				AND vaCFMAPCODE LIKE 'C%'
			<CFELSE>
				AND (vaCFMAPCODE LIKE 'V%' OR vaCFMAPCODE LIKE 'A%' OR vaCFMAPCODE LIKE 'F%' OR vaCFMAPCODE LIKE 'TH%')
			</CFIF>
		</CFIF>
		ORDER BY vaCFDESC
	</cfquery>

	<cfif display IS 1>
		<CFIF ArrayFind(q_biz["vaCFCODE"], value) GT 0>
			#q_biz["vaCFDESC"][ArrayFind(q_biz["vaCFCODE"], value)]#
		</CFIF>
	<cfelse>
		<OPTION value=""></OPTION>
		<CFLOOP query=q_biz>
			<option value=#q_biz.vacfcode# code=#q_biz.vacfmapcode# <cfif value is #q_biz.vacfcode#>selected</cfif>>#q_biz.vacfdesc#</option>
		</CFLOOP>
	</cfif>

	<!---script>document.write(JSVCgenOptions("<CFLOOP query=q_biz><cfif BITAND(iCLMTYPEMASK,claimtypemask) GT 0>#vaCFCODE#|#Server.SVClang(vaCFDESC,iLID)#|</cfif></CFLOOP>","|","#value#"));</script--->
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGenOptClmLossType=MTRGenOptClmLossType>

<cffunction name="MTRGenOptClmMajorEvent" description="Show Major Event" access="public" returntype="any" output="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="value" type="string" default="">
	<cfargument name="claimtypemask" type="string" required="true">
	<cfargument name="display" type="numeric" default=0>
	<cfset var q_biz={}>
	<cfquery NAME=q_biz DATASOURCE=#Request.MTRDSN#>
		SELECT vaCFCODE,vaCFDESC,iCLMTYPEMASK,iLID=isnull(iLID,0) FROM BIZ0025 WITH (NOLOCK)
		WHERE iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#claimtypemask#"><>0 AND iCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#INSGCOID#"> AND aCFTYPE='MAJOR_EVENT'
		AND siSTATUS=0
		ORDER BY vaCFDESC
	</cfquery>
	<cfif display IS 1>
		<CFIF ArrayFind(q_biz["vaCFCODE"], value) GT 0>
			#q_biz["vaCFDESC"][ArrayFind(q_biz["vaCFCODE"], value)]#
		</CFIF>
	<cfelse>
		<OPTION value=""></OPTION>
		<script>document.write(JSVCgenOptions("<CFLOOP query=q_biz><cfif BITAND(iCLMTYPEMASK,claimtypemask) GT 0>#vaCFCODE#|#Server.SVClang(vaCFDESC,iLID)#|</cfif></CFLOOP>","|","#value#"));</script>
		</cfif>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGenOptClmMajorEvent=MTRGenOptClmMajorEvent>

<cffunction name="MTRGenOptClmSeverity" description="Show Severity" access="public" returntype="any" output="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="value" type="string" default="">
	<cfargument name="claimtypemask" type="string" required="true">
	<cfargument name="display" type="numeric" default=0>
	<cfset var q_biz={}>
	<cfquery NAME=q_biz DATASOURCE=#Request.MTRDSN#>
		SELECT vaCFCODE,vaCFDESC,iCLMTYPEMASK,iLID=isnull(iLID,0) FROM BIZ0025 WITH (NOLOCK)
		WHERE iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#claimtypemask#"><>0 AND iCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#INSGCOID#"> AND aCFTYPE='SEVERITY_CODE'
		AND siSTATUS=0
		ORDER BY vaCFDESC
	</cfquery>
	<cfif display IS 1>
		<CFIF ArrayFind(q_biz["vaCFCODE"], value) GT 0>
			#q_biz["vaCFDESC"][ArrayFind(q_biz["vaCFCODE"], value)]#
		</CFIF>
	<cfelse>
			<OPTION value=""></OPTION>
	<script>document.write(JSVCgenOptions("<CFLOOP query=q_biz><cfif BITAND(iCLMTYPEMASK,claimtypemask) GT 0>#vaCFCODE#|#Server.SVClang(vaCFDESC,iLID)#|</cfif></CFLOOP>","|","#value#"));</script>
	</cfif>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGenOptClmSeverity=MTRGenOptClmSeverity>

<cffunction name="MTRGenOpt_THTMI_ServiceLoc" description="Service By Location drop down list" access="public" returntype="any" output="true">
	<cfargument name="caseid" type="numeric" required="true">
	<cfargument name="type" type="numeric" required="true" hint="1:Repairer, 2:Surveyor">
	<cfargument name="display" type="numeric" default=0>
	<cfset var q_biz={}>
	<cfset var q_trx={}>
	<cfset var value="">
	<cfset var desc="">
	<cfquery NAME=q_biz DATASOURCE=#Request.MTRDSN#>
	SELECT ID=a.vaCFCODE,DSC=b.vaCOBRNAME
	FROM BIZ0025 a WITH (NOLOCK)
		INNER JOIN SEC0005 b WITH (NOLOCK) ON b.iGCOID=1101177 AND b.siSTATUS=0
	WHERE a.iCOID=1101177 AND a.aCFTYPE='SERVICE_LOC' AND a.siSTATUS=0 AND b.vaBRANCHCODE=a.vaCFMAPCODE
	ORDER BY 2
	</cfquery>
	<cfif type IS 1>
		<cfquery NAME="q_trx" DATASOURCE=#Request.MTRDSN#>
			SELECT comp.icityid
			FROM TRX0001 rep with (nolock)
				INNER join sec0005 comp with (nolock) on rep.icoid = comp.icoid
			where rep.icaseid = <cfqueryparam value="#caseid#" cfsqltype="CF_SQL_INTEGER">
				AND rep.iCOID<>1137
		</cfquery>
		<cfset value=q_trx.icityid>
		<cfif display IS 1>
			<CFIF ArrayFind(q_biz["ID"], value) GT 0>
				#q_biz["DSC"][ArrayFind(q_biz["ID"], value)]#
			</CFIF>
		<cfelse>
			<select disabled onchange=DoReq(this)>
			<OPTION value=""></OPTION>
			<script>document.write(JSVCgenOptions("<CFLOOP query=q_biz>#ID#|#JSStringFormat(DSC)#|</CFLOOP>","|","#value#"));</script>
			</select>
		</cfif>
	<cfelseif type IS 2>
		<cfquery NAME="q_trx" DATASOURCE=#Request.MTRDSN#>
			SELECT TOP 1 comp.icityid,vaDESC=COALESCE(city.vaDESCLOCAL,city.vaDESC,''),comp.vaBRANCHCODE,adj.dtINSSBMT
			FROM trx0002 adj with (nolock)
				INNER join sec0005 comp with (nolock) on adj.icoid = comp.icoid
				INNER JOIN SYS0003 city WITH (NOLOCK) ON city.iCITYID=comp.iCITYID
			where adj.icaseid = <cfqueryparam value="#caseid#" cfsqltype="CF_SQL_INTEGER">
			order by adj.iADJCASEID
		</cfquery>
		<cfset value=q_trx.icityid>
		<cfset desc=q_trx.vaDESC>
		<cfif q_trx.dtINSSBMT IS NOT "">
			<!--- SIT request #13: Only show "Service by Sur Location" when first report is submitted --->
			<cfif display IS 1>
				<CFIF ArrayFind(q_biz["ID"], value) GT 0>
					#q_biz["DSC"][ArrayFind(q_biz["ID"], value)]#
					(#Server.SVClang("Branch Code",6966)#: #HTMLEditFormat(q_trx.vaBRANCHCODE)#)
					<cfif desc IS NOT "">
						(#Server.SVClang("City",1185)#: #HTMLEditFormat(desc)#)
					</cfif>
				</CFIF>
			<cfelse>
				<select disabled onchange=DoReq(this)>
				<OPTION value=""></OPTION>
				<script>document.write(JSVCgenOptions("<CFLOOP query=q_biz>#ID#|#JSStringFormat(DSC)#|</CFLOOP>","|","#value#"));</script>
				</select>
				(#Server.SVClang("Branch Code",6966)#: #HTMLEditFormat(q_trx.vaBRANCHCODE)#)
				<cfif desc IS NOT "">
					(#Server.SVClang("City",1185)#: #HTMLEditFormat(desc)#)
				</cfif>
			</cfif>
		</cfif>
	</cfif>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGenOpt_THTMI_ServiceLoc=MTRGenOpt_THTMI_ServiceLoc>

<cffunction name="MTRGenOpt_ServiceLoss" description="Service Loss Location" access="public" returntype="any" output="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="value" type="string" default="">
	<cfargument name="display" type="numeric" default=0>
	<cfset var q_biz={}>
	<cfset var q_trx={}>
	<cfquery NAME=q_biz DATASOURCE=#Request.MTRDSN#>
	SELECT ID=vaCFMAPCODE,DSC=vaCFDESC, CITYID=vaCFCODE
	FROM BIZ0025 WITH (NOLOCK)
	WHERE iCOID=<cfqueryparam value="#insgcoid#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='SERVICE_LOC' AND siSTATUS=0
	</cfquery>
	<cfif display IS 1>
		<CFIF ArrayFind(q_biz["ID"], value) GT 0>
			<!---#q_biz["CITYID"][ArrayFind(q_biz["ID"], value)]#--->
			<script>onChangeServiceByLoss("#q_biz["CITYID"][ArrayFind(q_biz["ID"], value)]#");</script>
		</CFIF>
	<cfelse>
		<OPTION value=""></OPTION>
		<script>document.write(JSVCgenOptions("<CFLOOP query=q_biz>#ID#|#JSStringFormat(DSC)#|</CFLOOP>","|","#value#"));</script>
	</cfif>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGenOpt_ServiceLoss=MTRGenOpt_ServiceLoss>

<cffunction name="MTRGenOptBenefits" description="Show Benefits" access="public" returntype="any" output="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="value" type="string" default="">
	<cfset var q_biz={}>
	<OPTION value=""></OPTION>
	<cfquery NAME=q_biz DATASOURCE=#Request.MTRDSN#>
		SELECT a.vaBENNAME,d.vaBENCODE
		FROM BIZ_BENPKG p
		INNER JOIN BIZ_BENCVG a WITH (NOLOCK) ON p.iPKGID=a.iPKGID
		INNER JOIN BIZ_BENDEF d WITH (NOLOCK) ON d.iBENDEFID=a.iBENDEFID
		WHERE iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<script>document.write(JSVCgenOptions("<CFLOOP query=q_biz>#vaBENCODE#|#Server.SVClang(vaBENNAME,0)#|</CFLOOP>","|","#value#"));</script>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGenOptBenefits=MTRGenOptBenefits>

<cffunction name="MTRGenOptRepudiateReason" description="Show Repudiate Reason" access="public" returntype="any" output="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<!--- #37741: [MY] All Insurer NM  - Amend Repudiate Reason --->
	<cfargument name="iclaimtype" type="numeric" default="-1">
	<cfset var q_biz={}>
	<OPTION value=""></OPTION>
	<cfquery NAME=q_biz DATASOURCE=#Request.MTRDSN#>
		SELECT iRPDCODE,vaRPDCODE,vaRPDDESC,iCLMTYPEMASK,iLID=isnull(iLANGID,0) FROM REPUDIATE_REASON WITH (NOLOCK)
		WHERE iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER">
		AND iCLMTYPEMASK&<cfqueryparam value="#iclaimtype#" cfsqltype="CF_SQL_INTEGER">>0
		AND siSTATUS=0
		ORDER BY CASE WHEN vaRPDCODE='Others' THEN 1 ELSE 0 END ASC, vaRPDCODE
	</cfquery>
	<script>document.write(JSVCgenOptions("<CFLOOP query=q_biz>#iRPDCODE#|#Server.SVClang(vaRPDDESC,iLID)#|</CFLOOP>","|"));</script>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGenOptRepudiateReason=MTRGenOptRepudiateReason>

<cffunction name="MTRGenOptTMICancelReason" description="Show TMI Cancel Reason" access="public" returntype="any" output="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfset var q_biz={}>
	<OPTION value=""></OPTION>
	<cfquery NAME=q_biz DATASOURCE=#Request.MTRDSN#>
		SELECT vaCFCODE,vaCFDESC,iCLMTYPEMASK,iLID=isnull(iLID,0) FROM BIZ0025 WITH (NOLOCK)
		WHERE iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='CANCEL_REASON'
		AND siSTATUS=0
		ORDER BY vaCFDESC
	</cfquery>
	<script>document.write(JSVCgenOptions("<CFLOOP query=q_biz>#vaCFCODE#|#Server.SVClang(vaCFDESC,iLID)#|</CFLOOP>","|"));</script>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGenOptTMICancelReason=MTRGenOptTMICancelReason>

<cffunction name="MTRGenOptTMIReopenReason" description="Show Reopen Reason" access="public" returntype="any" output="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfset var q_biz={}>
	<OPTION value=""></OPTION>
	<cfquery NAME=q_biz DATASOURCE=#Request.MTRDSN#>
		SELECT vaCFCODE,vaCFDESC,iCLMTYPEMASK,iLID=isnull(iLID,0) FROM BIZ0025 WITH (NOLOCK)
		WHERE iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='REOPEN_REASON'
		AND siSTATUS=0
		ORDER BY vaCFDESC
	</cfquery>
	<script>document.write(JSVCgenOptions("<CFLOOP query=q_biz>#vaCFDESC#|#Server.SVClang(vaCFDESC,iLID)#|</CFLOOP>","|",""));</script>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGenOptTMIReopenReason=MTRGenOptTMIReopenReason>

<cffunction name="MTRGenOptReopenReason" description="Show Reopen Reason" access="public" returntype="any" output="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="value" type="string" default="">
	<cfset var q_biz={}>
	<OPTION value=""></OPTION>
	<cfquery NAME=q_biz DATASOURCE=#Request.MTRDSN#>
		SELECT vaCFCODE,vaCFDESC,iCLMTYPEMASK,iLID=isnull(iLID,0) FROM BIZ0025 WITH (NOLOCK)
		WHERE iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='REOPEN'
		AND siSTATUS=0
		ORDER BY vaCFDESC
	</cfquery>
	<script>document.write(JSVCgenOptions("<CFLOOP query=q_biz>#vaCFCODE#|#Server.SVClang(vaCFDESC,iLID)#|</CFLOOP>","|","#value#"));</script>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGenOptReopenReason=MTRGenOptReopenReason>

<cffunction name="MTRGenOpt_AppointmentPlace" description="Appointment Place" access="public" returntype="any" output="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="value" type="string" default="">
	<cfset var q_biz={}>
	<OPTION value=""></OPTION>
	<cfquery NAME=q_biz DATASOURCE=#Request.MTRDSN#>
		SELECT vaCFCODE,vaCFDESC,iCLMTYPEMASK,iLID=isnull(iLID,0) FROM BIZ0025 WITH (NOLOCK)
		WHERE iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='APP_PLACE'
		AND siSTATUS=0
		ORDER BY vaCFDESC
	</cfquery>
	<script>document.write(JSVCgenOptions("<CFLOOP query=q_biz>#vaCFCODE#|#Server.SVClang(vaCFDESC,iLID)#|</CFLOOP>","|","#value#"));
	</script>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGenOpt_AppointmentPlace=MTRGenOpt_AppointmentPlace>

<cffunction name="MTRGenOptVehRegLoc" description="Show Vehicle Reg Location (i-survey)" access="public" returntype="any" output="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="value" type="string" default="">
	<cfargument name="display" type="numeric" default=0>
	<cfargument name="displayshort" type="numeric" default=0>
	<cfset var q_biz={}>
	<CFIF insgcoid IS 1101177>
		<cfquery NAME=q_biz DATASOURCE=#Request.MTRDSN#>
			SELECT vaCFCODE,vaCFDESC,vaCFMAPCODE,vaCFMAPCODE2=ISNULL(vaCFMAPCODE2,''),iCLMTYPEMASK,iLID=isnull(iLID,0) FROM BIZ0025 WITH (NOLOCK)
			WHERE iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='REG_PROVINCE'
			AND siSTATUS=0
			ORDER BY vaCFDESC
		</cfquery>
	<CFELSE>
		<cfquery NAME=q_biz DATASOURCE=#Request.MTRDSN#>
			SELECT vaCFCODE,vaCFDESC,vaCFMAPCODE,vaCFMAPCODE2=ISNULL(vaCFMAPCODE2,''),iCLMTYPEMASK,iLID=isnull(iLID,0) FROM BIZ0025 WITH (NOLOCK)
			WHERE iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='STATE'
			AND siSTATUS=0
			ORDER BY vaCFDESC
		</cfquery>
	</CFIF>
	<cfif display eq 1>
		<CFIF ArrayFind(q_biz["vaCFCODE"], value) GT 0>
			<cfif displayshort eq 0>
				#q_biz["vaCFDESC"][ArrayFind(q_biz["vaCFCODE"], value)]#
			<cfelseif displayshort eq 1>
				#q_biz["vaCFMAPCODE"][ArrayFind(q_biz["vaCFCODE"], value)]#
			<cfelseif displayshort eq 2>
				#q_biz["vaCFMAPCODE2"][ArrayFind(q_biz["vaCFCODE"], value)]#
			</cfif>
		</CFIF>
	<cfelse>
		<OPTION value=""></OPTION>
	<CFLOOP query=q_biz>
		<option value=#q_biz.vacfcode# code=#q_biz.vacfmapcode# <cfif value is #q_biz.vacfcode#>selected</cfif>>#q_biz.vacfdesc#</option>
	</CFLOOP>
	</cfif>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGenOptVehRegLoc=MTRGenOptVehRegLoc>

<cffunction name="MTRGenOpt_InsurerType" description="Insurer Type selection" access="public" returntype="any" output="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="value" type="string" default="">
	<cfargument name="display" type="numeric" default=0>
	<cfset var q_biz={}>
	<cfquery NAME=q_biz DATASOURCE=#Request.MTRDSN#>
	SELECT vaCFCODE,vaCFDESC,vaCFMAPCODE
	FROM BIZ0025 WITH (NOLOCK)
	WHERE iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='INS_TYPE' AND siSTATUS=0
	ORDER BY vaCFCODE
	</cfquery>
	<cfif display IS 1>
		<cfset idx=ArrayFind(q_biz["vaCFCODE"],value)>
		<CFIF idx GT 0>
			#HTMLEditFormat(q_biz["vaCFCODE"][idx])# - #HTMLEditFormat(q_biz["vaCFDESC"][idx])#
		</CFIF>
	<cfelse>
		<option value=""></option>
		<script>document.write(JSVCgenOptions("<CFLOOP query=q_biz>#vaCFCODE#|#JSStringFormat(vaCFCODE)# - #JSStringFormat(vaCFDESC)#|</CFLOOP>","|","#value#"));</script>
	</cfif>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGenOpt_InsurerType=MTRGenOpt_InsurerType>

<cffunction name="MTRGenOpt_ManufacturerList" description="Car Manufacturer selection" access="public" returntype="any" output="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="value" type="string" default="">
	<cfargument name="display" type="numeric" default=0>
	<cfset var q_biz={}>
	<cfquery NAME=q_biz DATASOURCE=#Request.MTRDSN#>
	SELECT vaCFCODE,vaCFDESC,vaCFMAPCODE,LID=ISNULL(iLID,0)
	FROM BIZ0025 WITH (NOLOCK)
	WHERE iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='MANUFACTURER' AND siSTATUS=0
	ORDER BY vaCFDESC
	</cfquery>
	<!---cfif display IS 1>
		<cfset idx=ArrayFind(q_biz["vaCFCODE"],value)>
		<CFIF idx GT 0>
			#HTMLEditFormat(q_biz["vaCFDESC"][idx])#
		</CFIF>
	<cfelse>
		<option value=""></option>
		<script>document.write(JSVCgenOptions("<CFLOOP query=q_biz>#vaCFCODE#|#JSStringFormat(vaCFCODE)# - #JSStringFormat(Server.SVCLang(vaCFDESC,LID))#|</CFLOOP>","|","#value#"));</script>
	</cfif--->
	<!--- 2018-02-27: Not using mapping from integration anymore, save as varchar --->
	<cfif display IS 1>
		#HTMLEditFormat(value)#
	<cfelse>
		<option value=""></option>
		<cfset Found="">
		<cfloop query=q_biz>
			<cfif UCase(vaCFMAPCODE) IS UCase(value)>
				<cfset Found=vaCFMAPCODE>
			</cfif>
		</cfloop>
		<cfif Found IS "" AND value IS NOT "">
			<option value="#HTMLEditFormat(value)#" selected>#HTMLEditFormat(value)#</option>
		</cfif>
		<script>document.write(JSVCgenOptions("<CFLOOP query=q_biz>#JSStringFormat(vaCFMAPCODE)#|#JSStringFormat(vaCFMAPCODE)#|</CFLOOP>","|","#Found#"));</script>
	</cfif>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGenOpt_ManufacturerList=MTRGenOpt_ManufacturerList>


<cffunction name="MTRGenOpt_TPInsList" description="TP Insurer List selection" access="public" returntype="any" output="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="value" type="string" default="">
	<cfargument name="display" type="numeric" default=0><!--- 0:give the <options>, 1:display value for viewonly, 2:return true or false if should display from biz0025  --->
	<cfset var q_biz={}>
	<cfset var ret = "">
	<cfquery NAME=q_biz DATASOURCE=#Request.MTRDSN#>
	SELECT <CFIF display eq 2> TOP 1 </CFIF> vaCFCODE,vaCFDESC,vaCFMAPCODE,LID=ISNULL(iLID,0)
	FROM BIZ0025 WITH (NOLOCK)
	WHERE iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='TP_INS' AND siSTATUS=0
	order by (case when vacfcode='1137' then N'ZZZZZZZZZ' else vacfdesc end ) asc
	</cfquery>
	<cfif display IS 1>
		<cfset idx=ArrayFind(q_biz["vaCFCODE"],value)>
		<CFIF idx GT 0>
			<cfset ret = HTMLEditFormat(Server.SVCLang(q_biz["vaCFDESC"][idx],q_biz["LID"][idx]))>
		</CFIF>
	<cfelseif display IS 2>
		<cfif q_biz.recordCount gt 0>
			<cfset ret = true>
		<cfelse>
			<cfset ret = false>
		</cfif>
	<cfelse>
		<cfsavecontent variable="ret"><script>document.write(JSVCgenOptions("<CFLOOP query=q_biz>#vaCFCODE#|#JSStringFormat(Server.SVCLang(vaCFDESC,LID))#|</CFLOOP>","|","#value#"));</script></cfsavecontent>
	</cfif>
	<cfreturn ret>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGenOpt_TPInsList=MTRGenOpt_TPInsList>

<cffunction name="MTRGenOpt_DamCon" description="Car Manufacturer selection" access="public" returntype="any" output="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="value" type="string" default="">
	<cfargument name="display" type="numeric" default=0>
	<cfargument name="NoDamage" type="numeric" default=0>
	<cfset var q_biz={}>
	<cfquery NAME=q_biz DATASOURCE=#Request.MTRDSN#>
	SELECT vaCFCODE,vaCFDESC,vaCFMAPCODE,LID=ISNULL(iLID,0)
	FROM BIZ0025 WITH (NOLOCK)
	WHERE iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='DAMCON' AND siSTATUS=0
	<CFIF INSGCOID EQ 1101177 AND NoDamage EQ 0 and session.vars.orgtype eq "I">AND vaCFCODE != 16</CFIF>
	ORDER BY vaCFCODE
	</cfquery>
	<cfif display IS 1>
		<cfset idx=ArrayFind(q_biz["vaCFCODE"],value)>
		<CFIF idx GT 0>
			<CFIF INSGCOID NEQ 1101177>#HTMLEditFormat(q_biz["vaCFMAPCODE"][idx])# - </CFIF>#HTMLEditFormat(q_biz["vaCFDESC"][idx])#
		</CFIF>
	<cfelse>
		<option value=""></option>
		<script>document.write(JSVCgenOptions("<CFLOOP query=q_biz>#vaCFCODE#|<CFIF INSGCOID NEQ 1101177>#JSStringFormat(vaCFMAPCODE)# - </CFIF>#JSStringFormat(Server.SVCLang(vaCFDESC,LID))#|</CFLOOP>","|","#value#"));</script>
	</cfif>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGenOpt_DamCon=MTRGenOpt_DamCon>

<cffunction name="MTRGenOpt_OccupationList" description="Occupation list selection" access="public" returntype="any" output="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="value" type="string" default="">
	<cfargument name="display" type="numeric" default=0>
	<cfset var q_biz={}>
	<cfquery NAME=q_biz DATASOURCE=#Request.MTRDSN#>
	SELECT vaCFCODE,vaCFDESC,vaCFMAPCODE,iLID=IsNull(iLID,0)
	FROM BIZ0025 WITH (NOLOCK)
	WHERE iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='OCCUPATION' AND siSTATUS=0
	ORDER BY vaCFDESC
	</cfquery>
	<cfif display IS 1>
		<cfset idx=ArrayFind(q_biz["vaCFCODE"],value)>
		<CFIF idx GT 0>
			#HTMLEditFormat(Server.SVClang(q_biz["vaCFDESC"][idx],q_biz["iLID"][idx]))#
		</CFIF>
	<cfelse>
		<option value=""></option>
		<script>document.write(JSVCgenOptions("<CFLOOP query=q_biz>#vaCFCODE#|#JSStringFormat(Server.SVClang(vaCFDESC,iLID))#|</CFLOOP>","|","#value#"));</script>
	</cfif>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGenOpt_OccupationList=MTRGenOpt_OccupationList>

<cffunction name="MTRGenOpt_Outsource" description="Occupation list selection" access="public" returntype="any" output="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="value" type="string" default="">
	<cfargument name="display" type="numeric" default=0>
	<cfset var q_biz={}>
	<cfquery NAME=q_biz DATASOURCE=#Request.MTRDSN#>
	SELECT vaCFCODE,vaCFDESC,vaCFMAPCODE,iLID=IsNull(iLID,0)
	FROM BIZ0025 WITH (NOLOCK)
	WHERE iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='OUTSOURCE_RSN' AND siSTATUS=0
	ORDER BY vaCFDESC
	</cfquery>
	<cfif display IS 1>
		<cfset idx=ArrayFind(q_biz["vaCFCODE"],value)>
		<CFIF idx GT 0>
			#HTMLEditFormat(Server.SVClang(q_biz["vaCFDESC"][idx],q_biz["iLID"][idx]))#
		</CFIF>
	<cfelse>
		<option value=""></option>
		<script>document.write(JSVCgenOptions("<CFLOOP query=q_biz>#vaCFCODE#|#JSStringFormat(Server.SVClang(vaCFDESC,iLID))#|</CFLOOP>","|","#value#"));</script>
	</cfif>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGenOpt_Outsource=MTRGenOpt_Outsource>

<cffunction name="MTRGenOpt_RecoveryCode" description="Recovery code selection" access="public" returntype="any" output="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="value" type="string" default="">
	<cfargument name="display" type="numeric" default=0>
	<cfset var q_biz={}>
	<cfquery NAME=q_biz DATASOURCE=#Request.MTRDSN#>
	SELECT vaCFCODE,vaCFDESC,vaCFMAPCODE
	FROM BIZ0025 WITH (NOLOCK)
	WHERE iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='RECOVERY_CODE' AND siSTATUS=0
	ORDER BY vaCFCODE
	</cfquery>
	<cfif display IS 1>
		<cfset idx=ArrayFind(q_biz["vaCFCODE"],value)>
		<CFIF idx GT 0>
			#HTMLEditFormat(q_biz["vaCFDESC"][idx])#
		</CFIF>
	<cfelse>
		<option value=""></option>
		<script>document.write(JSVCgenOptions("<CFLOOP query=q_biz>#vaCFCODE#|#JSStringFormat(vaCFDESC)#|</CFLOOP>","|","#value#"));</script>
	</cfif>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGenOpt_RecoveryCode=MTRGenOpt_RecoveryCode>


<cffunction name="MTRGenBankPaymentTR" description="Generate standard display block for repairer/supplier payment/bank-in" access="public" returntype="any" output="true">
<cfargument name="coid" type="numeric" required="true">
<cfargument name="inscoid" type="numeric" required="true">
<cfargument name="bankcoid" type="string" required="true">
<cfargument name="bankaccno" type="string" required="true">
<cfargument name="bankaccname" type="string" required="true">
<cfargument name="bankpayemail" type="string" required="true">

<cfquery name=q_coprofile datasource=#Request.MTRDSN#>
SELECT a.iCOID,a.iGCOID,a.iLOCID,a.siCOTYPEID,a.vaCONAME
FROM SEC0005 a WITH (NOLOCK) WHERE a.iCOID=<cfqueryparam value="#arguments.coid#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<CFIF q_coprofile.recordcount NEQ 1>
	<CFTHROW TYPE="EX_DBERROR" ErrorCode="BADPARAM">
</CFIF>

<!--- Get preferred bank account stored under coprofile --->
<cfquery name=q_bank2 datasource=#Request.MTRDSN#>
SELECT a.iBANKCOID,BANKNAME=b.vaCONAME,a.vaBANKACCOUNT,a.vaBANKACCNAME
FROM SEC0005 a WITH (NOLOCK) JOIN SEC0005 b WITH (NOLOCK) ON b.iCOID=a.iBANKCOID
WHERE a.iCOID=<cfqueryparam value="#q_coprofile.iCOID#" cfsqltype="CF_SQL_INTEGER"> AND Len(a.vaBANKACCOUNT)>0
</cfquery>
<cfif q_bank2.recordcount IS 0>
	<!--- If there's no pref a/c, try get it from HQ --->
	<cfquery name=q_bank2 datasource=#Request.MTRDSN#>
	SELECT a.iBANKCOID,BANKNAME=b.vaCONAME,a.vaBANKACCOUNT,a.vaBANKACCNAME
	FROM SEC0005 a WITH (NOLOCK) JOIN SEC0005 b WITH (NOLOCK) ON b.iCOID=a.iBANKCOID
	WHERE a.iCOID=<cfqueryparam value="#q_coprofile.iGCOID#" cfsqltype="CF_SQL_INTEGER"> AND Len(a.vaBANKACCOUNT)>0
	</cfquery>
</cfif>

<cfset q_bank3=QueryNew("ROWID,BANKCOID,BANKNAME,ACCTNO,ACCTNAME,PAYEMAILNOTI")>
<CFLOOP query=q_bank2>
	<cfset QueryAddRow(q_bank3)>
	<cfset q_bank3["ROWID"][q_bank3.recordcount]=q_bank3.recordcount>
	<cfset q_bank3["BANKCOID"][q_bank3.recordcount]=q_bank2.iBANKCOID>
	<cfset q_bank3["BANKNAME"][q_bank3.recordcount]=q_bank2.BANKNAME>
	<cfset q_bank3["ACCTNO"][q_bank3.recordcount]=q_bank2.vaBANKACCOUNT>
	<cfset q_bank3["ACCTNAME"][q_bank3.recordcount]=IIf(Trim(q_bank2.vaBANKACCNAME) IS "",DE(q_coprofile.vaCONAME),Trim(DE(q_bank2.vaBANKACCNAME)))>
</CFLOOP>

<cfif q_coprofile.siCOTYPEID IS 1>
	<!--- If cotype is Repairer, get bank account information from Workshop Profile --->
	<cfstoredproc PROCEDURE='sspMWPgetVersion' DATASOURCE=#Request.MTRDSN# RETURNCODE=YES>
	<cfprocparam TYPE=IN  DBVARNAME=@IVID NULL=YES VALUE=0 CFSQLTYPE=CF_SQL_INTEGER  >
	<cfprocparam TYPE=IN  DBVARNAME=@ICOID VALUE=#q_coprofile.iGCOID# CFSQLTYPE=CF_SQL_INTEGER  >
	<cfprocresult NAME="WPVERSION" Resultset=1 MAXROWS=1>
	</cfstoredproc>
	<cfif CFSTOREDPROC.STATUSCODE LT 0>
		<cfthrow TYPE="EX_DBERROR" ErrorCode="REP/ATTBILL/MWPGETVER(#CFSTOREDPROC.STATUSCODE#)">
	</cfif>
	<cfif WPVERSION.recordcount GT 0 AND WPVERSION.ISID GT 0>
		<cfstoredproc PROCEDURE='sspMWPgetBankInfo' DATASOURCE=#Request.MTRDSN# RETURNCODE=YES>
		<cfprocparam TYPE=IN  DBVARNAME=@ISID VALUE=#WPVERSION.ISID# CFSQLTYPE=CF_SQL_INTEGER>
		<cfprocresult NAME="GetBankInfo" Resultset=1>
		</cfstoredproc>
		<cfif CFSTOREDPROC.STATUSCODE LTE 0>
			<cfthrow TYPE="EX_DBERROR" ErrorCode="REP/ATTBILL/MWPGETBANK(#CFSTOREDPROC.STATUSCODE#)">
		</cfif>
		<CFLOOP query=GetBankInfo>
			<cfset QueryAddRow(q_bank3)>
			<cfset q_bank3["ROWID"][q_bank3.recordcount]=q_bank3.recordcount>
			<cfset q_bank3["BANKCOID"][q_bank3.recordcount]=GetBankInfo.siBANKID>
			<cfset q_bank3["BANKNAME"][q_bank3.recordcount]=GetBankInfo.vaCONAME>
			<cfset q_bank3["ACCTNO"][q_bank3.recordcount]=GetBankInfo.vaACCNO>
			<cfset q_bank3["ACCTNAME"][q_bank3.recordcount]=q_coprofile.vaCONAME>
		</CFLOOP>
	</cfif>
</cfif>

<CFQUERY datasource="#Request.MTRDSN#" name="q_getbankacc_panel">
	SELECT AC.iBANKCOID, AC.vaBANKACC, AC.vaBANKACCTNAME, AC.siDEFAULT, AC.siORDER, B.vaCONAME,PNL.vaBANKPAYEMAIL
	FROM TRX0030_BANKACC AC WITH (NOLOCK)
	INNER JOIN SEC0005 B WITH (NOLOCK) ON AC.iBANKCOID = B.iCOID
	JOIN TRX0030 PNL WITH(NOLOCK) ON AC.iPNLID=PNL.iPNLID
	WHERE PNL.iPNLCOID = <cfqueryparam value="#q_coprofile.iCOID#" cfsqltype="CF_SQL_INTEGER">
	AND AC.siSTATUS = 0
	ORDER BY AC.siDEFAULT DESC, AC.siORDER, B.vaCONAME
</CFQUERY>

<CFIF q_getbankacc_panel.recordcount GT 0>
	<CFLOOP query=q_getbankacc_panel>
		<cfset QueryAddRow(q_bank3)>
		<cfset q_bank3["ROWID"][q_bank3.recordcount]=q_bank3.recordcount>
		<cfset q_bank3["BANKCOID"][q_bank3.recordcount]=q_getbankacc_panel.iBANKCOID>
		<cfset q_bank3["BANKNAME"][q_bank3.recordcount]=q_getbankacc_panel.vaCONAME>
		<cfset q_bank3["ACCTNO"][q_bank3.recordcount]=q_getbankacc_panel.vaBANKACC>
		<cfset q_bank3["ACCTNAME"][q_bank3.recordcount]=IIf(Trim(q_getbankacc_panel.vaBANKACCTNAME) IS "",DE(q_coprofile.vaCONAME),Trim(DE(q_getbankacc_panel.vaBANKACCTNAME)))>
		<cfset q_bank3["PAYEMAILNOTI"][q_bank3.recordcount]=q_getbankacc_panel.vaBANKPAYEMAIL>
	</CFLOOP>
</CFIF>

<CFSET BANKSTR="#arguments.bankcoid#|#arguments.bankaccname#">
<CFOUTPUT>
<script>
function toggleBankIn(obj) {
	var o=JSVCall("chkBankIn");
	var o2=JSVCall("FBBANKSEL");
	var bankstr="#JSStringFormat(BANKSTR)#";
	var insgcoid=#Request.DS.CO[arguments.inscoid].GCOID#;
	if(obj==null && bankstr.length>1) {
		o.checked=true;
	}
	if(insgcoid==700495 && obj==null && !o.checked) {
		o.checked=true;
	}
	else if(insgcoid==50||insgcoid==700467||insgcoid==700505||insgcoid==700527||insgcoid==703035||insgcoid==700162) {
		o.checked=true;
		JSVCSetDisabledList("chkBankIn",true);
	}
	JSVCshow("tabBankAcc",o.checked);
	constructBankStr();
	toggleBankChange(o2);
}
function toggleBankChange(obj) {
	showBankDet(obj);
	JSVCshow("tabBankOth",obj.value==-1);
	JSVCshow("selBankDet",obj.value!=-1);
	constructBankStr();
}
function constructBankStr() {
	var o=JSVCall("FBBANKSTR"); <!--- FBBANKSTR (URLVAR): BANKCOID|BANKNAME|BANKACCTNO|BANKACCTNAME|BANKPAYEMAIL --->
	o.value="";
	if(JSVCall("chkBankIn").checked) {
		var o2=JSVCall("FBBANKSEL");
		if(o2.value!=""&&o2.value!="-1")
			o.value=o2.value+"|"+JSVCall("FBBANKPAYEMAIL").value;
		else {
			var o3=JSVCall("FBBANKCOID");
			o.value=o3.value+"|"+o3.options[o3.selectedIndex].text+"|"+JSVCall("FBBANKACCTNO").value+"|"+JSVCall("FBBANKACCTNAME").value+"|"+JSVCall("FBBANKPAYEMAIL").value;
		}
	}
}
function checkAcctNo(obj) {
	obj.value=obj.value.toString().replace(/[^0-9\-]/gi,"");
	DoReq(obj);
}
function showBankDet(o){

	if(o==null||typeof(o)=='undefined')return;
	if(o.value==-1)return;
	var bankdet=o,bnknm=JSVCall('txtbnm'),bnkacno=JSVCall('txtbaccno'),bnkacnm=txtbaccnm,pemailnoti=$('##'+o.id+' option:selected').attr('peml');
	var bankdet=bankdet.value.split("|");
	if(bankdet.length<=1)return;
	if(bnknm){
		bnknm.innerText=bankdet[1];
	}
	if(bnkacno){
		bnkacno.innerText=bankdet[2];
	}
	if(bnkacnm){
		bnkacnm.innerText=bankdet[3];
	}
	/*if(pemailnoti.length>0){
		JSVCall("FBBANKPAYEMAIL").value=pemailnoti;
	}else{
		JSVCall("FBBANKPAYEMAIL").value='';
	}*/

}
AddOnloadCode("toggleBankIn();");
</script>
<tr id="SectionBankIn">
	<td>#Server.SVClang("Bank In?",9829)#</td><td colspan=3><input type=checkbox id="chkBankIn" onclick=toggleBankIn(this)><label for=chkBankIn> #Server.SVClang("Request direct payment to your bank account",9688)#</label>
	<table class=clsTblNoBorder id="tabBankAcc" style="margin-left:20px;margin-top:3px">
	<tr>
		<td colspan=2><select CHKNAME="#Server.SVClang("Bank Account",9830)#" ID="FBBANKSEL" CHKREQUIRED onchange="toggleBankChange(this)" onblur="DoReq(this)"><option value=""><cfset selfound=false><cfloop query=q_bank3><option peml="<CFIF q_bank3.PAYEMAILNOTI IS NOT "">#q_bank3.PAYEMAILNOTI#</CFIF>" value="#q_bank3.BANKCOID#|#HTMLEditFormat(q_bank3.BANKNAME)#|#HTMLEditFormat(q_bank3.ACCTNO)#|#HTMLEditFormat(q_bank3.ACCTNAME)#"<CFIF BANKSTR IS q_bank3.BANKCOID&"|"&q_bank3.ACCTNO> SELECTED<cfset selfound=true></CFIF>>#HTMLEditFormat(q_bank3.BANKNAME)# - Acct No: #q_bank3.ACCTNO#</option></cfloop><option value=-1<CFIF NOT selfound AND Len(BANKSTR) GT 1> selected</CFIF>>#Server.SVClang("Others (Please specify below)",9832)#</option></select></td>
	</tr>
	<tr><td colspan=2>
		<table id="selBankDet" style="display:none">
			<tr><td>Bank :<span id="txtbnm"></span><td><tr>
			<tr><td>Account No :<span id="txtbaccno"></span><td><tr>
			<tr><td>Account Name: <span id="txtbaccnm"></span><td><tr>
		</table>
	</td></tr>
	<tr>
		<td colspan=2>
			<table id="tabBankOth" style="display:none">
				<cfset q_test=Request.DS.FN.SVCGetLocalBank(q_coprofile.iLOCID)>
				<tr><td><i>#Server.SVClang("Bank",8187)#:</i></td><td><select ID=FBBANKCOID CHKREQUIRED onchange=DoReq(this) onblur="DoReq(this);constructBankStr()"><option value=""><cfloop query=q_test><option value="#iCOID#"<CFIF iCOID IS arguments.bankcoid> SELECTED</CFIF>>#HTMLEditFormat(vaCONAME)#</option></cfloop></select></td></tr>
				<tr><td><i>#Server.SVClang("Account No",8188)#:</i></td><td><input ID=FBBANKACCTNO CHKREQUIRED type=text maxlength=50 size="30" value="#HTMLEditFormat(arguments.bankaccno)#" onblur="checkAcctNo(this);constructBankStr()" CHKREFORMAT="^[0-9\-]{7,}$"></td></tr>
				<tr><td><i>#Server.SVClang("Account Name",8189)#:</i></td><td><input ID=FBBANKACCTNAME CHKREQUIRED type=text maxlength=100 size="40" value="#HTMLEditFormat(arguments.bankaccname)#" onblur="DoReq(this);constructBankStr()" style="text-transform:uppercase"></td></tr>
			</table>
		</td>
	</tr>
	<tr><td>#Server.SVClang("Payment Notification Email",8894)#:</td><td><input ID=FBBANKPAYEMAIL type=text maxlength=50 size="30" value="#HTMLEditFormat(ListFirst(arguments.bankpayemail,";,"))#" onblur="JSVCDoEmail(this);constructBankStr()"></td></tr>
	</table>
	<input type=hidden name=FBBANKSTR id=FBBANKSTR value="">
	</td>
</tr>
</CFOUTPUT>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGenBankPaymentTR=MTRGenBankPaymentTR>

<cffunction access="public" name="MtrGetDetaffPoltype" returntype="struct" output=false description="">
    <cfargument name="gcoid" type="numeric" required="true">
    <cfargument name="poltype" type="numeric" required="true">
    <cfif NOT StructKeyExists(request.ds.detaffpoltype,arguments.gcoid)
        OR arguments.poltype lt 0
        OR arguments.poltype gt ArrayLen(request.ds.detaffpoltype[arguments.gcoid])>
        <cfreturn {desc="undefined"}>
    </cfif>
    <cfif arguments.poltype eq 0>
        <cfreturn {desc="[To be automated]"}>
    <cfelse>
        <cfreturn request.ds.detaffpoltype[arguments.gcoid][arguments.poltype]>
    </cfif>
</cffunction>
<CFSET Attributes.DS.MTRFN.MtrGetDetaffPoltype=MtrGetDetaffPoltype>

<cffunction name="SAS_TypeOfAccident" description="For SAS only. Generate options for Type of Accident" access="public" returntype="any" output="true">
<cfargument name="rptno" type="numeric" required="true" hint="Primary Key of SAS0001">
<cfargument name="edit" type="numeric" required="false" default=0 hint="0:Readonly,1:Edit">
<cfset var q_sas={}>
<cfset var q_catype={}>

<cfquery name=q_sas datasource=#Request.MTRDSN#>
SELECT b.dtEntryDateTime,a.iCollisionType,a.vaCollisionTypeText,a.vaCollisionUnknownText,a.siMIGRATED
FROM SAS0001 a WITH (NOLOCK)
	INNER JOIN SAS0001 b WITH (NOLOCK) ON b.iRPTNO=a.iMRPTNO AND a.siSTATUS=0 AND b.siSTATUS=0
WHERE a.iRPTNO=<cfqueryparam value="#Arguments.rptno#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfif q_sas.RecordCount NEQ 1>
	<cfthrow TYPE="EX_DBERROR" ErrorCode="GEN-TYPEOFACCIDENT(#q_sas.RecordCount#)">
</cfif>

<CFIF Arguments.edit IS 1>
	<cfif (ListFind("PROD,TRAIN",Application.DB_MODE) AND q_sas.dtEntryDateTime GE "2017-07-04") OR (ListFind("DEV,UAT",Application.DB_MODE) AND q_sas.dtEntryDateTime GE "2017-06-14")>
		<script>document.write(JSVCgenOptions("<CFLOOP INDEX=x LIST="#Request.DS.CATYPE_SAS_LIST#"><cfif BitAnd(Request.DS.CATYPE_SAS[x].MASK,1) GT 0>#x#|#Request.DS.CATYPE_SAS[x].DSC#|</cfif></CFLOOP>","|","#q_sas.iCollisionType#"));</script>
	<cfelse>
		<script>document.write(JSVCgenOptions("<CFLOOP INDEX=x LIST="#Request.DS.CATYPELIST#"><cfif BitAnd(Request.DS.CATYPEMASK[x],1) GT 0>#x#|#Request.DS.CATYPE[x]#|</cfif></CFLOOP>","|","#q_sas.iCollisionType#"));</script>
	</cfif>
<CFELSE>
	<cfif q_sas.iCollisionType GT 0>
		<cfif (ListFind("PROD,TRAIN",Application.DB_MODE) AND q_sas.dtEntryDateTime GE "2017-07-04") OR (ListFind("DEV,UAT",Application.DB_MODE) AND q_sas.dtEntryDateTime GE "2017-06-14")>
			#Request.DS.CATYPE_SAS[q_sas.iCollisionType].DSC#
		<cfelse>
			#Request.DS.CATYPE[q_sas.iCollisionType]#
		</cfif>
		<cfif q_sas.iCollisionType IS 55> - #HTMLEditFormat(q_sas.vaCollisionUnknownText)#</cfif>
	<cfelseif q_sas.siMIGRATED IS 1>
		#HTMLEditFormat(q_sas.vaCollisionTypeText)#
	</cfif>
</CFIF>

</cffunction>
<CFSET Attributes.DS.MTRFN.SAS_TypeOfAccident=SAS_TypeOfAccident>

<cffunction name="MTRPreselectCT" description="Returns true if claim type must be preselected before entering claim type screen" access="public" returntype="any" output="true">
<cfargument name="CASEID" type="numeric" required="false" hint="Case ID" default=0>
<cfargument name="CT" type="string" required="false" hint="claim type" default="">
<cfargument name="MODE" type="numeric" required="false" hint="Check type. Mode 1 = check if setting is enabled. Mode 2 : Check if setting is enabled, with claim type. " default=1>
<cfargument name="DOMAINID" type="numeric" required="false" hint="Source Domain Id" default=1><!--- Customization #23411 --->
	<cfset var preseletClaimType = 0>
	<cfset var ea_claimtype = "">

	<cfif session.vars.orgtype eq "I">
		<!--- Customization #23411: preselect claim type for all th insurer when create tp subfolder --->
		<CFIF SESSION.VARS.LOCID IS 11 AND DOMAINID EQ 6>
			<CFSET local.preseletClaimType = 1>
		<CFELSE>
			<CFSET local.preseletClaimType=Request.DS.FN.SVCgetExtAttrLogic("COADMIN",2,"COATTRSELCLAIMTYPE",10,SESSION.VARS.GCOID)>
			<CFIF not local.preseletClaimType eq 1>
				<cfset local.preseletClaimType = 0>
			</CFIF>
		</CFIF>
	</cfif>

	<cfif arguments.mode eq 2 and local.preseletClaimType eq 1><!--- Check against claim type and insurer company type --->
		<CFSET local.ea_claimtype=Request.DS.FN.SVCgetExtAttrLogic("COADMIN",2,"COATTRSELCLAIMTYPE_MASK",10,SESSION.VARS.GCOID)>
		<cfif (isNumeric(local.ea_claimtype) AND StructKeyExists(request.ds.clmtypereverse, Arguments.CT) AND BitAnd(local.ea_claimtype, request.ds.clmtypereverse[Arguments.CT]) gt 0)><!--- #23423: [All] eClaims - Clean up Preselect Claim Type --->
			<cfset local.preseletClaimType = 1>
		<cfelse>
			<cfset local.preseletClaimType = 0>
		</cfif>
	</cfif>

	<cfreturn local.preseletClaimType>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRPreselectCT=MTRPreselectCT>

<cffunction name="MTRPolicyGetVehicleModel" description="Returns vehicle model string from policy (BIZ_POL table)" access="public" returntype="string" output="false">
<cfargument name="CASEID" type="numeric" required="true" hint="Case ID">
<cfquery NAME=Local.q_bizpol DATASOURCE=#Request.MTRDSN#>
SELECT VEHMODELSTR_POL=RTrim(
	CASE WHEN IsNull(p.vaMAN,'')='' THEN '' ELSE p.vaMAN+' ' END+
	CASE WHEN IsNull(p.vaMODEL,'')='' THEN '' ELSE p.vaMODEL+' ' END+
	CASE WHEN IsNull(p.vaVEHBODY,'')='' THEN '' ELSE p.vaVEHBODY+' ' END+
	CASE WHEN p.iMANYEAR>0 THEN
		CASE WHEN p.iMANYEAR<=50 THEN '['+CAST(2000+p.iMANYEAR AS VARCHAR)+']'
			 WHEN p.iMANYEAR<=99 THEN '['+CAST(1900+p.iMANYEAR AS VARCHAR)+']'
			 ELSE '['+CAST(p.iMANYEAR AS VARCHAR)+']' END
	ELSE '' END)
FROM BIZ_POL p WITH (NOLOCK)
	INNER JOIN TRX0008 i WITH (NOLOCK) ON i.iBIZPOLID=p.iPOLID
WHERE i.iCASEID=<cfqueryparam value="#Arguments.CASEID#" cfsqltype="CF_SQL_INTEGER"> AND i.siSTATUS=0 AND i.siTPINS=0
</cfquery>
<cfreturn Trim(Local.q_bizpol.VEHMODELSTR_POL)>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRPolicyGetVehicleModel=MTRPolicyGetVehicleModel>

<cffunction name="MTRPolicyGetVehicleModelByPOLID" description="Returns vehicle model string from policy (BIZ_POL table)" access="public" returntype="string" output="false">
<cfargument name="BIZPOLID" type="numeric" required="true" hint="POL ID">
<cfquery NAME=Local.q_bizpol DATASOURCE=#Request.MTRDSN#>
SELECT VEHMODELSTR_POL=RTrim(
	CASE WHEN IsNull(p.vaMAN,'')='' THEN '' ELSE p.vaMAN+' ' END+
	CASE WHEN IsNull(p.vaMODEL,'')='' THEN '' ELSE p.vaMODEL+' ' END+
	CASE WHEN IsNull(p.vaVEHBODY,'')='' THEN '' ELSE p.vaVEHBODY+' ' END+
	CASE WHEN p.iMANYEAR>0 THEN
		CASE WHEN p.iMANYEAR<=50 THEN '['+CAST(2000+p.iMANYEAR AS VARCHAR)+']'
			 WHEN p.iMANYEAR<=99 THEN '['+CAST(1900+p.iMANYEAR AS VARCHAR)+']'
			 ELSE '['+CAST(p.iMANYEAR AS VARCHAR)+']' END
	ELSE '' END)
FROM BIZ_POL p WITH (NOLOCK)
	INNER JOIN TRX0008 i WITH (NOLOCK) ON i.iBIZPOLID=p.iPOLID
WHERE P.iPOLID=<cfqueryparam value="#Arguments.BIZPOLID#" cfsqltype="CF_SQL_INTEGER"> AND i.siSTATUS=0 AND i.siTPINS=0
</cfquery>
<cfreturn Trim(Local.q_bizpol.VEHMODELSTR_POL)>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRPolicyGetVehicleModelByPOLID=MTRPolicyGetVehicleModelByPOLID>

<cffunction name="MTRPolicyGetVehicleModelByPOLIDINT" description="Returns vehicle model string from policy (BIZ_POL table)" access="public" returntype="string" output="false">
<cfargument name="BIZPOLID" type="numeric" required="true" hint="POL ID">
<cfquery NAME=local.q_int_pol DATASOURCE=#Request.MTRDSN#>
SELECT poldata = p.vaPOLDATA
FROM INT_POL p WITH (NOLOCK)
WHERE P.iPOLID=<cfqueryparam value="#Arguments.BIZPOLID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfreturn Trim(local.q_int_pol.poldata)>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRPolicyGetVehicleModelByPOLIDINT=MTRPolicyGetVehicleModelByPOLIDINT>

<cffunction name="GIAIsARC" hint="GIA Accident Reporting Centre. Returns True or False">
	<cfset var flag = false>
	<cfset var canread = 0>
	<CFIF session.vars.orgtype eq "R">
		<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCchkgrp.cfm" GrpList="440R">
		<cfif CanRead IS 1>
			<cfset flag = true>
		</cfif>
	</CFIF>
	<cfreturn flag>
</cffunction>
<CFSET Attributes.DS.MTRFN.GIAIsARC=GIAIsARC>

<cffunction name="GIAIsSol" hint="GIA Solicitor. Returns True or False.">
	<cfset var flag = false>
	<cfset var canread = 0>
	<CFIF session.vars.orgtype eq "L">
		<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCchkgrp.cfm" GrpList="440R">
		<cfif CanRead IS 1>
			<cfset flag = true>
		</cfif>
	</CFIF>
	<cfreturn flag>
</cffunction>
<CFSET Attributes.DS.MTRFN.GIAIsSol=GIAIsSol>

<cffunction name="GIARMC" hint="GIARMC member. Returns True or False.">
	<cfset var flag = false>
	<CFQUERY NAME="qGetGIARMCAcc" DATASOURCE="#Request.MTRDSN#">
			SELECT TOP 1 1
			FROM SEC0001 staff
			INNER JOIN SEC0005 co ON co.iCOID=staff.iCOID
			INNER JOIN FBIL0009 acc WITH (NOLOCK) ON acc.iCOID=co.iCOID
			INNER JOIN FBIL0008 accinfo WITH (NOLOCK) ON acc.iACCID=accinfo.iACCID AND accinfo.siACCSTAT=0
			WHERE accinfo.iACCTYPE = 4 AND staff.vaUSID=<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#SESSION.VARS.USERID#">
	</CFQUERY>
	<cfif qGetGIARMCAcc.RecordCount GT 0>
		<cfset flag = true>
	</cfif>
	<cfreturn flag>
</cffunction>
<CFSET Attributes.DS.MTRFN.GIARMC=GIARMC>

<!--- #32314 --->
<cffunction name="blockClmAuditETC" hint="Block ClmAudit/Docs/Estimate Submitted/Insurer Authorized if label's ticked">
	<cfargument name="pnlcoid" type="numeric" default="">
	<cfargument name="inscoid" type="numeric" default="">
	<cfargument name="DOMAINID" type="numeric" default="500">

	<cfset var flag = false>
	<CFQUERY NAME="qGet_blockClmAudEtc" DATASOURCE="#Request.MTRDSN#">
		select
			TOP 1 1
		from
			trx0030 pnl with (nolock)
		left join
			fobj3021 lbl with (nolock) on pnl.iPNLID=lbl.iobjid and lbl.iDOMAINID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#DOMAINID#">
		where
			','+lbl.valookup+',' like '%,1600133,%'
		and
			pnl.iPNLCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#pnlcoid#">
		and
			pnl.icoid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#inscoid#">
	</CFQUERY>
	<cfif qGet_blockClmAudEtc.RecordCount GT 0>
		<cfset flag = true>
	</cfif>
	<cfreturn flag>
</cffunction>
<CFSET Attributes.DS.MTRFN.blockClmAuditETC=blockClmAuditETC>

<cffunction name="GIARMCBOLA" hint="GIARMC BOLA access. Returns True or False.">
	<cfargument name="CASEID" type="numeric" required="true">
	<cfset flag = 0>
	<CFQUERY NAME="qGetBOLAStat" DATASOURCE="#Request.MTRDSN#">
			SELECT iTPKFKSTAT
			FROM TRX0008 WITH (NOLOCK)
			WHERE iCASEID=<cfqueryparam value="#Arguments.CASEID#" cfsqltype="CF_SQL_INTEGER"> AND iTPKFKSTAT&8192=8192
	</CFQUERY>
	<cfif qGetBOLAStat.RecordCount GT 0>
		<cfset flag = 1>
	</cfif>
	<cfreturn flag>
</cffunction>
<CFSET Attributes.DS.MTRFN.GIARMCBOLA=GIARMCBOLA>

<cffunction name="GIAChkNRIC" hint="Check for NRIC / Identification per 22679 for ARC and Solicitor">
	<cfif (REQUEST.DS.MTRFN.GIAIsARC() or REQUEST.DS.MTRFN.GIAIsSol())>
		<CFIF NOT StructKeyExists(session.vars,"loginnric") or (StructKeyExists(session.vars,"loginnric") and session.vars.loginnric eq "") and attributes.fuseaction neq "dsp_nricvalidation">
			<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCurlback.cfm" NEW>
			<CFLOCATION URL="#request.webroot#index.cfm?fusebox=MTRgia&fuseaction=dsp_nricvalidation&#newurlback#&#Request.MToken#" ADDTOKEN="no">
		</CFIF>
	</cfif>
	<cfreturn true>
</cffunction>
<CFSET Attributes.DS.MTRFN.GIAChkNRIC=GIAChkNRIC>

<cffunction name="Chk2FA" hint="Check for 2FA">
	<cfargument name="CASEID" type="numeric" required="false">
	<cfif ListFind("I,R,A,G,L,RG,P",SESSION.VARS.ORGTYPE) AND
	(
		LISTFIND("PROD",APPLICATION.DB_MODE)
		OR (LISTFIND("UAT",APPLICATION.DB_MODE) AND SESSION.VARS.ORGTYPE IS "I" AND NOT ListFind("200002,203977",SESSION.VARS.ORGID))
		OR (LISTFIND("TRAIN",APPLICATION.DB_MODE) AND SESSION.VARS.ORGID IS 200036)
	)>
		<CFSET enable=1>
		<CFIF attributes.fusebox EQ "MTRtp" AND IsDefined("Arguments.CASEID")>
			<CFSET enable=REQUEST.DS.MTRFN.GIARMCBOLA(#Arguments.CASEID#)>
		</CFIF>
		<CFIF (NOT StructKeyExists(session.vars,"LOGIN2FAGIA") or (StructKeyExists(session.vars,"LOGIN2FAGIA") and session.vars.LOGIN2FAGIA eq 0)) and attributes.fuseaction neq "dsp_2FAvalidation" and enable EQ 1>
			<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCurlback.cfm" NEW>

			<CFLOCATION URL="#request.webroot#index.cfm?fusebox=MTRgia&fuseaction=dsp_2FAvalidation&#newurlback#&#Request.MToken#" ADDTOKEN="no">
		</CFIF>
	</cfif>
	<cfreturn true>
</cffunction>
<CFSET Attributes.DS.MTRFN.Chk2FA=Chk2FA>

<cffunction name="DisableSGGIA" hint="Disable SG GIA" returntype="boolean" output="false">
	<cfargument name="forceBlock" type="numeric" required="false" default=0> <!--- force block when date arise --->
		<CFIF NOT(Application.APPLOCID IS 2
			AND(
			listfindnocase("DEV",application.DB_MODE) GT 0 AND now() GTE "2020-09-30 00:00:00"
			OR
			listfindnocase("UAT",application.DB_MODE) GT 0 AND now() GTE "2020-10-30 17:00:00"
			OR
			listfindnocase("PROD,TRAIN",application.DB_MODE) GT 0 AND now() GTE "2020-11-27 17:00:00"))>
			<cfreturn false>
		</CFIF>
		<CFIF forceBlock IS 1 OR NOT(LISTFIND("D",session.vars.orgtype))> <!--- admin will not block unless it is force block , non admin will always block --->
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</CFIF>
</cffunction>
<CFSET Attributes.DS.MTRFN.DisableSGGIA=DisableSGGIA>

<cffunction name="DisableSGGIA_MSG" hint="Disable SG GIA MESSAGE" returntype="string" output="true">
	<cfargument name="mode" type="numeric" required="true">
	<cfargument name="msgDisplay" type="numeric"> <!--- 1:Blockquote 2:Pure Text --->
	<cfargument name="msgMode" type="numeric">
	<CFIF mode IS 1> <!--- Block Access --->
		<cfif NOT(REQUEST.DS.MTRFN.DisableSGGIA())><cfreturn false></cfif>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCASE" ExtendedInfo="Page not found">
	</CFIF>
	<CFIF mode IS 2> <!--- Warning Message --->
		<cfoutput>
			<cfsavecontent variable="a">#Server.SVCLang("Please be informed that there will be a change in the GIARMC system and vendor on <b><u>30 November 2020</u></b>. Click <a target='_blank' href='https://gia.org.sg/images/resources/For-Members/GIARMC-Changes-30Nov2020.pdf'>here</a> to view details of changes relating to the purchase of Accident Reports with effect from <b><u>30 November 2020</u></b>.",0)#</cfsavecontent>
			<cfsavecontent variable="b">#Server.SVCLang("Please be informed that there will be a change in the GIARMC system and vendor on 30 November 2020.",0)#\n\n#Server.SVCLang("Search fees of $14 (excl. gst) will not be refunded for searches made between 23 November to 27 November 2020, even for reports that are not found.",0)#</cfsavecontent>
			<cfsavecontent variable="c">#Server.SVCLang("Search fees of $14 (excl. gst) will <b>not</b> be refunded for searches made between 23 November to 27 November 2020, even for reports that are not found. Please click *OK* to agree and proceed.",0)#</cfsavecontent>
			<cfsavecontent variable="d">#Server.SVCLang("Search fees of $14 (excl. gst) will not be refunded for searches made between 23 November to 27 November 2020, even for reports that are not found. Please click *OK* to agree and proceed.",0)#</cfsavecontent>
			<cfsavecontent variable="e">#Server.SVCLang("Please be informed that there will be a change in the GIARMC system and vendor on <b>30 November 2020</b>. Search fees of $14 (excl. gst) will <b>not</b> be refunded for searches made between 23 November to 27 November 2020, even for reports that are not found.",0)#</cfsavecontent>
			<CFIF msgDisplay IS 1>
				<blockquote class=clsColorNote style="font-size:120%;padding:16px">
					<table align=center>
						<cfif msgMode IS 1><tr><td>#a#<td></tr></cfif>
						<cfif msgMode IS 2><tr><td>#b#<td></tr></cfif>
						<cfif msgMode IS 3><tr><td>#c#<td></tr></cfif>
						<cfif msgMode IS 4><tr><td>#d#<td></tr></cfif>
						<cfif msgMode IS 5><tr><td>#e#<td></tr></cfif>
					</table>
				</blockquote>
			<CFELSEIF msgDisplay IS 2>
				<cfif msgMode IS 1>#a#</cfif>
				<cfif msgMode IS 2>#b#</cfif>
				<cfif msgMode IS 3>#c#</cfif>
				<cfif msgMode IS 4>#d#</cfif>
				<cfif msgMode IS 5>#e#</cfif>
			</CFIF>
		</cfoutput>
	</CFIF>
</cffunction>
<CFSET Attributes.DS.MTRFN.DisableSGGIA_MSG=DisableSGGIA_MSG>

<cffunction name="ReportServer_Warning" hint="Generate warning message when reports are being accessed from production/backup server rather than reporting server." returntype="boolean" output="true">
<CFIF SESSION.VARS.LOCID IS 1 AND ListFindNoCase("www.merimen.com.my,merimen.com.my,203.115.213.27,malaysia2.merimen.com.my,203.115.213.26",CGI.SERVER_NAME)
		AND NOT Right(Application.ApplicationName,5) IS "train"
		AND NOT (IsDefined("SESSION.VARS") and isdefined("SESSION.VARS.SSOSETUPID") and SESSION.VARS.SSOSETUPID gt 0)>
	<cfif CGI.HTTPS EQ "ON">
		<cfset SECUREURL="https://">
	<cfelse>
		<cfset SECUREURL="http://">
	</cfif>
	<CFOUTPUT>
	<blockquote class=clsColorNote style="font-size:110%;padding:16px">
	REPORTS temporarily disabled on this server.<br><br>However, you could still generate your reports on the alternate reporting server. Please <a href="javascript:JSVCopenWin('#SECUREURL#report.merimen.com.my/claims/index.cfm','mrmreportwin')">Click Here</a> to goto the alternate reporting server.
	</blockquote>
	</CFOUTPUT>
	<CFRETURN true>
<CFELSE>
	<CFRETURN false>
</CFIF>
</cffunction>
<CFSET Attributes.DS.MTRFN.ReportServer_Warning=ReportServer_Warning>
<cffunction name="ReportQuery_BlockTime" hint="Block users from running some heavy reports during peak hours" returntype="any" output="true">
<CFIF listfindnocase("PROD",application.DB_MODE) GT 0>
	<CFQUERY NAME=q_trx DATASOURCE=#Request.SVCDSN#>
        declare @locdt datetime;
        select @locdt = dbo.fsvcdt(getdate(),<cfqueryparam cfsqltype="cf_sql_integer" value="#session.vars.locid#">,0);

        SELECT tm= CAST(CAST(DatePart(hh,@locdt) AS varchar)+REPLICATE('0',2-Len(CAST(DatePart(mi,@locdt) AS varchar)))+CAST(DatePart(mi,@locdt) AS varchar) AS int),dy=DatePart(dw,getdate())
    </CFQUERY>

	<!--- Peak hours cannot run: Mon-Fri 9am-12.00pm / 1.00pm-5.30pm --->
	<cfif (q_trx.dy GE 2 AND q_trx.dy LE 6)
		AND ((q_trx.tm GE 0900 AND q_trx.tm LE 1200) OR (q_trx.tm GE 1300 AND q_trx.tm LE 1730))>
		<cfoutput>
		<h4 align=center>#Server.SVCLang("Time-restriction has been temporarily implemented for Reporting Module for performance monitoring purpose.",9255)#
			<br>#Server.SVCLang("You are not able to access during this period:",9256)#
			<br><br>#Server.SVCLang("Mon-Fri: 9am-12pm and 1pm-5.30pm",0)#
			<br><br>#Server.SVCLang("We regret for any inconvenience caused.",9258)#
			<br><br><a href="javascript:window.history.go(-1)"><b>&lt;&lt; #Server.SVCLang("Click here to go back",11310)#</b></a>
		</h4>
		</cfoutput>
		<cfabort>
	</cfif>
</CFIF>
</cffunction>
<CFSET Attributes.DS.MTRFN.ReportQuery_BlockTime=ReportQuery_BlockTime>

<cffunction name="MTRPolDesc" hint="CF version of MTRPolDesc">
	<cfargument name="CASEID" type="numeric" required="true" hint="Case ID">
	<cfargument name="MODE" type="numeric" required="false" hint="Mode of function" default="0">
	<CFQUERY NAME="qGetPol" DATASOURCE="#Request.MTRDSN#">
			select b.iINSPOLID,b.iINSCLASSID,b.iBIZPOLID,b.iINSBUSID,b.iINSGCOID
			from trx0001 a WITH(NOLOCK)
			join trx0008 b WITH(NOLOCK) on b.iCASEID=a.iCASEID
			join biz2010 d WITH(NOLOCK) on d.icoid=b.iINSGCOID and d.iINSCLASSID=b.iINSCLASSID
			join biz2011 e WITH(NOLOCK) on e.iINSCLASSID=d.iINSCLASSID and e.iCOID=b.iINSGCOID
			WHERE b.iCASEID=<cfqueryparam value="#Arguments.CASEID#" cfsqltype="CF_SQL_INTEGER">
	</CFQUERY>
	<CFIF qGetPol.recordCount gt 0>
		<CFOUTPUT query="qGetPol">
		<CFIF Arguments.MODE EQ 0>
			<script>document.write(MTRPolDesc("#iINSCLASSID#","#iINSPOLID#","#iINSBUSID#",#serializejson(Request.DS.CO[iINSGCOID].PCLS1)#,#serializejson(Request.DS.CO[iINSGCOID].PCLS2)#,#serializejson(Request.DS.CO[iINSGCOID].PCLS3)#))</script>
			<cfreturn>
		<CFELSEIF Arguments.MODE EQ 1>
			<CFSET pA="">

			<CFIF iINSCLASSID NEQ "" AND StructKeyExists(Request.DS.CO[iINSGCOID].PCLS1,iINSCLASSID)>
				<CFSET p1 = Request.DS.CO[iINSGCOID].PCLS1[iINSCLASSID].NAME>
				<CFSET pA=p1>
			<CFELSE>
				<CFSET p1="">
			</CFIF>
			<CFIF iINSPOLID NEQ "" AND StructKeyExists(Request.DS.CO[iINSGCOID].PCLS2,iINSPOLID)>
				<CFSET p2 = Request.DS.CO[iINSGCOID].PCLS2[iINSPOLID].NAME>
				<CFSET pA=pA & " / " & p2>
			<CFELSE>
				<CFSET p2="">
			</CFIF>
			<CFIF iINSBUSID NEQ "" AND StructKeyExists(Request.DS.CO[iINSGCOID].PCLS3,iINSBUSID)>
				<CFSET p3 = Request.DS.CO[iINSGCOID].PCLS3[iINSBUSID].NAME>
				<CFSET pA=pA & " / " & p3>
			<CFELSE>
				<CFSET p3="">
			</CFIF>

			<CFRETURN pA>
		</CFIF>
		</CFOUTPUT>
	<CFELSE>
		<CFRETURN "">
	</CFIF>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRPolDesc=MTRPolDesc>

<cffunction name="MTRRemoveSuppGroup" hint="Remove supplementary documents (q_supp) from the q_docs query" output="false">
	<cfargument name="q_docs">
	<cfargument name="q_supp">
	<CFIF q_supp.recordCount gt 0>
		<cfquery name="q_docs" dbtype="query">
			select * from q_docs where iDOCID NOT IN (<cfqueryparam value="#Valuelist(q_supp.iDOCID)#" cfsqltype="CF_SQL_INTEGER" list="true">)
		</cfquery>
	</cfif>
	<cfreturn q_docs>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRRemoveSuppGroup=MTRRemoveSuppGroup>

<cffunction name="MTRGetSuppGroup" hint="Returns a struct of supplementary number given the maincaseid. Struct[CASEID]=Supplementary Number." output="false">
	<cfargument name="CASEID" type="numeric">
	<cfset var q_supptitle = "">
	<cfset var structSuppTitle = structNew()>

	<cfquery name="q_supptitle" datasource="#REQUEST.SVCDSN#">
	SELECT R.ICASEID,SUPPCNT=CASE WHEN R.iPCASEID=0 THEN 0 ELSE IsNull(R.siSUPPCNT,9999) END
		FROM TRX0001 R WITH (NOLOCK)
			INNER JOIN TRX0008 I WITH (NOLOCK) ON R.iCASEID=I.iCASEID AND I.siTPINS=0
		WHERE I.iMAINCASEID=<cfqueryparam cfsqltype="cf_sql_integer" value="#CASEID#">
		ORDER BY SUPPCNT,R.dtCRTON DESC
	</cfquery>

	<cfoutput query=q_supptitle>
		<cfif not structKeyExists(structSuppTitle,icaseid)>
			<cfset structSuppTitle[icaseid] = SUPPCNT>
		</cfif>
	</cfoutput>

	<cfreturn structSuppTitle>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGetSuppGroup=MTRGetSuppGroup>

<cffunction name="MTRFilterSuppGroup" hint="Returns a query of supplementary documents." output="false">
	<cfargument name="q_docs">
	<cfargument name="caseid">
	<cfargument name="EMCSDOCGROUP">
	<cfset var q_suppgroup = QueryNew("")>
	<cfset var structSuppGroup = structNew()>

	<cfquery name="q_suppgroup" dbtype="query">
		SELECT * FROM arguments.q_docs WHERE ilinkid is not null and ilinkid <> iobjid and ilinkid <> 0
		<CFIF Arguments.EMCSDOCGROUP>and IFINALBY<>1 AND ICRTBY<>1</cfif>
	</cfquery>

	<!--- do the ordering nicely so we can just use cfoutoput group --->
	<cfset structSuppGroup = REQUEST.DS.MTRFN.MTRGetSuppGroup(arguments.caseid)>

	<cfif q_suppgroup.recordCount gt 0>
		<cfset QueryAddColumn(q_suppgroup, "suppcnt", "Integer",[0])>
		<cfloop query="q_suppgroup">
			<cfif structKeyExists(structSuppGroup, ilinkid)>
				<cfset QuerySetCell(q_suppgroup, 'suppcnt', structSuppGroup[ilinkid], CurrentRow)>
			</cfif>
		</cfloop>
		<cfquery name="q_suppgroup" dbtype="query">
			SELECT * FROM q_suppgroup order by suppcnt asc, dtfinalon asc
		</cfquery>
	</cfif>

	<cfreturn q_suppgroup>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRFilterSuppGroup=MTRFilterSuppGroup>

<cffunction name="MTResignature" hint="Indicates whether claims doc/file needs to be e-signed or not (24879). " output="false">
	<cfargument name="DOCDEFID" type="numeric">
	<cfargument name="DOMAINID" type="numeric">
	<cfargument name="OBJID" type="numeric">
	<cfargument name="DOSIGN" type="numeric" default="0" hint="indicate whether just checking to sign or to do the signature">

	<cfargument name="DOCSTAT" type="numeric" default="0">
	<cfargument name="DOCID" type="numeric" default="0" hint="if docid is 0, pass in the linkid / crtcosecpos / crtcorole">
	<cfargument name="LINKID" type="numeric" default="0">
	<cfargument name="CRTCOSECPOS" type="numeric" default="0">
	<cfargument name="CRTCOROLE" type="numeric" default="0">
	<cfargument name="CONTENT" type="string" default="">


	<cfset var flag = false>
	<cfset var PDFOBJ = "">
	<cfset var RETOBJ = "">
	<cfset var MODRESULT = "">
	<cfset var SVCDOCORIGHASH = "">
	<cfset var SVCDOCLTRDESC = "">
	<cfset var param = "">
	<cfset var ErrorCode = "">
	<cfset var ErrorReason = "">

	<cfif Arguments.CONTENT eq "" and IsDefined("form.SVCDOCLTRCONTENT")>
		<cfset Arguments.CONTENT = FORM.SVCDOCLTRCONTENT>
	</cfif>
	<cfif Arguments.CONTENT eq "" and IsDefined("form.SVCDOCORIGHASH")>
		<cfset SVCDOCORIGHASH = FORM.SVCDOCORIGHASH>
	</cfif>
	<cfif Arguments.CONTENT eq "" and IsDefined("form.SVCDOCLTRDESC")>
		<cfset SVCDOCLTRDESC = FORM.SVCDOCLTRDESC>
	</cfif>

	<cfif dosign eq 0>

		<cfif session.vars.gcoid eq 1510001 and listfindnocase("9431,28",arguments.docdefid) gt 0><!--- Guarantee Letter and Report for Insurer.  --->
			<cfset flag=true>
		</cfif>

		<cfreturn flag>

	<cfelse>
		<cfset pages = 1>
		<!--- create the PDF --->
		<cfmodule TEMPLATE="#request.apppath#claims/CustomTags/MTRAR_StyleReplace.cfm" content="#Arguments.CONTENT#" varmodresult="Arguments.CONTENT" DOMAINID="#Arguments.DOMAINID#" DOCDEFID="#Arguments.DOCDEFID#" GCOID=1510001>

		<cfif session.vars.gcoid eq 1510001 and arguments.docdefid eq 28>
			<cfset totalrow = ArrayLen(rematchNoCase('<tr',Arguments.CONTENT))>

			<cfset rowsperpage = 59>
			<cfif totalrow gt rowsperpage and (totalrow mod rowsperpage) gt 0>
				<cfset pages = ceiling(totalrow / rowsperpage)>
				<cfset lastpagerows = totalrow - (rowsperpage * (pages-1) ) >
				<cfset str = "<br><br><br><br><br>">
				<cfloop from=1 to=#59-min(lastpagerows,59)# index=i>
					<cfset str &= "<br>">
				</cfloop>
				<cfset arguments.content = replacenocase(arguments.content,'<div class="PDF_ESIG" style="page-break-inside:avoid;position:fixed;bottom:0;">','#str#<div class="PDF_ESIG" style="page-break-inside:avoid;">',"one")>
			</cfif>
		</cfif>

		<!--- create the PDF --->
		<cfinvoke component="#Request.APPPATHCFC#services.cfc.EPLGenPDF" method="HTMtoPDF" content="#Arguments.CONTENT#" returnvariable="PDFOBJ" replaceImgPath="true" wkhtmltopdf=true openfont=true><!--- OUTPUTFILE="#PDFFILEPATH#" --->

		<!--- not everyone's DEV are set up to support the e-signature web service module.
			  - Need to install SSL certificate to CFIDE and
			  - only can sign from Office IP address. --->
		<!--- #33100 No include e-signature on VN MSIG for Insurer Rpt-for-Repairer--->
		<cfif Application.DB_MODE eq "DEV" OR Application.APPDEVMODE eq 1 OR
		(session.vars.gcoid eq 1510001 and arguments.docdefid eq 28)>
			<!--- just save the PDF file without signing --->
			<cfset RETOBJ = structNew()>
			<cfset RETOBJ.STATUS_FLAG = true>
			<cfset RETOBJ.SIGNED_STRUCT = structNew()>
			<cfset RETOBJ.SIGNED_STRUCT.0 = APPLICATION.TMPDIR & createUUID() & "_SIGN.PDF">
			<cffile action="write" file="#RETOBJ.SIGNED_STRUCT.0#" output="#ToBinary(local.PDFOBJ)#">
		<cfelse>
			<cfif session.vars.gcoid eq 1510001>
				<cfif arguments.docdefid eq 9431>
					<cfset param = "30,20,180,240|1"><!--- 150x250 --->
				<cfelseif arguments.docdefid eq 28>
					<cfset param = "70,30,200,130|#pages#"><!--- 150x120 --->
				</cfif>
			</cfif>
			<!--- Pass into signer --->
			<cfmodule template="#Request.logpath#index.cfm" FUSEBOX=SVCdoc FUSEACTION=ACT_DOCSIGN NOHEADER DOMAINID=#arguments.DOMAINID# OBJID=#arguments.OBJID# SIGN_TYPE=4 GCOID=#SESSION.VARS.GCOID# PDFOBJ=#PDFOBJ# MODRESULT=RETOBJ PARAM=#PARAM#>
		</cfif>

		<cfif NOT RETOBJ.STATUS_FLAG>
			<cfset ErrorCode = RETOBJ.FAIL_STRUCT.0.CODE>
			<cfset ErrorReason = RETOBJ.FAIL_STRUCT.0.REASON>

			<!--- audit trigger (itatypeid=123) for custom notifications.  --->
			<CFSTOREDPROC PROCEDURE="sspFOBJAudit" DATASOURCE="#Request.MTRDSN#" RETURNCODE="YES">
				<CFPROCPARAM TYPE="IN" DBVARNAME=@ITATYPEID VALUE="123" CFSQLTYPE="CF_SQL_INTEGER">
				<CFPROCPARAM TYPE="IN" DBVARNAME=@ai_auditmode VALUE="2" CFSQLTYPE="CF_SQL_INTEGER">
				<CFPROCPARAM TYPE="IN" DBVARNAME=@ai_usid VALUE="#SESSION.VARS.USID#" CFSQLTYPE="CF_SQL_INTEGER">
				<CFPROCPARAM TYPE="IN" DBVARNAME=@ICRTCOROLE NULL="YES" CFSQLTYPE="CF_SQL_INTEGER">
				<CFPROCPARAM TYPE="IN" DBVARNAME=@ICRTCOSECPOS NULL="YES" CFSQLTYPE="CF_SQL_INTEGER">
				<CFPROCPARAM TYPE="IN" DBVARNAME=@DTCURDT NULL="YES" CFSQLTYPE="CF_SQL_TIMESTAMP">
				<CFPROCPARAM TYPE="IN" DBVARNAME=@IDOMAINID VALUE="#arguments.DOMAINID#" CFSQLTYPE="CF_SQL_INTEGER">
				<CFPROCPARAM TYPE="IN" DBVARNAME=@IOBJID VALUE="#arguments.OBJID#" CFSQLTYPE="CF_SQL_INTEGER">
				<CFPROCPARAM TYPE="IN" DBVARNAME=@ILINKID VALUE="#arguments.OBJID#" CFSQLTYPE="CF_SQL_INTEGER">
				<CFPROCPARAM TYPE="IN" DBVARNAME=@VATAREMARKS VALUE="#ErrorReason#" CFSQLTYPE="CF_SQL_VARCHAR">
				<CFPROCPARAM TYPE="IN" DBVARNAME=@IPARAM1 VALUE="#ErrorCode#" CFSQLTYPE="CF_SQL_INTEGER"><!--- Error Code --->
			</CFSTOREDPROC>

			<cfthrow TYPE="EX_SIG" errorcode="SIG-DOCLTREDIT(#ErrorCode#) [#ErrorReason#]">
		</cfif>

		<cfif Arguments.DOCID eq 0><!--- file never created before --->
			<cfmodule template="#request.apppath#services/index.cfm" FUSEBOX=SVCdoc FUSEACTION=ACT_DOCEDIT NOHEADER
				DOMAINID=#Arguments.DOMAINID# OBJID=#Arguments.OBJID# LINKID=#Arguments.LINKID# CRTCOSECPOS=#Arguments.CRTCOSECPOS# CRTCOROLE=#Arguments.CRTCOROLE#
				DOCDEFID=#Arguments.DOCDEFID#
				DOCSTAT=#Arguments.DOCSTAT+32# COPYFILE="#RETOBJ.SIGNED_STRUCT.0#"
				PRESERVE_ORIGINAL="1"
				DOCDESC=#SVCDOCltrDesc# ORIGHASH=#SVCDOCORIGHASH#><!---DOCDESC_INCREMENTAL_SUFFIX=#DOCDESC_INCREMENTAL_SUFFIX#--->
		<cfelse>
			<cfmodule template="#request.apppath#services/index.cfm" FUSEBOX=SVCdoc FUSEACTION=ACT_DOCEDIT NOHEADER
				DOCID=#Arguments.DOCID#
				DOCSTAT=#Arguments.DOCSTAT+32# COPYFILE="#RETOBJ.SIGNED_STRUCT.0#"
				PRESERVE_ORIGINAL="1"
				DOCDESC=#SVCDOCltrDesc# ORIGHASH=#SVCDOCORIGHASH#><!---DOCDESC_INCREMENTAL_SUFFIX=#DOCDESC_INCREMENTAL_SUFFIX#--->
		</cfif>

		<cfreturn MODRESULT.DOCID>
	</cfif>

</cffunction>
<CFSET Attributes.DS.MTRFN.MTResignature=MTResignature>


<cffunction name="MTRblockComposeMail" hint="Block from composing e-mail if no e-mail address" output="true"><!--- 25112 --->
	<cfargument name="getmsg" default=false>
	<cfset var msg = "">
	<cfif getmsg>
		<cfsavecontent variable="msg">
			<blockquote id=COMPOSEMAILWARN class=clsColorWarning ><br>
			<cfoutput>
			#Server.SVClang("Unable to Compose Mail")#<br>&nbsp;<br>
			#Server.SVClang("You must have an e-mail address to use the compose mail feature. Kindly contact your local IT support to update your user account with your e-mail address.")#
			<br>&nbsp;<br>
			</cfoutput>
			</blockquote>
		</cfsavecontent>
		<cfreturn msg>
	<cfelse>
		<cfif session.vars.gcoid eq 200045>
			<cfquery name="q_getusr" datasource="#request.MTRDSN#">
			select vaemail = isNULL(ltrim(rtrim(vaemail)),'') from sec0001 with (nolock) where iusid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.vars.usid#">
			</cfquery>
			<cfif q_getusr.vaemail eq "">
				<cfreturn true>
			</cfif>
		</cfif>
		<cfreturn false>
	</cfif>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRblockComposeMail=MTRblockComposeMail>

<cffunction name="MTRformatPolicyNo" hint="Format the display of policy no. Mainly for the purpose of THTMI wants to strip off leading zeros in policy no." output="false">
<cfargument name="str" type=string required=yes>
<cfargument name="gcoid" type=string required=no default=#SESSION.VARS.GCOID#>
<cfset var polno=arguments.str>
<cfset var tmp_polno="">
<CFIF arguments.gcoid IS 1101177>
	<cfset tmp_polno=ListFirst(polno,"-")>
	<cfloop list="#ListRest(polno,"-")#" delimiters="-" index=z>
		<cfset tmp_polno &= "-" & Val(z)>
	</cfloop>
	<cfreturn HTMLEditFormat(Trim(tmp_polno))>
<CFELSE>
	<cfreturn HTMLEditFormat(Trim(polno))>
</CFIF>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRformatPolicyNo=MTRformatPolicyNo>


<cffunction name="ODWSChk" hint="Returns 1 if legacy OD WS. 0 otherwise." output="false">
<cfargument name="caseid" type="any" required=yes>
<cfargument name="claimtype" type="any" default="">
<cfargument name="locid" type="any" default="">
<cfargument name="insgcoid" type="any" default="">
	<cfset var Return = 0>
	<cfif Arguments.caseid GT 0>
		<cfquery NAME=q_odwschk DATASOURCE=#Request.MTRDSN#>
			SELECT retval = dbo.fODWSChk(RTRIM(a.aCLAIMTYPE),a.iLOCID,b.iINSGCOID)
			FROM TRX0001 a WITH (NOLOCK) INNER JOIN TRX0008 b WITH (NOLOCK) on a.icaseid=b.icaseid
			WHERE a.icaseid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.caseid#">
		</CFQUERY>
		<cfif q_odwschk.recordCount eq 0>
			<cfset Return = 0>
		<cfelse>
			<cfset Return = q_odwschk.retval>
		</cfif>
	<cfelse>
		<cfif ListFindNoCase("2,10",arguments.locid) and ListFindNoCase("WS,OD WS", arguments.claimtype) and arguments.insgcoid NEQ 1000001>
			<cfset Return = 1>
		</cfif>
	</cfif>
	<cfreturn Return>
</cffunction>
<CFSET Attributes.DS.MTRFN.ODWSChk=ODWSChk>


<cffunction access="public" name="MTRGSTWarning" returntype="string" output=true description="">
    <cfargument name="currGST" type="string" required="true">
    <cfargument name="customtext" type="string" required="false" default="Invoice">

    <cfset locale = request.ds.locales[session.vars.locid]>
	<CFSET VATTAXNAME=Server.SVClang(LOCALE.VATTAXNAME,LOCALE.VATTAXNAME_LID)>
	<CFIF VATTAXNAME IS "">
		<CFSET VATTAXNAME="GST">
	</CFIF>
    <cfif isnumeric(arguments.currGST) and locale.vattaxpc neq arguments.currGST>
        <blockquote class="clsColorNote" style="background-color:red;color:white">
            <br>
            <div> #Server.SVClang("Alert: {0} {1} differs ({2}%) from Standard {1} ({3}%)",0,0,arguments.customtext,VATTAXNAME,arguments.currGST,locale.vattaxpc)# </div>
            <br>
        </blockquote>
    </cfif>
</cffunction>
<CFSET Attributes.DS.MTRFN.mtrgstwarning=mtrgstwarning>


<cffunction access="public" name="MTRGSTcalcmodel" returntype="string" output=false description="">
    <cfargument name="caseid" type="numeric" required="true">
    <cfargument name="acotype" type="string" required="false" default="I">
    <cfquery name="qry_calc" datasource="#request.mtrdsn#">
    select sicalcmodel
    from trx0035 iest with (nolock)
    where iest.ilcaseid =  <cfqueryparam value=#arguments.caseid# CFSQLType="cf_sql_integer" null="no">
    and iest.acotype = <cfqueryparam value=#arguments.acotype# CFSQLType="cf_sql_char" null="no">
    </cfquery>

    <cfif qry_calc.sicalcmodel eq 5>
        <cfset var result = "SST">
    <cfelse>
        <cfset var result = "GST">
    </cfif>
    <cfreturn result>
</cffunction>
<CFSET Attributes.DS.MTRFN.mtrgstcalcmodel=mtrgstcalcmodel>

<cffunction access="public" name="MTRGSTsupportingConditions" returntype="string" output=false description="">
    <cfargument name="caseid" type="numeric" required="true">
	<cfargument name="orgtype" type="string" required="FALSE" default='#session.vars.orgtype#'>

    <cfquery name="qry_test" datasource="#request.mtrdsn#">
        select
            rep.aclaimtype
            ,rep.icoid as repcoid
            ,rep.sisettletype
            ,ins.siofrtype
            ,nvattaxpc=isnull(iest.nvattaxpc,aest.nvattaxpc)
            ,details.siinsuredgstreg
            ,details.siTPGSTReg

        from trx0001 rep WITH (NOLOCK)
        inner join trx0008 ins WITH (NOLOCK) on ins.icaseid = rep.icaseid
        left join trx0035 iest WITH (NOLOCK) on iest.ilcaseid = rep.icaseid and iest.acotype = 'i'
        left join trx0035 aest WITH (NOLOCK) on aest.ilcaseid = rep.icaseid and aest.acotype = 'a'
        inner join trx0055b details WITH (NOLOCK) on details.icaseid = rep.icaseid
        where rep.icaseid = <cfqueryparam value=#arguments.caseid# CFSQLType="cf_sql_integer" null="no">
    </cfquery>

    <cfset var result = false>

    <cfif qry_test.nvattaxpc eq 0 and listfindnocase("OD,OD KFK,MNT,OD TAC,OD MNT,OD TAC,OD TFR,WS,OD WS,OD EXW",trim(qry_test.aclaimtype)) gt 0>

        <cfset mygstcheck = request.ds.fn.SVCgetcovateff(qry_test.repcoid)>
        <cfset isvateff = mygstcheck.isvateff>

        <!--- offer type: claims (cost of repair, contract, major struct rep) + GST registrant --->
        <!--- offer type: cash up front,  GST r --->

        <cfset result = ((listfindnocase("4,2,6",qry_test.siofrtype) gt 0 and arguments.orgtype eq 'i') or arguments.orgtype neq 'i')
            	and isvateff>

    <cfelseif qry_test.nvattaxpc eq 0 and listfindnocase("NM EXW,TP,TP KFK",trim(qry_test.aclaimtype)) gt 0>
        <cfset result = true>

    <cfelseif qry_test.nvattaxpc GT 0>
    	<cfset result = true>

    </cfif>

    <cfreturn result>
</cffunction>

<CFSET Attributes.DS.MTRFN.MTRGSTsupportingConditions=MTRGSTsupportingConditions>

<cffunction access="public" name="MTRrecalculateflags" returntype="struct" output=false description="">
    <cfargument name="k" type="string" required="true">
    <cfset var test = {}>
    <cfset test.gst6 = {recalc= 1,   norecalc= 2}>
    <cfset test.gst0 = {recalc= 101, norecalc= 102}>
    <cfset test.sst6 = {recalc= 201, norecalc= 202}>

    <cfreturn structKeyExists(test,arguments.k)? test[arguments.k]: test["gst6"]>
</cffunction>
<CFSET Attributes.DS.MTRFN.mtrrecalculateflags=mtrrecalculateflags>

<cffunction access="public" name="MTRrecalculate" returntype="string" output=false description="">
    <cfargument name="doRecalc" type="boolean" required="true">

    <cfargument name="caseid" type="numeric" required="true">
    <cfargument name="targetSST" type="numeric" required="true">
    <cfargument name="targetGST" type="numeric" required="true">
    <cfargument name="auditremarks" type="string" required="true">
    <cfargument name="targetRecalc" type="numeric" required="true" default=1>
    <cfargument name="corole" type="numeric" required="true" default=2>
    <cfargument name="sicalcmodel" type="numeric" required="false" default=-1>

    <CFTRANSACTION ACTION="BEGIN">
    <CFTRY>
        <cfquery name="qry_thatcham" datasource="#request.mtrdsn#">
            select
                 vaSrcLbRef   as SrcLbRef
                ,vaLbProjDesc as LbProjDesc
                ,isnull(mnTOTLAB,0)       as labour
                ,isnull(mnTOTPAINTWORK,0) as paintworklabour
                ,isnull(nvattaxpc,0) as nvattaxpc
                ,isnull(sisvctaxpc,0) as sisvctaxpc
                ,sicalcmodel
                ,mnTOTRP
                ,mnTOTMT
                ,mnTOTPN
                ,mnTOTPA
            from trx0035 with (nolock)
            where
                ilcaseid = <cfqueryparam value=#arguments.caseid# CFSQLType="cf_sql_integer" null="no">
                and acotype = 'I'
        </cfquery>
        <cfif arguments.targetSST eq -1> <cfset arguments.targetSST = qry_thatcham.sisvctaxpc> </cfif>
        <cfif arguments.targetGST eq -1> <cfset arguments.targetGST = qry_thatcham.nvattaxpc> </cfif>
        <cfif arguments.sicalcmodel eq -1> <cfset arguments.sicalcmodel = qry_thatcham.sicalcmodel> </cfif>

        <cfif arguments.doRecalc>
            <!--- begin shiu: capture recent values of estcalcall, notably:  --->
            <CFSTOREDPROC PROCEDURE="sspFOBJLogMultiUpdate" DATASOURCE="#Request.MTRDSN#" RETURNCODE="YES">
                <cfprocparam type = "In" dbvarname = "@asi_mode"         cfsqltype = "cf_sql_integer"   null =no value="0">
                <cfprocparam type = "In" dbvarname = "@ai_logid"         cfsqltype = "cf_sql_integer"   null =no value="0">
                <cfprocparam type = "In" dbvarname = "@ai_usid"          cfsqltype = "cf_sql_integer"   null =no value="#session.vars.usid#">
                <cfprocparam type = "In" dbvarname = "@ai_corole"        cfsqltype = "cf_sql_integer"   null =no value=#arguments.corole#>
                <cfprocparam type = "In" dbvarname = "@asi_logtype"      cfsqltype = "cf_sql_smallint"  null =no value="700">
                <cfprocparam type = "In" dbvarname = "@ai_domideid"      cfsqltype = "cf_sql_integer"   null =no value="1">
                <cfprocparam type = "In" dbvarname = "@ai_objid"         cfsqltype = "cf_sql_integer"   null =no value="#arguments.caseid#">
                <cfprocparam type = "In" dbvarname = "@asi_skipseccheck" cfsqltype = "cf_sql_smallint"  null =no value="1">
                <cfprocparam type = "In" dbvarname = "@ai_gcoid"         cfsqltype = "cf_sql_integer"   null =no value="#session.vars.orgid#">
                <cfprocparam type = "In" dbvarname = "@asi_1"            cfsqltype = "cf_sql_smallint"  null =yes>
                <cfprocparam type = "In" dbvarname = "@asi_2"            cfsqltype = "cf_sql_smallint"  null =yes>
                <cfprocparam type = "In" dbvarname = "@asi_3"            cfsqltype = "cf_sql_smallint"  null =yes>
                <cfprocparam type = "In" dbvarname = "@asi_4"            cfsqltype = "cf_sql_smallint"  null =yes>
                <cfprocparam type = "In" dbvarname = "@asi_5"            cfsqltype = "cf_sql_smallint"  null =yes>
                <cfprocparam type = "In" dbvarname = "@as_1"             cfsqltype = "cf_sql_varchar"   null =no value="#qry_thatcham.srclbref#">
                <cfprocparam type = "In" dbvarname = "@as_2"             cfsqltype = "cf_sql_varchar"   null =yes>
                <cfprocparam type = "In" dbvarname = "@as_3"             cfsqltype = "cf_sql_varchar"   null =yes>
                <cfprocparam type = "In" dbvarname = "@as_4"             cfsqltype = "cf_sql_varchar"   null =yes>
                <cfprocparam type = "In" dbvarname = "@as_5"             cfsqltype = "cf_sql_varchar"   null =yes>
                <cfprocparam type = "In" dbvarname = "@as_6"             cfsqltype = "cf_sql_varchar"   null =yes>
                <cfprocparam type = "In" dbvarname = "@as_7"             cfsqltype = "cf_sql_varchar"   null =yes>
                <cfprocparam type = "In" dbvarname = "@as_8"             cfsqltype = "cf_sql_varchar"   null =yes>
                <cfprocparam type = "In" dbvarname = "@as_9"             cfsqltype = "cf_sql_varchar"   null =yes>
                <cfprocparam type = "In" dbvarname = "@ax_1"             cfsqltype = "cf_sql_nvarchar"  null =no value="#qry_thatcham.lbprojdesc#">
                <cfprocparam type = "In" dbvarname = "@ax_2"             cfsqltype = "cf_sql_nvarchar"  null =yes>
                <cfprocparam type = "In" dbvarname = "@ax_3"             cfsqltype = "cf_sql_nvarchar"  null =yes>
                <cfprocparam type = "In" dbvarname = "@ax_4"             cfsqltype = "cf_sql_nvarchar"  null =yes>
                <cfprocparam type = "In" dbvarname = "@ax_5"             cfsqltype = "cf_sql_nvarchar"  null =yes>
                <cfprocparam type = "In" dbvarname = "@ax_6"             cfsqltype = "cf_sql_nvarchar"  null =yes>
                <cfprocparam type = "In" dbvarname = "@ax_7"             cfsqltype = "cf_sql_nvarchar"  null =yes>
                <cfprocparam type = "In" dbvarname = "@ai_1"             cfsqltype = "cf_sql_integer"   null =yes>
                <cfprocparam type = "In" dbvarname = "@ai_2"             cfsqltype = "cf_sql_integer"   null =yes>
                <cfprocparam type = "In" dbvarname = "@ai_3"             cfsqltype = "cf_sql_integer"   null =yes>
                <cfprocparam type = "In" dbvarname = "@ai_4"             cfsqltype = "cf_sql_integer"   null =yes>
                <cfprocparam type = "In" dbvarname = "@ai_5"             cfsqltype = "cf_sql_integer"   null =yes>
                <cfprocparam type = "In" dbvarname = "@ai_6"             cfsqltype = "cf_sql_integer"   null =yes>
                <cfprocparam type = "In" dbvarname = "@ai_7"             cfsqltype = "cf_sql_integer"   null =yes>
                <cfprocparam type = "In" dbvarname = "@adt_1"            cfsqltype = "cf_sql_timestamp" null =yes>
                <cfprocparam type = "In" dbvarname = "@adt_2"            cfsqltype = "cf_sql_timestamp" null =yes>
                <cfprocparam type = "In" dbvarname = "@adt_3"            cfsqltype = "cf_sql_timestamp" null =yes>
                <cfprocparam type = "In" dbvarname = "@adt_4"            cfsqltype = "cf_sql_timestamp" null =yes>
                <cfprocparam type = "In" dbvarname = "@adt_5"            cfsqltype = "cf_sql_timestamp" null =yes>
                <cfprocparam type = "In" dbvarname = "@adt_6"            cfsqltype = "cf_sql_timestamp" null =yes>
                <cfprocparam type = "In" dbvarname = "@adt_7"            cfsqltype = "cf_sql_timestamp" null =yes>
                <cfprocparam type = "In" dbvarname = "@adt_8"            cfsqltype = "cf_sql_timestamp" null =yes>
                <cfprocparam type = "In" dbvarname = "@amn_1"            cfsqltype = "cf_sql_money"     null =no value="#qry_thatcham.labour#">
                <cfprocparam type = "In" dbvarname = "@amn_2"            cfsqltype = "cf_sql_money"     null =no value="#qry_thatcham.paintworklabour#">
            </CFSTOREDPROC>

            <!--- slot in value --->
            <cfif structkeyExists(form,"totlab") and form.totlab gt 0
                and structkeyExists(form,"totpalab") and form.totpalab gt 0
                and form.totlab gt 0 and form.totpalab gt 0>

                <CFSTOREDPROC PROCEDURE="sspESTLog" DATASOURCE="#Request.MTRDSN#" RETURNCODE="YES">
                    <cfprocparam type = "In" dbvarname ="@ai_usid"            cfsqltype = "cf_sql_integer"   null =no value=#session.vars.usid#>
                    <cfprocparam type = "In" dbvarname ="@ai_caseid"          cfsqltype = "cf_sql_integer"   null =no value=#arguments.caseid#>
                    <cfprocparam type = "In" dbvarname ="@aa_cotype"          cfsqltype = "cf_sql_char"      null =no value="I">
                    <cfprocparam type = "In" dbvarname ="@as_action"          cfsqltype = "cf_sql_varchar"   null =no value="THATCHAM">
                    <cfprocparam type = "In" dbvarname ="@as_SrcLbRef"        cfsqltype = "cf_sql_varchar"   null =no value="#qry_thatcham.SrcLbRef#">
                    <cfprocparam type = "In" dbvarname ="@as_LbProjDesc"      cfsqltype = "cf_sql_varchar"   null =no value="#qry_thatcham.LbProjDesc#">
                    <cfprocparam type = "In" dbvarname ="@amn_totlab"         cfsqltype = "cf_sql_money"     null =no value=#request.ds.fn.SVCnumLOCtoDB(totlab)#  >
                    <cfprocparam type = "In" dbvarname ="@amn_totpaintwork"   cfsqltype = "cf_sql_money"     null =no value=#request.ds.fn.SVCnumLOCtoDB(totpalab)#>
                </CFSTOREDPROC>
            </cfif>

            <!--- enable log --->
            <cfquery name="qry_enable" datasource="#request.mtrdsn#">
                update TRX0035_LOG
                    set sistatus = 1
                where
                ilcaseid = <cfqueryparam value=#arguments.caseid# CFSQLType="cf_sql_integer" null="no">
                and acotype = <cfqueryparam value="I" CFSQLType="cf_sql_char" null="no">
                and vaaction = 'THATCHAM'
            </cfquery>


            <!--- end shiu: capture recent values of estcalcall --->

            <cfquery name="qry_checkoverride" datasource="#request.mtrdsn#">
                select mntotall2,siTOTOVERRIDE
                from trx0035 where ilcaseid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.caseid#"> and acotype = 'I'
            </cfquery>

            <cfquery name="qry_test" datasource="#request.mtrdsn#">
                select nvattaxpc,sisvctaxpc
                from trx0035 iest with (nolock)
                where iest.ilcaseid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.caseid#">
                and iest.acotype = 'i'
            </cfquery>

            <cfset svctaxpc = arguments.targetSST>
            <cfset vattaxpc = arguments.targetGST>
            <cfset isDiffsvctaxpc = svctaxpc neq qry_test.sisvctaxpc>
            <cfset isDiffnvattaxpc = vattaxpc neq qry_test.nvattaxpc>

            <cfset rem = "">
            <cfif isdiffsvctaxpc > <cfset rem = rem&"Service Tax #qry_test.sisvctaxpc#% --> #svctaxpc#%; "> </cfif>
            <cfif isdiffnvattaxpc> <cfset rem = rem&"GST #qry_test.nvattaxpc#% --> #vattaxpc#%; "> </cfif>
            <cfif structkeyexists(arguments,"auditremarks") and len(arguments.auditremarks) gt 0>
                <cfset rem=rem&"#auditremarks#">
            </cfif>

            <cfif qry_checkoverride.recordcount eq 0>
                <cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCSTAT" EXTENDEDINFO="#Server.SVClang("Insurer has not offered.",25495)#">
            </cfif>
            <cfset override = qry_checkoverride.sitotoverride>
            <cfset overrideamt = qry_checkoverride.mntotall2>

            <!--- update service tax --->
            <CFSTOREDPROC PROCEDURE="sspESTSummaryEdit2" DATASOURCE="#Request.MTRDSN#" RETURNCODE="YES">
            <cfprocparam type = "In" dbvarname = "@ai_caseid"    cfsqltype= "cf_sql_integer"  null =no value="#arguments.caseid#">
            <cfprocparam type = "In" dbvarname = "@aa_cotype"    cfsqltype= "cf_sql_char"     null =no value="I">
            <cfprocparam type = "In" dbvarname = "@as_userid"    cfsqltype= "cf_sql_varchar"  null =no value="#session.vars.userid#">
            <cfprocparam type = "In" dbvarname = "@amn_totlab"   cfsqltype= "cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_totplab"  cfsqltype= "cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_rpovr"    cfsqltype= "cf_sql_money"    null =#len(qry_thatcham.mnTOTRP) eq 0# value=#qry_thatcham.mnTOTRP#>
            <cfprocparam type = "In" dbvarname = "@amn_mtovr"    cfsqltype= "cf_sql_money"    null =#len(qry_thatcham.mnTOTMT) eq 0# value=#qry_thatcham.mnTOTMT#>
            <cfprocparam type = "In" dbvarname = "@amn_pnovr"    cfsqltype= "cf_sql_money"    null =#len(qry_thatcham.mnTOTPN) eq 0# value=#qry_thatcham.mnTOTPN#>
            <cfprocparam type = "In" dbvarname = "@amn_paovr"    cfsqltype= "cf_sql_money"    null =#len(qry_thatcham.mnTOTPA) eq 0# value=#qry_thatcham.mnTOTPA#>
            <cfprocparam type = "In" dbvarname = "@amn_cpovr"    cfsqltype= "cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@asi_svctaxpc" cfsqltype= "cf_sql_smallint" null =no value="#arguments.targetsst#" scale=2>
            </CFSTOREDPROC>
            <CFSET returncode=CFSTOREDPROC.STATUSCODE>
            <CFIF returncode LTE 0>
                <CFTHROW TYPE="EX_DBERROR" ErrorCode="Transition/SVCTAX(#returncode#)">
            </CFIF>

            <!--- update vattax tax --->
            <CFSTOREDPROC PROCEDURE="sspESTSummaryEdit1" DATASOURCE="#Request.MTRDSN#" RETURNCODE="YES">
            <cfprocparam type = "In" dbvarname = "@ai_caseid"         cfsqltype="cf_sql_integer"  null=no value="#attributes.caseid#">
            <cfprocparam type = "In" dbvarname = "@aa_cotype"         cfsqltype="cf_sql_char"     null=no value="I">
            <cfprocparam type = "In" dbvarname = "@as_userid"         cfsqltype="cf_sql_varchar"  null=no value=#session.vars.userid#>
            <cfprocparam type = "In" dbvarname = "@as_dupcotype"      cfsqltype="cf_sql_varchar"  null=yes>
            <cfprocparam type = "In" dbvarname = "@amn_totapprv"      cfsqltype="cf_sql_money"    null=#override neq 1# value="#overrideamt#">
            <cfprocparam type = "In" dbvarname = "@asi_totoverride"   cfsqltype="cf_sql_smallint" null=yes>
            <cfprocparam type = "In" dbvarname = "@ai_patypeid"       cfsqltype="cf_sql_integer"  null=yes>
            <cfprocparam type = "In" dbvarname = "@asi_useoven"       cfsqltype="cf_sql_smallint" null=yes>
            <cfprocparam type = "In" dbvarname = "@asi_labtypemask"   cfsqltype="cf_sql_smallint" null=yes>
            <cfprocparam type = "In" dbvarname = "@asi_labtype"       cfsqltype="cf_sql_smallint" null=yes>
            <cfprocparam type = "In" dbvarname = "@amn_dexcess"       cfsqltype="cf_sql_money"    null=yes>
            <cfprocparam type = "In" dbvarname = "@amn_dexcesswaived" cfsqltype="cf_sql_money"    null=yes>
            <cfprocparam type = "In" dbvarname = "@ai_dxsmode"        cfsqltype="cf_sql_integer"  null=yes>
            <cfprocparam type = "In" dbvarname = "@asi_dxsclmpc"      cfsqltype="cf_sql_smallint" null=yes>
            <cfprocparam type = "In" dbvarname = "@amn_dxsmin"        cfsqltype="cf_sql_money"    null=yes>
            <cfprocparam type = "In" dbvarname = "@amn_d2f"           cfsqltype="cf_sql_money"    null=yes>
            <cfprocparam type = "In" dbvarname = "@ava_d2fremarks"    cfsqltype="cf_sql_varchar"  null=yes>
            <cfprocparam type = "In" dbvarname = "@asi_dunderinsured" cfsqltype="cf_sql_smallint" null=yes>
            <cfprocparam type = "In" dbvarname = "@amn_dsuminsured"   cfsqltype="cf_sql_money"    null=yes>
            <cfprocparam type = "In" dbvarname = "@amn_dmktvalue"     cfsqltype="cf_sql_money"    null=yes>
            <cfprocparam type = "In" dbvarname = "@asi_bttrperc"      cfsqltype="cf_sql_smallint" null=yes>
            <cfprocparam type = "In" dbvarname = "@amn_bttrval"       cfsqltype="cf_sql_money"    null=yes>
            <cfprocparam type = "In" dbvarname = "@asi_duncertainty"  cfsqltype="cf_sql_smallint" null=yes>
            <cfprocparam type = "In" dbvarname = "@amn_duncertainty"  cfsqltype="cf_sql_money"    null=yes>
            <cfprocparam type = "In" dbvarname = "@asi_tl"            cfsqltype="cf_sql_smallint" null=yes>
            <cfprocparam type = "In" dbvarname = "@asi_dmglevel"      cfsqltype="cf_sql_smallint" null=yes>
            <cfprocparam type = "In" dbvarname = "@asi_retwreck"      cfsqltype="cf_sql_smallint" null=yes>
            <cfprocparam type = "In" dbvarname = "@amn_wreckval"      cfsqltype="cf_sql_money"    null=yes>
            <cfprocparam type = "In" dbvarname = "@as_salvagenote"    cfsqltype="cf_sql_varchar"  null=yes>
            <cfprocparam type = "In" dbvarname = "@amn_consealamt"    cfsqltype="cf_sql_money"    null=yes>
            <cfprocparam type = "In" dbvarname = "@amn_tpjpjfee"      cfsqltype="cf_sql_money"    null=yes>
            <cfprocparam type = "In" dbvarname = "@amn_tpdocfee"      cfsqltype="cf_sql_money"    null=yes>
            <cfprocparam type = "In" dbvarname = "@amn_tpadjfee"      cfsqltype="cf_sql_money"    null=yes>
            <cfprocparam type = "In" dbvarname = "@amn_tplegalfee"    cfsqltype="cf_sql_money"    null=yes>
            <cfprocparam type = "In" dbvarname = "@ai_tplossusedays"  cfsqltype="cf_sql_integer"  null=yes>
            <cfprocparam type = "In" dbvarname = "@amn_tplossuserate" cfsqltype="cf_sql_money"    null=yes>
            <cfprocparam type = "In" dbvarname = "@amn_tplossexcess"  cfsqltype="cf_sql_money"    null=yes>
            <cfprocparam type = "In" dbvarname = "@amn_tplossncd"     cfsqltype="cf_sql_money"    null=yes>
            <cfprocparam type = "In" dbvarname = "@amn_tplossmedical" cfsqltype="cf_sql_money"    null=yes>
            <cfprocparam type = "In" dbvarname = "@amn_tplossothers1" cfsqltype="cf_sql_money"    null=yes>
            <cfprocparam type = "In" dbvarname = "@as_lbref"          cfsqltype="cf_sql_varchar"  null=yes>
            <cfprocparam type = "In" dbvarname = "@ai_lclsid"         cfsqltype="cf_sql_integer"  null=yes>
            <cfprocparam type = "In" dbvarname = "@an_vattaxpc"       cfsqltype="cf_sql_numeric"  null=no value="#arguments.targetgst#" scale=2>

            <!--- shiu: added parameters --->
            <cfprocparam type = "In" dbvarname = "@asi_wsrepair"          cfsqltype ="cf_sql_smallint" null =yes>
            <cfprocparam type = "In" dbvarname = "@asi_incidentcnt"       cfsqltype ="cf_sql_smallint" null =yes>
            <cfprocparam type = "In" dbvarname = "@an_salvagepc"          cfsqltype ="cf_sql_numeric"  null =yes scale=2>
            <cfprocparam type = "In" dbvarname = "@an_ovrdiscpc"          cfsqltype ="cf_sql_numeric"  null =yes scale=2>
            <cfprocparam type = "In" dbvarname = "@an_liablepc"           cfsqltype ="cf_sql_numeric"  null =yes scale=2>
            <cfprocparam type = "In" dbvarname = "@asi_vatcalctype"       cfsqltype ="cf_sql_smallint" null =yes>
            <cfprocparam type = "In" dbvarname = "@asi_vhstl"             cfsqltype ="cf_sql_smallint" null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_carrental"         cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_lossearning"       cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_tpudrinsured"      cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_captowcharge"      cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@an_stampdutypc"        cfsqltype ="cf_sql_numeric"  null =yes scale=2>
            <cfprocparam type = "In" dbvarname = "@an_deprpc"             cfsqltype ="cf_sql_numeric"  null =yes scale=2>
            <cfprocparam type = "In" dbvarname = "@amn_deprval"           cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_tlcoe"             cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_tlcoenet"          cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_tlomv"             cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_tlomvnet"          cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@asi_insuredack"        cfsqltype ="cf_sql_smallint" null =yes>
            <cfprocparam type = "In" dbvarname = "@asi_DDBINDEMNITY"      cfsqltype ="cf_sql_smallint" null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_settlenett"        cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@ai_liabflag"           cfsqltype ="cf_sql_integer"      null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_medicalrpt"        cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_personalbelong"    cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@ai_carrentaldays"      cfsqltype ="cf_sql_numeric"  null =yes scale=2>
            <cfprocparam type = "In" dbvarname = "@amn_carrentalrate"     cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@an_carrentalvatpc"     cfsqltype ="cf_sql_numeric"  null =yes scale=2>
            <cfprocparam type = "In" dbvarname = "@ai_lossearningdays"    cfsqltype ="cf_sql_numeric"  null =yes scale=2>
            <cfprocparam type = "In" dbvarname = "@amn_lossearningrate"   cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_smktvalue"         cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_smktvalue2"        cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@af_dmgallowpc"         cfsqltype ="cf_sql_numeric"  null =yes scale=2>
            <cfprocparam type = "In" dbvarname = "@amn_dmgallowval"       cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@af_upliftpc"           cfsqltype ="cf_sql_numeric"  null =yes scale=2>
            <cfprocparam type = "In" dbvarname = "@amn_upliftval"         cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_reimburseval"      cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@ai_ofrcurr"            cfsqltype ="cf_sql_integer"      null =yes>
            <cfprocparam type = "In" dbvarname = "@an_ofrexcrate"         cfsqltype ="cf_sql_numeric"  null =yes scale=15>
            <cfprocparam type = "In" dbvarname = "@asi_dav"               cfsqltype ="cf_sql_smallint" null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_offsetval"         cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@asi_dent113"           cfsqltype ="cf_sql_smallint" null =yes>
            <cfprocparam type = "In" dbvarname = "@an_premiumrate"        cfsqltype ="cf_sql_numeric"  null =yes scale=6>
            <cfprocparam type = "In" dbvarname = "@af_smstockpc"          cfsqltype ="cf_sql_numeric"  null =yes scale=2>
            <cfprocparam type = "In" dbvarname = "@amn_smstockval"        cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_tp2fexcess"        cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_excessrecovery"    cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_IPC_DIPC"          cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@asi_dcar"              cfsqltype ="cf_sql_smallint" null =yes>
            <cfprocparam type = "In" dbvarname = "@asi_drbc"              cfsqltype ="cf_sql_smallint" null =yes>
            <cfprocparam type = "In" dbvarname = "@asi_dpaintwc"          cfsqltype ="cf_sql_smallint" null =yes>
            <cfprocparam type = "In" dbvarname = "@ai_nonstdparts"        cfsqltype ="cf_sql_integer"      null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_invoicegst"        cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_DITC"              cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@asi_INVOICEGSTDEF"     cfsqltype ="cf_sql_smallint" null =yes>
            <cfprocparam type = "In" dbvarname = "@ai_liabflaggst"        cfsqltype ="cf_sql_integer"      null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_tpadjfeeGST"       cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_tplegalfeeGST"     cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@asi_keyudr"            cfsqltype ="cf_sql_smallint" null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_totudr"            cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_TPClaimAmt"        cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@asi_n4n"               cfsqltype ="cf_sql_smallint" null =yes>
            <cfprocparam type = "In" dbvarname = "@as_RECTYPECD"          cfsqltype ="cf_sql_varchar"  null =yes maxlength=5>
            <cfprocparam type = "In" dbvarname = "@amn_RECRSV"            cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@mn_VGMCGST"            cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@asi_accplus"           cfsqltype ="cf_sql_smallint" null =yes>
            <cfprocparam type = "In" dbvarname = "@as_accpluspolno"       cfsqltype ="cf_sql_varchar"  null =yes maxlength=30>
            <cfprocparam type = "In" dbvarname = "@asi_accpluscoverage"   cfsqltype ="cf_sql_smallint" null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_spraypaint"        cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_potwrecksalval"    cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@asi_WRECKTYPE"         cfsqltype ="cf_sql_smallint" null =yes>
            <cfprocparam type = "In" dbvarname = "@an_sanc2ipc"           cfsqltype ="cf_sql_numeric"  null =yes scale=2>
            <cfprocparam type = "In" dbvarname = "@asi_sanc2ireason"      cfsqltype ="cf_sql_smallint" null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_selfcideduct"      cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@as_accplusclmno"       cfsqltype ="cf_sql_varchar"  null =yes maxlength=30>
            <cfprocparam type = "In" dbvarname = "@amn_dsuminsured2"      cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@an_copay"              cfsqltype ="cf_sql_numeric"  null =yes scale=2>
            <cfprocparam type = "In" dbvarname = "@amn_copay"             cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_ismmktval"         cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_dmkttovalue"       cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_dmktfromvalue"     cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@asi_excesscoltype"     cfsqltype ="cf_sql_smallint" null =yes>
            <cfprocparam type = "In" dbvarname = "@asi_waiveBttrOACCheck" cfsqltype ="cf_sql_smallint" null =yes>
            <cfprocparam type = "In" dbvarname = "@an_PTLLIABLEPC"        cfsqltype ="cf_sql_numeric"  null =yes scale=2>
            <cfprocparam type = "In" dbvarname = "@asi_quantum"           cfsqltype ="cf_sql_smallint" null =yes>
            <cfprocparam type = "In" dbvarname = "@as_quantumRemarks"     cfsqltype ="cf_sql_varchar"  null =yes maxlength=0>
            <cfprocparam type = "In" dbvarname = "@ai_insacpt"            cfsqltype ="cf_sql_integer"  null =yes>
            <cfprocparam type = "In" dbvarname = "@asi_VEHTOWED"          cfsqltype ="cf_sql_smallint" null =yes>
            <cfprocparam type = "In" dbvarname = "@an_mktdeprpc"          cfsqltype ="cf_sql_numeric"  null =yes scale=2>
            <cfprocparam type = "In" dbvarname = "@amn_mktdeprval"        cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@amn_exscopay"          cfsqltype ="cf_sql_money"    null =yes>
            <cfprocparam type = "In" dbvarname = "@ai_aspid"              cfsqltype ="cf_sql_integer"  null =no value=0>
            <cfprocparam type = "In" dbvarname = "@ai_bypasslabour"       cfsqltype ="cf_sql_integer"  null =no value=1>
            <cfprocparam type = "In" dbvarname = "@asi_calcmodel"         cfsqltype ="cf_sql_smallint" null =no value=#arguments.sicalcmodel#>

            <cfprocresult name="instruct_trail">
            </CFSTOREDPROC>

            <CFSET returncode=CFSTOREDPROC.STATUSCODE>
            <CFIF returncode LTE 0>
                <CFTHROW TYPE="EX_DBERROR" ErrorCode="Transition/VATTAX/(#returncode#)">
            </CFIF>

            <CFSTOREDPROC PROCEDURE="sspESTcalcall" DATASOURCE="#Request.MTRDSN#" RETURNCODE="YES">
                <cfprocparam type = "In" dbvarname = "@ai_caseid"         cfsqltype="cf_sql_integer"  null=no value="#attributes.caseid#">
                <cfprocparam type = "In" dbvarname = "@aa_cotype"         cfsqltype="cf_sql_char"     null=no value="I">
                <cfprocparam type = "In" dbvarname = "@ai_aspid"          cfsqltype="cf_sql_integer"  null=no value="0">
                <cfprocparam type = "In" dbvarname = "@ai_bypassLabour"   cfsqltype="cf_sql_integer"  null=no value="1">
            </CFSTOREDPROC>

            <!--- disable log --->
            <cfquery name="qry_enable" datasource="#request.mtrdsn#">
                update TRX0035_LOG
                    set sistatus = 0
                where
                ilcaseid = <cfqueryparam value=#arguments.caseid# CFSQLType="cf_sql_integer" null="no">
                and acotype = <cfqueryparam value="I" CFSQLType="cf_sql_char" null="no">
                and vaaction = 'THATCHAM'
            </cfquery>

            <CFSTOREDPROC PROCEDURE="sspFOBJAudit" DATASOURCE=#Request.MTRDSN# RETURNCODE=YES>
                <CFPROCPARAM TYPE=IN  DBVARNAME=@ITATYPEID VALUE=901 CFSQLTYPE=CF_SQL_INTEGER>
                <CFPROCPARAM TYPE=IN  DBVARNAME=@ai_auditmode NULL=YES CFSQLTYPE=CF_SQL_INTEGER>
                <CFPROCPARAM TYPE=IN  DBVARNAME=@ai_usid VALUE=#session.vars.usid# CFSQLTYPE=CF_SQL_INTEGER>
                <CFPROCPARAM TYPE=IN  DBVARNAME=@ICRTCOROLE NULL=YES CFSQLTYPE=CF_SQL_INTEGER>
                <CFPROCPARAM TYPE=IN  DBVARNAME=@ICRTCOSECPOS NULL=YES CFSQLTYPE=CF_SQL_INTEGER>
                <CFPROCPARAM TYPE=IN  DBVARNAME=@DTCURDT NULL=YES CFSQLTYPE=CF_SQL_TIMESTAMP>
                <CFPROCPARAM TYPE=IN  DBVARNAME=@IDOMAINID VALUE=1 CFSQLTYPE=CF_SQL_INTEGER>
                <CFPROCPARAM TYPE=IN  DBVARNAME=@IOBJID VALUE=#arguments.caseid# CFSQLTYPE=CF_SQL_INTEGER>
                <CFPROCPARAM TYPE=IN  DBVARNAME=@ILINKID VALUE=#arguments.caseid# CFSQLTYPE=CF_SQL_INTEGER>
                <CFPROCPARAM TYPE=IN  DBVARNAME=@VATAREMARKS VALUE=#rem# CFSQLTYPE=cf_sql_varchar>
            </CFSTOREDPROC>

            <cfquery name="qry_result" datasource="#request.mtrdsn#">
                select nvattaxpc,sisvctaxpc
                from trx0035 iest with (nolock)
                where iest.ilcaseid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.caseid#">
                and iest.acotype = 'i'
            </cfquery>

            <cfset successSST = arguments.targetSST eq qry_result.sisvctaxpc>
            <cfset successGST = arguments.targetGST eq qry_result.nvattaxpc>
            <cfset print =isdiffsvctaxpc or isdiffnvattaxpc>

            <cfset rem = "">
            <cfset sucess = 0>
            <cfif isdiffsvctaxpc>
                <cfif successSST>
                    <cfset rem = rem&"Success:">
                    <cfset rem = rem&"Service Tax #qry_result.sisvctaxpc#%; ">
                     <cfset sucess = 1>
                <cfelse>
                    <cfset rem = rem&"Unsuccessful:">
                    <cfset rem = rem&"Service Tax #qry_result.sisvctaxpc#%; ">
                </cfif>
            </cfif>
            <cfif isdiffnvattaxpc>
                <cfif successGST>
                    <cfset rem = rem&"Success:">
                    <cfset rem = rem&"GST #qry_result.nvattaxpc#%; ">
                     <cfset sucess = 1>
                <cfelse>
                    <cfset rem = rem&"Unsuccessful:">
                    <cfset rem = rem&"GST #qry_result.nvattaxpc#%; ">
                </cfif>
            </cfif>

            <!--- ZH #25903: update the marker first as it is needed during triggering --->
	        <cfquery name="qry_setrecalcflag" datasource="#request.mtrdsn#">
	            update TRX0001 set siRECALC2 = <cfqueryparam value=#arguments.targetrecalc# CFSQLType="cf_sql_smallint" null="no">
	            where icaseid = <cfqueryparam value="#arguments.caseid#" CFSQLType = "cf_sql_integer" null="no">
	        </cfquery>

            <CFSTOREDPROC PROCEDURE="sspFOBJAudit" DATASOURCE=#Request.MTRDSN# RETURNCODE=YES>
                <CFPROCPARAM TYPE=IN  DBVARNAME=@ITATYPEID VALUE=901 CFSQLTYPE=CF_SQL_INTEGER>
                <CFPROCPARAM TYPE=IN  DBVARNAME=@ai_auditmode NULL=YES CFSQLTYPE=CF_SQL_INTEGER>
                <CFPROCPARAM TYPE=IN  DBVARNAME=@ai_usid VALUE=#session.vars.usid# CFSQLTYPE=CF_SQL_INTEGER>
                <CFPROCPARAM TYPE=IN  DBVARNAME=@ICRTCOROLE NULL=YES CFSQLTYPE=CF_SQL_INTEGER>
                <CFPROCPARAM TYPE=IN  DBVARNAME=@ICRTCOSECPOS NULL=YES CFSQLTYPE=CF_SQL_INTEGER>
                <CFPROCPARAM TYPE=IN  DBVARNAME=@DTCURDT NULL=YES CFSQLTYPE=CF_SQL_TIMESTAMP>
                <CFPROCPARAM TYPE=IN  DBVARNAME=@IDOMAINID VALUE=1 CFSQLTYPE=CF_SQL_INTEGER>
                <CFPROCPARAM TYPE=IN  DBVARNAME=@IOBJID VALUE=#arguments.caseid# CFSQLTYPE=CF_SQL_INTEGER>
                <CFPROCPARAM TYPE=IN  DBVARNAME=@ILINKID VALUE=#arguments.caseid# CFSQLTYPE=CF_SQL_INTEGER>
                <CFPROCPARAM TYPE=IN  DBVARNAME=@VATAREMARKS VALUE=#rem# CFSQLTYPE=cf_sql_varchar>
                <CFPROCPARAM TYPE=IN  DBVARNAME=@IPARAM1 VALUE=#sucess# CFSQLTYPE=CF_SQL_INTEGER>
            </CFSTOREDPROC>

        </cfif>

        <!--- marker: done recalc --->
        <cfquery name="qry_setrecalcflag" datasource="#request.mtrdsn#">
            update TRX0001 set siRECALC2 = <cfqueryparam value=#arguments.targetrecalc# CFSQLType="cf_sql_smallint" null="no">
            where icaseid = <cfqueryparam value="#arguments.caseid#" CFSQLType = "cf_sql_integer" null="no">
        </cfquery>

        <CFCATCH>
            <CFTRANSACTION ACTION="ROLLBACK">
            <CFRETHROW>
        </CFCATCH>
    </CFTRY>

    <CFTRANSACTION ACTION="COMMIT">
    </CFTRANSACTION>

</cffunction>
<CFSET Attributes.DS.MTRFN.MTRrecalculate=MTRrecalculate>

<cffunction access="public" name="MtrGetTaxUsed" returntype="struct" output=false description="">
    <cfargument name="locale" type="numeric" required="true">
    <cfquery name="qry_locale" datasource="#request.mtrdsn#">
        select
            vavattaxname,nvattaxpc
            ,vasvctaxname,nsvctaxpc
        from sys0009 with (nolock) where ilocid = <cfqueryparam value=#arguments.locale# CFSQLType="cf_sql_integer" null="no">
    </cfquery>

    <!--- priority order: vattax,svctax; bring forth next in line when null --->
    <cfset var order = ["vavattaxname|nvattaxpc|vat","vasvctaxname|nsvctaxpc|svc"]>
    <cfset var result = {taxtype="",taxval=-1,taxname=""}>
    <cfloop array=#order# index="item">
        <cfset result.taxname = qry_locale[listGetAt(item,1,"|")]>
        <cfset result.taxval  = qry_locale[listGetAt(item,2,"|")]>
        <cfset result.taxtype = listGetAt(item,3,"|")>
        <cfif len(result.taxtype) gt 0>
            <cfbreak>
        </cfif>
    </cfloop>

    <cfreturn result>
</cffunction>
<CFSET Attributes.DS.MTRFN.MtrGetTaxUsed=MtrGetTaxUsed>

<cffunction access="public" name="MTRTenderGST" returntype="struct" output=false description="">
	<cfargument name="coid" type="numeric">
	<cfargument name="thedate" type="date">
	<cfargument name="ettype" type="string" default=""><!--- tender type --->
	<!--- return:
			gstmod : 1 or 0 - to enable GST module
			isgst : 1 or 0 - the state of gst
			gstpc : default gst apply for company
			availgstpc : alternative gst % can be applied
	--->
	<!--- <cfset var test=request.ds.fn.SVCgetcovatefftimeline(arguments.thedate)> --->
<!--- SG AXA doesn't want to use GST module: <cfif request.ds.co[arguments.coid].locid IS 2 AND arguments.coid IS 200029 and arguments.ettype IS 1>
		<!--- SG AXA wreck only --->
		<CFSET results={gstmod=1,isgst=1,gstpc="3.5",allowgstpc="3.5"}> --->
	<cfif request.ds.co[arguments.coid].locid IS 1>
		<cfset var gov=request.ds.fn.SVCgetcovatefftimeline(arguments.thedate)>
		<cfset var co=request.ds.fn.SVCgetCoVATEff(arguments.coid)>
		<cfif gov.isGSTEra IS 1 AND co.isGSTEra IS 1>
			<!--- <CFSET results={isgst=#co.isGSTEra#,gstpc=#LSParseNumber(gov.timelinegst)#}> --->
			<CFSET results={gstmod=1,isgst=#co.isGSTEra#,gstpc=#LSParseNumber(gov.timelinegst)#,allowgstpc="0,6",sstpc=""}>
		<CFELSE>
			<CFSET results={gstmod=1,isgst=0,gstpc="",allowgstpc="",sstpc=#LSParseNumber(gov.timelinesvctaxpc)#}>
		</cfif>
	<cfelse>
		<CFSET results={gstmod=0,isgst=0,gstpc="",allowgstpc="",sstpc=""}><!--- disable GST module, no gst applied --->
	</cfif>
	<CFRETURN results>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRTenderGST=MTRTenderGST>

<cffunction access="public" name="MTRGSTinvheader" returntype="string" output=false description="">
    <cfargument name="caseid" type="numeric" required="true">
    <cfargument name="coid" type="numeric" required="true">
    <cfargument name="reinsp" type="numeric" required="false" default=0>
    <cfargument name="invid" type="numeric" required="false" default=0>

    <cfset mygstcheck = request.ds.fn.SVCgetcovateff(arguments.coid)>
    <cfset isvateff = mygstcheck.isvateff>
	<!--- <cfset mygsteff = mygstcheck.myeff>
	<cfset cogsteff = mygstcheck.coeff> --->
	<cfquery name="qry_coinfo" datasource="#request.mtrdsn#">
		select sicotypeid from sec0005 with (nolock) where icoid=<cfqueryparam value=#arguments.coid# CFSQLType="cf_sql_integer" null="no">
	</cfquery>
	<cfset cotype=#qry_coinfo.sicotypeid#> <!-- 1:repairer, 2:insurer, 3:adjuster, 12:solicitor --->

	<cfif cotype is 1 or cotype is 2> <!--- repairer/insurer --->
		<cfset model=request.ds.mtrfn.MTRGSTcalcmodel(arguments.caseid,"I")>
		<cfif model is "GST">
			<cfset result=1>
		<cfelseif model is "SST">
			<cfquery name="qry_calc" datasource="#request.mtrdsn#">
			    select siSVCTAXPC
			    from trx0035 with (nolock)
			    where ilcaseid =  <cfqueryparam value=#arguments.caseid# CFSQLType="cf_sql_integer" null="no">
			    and acotype = 'I'
		    </cfquery>
		    <cfif qry_calc.siSVCTAXPC GT 0>
				<cfset result=50>
			<cfelse>
				<cfset result=0>
			</cfif>
		<cfelse>
			<cfset result=0>
		</cfif>
	<cfelseif cotype is 3> <!--- adjuster --->
		<cfquery name="qry_calc" datasource="#request.mtrdsn#">
   			select a.siinvoicetype, a.nvattaxpc
	   	 	from trx0020 a with (nolock) inner join trx0002 adj with (nolock) on a.iadjcaseid=adj.iadjcaseid
	   	 	where adj.icaseid =  <cfqueryparam value=#arguments.caseid# CFSQLType="cf_sql_integer" null="no">
	   	 	and a.siRINSFLAG= <cfqueryparam value=#arguments.reinsp# CFSQLType="cf_sql_integer" null="no">
    	</cfquery>
    	<cfif qry_calc.siinvoicetype is 9>
    		<cfset result=1>
    	<cfelseif qry_calc.siinvoicetype is 5 and qry_calc.nvattaxpc gt 0>
    		<cfset result=50>
    	<cfelse>
    		<cfset result=0>
		</cfif>
	<cfelseif cotype is 12> <!--- solicitor --->
		<cfquery name="qry_calc" datasource="#request.mtrdsn#">
   			select siinvoicetype, nvattaxpc
   			from trx0099 with (nolock)
   			where isolcaseid = <cfqueryparam value=#arguments.caseid# CFSQLType="cf_sql_integer" null="no">
   			and iSOLINVID = <cfqueryparam value=#arguments.invid# CFSQLType="cf_sql_integer" null="no">
    	</cfquery>
    	<cfif qry_calc.siinvoicetype is 9>
    		<cfset result=1>
    	<cfelseif qry_calc.siinvoicetype is 5 and qry_calc.nvattaxpc gt 0>
    		<cfset result=50>
    	<cfelse>
    		<cfset result=0>
		</cfif>
	<cfelseif isvateff> <!--- is gst registrant --->
		<cfset result=1>
	<cfelse>
		<cfset result=0>
	</cfif>

    <cfreturn result>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGSTinvheader=MTRGSTinvheader>

<cffunction name="MTRUGSEARCH" output="yes" hint="User Group Popup Search (enableSearch)">
	<cfargument name="GCOID" type="numeric">
	<cfargument name="branch" type="boolean" default="false">
	<cfargument name="usergrp" type="boolean" default="false">
	<cfargument name="TEXTOBJID" type="string">
	<cfargument name="VALUEOBJID" type="string">
	<cfargument name="filtered_users" type="string" default="">
	<cfargument name="RETTYPE" type="numeric" default="1">

	<cfargument name="JSCALLBACK" type="string" default="">
	<cfargument name="JSCALLBACKCLR" type="string" default="">

	<CFSET var addFilter = "">
	<CFSET var Label = "">

	<cfif arguments.JSCALLBACK neq "">
		<cfset jscb = '"#arguments.JSCALLBACK#"'>
	<cfelse>
		<cfset jscb = 'null'>
	</cfif>
	<cfif arguments.JSCALLBACKCLR neq "">
		<cfset jscbclr = '"#arguments.jscallbackclr#"'>
	<CFELSE>
		<cfset jscbclr = 'null'>
	</CFIF>

	<CFSAVECONTENT variable="addFilter">
		<CFOUTPUT>
		<br>
		<table border="0">
			<CFIF branch>
				<tr>
					<td>#Server.SVClang("Branch",1065)#</td>
					<td><select ID=ddlbBranch NAME=ddlbBranch onblur="DoReq(this);"><option value=""></option>
						<cfquery NAME=q_branch DATASOURCE=#Request.MTRDSN#>
						SELECT DISTINCT vaCOBRNAME,iCOID FROM SEC0005 WITH(NOLOCK) WHERE iGCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#session.vars.gcoid#"> ORDER BY vaCOBRNAME ASC
						</cfquery>
						<cfloop query=q_branch><option BRNAME="#vaCOBRNAME#" value="#iCOID#">#HTMLEditFormat(vaCOBRNAME)#</option></cfloop>
						</select>
					</td>
				</tr>
			</CFIF>
			<CFIF usergrp>
				<tr>
					<td>#Server.SVClang("User Group",12106)#</td>
					<td><select ID=ddlbUsrGrp NAME=ddlbUsrGrp onblur="DoReq(this);">
						<OPTION value=""></option>
						<OPTION value="0">-No User Group-</OPTION>
						<cfquery NAME=q_usrgrp DATASOURCE=#Request.MTRDSN#>
						select distinct
						user_group.vaGRPName,
						user_group.iGRPID
						from FSEC4001 user_group
						inner join Fsec4002 user_group_users on user_group_users.iGRPID=user_group.iGRPID
						inner join sec0001 users on user_group_users.iUSID = users.iUSID
						inner join sec0005 co on users.iCOID=co.iCOID
						where co.igcoid=<cfqueryparam value="#GCOID#" cfsqltype="CF_SQL_INTEGER">
						</cfquery>
						<cfloop query=q_usrgrp><option USGRP="#vaGRPName#" value="#iGRPID#">#HTMLEditFormat(vaGRPName)#</option></cfloop>
						</select>
					</td>
				</tr>
			</CFIF>
		</table>
		</CFOUTPUT>
	</CFSAVECONTENT>
	<cfset label="#Server.SVClang("Search",1076)#">
	<cfmodule template="#request.logpath#index.cfm" fusebox="SVCobj" fuseaction="dsp_SVCSelector"
		URL="#request.webroot#index.cfm?fusebox=SVCObj&fuseaction=xml_SVCGetUserGroupUsers&COTYPEID=1&SUBCOTYPEFLAG=2#IIF(filtered_users eq '','''''','''&PERM=#filtered_users#''')##IIF(RETTYPE eq 1,'''''','''&RETTYPE=#RETTYPE#''')#"
		TYPE="CFM" SHOWCHECKBOX="0" TEXTOBJID="#TEXTOBJID#" VALUEOBJID="#VALUEOBJID#" SRCTEXTFIELD="USGROUP" SRCVALUEFIELD="USID" BUTTONTEXT="#label#" adtlfilterHTML="#JSStringFormat(addFilter)#" selectrecords=0
		JCALLBACK="#jscb#" JCALLBACKCLR="#jscbclr#">
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRUGSEARCH=MTRUGSEARCH>

<cffunction name="DisplayMiniLossDetails" hint="" returntype="any" output="yes">
<cfargument name="CASEID" required="true" type="numeric"
	displayname="The CaseID of the claim subfolder (DomainID=1). This is the unique reference running number for each claim subfolder and supplementary. Primary key for TRX0001."
	hint="CaseID for the claim subfolder.">
<cfargument name="MODE" required="false" default="0" type="numeric"
	displayname="Mode of display."
	hint="0: Table display, 1: Lite display.">
<cfset var q_clm={}>
<cfset var q_trx={}>
<cfset var Str="">
<cfquery DATASOURCE=#Request.MTRDSN# NAME="q_clm">
SELECT a.aCLAIMTYPE FROM TRX0001 a WITH (NOLOCK) WHERE a.iCASEID=<cfqueryparam value="#arguments.CASEID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfset CLMTYPE=q_clm.aCLAIMTYPE>
<cfset CLMFLOW=Left(q_clm.aCLAIMTYPE,2)>
<cfquery DATASOURCE=#Request.MTRDSN# NAME="q_clm">
SELECT ClmtypeSum_MTR=SUM(CASE WHEN Left(vaCLMTYPE,2)<>'NM' THEN iCLMTYPEMASK ELSE 0 END),
	ClmtypeSum_NM=SUM(CASE WHEN Left(vaCLMTYPE,2)='NM' THEN iCLMTYPEMASK ELSE 0 END)
FROM CLMD0010 WITH (NOLOCK)
</cfquery>
<cfquery DATASOURCE=#Request.MTRDSN# NAME="q_trx">
SELECT b.txtCDNATUREDESC,b.vaCDLOSSDESC,STDLOSSDESC=LTrim(RTrim(IsNull(c2.vaCFDESC,c.vaCFDESC))),
		VEHMODELSTR_POL=RTrim(
							CASE WHEN IsNull(p.vaMAN,'')='' THEN '' ELSE p.vaMAN+' ' END+
							CASE WHEN IsNull(p.vaMODEL,'')='' THEN '' ELSE p.vaMODEL+' ' END+
							CASE WHEN IsNull(p.vaVEHBODY,'')='' THEN '' ELSE p.vaVEHBODY+' ' END+
							CASE WHEN p.iMANYEAR>0 THEN
								CASE WHEN p.iMANYEAR<=50 THEN '['+CAST(2000+p.iMANYEAR AS VARCHAR)+']'
									 WHEN p.iMANYEAR<=99 THEN '['+CAST(1900+p.iMANYEAR AS VARCHAR)+']'
									 ELSE '['+CAST(p.iMANYEAR AS VARCHAR)+']' END
							ELSE '' END),
		VEHMODELSTR_CLM=LTrim(RTrim(IsNull(re.vaMAN,'')+' '+IsNull(re.vaMODEL,'')+' '+IsNull(re.vaVAR,'')))
FROM TRX0001 a WITH (NOLOCK)
	INNER JOIN TRX0008 i WITH (NOLOCK) ON i.iCASEID=a.iCASEID AND i.siTPINS=0
	INNER JOIN SEC0005 ins WITH (NOLOCK) ON ins.iCOID=a.iINSCOID
	INNER JOIN TRX0055 b WITH (NOLOCK) ON a.iMCASEID=b.iCASEID
		LEFT JOIN BIZ0025 c WITH (NOLOCK) ON b.iCDSTDLOSSDESC=c.vaCFCODE AND c.aCFTYPE='CIRACT' AND c.iCOID=0 AND c.iCLMTYPEMASK & <cfif CLMFLOW IS "NM"><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#q_clm.ClmtypeSum_NM#"><cfelse><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#q_clm.ClmtypeSum_MTR#"></cfif> > 0
		LEFT JOIN BIZ0025 c2 WITH (NOLOCK) ON b.iCDSTDLOSSDESC=c2.vaCFCODE AND c2.aCFTYPE='CIRACT' AND c2.iCOID=ins.iGCOID AND c2.iCLMTYPEMASK & <cfif CLMFLOW IS "NM"><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#q_clm.ClmtypeSum_NM#"><cfelse><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#q_clm.ClmtypeSum_MTR#"></cfif> > 0
		LEFT JOIN TRX0035 re WITH (NOLOCK) ON a.iCASEID=re.iLCASEID AND re.aCOTYPE='R'
		LEFT JOIN BIZ_POL p WITH (NOLOCK) ON p.iPOLID=i.iBIZPOLID
WHERE a.iCASEID=<cfqueryparam value="#Arguments.CASEID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<CFOUTPUT>
<CFLOOP query=q_trx>
<CFIF Arguments.MODE IS 1>
	<CFSET Str="">
	<cfif CLMFLOW IS "NM">
		<CFSET Str=Str&"<br> ... #Server.SVClang("Nature of Loss",3003)#: <b>#HTMLEditFormat(Trim(txtCDNATUREDESC))#</b>">
	</CFIF>
	<CFIF Trim(STDLOSSDESC) IS NOT "">
		<CFSET Str=Str&"<br> ... #Server.SVClang("Circumstances of Accident/Loss",1165)#: <b>#HTMLEditFormat(Trim(STDLOSSDESC))#</b>">
	</CFIF>
	<CFIF Trim(vaCDLOSSDESC) IS NOT "">
		<CFSET Str=Str&"<br> ... #Server.SVClang("Description of Accident/Loss",1166)#: <b>#HTMLEditFormat(Trim(vaCDLOSSDESC))#</b>">
	</CFIF>
	<CFIF Trim(VEHMODELSTR_POL) IS NOT "">
		<CFSET Str=Str&"<br> ... #Server.SVClang("Backend/Policy Model",17873)#: <b>#HTMLEditFormat(Trim(VEHMODELSTR_POL))#</b>">
	</CFIF>
	<CFIF Trim(VEHMODELSTR_CLM) IS NOT "">
		<CFSET Str=Str&"<br> ... #Server.SVClang("Vehicle Model",6839)#: <b>#HTMLEditFormat(Trim(VEHMODELSTR_CLM))#</b>">
	</CFIF>
	#Str#
<CFELSE>
	<CFIF request.ds.fn.SVCGetResp()>
		<table class="clsClmTable" align=center width=100% style="font-size:110%;">
			<col class="clsClmDtlTone1 col-md-3 col-xs-5" style="font-weight:normal; word-wrap: break-word;"><col class=clsClmDtlTone2>
			<col class="clsClmDtlTone1 col-md-9 col-xs-7" style="font-weight:normal; word-wrap: break-word;"><col class=clsClmDtlTone2>
			<tr><td class=header colspan=4>#Server.SVClang("CLAIM LOSS DETAILS",1150)#</td></tr>
			<cfif CLMFLOW IS "NM">
				<tr>
					<td valign=top style="font-weight:normal">#Server.SVClang("Nature of Loss",3003)#:</td>
					<td colspan=3>#HTMLEditFormat(txtCDNATUREDESC)#&nbsp;</td>
				</tr>
			</cfif>
			<tr>
				<td valign=top style="width:40ex;font-weight:normal">#Server.SVClang("Circumstances of Accident/Loss",1165)#:</td>
				<td colspan=3>#HTMLEditFormat(STDLOSSDESC)#&nbsp;</td>
			</tr>
			<tr>
				<td valign=top style="font-weight:normal">#Server.SVClang("Description of Accident/Loss",1166)#:</td>
				<td colspan=3>#HTMLEditFormat(vaCDLOSSDESC)#&nbsp;</td>
			</tr>
			<CFIF Trim(VEHMODELSTR_POL) IS NOT "">
				<tr>
					<td valign=top style="width:40ex;font-weight:normal">#Server.SVClang("Backend/Policy Model",17873)#:</td>
					<td colspan=3>#HTMLEditFormat(VEHMODELSTR_POL)#&nbsp;</td>
				</tr>
			</CFIF>
			<CFIF Trim(VEHMODELSTR_CLM) IS NOT "">
				<tr>
					<td valign=top style="width:40ex;font-weight:normal">#Server.SVClang("Vehicle Model",6839)#:</td>
					<td colspan=3>#HTMLEditFormat(VEHMODELSTR_CLM)#&nbsp;</td>
				</tr>
			</CFIF>
		</table>
		<br>
	<CFELSE>
		<table class=clsClmTable align=center width=100%>
		<col class=clsClmDtlTone1 style=font-weight:normal;width:40ex><col class=clsClmDtlTone2>
		<col class=clsClmDtlTone1 style=font-weight:normal;width:40ex><col class=clsClmDtlTone2>
		<tr><td class=header colspan=4>#Server.SVClang("CLAIM LOSS DETAILS",1150)#</td></tr>
		<cfif CLMFLOW IS "NM">
		<tr>
			<td valign=top style="font-weight:normal">#Server.SVClang("Nature of Loss",3003)#:</td>
			<td colspan=3>#HTMLEditFormat(txtCDNATUREDESC)#&nbsp;</td>
		</tr>
		</cfif>
		<tr>
			<td valign=top style="width:40ex;font-weight:normal">#Server.SVClang("Circumstances of Accident/Loss",1165)#:</td>
			<td colspan=3>#HTMLEditFormat(STDLOSSDESC)#&nbsp;</td>
		</tr>
		<tr>
			<td valign=top style="font-weight:normal">#Server.SVClang("Description of Accident/Loss",1166)#:</td>
			<td colspan=3>#HTMLEditFormat(vaCDLOSSDESC)#&nbsp;</td>
		</tr>
		<CFIF Trim(VEHMODELSTR_POL) IS NOT "">
			<tr>
				<td valign=top style="width:40ex;font-weight:normal">#Server.SVClang("Backend/Policy Model",17873)#:</td>
				<td colspan=3>#HTMLEditFormat(VEHMODELSTR_POL)#&nbsp;</td>
			</tr>
		</CFIF>
		<CFIF Trim(VEHMODELSTR_CLM) IS NOT "">
			<tr>
				<td valign=top style="width:40ex;font-weight:normal">#Server.SVClang("Vehicle Model",6839)#:</td>
				<td colspan=3>#HTMLEditFormat(VEHMODELSTR_CLM)#&nbsp;</td>
			</tr>
		</CFIF>
		</table>
		<br>
	</CFIF>
</CFIF>
</CFLOOP>
</CFOUTPUT>
<cfreturn>
</cffunction>
<CFSET Attributes.DS.MTRFN.DisplayMiniLossDetails=DisplayMiniLossDetails>

<cffunction name="DisplayWarningForRepudiatedClaim" hint="Display warning for repudiated insured claim" returntype="any" output="yes">
<cfargument name="CASEID" required="true" type="numeric"
	displayname="The CaseID of the claim subfolder (DomainID=1). This is the unique reference running number for each claim subfolder and supplementary. Primary key for TRX0001."
	hint="CaseID for the claim subfolder.">
<cfargument name="DISPMODE" required="false" default=0 type="numeric"
	displayname="Display warning text"
	hint="">
<cfargument name="INSGCOID" required="false" default="" type="string"
	displayname="Insurer group company GCOID <SEC0005.iGCOID>"
	hint="">
<cfargument name="REGNO" required="false" default="" type="string"
	displayname="Vechile No."
	hint="">
<cfargument name="LOSSDATE" required="false" default="" type="string"
	displayname="Accident Date/Time"
	hint="">
<CFSET var q_trx={}>
<CFSET var q_trx2={}>
<CFSET var warningstr="">
<cfset var CASELABEL=""><!---  #643  --->
<cfif Arguments.CASEID GT 0>
	<cfquery DATASOURCE=#Request.MTRDSN# NAME="q_trx">
	SELECT insuredvehno=CASE WHEN Left(a.aCLAIMTYPE,2)='TP' AND a.aCLAIMTYPE<>'TP KFK' THEN a.va3REGNO ELSE a.vaREGNO END,
		accdate=a.dtACCDATE,insgcoid=b.iGCOID
	FROM TRX0001 a WITH (NOLOCK)
		INNER JOIN SEC0005 b WITH (NOLOCK) ON b.iCOID=a.iINSCOID
	WHERE a.iCASEID=<cfqueryparam value="#Arguments.CASEID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif q_trx.recordcount NEQ 1>
		<CFTHROW TYPE="EX_DBERROR" ErrorCode="BADCASE" ExtendedInfo="Case not found">
	</cfif>
	<cfset Arguments.INSGCOID=q_trx.insgcoid>
	<cfset Arguments.REGNO=q_trx.insuredvehno>
	<cfset Arguments.LOSSDATE=Request.DS.FN.SVCdt(q_trx.accdate)>
</cfif>
<!--- Check for matching repudiated insured claims --->
<cfquery DATASOURCE=#Request.MTRDSN# NAME="q_trx2">
SELECT a.iCASEID,c.siCSTAT,c.siRSNID
FROM FDIR3004 s WITH (NOLOCK)
	INNER JOIN TRX0001 a WITH (NOLOCK) ON a.iCASEID=s.iOBJID
	INNER JOIN SEC0005 b WITH (NOLOCK) ON b.iCOID=a.iINSCOID
	INNER JOIN TRX0008 c WITH (NOLOCK) ON c.iCASEID=a.iCASEID AND c.siTPINS=0
WHERE s.iSRCHTYPEID=1 AND s.vaSRCH=<cfqueryparam cfsqltype="cf_sql_varchar" value=#Arguments.REGNO#>
<!--- AND a.iCASEID<><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Arguments.CASEID#"> --->
AND (CASE WHEN Left(a.aCLAIMTYPE,2)='TP' AND a.aCLAIMTYPE<>'TP KFK' THEN a.va3REGNO ELSE a.vaREGNO END)=<cfqueryparam cfsqltype="cf_sql_varchar" value=#Arguments.REGNO#>
AND a.dtACCDATE=<cfqueryparam cfsqltype="cf_sql_timestamp" value=#Request.DS.FN.SVCdtLOCtoDB(Arguments.LOSSDATE)#>
AND b.iGCOID=<cfqueryparam cfsqltype="cf_sql_integer" value=#Arguments.INSGCOID#>
</cfquery>
<cfsavecontent variable="warningstr">
<div align=center>
<blockquote style="width:50%;padding:10px;color:red;font-weight:bold;background-color:yellow;border:2px solid black">
Potential REPUDIATION Flagged / Claim REPUDIATED! Are you sure you want to proceed?
</blockquote>
</div>
</cfsavecontent>
<CFLOOP query="q_trx2">
	<!--- Cancelled & Repudiated reason --->
	<cfif (q_trx2.siCSTAT IS 999 AND q_trx2.siRSNID IS 4)>
		<cfif DISPMODE IS 1>
			<CFOUTPUT>#warningstr#</CFOUTPUT>
		</cfif>
		<CFRETURN warningstr>
	<cfelse>
		<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\chklabel.cfm" CASEID=#q_trx2.iCASEID#><!--- return CALLER.CASELABEL --->
		<!--- Potential Repudiation tagged --->
		<cfif ListFind(CASELABEL,138)>
			<cfif DISPMODE IS 1>
				<CFOUTPUT>#warningstr#</CFOUTPUT>
			</cfif>
			<CFRETURN warningstr>
		<cfelse>
			<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkdoccnt.cfm" DOMAINID=1 OBJID=#q_trx2.iCASEID# USID=0 COROLE=0 DOCDEFIDLIST="320" VARMODRESULT="DOCSRESULT">
			<!--- Repudiation Letter created --->
			<cfif DOCSRESULT.SUCCESS>
				<cfif DISPMODE IS 1>
					<CFOUTPUT>#warningstr#</CFOUTPUT>
				</cfif>
				<CFRETURN warningstr>
			</cfif>
		</cfif>
	</cfif>
</CFLOOP>
<CFRETURN "">
</cffunction>
<CFSET Attributes.DS.MTRFN.DisplayWarningForRepudiatedClaim=DisplayWarningForRepudiatedClaim>

<cffunction name="GetEffflagHTML" hint="Translate and display HTML for the Effective Flag" returntype="struct" output="no">
<cfargument name="EFFFLAG" required="true" type="numeric"
	displayname="The Effective Flag of the claim subfolder (DomainID=1). Refer to TRX0008.iEFFFLAG"
	hint="">
<cfargument name="RepFranchise" required="true" type="numeric"
	displayname="Whether repairer is a Franchise Holder. Refer to SEC0005.siFRANCHISE"
	hint="">
<cfargument name="DisplayLayout" required="false" type="numeric" default="0"
	displayname="Display formatting for the HTML"
	hint="0:Main Listing layout, 1:Claim Subfolder layout">
<cfargument name="ShowPanelFlags" required="false" type="numeric" default="1"
	displayname="Show panel related flags"
	hint="">
<cfargument name="LOCID" required="false" type="string"
	displayname="Locale ID"
	hint="Locale for the current session. <SYS0009.iLOCID>">
<cfargument name="INSGCOID" required="false" default="" type="string"
	displayname="Insurer group company GCOID <SEC0005.iGCOID>"
	hint="">
<cfset var EffCodeList="">
<cfset var result={NONPANELEXIST=0,HTMLStr=""}>

<cfif BitAnd(Arguments.EFFFLAG,16) IS 16 AND Arguments.RepFranchise IS 1>
	<cfif Arguments.ShowPanelFlags IS 1 AND BitAnd(Arguments.EFFFLAG,2) IS 2 AND NOT(INSGCOID IS 700051)>
		<cfset EffCodeList=ListAppend(EffCodeList,"{PN}")>
	</cfif>
	<cfset EffCodeList=ListAppend(EffCodeList,"{FR}")>
<cfelseif BitAnd(Arguments.EFFFLAG,16) IS 16 AND Arguments.RepFranchise IS 0>
	<cfif Arguments.ShowPanelFlags IS 1 AND BitAnd(Arguments.EFFFLAG,2) IS 2 AND NOT(INSGCOID IS 700051)>
		<cfset EffCodeList=ListAppend(EffCodeList,"{PN}")>
	</cfif>
	<cfset EffCodeList=ListAppend(EffCodeList,"{FA}")>
<cfelseif Arguments.ShowPanelFlags IS 1>
	<cfif BitAnd(Arguments.EFFFLAG,64) IS 64>
		<cfset EffCodeList=ListAppend(EffCodeList,"{SP}")>
	<cfelseif BitAnd(Arguments.EFFFLAG,2) IS 2>
		<cfset EffCodeList=ListAppend(EffCodeList,"{PN}")>
	<cfelseif BitAnd(Arguments.EFFFLAG,2) IS 0>
		<cfset EffCodeList=ListAppend(EffCodeList,"{NP}")>
		<cfset result.NONPANELEXIST=1>
	</cfif>
</cfif>

<cfloop list="#EffCodeList#" index="KitKat">
	<cfif Arguments.DisplayLayout IS 0>
		<cfif KitKat IS "{PN}">
			<cfset result.HTMLStr&="<div style=color:blue;font-weight:bold;font-size:80%>#Server.SVClang("PANEL",18014)#</div>">
		</cfif>
		<cfif KitKat IS "{NP}">
			<cfset result.HTMLStr&="<div style=color:red;font-weight:bold;font-size:80%>#Server.SVClang("NON-PANEL",4619)#</div>">
		</cfif>
		<cfif KitKat IS "{SP}">
			<cfset result.HTMLStr&="<div style=color:red;font-weight:bold;font-size:80%>#Server.SVClang("SUSPENDED",7796)#</div>">
		</cfif>
		<cfif KitKat IS "{FR}">
			<cfset result.HTMLStr&="<div style=color:green;font-weight:bold;font-size:80%>#Server.SVClang("FRANCHISE",4618)#</div>">
		</cfif>
		<cfif KitKat IS "{FA}">
			<cfset result.HTMLStr&="<div style=color:green;font-weight:bold;white-space:nowrap;font-size:80%>#Server.SVClang("FRANCHISE-AUTHORIZED",18015)#</div>">
		</cfif>
	<cfelseif Arguments.DisplayLayout IS 1>
		<cfif KitKat IS "{PN}">
			<cfset result.HTMLStr&="<span style=color:white;background-color:blue;font-weight:bold;font-size:100%>&nbsp;#Server.SVClang("PANEL",18014)#&nbsp;</span>&nbsp;">
		</cfif>
		<cfif KitKat IS "{NP}">
			<cfset result.HTMLStr&="<span style=color:white;background-color:red;font-weight:bold;font-size:100%>&nbsp;#Server.SVClang("NON-PANEL",4619)#&nbsp;</span>&nbsp;">
		</cfif>
		<cfif KitKat IS "{SP}">
			<cfset result.HTMLStr&="<span style=color:white;background-color:red;font-weight:bold;font-size:100%>&nbsp;#Server.SVClang("SUSPENDED",7796)#&nbsp;</span>&nbsp;">
		</cfif>
		<cfif KitKat IS "{FR}">
			<cfset result.HTMLStr&="<span style=color:white;background-color:green;font-weight:bold;font-size:100%>&nbsp;#Server.SVClang("FRANCHISE",4618)#&nbsp;</span>&nbsp;">
		</cfif>
		<cfif KitKat IS "{FA}">
			<cfset result.HTMLStr&="<span style=color:white;background-color:green;font-weight:bold;white-space:nowrap;font-size:100%>&nbsp;#Server.SVClang("FRANCHISE-AUTHORIZED",18015)#&nbsp;</span>&nbsp;">
		</cfif>
	</cfif>
</cfloop>

<cfreturn result>
</cffunction>
<CFSET Attributes.DS.MTRFN.GetEffflagHTML=GetEffflagHTML>

<cffunction name="DisplaySMSHistory" hint="Display claim SMS history" returntype="any" output="yes">
	<cfargument name="CASEID" required="true" type="numeric"
		displayname="The CaseID of the claim subfolder (DomainID=1). This is the unique reference running number for each claim subfolder and supplementary. Primary key for TRX0001."
		hint="CaseID for the claim subfolder.">
	<cfargument name="GCOID" required="true" type="numeric"
		displayname="SMS related to the group company"
		hint="">
	<cfargument name="IncRepairCard" required="false" default="0" type="numeric"
		displayname="Include adhoc SMS from repair card"
		hint="">
	<cfquery DATASOURCE=#Request.MTRDSN# NAME="GetRepCard">
	SELECT a.iREPAIRCARDID FROM TRX0001 a WITH (NOLOCK) WHERE a.iCASEID=<cfqueryparam value="#Arguments.CASEID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfquery DATASOURCE=#Request.MTRDSN# NAME="GetSMS">
	SELECT a.vaPHONENO,a.dtSMSSENT,a.VASMSBODY,a.iMSGSTAT
	FROM FMSG3010 a WITH (NOLOCK)
	WHERE a.iDOMAINID=1 AND a.iOBJID=<cfqueryparam value="#Arguments.CASEID#" cfsqltype="CF_SQL_INTEGER"> AND a.iGCOID=<cfqueryparam value="#Arguments.GCOID#" cfsqltype="CF_SQL_INTEGER">
	<cfif Arguments.IncRepairCard AND GetRepCard.iREPAIRCARDID GT 0>
	UNION ALL
	SELECT a.vaPHONENO,a.dtSMSSENT,VASMSBODY=CASE WHEN a.iGCOID=<cfqueryparam value="#Arguments.GCOID#" cfsqltype="CF_SQL_INTEGER"> THEN a.vaSMSBODY ELSE '(From '+b.vaCONAME+')' END,a.iMSGSTAT
	FROM FMSG3010 a WITH (NOLOCK),SEC0005 b WITH (NOLOCK)
	WHERE a.iDOMAINID=5 AND a.iOBJID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#GetRepCard.iREPAIRCARDID#"> AND a.iGCOID=b.iCOID
	</cfif>
	ORDER BY a.dtSMSSENT
	</cfquery>
	<CFOUTPUT>
	<cfif GetSMS.RecordCount GT 0>
		<br>
		<table class=clsClmBorder width=100%>
			<tr><td class=header colspan=4>#Server.SVClang("HISTORY OF SMS SENT",18012)#</tr>
			<tr class=clsColumnHeader><td align=left>#Server.SVCLang("No.",7055)#</td><td align=left>#Server.SVClang("Sent on",18013)#</td><td align=left>#Server.SVClang("Phone No",6855)#</td><td align=left>#Server.SVClang("Message",6856)#</td></tr>
			<cfloop query="GetSMS">
			<tr><td style=width:5ex>#CurrentRow#</td><td><CFIF iMSGSTAT GT 0>#Request.DS.FN.SVCdtDBtoLOC(dtSMSSENT,0,0,"STD")#<CFELSE>UNSENT</CFIF></td><td>#vaPHONENO#</td><td>#HTMLEditFormat(vaSMSBODY)#</td></tr>
			</cfloop>
		</table>
	</cfif>
	</CFOUTPUT>
	<CFRETURN>
</cffunction>
<CFSET Attributes.DS.MTRFN.DisplaySMSHistory=DisplaySMSHistory>


<CFFUNCTION name="CHKUPDTWorksheetRuleset" hint="Return true if ruleset is updated/different from trx0035/trx0095" returntype="any" output="true">
	<CFARGUMENT name="CASEID" required="true" type="numeric">
	<CFARGUMENT name="USID" required="true" type="numeric">
	<CFARGUMENT name="MODE" required="false" type="numeric" default="0">
	<CFARGUMENT name="COTYPE" required="false" type="string" default="I">
	<CFQUERY name="q_chkws" datasource="#Request.mtrdsn#">
		Declare @rsid int,@cursid int;
		DECLARE @caseid int = <cfqueryparam value="#Arguments.CASEID#" cfsqltype="cf_sql_integer">;
		DECLARE @acotype varchar(10) = <cfqueryparam value="#Arguments.COTYPE#" cfsqltype="cf_sql_nvarchar">;
		DECLARE @iusid int = <cfqueryparam value="#Arguments.USID#" cfsqltype="cf_sql_integer">;
		EXEC sspESTItmGetRuleset @ai_caseid=@caseid, @aa_cotype=@acotype, @ai_usid=@iusid, @ai_rulesetid=@rsid OUT,@ai_cur_rulesetid=@cursid OUT
		select newrs=@rsid,currs=@cursid
	</CFQUERY>
	<CFSET NEWRS=q_chkws.newrs>
	<CFSET CURRS=q_chkws.currs>

	<CFIF Arguments.MODE EQ 0>
		<CFIF NEWRS IS NOT "" AND CURRS IS NOT "">
			<CFIF (NEWRS NEQ CURRS)>
				<CFRETURN true>
			<CFELSEIF NEWRS EQ CURRS>
				<CFRETURN false>
			</CFIF>
		<CFELSE>
			<CFRETURN false>
		</CFIF>
	<CFELSEIF Arguments.MODE EQ 1>
		<!--- Other mode , if necessary --->
	</CFIF>

</CFFUNCTION>
<CFSET Attributes.DS.MTRFN.CHKUPDTWorksheetRuleset=CHKUPDTWorksheetRuleset>

<cffunction access="public" name="MTRDisplayCatastropheEventName" hint="return event/catastrophe name - EM0001 vaNAME" returntype="string" output=true description="">
    <CFARGUMENT name="CASEID" required="true" type="numeric">
    <CFARGUMENT name="EMID" required="false" type="numeric">

		<cfset result="">
		<CFIF Arguments.CASEID NEQ 0>
	    <CFQUERY name="q_geteventname" datasource="#Request.mtrdsn#">
			 SELECT b.vaNAME FROM
			 TRX0055 a WITH (NOLOCK)
			 LEFT JOIN EM0001 b WITH (NOLOCK) on a.iEMID = b.iEMID
			 WHERE a.iCASEID=<cfqueryparam value="#Arguments.CASEID#" cfsqltype="cf_sql_integer"> AND b.sistatus = 0
			</CFQUERY>
		<CFELSEIF Arguments.EMID NEQ 0>
			<CFQUERY name="q_geteventname" datasource="#Request.mtrdsn#">
			 SELECT b.vaNAME FROM
			 EM0001 b WITH (NOLOCK)
			 WHERE b.iEMID=<cfqueryparam value="#Arguments.EMID#" cfsqltype="cf_sql_integer"> AND b.sistatus = 0
			</CFQUERY>
		<CFELSE>
			<CFRETURN>
		</CFIF>

		<CFIF q_geteventname.vaNAME NEQ ""><cfset result=q_geteventname.vaNAME></CFIF>
		<CFRETURN result>

</cffunction>
<CFSET Attributes.DS.MTRFN.MTRDisplayCatastropheEventName=MTRDisplayCatastropheEventName>

<cffunction name="MTRSortUserApprovalLimit" description="sort user approval limit asc" access="public" returntype="struct" output="no">
	<cfargument name="CASEID" required="true" type="numeric">
	<cfargument name="GCOID" required="true" type="numeric">
	<cfargument name="RSVTYPE" required="false" type="string" DEFAULT="RSV">
	<cfargument name="CLMTYPEMASK" required="false" type="numeric" default=-1>
	<cfargument name="SORTTYPE" required="false" type="string" default="ASC">

	<CFIF RSVTYPE EQ "RSV"><CFSET GRPPERM=46><CFELSEIF RSVTYPE EQ "CLM"><CFSET GRPPERM=2></CFIF>
	<!--- @CFLintIgnore CFQUERYPARAM_REQ --->
	<CFQUERY name="q_approver" datasource=#request.mtrdsn#>
		SELECT vaUSNAME=a.vaUSNAME,a.vaUSID,a.iUSID,mnAPPLIMIT=CASE WHEN polgrp.iUSID IS NOT NULL THEN ISNULL(polgrp.mnAPPLIMIT,0) ELSE a.mnAPPLIMIT END
		from SEC0001 a WITH (NOLOCK)
		inner join SEC0005 b WITH (NOLOCK) on a.icoid=b.icoid and b.sistatus=0
		inner join dbo.fFSECUserPermissionByCoGroup(<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#GCOID#">,<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#GRPPERM#">) c on b.icoid=c.icoid and a.iusid=c.iusid
		LEFT JOIN CasePolGrpAcc ('#RSVTYPE#',<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.caseid#">,0,0,0,0,<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CLMTYPEMASK#">,0) polgrp ON a.iUSID=polgrp.iUSID
		WHERE a.siSTATUS=0 	AND a.iCLMTYPEACCMASK&<cfqueryparam value="#CLMTYPEMASK#" cfsqltype="CF_SQL_INTEGER">=<cfqueryparam value="#CLMTYPEMASK#" cfsqltype="CF_SQL_INTEGER">  <!---Only relevant claim type access users--->
	</CFQUERY>

	    <cfset apprvStructSort={APPRVLIMIT=StructNew(),APPRVUNLIMITED=StructNew(),APPRVKEYSORT=StructNew()}>
	    <CFLOOP query=q_approver>
		   <CFSET tStruct=StructNew()>
			<CFSET tStruct={iUSID= #iUSID#, vaUSID="#vaUSID#",vaUSName="#vaUSName#",RSVlimit="#mnAPPLIMIT#"}>
			<CFIF mnAPPLIMIT GTE 0><cfset apprvStructSort.APPRVLIMIT[tStruct.iUSID]=tStruct><CFELSE><cfset apprvStructSort.APPRVUNLIMITED[tStruct.iUSID]=tStruct></CFIF>
			<cfset apprvStructkey=StructSort(apprvStructSort.APPRVLIMIT, "numeric", "#SORTTYPE#","RSVlimit")>
		</CFLOOP>
		<CFIF  isDefined("apprvStructkey")>
			<cfset apprvStructSort.APPRVKEYSORT=apprvStructkey>
		</CFIF>
	<cfreturn apprvStructSort>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRSortUserApprovalLimit=MTRSortUserApprovalLimit>

<cffunction name="MTRChkApprovalLimitSGMSIG" description="return block string if doesnt meet limit validation" access="public"  returntype="struct" output="no">
	<cfargument name="CASEID" required="true" type="numeric">
	<cfargument name="GCOID" required="true" type="numeric">
	<cfargument name="USID" required="true" type="numeric">
	<cfargument name="OFFERAMT" required="true" type="numeric">
	<cfargument name="CLMNO" required="true" type="string">
	<cfargument name="CLMTYPEMASK" required="false" type="numeric" default=-1>
	<cfargument name="INCL_ALLRESVCODE" required="false" type="numeric" default=0>
	<CFSET blockstring="">
	<CFSET settlementLimit=0><CFSET reserveSet=0><CFSET reserveLimit=0><CFSET reservecode="">
	<CFSET lstreservecode=""><CFSET lstreserveSet=""> <!--- #40668 kofam --->
	<CFSET clmGrpList="">
	<CFSET clmGrpList=ListAppend(clmGrpList,(1+4+16))> <!--- OD group: OD,WS,TF --->
	<CFSET clmGrpList=ListAppend(clmGrpList,(2+1024+1073741824+2048))> <!--- TP group: TP,TPUL,TPSB,TPPD --->
	<CFSET clmGrpList=ListAppend(clmGrpList,(4096))> <!--- TPBI group: TPBI --->
	<CFSET clmGrp="">
	<CFLOOP INDEX=X LIST=#clmGrpList#>
		<CFIF BitAnd(arguments.CLMTYPEMASK,X) GT 0>
			<CFSET clmGrp=X>
			<CFBREAK>
		</CFIF>
	</CFLOOP>

	<!--- Settlement/Approval Limit --->
	<CFQUERY name="q_apprlimit" datasource=#request.mtrdsn#>
		SELECT mnAPPLIMIT=CASE WHEN polgrp.iUSID IS NOT NULL THEN ISNULL(polgrp.mnAPPLIMIT,0) ELSE a.mnAPPLIMIT END
		from SEC0001 a WITH (NOLOCK)
		inner join SEC0005 b WITH (NOLOCK) on a.icoid=b.icoid and b.sistatus=0
		inner join dbo.fFSECUserPermissionByCoGroup(200036,2) c on b.icoid=c.icoid and a.iusid=c.iusid
		LEFT JOIN CasePolGrpAcc ('CLM',<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.caseid#">,0,0,0,0,<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#CLMTYPEMASK#">,0) polgrp ON a.iUSID=polgrp.iUSID
		WHERE a.siSTATUS=0
		<CFIF arguments.CLMTYPEMASK NEQ -1> AND a.iCLMTYPEACCMASK&<cfqueryparam value="#arguments.CLMTYPEMASK#" cfsqltype="CF_SQL_INTEGER">=<cfqueryparam value="#CLMTYPEMASK#" cfsqltype="CF_SQL_INTEGER"></CFIF>  <!---Only relevant claim type access users--->
		AND a.iusid=<cfqueryparam value="#Arguments.USID#" cfsqltype="cf_sql_integer">
	</CFQUERY>

	<!--- current offer + previously approved offer by same person must not exceed approver settlement limit --->
	<!--- * offers - made for the same claim types in the file (same claim no.), not previously superceded --->
	<CFIF q_apprlimit.recordcount GT 0>
		<CFSET settlementLimit=q_apprlimit.mnAPPLIMIT>
		<CFIF settlementLimit NEQ -1>
			<CFQUERY name="q_totappr" datasource=#request.mtrdsn#>
				select totApr=isnull(sum(COALESCE((IsNull(a.mnCLMTOTINS,0)+isnull(a.mnCLMTOTDEDUCT,0)),est.MNTOTCLM,est.MNTOTAPPRV,a.mnTOTGROSS)),0)
				from TRX0008 a with (nolock) JOIN SEC0001 b with (nolock) on a.vaAUTHBY=b.vaUSID
				left join trx0035 est with (nolock) on est.ilcaseid = a.icaseid and est.acotype = 'I'
				where a.vaCLMNO=<cfqueryparam value="#Arguments.CLMNO#" cfsqltype="cf_sql_nvarchar">
				and b.iUSID=<cfqueryparam value="#Arguments.USID#" cfsqltype="cf_sql_integer">
				and a.icaseid <> <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.caseid#"> <!--- system is double counting approve amount: shouldn't include current offer --->
				<CFIF clmGrp NEQ ""> AND a.iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#clmGrp#"> > 0</CFIF> <!---Only relevant claim type --->
			</CFQUERY>
			<CFIF q_totappr.recordcount GT 0>
				<CFSET settlementLimit=(q_apprlimit.mnAPPLIMIT-q_totappr.totApr)>
			</CFIF>
		</CFIF>
	</CFIF>


	<!--- Reserve Limit check on rsv--->
	<CFSET ApprovalLimit=Request.DS.MTRFN.MTRgetUserCasePolGrpAcc("RSV",#arguments.usid#,#arguments.caseid#,0)>
	<CFSET reserveLimit=ApprovalLimit.LIMIT>

	<!--- Reserve Set --->
	<CFQUERY NAME=q_resv DATASOURCE=#Request.MTRDSN#>
		select iLCLMID=ISNULL(c.iLCLMID,0),ic.iGCOID,c.dtCLMREG,c.vaCLMNO,CLMTYPE=r.aCLAIMTYPE, c.iINSPOLID, 
		iTYPECLMMASK=ISNULL(c.iTYPECLMMASK,0) <!--- 40668 kofam --->
		FROM TRX0008 c WITH (NOLOCK)
		JOIN TRX0001 r WITH (NOLOCK) ON c.icaseid=r.icaseid
				INNER JOIN TRX0054 b ON c.iCASEID=b.iCASEID AND b.aCOTYPE='I'
				INNER JOIN SEC0005 ic ON c.iCOID=ic.iCOID
		WHERE c.iCASEID=<cfqueryparam value="#Arguments.CASEID#" cfsqltype="CF_SQL_INTEGER">
		ORDER BY c.iCASEID
	</CFQUERY>
	<CFIF q_resv.recordcount IS 0>
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCASE" ExtendedInfo="Item not found">
	</CFIF>
	
	<CFSET CLMID=q_resv.iLCLMID>
	<CFSET CLMTYPE=TRIM(q_resv.CLMTYPE)>

	<CFIF CLMID NEQ '' AND CLMID GT 0>
		<CFQUERY NAME=q_resvtype DATASOURCE=#Request.MTRDSN#>
			SELECT a.iRESVTYPE,a.iCLMRESVID,a.siCLMREGAUTO, BASECURRID=b.ibasecurrid
			FROM CLM0001 a WITH (NOLOCK)
			JOIN TRX0001 b with (nolock) ON a.iMAINCASEID=b.iCASEID
			WHERE a.iCLMID=<cfqueryparam value="#CLMID#" cfsqltype="CF_SQL_INTEGER">
		</CFQUERY>

		<CFIF q_resvtype.recordcount GT 0 AND q_resvtype.iCLMRESVID GT 0>
			<CFIF q_resvtype.iRESVTYPE IS 2 OR q_resvtype.iRESVTYPE IS 3>

				<cfif q_resv.iINSPOLID NEQ "">
					<!--- Get policy class --->
					<cfquery name="q_polClass" datasource="#REQUEST.MTRDSN#">
						SELECT vaPOLLOGICNAME
						FROM BIZ2011 WITH (NOLOCK)
						WHERE iCOID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ARGUMENTS.GCOID#">
						AND iPOLID = <cfqueryparam cfsqltype="cf_sql_integer" value="#q_resv.iINSPOLID#">
					</cfquery>
				<cfelse>
					<cfset q_polClass = queryNew("vaPOLLOGICNAME")>
				</cfif>

				<CFSET CLMFLOW=Left(q_resv.CLMTYPE,2)>
				<CFQUERY NAME=q_resvset DATASOURCE=#Request.MTRDSN#>
					select AMT=SUM(IsNull(a.mnAMT,0)),
					RESVCODE=a.vaRESVCODE
					FROM CLM0021 a WITH (NOLOCK)
					JOIN CLM0020 b WITH (NOLOCK) on a.iCLMRESV2ID=b.iCLMRESV2ID AND b.iCLMRESV2ID=<cfqueryparam value="#q_resvtype.iCLMRESVID#" cfsqltype="CF_SQL_INTEGER">
					WHERE b.iCLMID=<cfqueryparam value="#CLMID#" cfsqltype="CF_SQL_INTEGER">
					<!---<CFIF CLMTYPE EQ 'TP BI'>
						AND a.vaRESVCODE='TPBI'
					<CFELSEIF CLMFLOW EQ 'OD' OR (CLMFLOW EQ 'NM' AND NOT (LISTFINDNOCASE("NM LB,NM WC,NM TR,NM PA,NM MC,NM MH,NM FR,NM MSC",CLAIMTYPE)))> <!--- 37150 Add NM TR, NM PA Claimtype --->
						AND a.vaRESVCODE='OD'
					<CFELSEIF CLMFLOW EQ 'TP'>
						AND a.vaRESVCODE='TPPD'
					<CFELSEIF CLMTYPE EQ 'NM WC'>
						AND a.vaRESVCODE IN ((SELECT vaRESVCODE FROM CLMB0009 WHERE iIGCOID=200036 AND vaPOLCLASS='NM|1048576' AND vaRESVCODE != 'EX'))
					<CFELSEIF CLMTYPE EQ 'NM LB'>
						AND a.vaRESVCODE IN ((SELECT vaRESVCODE FROM CLMB0009 WHERE iIGCOID=200036 AND vaPOLCLASS='NM|16777216' AND vaRESVCODE != 'EX'))
					<!--- 37163 Add NM TR, NM PA Claimtype kofam --->
					<CFELSEIF CLMTYPE EQ 'NM TR'>
						AND a.vaRESVCODE IN ((SELECT vaRESVCODE FROM CLMB0009 WHERE iIGCOID=200036 AND vaPOLCLASS='NM|33554432' AND vaRESVCODE != 'EX'))
					<CFELSEIF CLMTYPE EQ 'NM PA'>
						AND a.vaRESVCODE IN ((SELECT vaRESVCODE FROM CLMB0009 WHERE iIGCOID=200036 AND vaPOLCLASS='NM|32768' AND vaRESVCODE != 'EX'))
					<!--- End 37163 kofam --->
					<CFELSEIF CLMTYPE EQ 'NM MC'>
						<!--- #38045: [SG] MSIG - Marine - Offer Authorization --->
						<cfif uCase(q_polClass.vaPOLLOGICNAME) EQ "BAILEE">
							AND a.vaRESVCODE IN ('TPD')
						<cfelse>
							AND a.vaRESVCODE IN ('MC','EX','OX')
						</cfif>
					<CFELSEIF CLMTYPE EQ 'NM MH'>
						<!--- #38045: [SG] MSIG - Marine - Offer Authorization --->
						AND a.vaRESVCODE IN ('RP','LH','TL','OX')
					<CFELSEIF CLMTYPE EQ 'NM FR'>
						AND a.vaRESVCODE IN ((SELECT vaRESVCODE FROM CLMB0009 WHERE iIGCOID=200036 AND vaPOLCLASS='NM|131072' AND vaRESVCODE != 'EX'))
					<CFELSEIF CLMTYPE EQ 'NM MSC'>
						AND a.vaRESVCODE IN ((SELECT vaRESVCODE FROM CLMB0009 WHERE iIGCOID=200036 AND vaPOLCLASS='NM|268435456' AND vaRESVCODE != 'EX'))
					</CFIF>--->
					<!--- #40350 ---> 
					<CFIF CLMTYPE EQ 'NM WC'>
						AND a.vaRESVCODE IN ((SELECT vaRESVCODE FROM CLMB0009 WHERE iIGCOID=200036 AND vaPOLCLASS='NM|1048576' <CFIF ARGUMENTS.INCL_ALLRESVCODE is 0> AND vaRESVCODE != 'EX'</CFIF>))
					<!--- 40668 Add NM ENG Claimtype kofam --->
					<CFELSEIF CLMTYPE EQ 'NM ENG'>
						AND a.vaRESVCODE IN ((SELECT vaRESVCODE FROM CLMB0009 WHERE iIGCOID=200036 AND vaPOLCLASS='NM|8388608' <CFIF ARGUMENTS.INCL_ALLRESVCODE is 0> AND vaRESVCODE != 'EX'</CFIF>))
					<!--- End 40668 kofam --->
					<CFELSEIF CLMTYPE EQ 'NM LB'>
						AND a.vaRESVCODE IN ((SELECT vaRESVCODE FROM CLMB0009 WHERE iIGCOID=200036 AND vaPOLCLASS='NM|16777216' <CFIF ARGUMENTS.INCL_ALLRESVCODE is 0> AND vaRESVCODE != 'EX'</CFIF>))
					<!--- 37163 Add NM TR, NM PA Claimtype kofam --->
					<CFELSEIF CLMTYPE EQ 'NM TR'>
						AND a.vaRESVCODE IN ((SELECT vaRESVCODE FROM CLMB0009 WHERE iIGCOID=200036 AND vaPOLCLASS='NM|33554432' <CFIF ARGUMENTS.INCL_ALLRESVCODE is 0> AND vaRESVCODE != 'EX'</CFIF>))
					<CFELSEIF CLMTYPE EQ 'NM PA'>
						AND a.vaRESVCODE IN ((SELECT vaRESVCODE FROM CLMB0009 WHERE iIGCOID=200036 AND vaPOLCLASS='NM|32768' <CFIF ARGUMENTS.INCL_ALLRESVCODE is 0> AND vaRESVCODE != 'EX'</CFIF>))
					<!--- End 37163 kofam --->
					<CFELSEIF CLMTYPE EQ 'NM MC'>
						<CFIF  ARGUMENTS.INCL_ALLRESVCODE IS 1>
							AND a.vaRESVCODE IN ((SELECT vaRESVCODE FROM CLMB0009 WHERE iIGCOID=200036 AND vaPOLCLASS IN ('NM|2097152','NM|2097152|BAILEE')))
						<CFELSE>
							<!--- #38045: [SG] MSIG - Marine - Offer Authorization --->
							<cfif uCase(q_polClass.vaPOLLOGICNAME) EQ "BAILEE">
								AND a.vaRESVCODE IN ('TPD')
							<cfelse>
								AND a.vaRESVCODE IN ('MC','EX','OX')
							</cfif>
						</CFIF>
					<CFELSEIF CLMTYPE EQ 'NM MH'>
						<CFIF  ARGUMENTS.INCL_ALLRESVCODE IS 1>
							AND a.vaRESVCODE IN ((SELECT vaRESVCODE FROM CLMB0009 WHERE iIGCOID=200036 AND vaPOLCLASS='NM|4194304'))
						<CFELSE>
							<!--- #38045: [SG] MSIG - Marine - Offer Authorization --->
							AND a.vaRESVCODE IN ('RP','LH','TL','OX')
						</CFIF>
					<CFELSEIF CLMTYPE EQ 'NM FR'>
						AND a.vaRESVCODE IN ((SELECT vaRESVCODE FROM CLMB0009 WHERE iIGCOID=200036 AND vaPOLCLASS='NM|131072' <CFIF ARGUMENTS.INCL_ALLRESVCODE is 0> AND vaRESVCODE != 'EX'</CFIF>))
					<CFELSEIF CLMTYPE EQ 'NM MSC'>
						AND a.vaRESVCODE IN ((SELECT vaRESVCODE FROM CLMB0009 WHERE iIGCOID=200036 AND vaPOLCLASS='NM|268435456' <CFIF ARGUMENTS.INCL_ALLRESVCODE is 0> AND vaRESVCODE != 'EX'</CFIF>))
					<CFELSEIF CLMTYPE EQ 'NM HS'>
						AND a.vaRESVCODE IN ((SELECT vaRESVCODE FROM CLMB0009 WHERE iIGCOID=200036 AND vaPOLCLASS='NM|524288' <CFIF ARGUMENTS.INCL_ALLRESVCODE is 0> AND vaRESVCODE != 'EX'</CFIF>))
					</CFIF>
					group by a.vaRESVCODE
				</CFQUERY>
								
				<CFIF q_resvset.recordcount IS 1>
					<CFSET reserveSet=q_resvset.AMT>
					<CFSET reservecode=q_resvset.RESVCODE>
					<!--- Start #40668 kofam --->
					<CFSET lstreserveSet="#q_resvset.AMT#">
					<CFSET lstreservecode=q_resvset.RESVCODE>
					<!--- End #40668 kofam --->
				<CFELSE>
					<CFLOOP query=q_resvset>
						<CFSET reserveSet=reserveSet+AMT>
						<CFSET reservecode=reservecode&'[#RESVCODE#]'>
						<!--- Start #40668 kofam --->
						<CFSET lstreserveSet=ListAppend(lstreserveSet,AMT)>
						<CFSET lstreservecode=ListAppend(lstreservecode,RESVCODE)>
						<!--- End #40668 kofam --->
					</CFLOOP>
				</CFIF>

				<CFIF CLMTYPE EQ 'NM HS'>
					<CFQUERY NAME=q_resvPaid DATASOURCE=#Request.MTRDSN#>
						SELECT nmhsPaid=sum(mnPAYAMT) FROM  CLM0006 
						WHERE iCLMID=<cfqueryparam value="#CLMID#" cfsqltype="CF_SQL_INTEGER"> AND siSTATUS=0 
						GROUP BY iCLMID
						<!--- SELECT 
						nmhsPaid=CASE WHEN EXISTS(
						SELECT 1 FROM CLMB0009 WHERE iIGCOID=200036 AND vaPOLCLASS='NM|16777216' AND vaRESVCODE = c.vaRESVCODE) THEN SUM(ISNULL(a.mn4,0)
						) ELSE 0 END
						FROM TRX0008 m with (nolock) 
						JOIN FOBJ3025 a WITH (NOLOCK) ON  a.iDOMID=1 AND a.iOBJID=m.icaseid AND a.siLOGTYPE=30 AND a.siSTATUS=0
						JOIN CLMB0009 c WITH (NOLOCK) on c.iIGCOID=200036 and c.iRESVDEFID=a.i7
						WHERE
						m.iLCLMID=<cfqueryparam value="#CLMID#" cfsqltype="CF_SQL_INTEGER">
						AND m.iCASEID=<cfqueryparam value="#Arguments.CASEID#" cfsqltype="CF_SQL_INTEGER"> AND 
						m.siTPINS=0 AND a.mn4 IS NOT NULL
						GROUP BY m.iCASEID,c.vaRESVCODE --->
					</CFQUERY>

					<CFIF q_resvPaid.recordcount GTE 1>
						<CFSET reserveSet=reserveSet-q_resvPaid.nmhsPaid>
					</CFIF>
				</CFIF>

			<CFELSE>

				<CFQUERY NAME=q_resvset DATASOURCE=#Request.MTRDSN#>
					SELECT
						b.mnRESERVECLM,
						b.mnRESERVEADJ,
						b.mnRESERVEADJTP,
						b.mnRESERVETPPD,
						b.mnRESERVEBI,
						b.mnRESERVEKFK,

						b.mnRESERVETPPDCHAIN,
						b.mnRESERVEMEDICAL,
						b.mnRESERVEOWNLEGAL,
						b.mnRESERVETPLEGALTP,
						b.mnRESERVETPLEGALBI,

						b.mnRESERVEPASSENGERS,
						b.mnRESERVEFLOOD,
						b.mnRESERVEFIRE,
						b.mnRESERVESPECIAL,
						b.mnRESERVEACCESSORY,

						b.mnRESERVEOTHERS,
						b.mnRESERVERECWRECK,
						b.mnRESERVERECKFK,
						b.mnRESERVERECSUBRO,

						b.mnRESERVESOL,
						b.mnRESERVECON,

						mnRESERVEMEDICALEXPENSE,
						mnRESERVEMLWAGES,
						mnRESERVEPICI,
						mnRESERVEEXPENSES,
						mnRESERVECOMMONLAW,

						CLMTYPEMASK=b.iODCLMTYPEMASK,OFRTYPE=b.iODOFRTYPE,TLTYPE=b.iODTLTYPE,b.txtNOTES
					FROM CLM0005 b WITH (NOLOCK)
						WHERE b.iCLMID=<cfqueryparam value="#CLMID#" cfsqltype="CF_SQL_INTEGER">
						AND b.iCLMRESVID=<cfqueryparam value="#q_resvtype.iCLMRESVID#" cfsqltype="CF_SQL_INTEGER">
				</CFQUERY>
				<CFSET TOTCLM=0><CFSET TOTADJ=0><CFSET TOTLEGAL=0><CFSET TOTTP=0><CFSET TOTJRNL=0><CFSET TOTREC=0><CFSET TOTBI=0><CFSET TOTWICA=0>
				<CFIF q_resvset.recordcount GT 0>
					<!--- might not need all this, but put first incase user request : for manual registration --->
					<CFSET RESVLIST="Clm,TPPD,BI,Adj,AdjTP,KFK,TPPDChain,Medical,OwnLegal,TPLegalTP,TPLegalBI,Fire,Flood,Special,Passengers,Accessory,Others,RecWreck,RecKFK,RecSubro,Sol,MEDICALEXPENSE,MLWAGES,PICI,EXPENSES,COMMONLAW">
					<CFSET XCNT=0><CFSET NEXTROW="">
					<CFSET TOTCLM=0><CFSET TOTADJ=0><CFSET TOTLEGAL=0><CFSET TOTTP=0><CFSET TOTJRNL=0><CFSET TOTREC=0><CFSET TOTBI=0><CFSET TOTWICA=0>

					<CFLOOP INDEX=X LIST=#RESVLIST#>
						<CFSET R=Evaluate("q_resvset.mnRESERVE#X#")>
						<CFIF R IS NOT "">
							<CFIF X IS "TPPD" OR X IS "TPPDChain">
								<CFSET TOTTP=TOTTP+R>
							<CFELSEIF  X IS "BI">
								<CFSET TOTBI=TOTBI+R>
							<CFELSEIF X IS "Adj" OR X IS "AdjTP">
								<CFSET TOTADJ=TOTADJ+R>
							<CFELSEIF X IS "OwnLegal" OR X IS "TPLegalTP" OR X IS "TPLegalBI" OR X IS "Sol">
								<CFSET TOTLEGAL=TOTLEGAL+R>
							<CFELSEIF X IS "Others">
								<CFSET TOTJRNL=TOTJRNL+R>
							<CFELSEIF X IS "RecWreck" OR X IS "RecKFK" OR X IS "RecSubro">
								<CFSET TOTREC=TOTREC+R>
							<CFELSEIF LISTFINDNOCASE("MEDICALEXPENSE,MLWAGES,PICI,EXPENSES,COMMONLAW",X)>
								<CFSET TOTWICA=TOTWICA+R>
							<CFELSE>
								<CFSET TOTCLM=TOTCLM+R>
							</CFIF>
						</CFIF>
					</CFLOOP>
				</CFIF>
				
				<!--- #40350 --->
				<!--- <CFIF LISTFINDNOCASE('OD,WS,SC,TF',CLMTYPE) OR (Left(CLMTYPE,2) EQ 'NM' AND CLMTYPE NEQ 'NM WC')> <!--- #33155 : bug fixed ; NM reserve same as OD --->
					<CFSET reserveSet=(TOTCLM-TOTTP-TOTBI-TOTADJ-TOTJRNL)>
					<CFSET reservecode="OD">
				<CFELSEIF LISTFINDNOCASE('TP,TP PD,TP UL,TP SB',CLMTYPE)>
					<CFSET reserveSet=TOTTP>
					<CFSET reservecode="TPPD">
				<CFELSEIF CLMTYPE EQ 'TP BI'>
					<CFSET reserveSet=TOTBI>
					<CFSET reservecode="TPBI">
				<CFELSEIF CLMTYPE EQ 'NM WC'>
					<CFSET reserveSet=TOTWICA>
					<CFSET reservecode="">
				</CFIF> --->
				<CFIF CLMTYPE EQ 'NM WC'>
					<CFSET reserveSet=TOTWICA>
					<CFSET reservecode="">
				<CFELSE>
					<CFSET reserveSet=TOTCLM>
				</CFIF>
			</CFIF>
		</CFIF>
	</CFIF>

	<!--- Start #40668 kofam --->
	<!--- Worksheet Set --->
	<CFIF ARGUMENTS.GCOID IS 200036 AND CLMTYPE IS "NM WC" AND INCL_ALLRESVCODE IS 0>
		<CFQUERY NAME=q_worksheet DATASOURCE=#Request.MTRDSN#>
			SELECT n.VARULEVARNAME, itemAmt=ISNULL(m.MNVAL1,0)
			FROM TRX0008 i WITH (NOLOCK)
			JOIN trx0035 b WITH (NOLOCK) ON i.icaseid=b.ilcaseid AND b.aCOTYPE='I'
			JOIN FITM0002 m WITH (NOLOCK) ON m.iitmgrpid=b.iitmgrpid
			JOIN FITR0002 n WITH (NOLOCK) ON m.iruleid=n.iruleid 
			WHERE i.iMAINCASEID=<cfqueryparam value="#Arguments.CASEID#" cfsqltype="CF_SQL_INTEGER">
			ORDER BY n.IRULEID
		</CFQUERY>
		<cfloop query="q_worksheet">
			<CFSET rsvCd="">
			<CFSET reserveAmt=0>
			<!--- Worksheet: Medical Leaves --->
			<CFIF VARULEVARNAME IS "WCML" AND itemAmt GT 0>
				<CFSET rsvCd="WL">
			<!--- Worksheet: Medical Expense --->
			<CFELSEIF VARULEVARNAME IS "WCME" AND itemAmt GT 0>
				<CFSET rsvCd="WM">
			<!--- Worksheet: Permanent Incapacity / Current Incapacity --->
			<CFELSEIF VARULEVARNAME IS "WCPI" AND itemAmt GT 0>
				<CFSET rsvCd="WP">
			<!--- Worksheet: Fatal --->
			<CFELSEIF VARULEVARNAME IS "WCFT" AND itemAmt GT 0>
				<CFSET rsvCd="WD">
			<!--- Worksheet: Negotiated Settlement --->
			<CFELSEIF VARULEVARNAME IS "WCST">
				<CFSET rsvCd="WL,WM,WP,WD,WC">
				<CFIF LEN(lstreserveSet) GT 0>
					<CFSET reserveAmt=ListChangeDelims(lstreserveSet,"+")>
					<CFSET reserveAmt=Evaluate(reserveAmt)>
				</CFIF>
			</CFIF>
			<!--- Get Specific Reserve Code Amount --->
			<CFIF ListContains(lstreservecode,rsvCd) GT 0>
				<CFSET reserveAmt=ListGetAt(lstreserveSet,ListContains(lstreservecode,rsvCd))>
			</CFIF>
			<!--- Check Specific Reserve Code Amount compare with Worksheet Amount --->
			<CFIF rsvCd IS NOT "" AND itemAmt GT reserveAmt>
				<CFSET blockstring=ListAppend(blockstring,"Insufficient reserve set (#rsvCd#) [S$#REQUEST.DS.FN.SVCNum(itemAmt)# -> S$#REQUEST.DS.FN.SVCNum(reserveAmt)#]","|")>
			</CFIF>
		</cfloop>

		<!---
		<!--- Type of Claim: Common Law (CL), Check Offer Amount --->
		<CFIF BitAnd(q_resv.iTYPECLMMASK,2) GT 0>
			<CFSET rsvCd="WC">
			<CFIF ListContains(lstreservecode,rsvCd) GT 0>
				<CFSET reserveAmt=ListGetAt(lstreserveSet,ListContains(lstreservecode,rsvCd))>
			</CFIF>
			<CFSET reservecode = "WC">
			<CFSET reserveSet = reserveAmt>
		<!--- Exclude --->
		<CFELSE>
			<CFSET reservecode = "">
			<CFSET reserveSet = OFFERAMT>
		</CFIF>
		--->

		<CFSET reservecode = "">
		<CFSET reserveSet = OFFERAMT>
	</CFIF>
	<!--- End #40668 kofam --->

	<CFIF OFFERAMT GT settlementLimit AND settlementLimit NEQ -1>
		<CFSET blockstring=ListAppend(blockstring,"The claim amount exceeds your approval limit [S$#REQUEST.DS.FN.SVCNum(OFFERAMT)# -> S$#REQUEST.DS.FN.SVCNum(settlementLimit)#]","|")>
	</CFIF>
	<CFIF OFFERAMT GT reserveSet>
		<CFIF  reservecode neq "">
			<CFSET blockstring=ListAppend(blockstring,"Insufficient reserve set (#reservecode#) [S$#REQUEST.DS.FN.SVCNum(OFFERAMT)# -> S$#REQUEST.DS.FN.SVCNum(reserveSet)#]","|")>
		<CFELSE>
			<CFSET blockstring=ListAppend(blockstring,"Insufficient reserve set [S$#REQUEST.DS.FN.SVCNum(OFFERAMT)# -> S$#REQUEST.DS.FN.SVCNum(reserveSet)#]","|")>
		</CFIF>
	</CFIF>
	<CFIF OFFERAMT GT reserveLimit AND reserveLimit NEQ -1>
			<CFSET blockstring=ListAppend(blockstring,"Insufficient Reserve Approval Limit [S$#REQUEST.DS.FN.SVCNum(OFFERAMT)# -> S$#REQUEST.DS.FN.SVCNum(reserveLimit)#]","|")>
	</CFIF>
	<CFSET results={BLOCKSTRING=blockstring,SETTLEMENTLIMIT=settlementLimit,RESERVESET=reserveSet,RESERVELIMIT=reserveLimit}>
	<CFRETURN results>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRChkApprovalLimitSGMSIG=MTRChkApprovalLimitSGMSIG>

<cffunction name="MTRgetSortInsCStat" description="Retrieve the insurer CSTAT list in desired order" access="public" returntype="string" output="no">
<cfargument name="GCOID" required="true" type="numeric">
<cfset var str="">
<CFIF arguments.GCOID IS 1100001 OR arguments.GCOID IS 1101213>
	<CFSET str="-5|0|1|41|2|31|27|47|25|43|44|45|40|39|42|37|38|24|26|28|3|10|11|12|20|4|5|23|6|46|17|18|7|21|22|30|15|29|32|35|8|16|19|36|900">
<CFELSE>
	<CFSET str="-5|41|0|1|2|31|27|47|25|43|44|45|40|39|42|37|38|24|26|28|49|50|51|52|3|10|11|12|20|4|5|23|6|46|17|18|7|21|22|30|48|15|29|32|35|8|16|19|36|900">
</CFIF>
<cfreturn str>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRgetSortInsCStat=MTRgetSortInsCStat>

<cffunction name="MTRshowHideRow" returntype="any" output="true">
	<cfargument name="id" type="string" required="false">
	<cfargument name="title" type="string" required="false">
	<CFOUTPUT>
		<CFSET var ret="<tr onclick=""JSVCShowHideRow('#id#','#id#_imgTog',2,true)"">  &emsp; <td class=""header""> <img  name=""#id#_imgTog"" src=""#request.apppath#services/images/minus.gif""> #title# </td></tr>">
		#ret#
	</CFOUTPUT>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRshowHideRow=MTRshowHideRow>

<cffunction name="MTRQueryReplaceValue" returntype="query" output="true">
	<cfargument name="qSource" type="query" required="true">
	<cfargument name="qTarget" type="query" required="true">
	<cfif qSource.recordcount GT 0>
		<cfif qTarget.recordcount IS 0><cfset QueryAddRow(qTarget)></cfif>
		<cfloop list="#qSource.columnList#" index="col">
			<cfif ListFindNoCase( qTarget.ColumnList, col)>
				<cfif qTarget.recordcount IS 0><cfset QueryAddRow(qTarget)></cfif>
				<cfset QuerySetCell(qTarget, col,evaluate("qSource.#col#"))>
			</cfif>
		</cfloop>
	</cfif>
	<cfreturn qTarget>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRQueryReplaceValue=MTRQueryReplaceValue>

<cffunction name="MTRAPChkAddAllow" description="to find out whether the USID is allowed to be added into current approval listing" access="public" returntype="struct">
	<!--- current built for UAE --->
	<cfargument name="DOMID" type="numeric" required="true">
	<cfargument name="OBJID" type="numeric" required="true">
	<cfargument name="APTRXID" type="numeric" required="true"><!--- with aptrxid to get the module, from module, to find out related aptrxid, and determine whether the usid has higher approval level --->
	<cfargument name="USID" type="numeric" required="true">
	<cfset var q_p=""><cfset var apmodule=""><cfset var aprevid=""><cfset var aplimit=""><cfset var apselector="">
	<cfset var ptid_aprevid=""><cfset var ptid_apgrpid=""><cfset var ptid_apgrpname=""><cfset var ptid_limit=""><cfset var ALLOWADD=0>
	<CFQUERY name="q_p" datasource=#request.mtrdsn#>
	SELECT counter=count(1) from fapm0002 with (nolock)
	where iaptrxid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.APTRXID#">
	AND iusid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.USID#">
	</cfquery>
	<cfif q_p.counter IS 0><!--- if the current aptrxid has no member specified ? --->
		<CFQUERY name="q_p" datasource=#request.mtrdsn#>
		select aprevid=a.iAPREVID, apmodule=b.vaMODULE, aplimit=b.mnlimit
		FROM fapm0003 c with (nolock)
		JOIN fapm0001 a with (nolock) ON c.iapmtid=a.iapmtid
		JOIN FAPD0005 b with (nolock) ON a.iAPREVID=b.iAPREVID
		where a.iaptrxid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.APTRXID#">
		AND c.idomainid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.DOMID#">
		AND c.iobjid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.OBJID#">
		</cfquery>
		<cfif q_p.recordcount NEQ 1><cfthrow TYPE="EX_DBERROR" ErrorCode="MTRFN/CHKAP1"></cfif>
		<!--- defined as current aptrxid's details --->
		<cfset apmodule=#q_p.apmodule#><cfset aprevid=#q_p.aprevid#><cfset aplimit=#q_p.aplimit#>
		<!--- to get iselector --->
		<cfif arguments.DOMID IS 1>
			<CFQUERY name="q_p" datasource=#request.mtrdsn#>
			select iclmtypemask from trx0001 with (nolock) where icaseid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.OBJID#">
			</cfquery>
			<cfset apselector=#q_p.iclmtypemask#>
			<cfif NOT(apselector GT 0)><CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADPARAM" EXTENDEDINFO="APSELECTOR(#apselector#)"></cfif><!--- should have clmtypemask --->
		<cfelse>
			<CFTHROW TYPE="EX_DBERROR" ErrorCode="BADPARAM"><!--- not applicable for non-domid=1 atm --->
		</cfif>
		<cfif aprevid GT 0 AND apmodule NEQ "">
			<cfif aplimit IS ""><cfset aplimit=-1></cfif>
			<CFQUERY name="q_p" datasource=#request.mtrdsn#>
			select TOP 1 a.iAPREVID, a.vaAPGRPID, a.mnLIMIT, APGRPNAME=c.vaGRPNAME
			FROM FAPD0005 a with (nolock)
			JOIN FAPD0006 e with (nolock) ON e.iCOID=a.iCOID AND e.vaMODULE=a.vaMODULE
			JOIN FAPD0002 c with (nolock) on c.vaAPGRPID=a.vaAPGRPID
			JOIN FAPD0003 b with (nolock) ON a.vaAPGRPID=b.vaAPGRPID AND b.iUSID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.USID#">
			WHERE a.vamodule=<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#apmodule#">
				AND a.sistatus=0 AND (ISNULL(e.iselector,-1)&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#apselector#">)>0
				<cfif aplimit IS -1><!--- require user with unlimited limit --->
				AND ISNULL(a.mnLIMIT,-1)=-1
				<cfelse>
				AND ( ISNULL(a.mnLIMIT,-1)=-1 OR (ISNULL(a.mnLIMIT,-1)>=0 AND a.mnLIMIT>=<cfqueryparam cfsqltype="CF_SQL_MONEY" value="#aplimit#">) )
				</cfif>
			ORDER BY a.mnLIMIT, a.iAPREVID
			</cfquery>
			<cfif q_p.recordcount GT 0>
				<cfset ALLOWADD=1><cfset ptid_aprevid=#q_p.iAPREVID#>
				<cfset ptid_apgrpid=#q_p.vaAPGRPID#><cfset ptid_limit=#q_p.mnLIMIT#><cfset ptid_apgrpname=#q_p.apgrpname#>
			</cfif>
		</cfif>
	</cfif>
	<!--- return vars --->
	<cfset var vars={}>
	<cfset StructInsert(vars,"ALLOW",ALLOWADD)>
	<cfset Structinsert(vars,"APREVID", ((ALLOWADD IS 1) ? ptid_aprevid : "") )>
	<cfset Structinsert(vars,"APGRPID", ((ALLOWADD IS 1) ? ptid_apgrpid : "") )>
	<cfset Structinsert(vars,"APGRPNAME", ((ALLOWADD IS 1) ? ptid_apgrpname : "") )>
	<cfset Structinsert(vars,"APLIMIT", ((ALLOWADD IS 1) ? ptid_limit : "") )>
	<cfreturn vars>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRAPChkAddAllow=MTRAPChkAddAllow>

<cffunction name="MTRGetTenderTypeIDByPerm" description="Get Tender Type ID user permission" access="public" returntype="string">
	<cfset tendertype="">
	<cfif Isarray(session.vars.plist) and arrayfindnocase(session.vars.plist,281) GT 0><!--- motor --->
		<cfset tendertype=listappend(tendertype,"1,2,3,4,5,6")><!--- with blank or unspecified tender type --->
	</cfif>
	<cfif Isarray(session.vars.plist) and arrayfindnocase(session.vars.plist,282) GT 0><!--- nonmotor --->
		<cfset tendertype=listappend(tendertype,"11")>
	</cfif>
	<cfreturn tendertype>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRGetTenderTypeIDByPerm=MTRGetTenderTypeIDByPerm>

<cffunction name="MTRGetPDWorksheetMode" description="GET TPPD Worksheet Mode (New for VN)" access="public" returntype="string">
	<cfargument name="claimtype" type="string" required="true">
	<cfset locid=session.vars.locid>
	<cfset PROPERTY_MODE=0>
	<cfif locid is 15 AND Arguments.claimtype IS "TP PD">
		<cfset PROPERTY_MODE=1>
	</cfif>
	<cfreturn PROPERTY_MODE>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRGetPDWorksheetMode=MTRGetPDWorksheetMode>

<cffunction name="MTRGetWorksheetParam" description="define default worksheet params for Item" access="public"  returntype="struct" output="yes">
	<cfargument name="caseid" type="numeric" required="true">
	<cfargument name="cmtid" type="numeric" required="true">
	<cfargument name="orgtype" type="string" required="true">
	<cfargument name="rsid" type="numeric" required="true">
	<cfset var q_ws="">
	<CFQUERY name="q_ws" datasource=#request.mtrdsn#>
	select imaincaseid, ilclmid from trx0008 with (nolock) where icaseid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.caseid#"> and siTPINS=0
	</CFQUERY>
	<cfset var MCASEID=#q_ws.imaincaseid#><cfset var CLMID=#q_ws.ilclmid#>
	<CFQUERY name="q_ws" datasource=#request.mtrdsn#>
	select vaRULESETNAME from fitr0001 where irulesetid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#rsid#">
	</CFQUERY>
	<cfset var RSNAME=q_ws.vaRULESETNAME>
	<cfset var DEFSETITM={}>
	<cfif RSNAME IS "PHTPBICTPL" OR RSNAME IS "PHTPBIOVTPL"><!--- to provide coverage for each item --->
		<cfset DEFSETITM={
			<!--- DI	Death Indemnity --->
			"DI"= {"ITMCVG"= 70000},
			<!--- BFE	Burial and Funeral Expenses --->
			"BFE"= {"ITMCVG"= 30000},
			<!--- HR	Hospital Rooms --->
			<!--- LAB	Laboratory exam fees, X-rays --->
			"LAB"= {"ITMCVG"= 2000},
			<!--- CF	Consultation Fee --->
			<!--- MEDEX	Medical Expenses --->
			"MEDEX"= {"ITMCVG"= 5000},
			<!--- DM	Drugs and Medicine --->
			"DM"= {"ITMCVG"= 20000},
			<!--- AMB	Ambulance --->
			"AMB"= {"ITMCVG"= 1500},
			<!--- PMD	Permanent Disablement --->
			<!--- OTR	Other Incidental Expenses --->
			"OTR"= {"ITMCVG"= 10000},

			<!--- SURGEX	surgical expenses (itmdtl limit : major=7500, med=5000, minor=1500)--->
			"SURGEX"= {"ITMDTL_CVG"= 2500},
			<!--- AGF	Anaesthesiologist's Fees (itmdtl limit : major=2500, med=2000, minor=500)--->
			"AGF"= {"ITMDTL_CVG"= 2500},
			<!--- OR	Operating Room (itmdtl limit :  major=1500, med=1000, minor=500)--->
			"OR"= {"ITMDTL_CVG"= 1500}

		}>
	<cfelseif RSNAME IS "PHTPBIVTPL"><!--- to bring forward figures from the previous CTPL --->
		<!--- voluntary claim with finalised CTPL claim
		MNVAL4 (claim amount) should be taken from CTPL's claim amount (MNVAL1A)
		MNVAL5 (CTPL Offer) should be taken from CTPL's offer amount (MNVAL1)
		--->
		<CFQUERY NAME="q_ws" DATASOURCE=#Request.MTRDSN#>
		DECLARE @li_cltid int
		SELECT @li_cltid=iCLTID from trx0085 with (nolock) WHERE icaseid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.caseid#"> AND iCMTID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.cmtid#"> and sistatus=0 /* with parent node of CLTID, to get related CMTID */
		/* get previous worksheet for respective claimant */
		SELECT CLAIMAMT=x.MNVAL1A, CTPLOFR=x.MNVAL1, NETCLMAMT=x.mnVAL9, RULEVARNAME=j.vaRULEVARNAME, ITMID=x.iITMID, ITM_NVAL3=x.NVAL3, ITM_NVAL3=x.NVAL3, ITM_MNVAL4=x.MNVAL4, ITM_MNVAL1=x.MNVAL1
		FROM FITM0002 x with (nolock)
		JOIN FITR0002 j with (nolock) ON x.IRULEID=j.IRULEID and vaPITM_rulevarname is null /* only grab the parent item only */
		WHERE x.iiTMGRPID IN (
			SELECT TOP 1 f.iitmgrpid
			FROM TRX0008 a with (nolock)
			JOIN CLM0004 b with (nolock) on a.icaseid=b.icaseid
			JOIN CLM0051 c with (nolock) on c.iclmid=b.iclmid
			JOIN CLM0051 h with (nolock) on c.iCLMRELID=h.iCLMRELID
			JOIN TRX0008 d with (nolock) on d.ilclmid=h.iclmid AND d.siTPINS=0
			JOIN TRX0001 g with (nolock) on g.icaseid=d.icaseid
			JOIN TRX0085 e with (nolock) on e.icaseid=d.icaseid AND e.icltid=@li_cltid
			JOIN TRX0095 f with (nolock) on f.icaseid=e.icaseid AND e.icmtid=f.icmtid and f.sistatus=0 AND f.acotype='I'
			/*and d.dtauth is not null*/ and g.sipolicycover=36 /* with CTPL claim */
			WHERE a.icaseid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.caseid#">
			ORDER BY a.icaseid DESC
		)
		</cfquery>
		<cfif q_ws.recordcount GT 0>
			<cfloop query="q_ws">
				<cfif NOT structkeyexists(DEFSETITM,RULEVARNAME)><cfset StructInsert(DEFSETITM,RULEVARNAME,structnew())></cfif>
				<cfset structinsert(DEFSETITM[RULEVARNAME],"LASTITMID",q_ws.ITMID)>
				<cfif LISTFINDNOCASE("PHILHEALTH,OTRDEDUCT",q_ws.RULEVARNAME)>
					<cfif q_ws.ITM_NVAL3 NEQ "">
						<cfset structinsert(DEFSETITM[RULEVARNAME],"ITM_NVAL3",evaluate(100-q_ws.ITM_NVAL3))><!--- philhealth % --->
					<cfelse>
						<cfset structinsert(DEFSETITM[RULEVARNAME],"ITM_NVAL3","")><!--- philhealth % --->
					</cfif>
					<cfset structinsert(DEFSETITM[RULEVARNAME],"ITM_MNVAL4",q_ws.ITM_MNVAL4)><!--- philhealth rate --->
					<cfif DEFSETITM[RULEVARNAME].ITM_NVAL3 NEQ "" AND DEFSETITM[RULEVARNAME].ITM_MNVAL4 NEQ "">
						<cfset structinsert(DEFSETITM[RULEVARNAME],"ITMTOTOFR",evaluate(DEFSETITM[RULEVARNAME].ITM_NVAL3/100*DEFSETITM[RULEVARNAME].ITM_MNVAL4))>
					</cfif>
				<cfelse>
					<cfset structinsert(DEFSETITM[RULEVARNAME],"ITM_MNVAL4",q_ws.CLAIMAMT)>
					<cfset structinsert(DEFSETITM[RULEVARNAME],"ITM_MNVAL5",q_ws.CTPLOFR)>
					<cfset structinsert(DEFSETITM[RULEVARNAME],"ITM_MNVAL9",q_ws.NETCLMAMT)>
					<cfset tot="">
					<!--- calc EBI (ITM_MNVAL6) = Nett claim amount - CTPL offer --->
					<cfif q_ws.CTPLOFR IS 0 OR q_ws.CTPLOFR IS "">
						<cfset tot=#q_ws.CTPLOFR#>
						<cfset structinsert(DEFSETITM[RULEVARNAME],"ITM_MNVAL6",tot)>
					<cfelseif q_ws.NETCLMAMT NEQ "">
						<cfif q_ws.NETCLMAMT GT q_ws.CTPLOFR>
							<cfset tot=#evaluate(q_ws.NETCLMAMT-q_ws.CTPLOFR)#>
							<cfset structinsert(DEFSETITM[RULEVARNAME],"ITM_MNVAL6",tot)>
						<cfelse>
							<!--- <cfset structinsert(DEFSETITM[RULEVARNAME],"ITM_MNVAL6",0)> --->
							<cfset structinsert(DEFSETITM[RULEVARNAME],"ITM_MNVAL6","")>
						</cfif>
					</cfif>
					<!--- <cfif DEFSETITM[RULEVARNAME].ITM_MNVAL6 GT 0> --->
						<cfset structinsert(DEFSETITM[RULEVARNAME],"ITM_MNVAL10",DEFSETITM[RULEVARNAME].ITM_MNVAL6)>
						<cfset structinsert(DEFSETITM[RULEVARNAME],"ITMTOTOFR",DEFSETITM[RULEVARNAME].ITM_MNVAL6)>
					<!--- </cfif> --->
				</cfif>
			</cfloop>
		</cfif>
	</cfif>

	<cfif LISTFINDNOCASE("PHTPBICTPL,PHTPBIVTPL,PHTPBIOVTPL",RSNAME)>
		<!--- get the PMD listing --->
		<cfquery NAME=q_listpmd DATASOURCE=#Request.SVCDSN#>
		select IDX=iLINE, STATUS=sistatus, TXT=vaP1 + case when sistatus=1 THEN ' [DELETED]' ELSE '' END, LIMIT=mn1 from FTBL0001 with (nolock)
		WHERE IICOID=0 and VATBLCODE='WSITM_PH_PMDTYPE'
		ORDER BY vaP1
		</cfquery>
		<cfif q_listpmd.recordcount GT 0>
			<cfif NOT structkeyexists(DEFSETITM,"PMD")><cfset StructInsert(DEFSETITM,"PMD",structnew())></cfif>
			<cfset structinsert(DEFSETITM["PMD"],"WSITM_PMDTYPE",DEserializeJSON(serializeJSON(q_listpmd)))><!---struct in string --->
		</cfif>
		<!--- get the SURGEX listing --->
		<cfquery NAME=q_listpmd DATASOURCE=#Request.SVCDSN#>
		select IDX=iLINE, STATUS=sistatus, TXT=vaP1 + case when sistatus=1 THEN ' [DELETED]' ELSE '' END, LIMIT=mn1 from FTBL0001 with (nolock)
		WHERE IICOID=0 and VATBLCODE='WSITM_PH_SURGEX'
		ORDER BY vaP1
		</cfquery>
		<cfif q_listpmd.recordcount GT 0>
			<cfif NOT structkeyexists(DEFSETITM,"SURGEX")><cfset StructInsert(DEFSETITM,"SURGEX",structnew())></cfif>
			<cfset structinsert(DEFSETITM["SURGEX"],"WSITM_SURGEX",DEserializeJSON(serializeJSON(q_listpmd)))><!---struct in string --->
		</cfif>
		<!--- get the AGF listing --->
		<cfquery NAME=q_listpmd DATASOURCE=#Request.SVCDSN#>
		select IDX=iLINE, STATUS=sistatus, TXT=vaP1 + case when sistatus=1 THEN ' [DELETED]' ELSE '' END, LIMIT=mn1 from FTBL0001 with (nolock)
		WHERE IICOID=0 and VATBLCODE='WSITM_PH_AGF'
		ORDER BY vaP1
		</cfquery>
		<cfif q_listpmd.recordcount GT 0>
			<cfif NOT structkeyexists(DEFSETITM,"AGF")><cfset StructInsert(DEFSETITM,"AGF",structnew())></cfif>
			<cfset structinsert(DEFSETITM["AGF"],"WSITM_AGF",DEserializeJSON(serializeJSON(q_listpmd)))><!---struct in string --->
		</cfif>
		<!--- get the OR listing --->
		<cfquery NAME=q_listpmd DATASOURCE=#Request.SVCDSN#>
		select IDX=iLINE, STATUS=sistatus, TXT=vaP1 + case when sistatus=1 THEN ' [DELETED]' ELSE '' END, LIMIT=mn1 from FTBL0001 with (nolock)
		WHERE IICOID=0 and VATBLCODE='WSITM_PH_OR'
		ORDER BY vaP1
		</cfquery>
		<cfif q_listpmd.recordcount GT 0>
			<cfif NOT structkeyexists(DEFSETITM,"OR")><cfset StructInsert(DEFSETITM,"OR",structnew())></cfif>
			<cfset structinsert(DEFSETITM["OR"],"WSITM_OR",DEserializeJSON(serializeJSON(q_listpmd)))><!---struct in string --->
		</cfif>
	</cfif>

	<!--- return vars --->
	<cfset var vars={}>
	<cfset StructInsert(vars,"DEFSETITM",DEFSETITM)>
	<cfset Structinsert(vars,"ERROR","")>
	<cfreturn vars>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRGetWorksheetParam=MTRGetWorksheetParam>

<cffunction name="MTRSGGIADataMask" returntype="string" output="true" access="public">
	<cfargument name="strOri" type="string" required="true">
	<cfargument name="gendoc" type="numeric" required="false" default="0"><!--- to generate document, always mask --->
	<CFIF Len(strOri) GT 5>
		<CFSET strMask=Left(strOri, 1) & RepeatString("X", Len(strOri) - 5) & Right(strOri, 4)>
	<CFELSE>
		<CFSET strMask=strOri>
	</CFIF>
	<!--- Temporary disable masking until further notice --->
	<!--- <CFIF ListFindNoCase("PROD",Application.DB_MODE) AND gendoc NEQ 1>
		<CFSET strMask=strOri>
	</CFIF> --->
	<cfreturn strMask>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRSGGIADataMask=MTRSGGIADataMask>

<cffunction name="fMultiAssign2" returntype="struct" output="false" access="public">
<cfargument name="CASEID" type="numeric" required="true">
<cfargument name="EXTID" type="numeric" required="true">
<cfargument name="COTYPE" type="string" required="true">
<cfset var q_multi={}>
<cfset var str={ MultiFlag=0, MultiAssignID=0, CotypeSuffix="",WorkingCotype="",WorkingCotype_R="",MultiAssignID_R=0,MultiClmTable=0 }>
<cfquery NAME=q_multi DATASOURCE=#Request.MTRDSN#>
SELECT MultiFlag,MultiAssignID,CotypeSuffix,WorkingCotype,WorkingCotype_R,MultiAssignID_R,MultiClmTable
FROM fMultiAssign2(<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.CASEID#">,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.EXTID#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.COTYPE#">)
</cfquery>
<cfset str.MultiFlag=q_multi.MultiFlag>
<cfset str.MultiAssignID=q_multi.MultiAssignID>
<cfset str.CotypeSuffix=q_multi.CotypeSuffix>
<cfset str.WorkingCotype=q_multi.WorkingCotype>
<cfset str.WorkingCotype_R=q_multi.WorkingCotype_R>
<cfset str.MultiAssignID_R=q_multi.MultiAssignID_R>
<cfset str.MultiClmTable=q_multi.MultiClmTable>
<cfreturn str>
</cffunction>
<cfset Attributes.DS.MTRFN.fMultiAssign2=fMultiAssign2>

<cffunction name="fFeatureOnOff" returntype="struct" output="false" access="public">
<cfargument name="CaseID" type="numeric" required="true">
<cfargument name="Feature" type="string" required="true">
<cfset var q_feat={}>
<cfset var str={ On=0, SubFeature="" }>
<cfquery NAME=q_feat DATASOURCE=#Request.MTRDSN#>
SELECT siON,vaSUBFEATURE
FROM fFeatureOnOff(<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.CaseID#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Feature#">)
</cfquery>
<cfset str.On=q_feat.siON>
<cfset str.SubFeature=q_feat.vaSUBFEATURE>
<cfreturn str>
</cffunction>
<cfset Attributes.DS.MTRFN.fFeatureOnOff=fFeatureOnOff>

<cffunction name="MTRMaskData" returntype="string" output="false" access="public">
	<cfargument name="data" type="string" required="true">
	<cfargument name="maskFormat" type="string" required="true">
	<cfargument name="replaceData" type="string" required="true">
	<cfargument name="visibleChar" type="numeric" required="false">
	<CFSET startChar=1>
	<CFSET str=''>
	<CFIF IsDefined('visibleChar') AND visibleChar IS NOT "">
		<CFSET str=LEFT(data,visibleChar)>
		<CFSET startChar=visibleChar+1>
	</CFIF>
	<CFSET str&=REReplace(mid(data,startChar,LEN(data)), maskFormat, replaceData, "ALL")>
	<cfreturn str>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRMaskData=MTRMaskData>

<!--- Aisyah #44065 --->
<cffunction name="MTRMaskDataPolNo" returntype="string" output="false" access="public">
	<cfargument name="data" type="string" required="true">
	<cfargument name="maskFormat" type="string" required="true">
	<cfargument name="replaceData" type="string" required="true">
	<cfargument name="visibleFChar" type="numeric" required="false">
	<cfargument name="visibleLChar" type="numeric" required="false">
	
	<CFSET startChar=1>
	<CFSET str=''>
	<CFIF (IsDefined('visibleFChar') AND visibleFChar IS NOT "") AND (IsDefined('visibleLChar') AND visibleLChar IS NOT "")>
		<CFSET first=LEFT(data,visibleFChar)>
		<CFSET last=RIGHT(data,visibleLChar)>
	</CFIF>

	<CFIF len(data) LTE 8>
		<CFSET str&=data>
	<CFELSE>
		<CFSET str&=first&REReplace(mid(data,5,len(data)-8), maskFormat, replaceData, "ALL")&last>
	</CFIF>
	<cfreturn str>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRMaskDataPolNo=MTRMaskDataPolNo>

<CFFUNCTION name="rhbNMCHKNOTIDAY" returntype="string" output="true" access="public">
	<CFARGUMENT name="OBJID" type="numeric" required="false">
	<CFARGUMENT name="MODE" type="numeric" required="false" default="0">
	<CFARGUMENT name="ACCDATE" type="string" required="false" default="">
	<CFARGUMENT name="NOTIDATE" type="string" required="false" default="">

	<CFIF MODE EQ 2><!--- Gen JS struct --->
		<CFQUERY name="qRHBCHNOTIDAY" datasource="#Request.MTRDSN#">
			select NOTIDAY=vaCFMAPCODE,CODE=b.vaCODE,CLASSID=b.iINSCLASSID
			FROM BIZ0025 c WITH(NOLOCK)
			JOIN BIZ2010 b WITH(NOLOCK) ON LTRIM(RTRIM(c.vaCFCODE))=LTRIM(RTRIM(b.vaCODE))
			WHERE c.aCFTYPE='NMCLMNOTREM'
			AND b.iCOID=67
		</CFQUERY>
		<script>
			var rhbnotday=[<CFOUTPUT query="qRHBCHNOTIDAY">[#CLASSID#,#NOTIDAY#],</CFOUTPUT>];
			var classid=$('##INSCLASSID').val();
			var accdate='#ACCDATE#';
			var notidate=#NOTIDATE IS NOT ""?"'"&NOTIDATE&"'":"$('##sleNotify').val()"#;
		</script>
	<CFELSE>
		<CFQUERY name="qRHBCHNOTIDAY" datasource="#Request.MTRDSN#">
			select NOTIDAY=vaCFMAPCODE,NOTIDATE=a.dtINSNOTIFY,ACCDATE=d.dtACCDATE
			FROM BIZ0025 c WITH(NOLOCK)
			JOIN BIZ2010 b WITH(NOLOCK) ON LTRIM(RTRIM(c.vaCFCODE))=LTRIM(RTRIM(b.vaCODE))
			JOIN TRX0008 a WITH(NOLOCK) ON b.iINSCLASSID=a.iINSCLASSID
			JOIN TRX0001 d WITH(NOLOCK) ON a.iCASEID=d.iCASEID
			WHERE a.iINSGCOID=67
			AND c.aCFTYPE='NMCLMNOTREM'
			AND a.iCASEID=<cfqueryparam value="#OBJID#" cfsqltype="cf_sql_integer">
		</CFQUERY>


			<CFIF MODE EQ 1>
				<CFIF qRHBCHNOTIDAY.Recordcount GT 0>
					<CFRETURN qRHBCHNOTIDAY.NOTIDAY>
				<CFELSE>
					<CFRETURN 0>
				</CFIF>
			<CFELSE>
				<CFIF qRHBCHNOTIDAY.Recordcount GT 0>
					<CFRETURN dateDiff('d',qRHBCHNOTIDAY.ACCDATE,qRHBCHNOTIDAY.NOTIDATE) GT qRHBCHNOTIDAY.NOTIDAY ? true:false>
				<CFELSE>
					<CFRETURN false>
				</CFIF>
			</CFIF>
	</CFIF>
</CFFUNCTION>
<cfset Attributes.DS.MTRFN.rhbNMCHKNOTIDAY=rhbNMCHKNOTIDAY>

<cffunction name="MTRClientPortalStat" returntype="string" output="true" access="public">
	<cfargument name="FILESTAT" type="string" required="true">
	<cfargument name="IIGCOID" type="numeric" required="true">
	<cfargument name="CLAIMTYPE" type="string" required="true">
	<cfargument name="LOCID" type="numeric" required="true">
	<cfargument name="siRSNID" type="numeric" required="true" default="0">
	<cfargument name="siOFRTYPE" type="numeric" required="true" default="0">
	<cfargument name="lgdef_claimfilestatus" type="any" required="false" default="0">
	<cfset stat="">
	<cfset CLMFLOW=Left(CLAIMTYPE,2)>
	<!--- general --->
	<cfswitch expression=#FILESTAT#>
		<cfcase value="0" delimiters=",">
			<cfif CLMFLOW IS "NM">
				<cfset stat="#request.DS.FN.SVClang("This claim is Pending Processing by Insurer",13314,lgdef_claimfilestatus)#">
			<cfelse>
				<cfset stat="#request.DS.FN.SVClang("This claim is Pending Repair Estimate",13315,lgdef_claimfilestatus)#">
			</cfif>
		</cfcase>
		<cfcase value="24,26" delimiters=","> <cfset stat="#request.DS.FN.SVClang("This claim is Pending Document",13316,lgdef_claimfilestatus)#"></cfcase>
		<cfcase value="2,25,27" delimiters=","> <cfset stat="#request.DS.FN.SVClang("This claim is Pending Adjuster Survey",13317,lgdef_claimfilestatus)#"></cfcase>
		<cfcase value="5,18" delimiters=","> <cfset stat="#request.DS.FN.SVClang("This claim has been approved",13318,lgdef_claimfilestatus)#"></cfcase>
		<cfcase value="23" delimiters=","> <cfset stat="#request.DS.FN.SVClang("This claim is Pending Claimant Acceptance",31651,lgdef_claimfilestatus)#"></cfcase>
		<cfcase value="22" delimiters=","> <cfset stat="#request.DS.FN.SVClang("This claim is Pending Signed DV & Final Bill",13319,lgdef_claimfilestatus)#"></cfcase>
		<cfcase value="6" delimiters=","> <cfset stat="#request.DS.FN.SVClang("This claim is Pending for reinspection after repair",13320,lgdef_claimfilestatus)#"></cfcase>
		<cfcase value="8" delimiters=","> <cfset stat="#request.DS.FN.SVClang("This claim is Pending for Payment",13321,lgdef_claimfilestatus)#"></cfcase>
		<cfcase value="36,999" delimiters=",">
			<cfif (CLMFLOW IS "NM" AND siRSNID IS 1) OR (CLMFLOW IS "NM" AND FILESTAT IS 36) OR CLAIMTYPE IS "TF" OR (CLMFLOW NEQ "NM" AND siOFRTYPE IS 3 AND siRSNID IS 1) OR (CLAIMTYPE IS "TP UL" AND siRSNID IS 1)><!--- nonmotor OR MTR in total loss --->
				<cfset stat="#request.DS.FN.SVClang("This claim is settled",13322,lgdef_claimfilestatus)#">
			<cfelse>
				<cfif siRSNID IS 1>
				<cfset stat="#request.DS.FN.SVClang("The vehicle has been <b>fully repaired</b>",13323,lgdef_claimfilestatus)#">
				<cfelseif siRSNID IS 3>
				<cfset stat="#request.DS.FN.SVClang("This claim is cancelled",13324,lgdef_claimfilestatus)#">
				<cfelseif siRSNID NEQ "" AND NOT(LOCID IS 7)>
				<cfset stat="This claim is <b>#request.ds.CLMCLOSERSNID[siRSNID]#</b>">
				<cfelse>
				<cfset stat="#request.DS.FN.SVClang("This claim is settled",13322,lgdef_claimfilestatus)#">
				</cfif>
			</cfif>
		</cfcase>
		<cfcase value="30" delimiters=","><!--- request from Customization #13216 [ID] - All Insurer - Motor Claims - Revise some Status Description on Customer Portal --->
			<cfif LOCID IS 7>
				<cfset stat="#request.DS.FN.SVClang("The vehicle has been <b>fully repaired</b>",13323,lgdef_claimfilestatus)#">
			<cfelse>
				<cfset stat="#request.DS.FN.SVClang("This claim is Pending Processing by Insurer",13314,lgdef_claimfilestatus)#">
			</cfif>
		</cfcase>
		<cfdefaultcase>
			<cfset stat="#request.DS.FN.SVClang("This claim is Pending Processing by Insurer",13314,lgdef_claimfilestatus)#">
		</cfdefaultcase>
	</cfswitch>
	<cfif IIGCOID IS 702933 AND FILESTAT GT 0 AND FILESTAT NEQ 0 AND FILESTAT NEQ 999> <cfset stat&="(#Server.SVClang(Request.DS.ISTAT[FILESTAT],REQUEST.DS.ISTAT["LID_#FILESTAT#"])#)"></cfif>
	<cfreturn stat>
</cffunction>
<cfset Attributes.DS.MTRFN.MTRClientPortalStat=MTRClientPortalStat>

<cffunction name="MTREstGetWorksheetRS" returntype="struct" output="false" access="public">
	<cfargument name="CASEID" type="numeric" required="true">
	<cfargument name="COTYPE" type="string" required="true">
	<cfset var str={ WORKSHEET=0, RULESETID="", RULESETCODE="", CASE_RULESETID="", CASE_ITMGRPID="", CASE_RULESETCODE="" }>
	<cfset var rsID=""><cfset var rsNAME=""><cfset var cur_rsID=""><cfset var cur_igID=""><cfset var cur_curid=""><cfset var cur_rsnm="">
	<CFSTOREDPROC PROCEDURE="sspESTItmGetRuleset" DATASOURCE=#REQUEST.MTRDSN# RETURNCODE=YES>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#arguments.CASEID# DBVARNAME=@ai_caseid>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_CHAR VALUE=#arguments.COTYPE# DBVARNAME=@aa_cotype>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#SESSION.VARS.USID# DBVARNAME=@ai_usid>
		<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_INTEGER VARIABLE=rsID VALUE=0 DBVARNAME=@ai_rulesetid>
		<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_VARCHAR VARIABLE=rsNAME VALUE="" DBVARNAME=@as_rulesetname>
		<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_INTEGER VARIABLE=cur_rsID VALUE=0 DBVARNAME=@ai_cur_rulesetid>
		<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_INTEGER VARIABLE=cur_igID VALUE=0 DBVARNAME=@ai_cur_itmgrpid>
		<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_INTEGER VARIABLE=cur_curid VALUE=0 DBVARNAME=@ai_cur_currencyid>
		<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_VARCHAR VARIABLE=cur_rsnm VALUE="" DBVARNAME=@as_cur_rulesetname>
	</cfstoredproc>
	<cfif CFSTOREDPROC.STATUSCODE LT 0>
		<cfthrow TYPE="EX_DBERROR" ErrorCode="EST/GETRULESET(#CFSTOREDPROC.STATUSCODE#)">
	</cfif>
	<cfif CFSTOREDPROC.STATUSCODE LT 0>
		<cfthrow TYPE="EX_DBERROR" ErrorCode="EST/GETRULESET(#CFSTOREDPROC.STATUSCODE#)">
	</cfif>
	<CFIF rsID GT 0><cfset str.WORKSHEET=1></CFIF>
	<cfset str.RULESETID=#rsID#>
	<cfset str.RULESETCODE=#rsNAME#>
	<cfset str.CASE_RULESETID=#cur_rsID#>
	<cfset str.CASE_ITMGRPID=#cur_igID#>
	<cfset str.CASE_RULESETCODE=#cur_rsnm#>

	<cfreturn str>
</cffunction>
<cfset Attributes.DS.MTRFN.MTREstGetWorksheetRS=MTREstGetWorksheetRS>

<cffunction name="IsPanel" returntype="boolean" output="yes">
	<cfargument name="pnlfor" type="numeric" required="true">
	<cfargument name="paneltype" type="numeric" required="false">
	<cfargument name="iSUBCOTYPEFLAG" type="numeric" required="false">
	<cfquery DATASOURCE=#Request.MTRDSN# NAME="q_trx">
		SELECT 1
		FROM TRX0030 pnl WITH (NOLOCK)
		JOIN SEC0005 co WITH (NOLOCK) ON co.iCOID=pnl.iPNLCOID
		WHERE PNL.iPNLCOID=<cfqueryparam value="#session.vars.gcoid#" cfsqltype="CF_SQL_INTEGER">
		AND pnl.iCOID=<cfqueryparam value="#arguments.pnlfor#" cfsqltype="cf_sql_integer">
		<CFIF IsDefined('arguments.paneltype')>
			AND pnl.siPNLTYPE=<cfqueryparam value="#arguments.paneltype#" cfsqltype="cf_sql_integer">
		</CFIF>
		<CFIF IsDefined('arguments.iSUBCOTYPEFLAG')>
			AND co.iSUBCOTYPEFLAG=<cfqueryparam value="#arguments.iSUBCOTYPEFLAG#" cfsqltype="cf_sql_integer">
		</CFIF>
	</cfquery>
	<CFRETURN q_trx.RecordCount GT 0>
</cffunction>
<CFSET Attributes.DS.MTRFN.IsPanel=IsPanel>
<cffunction name="GenDirectPay" output=yes>
<cfargument name="caseid" type=numeric>
<cfargument name="showbtn" type="numeric" default="1">
<CFQUERY DATASOURCE=#Request.MTRDSN# NAME="q_fpay">
	SELECT b.vaCONAME,a.IBANKCOID,b.iGCOID,gcoidname=c.vaconame,b.VABRANCHCODE,
			a.siBANKTYPE,
			a.vaACCNAME,
			a.vaACCNO,
			a.siCHQTYPE,
			a.vaPAYRMK,
			a.vaPAYTAXID,
			a.vaPAYADD,a.siPAYTYPE,b.vacobrname
	FROM FPAY0014 a WITH (NOLOCK)
	LEFT OUTER JOIN SEC0005 b WITH (NOLOCK) ON a.iBANKCOID = b.iCOID
	LEFT OUTER JOIN SEC0005 c WITH (NOLOCK) ON c.icoid = b.igcoid
	WHERE a.iCASEID = <cfqueryparam value="#caseid#" cfsqltype="CF_SQL_INTEGER"> and a.ilogid = 0 and siDIRECTYPE = 0
</cfquery>
<CFQUERY DATASOURCE=#Request.MTRDSN# NAME="q_taskinfo">
	SELECT TOP 1 a.assocObj,a.iTaskID,a.iObjID,a.dtApply,asgnname=b.vaUSName
	FROM FTSK0001 a WITH (NOLOCK)
	LEFT JOIN SEC0001 b WITH (NOLOCK) ON a.iObjID = b.iUSID
	WHERE a.assocDomain = 1 AND a.assocObj = <cfqueryparam value="#caseid#" cfsqltype="CF_SQL_INTEGER"> AND a.vaSubject LIKE '%+ Due%'
	ORDER BY a.iTaskID DESC
</cfquery>
<CFIF (q_fpay.recordcount GTE 0 AND showbtn EQ 1) OR (q_fpay.recordcount GT 0 AND showbtn EQ 0)>
			<CFIF showbtn EQ 1>
			<input type=button class=clsButton value="Direct Pay" onclick="MTRpopDirectPay(#attributes.caseid#,0)">
			<CFIF q_fpay.recordcount GT 0>
			<input type=button class=clsButton value="Delivery Form" onclick="MTRDeliveryForm(#attributes.caseid#,0)">
			</CFIF>
			<input type=checkbox value="Auto Task to payment" onclick="MTRpopAutoTask(#attributes.caseid#,0)" <CFIF q_taskinfo.recordcount GT 0>CHECKED DISABLED</CFIF>><span class=clsColorNote>#Server.SVClang("Auto Task to payment",0)#</span>
			</CFIF>

	<table class="clsClmTable table inlineTable" align="center" width="100%">
	<col class=clsClmDtlTone1 style=font-weight:bold width=25%>
	<col class=clsClmDtlTone2 width=75%>
	<CFIF q_fpay.recordcount GT 0>
		<cfoutput query="q_fpay">
			<tr id="paytype">
				<td>#Server.SVClang("Payment Type",0)#</td>
				<td><CFIF q_fpay.siPAYTYPE eq 1>Transfer
					<CFELSEIF q_fpay.siPAYTYPE eq 2>Cheque</CFIF>
				</td>
			</tr>
		<CFIF q_fpay.siPAYTYPE eq 1>
			<tr id="bankname">
				<td>#Server.SVClang("Bank Name",0)#</td>
				<td>#gcoidname#</td>
			</tr>
			<tr id="brankbr">
				<td>#Server.SVClang("Bank Branch",0)#</td>
				<td>#vaCONAME# - #vacobrname#/#vabranchcode#</td>
			</tr>
			<tr id="bankacctype">
				<td>#Server.SVClang("Bank Account type",0)#</td>
				<td><CFIF q_fpay.siBANKTYPE eq 1>Saving
					<CFELSEIF q_fpay.siBANKTYPE eq 2>Current</CFIF>
				</td>
			</tr>
		</CFIF>
			<tr id="accname">
				<td>#Server.SVClang("Account Name",0)#</td>
				<td>#q_fpay.vaACCNAME#</td>
			</tr>
		<CFIF q_fpay.siPAYTYPE eq 1>
			<tr id="accno">
				<td>#Server.SVClang("Account No.",0)#</td>
				<td>#q_fpay.vaACCNO#</td>
			</tr>
		</CFIF>
			<tr id="payrmk">
				<td>#Server.SVClang("Payment Remark",0)#</td>
				<td>#q_fpay.vaPAYRMK#</td>
			</tr>
		<CFIF q_fpay.siPAYTYPE eq 2>
			<tr id="deliverycheque">
				<td>#Server.SVClang("Delivery Cheque",0)#</td>
				<td><CFIF q_fpay.siCHQTYPE eq 1>Receiving By Payee
					<CFELSEIF q_fpay.siCHQTYPE eq 2>Receiving By Appointee
					<CFELSEIF q_fpay.siCHQTYPE eq 3>In-house Messenger
					<CFELSEIF q_fpay.siCHQTYPE eq 4>Mailing</CFIF>
				</td>
			</tr>
		</CFIF>
			<tr>
				<td>#Server.SVClang("Payee Tax ID",0)#</td>
				<td>#q_fpay.vaPAYTAXID#</td>
			</tr>
			<tr>
				<td>#Server.SVClang("Payee Address",0)#</td>
				<td>#q_fpay.vaPAYADD#</td>
			</tr>
		</cfoutput>
	<CFELSE>
		<cfset dispYes=0> <!--- #36531 kofam --->
	</CFIF>
	<CFIF q_taskinfo.recordcount GT 0>
		<cfoutput query="q_taskinfo">
			<tr>
				<td>#Server.SVClang("Assign To",0)#</td>
				<td>#q_taskinfo.asgnname#</td>
			</tr>
			<tr>
				<td>#Server.SVClang("Date Due",0)#</td>
				<td>#request.DS.FN.SVCdtDBtoLOC(q_taskinfo.dtApply,0)#</td>
			</tr>
		</cfoutput>
	</CFIF>
</table><br>
</CFIF>
</cffunction>
<CFSET Attributes.DS.MTRFN.GenDirectPay=GenDirectPay>

<cffunction name="SubroRemarks" output=yes>
	<cfargument name="mapcode" type=string required="true">
	<cfargument name="insgcoid" type="numeric" required="true">
	<cfargument name="value" type="string" default="">
	<cfargument name="claimtypemask" type="string" required="true">
	<CFQUERY DATASOURCE=#Request.MTRDSN# NAME="q_bizmap">
		SELECT vaCFCODE,vaCFDESC,iLID=ISNULL(iLID,0),iCLMTYPEMASK
		FROM BIZ0025 WITH (NOLOCK) WHERE
		iCLMTYPEMASK&<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#claimtypemask#"><>0 AND
		iCOID=<cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER"> AND aCFTYPE='SUBROREMARKS' AND SISTATUS=0
		AND vaCFMAPCODE=<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#mapcode#">
		ORDER BY vaCFCODE
	</cfquery>
	<CFIF q_bizmap.recordcount GT 0>
		<OPTION value=""></OPTION>
		<script>document.write(JSVCgenOptions("<CFLOOP query=q_bizmap><cfif BITAND(iCLMTYPEMASK,claimtypemask) GT 0>#vaCFCODE#|#Server.SVClang(vaCFDESC,iLID)#</cfif>|</CFLOOP>","|","#value#"));</script>
	</CFIF>
</cffunction>
<CFSET Attributes.DS.MTRFN.SubroRemarks=SubroRemarks>


<CFFUNCTION NAME="ALTCOLOGIC" output="yes">
	<CFARGUMENT name="LOGICNAME" type="string" required="true">


	<CFQUERY name="qaltcologic" datasource="#Request.MTRDSN#">
		SELECT vaCOLOGICNAME
		FROM
		SEC0005 co WITH(NOLOCK)
		JOIN FSYS0013 cocus WITH(NOLOCK) ON co.iCOID=cocus.iOWNOBJID AND cocus.iOWNDOMID=10
		JOIN FSYS0012 cus WITH(NOLOCK) ON cocus.iATTRID=cus.iATTRID AND cocus.vaATTRTYPE=cus.vaATTRTYPE AND cus.vaFieldLogicName='ALTCOLOGICNAME'
		WHERE ','+cocus.vaATTR+',' LIKE '%,'+<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#LOGICNAME#">+',%'

	</CFQUERY>
	<CFRETURN qaltcologic.vaCOLOGICNAME>
</CFFUNCTION>
<CFSET Attributes.DS.MTRFN.ALTCOLOGIC=ALTCOLOGIC>


<CFFUNCTION NAME="MTREXPIREDCASE" output="yes">
	<CFARGUMENT name="caseid" type="string" required="true">
	<CFARGUMENT name="lbllst" type="string" required="true">
	<CFARGUMENT name="mode" type="numeric" required="true"> <!--- 1: Display --->

	<CFSET NOW=now()>
	<CFSET usecase="">

	<cfset expired="">
	<CFIF ListFind(lbllst,"1700061")>
		<cfset expired="1700061">
	</CFIF>

	<CFQUERY name="qExpiredCases" datasource="#Request.MTRDSN#">
		select r.dtACCDATE,r.dtPOLICYFR,dtPOLICYTO = DATEADD(day, 1, r.dtPOLICYTO),b.dtPDPURCH
		from trx0001 r with (nolock)
		inner join trx0055 b with (nolock) on r.iCASEID=b.iCASEID
		where r.iCASEID=<cfqueryparam value="#caseid#" cfsqltype="CF_SQL_INTEGER">
	</CFQUERY>

	<cfset MFW=false>
	<CFIF qExpiredCases.dtACCDATE GTE qExpiredCases.dtPDPURCH AND qExpiredCases.dtACCDATE LTE qExpiredCases.dtPOLICYFR>
		<cfset MFW=true>
	</CFIF>

	<CFIF MFW AND NOW GTE qExpiredCases.dtPDPURCH AND NOW LTE qExpiredCases.dtPOLICYFR> <!--- 1 --->
		<CFIF mode IS 1><cfoutput>#Server.SVClang("Invalid- within MFW (Manufacture's Warranty)",47218)#</cfoutput></CFIF>
		<CFSET usecase=1>
	<CFELSEIF (MFW AND NOW GTE qExpiredCases.dtPOLICYFR AND NOW LTE qExpiredCases.dtPOLICYTO) OR (qExpiredCases.dtACCDATE EQ "" AND qExpiredCases.dtPOLICYFR EQ "" AND qExpiredCases.dtPOLICYTO EQ "" AND qExpiredCases.dtPDPURCH EQ "")> <!--- 2 ---> <!--- #39112: All dates are null for history uploaded, do not tag Expired --->
		<cfset expired="">
		<CFSET usecase=2>
	<CFELSEIF (MFW AND NOW GT qExpiredCases.dtPOLICYTO)
		OR (expired IS "" AND NOW GT qExpiredCases.dtPOLICYTO)
		OR (NOW GT qExpiredCases.dtPOLICYTO)> <!--- 3,4,5 --->
		<CFIF mode IS 1><cfoutput>#Server.SVClang("Invalid- expired EXW (Extended Warranty)",47219)#</cfoutput></CFIF>
		<CFSET usecase="3,4,5">
		<cfset expired="1700061">
	</CFIF>

	<cfstoredproc PROCEDURE='sspFOBJLabelSelect' DATASOURCE="#Request.MTRDSN#" RETURNCODE=YES>
		<CFPROCPARAM TYPE=IN DBVARNAME=@ai_domainid VALUE=1 CFSQLTYPE="CF_SQL_INTEGER">
		<CFPROCPARAM TYPE=IN DBVARNAME=@ai_objid VALUE="#CASEID#" CFSQLTYPE="CF_SQL_INTEGER">
		<CFPROCPARAM TYPE=IN DBVARNAME=@ai_usid VALUE="1" CFSQLTYPE="CF_SQL_INTEGER">
		<CFPROCPARAM TYPE=IN DBVARNAME=@as_lbllist VALUE="1700061" CFSQLTYPE="CF_SQL_VARCHAR">
		<CFPROCPARAM TYPE=IN DBVARNAME=@as_sellist VALUE="#expired#" CFSQLTYPE="CF_SQL_VARCHAR">
	</cfstoredproc>
	<cfset returncode = CFSTOREDPROC.StatusCode>
	<cfif returncode LT 0>
		<cfthrow TYPE="EX_DBERROR" ErrorCode="CLMHEADER/MTRCFFUNCTION/EXPIRED/LABEL/(#returncode#)">
	</cfif>

	<CFIF mode IS 0>
	<CFRETURN usecase>
	</CFIF>

</CFFUNCTION>
<CFSET Attributes.DS.MTRFN.MTREXPIREDCASE=MTREXPIREDCASE>

<cffunction name="MTRCMFCHECKCASE" description="Check CMF Case with same Veh No. or Chassis No. or Engine No. with same DOL in the same month" access="public" returntype="string" output="false">
<cfargument name="CASEID" type="numeric" required="true" hint="CASE ID">
<cfquery NAME=q_case_detail DATASOURCE=#Request.MTRDSN#>
 	SELECT MONTH = MONTH(dtACCDATE),YEAR = YEAR(dtACCDATE),VEHNO = vaREGNO,CHASNO = vaCHANO,ENGINENO = vaENGNO from TRX0001 WITH (NOLOCK) WHERE iCASEID = #arguments.CASEID#
</cfquery>

<cfquery NAME=q_cases DATASOURCE=#Request.MTRDSN#>
 	select 1 from trx0001 with (nolock) where MONTH(dtACCDATE) = #q_case_detail.MONTH# and YEAR(dtACCDATE) = #q_case_detail.YEAR# and (vaREGNO = '#q_case_detail.VEHNO#' OR vaCHANO = '#q_case_detail.CHASNO#' OR vaENGNO = '#q_case_detail.ENGINENO#')
</cfquery>

<CFIF q_cases.recordCount GT 1>
	<CFSET SkipResult = true>
<CFELSEIF q_cases.recordCount EQ 1>
	<CFSET SkipResult = false>
</cfif>

<cfreturn Trim(SkipResult)>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRCMFCHECKCASE=MTRCMFCHECKCASE>

<CFFUNCTION NAME="OfferLTREmailRecipient" output="yes">
	<CFARGUMENT name="qry" type="query" required="true">

	<!--- To email Offer Letter --->
	<CFSET EMAIL_CHKFLAG=0>
	<CFIF (INSGCOID IS 2622 AND UCase(Arguments.qry.vaINSUREDNAME) IS "TELEKOM MALAYSIA BERHAD")
		OR ((INSGCOID IS 37 OR INSGCOID IS 1101192 OR INSGCOID IS 4 OR INSGCOID IS 67) AND Arguments.qry.siISAGENT IS 1 AND Len(Arguments.qry.vaAGENTEMAIL) GT 5)
		OR ((INSGCOID IS 67) AND CLMFLOW IS "NM" AND ((Arguments.qry.siISAGENT IS 2 AND Len(Arguments.qry.vaAGENTEMAIL) GT 5) OR Arguments.qry.vaCIEMAIL neq "" OR Arguments.qry.vaCLMEMAIL neq "" OR Arguments.qry.vaINTEMAIL neq "") )
		OR ((INSGCOID IS 200028 OR INSGCOID IS 200041) AND Len(Arguments.qry.vaAGENTEMAIL) GT 5)
		OR ((INSGCOID IS 200800 AND ( CLAIMTYPE IS "NM PA" OR CLAIMTYPE IS "NM TR")) AND (Len(Arguments.qry.vaAGENTEMAIL) GT 5 OR (Arguments.qry.CRTBYEMAIL NEQ "" AND Arguments.qry.vaAGENTEMAIL EQ "")) AND Arguments.qry.siINTERMEDIARY EQ 0 <!--- Only for Zurich #41937 --->)
		OR ((INSGCOID IS 203018 OR INSGCOID IS 200002) AND CLAIMTYPE IS "NM TR" AND Arguments.qry.vaCLMEMAIL NEQ "")
		OR ((INSGCOID IS 200043) AND CLAIMTYPE IS "NM WC" AND ((Arguments.qry.vaCIEMAIL NEQ "") OR (Arguments.qry.vaAGENTEMAIL NEQ "")))
		OR (INSGCOID IS 64 AND CLMFLOW IS "NM" AND (Len(Arguments.qry.vaAGENTEMAIL) GT 5 OR Len(Arguments.qry.vacfmapcode) GT 5 OR Len(Arguments.qry.vacfmapcode2) GT 5))
		OR (INSGCOID IS 32 AND (Arguments.qry.vaAGENTEMAIL NEQ "" OR Arguments.qry.vacfmapcode NEQ "" OR Arguments.qry.vacfmapcode2 NEQ ""))>
		<CFSET EMAIL_CHKFLAG+=1>
	</CFIF>
	<CFIF Len(Arguments.qry.corpcoemail) GT 5>
		<CFSET EMAIL_CHKFLAG+=2>
	</CFIF>
	<CFSET EMAIL_RECIPIENTBITVAL=0>
	<CFIF EMAIL_CHKFLAG GT 0>
		<cfset autosendmail=0>
		<cfif LOCID IS 2 OR INSGCOID IS 67 OR ((INSGCOID IS 37 OR INSGCOID IS 1101192) AND CLMFLOW NEQ "NM") OR (INSGCOID IS 32 AND CLMFLOW IS "NM")>
			<cfset autosendmail=1>
		</cfif>
		<blockquote class=clsColorNote style="padding:6px">
		<CFIF BitAnd(EMAIL_CHKFLAG,1) IS 1>
			<div>
				<cfif INSGCOID IS 64>
					<cfset thecclist="">
					<cfif Arguments.qry.vacfmapcode2 NEQ ""><cfset thecclist=#listappend(thecclist,Arguments.qry.vacfmapcode2,";")#></cfif>
					<cfif INSPICEMAIL NEQ ""><cfset thecclist=#listappend(thecclist,INSPICEMAIL,";")#></cfif>
					<!--- Detail Offer Breakdown --->
					<cfquery name=q_cnt datasource="#Request.MTRDSN#">
					SELECT TOP 1 idocid from fdoc3003 where idomainid=1 and iobjid=<cfqueryparam cfsqltype="cf_sql_integer" value="#Attributes.caseid#">
					and idocdefid=756 and sistatus=0 and dtfinalon is not null and dtrevokedon is null
					ORDER BY dtfinalon desc
					</cfquery>
					<cfif Arguments.qry.vaAGENTEMAIL NEQ "">
						<input type=checkbox id=CHKSENDEMAIL1 name=CHKSENDEMAIL_AG value="#HTMLEditFormat(Arguments.qry.vaAGENTEMAIL)#" <cfif autosendmail IS 1>CHECKED</cfif>>
						<cfif q_cnt.recordcount GT 0 AND q_cnt.idocid GT 0><label for=CHKSENDEMAIL1>#Server.SVClang("Check here to send Offer Letter/DV + Detail Offer Breakdown  to the agent's email address",36074)#: #HTMLEditFormat(Arguments.qry.vaAGENTEMAIL)#</label>
						<cfelseif CLAIMTYPE IS "NM PA"><label for=CHKSENDEMAIL1>#Server.SVClang("Check here to send Offer Letter/DV + Insurer Report to the agent's email address",36075)#: #HTMLEditFormat(Arguments.qry.vaAGENTEMAIL)#</label>
						<cfelse><!--- non PA ---><label for=CHKSENDEMAIL1>#Server.SVClang("Check here to send Offer Letter/DV to the agent's email address",10804)#: #HTMLEditFormat(Arguments.qry.vaAGENTEMAIL)#</label>
						</cfif>
					</cfif>
					<cfif Arguments.qry.vacfmapcode NEQ "" OR Arguments.qry.vacfmapcode2 NEQ "">
						<br><input type=checkbox id=CHKSENDEMAIL2 name=CHKSENDEMAIL_AG value="#HTMLEditFormat(Arguments.qry.vacfmapcode)#<cfif thecclist neq ''>|#HTMLEditFormat(thecclist)#</cfif>" <cfif autosendmail IS 1>CHECKED</cfif>>
						<cfif q_cnt.recordcount GT 0 AND q_cnt.idocid GT 0><label for=CHKSENDEMAIL2>#Server.SVClang("Check here to send Offer Letter/DV + Detail Offer Breakdown to the marketing staff's email address",36076)#: #HTMLEditFormat(Arguments.qry.vacfmapcode)#<cfif Arguments.qry.vacfmapcode2 neq ''>, CC: #HTMLEditFormat(Arguments.qry.vacfmapcode2)#</cfif></label>
						<cfelseif CLAIMTYPE IS "NM PA"><label for=CHKSENDEMAIL2>#Server.SVClang("Check here to send Offer Letter/DV + Insurer Report to the marketing staff's email address",36077)#: #HTMLEditFormat(Arguments.qry.vacfmapcode)#<cfif Arguments.qry.vacfmapcode2 neq ''>, CC: #HTMLEditFormat(Arguments.qry.vacfmapcode2)#</cfif></label>
						<cfelse><!--- non PA ---><label for=CHKSENDEMAIL2>#Server.SVClang("Check here to send Offer Letter/DV to the marketing staff's email address",36078)#: #HTMLEditFormat(Arguments.qry.vacfmapcode)#<cfif Arguments.qry.vacfmapcode2 neq ''>, CC: #HTMLEditFormat(Arguments.qry.vacfmapcode2)#</cfif></label>
						</cfif>
					</cfif>
					<!--- <input type=hidden name=CHKSENDEMAILADDR1 value="#HTMLEditFormat(Arguments.qry.vaAGENTEMAIL)#">
					<input type=hidden name=CHKSENDEMAILADDR2 value="#HTMLEditFormat(Arguments.qry.vacfmapcode)#<cfif thecclist neq ''>|#HTMLEditFormat(thecclist)#</cfif>"> --->
				<cfelse>
					<cfif INSGCOID IS 2622>
						<input type=checkbox id=CHKSENDEMAIL1 name=CHKSENDEMAIL_AG value="#HTMLEditFormat(Arguments.qry.vaAGENTEMAIL)#" <cfif autosendmail IS 1>CHECKED</cfif>><label for=CHKSENDEMAIL1>
						Telekom Malaysia Berhad - Check here to send Offer Letter/DV and Adjuster Report (if available) to the clients.</label>
					<cfelseif INSGCOID IS 203018 OR INSGCOID IS 200002>
						<cfif Arguments.qry.vaCLMEMAIL NEQ "">
							<input type=checkbox id=CHKSENDEMAIL1 name=CHKSENDEMAIL_AG value="#HTMLEditFormat(Arguments.qry.vaCLMEMAIL)#" <cfif autosendmail IS 1>CHECKED</cfif>><label for=CHKSENDEMAIL1>
							#Server.SVClang("Check here to send Offer Letter/DV to the claimant's email address",37335)#: #HTMLEditFormat(Arguments.qry.vaCLMEMAIL)#</label>
						</cfif>
					<cfelseif INSGCOID eq 200043>
						<cfif Arguments.qry.vaCIEMAIL NEQ "">
							<input type=checkbox id=CHKSENDEMAIL1 name=CHKSENDEMAIL_AG value="#HTMLEditFormat(Arguments.qry.vaCIEMAIL)#" <cfif autosendmail IS 1>CHECKED</cfif>><label for=CHKSENDEMAIL1>
							#Server.SVClang("Check here to send Offer Letter/DV to the insured's email address",37335)#: #HTMLEditFormat(Arguments.qry.vaCIEMAIL)#</label>
						</cfif>
							<br>
						<cfif Arguments.qry.vaAGENTEMAIL NEQ "">
							<input type=checkbox id=CHKSENDEMAIL2 name=CHKSENDEMAIL_AG value="#HTMLEditFormat(Arguments.qry.vaAGENTEMAIL)#" <cfif autosendmail IS 1>CHECKED</cfif>><label for=CHKSENDEMAIL2>
							#Server.SVClang("Check here to send Offer Letter/DV to the agent's email address",17293)#: #HTMLEditFormat(Arguments.qry.vaAGENTEMAIL)#</label>
						</cfif>
					<cfelseif INSGCOID is 67>
						<!--- #11602 [MY] RHB NM - Attach additional document to the claim offer email (payment Notice idocdefid:9211) --->
						<cfquery name=q_pn datasource=#request.SVCDSN#>
							select 1 from FDOC3003 where IDOMAINID=1 and IDOCDEFID=9211 and IOBJID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" Value="#attributes.CASEID#">
						</cfquery>

						<CFIF Arguments.qry.vaCIEMAIL neq ""><CFSET CI_EMAIL = Arguments.qry.vaCIEMAIL><CFELSE><CFSET CI_EMAIL = ""></CFIF>
						<CFIF Arguments.qry.vaCLMEMAIL neq ""><CFSET CLM_EMAIL = Arguments.qry.vaCLMEMAIL><CFELSE><CFSET CLM_EMAIL = ""></CFIF>
						<CFIF Arguments.qry.vaINTEMAIL neq ""><CFSET INT_EMAIL = Arguments.qry.vaINTEMAIL><CFELSE><CFSET INT_EMAIL = ""></CFIF>

						<CFIF q_pn.recordcount neq 0><CFSET prm="Offer Letter/DV and the attached Payment Notice"><CFELSE><CFSET prm="Offer Letter/DV"></CFIF>
						<input type=checkbox id=CHKSENDEMAIL1 name=CHKSENDEMAIL_AG value="#HTMLEditFormat(Arguments.qry.vaAGENTEMAIL)#<CFIF INT_EMAIL neq "">,#HTMLEditFormat(INT_EMAIL)#</CFIF><CFIF CI_EMAIL neq "">,#HTMLEditFormat(CI_EMAIL)#</CFIF><CFIF CLM_EMAIL neq "">,#HTMLEditFormat(CLM_EMAIL)#</CFIF><cfif INSPICEMAIL neq ''>|#HTMLEditFormat(INSPICEMAIL)#</cfif>" <cfif autosendmail IS 1>CHECKED</cfif>><label for=CHKSENDEMAIL1>
						#Server.SVClang("Check here to send {0} to the agent's email address",17293,0,"#prm#")#: #HTMLEditFormat(Arguments.qry.vaAGENTEMAIL)#<CFIF INT_EMAIL neq "">, #INT_EMAIL# (Intimation)</CFIF><CFIF CI_EMAIL neq "">, #CI_EMAIL# (Insured)</CFIF><CFIF CLM_EMAIL neq "">, #CLM_EMAIL# (Claimant)</CFIF><cfif INSPICEMAIL neq ''>, CC: #HTMLEditFormat(INSPICEMAIL)#</cfif></label>
						<cfif Arguments.qry.vacfmapcode NEQ "" OR Arguments.qry.vacfmapcode2 NEQ "">
						<br><input type=checkbox id=CHKSENDEMAIL2 name=CHKSENDEMAIL_AG value="#HTMLEditFormat(Arguments.qry.vacfmapcode)#<cfif Arguments.qry.vacfmapcode2 neq ''>|#HTMLEditFormat(Arguments.qry.vacfmapcode2)#</cfif><cfif INSPICEMAIL neq ''>|#HTMLEditFormat(INSPICEMAIL)#</cfif>" <cfif autosendmail IS 1>CHECKED</cfif>><label for=CHKSENDEMAIL2>
						#Server.SVClang("Check here to send {0} to the marketing staff's email address",36079,0,"#prm#")# : #HTMLEditFormat(Arguments.qry.vacfmapcode)#<cfif Arguments.qry.vacfmapcode2 neq ''>, CC: #HTMLEditFormat(Arguments.qry.vacfmapcode2)#</cfif><cfif INSPICEMAIL neq ''>, CC: #HTMLEditFormat(INSPICEMAIL)#</cfif></label>
						</cfif>
					<cfelseif INSGCOID IS 32> 
						<CFIF Arguments.qry.vaAGENTEMAIL NEQ "">
							<CFIF ((Arguments.qry.siEMAILOFFERLTR IS "" AND LEFT(CLAIMTYPE,2) NEQ "TP") OR (Arguments.qry.siEMAILOFFERLTR IS NOT "" AND BitAnd(Arguments.qry.siEMAILOFFERLTR,1) GT 0)) AND NOT(CLMFLOW IS "NM" AND Arguments.qry.siEMAILOFFERLTR IS "" AND ((Arguments.qry.siOFRDTL NEQ "" AND BitAnd(Arguments.qry.siOFRDTL,256) IS 256) OR (Arguments.qry.siOFRDTL IS "" AND IsDefined("allowadjsigneddv") AND allowadjsigneddv IS 1)))>
								<CFSET EMAIL_RECIPIENTBITVAL = EMAIL_RECIPIENTBITVAL + 1>
							</CFIF>
							<input type=checkbox id=CHKSENDEMAIL1 name=CHKSENDEMAIL_AG value="#HTMLEditFormat(Arguments.qry.vaAGENTEMAIL)#" <cfif BitAnd(EMAIL_RECIPIENTBITVAL,1) GT 0>CHECKED</CFIF> emailBitVal=1 onclick="saveEmailBit(this)"><label for=CHKSENDEMAIL1>
							#Server.SVClang("Check here to send Offer Letter/DV to the agent's email address",10804)#: #HTMLEditFormat(Arguments.qry.vaAGENTEMAIL)#</label>
							<cfif Arguments.qry.vacfmapcode NEQ "" OR Arguments.qry.vacfmapcode2 NEQ ""><br></cfif>
						</CFIF>
						<cfif Arguments.qry.vacfmapcode NEQ "" OR Arguments.qry.vacfmapcode2 NEQ "">
							<CFIF ((Arguments.qry.siEMAILOFFERLTR IS "" AND autosendmail IS 1 AND LEFT(CLAIMTYPE,2) NEQ "TP") OR (Arguments.qry.siEMAILOFFERLTR IS NOT "" AND BitAnd(Arguments.qry.siEMAILOFFERLTR,2) GT 0)) AND NOT(CLMFLOW IS "NM" AND Arguments.qry.siEMAILOFFERLTR IS "" AND ((Arguments.qry.siOFRDTL NEQ "" AND BitAnd(Arguments.qry.siOFRDTL,256) IS 256) OR (Arguments.qry.siOFRDTL IS "" AND IsDefined("allowadjsigneddv") AND allowadjsigneddv IS 1)))>
								<CFSET EMAIL_RECIPIENTBITVAL = EMAIL_RECIPIENTBITVAL + 2>
							</CFIF>
							<input type=checkbox id=CHKSENDEMAIL2 name=CHKSENDEMAIL_AG value="|#HTMLEditFormat(Arguments.qry.vacfmapcode)#<cfif Arguments.qry.vacfmapcode2 neq ''>;#HTMLEditFormat(Arguments.qry.vacfmapcode2)#</cfif>" <cfif BitAnd(EMAIL_RECIPIENTBITVAL,2) GT 0>CHECKED</cfif> emailBitVal=2 onclick="saveEmailBit(this)"><label for=CHKSENDEMAIL2>
							#Server.SVClang("Check here to send Offer Letter/DV to the marketing staff's email address",36078)#: #HTMLEditFormat(Arguments.qry.vacfmapcode)#<cfif Arguments.qry.vacfmapcode2 neq ''>; #HTMLEditFormat(Arguments.qry.vacfmapcode2)#</cfif></label>
						</cfif>
						<input type=hidden name="CHKSENDEMAIL_AGVAL" value=<cfoutput>#EMAIL_RECIPIENTBITVAL#</cfoutput>>
					<cfelseif INSGCOID IS 200800>
						<CFIF Len(Arguments.qry.vaAGENTEMAIL) GT 5>
							<CFSET AGENTEMAIL="#Arguments.qry.vaAGENTEMAIL#">
						<CFELSEIF Arguments.qry.CRTBYEMAIL NEQ "" AND Arguments.qry.vaAGENTEMAIL EQ "">
							<CFSET AGENTEMAIL="#Arguments.qry.CRTBYEMAIL#">
						</CFIF>
						<!--- Aisyah #43524 --->
						<CFIF Arguments.qry.vaCLMEMAIL NEQ "">
							<CFSET CLM_EMAIL="#Arguments.qry.vaCLMEMAIL#">
						</CFIF>

						<input type=checkbox id=CHKSENDEMAIL1 name=CHKSENDEMAIL_AG value="#HTMLEditFormat(AGENTEMAIL)#" <cfif autosendmail IS 1>CHECKED</cfif>><label for=CHKSENDEMAIL1>
						#Server.SVClang("Check here to send Offer Letter/DV to the agent's email address",10804)#: #HTMLEditFormat(AGENTEMAIL)#</label>
						<cfif Arguments.qry.vacfmapcode NEQ "" OR Arguments.qry.vacfmapcode2 NEQ "">
						<br><input type=checkbox id=CHKSENDEMAIL2 name=CHKSENDEMAIL_AG value="#HTMLEditFormat(Arguments.qry.vacfmapcode)#<cfif Arguments.qry.vacfmapcode2 neq ''>|#HTMLEditFormat(Arguments.qry.vacfmapcode2)#</cfif>" <cfif autosendmail IS 1>CHECKED</cfif>><label for=CHKSENDEMAIL2>
						#Server.SVClang("Check here to send Offer Letter/DV to the marketing staff's email address",36078)#: #HTMLEditFormat(Arguments.qry.vacfmapcode)#<cfif Arguments.qry.vacfmapcode2 neq ''>, CC: #HTMLEditFormat(Arguments.qry.vacfmapcode2)#</cfif></label>
						</cfif>
					<cfelse>
						<input type=checkbox id=CHKSENDEMAIL1 name=CHKSENDEMAIL_AG value="#HTMLEditFormat(Arguments.qry.vaAGENTEMAIL)#" <cfif autosendmail IS 1>CHECKED</cfif>><label for=CHKSENDEMAIL1>
						#Server.SVClang("Check here to send Offer Letter/DV to the agent's email address",10804)#: #HTMLEditFormat(Arguments.qry.vaAGENTEMAIL)#</label>
						<cfif Arguments.qry.vacfmapcode NEQ "" OR Arguments.qry.vacfmapcode2 NEQ "">
						<br><input type=checkbox id=CHKSENDEMAIL2 name=CHKSENDEMAIL_AG value="#HTMLEditFormat(Arguments.qry.vacfmapcode)#<cfif Arguments.qry.vacfmapcode2 neq ''>|#HTMLEditFormat(Arguments.qry.vacfmapcode2)#</cfif>" <cfif autosendmail IS 1>CHECKED</cfif>><label for=CHKSENDEMAIL2>
						#Server.SVClang("Check here to send Offer Letter/DV to the marketing staff's email address",36078)#: #HTMLEditFormat(Arguments.qry.vacfmapcode)#<cfif Arguments.qry.vacfmapcode2 neq ''>, CC: #HTMLEditFormat(Arguments.qry.vacfmapcode2)#</cfif></label>
						</cfif>
					</cfif>
					<!--- <input type=hidden name=CHKSENDEMAILADDR1 value="#HTMLEditFormat(Arguments.qry.vaAGENTEMAIL)#">
					<input type=hidden name=CHKSENDEMAILADDR2 value="#HTMLEditFormat(Arguments.qry.vacfmapcode)#<cfif Arguments.qry.vacfmapcode2 neq ''>|#HTMLEditFormat(Arguments.qry.vacfmapcode2)#</cfif>"> --->
				</cfif>
			</div>
		</CFIF>
		<CFIF BitAnd(EMAIL_CHKFLAG,2) IS 2>
		<div>
			<input type=checkbox id=CHKSENDEMAIL2 name=CHKSENDEMAIL_CORP value="#HTMLEditFormat(Arguments.qry.corpcoemail)#" <cfif autosendmail IS 1>CHECKED</cfif>><label for=CHKSENDEMAIL2>
			#Server.SVClang("Check here to send Offer Letter/DV to the client's email address",35918)#: #HTMLEditFormat(Arguments.qry.corpcoemail)#</label>
			<!--- <input type=hidden name=CHKSENDEMAILADDR2 value="#HTMLEditFormat(Arguments.qry.corpcoemail)#"> --->
		</div>
		</CFIF>
		</blockquote>
	</CFIF>

	<script>
		function saveEmailBit(obj){
			var storeObj = JSVCall("CHKSENDEMAIL_AGVAL");
			if(storeObj == null || obj.getAttribute("emailBitVal") == null) return;
			var objVal = parseInt(obj.getAttribute("emailBitVal"));
			var storeVal = parseInt(storeObj.value);

			if(obj.checked == true && (storeVal&objVal)==0){
				storeVal = storeVal + objVal;
			}
			else if(obj.checked == false && (storeVal&objVal)>0){
				storeVal = storeVal - objVal;
			}
			storeObj.value = storeVal;
		}
	</script>

</CFFUNCTION>
<CFSET Attributes.DS.MTRFN.OfferLTREmailRecipient=OfferLTREmailRecipient>

<CFFUNCTION NAME="BVGenClmSettleDoc" output="yes">
	<CFARGUMENT name="OBJID" type="numeric" required="true">
	<CFARGUMENT name="REQID" type="numeric" required="true">
	<CFARGUMENT name="REVOKED" type="numeric" required="true"> <!--- 1: revoked if any, 2: return upon complete revoked doc --->
	<CFARGUMENT name="AUTH" type="numeric" required="false" default=0>
	<CFARGUMENT name="DOCSUFFIX" type="string" required="false" default="">

	<CFSTOREDPROC PROCEDURE="sspFOBJLogMultiGet" DATASOURCE=#Request.SVCDSN# RETURNCODE=YES>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=1 DBVARNAME=@ai_domid>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#Arguments.OBJID# DBVARNAME=@ai_objid>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#SESSION.VARS.USID# DBVARNAME=@ai_usid>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=2 DBVARNAME=@ai_corole>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_SMALLINT VALUE=2021 DBVARNAME=@asi_logtype>
		<CFPROCRESULT resultset=1 NAME=q_row>
	</CFSTOREDPROC>

	<CFSET CASEPRSTRUCT = StructNew()>
	<CFSET PRStruct=StructNew()>
	<CFSET PRLOGID=0>
	<CFSET PRSTR="PRDtls#Arguments.REQID#">
	<CFSET PRRUNCNT=0>
	<CFIF q_row.RecordCount GT 0>
		<CFSET LOGSTR=#deserializeJSON(q_row.vx1)#>
		<CFSET PRLOGID=q_row.iLOGID>
		<CFSET CASEPRSTRUCT=LOGSTR>
		<CFIF IsDefined("LOGSTR.#PRSTR#")>
			<CFSET PRStruct=#Evaluate("LOGSTR.#PRSTR#")#>
		</CFIF>
		<CFSET PRRUNCNT=Int(LOGSTR.RunNoCnt)>
	</CFIF>

	<CFIF StructIsEmpty(PRStruct)>
		<CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCSTAT" EXTENDEDINFO="PR Running No Not Found">
	</CFIF>

	<CFIF Arguments.REVOKED GT 0 AND PRStruct.iDOCID NEQ 0>
		<cfstoredproc PROCEDURE="sspFDOCDocRevoke" DATASOURCE=#Request.SVCDSN# RETURNCODE="YES">
			<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#PRStruct.IDOCID# DBVARNAME=@ai_docid>
			<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#SESSION.VARS.USID# DBVARNAME=@ai_usid>
			<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=1 DBVARNAME=@ai_skipseccheck>
		</cfstoredproc>
		<cfset RETURNCODE=CFSTOREDPROC.STATUSCODE>
		<cfif RETURNCODE LT 0>
			<cfthrow TYPE="EX_DBERROR" ErrorCode="REVOKECLMLTR(#RETURNCODE#)">
		</cfif>
	</CFIF>

	<CFIF Arguments.REVOKED EQ 2> <!--- only revoked doc --->
		<CFSET PRStruct.iDOCID = 0>
		<CFSET StructUpdate(CASEPRSTRUCT,PRSTR,PRStruct)>
		<CFSET CASEPRSTR = serializeJSON(CASEPRSTRUCT)>
		<cfmodule template="#Request.LOGPATH#index.cfm" FUSEBOX=SVCobj FUSEACTION=ACT_MULTILOGINNER DOMAINID=1 OBJID=#Arguments.OBJID# USID=#SESSION.VARS.USID# COROLE=2 LOGTYPE=2021 LOGID=#PRLOGID# SKIPSECCHECK=1 ax_1="#CASEPRSTR#">
		<cfreturn>
	</CFIF>

	<CFIF Arguments.AUTH IS 1>
		<CFSET CLMLTR_DOCDEFID = 1201925> <!--- Claim Settlement --->
	<CFELSE>
		<CFSET CLMLTR_DOCDEFID = 12020591> <!--- Claim Settlement Draft --->
	</CFIF>
	<CFSET Request.RPTGENERATIONMODE=1>
	<CFSAVECONTENT VARIABLE="DOCCLMLTR"><CFMODULE template="#Request.logpath#index.cfm" FUSEBOX="SVCdoc" FUSEACTION="dsp_getletter" DOMAINID=1 OBJID=#Arguments.OBJID# COROLE=2 GCOID=1512247 DOCDEFID=#CLMLTR_DOCDEFID# iREQID=#Arguments.REQID#></CFSAVECONTENT>
	<CFSET Request.RPTGENERATIONMODE=0>
	<CFSET BCOREAD=19>
	<CFSET CLMLTR_CRTCOROLE=2>	
	<CFMODULE template="#Request.logpath#index.cfm" FUSEBOX=SVCdoc FUSEACTION=ACT_DOCEDIT NOHEADER
		DOMAINID=1 OBJID=#Arguments.OBJID# LINKID=#Arguments.OBJID# BCOREAD=#BCOREAD# CRTCOROLE=#CLMLTR_CRTCOROLE# 
		DOCDEFID=#CLMLTR_DOCDEFID# DOCSTAT=3 CONTENT=#DOCCLMLTR# CRTCOID=1512247>

	<cfquery NAME=q_clmltr DATASOURCE=#Request.MTRDSN#>
		SELECT TOP 1 IDOCID 
		FROM FDOC3003 WITH (NOLOCK)
		WHERE IDOMAINID=1 AND IOBJID=<cfqueryparam value="#Arguments.OBJID#" cfsqltype="CF_SQL_INTEGER"> 
		AND IDOCDEFID IN (<cfqueryparam value="#CLMLTR_DOCDEFID#" cfsqltype="CF_SQL_INTEGER" list="true">) AND dtREVOKEDON IS NULL
		ORDER BY DTCRTON DESC
	</cfquery>

	<CFSET PRStruct.iDOCID = q_clmltr.IDOCID>
	<CFSET StructUpdate(CASEPRSTRUCT,PRSTR,PRStruct)>
	
	<cfquery NAME=updRunNo DATASOURCE=#Request.MTRDSN#>
		UPDATE FDOC3003 
		SET vaDOCDESC = vaDOCDESC+' ('+<cfqueryparam value="#PRStruct.RunningNo#" cfsqltype="CF_SQL_VARCHAR">+')'<CFIF Arguments.DOCSUFFIX NEQ "">+<cfqueryparam value="#Arguments.DOCSUFFIX#" cfsqltype="CF_SQL_VARCHAR"></CFIF>
		WHERE iDOCID = <cfqueryparam value="#PRStruct.iDOCID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>

	<CFSET CASEPRSTR = serializeJSON(CASEPRSTRUCT)>
	<cfmodule template="#Request.LOGPATH#index.cfm" FUSEBOX=SVCobj FUSEACTION=ACT_MULTILOGINNER DOMAINID=1 OBJID=#Arguments.OBJID# USID=#SESSION.VARS.USID# COROLE=2 LOGTYPE=2021 LOGID=#PRLOGID# SKIPSECCHECK=1 ax_1="#CASEPRSTR#">
</CFFUNCTION>
<CFSET Attributes.DS.MTRFN.BVGenClmSettleDoc=BVGenClmSettleDoc>

<CFFUNCTION NAME="BVUpdClmSettleRunNo" output="yes">
	<CFARGUMENT name="OBJID" type="numeric" required="true">
	<CFARGUMENT name="REQID" type="numeric" required="true">

	<CFSTOREDPROC PROCEDURE="sspFOBJLogMultiGet" DATASOURCE=#Request.SVCDSN# RETURNCODE=YES>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=1 DBVARNAME=@ai_domid>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#Arguments.OBJID# DBVARNAME=@ai_objid>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#SESSION.VARS.USID# DBVARNAME=@ai_usid>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=2 DBVARNAME=@ai_corole>
		<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_SMALLINT VALUE=2021 DBVARNAME=@asi_logtype>
		<CFPROCRESULT resultset=1 NAME=q_row>
	</CFSTOREDPROC>

	<CFSET CASEPRSTRUCT = StructNew()>
	<CFSET PRStruct=StructNew()>
	<CFSET PRLOGID=0>
	<CFSET PRSTR="PRDtls#Arguments.REQID#">
	<CFSET PRRUNCNT=0>
	<CFIF q_row.RecordCount GT 0>
		<CFSET LOGSTR=#deserializeJSON(q_row.vx1)#>
		<CFSET PRLOGID=q_row.iLOGID>
		<CFSET CASEPRSTRUCT=LOGSTR>
		<CFIF IsDefined("LOGSTR.#PRSTR#")>
			<cfreturn>
		</CFIF>
		<CFSET PRRUNCNT=Int(LOGSTR.RunNoCnt)>
	</CFIF>

	<CFIF StructIsEmpty(PRStruct)>
		<CFSET StructInsert(PRStruct,"RunningNo",1)>
		<CFSET StructInsert(PRStruct,"iDOCID",0)>
	</CFIF>

	<CFIF q_row.RecordCount GT 0>
		<CFSET PRRUNCNT= PRRUNCNT + 1>
		<CFSET PRStruct.RunningNo = Int(PRRUNCNT)>
	<CFELSE>
		<CFSET PRStruct.RunningNo = 1>
		<CFSET PRRUNCNT=1>
	</CFIF>
	<CFSET StructInsert(CASEPRSTRUCT,PRSTR,PRStruct)>
	

	<CFIF q_row.RecordCount EQ 0>
		<CFSET StructInsert(CASEPRSTRUCT,"RunNoCnt",Int(PRRUNCNT))>
	<CFELSE>
		<CFSET StructUpdate(CASEPRSTRUCT,"RunNoCnt",Int(PRRUNCNT))>
	</CFIF>

	<CFSET CASEPRSTR = serializeJSON(CASEPRSTRUCT)>
	<cfmodule template="#Request.LOGPATH#index.cfm" FUSEBOX=SVCobj FUSEACTION=ACT_MULTILOGINNER DOMAINID=1 OBJID=#Arguments.OBJID# USID=#SESSION.VARS.USID# COROLE=2 LOGTYPE=2021 LOGID=#PRLOGID# SKIPSECCHECK=1 ax_1="#CASEPRSTR#">
</CFFUNCTION>
<CFSET Attributes.DS.MTRFN.BVUpdClmSettleRunNo=BVUpdClmSettleRunNo>

<CFFUNCTION NAME="BVPolCoverage" output="yes"> <!--- shared in dsp_clmregdtl, dsp_insclmreg --->
	<cfargument name="CLAIMTYPE" type="string" required="true">
	<cfargument name="SRCDOMAINID" type="numeric" required="false" default="1">

	<cffunction name="JSPolicyClassGen">
		<cfargument name="CLMCOID" type="numeric">
		<cfargument name="CLMTYPE" type="string">
		<cfargument name="CLASSDEFCODE" type="string" required="no" default="">
		<cfargument name="BUSDEFCODELIST" type="string" required="no" default="">

		<cfquery name="q_clmtype" datasource="#Request.MTRDSN#">
			SELECT CLMTYPEMASK=ISNULL(SUM(iclmtypemask),0) FROM clmd0010 WITH (NOLOCK) WHERE vaCLMTYPE=<cfqueryparam value="#CLMTYPE#" cfsqltype="CF_SQL_NVARCHAR">
		</cfquery>
		
		<cfset CLMTYPEMASK=#q_clmtype.CLMTYPEMASK#>

		<cfquery name="q_polclass" datasource="#Request.MTRDSN#">
			SELECT a.iINSCLASSID,CLSCODE=a.vaCODE,POLCODE=b.vaPOLCODE,BUSCODE=c.vaBUSCODE,a.vaINSCLASSNAME,a.vaINSLOGICNAME,
			CSTAT=a.siSTATUS,b.iPOLID,b.vaPOLNAME,b.vaPOLLOGICNAME,PSTAT=b.siSTATUS,c.IBUSID,c.vaBUSNAME,c.vaBUSLOGICNAME,
			BSTAT=c.siSTATUS,CCLMTYPEMASK=a.iCLMTYPEMASK,PCLMTYPEMASK=b.iCLMTYPEMASK,BCLMTYPEMASK=c.iCLMTYPEMASK,BUSLID=IsNull(c.iLID,0),
			CLASSLID=IsNull(a.iLID,0),POLLID=IsNull(b.iLID,0),BUSDEFCODE=c.vaDEFCODE
			FROM BIZ2010 a WITH (NOLOCK)
			LEFT JOIN BIZ2011 b WITH (NOLOCK) ON a.iINSCLASSID=b.iINSCLASSID AND b.iclmtypemask&<cfqueryparam value="#CLMTYPEMASK#" cfsqltype="CF_SQL_INTEGER"><>0 AND b.sistatus=0
			LEFT JOIN BIZ2012 c WITH (NOLOCK) ON b.iPOLID=c.iPOLID AND c.iclmtypemask&<cfqueryparam value="#CLMTYPEMASK#" cfsqltype="CF_SQL_INTEGER"><>0 AND c.sistatus=0
			WHERE a.iCOID=<cfqueryparam cfsqltype="cf_sql_integer" value="#Request.DS.CO[CLMCOID].GCOID#"> and a.sistatus = 0 and a.iclmtypemask&<cfqueryparam value="#CLMTYPEMASK#" cfsqltype="CF_SQL_INTEGER"><>0
			<CFIF arguments.CLASSDEFCODE IS NOT ""> AND a.vaDEFCODE=<cfqueryparam value="#arguments.CLASSDEFCODE#" cfsqltype="CF_SQL_VARCHAR"></CFIF>
			ORDER BY CASE WHEN ISNULL(a.vaCODE,'')='' THEN 1 ELSE 0 END,a.vaCODE,a.vaINSCLASSNAME,
				CASE WHEN ISNULL(b.vaPOLCODE,'')='' THEN 1 ELSE 0 END,b.vaPOLCODE,b.vaPOLNAME,
				CASE WHEN ISNULL(c.vaBUSCODE,'')='' THEN 1 ELSE 0 END,c.vaBUSCODE,c.vaBUSNAME
		</cfquery>

		<CFIF arguments.BUSDEFCODELIST IS NOT ""> <!--- #37381 --->
			<cfquery name="q_poldata" dbtype="query">
				SELECT * 
				FROM q_polclass
				WHERE BUSDEFCODE IN (#ListQualify(arguments.BUSDEFCODELIST,"'")#)
			</cfquery>
		</CFIF>

		<CFIF IsDefined("q_poldata") AND q_poldata.recordCount GT 0>
			<CFSET qry_name="q_poldata">
		<CFELSE>
			<CFSET qry_name="q_polclass">
		</CFIF>

		<script>
			polclass=[<cfoutput query="#qry_name#" group="iINSCLASSID">[<cfset idC=iINSCLASSID>#iINSCLASSID#,"<cfif CLSCODE NEQ "">#CLSCODE# - </cfif>#JSStringFormat(Server.SVClang(vaINSCLASSNAME,CLASSLID))#","#vaINSLOGICNAME#",#CSTAT#,#cclmtypemask#,[<cfoutput group="iPOLID"><cfif idC IS iINSCLASSID AND iPOLID IS NOT "">[<cfset idP=iPOLID>#iPOLID#,"<cfif POLCODE NEQ "">#POLCODE# - </cfif>#JSStringFormat(Server.SVClang(vaPOLNAME,POLLID))#","#vaPOLLOGICNAME#",#PSTAT#,#pclmtypemask#,[<cfoutput group="iBUSID"><cfif idP IS iPOLID AND iBUSID IS NOT "">[#iBUSID#,"<cfif BUSCODE NEQ "">#BUSCODE# - </cfif>#JSStringFormat(Server.SVClang(vaBUSNAME,BUSLID))#","#vaBUSLOGICNAME#",#BSTAT#,#bclmtypemask#<CFIF qry_name EQ "q_poldata"><CFIF StructKeyExists(polDtls,"#BUSDEFCODE#")>,#polDtls[BUSDEFCODE]#<CFELSE>,""</CFIF></CFIF>],</cfif></cfoutput>],],</cfif></cfoutput>],],</cfoutput>];
		</script>	
	</cffunction>

	<CFIF ibizpolid GT 0>
		<cfquery NAME=q_intpol DATASOURCE=#Request.MTRDSN#>
			SELECT vaPOLNO,dtPERIODFROM,dtPERIODTO,vaPOLDATA,vaCLMCONF FROM INT_POL with(NOLOCK)
			WHERE iPOLID = <cfqueryparam value="#ibizpolid#" cfsqltype="CF_SQL_INTEGER">
			AND IGCOID = <cfqueryparam value="#INSGCOID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<CFSET Otrdetail = deserializeJSON(q_intpol.vaPOLDATA)>
	</CFIF>

	<CFSET BUSDEFCODELIST=""> 
	<CFIF IsDefined("Otrdetail.COVERAGE.DATA")>
		<CFSET polDtls=StructNew()>
		<CFLOOP array="#Otrdetail.COVERAGE.DATA#" index="item">
			<CFSET StructInsert(polDtls, item.namecode, item.insuranceamount)>
		</CFLOOP> <!--- get pol, Sum Insured --->
		<CFSET BUSDEFCODELIST=StructKeyList(polDtls,",")>
	</CFIF>

	#JSPolicyClassGen(INSGCOID, Arguments.CLAIMTYPE, "MTRCLM",BUSDEFCODELIST)#

	<script>
		AddOnloadCode("PolChange(polclass,0,'INSCLASSID','INSPOLID','INSBUSID',<cfif iINSCLASSID GT 0>#iINSCLASSID#<cfelse>''</cfif>,<cfif iINSPOLID GT 0>#iINSPOLID#<cfelse>''</cfif>,<cfif iINSBUSID GT 0>#iINSBUSID#<cfelse>''</cfif>);");

		function populateSI(){
			var sumInsuredAmt=$('##INSBUSID').find(':selected').attr('sum_insured');
			var sumInsured=JSVCall("mnSUMINSURED");
			if(sumInsured != null){
				if(typeof sumInsuredAmt!="undefined"){
					sumInsured.value=sumInsuredAmt;
					JSVCCurr(sumInsured);
				}
				else{
					sumInsured.value="";
				}
			}
		}

		function populateOrigSI(){
			var sumInsured = JSVCall("mnSUMINSURED");
			sumInsured.value = "#mnSUMINSURED#";
			JSVCCurr(sumInsured);
		}
		
		<CFIF qry_name EQ "q_poldata" AND ((Arguments.SRCDOMAINID IS NOT 16 AND Arguments.SRCDOMAINID IS NOT 1 AND Arguments.SRCDOMAINID IS NOT 6) OR (IsDefined("Attributes.DUPCHK") AND Attributes.DUPCHK IS 1))>
			//avoid overwrite SI amount due to PolChange calling populateSI function
			AddOnloadCode('if(JSVCall("mnSUMINSURED")!=null){populateOrigSI();}');
		<CFELSEIF Arguments.SRCDOMAINID IS 1 OR Arguments.SRCDOMAINID IS 6>
			AddOnloadCode('populateSI();');
		</CFIF>
	</script>

	<tr><td><b>#Server.SVClang("Policy Class",8456)#</b></td><td><select id="INSCLASSID" name="INSCLASSID" onchange="PolChange(polclass,1,'INSCLASSID','INSPOLID','INSBUSID');DoReq(this)" <CFIF Arguments.SRCDOMAINID IS 16 OR ibizpolid GT 0>CHKREQUIRED</CFIF>></select></td></tr>
	<tr><td><b>#Server.SVClang("Policy Group",9199)#</b></td><td><select id="INSPOLID" name="INSPOLID" onchange="PolChange(polclass,2,'INSCLASSID','INSPOLID','INSBUSID');DoReq(this)" <CFIF Arguments.SRCDOMAINID IS 16 OR ibizpolid GT 0>CHKREQUIRED</CFIF>><option></select></td></tr>
	<tr><td><b>#Server.SVClang("Policy Coverage",5631)#</b></td><td><select id="INSBUSID" name="INSBUSID" onchange="DoReq(this);<CFIF qry_name EQ "q_poldata">populateSI();</CFIF>" <CFIF Arguments.SRCDOMAINID IS 16 OR ibizpolid GT 0>CHKREQUIRED</CFIF>><option></select></td></tr>
</CFFUNCTION>
<CFSET Attributes.DS.MTRFN.BVPolCoverage=BVPolCoverage>

<cffunction name="MTRTableSelect" hint="Creates a select option based on the COID:TBLNAME:val1,dis1,val2,val3 definition list(copy from ePolicy)" access="public">
	<cfargument name="name" default=""><!--- name of the select option --->
	<cfargument name="idname" default=""><!--- id of the select option --->
	<cfargument name="req" default=0><!--- 1-required, 0-not required --->
	<cfargument name="vadeflist"><!--- vadeflist="COID:TBLNAME:val1,dis1,val2,val3"--->
	<cfargument name="defvalue" default="">
	<cfargument name="viewonly" default=0> <!--- 0-normal, 1-viewonly (text output), 2-disabled DDL --->
	<cfargument name="onchange" default="">
	<cfargument name="style" default="" required="false">
	<cfargument name="class" default="" required="false">
	<cfargument name="onblur" default="">
	<cfargument name="placeholder" default=""> <!--- default text empty value for the dropdownlist --->
	<cfargument name="dynamicHTML" default="0"> <!--- return as a string for dynamic HTML building javascript --->
	<cfargument name="sortByColumn" default="ILINE"> <!--- sort query result by column (always ASC) --->

	<!---COID:TBLNAME:val1,dis1,val2,val3--->
	<cfset tblarr=listtoarray(vadeflist,":")>
	<cfif arraylen(tblarr) neq 3><!--- error --->
		<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCSTAT" Extendedinfo="No Table Definition Found">
	<cfelse>
		<cfset valarr=listtoarray(tblarr[3],",")>
		<cftry>
			<cfquery name=q_tdd datasource=#request.svcdsn#>
			select strval1=<cfif valarr[1] eq 1>vaP1<cfelseif valarr[1] eq 2>vaP2<cfelseif valarr[1] eq 3>vaP3<cfelseif valarr[1] eq 4>vaP4<cfelseif valarr[1] eq 5>vaP5<cfelseif valarr[1] eq 6>nVAL1<cfelseif valarr[1] eq 7>nVAL2</cfif>
			,disval=<cfif valarr[2] eq 1>vaP1<cfelseif valarr[2] eq 2>vaP2<cfelseif valarr[2] eq 3>vaP3<cfelseif valarr[2] eq 4>vaP4<cfelseif valarr[2] eq 5>vaP5<cfelseif valarr[2] eq 6>nVAL1<cfelseif valarr[2] eq 7>nVAL2</cfif>
			<cfif arraylen(valarr) gte 3 and valarr[3] neq "">
			,strval2=<cfif valarr[3] eq 1>vaP1<cfelseif valarr[3] eq 2>vaP2<cfelseif valarr[3] eq 3>vaP3<cfelseif valarr[3] eq 4>vaP4<cfelseif valarr[3] eq 5>vaP5<cfelseif valarr[3] eq 6>nVAL1<cfelseif valarr[3] eq 7>nVAL2</cfif>
			</cfif>
			<cfif arraylen(valarr) gte 4 and valarr[4] neq "">
			,strval3=<cfif valarr[4] eq 1>vaP1<cfelseif valarr[4] eq 2>vaP2<cfelseif valarr[4] eq 3>vaP3<cfelseif valarr[4] eq 4>vaP4<cfelseif valarr[4] eq 5>vaP5<cfelseif valarr[4] eq 6>nVAL1<cfelseif valarr[4] eq 7>nVAL2</cfif>
			</cfif>
			from FTBL0001 with (nolock)
			where vatblcode = <cfqueryparam value="#tblarr[2]#" cfsqltype="CF_SQL_NVARCHAR"> and iicoid=<cfqueryparam value="#tblarr[1]#" cfsqltype="CF_SQL_INTEGER">
			<cfif viewonly and defvalue neq "">
				<cfset defarr=listtoarray(defvalue,"~")><cfset filter=0>

				<cfif arraylen(defarr) gte 1 and defarr[1] neq ""><cfset filter=1>
				and <cfif valarr[1] eq 1>vaP1<cfelseif valarr[1] eq 2>vaP2<cfelseif valarr[1] eq 3>vaP3<cfelseif valarr[1] eq 4>vaP4<cfelseif valarr[1] eq 5>vaP5<cfelseif valarr[1] eq 6>nVAL1<cfelseif valarr[1] eq 7>nVAL2</cfif> = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#defarr[1]#">
				</cfif>

				<cfif arraylen(defarr) gte 3 and defarr[2] neq ""><cfset filter=1>
				and <cfif valarr[3] eq 1>vaP1<cfelseif valarr[3] eq 2>vaP2<cfelseif valarr[3] eq 3>vaP3<cfelseif valarr[3] eq 4>vaP4<cfelseif valarr[3] eq 5>vaP5<cfelseif valarr[3] eq 6>nVAL1<cfelseif valarr[3] eq 7>nVAL2</cfif> = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#defarr[2]#">
				</cfif>

				<cfif arraylen(defarr) gte 4 and defarr[3] neq ""><cfset filter=1>
				and <cfif valarr[4] eq 1>vaP1<cfelseif valarr[4] eq 2>vaP2<cfelseif valarr[4] eq 3>vaP3<cfelseif valarr[4] eq 4>vaP4<cfelseif valarr[4] eq 5>vaP5<cfelseif valarr[4] eq 6>nVAL1<cfelseif valarr[4] eq 7>nVAL2</cfif> = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#defarr[3]#">
				</cfif>
			</cfif>
			AND siSTATUS = 0
			order by 
				<!--- @CFIGNORESQL_S --->#sortByColumn#<!--- @CFIGNORESQL_E --->
			</cfquery>
			<cfcatch><cfthrow TYPE="EX_SECFAILED" ErrorCode="MTCTableSelect Function Error" Extendedinfo="In MTCcffunctions"></cfcatch>
		</cftry>
		<cfif viewonly eq 1>
			<cfif defvalue neq "" and q_tdd.recordCount neq 0 and filter><cfoutput>#q_tdd.disval#</cfoutput></Cfif>
		<cfelse>
			<cfif dynamicHTML EQ 0>
				<cfoutput><select <cfif req eq 1>CHKREQUIRED onChange="DoReq(this);<cfif onchange neq "">#onchange#</cfif>"<cfelseif req neq 1 and onchange neq "">onChange="#onchange#"</cfif><cfif name neq ""> name="#name#"</cfif><cfif idname neq ""> id="#idname#"</cfif> <cfif style neq ""> style="#style#"</cfif> <cfif class neq ""> class="#class#"</cfif><cfif onblur neq ""> onblur="#onblur#"</cfif> <cfif viewonly EQ 2> disabled </cfif>><option value=""><cfif placeholder neq "">#placeholder#</cfif></option><script>document.write(JSVCgenOptions("<cfloop query=q_tdd>#strval1#<cfif isDefined("strval2") and strval2 neq "">~#strval2#</cfif><cfif isDefined("strval3") and strval3 neq "">~#strval3#</cfif>|#disval#|</cfloop>","|"<cfif defvalue neq "">,"#defvalue#"<cfelseif q_tdd.recordCount eq 1>,"#q_tdd.strval1#<cfif isDefined("strval2") and strval2 neq "">~#q_tdd.strval2#</cfif><cfif isDefined("strval3") and strval3 neq "">~#q_tdd.strval3#</cfif>"</cfif>));</script></select></cfoutput>
			<cfelseif dynamicHTML EQ 1>
				<cfoutput>'<select <cfif req eq 1>CHKREQUIRED onChange="DoReq(this);<cfif onchange neq "">#onchange#</cfif>"<cfelseif req neq 1 and onchange neq "">onChange="#onchange#"</cfif><cfif name neq ""> name="#name#"</cfif><cfif idname neq ""> id="#idname#"</cfif> <cfif style neq ""> style="#style#"</cfif> <cfif class neq ""> class="#class#"</cfif><cfif onblur neq ""> onblur="#onblur#"</cfif> <cfif viewonly EQ 2> disabled </cfif>><option value=""><cfif placeholder neq "">#placeholder#</cfif></option>'+JSVCgenOptions("<cfloop query=q_tdd>#strval1#<cfif isDefined("strval2") and strval2 neq "">~#strval2#</cfif><cfif isDefined("strval3") and strval3 neq "">~#strval3#</cfif>|#disval#|</cfloop>","|"<cfif defvalue neq "">,"#defvalue#"<cfelseif q_tdd.recordCount eq 1>,"#q_tdd.strval1#<cfif isDefined("strval2") and strval2 neq "">~#q_tdd.strval2#</cfif><cfif isDefined("strval3") and strval3 neq "">~#q_tdd.strval3#</cfif>"</cfif>)+'</select>'</cfoutput>
			</cfif>
		</cfif>
	</cfif>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRTableSelect=MTRTableSelect>

<CFFUNCTION NAME="MTRSompoMedExpCertRunNo" output="yes">
	<CFARGUMENT name="caseid" type="string" required="true">
	<CFARGUMENT name="mode" type="string" required="true">

	<CFSET RETURNSTR = "">
	<CFSET PREV_RUNNO = "">

	<cfquery NAME=q_runnoLog DATASOURCE=#Request.MTRDSN#>
		SELECT TOP 1 RUNNO = va4, PREV_RUNNO = vx4 
		FROM FOBJ3025 WITH (NOLOCK) 
		WHERE iGCOID=1101213 AND iDOMID=1 AND siLOGTYPE=2093
		AND iOBJID = <cfqueryparam value="#Arguments.caseid#" cfsqltype="CF_SQL_INTEGER">
		ORDER BY dtCRTON DESC
	</cfquery>
	<CFIF q_runnoLog.recordCount GT 0>
		<CFIF LEN(q_runnoLog.PREV_RUNNO) GT 0>
			<CFSET PREV_RUNNO = q_runnoLog.PREV_RUNNO & ", " & q_runnoLog.RUNNO>
		<CFELSE>
			<CFSET PREV_RUNNO = q_runnoLog.RUNNO>
		</CFIF>
	</CFIF>

	<CFIF Arguments.mode EQ "PREV_RUNNO">
		<CFSET RETURNSTR = PREV_RUNNO>
	<CFELSEIF Arguments.mode EQ "NEW_RUNNO">
		<cfquery NAME=q_trxDtls DATASOURCE=#Request.MTRDSN#>
			SELECT CLAIMANT = CASE WHEN LEFT(RTRIM(b.aCLAIMTYPE),2) ='TP' THEN ib.vaCLAIMANT ELSE b.vaINSUREDNAME END, 
			DRVNAME = b.vaDRVNAME, PROVINCE = p.vaCFDESC, NOTIFYNO = b.vaCNOTIFYNO, CLMNO = i.vaCLMNO, 
			INSREGNO = CASE WHEN LEFT(RTRIM(b.aCLAIMTYPE),2) ='TP' THEN b.va3REGNO ELSE b.vaREGNO END
			FROM TRX0008 i WITH (NOLOCK) 
			INNER JOIN TRX0001 b WITH (NOLOCK) ON b.iCASEID = i.iCASEID
			LEFT JOIN TRX0055B ib WITH (NOLOCK) ON ib.iCASEID = i.iCASEID
			LEFT JOIN BIZ0025 p WITH (NOLOCK) ON p.iCOID=1101213 AND p.aCFTYPE='STATE' AND p.vaCFCODE = b.iREGNO_STATEID
			WHERE i.iCASEID = <cfqueryparam value="#Arguments.caseid#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<CFIF findNoCase("/",q_trxDtls.PROVINCE) GT 0>
			<CFSET VEHPROVINCE = mid(q_trxDtls.PROVINCE,1,findNoCase("/",q_trxDtls.PROVINCE)-1)>
		<CFELSE>
			<CFSET VEHPROVINCE = q_trxDtls.PROVINCE>
		</CFIF>
		<CFSTOREDPROC PROCEDURE="sspFSYSReserveRunningID" DATASOURCE=#Request.MTRDSN# RETURNCODE=YES>
			<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE="#SESSION.VARS.GCOID#" DBVARNAME=@ai_coid>
			<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_VARCHAR VALUE="MEXPCERT" DBVARNAME=@aa_raname>
			<CFPROCPARAM TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE="#SESSION.VARS.USID#" DBVARNAME=@ai_usid>
			<CFPROCPARAM TYPE=OUT CFSQLTYPE=CF_SQL_VARCHAR VARIABLE="CURRUNNO" DBVARNAME=@as_reserved>
		</CFSTOREDPROC>
		<cfmodule TEMPLATE="#request.apppath#services/index.cfm" FUSEBOX=SVCobj FUSEACTION=act_multiloginner DOMAINID=1 OBJID=#Attributes.caseid# COROLE=2 LOGTYPE=2093 LOGID=0 
			as_4 = "#CURRUNNO#" ax_4 = "#PREV_RUNNO#" ax_1 = "#q_trxDtls.CLAIMANT#" ax_2="#q_trxDtls.DRVNAME#" as_1 = "#q_trxDtls.INSREGNO#" 
			ax_3 = "#VEHPROVINCE#" as_2 = "#q_trxDtls.NOTIFYNO#" as_3 = "#q_trxDtls.CLMNO#">
		<CFSET RETURNSTR = CURRUNNO>
	</CFIF>

	<CFRETURN RETURNSTR>
</CFFUNCTION>
<CFSET Attributes.DS.MTRFN.MTRSompoMedExpCertRunNo=MTRSompoMedExpCertRunNo>

<CFFUNCTION NAME="MTRgetTypeClaimList" access="public" returntype="any" output="true">
	<CFARGUMENT name="gcoid" type="string" required="true">
	<CFARGUMENT name="clmtypemask" type="string" required="true">
	<CFARGUMENT name="selecteditem" type="string" required="false" default=""><!--- delim with comma; list of selected item. the item could be selected previously, but deleted later. with param of selected items, system will able bring back the deleted item selected into select option --->
	<cfset var Ret=StructNew()>
	<cfset ret.typeclm={}>
	<cfset ret.optlist="">
	<cfset var icoid=#arguments.gcoid#>
	<cfset var q_t="">
	<cfif icoid NEQ "" AND arguments.clmtypemask NEQ "">
		<cfif structkeyexists(request.ds.typeclmbycoid,icoid)>
			<cfloop list=#request.ds.typeclmbycoid[icoid].list# index="itm">
				<cfif request.ds.typeclmbycoid[icoid].typeclm[itm].clmtypemask GT 0 AND BITAND(request.ds.typeclmbycoid[icoid].typeclm[itm].clmtypemask,arguments.clmtypemask) GT 0>
					<cfset Ret.typeclm[itm]=request.ds.typeclmbycoid[icoid].typeclm[itm]>
					<cfset Ret.optlist=listappend(Ret.optlist,"#itm#|#request.ds.typeclmbycoid[icoid].typeclm[itm].name#","|")>
					<cfif arguments.selecteditem NEQ "" AND listfind(arguments.selecteditem,itm) GT 0>
						<!--- found the list from selected item param? --->
						<cfset arguments.selecteditem=ListDeleteAt(arguments.selecteditem, ListFind(arguments.selecteditem,itm))>
					</cfif>
				</cfif>				
			</cfloop>
		</cfif>
		<cfif LISTLEN(arguments.selecteditem) GT 0><!--- found item which flagged as deleted? try retrieve in biz0025. usually this only happen to old cases --->
			<cfquery NAME=q_t DATASOURCE=#Request.MTRDSN#>
			select vacfcode, vacfdesc FROM biz0025 with (nolock)
			where icoid=<cfqueryparam value="#icoid#" cfsqltype="CF_SQL_INTEGER">
			AND acftype='TYPECLM'
			AND cast(vacfcode as integer) IN ( select val from dbo.StringToTableInt(<cfqueryparam value="#arguments.selecteditem#" cfsqltype="CF_SQL_varchar">) )
			</cfquery>
			<cfloop query="q_t">
				<!--- parse deleted item into select option --->
				<cfset Ret.optlist=listappend(Ret.optlist,"#q_t.vacfcode#|#q_t.vacfdesc# (deleted)","|")>
			</cfloop>
		</cfif>
	</cfif>
	<cfreturn Ret>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRgetTypeClaimList=MTRgetTypeClaimList>
<CFFUNCTION NAME="MTRgetTypeClaimSelected" access="public" returntype="any" output="true">	
	<!--- new method to get type of claim as a replacement method from MTRgetTypeofClaim, to overcome the issue of keep track the list exceeds 64 items 
		required:
		(1) caseid 
		OR
		(2) gcoid + selected value

		params:
		caseid: (main caseid) will get value in list based on caseid provided, and show the type of claim
		gcoid: definition defined for gcoid (insurer)
		value: (in list) will show the type of claim based on param list provided
	--->
	<CFARGUMENT name="caseid" type="string" required="true"><!--- either 0 (without caseid provided) or +ve (caseid) --->
	<CFARGUMENT name="gcoid" type="string" default=0>
	<CFARGUMENT name="value" type="string" default="">
	<cfset var q_t=""><cfset var itm="">
	<cfif arguments.caseid GT 0>
		<cfset arguments.value="">
		<cfquery NAME=q_t DATASOURCE=#Request.MTRDSN#>
		SELECT b.igcoid, vaTYPECLMLIST FROM TRX0008 a with (nolock)
		JOIN SEC0005 b with (nolock) ON a.icoid=b.icoid
		WHERE icaseid=<cfqueryparam value="#arguments.caseid#" cfsqltype="CF_SQL_INTEGER"> and sitpins=0
		</cfquery>
		<cfif q_t.recordcount GT 0>
			<cfset arguments.value=#q_t.vaTYPECLMLIST#>
			<cfset arguments.gcoid=#q_t.igcoid#>
		</cfif>
	</cfif>
	<cfif arguments.gcoid IS ""><cfset arguments.gcoid=0></cfif>
	<cfset var Ret=StructNew()>
	<cfset ret.typeclm={}>
	<cfset ret.valuelist="">
	<cfset ret.desclist="">
	<!--- <cfdump var=#arguments.value#> .. --->
	<cfif arguments.value NEQ "">
		<!--- <cfdump var=#request.ds.typeclmbycoid#> vs <cfdump var=#arguments.gcoid#> --->
		<!--- based on request.ds.typeclmbycoid --->
		<cfloop list=#arguments.value# index="itm">
			<cfif structkeyexists(request.ds.typeclmbycoid,arguments.gcoid)>
				<!--- <cfif structkeyexists(request.ds.typeclmbycoid[arguments.gcoid],typeclm) AND structkeyexists(request.ds.typeclmbycoid[arguments.gcoid].typeclm,itm) AND listfindnocase(arguments.value,ITM) GT 0>22. --->
				<cfif structkeyexists(request.ds.typeclmbycoid[arguments.gcoid].typeclm,itm) 
				AND listfindnocase(arguments.value,ITM) GT 0>
					<cfset Ret.typeclm[itm]=request.ds.typeclmbycoid[arguments.gcoid].typeclm[itm]>
					<cfif LISTFINDNOCASE(ret.valuelist,itm) IS 0>
						<cfset ret.valuelist=listappend(ret.valuelist,itm)>
						<cfset ret.desclist=listappend(ret.desclist,request.ds.typeclmbycoid[arguments.gcoid].typeclm[itm].name,"|")>
						<cfif arguments.value NEQ "" AND listfind(arguments.value,itm) GT 0>
							<!--- found the list from selected item param? --->
							<cfset arguments.value=ListDeleteAt(arguments.value, ListFind(arguments.value,itm))>
						</cfif>
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		<cfif LISTLEN(arguments.value) GT 0><!--- found item which flagged as deleted? try retrieve in biz0025. usually this only happen to old cases --->
			<cfquery NAME=q_t DATASOURCE=#Request.MTRDSN#>
			select vacfcode, vacfdesc FROM biz0025 with (nolock)
			where icoid=<cfqueryparam value="#icoid#" cfsqltype="CF_SQL_INTEGER">
			AND acftype='TYPECLM'
			AND cast(vacfcode as integer) IN ( select val from dbo.StringToTableInt(<cfqueryparam value="#arguments.value#" cfsqltype="CF_SQL_varchar">) )
			</cfquery>
			<cfloop query="q_t">
				<!--- parse deleted item into select option --->
				<cfset ret.valuelist=listappend(ret.valuelist,q_t.vacfcode)>
				<cfset ret.desclist=listappend(ret.desclist,"#q_t.vacfdesc# (deleted)","|")>
			</cfloop>
		</cfif>
	</cfif>
	<cfreturn Ret>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRgetTypeClaimSelected=MTRgetTypeClaimSelected><CFSET Attributes.DS.MTRFN.MTRSompoMedExpCertRunNo=MTRSompoMedExpCertRunNo>

<cffunction name="MTRIsBike" access="public" returntype="boolean" output="no" hint="">
<cfargument name="CaseID" type="numeric" required="true">
<cfset var q_trx={}>
<cfset result=false>
<cfquery NAME=q_trx DATASOURCE=#Request.MTRDSN#>
SELECT b.siVHTYPEID
FROM TRX0001 a WITH (NOLOCK)
	INNER JOIN mpartsdb.dbo.CAT0005 b WITH (NOLOCK) ON a.iVARID=b.iVARID
WHERE a.iCASEID=<cfqueryparam value="#arguments.CaseID#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfif q_trx.RecordCount IS 1 AND ListFind("21,30,31,32,33,34,35,36",q_trx.siVHTYPEID)>
	<cfset result=true>
</cfif>
<cfreturn result>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRIsBike=MTRIsBike>

<cffunction name="MTRTemplateShow" access="public" output="yes">
	<cfargument name="coid" type="numeric" required="true">
	<cfargument name="filename" type="string" required="true">
	<cfargument name="attrs" type="struct" required="false" default=#structnew()#>
	<!--- can be enhanced with docdefid in the future: <cfargument name="docdefid"> --->
	<cfset PHYPATH="#Request.logpath#secured/template/#arguments.coid#/#arguments.filename#.cfm">
	<cfset var customtemplate=0>
	<cfif FileExists(ExpandPath(PHYPATH))><cfset customtemplate=1></cfif>
	<cfif customtemplate IS 0>
		<cfset PHYPATH="#Request.logpath#secured/template/#arguments.filename#.cfm">
		<cfif NOT FileExists(PHYPATH)>
			<CFTHROW TYPE="EX_DBERROR" ErrorCode="BADPARAM">
		</cfif>
	</cfif>
	<cfmodule TEMPLATE="#PHYPATH#" attributecollection=#arguments.attrs#>
	<cfreturn>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRTemplateShow=MTRTemplateShow>

<cffunction name="MTRCalcVNVAT" output="true">
	<cfargument name="oldTaxPC" required="true" hint="no apply tax dropdown and shared VAT with Edit Offer screen">
	<cfargument name="newTaxPC" required="true" hint="VAT selected from apply tax drop down from ##43137">
	<cfargument name="applyTax" required="true" hint="Obsolete by ##43137 but still applicable to existing old case before enhancement">
	<cfargument name="mode" default="0" hint="0: Return VAT only, 1: Return 1+VAT">

	<cfset baseConstant = 0>
	<CFIF arguments.mode EQ 1>
		<cfset baseConstant = 1>
	</CFIF>
	<CFIF newTaxPC GTE 0> <!--- newTaxPC: -1 when it is null so will check on old calculation instead --->
		<cfset VATPC = baseConstant +(arguments.newTaxPC/100)>
	<CFELSEIF applyTax EQ 1>
		<cfset VATPC = baseConstant +(arguments.oldTaxPC/100)>
	<CFELSE>
		<cfset VATPC = baseConstant>
	</CFIF>
	<cfreturn VATPC>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRCalcVNVAT=MTRCalcVNVAT>

<!--- 43426 --->
<cffunction name="MTRGenOptMRCPart" description="Show MRC parts" access="public" returntype="any" output="true">
	<cfargument name="caseid" type="numeric" required="true">
	<cfargument name="partid" type="numeric" required="true">
	<cfset var q_mrcpart1={}>
	<cfset var q_mrcpart2={}>
	<!--- Get MRC Ref --->
	<CFQUERY NAME=q_mrcref DATASOURCE=#Request.MTRDSN#>
		SELECT b.vaSRCPTREF,carModel = vaMAN + ' ' + vaMODEL
		FROM TRX0035 b WITH (NOLOCK)
		WHERE b.aCOTYPE='I' 
		AND b.iLCASEID=<cfqueryparam value="#arguments.caseid#" cfsqltype="CF_SQL_INTEGER"> 
		AND b.iPSCID=4
	</CFQUERY>

		<!--- Get Part No of Standard Parts --->
		<CFQUERY NAME=q_ptno DATASOURCE=#Request.MTRDSN#>
			SELECT a.vaPARTNO
				FROM [mpartsdb].[dbo].PDB0006 a WITH (NOLOCK)
			WHERE a.iPSCID=1 
			AND a.VADESCCODE=<cfqueryparam value="#arguments.partid#" cfsqltype="CF_SQL_INTEGER"> 
		</CFQUERY>
		<CFSET NORMALIZED_PARTNO=UCase(ReReplaceNoCase(q_ptno.vaPARTNO,"[^A-Z0-9]","","ALL"))>
	
		<!--- Get MRC Parts by using Part No of Standard Parts --->
		<CFQUERY NAME=q_mrcpart1 DATASOURCE=#Request.MTRCATDSN#>
			SELECT TOP 1 p.VADESCCODE, d.vaDESC, partLID=isNull(d.iLID,0)
			FROM  [mpartsdb].[dbo].PDB0006 p WITH (NOLOCK)
			INNER JOIN [mpartsdb].[dbo].PDB0003 d WITH (NOLOCK) ON d.iPSCID=p.iPSCID AND d.vaDESCCODE=p.vaDESCCODE AND d.siSTATUS=0
			WHERE p.iPSCID=4 
			AND p.vaPARTNO=<cfqueryparam value="#NORMALIZED_PARTNO#" cfsqltype="CF_SQL_NVARCHAR"> 
			AND p.vaPROJCODE=<cfqueryparam value="#q_mrcref.vaSRCPTREF#" cfsqltype="CF_SQL_NVARCHAR">
			ORDER BY p.vaDESCCODE
		</CFQUERY>

		<CFIF q_mrcpart1.RecordCount IS 1>
			<script>document.write(JSVCgenOptions("<CFLOOP query=q_mrcpart1>#VADESCCODE#|#Server.SVClang(vaDESC,partLID)#|</CFLOOP>","|"));</script>
		<CFELSE>
			<CFQUERY NAME=q_ptname DATASOURCE=#Request.MTRDSN#>
				SELECT a.vaDESC
					FROM [mpartsdb].[dbo].PDB0003 a WITH (NOLOCK)
				WHERE a.iPSCID=1 
				AND a.VADESCCODE=<cfqueryparam value="#arguments.partid#" cfsqltype="CF_SQL_INTEGER"> 
			</CFQUERY>

			<cfset partname = q_ptname.vaDESC>
			<cfset firstitm = listFirst(partname, " ")>
			<cfset partarr = ListToArray(partname, " ")>
			<CFIF ArrayLen(partarr) GT 0>
				<cfset selectquery = 'select'>
				<cfset cnt = 1>
				<CFLOOP array=#partarr# index=idx>
					<cfoutput>
						<cfset selectquery = selectquery & " text" & cnt & "=dbo.fGetMetaphone('" & idx & ''')'>
						<CFIF cnt LT ArrayLen(partarr)>
							<cfset selectquery = selectquery & ','>
						</CFIF>
						<cfset cnt = cnt + 1>
					</cfoutput>
				</cfloop>

				<CFQUERY NAME=q_mrcmeta DATASOURCE=#Request.MTRDSN#>
					<!--- @CFIGNORESQL_S --->#preserveSingleQuotes(selectquery)#<!--- @CFIGNORESQL_E --->
				</CFQUERY>

				<CFIF q_mrcmeta.recordcount EQ 1>
					<cfset str1 = 'CASE WHEN c.vadesc LIKE ''%' & q_mrcmeta.text1 & '%'' THEN 1 ELSE 0 END'>
					<cfset str2 = 'd.vadesc like (''%' & firstitm & '%'')'>
					<cfset str3 = 'c.vadesc like (''%' & q_mrcmeta.text1 & '%'')'>

					<CFIF ArrayLen(partarr) GT 1>
						<CFLOOP index="idx" from="2" to="#ArrayLen(partarr)#">
							<cfset metatext = #q_mrcmeta["text" & idx]# >
							<cfoutput>
								<cfset str1 = str1 & ' + CASE WHEN c.vadesc LIKE ''%' & #metatext# & '%'' THEN 1 ELSE 0 END'>
								<cfset str3 = str3 & ' OR c.vadesc like (''%' & #metatext# & '%'')'>
							</cfoutput>
						</cfloop>
					</CFIF>
					<cfset conditionStr = str2 & ' and (' & str3 & ')'>

					<CFQUERY NAME=q_mrcpart2 DATASOURCE=#Request.MTRDSN#>
						Select DISTINCT TOP 10 d.vadesccode, d.vadesc, partLID=isNull(d.iLID,0),
						MATCHES=(<!--- @CFIGNORESQL_S --->#preserveSingleQuotes(str1)#<!--- @CFIGNORESQL_E --->)
							FROM mpartsdb.dbo.PDB0006 b WITH (NOLOCK)
						LEFT JOIN mpartsdb.dbo.PDB0005 a with (nolock) ON a.iPSCID=b.IPSCID
						LEFT JOIN mpartsdb.dbo.PDB0003_METAMAP c with (nolock) ON c.IPSCID=b.IPSCID AND c.VADESCCODE=b.VADESCCODE
						LEFT JOIN mpartsdb.dbo.PDB0003 d ON c.IPSCID=d.IPSCID and c.VADESCCODE=d.VADESCCODE
						WHERE b.iPSCID=4 
						<CFIF q_mrcref.vaSRCPTREF NEQ "">
							AND b.vaPROJCODE=<cfqueryparam value="#q_mrcref.vaSRCPTREF#" cfsqltype="CF_SQL_NVARCHAR">	
						<CFELSE>
							AND a.VAPROJDESC like ('%#q_mrcref.carModel#%')					
						</CFIF>
						AND <!--- @CFIGNORESQL_S --->#preserveSingleQuotes(conditionStr)#<!--- @CFIGNORESQL_E --->
						ORDER BY MATCHES DESC
					</CFQUERY>

					<CFIF q_mrcpart2.RecordCount GT 0>
						<script>document.write(JSVCgenOptions("<CFLOOP query=q_mrcpart2>#VADESCCODE#|#Server.SVClang(vaDESC,partLID)#|</CFLOOP>","|"));</script>
					</CFIF>
				</CFIF>
			</CFIF>
		</CFIF>
</cffunction>
<CFSET Attributes.DS.MTRFN.MTRGenOptMRCPart=MTRGenOptMRCPart>