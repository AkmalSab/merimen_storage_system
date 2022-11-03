<cfparam NAME=Attributes.fuseaction DEFAULT="">
<cfswitch expression="#attributes.fuseaction#">
	<cfcase VALUE="dsp_labelmanadd">
		<cfinvoke component="tag.index" method="dsp_labelmanadd" ArgumentCollection=#Attributes#>
	</cfcase>
    <cfcase VALUE="dsp_labelmanedit">
		<cfinvoke component="tag.index" method="dsp_labelmanedit" ArgumentCollection=#Attributes#>
	</cfcase>
	<cfcase VALUE="act_labelmanadd">
		<cfinvoke component="tag.index" method="act_labelmanadd" ArgumentCollection=#Attributes#>
	</cfcase>
	<cfcase value="xml_SVCGetLabeldef">
		<cfinvoke component="tag.index" method="xml_SVCGetLabeldef" ArgumentCollection=#Attributes#>
	</cfcase>
</cfswitch>