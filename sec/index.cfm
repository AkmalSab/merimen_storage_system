<cfparam NAME=Attributes.fuseaction DEFAULT="">
<cfswitch expression="#attributes.fuseaction#">
    <cfcase value=act_login>
        <cfinvoke component="sec.index" method="act_login" ArgumentCollection=#Attributes#>
    </cfcase>
</cfswitch>
