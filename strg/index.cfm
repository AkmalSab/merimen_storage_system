<cfparam NAME=Attributes.fuseaction DEFAULT="">
<cfswitch expression="#attributes.fuseaction#">
	<cfcase VALUE="dsp_testupload">
		<cfinvoke component="strg.index" method="dsp_testupload" ArgumentCollection=#Attributes#>
	</cfcase>
    <cfcase VALUE="dsp_createitem">
		<cfinvoke component="strg.index" method="dsp_createitem" ArgumentCollection=#Attributes#>
	</cfcase>
	<cfcase VALUE="act_updatestatus">
		<cfinvoke component="strg.index" method="act_updatestatus" ArgumentCollection=#Attributes#>
	</cfcase>
</cfswitch>