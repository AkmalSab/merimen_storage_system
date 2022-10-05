<!--- some padding changes--->
<cfparam name="attributes.gcoid" default="0">
<cfparam name="attributes.domainid" default="0">
<cfparam name="attributes.docdefid" default="0">

<CFIF attributes.domainid eq 7><!--- accident reporting --->
	<CFIF findnocase("<!--AR_WKHTML-->",attributes.content) eq 0>
		<cfsavecontent variable="tmp_style"><cfmodule TEMPLATE="#request.apppath#claims/CustomTags/MTRAR_Style.cfm" DOMAINID=7></cfsavecontent>

		<!--- Style replacement for old AR --->
		<!--- Tbl1 --->
		<cfset attributes.content=ReplaceNoCase(attributes.content,'<table border="0" cellPadding="3" cellSpacing="1" style="WIDTH:100%" align="center">',
																   '<table border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%" align="center" class=tbl1>',"one")>

		<cfset attributes.content=ReplaceNoCase(attributes.content,'<td colspan="1" align="left" style="font-size:70%">',
																   '<td colspan="1" align="left" style="font-size:8px">',"one")>

		<cfset attributes.content=ReplaceNoCase(attributes.content,'<td colspan="2" align="left" style="font-weight:normal;text-decoration:underline;font-size:100%">IMPORTANT NOTICE</td>',
																   '<td colspan="2" align="left" style="font-weight:normal;font-size:100%"><span class="line">IMPORTANT NOTICE</span></td>',"one")>

		<cfset attributes.content=ReplaceNoCase(attributes.content,'<Tr><Td colspan="2" align="center" style="font-size:120%;font-weight:bold;padding:5px">SINGAPORE ACCIDENT STATEMENT</Td></Tr>',
																   '<Tr><Td colspan="2" align="center" style="padding:10px 0px 6px 0px;" class=arheader>SINGAPORE ACCIDENT STATEMENT</Td></Tr>',"one")>

		<cfset attributes.content=ReplaceNoCase(attributes.content,'<td colspan="1" align="right" style="font-size:120%;font-weight:bold">Your NCD will be affected due to late reporting',
																   '<td colspan="1" align="right" class=arheaderLate>Your NCD will be affected due to late reporting',"one")>
		<!--- Tbl2 --->
		<cfset attributes.content=ReplaceNoCase(attributes.content,'<table border="0" cellPadding="2" cellSpacing="0" style="WIDTH:100%;font-size:80%">',
																   '<table border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-size:80%" class=tbl2>',"one")>

		<cfset attributes.content=ReplaceNoCase(attributes.content,' style="font-size:110%;text-decoration:underline"',
																   ' class="important"',"all")>

		<cfset attributes.content=ReplaceNoCase(attributes.content,' style="font-size:110%"',
																   ' class="important-nl"',"all")>

		<cfset attributes.content=ReplaceNoCase(attributes.content,' style="font-size:110%;font-weight:bold;text-decoration:underline"',
																   ' class="vimportant"',"all")>

		<!--- Tbl3 --->
		<cfset attributes.content=ReplaceNoCase(attributes.content,'<table border="0" cellPadding="3" cellSpacing="2" style="WIDTH:100%;font-size:100%" align="center">',
																   '<table border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-size:100%" align="center" class=tbl3>',"one")>
		<cfset attributes.content=replacenocase(trim(attributes.content),"</style>","</style>#tmp_style#","one")>
	</CFIF>
<CFELSEIF attributes.domainid eq 1>

	<cfif isdefined("attributes.GCOID") and attributes.GCOID eq 1510001>
			<cfset attributes.content=ReplaceNoCase(attributes.content,'<table cellPadding=3 cellSpacing=1 style=WIDTH:100%>',
																	   '<table cellPadding="0" cellSpacing="0" style="WIDTH:100%;" class=tbl2>',"one")>
			<cfset attributes.content=AddOnStyle(attributes.content,attributes.domainid)>
			
	<cfelseif attributes.docdefid eq 23 or attributes.docdefid eq 28><!--- Repairer Estimate --->
		<CFIF findnocase("<!--WKHTML-->",attributes.content) eq 0>
			<cfset attributes.content=ReplaceNoCase(attributes.content,'<col style=width:22ex;font-weight:bold VALIGN=TOP><col VALIGN=TOP><col style=width:22ex;font-weight:bold VALIGN=TOP><col VALIGN=TOP>',
																	   '<col style=width:25%;font-weight:bold VALIGN=TOP nowrap><col VALIGN=TOP style=width:35%><col style=width:20%;font-weight:bold VALIGN=TOP><col VALIGN=TOP style=width:20%>',"one")>
			<cfset attributes.content=ExToEm(attributes.content)>
			<cfset attributes.content=BorderIssueTotalOffer(attributes.content)>
			<cfset attributes.content=BorderIssue(attributes.content)>
			<cfset attributes.content=BorderIssueCoC(attributes.content)>
			<cfset attributes.content=CellNoWrap(attributes.content)>
			<cfset attributes.content=AddOnStyle(attributes.content,attributes.domainid)>
		</CFIF>
		<cfset attributes.content=AddOnStyle(attributes.content,attributes.domainid)>
	<CFELSEIF attributes.docdefid eq 24><!--- Adjuster Estimates --->
		<CFIF findnocase("<!--WKHTML-->",attributes.content) eq 0>
			<cfset attributes.content=ReplaceNoCase(attributes.content,'<col style=width:22ex;font-weight:bold VALIGN=TOP><col VALIGN=TOP><col style=width:22ex;font-weight:bold VALIGN=TOP><col VALIGN=TOP>',
																	   '<col style=width:25%;font-weight:bold VALIGN=TOP nowrap><col VALIGN=TOP style=width:35%><col style=width:20%;font-weight:bold VALIGN=TOP><col VALIGN=TOP style=width:20%>',"one")>
			<cfset attributes.content=ExToEm(attributes.content)>
			<cfset attributes.content=BorderIssueTotalOffer(attributes.content)>
			<cfset attributes.content=BorderIssue(attributes.content)>
			<cfset attributes.content=BorderIssueCoC(attributes.content)>
			<cfset attributes.content=CellNoWrap(attributes.content)>
		</CFIF>
		<cfset attributes.content=AddOnStyle(attributes.content,attributes.domainid)>
	<CFELSEIF attributes.docdefid eq 711><!--- NM Wica Worksheet--->
		<CFIF findnocase("<!--WKHTML-->",attributes.content) eq 0>
			<cfset attributes.content=ExToEm(attributes.content)>
			<cfset attributes.content=BorderIssueTotalOffer(attributes.content)>
			<cfset attributes.content=BorderIssue(attributes.content)>
		</CFIF>
		<cfset attributes.content=AddOnStyle(attributes.content,attributes.domainid)>
	<CFELSEIF attributes.docdefid eq 27><!--- Insurer Report--->
		<CFIF findnocase("<!--WKHTML-->",attributes.content) eq 0>					
			<cfset attributes.content=ExToEm(attributes.content)>
			<cfset attributes.content=BorderIssueTotalOffer(attributes.content)>
			<cfset attributes.content=BorderIssue(attributes.content)>
			<cfset attributes.content=BorderIssueCoC(attributes.content)>
			<cfset attributes.content=CellNoWrap(attributes.content)>
		</CFIF>
		<cfset attributes.content=AddOnStyle(attributes.content,attributes.domainid)>
	</CFIF>
<CFELSEIF attributes.domainid eq 30>
	<CFIF attributes.docdefid eq 3000><!--- Invoice --->
		<CFIF findnocase("<!--WKHTML-->",attributes.content) eq 0>
			<cfset attributes.content=ReplaceNoCase(attributes.content,'<table cellpadding=3 cellspacing=0 border=0 bordercolor="black" align="center" style="WIDTH:100%;font-size:100%;border-collapse:collapse;border:1px solid black">','<table cellpadding=3 cellspacing=0 border=0 align="center" style="WIDTH:100%;font-size:100%;border:1px solid black;">',"one")>
			<!--- removal of clsNoBox from the invoice --->
			<cfset attributes.content=ReReplaceNoCase(attributes.content,'<tr><td([^>]*)class=clsNoBox([^>]*)></td></tr>','<tr><td\1\2></td></tr>','all')>
			<!--- odd height --->
			<cfset attributes.content=ReplaceNoCase(attributes.content,'<tr height=60><td align=center>','<tr><td align=center style="height:30px">','one')>
		</CFIF>
	</CFIF>
</CFIF>
<CFSET Caller["#attributes.varmodresult#"]=trim(attributes.content)>

<cffunction name="ExToEm" output="false">
	<cfargument name="content" type="string">
		<cfset var posnew = 1>
		<cfset var pos1 = 1>
		<cfset var oristr = "">
		<cfset var ex = "">
		<cfset var newterm = "">
		<cfset var newwidth = "">
		<cfset var newcontent = arguments.content>

		<cfset pos1 = refindnocase("<col[^>]*width:(\d{1,3}ex)[^>]*>",arguments.content,posnew,true)>
		<cfloop condition="pos1.pos[1] gt 0">
			<cfset oristr = mid(arguments.content,pos1.pos[1],pos1.len[1])>
			<cfset ex = mid(arguments.content,pos1.pos[2],pos1.len[2])>

				<cfset newterm = "#replacenocase(ex,"ex","","one")/2#em">

			<cfset newwidth = replacenocase(oristr, ex, newterm,"one")>
			<cfset posnew = pos1.pos[1] + len(newterm)-1>
			<cfset local.newcontent = replacenocase(local.newcontent, oristr, newwidth,"all")>
			<cfset pos1 = refindnocase("<col[^>]*width:(\d{1,3}ex)[^>]*>",attributes.content,posnew,true)>
		</cfloop>
	<cfreturn local.newcontent>
</cffunction>

<cffunction name="AddOnStyle">
	<cfargument name="content" type="string">
	<cfargument name="domainid" type="numeric" default=0>
	<cfset var tmp_style = "">
	<cfsavecontent variable="tmp_style"><cfmodule TEMPLATE="#request.apppath#claims/CustomTags/MTRAR_Style.cfm" DOMAINID=#domainid# GCOID="#attributes.gcoid#"></cfsavecontent>
	<cfset arguments.content=replacenocase(trim(arguments.content),"</style>","</style>#tmp_style#","one")>
	<cfreturn arguments.content>
</cffunction>

<cffunction name="BorderIssue" output="false">
	<cfargument name="content" type="string">
	<cfreturn ReReplaceNoCase(arguments.content,'=([ ''""]*)clsClmBorder','=\1clsNewBorder',"all")>
</cffunction>

<cffunction name="BorderIssueCoC" output="false" hint="Fix borked table in Cost of Claims">
	<cfargument name="content" type="string">
	<!--- 3 columns but colspan=4, resulting in right border of "Cost of Claims" header not showing! --->
	<!--- don't show border on total offer because it is currently borked--->
	<cfset arguments.content = replacenocase(arguments.content,'><td colspan=2>&nbsp;</td><td style="border-bottom:1px solid black" colspan=2>&nbsp;</td></tr>','><td colspan=2>&nbsp;</td><td style="border-bottom:1px solid black">&nbsp;</td></tr>','all')>
	<cfset arguments.content = replacenocase(arguments.content,'><td colspan=2>&nbsp;</td><td style="border-top:1px solid black" colspan=2>&nbsp;</td></tr>','><td colspan=2>&nbsp;</td><td style="border-top:1px solid black">&nbsp;</td></tr>','all')>
	<cfreturn arguments.content>
</cffunction>

<cffunction name="BorderIssueTotalOffer" output="false" hint="Total Offer has broken borders due to wrong colspan being set. For now, just hide it.">
	<cfargument name="content" type="string">
	<cfset arguments.content = replacenocase(arguments.content,'<table id=''offerinfo'' class="clsClmBorder clsClmEstTone1" width=100% cellspacing=0 cellpadding=1>','<table id=''offerinfo'' class="clsClmEstTone1" width=100% cellspacing=0 cellpadding=1>','one')>
	<cfreturn arguments.content>
</cffunction>

<cffunction name="CellNoWrap" output="false" hint="add no wrap to cells">
	<cfargument name="content" type="string">
	<cfset arguments.content = rereplacenocase(arguments.content,'<td>([^<]*)New \((TTS|Opn)\)([^<]*)</td>','<td nowrap>\1New (\2)\3</td>','one')>
	<cfreturn arguments.content>
</cffunction>

