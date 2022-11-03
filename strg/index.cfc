<cfcomponent displayname="mmr_strg_sys" hint="">
    <cffunction name="dsp_createitem" hint="Homepage for this module" returntype="any" output="true">
        <cfargument name="DOMAINID" required="true" type="numeric" default="1" displayname="DOMAIN ID" hint="DOMAIN ID">
        <cfargument name="OBJID" required="true" type="numeric" default="1" displayname="OBJECT ID" hint="OBJECT ID">
        <cfargument name="LOCID" required="true" default="#SESSION.VARS.LOCID#" type="string" displayname="Locale ID" hint="Specifies the locale id. <SYS0009.iLOCID>">
        <cfargument name="USID" required="true" type="numeric" default="#SESSION.VARS.USID#" displayname="User ID" hint="The current User ID. The user that is accessing the function. [SESSION.VARS.USID]">
        <cfargument name="GCOID" required="true" default="#SESSION.VARS.GCOID#" type="numeric" displayname="Group Company ID" hint="To get the single sign on setup details for the company. <FSSO_SETUP.iGCOID>">
        <cfargument name="COROLE" required="false" type="numeric" default="2" displayname="Company Role" hint="Company Role based on Domain ID <FOBJ3003.iCOROLEID>">
        <cfmodule template="dsp_createitem.cfm" AttributeCollection=#Arguments#>
        <cfreturn>
    </cffunction>
    <cffunction name="act_createitem" hint="Homepage for this module" returntype="any" output="true">
        <cfmodule template="act_createitem.cfm" AttributeCollection=#Arguments#>
        <cfreturn>
    </cffunction>
    <cffunction name="act_updatestatus" hint="Homepage for this module" returntype="any" output="true">
        <cfmodule template="act_updatestatus.cfm" AttributeCollection=#Arguments#>
        <cfreturn>
    </cffunction>
    <cffunction name="act_updateitem" hint="Homepage for this module" returntype="any" output="true">
        <cfmodule template="act_updateitem.cfm" AttributeCollection=#Arguments#>
        <cfreturn>
    </cffunction>
    <cffunction name="dsp_viewletter" hint="Homepage for this module" returntype="any" output="true">
        <cfmodule template="dsp_viewletter.cfm" AttributeCollection=#Arguments#>
        <cfreturn>
    </cffunction>
    <cffunction name="dsp_updateitem" hint="Homepage for this module" returntype="any" output="true">
        <cfmodule template="dsp_updateitem.cfm" AttributeCollection=#Arguments#>
        <cfreturn>
    </cffunction>
    <cffunction name="act_deleteitem" hint="Homepage for this module" returntype="any" output="true">
        <cfmodule template="act_deleteitem.cfm" AttributeCollection=#Arguments#>
        <cfreturn>
    </cffunction>
</cfcomponent>
