<cfcomponent displayname="motor" hint="">
    <cffunction name="act_login" hint="Display the main login page.">
        <cfargument name="RETRYID" required="false" default=0 type="numeric" displayname="The number of retries" hint="">
        <cfargument name="USERID" required="false" default="" type="string" displayname="The UserID last attempted to login" hint="">
        <cfinclude  template="act_login.cfm">
    </cffunction>
    <cffunction name="act_logout" hint="Logout link" returntype="any" output="true">
        <CFMODULE template="act_logout.cfm" AttributeCollection=#Arguments#>
        <CFRETURN>
    </cffunction>
</cfcomponent>
