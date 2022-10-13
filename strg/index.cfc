<cfcomponent displayname="mmr_strg_sys" hint="">
    <cffunction name="dsp_createitem" hint="Homepage for this module" returntype="any" output="true">
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
</cfcomponent>
