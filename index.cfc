<cfcomponent displayname="mmr_strg_sys" hint="">
    <cffunction name="dsp_login" hint="Display the main login page.">
        <cfargument name="RETRYID" required="false" default=0 type="numeric" displayname="The number of retries" hint="">
        <cfargument name="USERID" required="false" default="" type="string" displayname="The UserID last attempted to login" hint="">
        <cfinclude  template="dsp_login.cfm">
        <cfreturn>
    </cffunction>
    <cffunction name="dsp_home" hint="Homepage for this module" returntype="any" output="true">
        <cfargument name="fusebox" required="false" type="string"
            displayname=""
            hint="">
        <cfargument name="Fuseaction" required="false" type="string"
            displayname=""
            hint="">
        <cfargument name="SETLOGIN" required="false" default="" type="string"
            displayname="Bring user back to his last visited module."
            hint="">
        <CFMODULE template="dsp_home.cfm" AttributeCollection=#Arguments#>
        <CFRETURN>
    </cffunction>
    <cffunction name="act_searchitem" hint="Display the main login page.">
        <cfinclude  template="act_searchitem.cfm">
        <cfreturn>
    </cffunction>
</cfcomponent>
