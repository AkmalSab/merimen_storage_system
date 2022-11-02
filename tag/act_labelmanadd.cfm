<cfmodule template="#request.apppath#services/CustomTags\SVCDisableDirect.cfm" Path="#GetCurrentTemplatePath()#"> 
<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkguid.cfm" REQUIRED>
<cfparam name="attributes.labelid" default="0">
<cfparam name="attributes.labelcoid" default="-1">
<cfparam name="attributes.labelstat" default="">
<cfparam name="attributes.labelcostat" default="">

<cfset allowCreateLabel = false>
<cfif application.db_mode eq 'DEV' or (isdefined("form.owner") and form.owner eq 700469)>
	<cfset allowCreateLabel = true>
</cfif>

<cfset database = request.svcdsn>

<cftransaction action=begin>

<cfquery name="qry_labelidcheck" datasource="#database#">
    select 1 from FOBJB3020 where iLBLDEFID = <cfqueryparam value="#form.LABELID#" CFSQLType = "cf_sql_integer" null="no">
</cfquery>

<cftry>
    <!--- update label definition --->
    <cfif qry_labelidcheck.recordcount gt 0> 
        <cfquery name="qry_labeldef2" datasource="#database#" result="rslt_labeldef2">
            update FOBJB3020 set  
            SIPRIVATE    =<cfqueryparam value="#StructKeyExists(form,'ISPRIVATE')?1:0#" CFSQLType = "cf_sql_smallint" null="no"> 

        <cfif allowCreateLabel>
            ,IDOMAINID   =<cfqueryparam value="#form.thedom#" CFSQLType = "cf_sql_integer" null="no">                        
            ,ILOCID      =<cfqueryparam value="#form.theloc#" CFSQLType = "cf_sql_integer" null="no">                         
        </cfif>

            ,BCOCREATE   =<cfqueryparam value="#form.CREATORVAL#" CFSQLType = "cf_sql_integer" null="no">                        
            ,BCOREAD     =<cfqueryparam value="#form.READERVAL#" CFSQLType = "cf_sql_integer" null="no">                         
            ,ICOLORTXT   =<cfqueryparam value="#form.TXCOL#" CFSQLType = "cf_sql_varchar" null="no" maxlength=6>            
            ,ICOLORBGRND =<cfqueryparam value="#form.BGCOL#" CFSQLType = "cf_sql_varchar" null="no" maxlength=6>            
            ,VALBLNAME   =<cfqueryparam value="#form.LABELNAME#" CFSQLType = "cf_sql_varchar" null="no" maxlength=200>           
            ,VALBLDESC   =<cfqueryparam value="#form.LABELDESC#" CFSQLType = "cf_sql_varchar" null="no">
            ,SISTATUS    =<cfqueryparam value="#StructKeyExists(form,'DEACTIVATELABEL')?1:0#" CFSQLType = "cf_sql_smallint" null="no"> 
			,vaLBLNAME_LOCALLANG   =<cfif form.LOCALENAME is "">NULL<CFELSE><cfqueryparam value="#form.LOCALENAME#" CFSQLType = "cf_sql_varchar" ></CFIF>           
            ,vaLBLDESC_LOCALLANG   =<cfif form.LOCALEDESC is "">NULL<CFELSE><cfqueryparam value="#form.LOCALEDESC#" CFSQLType = "cf_sql_varchar" ></CFIF>
            where     
            ILBLDEFID = <cfqueryparam value="#form.LABELID#" CFSQLType = "cf_sql_integer" null="no">
        </cfquery>
        <cfif rslt_labeldef2.recordcount gt 0>
            <cfset attributes.labelid = form.labelid>
            <cfset attributes.labelstat="U">
        </cfif>

    <!--- create label definition --->
    <cfelse>
        <cfif allowCreateLabel>
            <cfquery name="qry_labeldef1" datasource="#database#" result="rslt_labeldef1">
                insert into FOBJB3020 
                    (ILBLDEFID,IDOMAINID,ILOCID,SIPRIVATE,BCOCREATE,BCOREAD,ICOLORTXT,ICOLORBGRND,VALBLNAME,VALBLDESC,ICRTBY,DTCRTON,SISTATUS,vaLBLNAME_LOCALLANG,vaLBLDESC_LOCALLANG)
                values
                    (<cfqueryparam value="#form.LABELID#" CFSQLType = "cf_sql_integer" null="no">
                    ,<cfqueryparam value="#form.theDOM#" CFSQLType = "cf_sql_integer" null="no">
                    ,<cfqueryparam value="#form.theLOC#" CFSQLType = "cf_sql_integer" null="no">
                    ,<cfqueryparam value="#StructKeyExists(form,'ISPRIVATE')?1:0#" CFSQLType = "cf_sql_smallint" null="no">
                    ,<cfqueryparam value="#form.CREATORVAL#" CFSQLType = "cf_sql_integer" null="no">
                    ,<cfqueryparam value="#form.READERVAL#" CFSQLType = "cf_sql_integer" null="no">
                    ,<cfqueryparam value="#form.TXCOL#" CFSQLType = "cf_sql_varchar" null="no" maxlength=6>
                    ,<cfqueryparam value="#form.BGCOL#" CFSQLType = "cf_sql_varchar" null="no" maxlength=6>
                    ,<cfqueryparam value="#form.LABELNAME#" CFSQLType = "cf_sql_varchar" null="no" maxlength=200>
                    ,<cfqueryparam value="#form.LABELDESC#" CFSQLType = "cf_sql_varchar" null="no">
                    ,<cfqueryparam cfsqltype="cf_sql_integer" value="#session.vars.usid#">
                    ,<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">
                    ,<cfqueryparam value="#StructKeyExists(form,'DEACTIVATELABEL')?1:0#" CFSQLType = "cf_sql_smallint" null="no">
					,<cfif form.LOCALENAME is "">NULL<CFELSE><cfqueryparam value="#form.LOCALENAME#" CFSQLType = "cf_sql_varchar"></CFIF>
					,<cfif form.LOCALEDESC is "">NULL<CFELSE><cfqueryparam value="#form.LOCALEDESC#" CFSQLType = "cf_sql_varchar"></CFIF>
                    )
            </cfquery>
            <cfif rslt_labeldef1.recordcount gt 0>
                <cfset attributes.labelid = form.labelid>
                <cfset attributes.labelcoid = -1>
                <cfset attributes.labelstat="C">
            </cfif>
        </cfif>
    </CFIF>
    <cfcatch type="database">
        <cftransaction action="rollback">
        <CFTHROW TYPE="EX_DBERROR" Message="AN ERROR HAPPENED IN INSERT/ UPDATE LABEL">
    </cfcatch>
</cftry>


<!--- Tie label to company
1. check if label exist
2. check if label already tied, prevent dups
3. if tieco
4. if not exist, tie label to co
5. if already exist, edit record label co 
6. if not tieco
7. if already exist, delete
--->

<cfquery name="qry_labelidcheck2" datasource="#database#">
    select 1 from FOBJB3020 where iLBLDEFID = <cfqueryparam value="#form.LABELID#" CFSQLType = "cf_sql_integer" null="no">
</cfquery>

<cfif qry_labelidcheck2.recordcount eq 0>
    <cfthrow TYPE="EX_SECFAILED" ErrorCode="BADCSTAT" EXTENDEDINFO="INVALID LABELID">
</cfif>

<cfif StructKeyExists(form,'owner')> 
    <cfquery name="qry_labelcocheck" datasource="#database#">
        select igcoid 
        from FOBJB3022 
        where 
            iLBLDEFID = <cfqueryparam value="#form.LABELID#" CFSQLType = "cf_sql_integer" null="no">
            and iGCOID = <cfqueryparam value="#form.OWNER#" CFSQLType = "cf_sql_integer" null="no">
    </cfquery>

    <cftry>
        <cfif StructKeyExists(form,'TIECO')>

            <cfif qry_labelcocheck.recordcount gt 0> 
                <cfquery name="qry_tieco2" datasource="#database#" result="rslt_tieco2">
                    update FOBJB3022 set
                        siSTATUS       = <cfqueryparam value="#StructKeyExists(form,'DEACTIVATE')?1:0#" CFSQLType = "cf_sql_smallint" null="no">
    <!--- 
            <cfif application.db_mode eq 'DEV'>
                ,iLBLDEFID       = <cfqueryparam value="#form.LABELID#" CFSQLType = "cf_sql_integer" null="no">
                ,iGCOID         = <cfqueryparam value="#form.OWNER#" CFSQLType = "cf_sql_integer" null="no">
            </cfif>
    --->
                        ,iGROUPPRIORITY = <cfqueryparam value="#form.GROUPORDER#" CFSQLType = "cf_sql_integer" null="#form.GROUPORDER eq ''#">
                        ,iSELECTOR      = <cfqueryparam value="#form.CLAIMTYPEVAL#" CFSQLType = "cf_sql_integer" null="no">
                        ,vaSELECTOR     = <cfqueryparam value="" CFSQLType = "cf_sql_integer" null="yes">
                    where 
                        iLBLDEFID = <cfqueryparam value="#attributes.labelid#" CFSQLType = "cf_sql_integer" null="no">
                        and iGCOID = <cfqueryparam value="#form.OWNER#" CFSQLType = "cf_sql_integer" null="no">
                </cfquery>
                <cfif rslt_tieco2.recordcount gt 0>
                    <cfset attributes.labelid = form.labelid>
                    <cfset attributes.labelstat="U">
                </cfif>
            <cfelse>
                <cfquery name="qry_tieco1" datasource="#database#" result="rslt_tieco1">
                    insert into FOBJB3022 
                        (iLBLDEFID,iGCOID,iCRTBY,dtCRTON,siSTATUS,iGROUPPRIORITY,iSELECTOR,vaSELECTOR)
                    values
                        ( <cfqueryparam value="#form.LABELID#" CFSQLType = "cf_sql_integer" null="no">
                        ,<cfqueryparam value="#form.OWNER#" CFSQLType = "cf_sql_integer" null="no">
                        ,<cfqueryparam cfsqltype="cf_sql_integer" value="#session.vars.usid#">
                        ,<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">
                        ,<cfqueryparam value="#StructKeyExists(form,'DEACTIVATE')?1:0#" CFSQLType = "cf_sql_smallint" null="no">
                        ,<cfqueryparam value="#form.GROUPORDER#" CFSQLType = "cf_sql_integer" null="#form.GROUPORDER eq ''#">
                        ,<cfqueryparam value="#form.CLAIMTYPEVAL#" CFSQLType = "cf_sql_integer" null="no">
                        ,<cfqueryparam value="" CFSQLType = "cf_sql_integer" null="yes">
                        )
                </cfquery>
                <cfif rslt_tieco1.recordcount gt 0>
                    <cfset attributes.labelid = form.labelid>
                    <cfset attributes.labelcoid=form.owner>
                    <cfset attributes.labelcostat="C">
                </cfif>
            </cfif>

        <!--- remove tie/ deactivate --->
        <cfelse>
            <cfif qry_labelcocheck.recordcount gt 0> 
                <cfquery name="qry_tieco3" datasource="#database#">
                    delete
                    from FOBJB3022 
                    where 
                        iLBLDEFID = <cfqueryparam value="#form.LABELID#" CFSQLType = "cf_sql_integer" null="no">
                        and iGCOID = <cfqueryparam value="#form.OWNER#" CFSQLType = "cf_sql_integer" null="no">
                </cfquery>
                <cfset attributes.labelcoid=''>
                <cfset attributes.labelcostat="D">
            <cfelse>
                <cfset attributes.labelcoid=-1>
            </cfif>
        </cfif>
        <cfcatch type="database">
            <cftransaction action="rollback">
            <CFTHROW TYPE="EX_DBERROR" Message="AN ERROR HAPPENED UPDATING LABEL-CO LINK">
        </cfcatch>
    </cftry>
</cfif>

<cftransaction action="commit">
</cftransaction>

<CFLOCATION url="#request.webroot#index.cfm?fusebox=MTRadmin&fuseaction=dsp_labelmanadd&labelstat=#attributes.labelstat#&labelcostat=#attributes.labelcostat#&labelcoid=#attributes.labelcoid#&coid=#attributes.coid#&labelid=#attributes.labelid#&#Request.MToken#" ADDTOKEN="no">

