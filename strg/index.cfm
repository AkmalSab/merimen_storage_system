<cfparam NAME=Attributes.fuseaction DEFAULT="">
<cfswitch expression="#attributes.fuseaction#">
	<cfcase VALUE="dsp_edititem">
		<cfinvoke component="strg.index" method="dsp_edititem" ArgumentCollection=#Attributes#>
	</cfcase>
    <cfcase VALUE="dsp_createitem">
		<cfinvoke component="strg.index" method="dsp_createitem" ArgumentCollection=#Attributes#>
	</cfcase>
	<cfcase VALUE="dsp_viewitem">
		<cfinvoke component="strg.index" method="dsp_viewitem" ArgumentCollection=#Attributes#>
	</cfcase>
</cfswitch>