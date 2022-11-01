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
    <cffunction name="dsp_modgroupperm" hint="Modify Group Permission interface (popup)" returntype="any" output="true">
        <cfargument name="idomainid" required="false" default="" type="string"
            displayname="The DomainID of the object"
            hint="The DomainID of the object. Each object is identified by a (DomainID,ObjID) pair.">
        <cfargument name="iobjid" required="false" default="" type="string"
            displayname="The ObjID of the object"
            hint="The ObjID of the object. Each object is identified by a (DomainID,ObjID) pair.">
        <cfargument name="igrpid" required="false" default="" type="string"
            displayname="Group ID"
            hint="Group ID must be passed in to display the list of permissions for the group (iGrpID in FSEC4001).">
        <cfargument name="grpname" required="false" type="string"
            displayname="Group Name"
            hint="Name of the group.">
        <CFMODULE template="dsp_modgroupperm.cfm" AttributeCollection=#Arguments#>
        <CFRETURN>
    </cffunction>
    <cffunction name="act_modgroupperm" hint="Modify the Permission for a group" returntype="any" output="true">
        <cfargument name="igrpid" required="false" default="" type="string"
            displayname="Group ID"
            hint="Modify the permissions for this User Group ID">
        <cfargument name="idomainid" required="false" default="" type="string"
            displayname="The DomainID of the object"
            hint="The DomainID of the object. Each object is identified by a (DomainID,ObjID) pair.">
        <cfargument name="iobjid" required="false" default="" type="string"
            displayname="The ObjID of the object"
            hint="The ObjID of the object. Each object is identified by a (DomainID,ObjID) pair.">
        <cfargument name="usid" required="false" type="string"
            displayname="The iUSID "
            hint="User making the changes.">
        <CFMODULE template="act_modgroupperm.cfm" AttributeCollection=#Arguments#>
        <CFRETURN>
    </cffunction>
    <cffunction name="act_delgroup" hint="Deletes a user group." returntype="any" output="false">
        <cfargument name="iDomainID" required="false" default="" type="string"
            displayname="The DomainID of the object"
            hint="The DomainID of the object. Each object is identified by a (DomainID,ObjID) pair.">
        <cfargument name="iobjid" required="false" default="" type="string"
            displayname="The ObjID of the object"
            hint="The ObjID of the object. Each object is identified by a (DomainID,ObjID) pair.">
        <cfargument name="igrpid" required="false" default="" type="string"
            displayname="Group ID"
            hint="Group ID to delete.">
        <cfargument name="urlback" required="false" default="" type="string"
            displayname="Back button URL."
            hint="URL for the back button in dsp_grouplist to go back to">
        <CFMODULE template="act_delgroup.cfm" AttributeCollection=#Arguments#>
        <CFRETURN>
    </cffunction>
</cfcomponent>
