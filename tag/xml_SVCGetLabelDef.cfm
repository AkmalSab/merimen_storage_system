<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCDISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">
<CFPARAM name="attributes.coid" default="1137">
<CFPARAM name="attributes.keyword" default="">

<cfoutput>
<cfquery name="qry_co" datasource="#request.mtrdsn#" result="rslt_co">
    select 
        igcoid,ilocid 
    from sec0005 
    where icoid = <cfqueryparam value="#attributes.coid#" CFSQLType = "cf_sql_integer" null="no">
</cfquery>

<cfdump  var="#qry_co#">

<cfif rslt_co.recordcount eq 0> 
    <cfexit method="exittemplate">
</cfif>

<cfset gcoids = '0'>
<cfset gcoids = ListAppend(gcoids,qry_co.igcoid)>
<cfset locs = '0'>
<cfset locs = ListAppend(gcoids,qry_co.ilocid)>

<cfquery name="q_tag" datasource=#request.MTRDSN# result="rslt_tag"> 
select 
	def.ILBLDEFID as labelid
	,def.IDOMAINID as domain
	,def.ILOCID as locid
	,def.SIPRIVATE as isprivate
	,isnull(def.BCOCREATE,0) as creator
	,isnull(def.BCOREAD,0) as reader
	,isnull(def.ICOLORTXT,'000000') as txcol
	,isnull(def.ICOLORBGRND,'ffffff') as bgcol
	,def.VALBLNAME as labelname
	,def.VALBLDESC as labeldesc
	,def.SISTATUS as deactivatelabel
	,isnull(labelco.ILBLDEFID,0) as tielabelco
	,isnull(labelco.iGCOID,0) as gcoid
	,isnull(labelco.siSTATUS,0) as deactivatelabelco
	,isnull(labelco.iSELECTOR,-1) as claimtypeval
	,isnull(labelco.vaSELECTOR,'') as selector2
    ,igrouppriority as grouporder
from FOBJB3020 def
left join FOBJB3022 labelco 
	on labelco.iGCOID in (<cfqueryparam value="#gcoids#" CFSQLType = "cf_sql_integer" null="no" list="yes" separator=",">) 
        and labelco.iLBLDEFID = def.iLBLDEFID 
where 
    def.ILOCID in (<cfqueryparam value="#locs#" CFSQLType = "cf_sql_integer" null="no" list="yes" separator=",">)
    and (def.valblname like <cfqueryparam value="#attributes.keyword#%" CFSQLType = "cf_sql_varchar" null="#attributes.keyword eq ''#"> OR <cfqueryparam value="#url.keyword#" CFSQLType = "cf_sql_varchar" null="#attributes.keyword eq ''#"> is null)
</cfquery>
</cfoutput>

<!--- 
		<infolink><![CDATA[#Request.WEBROOT#index.cfm?fusebox=SVCadmin&fuseaction=dsp_viewcom&COID={COID}&#Request.MToken#]]></infolink>
--->

<!--- XML output : create based on sql result --->
<cfcontent reset="yes" type="text/xml; charset=utf-8"><?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Result>
    <cfoutput>
    <summary> 
        <title>Label Results</title>
        <recordcount>#rslt_tag.recordcount#</recordcount>
        <columns>
            labelname ,labeldesc,*theloc ,*thedom ,labelid ,*deactivatelabel ,*txcol ,*bgcol ,*readers ,*creators ,*isprivate ,*tielabelco ,theowner ,*deactivatelabelco ,*claimtypes ,*grouporder ,*selector1,listed
        </columns>
    </summary> 
    </cfoutput> <cfoutput query="q_tag">
    <data>
        <labelname>#xmlformat(LabelName)#</labelname>
        <labeldesc>#xmlformat(LabelDesc neq ''?LabelDesc:'-- No Desc --')#</labeldesc>
        <theloc>#xmlformat(LOCID)#</theloc>
        <thedom>#xmlformat(DOMAIN)#</thedom>
        <labelid>#xmlformat(labelid)#</labelid>
        <deactivatelabel>#xmlformat(deactivatelabel)#</deactivatelabel>
        <txcol>#xmlformat(txcol)#</txcol>
        <bgcol>#xmlformat(bgcol)#</bgcol>
        <readers>#xmlformat(reader)#</readers>
        <creators>#xmlformat(creator)#</creators>
        <isprivate>#xmlformat(isPRIVATE)#</isprivate>
        <tielabelco>#xmlformat(tielabelco)#</tielabelco>
        <theowner>#xmlformat(GCOID)#</theowner>
        <deactivatelabelco>#xmlformat(deactivatelabelco)#</deactivatelabelco>
        <claimtypes>#xmlformat(claimtypeval)#</claimtypes>
        <grouporder>#xmlformat(grouporder)#</grouporder>
        <selector2>#xmlformat(selector2)#</selector2>
        <notlisted>#xmlformat(tielabelco gt 0?'YES':'NO')#</notlisted>
    </data> 
    </cfoutput>
</Result>
