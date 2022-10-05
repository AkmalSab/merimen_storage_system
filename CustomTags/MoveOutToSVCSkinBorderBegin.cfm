<cfparam name="Attributes.TITLE" default="">
<cfparam name="Attributes.SKIN" default=1>
<cfparam name="Attributes.WIDTH" default="100%">
<cfparam name="Attributes.HEIGHT" default="100%">
<cfparam name="Attributes.COLLAPSABLE" default=0>
<cfparam name="Attributes.ALIGN" default="center">
<cfparam name="Attributes.ICON" default="">
<cfparam name="Attributes.BGCOLOR" default="dadada">
<cfset Request.CURSKIN=Attributes.SKIN>
<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCADDFILE.cfm" FNAME="SVCTAB">
<cfoutput><script>SkinBorderBegin(#Request.SKIN#,#Attributes.TITLE#,
#Attributes.WIDTH#,#Attributes.HEIGHT#,#Attributes.COLLAPSABLE#,#Attributes.ALIGN#,
#Attributes.ICON#,#Attributes.BGCOLOR#)</script></cfoutput>
