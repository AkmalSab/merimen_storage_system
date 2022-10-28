<cfparam NAME=Attributes.fuseaction DEFAULT="">
<cfswitch expression="#attributes.fuseaction#">
    <cfcase value=act_login>
        <cfinvoke component="sec.index" method="act_login" ArgumentCollection=#Attributes#>
    </cfcase>
    <cfcase value=act_logout>
        <cfinvoke component="sec.index" method="act_logout" ArgumentCollection=#Attributes#>
    </cfcase>
    <cfcase value=dsp_grouplist>
        <cfinvoke component="sec.index" method="dsp_grouplist" ArgumentCollection=#Attributes#>
    </cfcase>
    <cfcase value=xml_SVCGetAllUser>
        <cfinvoke component="sec.index" method="xml_SVCGetAllUser" ArgumentCollection=#Attributes#>
    </cfcase>
    <cfcase value=act_creategroup>
        <cfinvoke component="sec.index" method="act_creategroup" ArgumentCollection=#Attributes#>
    </cfcase>
    <cfcase value=qry_sspFSECCreateUserGroup>
        <cfinvoke component="sec.index" method="qry_sspFSECCreateUserGroup" ArgumentCollection=#Attributes#>
    </cfcase>
    
</cfswitch>
