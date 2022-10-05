<cfparam name="attributes.tendergroupid" default=0>
<CFPARAM name="Attributes.ChkCoID" default=0>
<cfset caller.tgcat=""><!--- tender group category... 1: motor , 2: non-motor --->
<cfset caller.insgcoid="">
<cfset caller.orgtype=#session.vars.orgtype#>
<cfif NOT(listfindnocase("D,I",caller.orgtype) GT 0)><cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO"></cfif>

<cfquery datasource=#Request.MTRDSN# name=q_tg>
select tgcat=itgcat, coid=iinscoid from sec0010 with (nolock) where itendergroupid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.tendergroupid#">
</cfquery>
<!--- <cfdump var=#q_tg#> <cfabort> --->
<cfif attributes.tendergroupid GT 0>
	<cfif q_tg.recordcount IS 0><cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCASE"></cfif>
	<cfset caller.insgcoid=#q_tg.coid#>
	<cfset caller.tgcat=#q_tg.tgcat#>
	<cfif caller.orgtype NEQ "D">
		<cfif session.vars.gcoid NEQ caller.insgcoid><cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCO"></cfif>
	</cfif>
</cfif>
<!--- <cfif not isdefined("attributes.coid") and not isdefined("attributes.itendergroupid")>
	<cfthrow TYPE="EX_SECFAILED" ErrorCode="BADPARAM">
</cfif> --->