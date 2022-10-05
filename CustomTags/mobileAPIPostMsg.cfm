<cfparam name="message" default="">
<cfparam name="redirect" default="">

<!--- Control the message that post from web apps --->
<cfswitch expression="message">
	<cfcase value="address">
		<cfset message = 'JSON.stringify(window.location)'>
	</cfcase>
	<cfcase value="Finalize">
		<cfset message = 'Report Finalize'>
	</cfcase>
	<cfdefaultcase>
		<cfset message = 'PostMessage'>
	</cfdefaultcase>
</cfswitch>

<cfoutput>
<script type="text/javascript">
	console.log('Post Message');
	(window["ReactNativeWebView"]||window).postMessage('#message#');
	window.location.href='#urlredirect#'
</script>
</cfoutput>
