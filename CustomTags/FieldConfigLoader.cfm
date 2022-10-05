<cfparam NAME=Attributes.CONFIGFIELD default="0"><!--- 0: real usage in the page. 1:registering all fields. 2:configuring --->
<cfparam NAME=Attributes.COROLE default="#session.vars.orgType#">
<!--- <cfparam NAME=Attributes.iINSGCOID default=""> --->
<cfparam NAME=Attributes.SCREENCODE default="CREATE_NEW">
<cfparam NAME=Attributes.siCSTAT default="0">
<cfparam NAME=Attributes.CASEID default="0">
<cfparam NAME=Attributes.EXTID default=0 type=numeric>

<cfif (structKeyExists(session,"vars") and structKeyExists(session.vars,"fieldconfig"))>
    <cfset Attributes.CONFIGFIELD=2>
</cfif>

<CFSET fieldconfig_stat = 0>
<cfif attributes.caseid gt 0>
    <cfquery name="q_getcase" datasource="#REQUEST.MTRDSN#">
        select top 1 a.iCLMTYPEMASK,repstat=a.sicstat,insstat=b.sicstat,adjstat=c.sicstat,b.iINSGCOID
            FROM TRX0001 a with (nolock) INNER JOIN TRX0008 b WITH (NOLOCK) on a.icaseid = b.icaseid and b.siTPINS=0
            LEFT JOIN TRX0002 c WITH (NOLOCK) ON c.iCASEID=b.iCASEID AND c.iADJCASEID=<cfif Attributes.COROLE IS "A" AND Attributes.EXTID GT 0><cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.EXTID#"><cfelse>b.iMAIN_ADJCASEID</cfif>
            <!--- LEFT JOIN TRX0008 tp WITH (NOLOCK) ON tp.iCASEID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.CASEID#"> AND tp.siTPINS=1 --->
            where a.icaseid = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.caseid#">
    </cfquery>
    <cfset iINSGCOID = q_getcase.iINSGCOID>
    <cfif Attributes.COROLE eq "I">
        <cfset fieldconfig_stat = q_getcase.insstat>
    <cfelseif Attributes.COROLE eq "A">
        <cfset fieldconfig_stat = q_getcase.adjstat>
    <cfelseif Attributes.COROLE eq "R">
        <cfset fieldconfig_stat = q_getcase.repstat>
    </cfif>
<cfelse>
    <cfif Attributes.COROLE eq "I">
        <cfset iINSGCOID = request.ds.co[session.vars.orgid].gcoid>
    <cfelse>
        <cfset iINSGCOID = 0>
    </cfif>
</cfif>

<CFQUERY name="q_configfield" DATASOURCE="#request.MTRDSN#">
select iINSGCOID, iCLMTYPE, vaCOROLE, vaELEMENTNAME=isNULL(NULLIF(vaELEMENTNAME,''),vaELEMENTID), vaELEMENTTYPE, iREQ, siCSTAT from SCREEN_CONFIG_FIELD with (nolock)
    where vaSCREENCODE=<cfqueryparam cfsqltype="CF_SQL_NVARCHAR" value="#Attributes.SCREENCODE#">
    and vaCOROLE=<cfqueryparam cfsqltype="CF_SQL_NVARCHAR" value="#Attributes.COROLE#">
    <cfif Attributes.COROLE eq "I">
        and iINSGCOID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#request.ds.co[iINSGCOID].gcoid#">
    </cfif>
    <CFIF Attributes.SCREENCODE neq "CREATE_NEW"><!--- and Attributes.SCREENCODE neq "CHANGE_REG"--->
        and sicstat = <cfqueryparam cfsqltype="cf_sql_integer" value="#fieldconfig_stat#">
    <cfelse>
        and sicstat is null
    </CFIF>
</CFQUERY>

<cfif q_configfield.recordCount eq 0>
    <cfexit>
<cfelse>
    <cfif Attributes.CONFIGFIELD gt 0>
        <!--- <script>AddOnloadCode("$('#config_reset').show();");</script> --->
    </cfif>
</cfif>

<cfset FIELD_CONFIG = structNew()>
<cfoutput query="q_configfield">
    <cfset CONF_CT = REQUEST.DS.CLMTYPE[iCLMTYPE]>
    <cfif not structKeyExists(FIELD_CONFIG, iINSGCOID)>
        <cfset FIELD_CONFIG[iINSGCOID] = structNew()>
    </cfif>
    <cfif not structKeyExists(FIELD_CONFIG[iINSGCOID], CONF_CT)>
        <cfset FIELD_CONFIG[iINSGCOID][CONF_CT] = structNew()>
        <cfset FIELD_CONFIG[iINSGCOID][CONF_CT].REQ = "">
        <cfset FIELD_CONFIG[iINSGCOID][CONF_CT].OPT = "">
    </cfif>
    <cfif iREQ eq 1>
        <cfset FIELD_CONFIG[iINSGCOID][CONF_CT].REQ = listAppend(FIELD_CONFIG[iINSGCOID][CONF_CT].REQ,vaELEMENTNAME)>
    <cfelse>
        <cfset FIELD_CONFIG[iINSGCOID][CONF_CT].OPT = listAppend(FIELD_CONFIG[iINSGCOID][CONF_CT].OPT,vaELEMENTNAME)>
    </cfif>
</cfoutput>
<!---cfdump var="#FIELD_CONFIG#"--->

<script>
var FIELD_CONFIG_JS = <cfoutput>#REQUEST.DS.FN.SVCSerializeJSON(FIELD_CONFIG)#</cfoutput>;
var _old_FIELD_CONFIG_CT = "";

function FieldConfigChk(conf_iINSGCOID,conf_ct)
{
    var reqlist;
    if(FIELD_CONFIG_JS[conf_iINSGCOID][conf_ct] && FIELD_CONFIG_JS[conf_iINSGCOID][conf_ct].REQ)
        reqlist=FIELD_CONFIG_JS[conf_iINSGCOID][conf_ct].REQ.split(",");

    var optlist;
    if(FIELD_CONFIG_JS[conf_iINSGCOID][conf_ct] && FIELD_CONFIG_JS[conf_iINSGCOID][conf_ct].OPT)
        optlist=FIELD_CONFIG_JS[conf_iINSGCOID][conf_ct].OPT.split(",");

    for(var x in reqlist)
    {
        var chkobj=$('#ScraperChecked_name_' + reqlist[x]);
        if(!chkobj.attr("checked"))
            $('#ScraperChecked_name_'+reqlist[x]).trigger("click");
    }
    for(var x in optlist)
    {
        var chkobj=$('#ScraperChecked_name_' + optlist[x]);
        if(chkobj.attr("checked"))
            $('#ScraperChecked_name_'+optlist[x]).trigger("click");
    }

    _old_FIELD_CONFIG_CT = conf_ct;
}
</script>

<cfswitch expression="#Attributes.SCREENCODE#">
    <cfcase value="CREATE_NEW,CHANGE_REG">
        <!--- do nothing. handled by : mclm.js //clmchange() calling JSVCFieldConfig and JSVCFieldReset --->
    </cfcase>
    <cfdefaultcase>
      <cfoutput>
        <script>
            AddOnloadCode("JSVCFieldConfig(#iINSGCOID#,'#CONF_CT#');");
        </script>
      </cfoutput>
    </cfdefaultcase>
</cfswitch>
