<cfcomponent displayname="mmr_strg_sys" hint="">
    <cffunction name="dsp_viewitem" hint="Display the main login page.">
        <cfinclude  template="dsp_viewitem.cfm">
        <cfreturn>
    </cffunction>
    <cffunction name="dsp_createitem" hint="Homepage for this module" returntype="any" output="true">
        <cfmodule template="dsp_createitem.cfm" AttributeCollection=#Arguments#>
        <cfreturn>
    </cffunction>
    <cffunction name="dsp_edititem" hint="Homepage for this module" returntype="any" output="true">
        <cfmodule template="dsp_edititem.cfm" AttributeCollection=#Arguments#>
        <cfreturn>
    </cffunction>
</cfcomponent>
