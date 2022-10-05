<!---
FILENAME : CLAIMS/root/dsp_error.cfm
DESCRIPTION :
Error processing page for CLAIMS.
   
INPUT/ATTR:
ERROR structure from Cold Fusion Server.

OUTPUT : None.

CREATED BY : Andrew
CREATED ON : 26 July 2002

REVISION HISTORY
BY          ON          REMARKS
=========   ==========  ======================================================================================
--->
<cfset HOMEURL="#Request.Webroot#index.cfm?fusebox=MTRroot&fuseaction=dsp_login">	
<CFIF IsDefined("Attributes.TRAIN")>
	<CFSET HOMEURL&="&train=1">
</cfif>
<CFIF IsDefined("Attributes.GCOID") and Attributes.GCOID gt 0>
	<cfset HOMEURL=Request.DS.FN.SVCGetLoginURLCustom(application.appmode,"",HOMEURL,attributes.GCOID)>
</cfif>
<cfif (IsDefined("Attributes.LF") and Attributes.LF neq "")>
	<CFSET HOMEURL&="&lf=#URLEncodedFormat(Request.DS.FN.SVCSanitizeInput(attributes.LF,'JS-NQ'))#">
	<cfset HOMEURL=Request.DS.FN.SVCGetLoginURLCustom(application.appmode,attributes.LF,HOMEURL)>
</cfif>

<CFSET ErrorStruct=StructNew()>
<CFSET StructAppend(ErrorStruct,Error,True)>
<cfmodule TEMPLATE="#request.apppath#services/index.cfm" FUSEBOX=SVCroot FUSEACTION=dsp_errordefine ERRORSTRUCT=#ErrorStruct#>
<cfmodule TEMPLATE="#request.apppath#services/index.cfm" FUSEBOX=SVCroot FUSEACTION=dsp_errorhandler ERRORSTRUCT=#ErrorStruct# ErrorDisplay=1 HomeURL=#HomeURL#>