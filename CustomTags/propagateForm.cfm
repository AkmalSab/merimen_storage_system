<!--- 
Regenerates items in FORM structure into HTML Hidden fields
so as to propagate a form.

Parameters: None
Return Values : None
--->
<CFIF IsDefined("Form")>
	<CFOUTPUT><cfloop collection=#Form# item=abc><CFIF UCase(abc) IS NOT "FIELDNAMES" AND UCase(abc) IS NOT "FORMGUID" AND LEN(abc) GT 0><CFSET sim=StructFind(Form,abc)><CFIF IsSimpleValue(sim)><INPUT TYPE=HIDDEN NAME=#abc# VALUE="#HTMLEditFormat(sim)#"></CFIF></cfif></CFLOOP></CFOUTPUT>
</cfif>