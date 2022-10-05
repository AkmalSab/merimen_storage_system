<cfparam name="attributes.CMTNOTID" default=0>
<cfparam name="attributes.DOMAINID" default=9>

<cfif attributes.CMTNOTID GT 0>
	<cfif attributes.DOMAINID EQ 9>
		<cfquery datasource=#Request.MTRDSN# name=q_co>
		SELECT iinscoid,caseuuid=a.vaUUID FROM CMT0001 a with (nolock) 
		WHERE icmtnotid=<cfqueryparam cfsqltype="cf_sql_integer" value=#attributes.CMTNOTID#>
		UNION
		SELECT iinscoid,caseuuid=a.vaUUID FROM CMT0001_pro a with (nolock) 
		WHERE icmtnotid=<cfqueryparam cfsqltype="cf_sql_integer" value=#attributes.CMTNOTID#> AND siprocessstatus=1
		</cfquery>
        <cfset caseuuid=q_co.caseuuid>
	<cfelseif attributes.DOMAINID EQ 1>
		<cfquery datasource=#Request.MTRDSN# name=q_co>
		SELECT iinscoid=iINSGCOID,caseuuid=vaUUID FROM trx0008 with (nolock) 
		WHERE icaseid=<cfqueryparam cfsqltype="cf_sql_integer" value=#attributes.CMTNOTID#>
		</cfquery>
        <CFIF q_co.caseuuid EQ ''>
			<cfset caseuuid=REReplace(CreateUUID(),"-","","ALL")>
			<cfstoredproc PROCEDURE="sspTRXClmAssignUUID" DATASOURCE=#Request.MTRDSN# RETURNCODE=YES>
				<cfif attributes.CMTNOTID GT 0>
        			<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER VALUE=#attributes.CMTNOTID# DBVARNAME=@ai_CASEID>
				<cfelse>
        			<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_INTEGER NULL=YES DBVARNAME=@ai_CASEID>
				</cfif>
				<cfif caseuuid NEQ ''>
					<cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_VARCHAR VALUE="#TRIM(caseuuid)#" DBVARNAME=@as_UUID>
				<cfelse>
				    <cfprocparam TYPE=IN CFSQLTYPE=CF_SQL_VARCHAR NULL=YES DBVARNAME=@as_UUID>
				</cfif>
			</cfstoredproc>
			<cfset returncode=CFSTOREDPROC.STATUSCODE>
			<cfif returncode LT 0>
	    		<cfthrow TYPE="EX_DBERROR" ErrorCode="CLAIMANT/NOTIFY(#returncode#)">
			</cfif>
		<CFELSE>
        	<cfset caseuuid=q_co.caseuuid>
		</CFIF>
	</cfif>
	<cfset LOCID=#request.ds.co[q_co.iinscoid].locid#>
	<cfif NOT(q_co.recordcount IS 1)><CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCASE"></cfif>
	<cfif caseuuid IS ""><CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCASE" EXTENDEDINFO="Unable to access for editing notification"></cfif>
	<CFIF NOT StructKeyExists(SESSION,"VARS")>
		<cflock SCOPE="SESSION" Type="Exclusive" TimeOut=60>
			<cfset SESSION.VARS=StructNew()>
			<CFIF NOT StructKeyExists(SESSION.VARS,"USID")>
				<CFSET StructInsert(SESSION.VARS,"USID",1)>
			</CFIF>
			<CFIF NOT StructKeyExists(SESSION.VARS,"USERID")>
				<CFSET StructInsert(SESSION.VARS,"USERID",1)>
			</CFIF>
			<CFIF NOT StructKeyExists(SESSION.VARS,"LOCID")>
				<CFSET StructInsert(SESSION.VARS,"LOCID",#LOCID#)>
			</CFIF>   
			<CFIF NOT StructKeyExists(SESSION.VARS,"ORGTYPE")>    
				<CFSET StructInsert(SESSION.VARS,"ORGTYPE","")>
			</CFIF>
 			<CFIF NOT StructKeyExists(SESSION.VARS,"ORGNAME")>
				<CFSET StructInsert(SESSION.VARS,"ORGNAME","Anonymous")>
			</CFIF>
<!---
			<CFIF NOT StructKeyExists(SESSION.VARS,"USERNAME")>
				<CFSET StructInsert(SESSION.VARS,"USERNAME","Anonymous")>
			</CFIF>
			<CFIF NOT StructKeyExists(SESSION.VARS,"PLIST")>
				<CFSET StructInsert(SESSION.VARS,"PLIST",ArrayNew(1))>
			</CFIF>
--->
			<CFIF NOT StructKeyExists(SESSION.VARS,"SUBCOTYPEID")>
				<CFSET StructInsert(SESSION.VARS,"SUBCOTYPEID",2)>
			</CFIF>
			<CFIF NOT StructKeyExists(SESSION.VARS,"GCOID")>  
				<CFSET StructInsert(SESSION.VARS,"GCOID",1137)>
			</CFIF> 
			<CFIF NOT StructKeyExists(SESSION.VARS,"ORGID")>  
				<CFSET StructInsert(SESSION.VARS,"ORGID",1137)>
			</CFIF>
			<CFIF NOT StructKeyExists(SESSION.VARS,"CHILDCOACCESS")>  
				<CFSET StructInsert(SESSION.VARS,"CHILDCOACCESS",1)>
			</CFIF>        
			<CFIF NOT StructKeyExists(SESSION.VARS,"CASEUUID")>  
				<CFSET StructInsert(SESSION.VARS,"CASEUUID",#caseuuid#)>
			</CFIF>
			<CFIF NOT StructKeyExists(SESSION.VARS,"LGID")>  
				<CFSET StructInsert(SESSION.VARS,"LGID",0)>
			</CFIF>
			<CFIF NOT StructKeyExists(SESSION.VARS,"CASECMTNOTID")>
				<CFSET StructInsert(SESSION.VARS,"CASECMTNOTID",#attributes.CMTNOTID#)>
			</CFIF>
		</CFLOCK> 
	</CFIF>
</cfif>
