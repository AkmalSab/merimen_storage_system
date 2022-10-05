<!---
FILENAME : act_logout.cfm
DESCRIPTION :
   

   
INPUT/ATTR:

INPUT/FORM:

OUTPUT :

CREATED BY :
CREATED ON :

REVISION HISTORY

BY          ON          REMARKS
=========   ==========  ======================================================================================
--->
<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCDISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">
<!---OUTPUT:TRUE--->
<CFPARAM name="attributes.LF" default="">

<CFIF Right(Application.ApplicationName,6) IS "_train">
	<CFMODULE TEMPLATE="#request.apppath#services/index.cfm" FUSEBOX=SVCsec FUSEACTION=act_logout TRAIN=1 LF=#attributes.LF#>
<CFELSE>
	<CFMODULE TEMPLATE="#request.apppath#services/index.cfm" FUSEBOX=SVCsec FUSEACTION=act_logout LF=#attributes.LF#>
</cfif>

