<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCDISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">
<CFSET CASEID = Attributes.CASEID>
<CFSET INSGCOID = Attributes.INSGCOID>

<CFSET MAILSUBJECT="[#Application.DB_COUNTRY#_#Application.DB_MODE#] [CLAIM] - Connection Failure on ETIQA API - CASEID: #CASEID#">
<CFSET EmailTo="amir.ot@etiqa.com.my;analitiqa@etiqa.com.my;MRMIntegration@merimen.com">
<CFSET EmailCC="jimmy.loh@merimen.com">
<CFOBJECT component="#Request.APPPATHCFC#services.cfc.SVCmail" name="MAIL">

<CFSET Attributes.IntSettings=Request.DS.FN.SVCgetAppSettings("I-MY-ETQ-CLM")>
<CFSET Request.ERRORDIAGNOSTICS="">
<CFSET success=0>
<CFSET RESP={}>
<CFSET RESP.SUCCESS=0>
<CFSET ResponseStruct=StructNew()>
<CFSET ResponseStruct.ServiceName="">
<CFSET ResponseStruct.SOAPRequestJSON="">
<CFSET ResponseStruct.SOAPResponseJSON="">
<CFSET ResponseStruct.HTTPStatusCode="">

<CFTRY>
<CFIF CASEID NEQ 0>	
	<CFQUERY NAME="q_getAPIinfo" DATASOURCE=#Request.MTRDSN#>
		SELECT 
		[driveable] = CASE WHEN a.siDRIVEABLE = 1 THEN 'true' ELSE 'false' END,
		[odometer] = a.iODO,
		[estrepdays] = a.siRepdays,
		[vehicle_type] = l.siVDVHTYPEID, 
		[insured] = a.vaINSUREDNAME, 
		[driver] = a.vaDRVNAME, 
		[year_of_vehicle]= DATEDIFF(year,l.dtVDJPJREG,a.dtACCDATE),
		[vehsource] = CASE WHEN a.iVEHSOURCE = 1 THEN 'true' Else 'false' END, 
		[dateofloss]= a.dtACCDATE,
		[dateofjpj] = l.dtVDJPJREG, 
		[tpinvolved] = CASE WHEN a.siTP = 1 THEN 'true' Else 'false' END, 
		[tpinjury] = CASE WHEN a.siINJURY = 1 THEN 'true' Else 'false' END,  
		[losslocType] = loc.vaCFDESC, 
		[provisional] = CASE WHEN l.siCDDPL = 1 THEN 'true' Else 'false' END,
		[gencond] = CASE
					WHEN a.vaGENCON = 'P' THEN 'Poor'
					WHEN a.vaGENCON = 'F' THEN 'Fair'
					WHEN a.vaGENCON = 'G' THEN 'Good'
					WHEN a.vaGENCON = 'E' THEN 'Excellent'
					END, 
		[dmgcond] = CASE
					WHEN l.siCONDAMAGE = 1 THEN 'Minor'
					WHEN l.siCONDAMAGE = 2 THEN 'Moderate'
					WHEN l.siCONDAMAGE = 3 THEN 'Serious'
					WHEN l.siCONDAMAGE = 4 THEN 'Very Serious'
					END, 
		[dmglosstype] = dmg.vaCFDESC,
		[rprtype]	= CASE WHEN (r.siFRANCHISE=1) THEN 'Franchise' 
						ELSE
							CASE WHEN b.iEFFFLAG&2=2 THEN 'Panel' ELSE 'Non-Panel' 
	        			END
	        		  END
	    FROM TRX0001 a WITH(NOLOCK)
				LEFT JOIN TRX0008 b WITH(NOLOCK) ON b.iCASEID=a.iCASEID AND b.siTPINS=0
				INNER JOIN SEC0005 r WITH(NOLOCK) ON r.iCOID=a.iCOID
				LEFT JOIN BIZ0025 dmg WITH(NOLOCK) ON (dmg.icoid = <cfqueryparam value="#INSGCOID#" cfsqltype="cf_sql_integer"> or dmg.icoid=0)
					AND dmg.aCFTYPE = 'ISMVEHDMG'
					AND dmg.vaCFCODE = a.siDAMTYPE
				LEFT JOIN TRX0055 l WITH(NOLOCK) ON l.iCASEID = a.iCASEID
				LEFT JOIN BIZ0025 loc WITH(NOLOCK) ON (loc.icoid = <cfqueryparam value="#INSGCOID#" cfsqltype="cf_sql_integer"> or loc.icoid=0)
					AND loc.aCFTYPE = 'LOCCLAIM' 
					AND loc.vaCFCODE = l.siLOCCLAIM
		WHERE a.iCASEID = <cfqueryparam value="#CASEID#" cfsqltype="cf_sql_integer">  and a.iMCASEID=l.iCASEID 
	</CFQUERY>

	<CFQUERY name = q_getParts datasource=#Request.MTRDSN#>
		SELECT vaDESC,OCASEID=IsNull(iOCASEID,0) FROM trx0036 WITH(NOLOCK) where iLCASEID = <cfqueryparam value="#CASEID#" cfsqltype="cf_sql_integer"> AND aCOTYPE = 'R' 	
		order by OCASEID,iLGROUPID,CASE WHEN vaSRCPLID IS NULL THEN 'ZZZZ' ELSE vaDESC END,iDPTID 
	</CFQUERY>

	<CFIF q_getParts.RecordCount GT 0 >
		<CFSET parts_list= ArrayNew(1)>
		<CFLOOP query="q_getParts">
			<CFSET ArrayAppend(parts_list, vaDESC)>
		</CFLOOP>
		<CFSCRIPT>parts_list = serializeJSON(parts_list);</CFSCRIPT>
	</CFIF>

	<CFIF q_getAPIinfo.RecordCount GT 0>
		<CFOUTPUT query ="q_getAPIinfo">
			<CFSET vehtype = #Request.DS.VHTYPE[vehicle_type]#>
		
			<CFSAVECONTENT variable="SOAPRequestJSON">
				{
				"case_id": #CASEID#,
				"driveable": #driveable#,
				"odometer_reading": #odometer#,
				"est_repair_duration_rep": #estrepdays#,
				"vehicle_type": "#vehtype#",
				<CFIF insured EQ driver>"owner": true,
				<CFELSE>"owner": false,
				</CFIF>
				"tow": #vehsource#,
				"year_of_vehicle": #year_of_vehicle#,
				"repairer_type": "#rprtype#",
				"third_party_involved": #tpinvolved#,
				"third_party_injury": #tpinjury#,
				"loss_location_type": "#losslocType#",
				"provisional": #provisional#,
				"general_condition": "#gencond#",
				"damage_condition": "#dmgcond#",
				"damage_loss_type": "#dmglosstype#",
				"parts_list": #parts_list#
				}
			</CFSAVECONTENT>
		</CFOUTPUT>
	<CFELSE>
		<CFSET SOAPRequestJSON="">
	</CFIF>
<CFELSE>
	<CFTHROW TYPE="EX_DBERROR" ErrorCode="No Case Found (#CASEID#)">
</CFIF>


<!---Get Token--->
<!--- 
sit_token_url-"https://staging.api.maybank.com:21100/api/v1.0/my/oauth/token"
uat_token_url-"https://staging.api.maybank.com:31100/api/v1.0/my/oauth/token" 
--->
<CFSET base_url=Attributes.IntSettings.WEBSVCADDR>
<CFSET token_url=Attributes.IntSettings.tokenURL> 
<CFSET post_url=Attributes.IntSettings.postURL>
<CFSET success=0>
<CFSET retry=0>
<CFSET tokenResponseData="">

<CFOUTPUT>
<CFSAVECONTENT variable="TOKENREQUESTDATA">
{
	"grant_type":"#Attributes.IntSettings.CLMGrantType#",
	"scope":"#Attributes.IntSettings.CLMScope#",
	"client_id":"#Attributes.IntSettings.CLMClientID#",
	"client_secret":"#Attributes.IntSettings.CLMClientSecret#"
}
</CFSAVECONTENT>
</CFOUTPUT>

<CFLOOP condition="success NEQ 1 AND retry LT 5">
	<cfhttp method="POST" url="#token_url#" timeout="30" result="token_result">
		<CFHTTPparam type="header" name="Content-Type" value="application/json"/>
		<CFHTTPparam type="body" value="#TOKENREQUESTDATA#"/>
	</cfhttp>

	<CFIF isDefined("token_result.Statuscode")>
		<CFSET ResponseStruct.HTTPStatusCode=token_result.StatusCode>
		<CFIF token_result.Statuscode EQ "200 OK">
			<CFSET success=1>
		<CFELSE>
			<CFSET retry+=1>
		</CFIF>
	</CFIF>
</CFLOOP>

<CFIF isDefined("token_result.Filecontent") AND token_result.Filecontent NEQ "">
	<CFSET ResponseStruct.SOAPResponseJSON=Trim(ToString(token_result.Filecontent))>
	<CFSET ResponseStruct.SOAPRequestJSON=TOKENREQUESTDATA>
</CFIF>

<CFIF success>
	<CFSET tokenResponseData = ResponseStruct.SOAPResponseJSON>
	<CFSET tokenResult = deserializeJSON(tokenResponseData)>
	<CFSET tokenResult = tokenResult.data>
	<CFIF tokenResult.access_token NEQ "">
		<CFSET access_token = Trim(tokenResult.access_token)>
	<CFELSE>
		<CFSET access_token = "">
		<Cfthrow TYPE="EX_SECFAILED" ErrorCode="BADTOKEN" EXTENDEDINFO="Access Token is blank">
	</CFIF>
	<CFIF tokenResult.token_type NEQ "">
		<CFSET token_type = Trim(tokenResult.token_type)>
	<CFELSE>
		<CFSET token_type = "">
		<Cfthrow TYPE="EX_SECFAILED" ErrorCode="BADTOKEN" EXTENDEDINFO="Token Type is blank">
	</CFIF>
	<CFIF tokenResult.scope NEQ "">
		<CFSET scope = Trim(tokenResult.scope)>
	<CFELSE>
		<CFSET scope = "">
		<Cfthrow TYPE="EX_SECFAILED" ErrorCode="BADTOKEN" EXTENDEDINFO="Scope is blank">
	</CFIF>

	<CFIF tokenResponseData IS NOT "">
		<CFSET ResponseStruct.ServiceName="EtiqaGetPartsColor">
		<CFSET success=0>
		<CFSET retry=0 >

		<!---Connect API--->
		<!--- https://staging.api.maybank.com:31101/api/v1/my/merimen/claims --->
		<CFLOOP condition="success NEQ 1 AND retry LT 5">
			<CFHTTP method="post" url="#post_url#" result="result" timeout="30" throwonerror="true">
				<CFHTTPparam type="header" name="Content-Type" value="application/json"/>
				<CFHTTPparam type="header" name="Authorization" value="#token_type# #access_token#"/>
				<CFHTTPparam type="body" value="#SOAPRequestJSON#"/>
			</CFHTTP>

			<CFIF isDefined("result.Statuscode")>
				<CFSET ResponseStruct.HTTPStatusCode=result.StatusCode>
				<CFIF result.Statuscode EQ "201 CREATED">
					<CFSET success=1>
				<CFELSE>
					<CFSET retry+=1>
				</CFIF>
			</CFIF>
		</CFLOOP>

		<CFIF isDefined("result.Filecontent") AND result.Filecontent NEQ "">
			<CFSET ResponseStruct.SOAPResponseJSON=Trim(ToString(result.Filecontent))>
			<CFSET ResponseStruct.SOAPRequestJSON=SOAPRequestJSON>
		</CFIF>

		<CFIF success>
			<CFSET responseJSON = deserializeJSON(ResponseStruct.SOAPResponseJSON)>
			<CFIF isDefined("responseJSON.case_id") AND responseJSON.case_id NEQ "">
				<CFSET RESP.CASEID=responseJSON.case_id>
				<CFSET RESP.RESULT=responseJSON.parts>
				<CFSET RESP.SUCCESS=1>
			<CFELSE>
				<Cfthrow TYPE="EX_SECFAILED" ErrorCode="BADJSON" EXTENDEDINFO="CASEID and PartDetails are not found in response. RESPONSE: #ResponseStruct.SOAPResponseJSON#">
			</CFIF>
		<CFELSE>
			<Cfthrow TYPE="EX_SECFAILED" ErrorCode="BADHTTP" EXTENDEDINFO="#result.Filecontent#">
			<!--- Send error mail --->
			<CFSET MAILBODY=result.Filecontent>
			<CFSET MAIL.Create(INSGCOID,1,2,0,0,MAILSUBJECT,MAILBODY,EmailTo,EmailCC)>
			<CFSET MAIL.Send()>		
		</CFIF>
	</CFIF>
<CFELSE>
	<Cfthrow TYPE="EX_SECFAILED" ErrorCode="BADHTTP" EXTENDEDINFO="#token_result.Filecontent#">
	<!--- Send error mail --->
	<CFSET MAILBODY=token_result.Filecontent>
	<CFSET MAIL.Create(INSGCOID,1,2,0,0,MAILSUBJECT,MAILBODY,EmailTo,EmailCC)>
	<CFSET MAIL.Send()>		
</CFIF>

<cfcatch>
	<CFIF isDefined("ResponseStruct.SOAPResponseJSON") AND ResponseStruct.SOAPResponseJSON IS NOT "" >
		<CFIF isJSON(ResponseStruct.SOAPResponseJSON)>
			<CFSET errormsg = deserializeJSON(ResponseStruct.SOAPResponseJSON)>
			<CFIF isDefined("errormsg.code") AND errormsg.code EQ "500">
				<CFSET Request.ErrorDiagnostics="#errormsg.code# #errormsg.status# - Response: #errormsg.message#">
			<CFELSEIF isDefined("errormsg.code") AND isDefined("errormsg.details")>
				<CFSET Request.ErrorDiagnostics="#errormsg.code# - Response: #errormsg.details#">
			<CFELSE>
				<CFSET Request.ErrorDiagnostics="BADJSON Response: #ResponseStruct.SOAPResponseJSON#">
			</CFIF>
		<CFELSE>
			<CFSET Request.ErrorDiagnostics="HTTP StatusCode: #ResponseStruct.HTTPStatusCode#... Response: #ResponseStruct.SOAPResponseJSON#">
		</CFIF>
	<CFELSE>
		<CFSET Request.ErrorDiagnostics=#serializeJSON(CFCATCH)#>
	</CFIF>
</cfcatch>

<cffinally>
	<CFSET STATUS="FAIL">
	<CFIF RESP.SUCCESS>
		<CFSET STATUS="SUCCESS">
	</CFIF>
	<CFQUERY NAME=q_clm DATASOURCE=#Application.MTRDSN#>
		DECLARE @li_result int
		EXECUTE @li_result=sspFINTCreateOutgoingLog @as_batchname=<cfqueryparam value="#Attributes.IntSettings.BATCHNAME#" cfsqltype="CF_SQL_VARCHAR">
													,@as_msg=<cfqueryparam value="#ResponseStruct.SOAPRequestJSON#" cfsqltype="CF_SQL_VARCHAR">
													<CFIF isDEFINED("ResponseStruct.SOAPResponseJSON") AND ResponseStruct.SOAPResponseJSON IS NOT "">
														,@as_msg2=<cfqueryparam value="#ResponseStruct.SOAPResponseJSON#" cfsqltype="CF_SQL_VARCHAR">
													<CFELSE>
														,@as_msg2=NULL
													</CFIF>
													,@as_filenameORurl=<cfqueryparam value="#ResponseStruct.ServiceName#: #base_url#" cfsqltype="CF_SQL_VARCHAR">
													,@as_inteventstr=<cfqueryparam value="0" cfsqltype="CF_SQL_VARCHAR">
		SELECT Result=@li_result;
	</CFQUERY>
	<cfmodule TEMPLATE="#Request.LOGPATH#\CustomTags\MTRINTMultiLog.cfm" Mode=2 DomainID=312 IOBJID=#q_clm.Result# KEY="CLAIM_DATA" VALUE="ETQ_CLM_DATA">
	<cfmodule TEMPLATE="#Request.LOGPATH#\CustomTags\MTRINTMultiLog.cfm" Mode=2 DomainID=312 IOBJID=#q_clm.Result# KEY="CASE_ID" VALUE="#CASEID#">
	<cfmodule TEMPLATE="#Request.LOGPATH#\CustomTags\MTRINTMultiLog.cfm" Mode=2 DomainID=312 IOBJID=#q_clm.Result# KEY="WEB_STATUS" VALUE="#STATUS#">
	<cfmodule TEMPLATE="#Request.LOGPATH#\CustomTags\MTRINTMultiLog.cfm" Mode=2 DomainID=312 IOBJID=#q_clm.Result# KEY="RESP_STATUS" VALUE="#STATUS#">

	<CFIF RESP.SUCCESS>
		<cfmodule TEMPLATE="#Request.LOGPATH#\CustomTags\MTRINTMultiLog.cfm" Mode=2 DomainID=312 IOBJID=#q_clm.Result# KEY="CLM_DETAILS" VALUE=#ResponseStruct.SOAPResponseJSON#>
	<CFELSE>
		<cfmodule TEMPLATE="#Request.LOGPATH#\CustomTags\MTRINTMultiLog.cfm" Mode=2 DomainID=312 IOBJID=#q_clm.Result# KEY="ERR_INFO" VALUE=#Request.ErrorDiagnostics#>
	</CFIF>
	
</cffinally>
</CFTRY>

<CFOUTPUT>#SERIALIZEJSON(RESP)#</CFOUTPUT>