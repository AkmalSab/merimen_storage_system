<cfcomponent displayname="mmr_strg_sys" hint="">
    <cffunction access="public" name="dsp_labelmanadd" output=true>
        <cfargument name="coid" required="false" default="1" type="string" displayname="coid" hint="coid">
        <cfmodule template="dsp_labelmanadd.cfm" attributecollection=#arguments#>
        <cfreturn>
    </cffunction>
    <cffunction access="public" name="dsp_labelmanedit" output=true>
        <cfmodule template="dsp_labelmanedit.cfm" attributecollection=#arguments#>
        <cfreturn>
    </cffunction>
    <cffunction access="public" name="act_labelmanadd" output=false>
        <cfmodule template="act_labelmanadd.cfm" attributecollection=#arguments#>
        <cfreturn>
    </cffunction>
    <cffunction name="xml_SVCGetLabeldef" hint="" returntype="any" output="true">
        <cfargument name="COID" required="false" default="1137" type="numeric" displayname="COID" hint="">
        <cfargument name="keyword" required="false" default="" type="string" displayname="keyword" hint="">
        <CFMODULE template="xml_SVCGetLabeldef.cfm" AttributeCollection=#Arguments#>
        <CFRETURN>
    </cffunction>
</cfcomponent>
