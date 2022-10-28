<cfcomponent displayname="motor" hint="">
    <cffunction name="act_login" hint="Validate Login">
        <cfargument name="RETRYID" required="false" default=0 type="numeric" displayname="The number of retries" hint="">
        <cfargument name="USERID" required="false" default="" type="string" displayname="The UserID last attempted to login" hint="">
        <cfinclude  template="act_login.cfm">
    </cffunction>
    <cffunction name="act_logout" hint="Logout link" returntype="any" output="true">
        <CFMODULE template="act_logout.cfm" AttributeCollection=#Arguments#>
        <CFRETURN>
    </cffunction>
    <cffunction name="dsp_grouplist" hint="Group list page" returntype="any" output="true">
        <CFMODULE template="dsp_grouplist.cfm" AttributeCollection=#Arguments#>
        <CFRETURN>
    </cffunction>
    <cffunction name="xml_SVCGetAllUser" hint="Group list page" returntype="any" output="true">
        <CFMODULE template="xml_SVCGetAllUser.cfm" AttributeCollection=#Arguments#>
        <CFRETURN>
    </cffunction>
    <cffunction name="act_creategroup" hint="Group list page" returntype="any" output="true">
        <CFMODULE template="act_creategroup.cfm" AttributeCollection=#Arguments#>
        <CFRETURN>
    </cffunction>
    <cffunction name="qry_sspFSECCreateUserGroup" hint="Group list page" returntype="any" output="true">
        <CFMODULE template="qry_sspFSECCreateUserGroup.cfm" AttributeCollection=#Arguments#>
        <CFRETURN>
    </cffunction>
</cfcomponent>
