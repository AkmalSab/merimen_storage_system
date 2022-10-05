<!--- 
Tag to generate description for rpt-for-repairer type
0: No report
Bit 1: Disclose
Bit 2: Hide Part Prices
Bit 4: Hide Non-parts
Bit 8: Factor Overridden Approved Amt into Parts
Bit 16: Hide Rep Est
Bit 32: Show Adj Recommend
--->
<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCDISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">
<CFPARAM NAME=Attributes.OFRPRICE DEFAULT=0>
<CFPARAM NAME=Attributes.EXTRAONLY DEFAULT=0>
<CFSET EXTRALIST="">
<CFIF NOT Attributes.EXTRAONLY>
	<CFIF BitAnd(Attributes.OFRPRICE,1) IS 1>
	<CFSET DISPMASK=BitAnd(Attributes.OFRPRICE,7)\2>
	<CFIF DISPMASK IS 0><cfoutput>#Server.SVClang("Disclose All",3582)#</cfoutput>
	<CFELSEIF DISPMASK IS 1><cfoutput>#Server.SVClang("Disclose All (without Parts Prices)",3583)#</cfoutput>
	<CFELSEIF DISPMASK IS 2><cfoutput>#Server.SVClang("Disclose Parts Only",3584)#</cfoutput>
	<CFELSEIF DISPMASK IS 3><cfoutput>#Server.SVClang("Disclose Parts Only (without Parts Prices)",3585)#</cfoutput>
	</CFIF>
	<CFELSE><cfoutput>#Server.SVClang("No Report",3586)#</cfoutput></CFIF>
</CFIF>
<CFIF BitAnd(Attributes.OFRPRICE,8) IS 8>
	<CFSET EXTRALIST="#Server.SVClang("Factor Overridden in Parts",3587)#">
</CFIF>
<CFIF BitAnd(Attributes.OFRPRICE,16) IS 16>
	<CFIF EXTRALIST IS "">
		<CFSET EXTRALIST="#Server.SVClang("Hide Rep Col",3588)#">
	<CFELSE>
		<CFSET EXTRALIST=EXTRALIST & ", <cfoutput>#Server.SVClang("Hide Rep Col",3588)#</cfoutput>">
	</CFIF>
</CFIF>
<CFIF BitAnd(Attributes.OFRPRICE,32) IS 32>
	<CFIF EXTRALIST IS "">
		<CFSET EXTRALIST="#Server.SVClang("Show Adj Col",3589)#">
	<CFELSE>
		<CFSET EXTRALIST=EXTRALIST & ", <cfoutput>#Server.SVClang("Show Adj Col",3589)#</cfoutput>">
	</CFIF>
</CFIF>
<CFIF EXTRALIST IS NOT "">
	<CFOUTPUT>[#EXTRALIST#]</CFOUTPUT>
</CFIF>

