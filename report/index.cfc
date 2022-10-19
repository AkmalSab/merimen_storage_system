<cfcomponent displayname="mmr_strg_sys" hint="Report's function">
    <cffunction name="dsp_viewreport" hint="Display the main login page.">
        <cfinclude  template="dsp_viewreport.cfm">
        <cfreturn>
    </cffunction>
    <cffunction name="act_searchreport" hint="Display the main login page.">
        <cfinclude  template="act_searchreport.cfm">
        <cfreturn>
    </cffunction>
</cfcomponent>
