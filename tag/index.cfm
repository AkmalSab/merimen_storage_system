<cfparam NAME=Attributes.fuseaction DEFAULT="">
<cfswitch expression="#attributes.fuseaction#">
	<cfcase VALUE="dsp_labelmanadd">
		<cfinvoke component="tag.index" method="dsp_labelmanadd" ArgumentCollection=#Attributes#>
	</cfcase>
    <cfcase VALUE="dsp_labelmanedit">
		<cfinvoke component="tag.index" method="dsp_labelmanedit" ArgumentCollection=#Attributes#>
	</cfcase>
</cfswitch>z