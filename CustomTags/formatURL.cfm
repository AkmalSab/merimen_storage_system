<CFPARAM NAME="Attributes.URL" default="#CGI.SCRIPT_NAME#?#CGI.QUERY_STRING#">
<cfset attributes.url=rereplacenocase(attributes.url,"((cfid)|(cftoken)|(jsessionid)|(userid)|(nolayout)|(rid)|(lastlogon)|(br)|(ct)|(mobile)|(usid)|(locid))[/=][^/&]*[/&]*","","all")>
<cfset attributes.url=rereplacenocase(attributes.url,"[/&][/&]+","","all")>
<CFSET Caller.Result=URLEncodedFormat(Attributes.URL)>