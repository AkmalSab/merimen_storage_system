<cfparam NAME="attributes.FUSEBOX" DEFAULT="">
<cfparam NAME="attributes.FUSEACTION" DEFAULT="">

<cfswitch EXPRESSION=#attributes.fusebox#>
	<cfcase VALUE="homepage">
		<cfinvoke component="index" method="dsp_login" ArgumentCollection=#Attributes#>
	</cfcase>
	<cfcase VALUE="sec">
		<cfinclude TEMPLATE="sec/index.cfm">
	</cfcase>
	<cfcase VALUE="MTRroot">
		<cfinvoke component="index" method="dsp_home" ArgumentCollection=#Attributes#>
	</cfcase>
	<cfcase VALUE="search">
		<cfinvoke component="index" method="act_searchitem" ArgumentCollection=#Attributes#>
	</cfcase>
	<cfcase VALUE="strg">
		<cfinclude TEMPLATE="strg/index.cfm">
	</cfcase>
	<cfcase VALUE="rpt">
		<cfinclude TEMPLATE="report/index.cfm">
	</cfcase>
	<cfcase VALUE="tag">
		<cfinclude TEMPLATE="tag/index.cfm">
	</cfcase>
	<cfcase VALUE="SVCobj">
        <cfinclude TEMPLATE="/services/obj/index.cfm">
    </cfcase>
	<cfdefaultcase>
		<cfinvoke component="index" method="dsp_login" ArgumentCollection=#Attributes#>
	</cfdefaultcase>
</cfswitch>