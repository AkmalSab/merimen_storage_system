<cfparam NAME="attributes.FUSEBOX" DEFAULT="">
<cfparam NAME="attributes.FUSEACTION" DEFAULT="">

<cfswitch EXPRESSION=#attributes.fusebox#>
	<cfcase VALUE="homepage">
		<cfinvoke component="index" method="dsp_login" ArgumentCollection=#Attributes#>
	</cfcase>
	<cfcase VALUE="sec">
		<cfinclude TEMPLATE="sec/index.cfm">
	</cfcase>
	<cfdefaultcase>
		<cfinvoke component="index" method="dsp_login" ArgumentCollection=#Attributes#>
	</cfdefaultcase>
</cfswitch>