<cfparam name="Attributes.COMMAND">
<cfparam name="Attributes.TABID" default="">
<cfparam name="Attributes.GTABID" default="TABHEADER1">
<cfparam name="Attributes.TITLE" default="">
<cfparam name="Attributes.SKIN" default=1>
<cfparam name="Attributes.WIDTH" default="100%">
<cfparam name="Attributes.SHOWEXPAND" default=1>
<cfif IsDefined("Request.CURTABSKIN")>
	<cfset Attributes.SKIN=Request.CURTABSKIN>
<cfelse>
	<cfset Request.CURTABSKIN=Attributes.SKIN>
</cfif>
<cfoutput>
<cfif Attributes.COMMAND IS "START">
	<script>
	var vTabLastPos=""; // Global variable, connected to meriscpt.js function TabClick()
	function hideAllTabs(x) {
		vTabLastPos="";
		var td=x.childNodes[0].firstChild;
		var id="";
		for(i=0;i<td.childNodes.length;i++) {
			if(!td.childNodes[i].id) continue;
			id=td.childNodes[i].id.substr(3,td.childNodes[i].id.length-3); // TAGxx
			td.childNodes[i].className="clsTab<cfif Attributes.SKIN GT 1>#Attributes.SKIN#</cfif>";
			if(id!="ALL") document.all("TABLE"+id).style.display="none";
			// Skin
			<cfif Attributes.SKIN IS 2>
			document.getElementById("TABIMG1"+id).src="#Request.Webroot#common/tab1i_02.gif";
			document.getElementById("TABIMG2"+id).style.backgroundImage="url(#Request.Webroot#common/tab1i_04.gif)";
			document.getElementById("TABIMG3"+id).src="#Request.Webroot#common/tab1i_06.gif";
			</cfif>
		}
	}
	function TabClick2(id) {
			var tab=document.getElementById("TAG"+id),td="";
			tab.className="clsTab<cfif Attributes.SKIN GT 1>#Attributes.SKIN#</cfif>Selected";
			if(document.getElementById("TABLE"+id)) document.getElementById("TABLE"+id).style.display="block";
			if(id=="ALL") {
				td=document.getElementById("#Attributes.GTABID#").childNodes[0].firstChild;
				for(i=0;i<td.childNodes.length;i++) {
					if(!td.childNodes[i].id) continue;
					id=td.childNodes[i].id.substr(3,td.childNodes[i].id.length-3); // TAGxx
					if(id!="ALL") document.all("TABLE"+id).style.display="block";
				}
			}
			// Skin
			<cfif Attributes.SKIN IS 2>
			document.getElementById("TABIMG1"+id).src="#Request.Webroot#common/tab1_02.gif";
			document.getElementById("TABIMG2"+id).style.backgroundImage="url(#Request.Webroot#common/tab1_04.gif)";
			document.getElementById("TABIMG3"+id).src="#Request.Webroot#common/tab1_06.gif";
			</cfif>
	}
	</script>
	<table width=#Attributes.WIDTH# cellspacing=0 cellpadding=0 id=#Attributes.GTABID# style="display:block; table-layout:fixed"><tr>
	<cfif Attributes.SKIN IS 2>
		<td width=13 nowrap height="30" style="background-image:url(#Request.Webroot#common/tab1_01.gif);background-repeat:repeat-x">
	</cfif>
</cfif>
<cfif Attributes.COMMAND IS "WRITETAB">
	<cfif Attributes.SKIN IS 1>
		<td class=clsTab width=20% id=TAG#Attributes.TABID# onclick=hideAllTabs(#Attributes.GTABID#);TabClick('#Attributes.TABID#')><a href=JavaScript:hideAllTabs(#Attributes.GTABID#,0);TabClick('#Attributes.TABID#')>#Attributes.TITLE#</a></td>
	<cfelseif Attributes.SKIN IS 2>
		<td class=clsTab2 width=20% id=TAG#Attributes.TABID# onclick=hideAllTabs(#Attributes.GTABID#);TabClick2('#Attributes.TABID#')>
			<table cellpadding=0 cellspacing=0 border=0><tr><td width=6 height=30><img src="#Request.Webroot#common/tab1i_02.gif" class=clsNoPrint id=TABIMG1#Attributes.TABID#></td><td width="100%" nowrap height="30" style="background-image:url(#Request.Webroot#common/tab1i_04.gif);background-repeat:repeat-x" align="center" id=TABIMG2#Attributes.TABID#>
			<a href=JavaScript:hideAllTabs(#Attributes.GTABID#);TabClick2('#Attributes.TABID#')>#Attributes.TITLE#</a>
			</td><td width=12 height=30><img src="#Request.Webroot#common/tab1i_06.gif" class=clsNoPrint id=TABIMG3#Attributes.TABID#></td></tr></table>
		</td>
	</cfif>
</cfif>
<cfif Attributes.COMMAND IS "ENDTAB">
	<cfif Attributes.SKIN IS 1>
		<cfif Attributes.SHOWEXPAND IS 1>
		<td class=clsTab id=TAGALL onclick="hideAllTabs(#Attributes.GTABID#);">
		<a href=JavaScript:hideAllTabs(#Attributes.GTABID#);TabClick2('ALL')>Show All</a></td>
		</cfif>
		</tr></table>
		<table width=100% class=clsTabOutside cellspacing=0 cellpadding=0><tr><td class=clsTabInside>
	<cfelseif Attributes.SKIN IS 2>
		<cfif Attributes.SHOWEXPAND IS 1>
		<td class=clsTab2 width=* id=TAGALL onclick="hideAllTabs(#Attributes.GTABID#);TabClick2('ALL')">
			<table cellpadding=0 cellspacing=0 border=0><tr><td width=6 height=30><img src="#Request.Webroot#common/tab1i_02.gif" class=clsNoPrint id=TABIMG1ALL></td><td width=100% nowrap height="30" style="background-image:url(#Request.Webroot#common/tab1i_04.gif);background-repeat:repeat-x" align="center" id=TABIMG2ALL>
			<a href=JavaScript:hideAllTabs(#Attributes.GTABID#);TabClick2('ALL')>Show All</a>
			</td><td width=12 height=30><img src="#Request.Webroot#common/tab1i_06.gif" class=clsNoPrint id=TABIMG3ALL></td></tr></table>
		</td>
		</cfif>
		<td width=5 nowrap height="30" style="background-image:url(#Request.Webroot#common/tab1_08.gif);background-repeat:repeat-x">
		</tr></table>
		<table width=100% border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td style="background-image:url(#Request.webroot#common/tab1border_02.gif);background-repeat:repeat-y" width="8"></td>
				<td width="100%" bgcolor="##FFFFFF" colspan="3">
	</cfif>
</cfif>
<cfif Attributes.COMMAND IS "BEGINBORDER">
	<cfif Attributes.SKIN IS 1>
		<table id=TABLE#Attributes.TABID# width=#Attributes.WIDTH# cellspacing=1 style="display:none"><tr><td>
	<cfelseif Attributes.SKIN IS 2>
		<table id=TABLE#Attributes.TABID# width=#Attributes.WIDTH# cellspacing=1 style="display:none"><tr><td>
	</cfif>
</cfif>
<cfif Attributes.COMMAND IS "ENDBORDER">
	<cfif Attributes.SKIN IS 1>
		</td></tr></table>
	<cfelseif Attributes.SKIN IS 2>
		</td></tr></table>
	</cfif>
</cfif>
<cfif Attributes.COMMAND IS "FINISH">
	<cfif Attributes.SKIN IS 1>
		</td></tr></table>
	<cfelseif Attributes.SKIN IS 2>
				</td>
				<td style="background-image:url(#Request.webroot#common/tab1border_04.gif);background-repeat:repeat-y" width="8"></td>
			</tr>
			<tr>
				<td><img src="#Request.webroot#common/tab1border_05.gif" width="8" height="9" alt="" class="clsNoPrint"></td>
				<td width="100%" style="background-image:url(#Request.webroot#common/tab1border_09.gif);background-repeat:repeat-x" colspan="3" height="9"></td>
				<td><img src="#Request.webroot#common/tab1border_11.gif" width="8" height="9" alt="" class="clsNoPrint"></td>
			</tr>
		</table>
	</cfif>
</cfif>
</cfoutput>