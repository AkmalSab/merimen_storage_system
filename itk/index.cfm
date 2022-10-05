<cfparam NAME=Attributes.fuseaction DEFAULT="">
<cfswitch expression="#attributes.fuseaction#">
    <cfcase value=act_login>
        <cfinvoke component="itk.index" method="act_login" ArgumentCollection=#Attributes#>
    </cfcase>
</cfswitch>
