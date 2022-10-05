<cfparam NAME=Attributes.fuseaction DEFAULT="">
<cfswitch expression="#attributes.fuseaction#">
    <cfcase value=act_login>
        <cfinvoke component="sec.index" method="act_login" ArgumentCollection=#Attributes#>
    </cfcase>
    <cfcase value=act_logout>
        <cfinvoke component="sec.index" method="act_logout" ArgumentCollection=#Attributes#>
    </cfcase>
</cfswitch>
