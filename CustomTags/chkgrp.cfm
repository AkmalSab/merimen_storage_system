<!--- 
Custom Tag <CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCchkgrp.cfm">
Attributes
----------
Author 	: Andrew Ooi
Date	: 16 May 2000
Revision: 1

Example 
-------

Purpose
-------
This custom tag retrieve the running integer for a particular variable
--->
<CFIF Not IsDefined("SESSION.VARS.PLIST")>
	<CFTHROW TYPE="EX_SECFAILED" ErrorCode="NOLOGIN">
</cfif>
<CFPARAM name="Attributes.GrpList" default="">
<CFPARAM name="Attributes.ChkRead" default="">
<CFPARAM name="Attributes.ChkWrite" default="">
<CFSET len = ArrayLen(SESSION.VARS.PLIST)>
<CFIF Not IsDefined("Attributes.NORESET")>
	<CFSET Caller.CanRead = 0>
	<CFSET Caller.CanWrite = 0>
</cfif>
<CFIF len GT 0>
	<CFLOOP index="cnt" from=1 to=#len#>
		<CFIF Find(",#SESSION.VARS.PLIST[cnt]#W,",",#Attributes.GrpList#,") GT 0>
			<CFSET CALLER.CanWrite=1>
			<CFSET CALLER.CanRead=1>
			<CFBREAK>
		</cfif>
		<CFIF Find(",#SESSION.VARS.PLIST[cnt]#R,",",#Attributes.GrpList#,") GT 0>
			<CFSET CALLER.CanRead=1>
		</cfif>
	</cfloop>
</cfif>
<CFIF Attributes.ChkRead IS 1 AND CALLER.CANREAD IS 0>
	<CFTHROW TYPE="EX_SECFAILED" ErrorCode="CANNOTREAD">
</cfif>
<CFIF Attributes.ChkWrite IS 1 AND CALLER.CANWRITE IS 0>
	<CFTHROW TYPE="EX_SECFAILED" ErrorCode="CANNOTWRITE">
</cfif>