<!--- 
Returns the attribute for a certain AttrID and Domain Attr ID
Parameters:
	AttrID: Attribute ID to retrieve (required)
	ID: Attribute domain ID in integer (required or VID required)
	VID: Attribute domain ID in varchar (required or ID required)
Return Values :
	Caller.AttrValue = Value of the attribute
--->
<!---CFIF IsDefined("Attributes.ID")>
	<CFQUERY NAME=q_trx DATASOURCE=#Request.MTRDSN#>
	SELECT vaATTR FROM SYS0013 WITH (NOLOCK) WHERE iATTRID=<cfqueryparam value="#Attributes.AttrID#" cfsqltype="CF_SQL_INTEGER"> AND iATTRDOMID=<cfqueryparam value="#Attributes.ID#" cfsqltype="CF_SQL_INTEGER">
	</CFQUERY>
<CFELSE>
	<CFQUERY NAME=q_trx DATASOURCE=#Request.MTRDSN#>
	SELECT vaATTR FROM SYS0014 WITH (NOLOCK) WHERE iATTRID=<cfqueryparam value="#Attributes.AttrID#" cfsqltype="CF_SQL_INTEGER"> AND vaATTRDOMID=<cfqueryparam value="#Attributes.VID#" cfsqltype="CF_SQL_NVARCHAR">
	</CFQUERY>
</CFIF>
<CFIF q_trx.recordcount GT 0><CFSET Caller.AttrValue=q_trx.vaATTR><CFELSE><CFSET Caller.AttrValue=""></cfif--->
<cfparam name=Attributes.AttrID type=string>
<cfparam name=Attributes.ID type=numeric>
<CFIF IsNumeric(Attributes.AttrID)>
	<!--- For legacy purpose! --->
	<CFSET Attributes.AttrID="COATTR"&Attributes.AttrID>
</CFIF>
<CFSET Caller.AttrValue=Request.DS.FN.SVCgetExtAttrLogic("COADMIN",0,Attributes.AttrID,10,Attributes.ID)>