<cfparam NAME=Attributes.fuseaction DEFAULT="">
<cfswitch expression="#attributes.fuseaction#">
	<cfcase VALUE="dsp_viewreport">
		<cfinvoke component="report.index" method="dsp_viewreport" ArgumentCollection=#Attributes#>
	</cfcase>
</cfswitch>