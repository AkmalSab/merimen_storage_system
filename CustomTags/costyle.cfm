<cfparam name="attributes.COID" default="0">

<cfquery name="qry_costyle" datasource="#request.mtrdsn#">
    select 
        igcoid 
    from sec0005 
    where icoid = <cfqueryparam value="#attributes.coid#" CFSQLType="cf_sql_integer">
</cfquery>

<cfset gcoid = qry_costyle.igcoid>

<cfoutput>
<style>
<cfif gcoid eq 50 OR gcoid eq 700513>
    body, table td {
        <cfif (listfindnocase("TRAIN,PROD", application.db_mode) gt 0 and DateDiff("d",DateFormat(Now(), "yyyy-mm-dd"), "2016-06-01") LTE 0)
                or listfindnocase("TRAIN,PROD", application.db_mode) eq 0>
        font-family:Georgia;
        <cfelse>
        font-family:Arial;
        </cfif>
    }
</cfif>
</style>
</cfoutput>
