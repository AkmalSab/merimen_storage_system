<CFIF IsDefined("Attributes.New")>
	<CFMODULE TEMPLATE="#Request.LOGPATH#CustomTags\FORMATURL.cfm">
	<CFIF (Not IsDefined("Caller.URLBack")) OR Caller.URLBack IS NOT Result>
		<CFSET Caller.NewURLBack = "URLBack=" & Result>
	<CFELSE>
		<CFSET Caller.NewURLBack = "">
	</CFIF>
<CFELSE>
	<CFIF IsDefined("Caller.URLBack") AND Len(Caller.URLBack) GT 0>
		<CFSET Caller.NewURLBack = "URLBack=" & URLEncodedFormat(Caller.URLBack)>
	<CFELSE>
		<CFSET Caller.NewURLBack = "">
	</cfif>
</cfif>
