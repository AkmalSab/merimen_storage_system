<!---
It seems like dsp_userprofile has some hardcodes to support blocking permissions from being displayed in certain locales.
The User group listing should also use back this same rule. (At the moment there is a bug where permission group not reflecting userprofile shown/hidden groups)

The user matrix report should only show permission & permission groups that are being displayed in the user profile.
#20137: [MY] AmG Motor - Admin Module
 --->
<cfparam name="attributes.COID" default="">
<cfparam name="Attributes.LOCID" default=""><!--- Pass in LOCID from caller --->
<cfparam name="Attributes.ORGTYPE" default=""><!--- Pass in orgtype from caller --->

<CFSET PERMGRPNOTLIST=""><!--- don't display permission groups in this list --->
<CFSET permhidlist = ""> <!--- hide from ui only --->
<CFSET PRESELECTLIST = ""><!--- for creating new users only --->
<CFSET PERMDISLIST = ""><!--- to hide permission (user screen), to disable permission from granted (mrm admin screen) --->

<CFIF Attributes.LOCID IS 2>
	<cfset PERMGRPNOTLIST="70">
	<cfif NOT(Attributes.ORGTYPE IS "I" OR Attributes.ORGTYPE IS "D")>
		<cfset PERMGRPNOTLIST=ListAppend(PERMGRPNOTLIST,"80,90")>
	</cfif>
	<CFIF Attributes.ORGTYPE IS NOT "D">
	   <cfset permhidlist=ListAppend(permhidlist,"440,503,444,442,441,443,500,504,501,502,53,507")>
	</CFIF>
<CFELSE>
	<cfset PERMGRPNOTLIST="70,80,90">
	<cfif Attributes.LOCID IS 5>
		<cfset PRESELECTLIST="7,34,1,35,75,76,63,33,64,401,402,98,99">
	</cfif>
</CFIF>

<!--- <cfif NOT(structkeyexists(request.ds.co,attributes.COID) AND request.ds.co[attributes.COID].gcoid IS 200045)> --->
<cfif NOT(Attributes.LOCID IS 2)>
	<cfset permdislist=listappend(permdislist,"139")>
</cfif>

<!--- For insurer only. --->
<cfif structKeyExists(request.ds.co, attributes.coid) and request.ds.co[attributes.COID].COTYPEID eq 2>
	<CFSET AttrVal=Request.DS.FN.SVCgetExtAttrLogic("COADMIN",0,"COATTR124",10,request.ds.co[attributes.COID].gcoid)>
	<CFIF NOT(isNumeric(AttrVal) AND BITAND(AttrVal,1) IS 1)>
		<cfset permdislist=listappend(permdislist,"67")>
	</cfif>
	<cfif NOT(request.ds.co[attributes.COID].gcoid IS 29 OR request.ds.co[attributes.COID].gcoid IS 67)><cfset permdislist=listappend(permdislist,"66")></cfif>
</cfif>


<cfset caller.PERMGRPNOTLIST = PERMGRPNOTLIST>
<cfset caller.PERMHIDLIST = PERMHIDLIST>
<cfset caller.PRESELECTLIST = PRESELECTLIST>
<cfset caller.PERMDISLIST = PERMDISLIST>