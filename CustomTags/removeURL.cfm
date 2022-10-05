<CFPARAM NAME="Attributes.URL" default="#CGI.SCRIPT_NAME#?#CGI.QUERY_STRING#">
<cfset caller.result=rereplacenocase(attributes.url,"[/&]*(#Attributes.ITEM#)[/=][^/&]*","","all")>

