<cfcomponent displayname="mmr_strg_sys" hint="">
    <cffunction name="dsp_createitem" hint="Homepage for this module" returntype="any" output="true">
        <cfmodule template="dsp_createitem.cfm" AttributeCollection=#Arguments#>
        <cfreturn>
    </cffunction>
    <cffunction name="dsp_testupload" hint="Homepage for this module" returntype="any" output="true">
        <cfmodule template="dsp_testupload.cfm" AttributeCollection=#Arguments#>
        <cfreturn>
    </cffunction>
</cfcomponent>
