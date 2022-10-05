<!--- 
Sets list of domain values

Parameters:
	DOMAIN = Name of domain
	GETVAL = Description to get from domain value
--->
<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCDISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">
<CFPARAM NAME=ATTRIBUTES.DOMAIN DEFAULT="">
<CFSET Attributes.DOMAIN=UCase(Trim(Attributes.DOMAIN))>
<CFIF ATTRIBUTES.DOMAIN IS "DAMTYPE">
	<CFSET DOMRESULT=StructNew()>
	<CFSET StructInsert(DOMRESULT,"0","Collision")>
	<CFSET StructInsert(DOMRESULT,"1","Self-Accident")>
	<CFSET StructInsert(DOMRESULT,"2","Malicious Damage")>
	<CFSET StructInsert(DOMRESULT,"3","Fire")>
	<CFSET StructInsert(DOMRESULT,"4","Flood")>
	<CFSET StructInsert(DOMRESULT,"5","Recovered from Theft")>
	<CFSET StructInsert(DOMRESULT,"6","Missing/Theft")>
	<CFSET StructInsert(DOMRESULT,"7","Damaged in Transit (Marine)")>
	<CFSET StructInsert(DOMRESULT,"8","Robbery")>
	<CFSET StructInsert(DOMRESULT,"9","CBT")>
	<CFSET StructInsert(DOMRESULT,"10","Damaged in Transit (Inland)")>
	<CFSET StructInsert(DOMRESULT,"11","Windscreen")>
<!---CFELSEIF ATTRIBUTES.DOMAIN IS "DAMTYPE2">
	<CFSET DOMRESULT=StructNew()>
	<CFSET StructInsert(DOMRESULT,"0","Collision")>
	<CFSET StructInsert(DOMRESULT,"1","Self-Accident")>
	<CFSET StructInsert(DOMRESULT,"2","Malicious Damage")>
	<CFSET StructInsert(DOMRESULT,"3","Fire")>
	<CFSET StructInsert(DOMRESULT,"4","Flood")>
	<CFSET StructInsert(DOMRESULT,"5","Recovered from Theft")>
	<CFSET StructInsert(DOMRESULT,"6","Missing/Theft")>
	<CFSET StructInsert(DOMRESULT,"7","Damaged in Transit (Marine)")>
	<CFSET StructInsert(DOMRESULT,"8","Robbery")>
	<CFSET StructInsert(DOMRESULT,"9","CBT")>
	<CFSET StructInsert(DOMRESULT,"10","Damaged in Transit (Inland)")>
	<CFSET StructInsert(DOMRESULT,"11","Windscreen")>
	<CFSET StructInsert(DOMRESULT,"12","Impact")>
	<CFSET StructInsert(DOMRESULT,"13","Earthquake")>
	<CFSET StructInsert(DOMRESULT,"14","Internal Defect")>
	<CFSET StructInsert(DOMRESULT,"15","Theft of Motorcycle / Accessories")>
	<CFSET StructInsert(DOMRESULT,"16","Riots")>
	<CFSET StructInsert(DOMRESULT,"17","Others")>
	<CFSET StructInsert(DOMRESULT,"18","Theft of In Accessories")>
	<CFSET StructInsert(DOMRESULT,"19","Theft of Out Accessories")>
	<CFSET StructInsert(DOMRESULT,"20","Malicious Damage")>
	<CFSET StructInsert(DOMRESULT,"21","Civil Commotion, Terror, Sabotage")--->
<CFELSEIF Attributes.DOMAIN IS "CDFAULT">
	<CFSET DOMRESULT=StructNew()>
	<CFSET StructInsert(DOMRESULT,"1","Driver")>
	<CFSET StructInsert(DOMRESULT,"2","Third Party")>
	<CFSET StructInsert(DOMRESULT,"3","Unknown")>
<CFELSEIF Attributes.DOMAIN IS "LOCCLAIM">
	<CFSET DOMRESULT=StructNew()>
	<CFSET StructInsert(DOMRESULT,"1","Roadside - Public Parking")>
	<CFSET StructInsert(DOMRESULT,"2","Roadside - Outside Residence")>
	<CFSET StructInsert(DOMRESULT,"3","Within Compound of Residence")>
	<CFSET StructInsert(DOMRESULT,"11","Parking Lot - Open")>
	<CFSET StructInsert(DOMRESULT,"12","Parking Lot - Covered")>
	<CFSET StructInsert(DOMRESULT,"21","Toll Highway")>
	<CFSET StructInsert(DOMRESULT,"22","Trunk Road")>
	<CFSET StructInsert(DOMRESULT,"23","City Road")>
	<CFSET StructInsert(DOMRESULT,"30","Intersection")>
	<CFSET StructInsert(DOMRESULT,"40","Robbery / Car Jack")>
	<CFSET StructInsert(DOMRESULT,"99","Others")>
	<CFSET StructInsert(DOMRESULT,"101","Ship, Air")>
	<CFSET StructInsert(DOMRESULT,"104","Rail")>
	<CFSET StructInsert(DOMRESULT,"105","Truck")>
	<CFSET StructInsert(DOMRESULT,"106","Tranship")>
	<CFSET StructInsert(DOMRESULT,"107","Warehouse")>
	<CFSET StructInsert(DOMRESULT,"108","Factory")>
<CFELSEIF Attributes.DOMAIN IS "VHCLASS">
	<CFSET DOMRESULT=StructNew()>
	<CFSET StructInsert(DOMRESULT,"1","Motorcycle")>
	<CFSET StructInsert(DOMRESULT,"2","Private/Company Car")>
	<CFSET StructInsert(DOMRESULT,"3","Taxi")>
	<CFSET StructInsert(DOMRESULT,"4","Bus")>
	<CFSET StructInsert(DOMRESULT,"5","Goods Vehicle")>
	<CFSET StructInsert(DOMRESULT,"6","Tanker")>
	<CFSET StructInsert(DOMRESULT,"7","Mobile Equipment & Others")>
	<CFSET StructInsert(DOMRESULT,"8","Motor Trade")>
	<CFSET StructInsert(DOMRESULT,"9","Government")>
<CFELSEIF Attributes.DOMAIN IS "VHCONDAMAGE">
	<CFSET DOMRESULT=StructNew()>
	<CFSET StructInsert(DOMRESULT,"1","Minor")>
	<CFSET StructInsert(DOMRESULT,"2","Moderate")>
	<CFSET StructInsert(DOMRESULT,"3","Serious")>
	<CFSET StructInsert(DOMRESULT,"4","Very Serious")>
<CFELSEIF Attributes.DOMAIN IS "VHASMBTYPE">
	<CFSET DOMRESULT=StructNew()>
	<CFSET StructInsert(DOMRESULT,"1","Reconditioned")>
	<CFSET StructInsert(DOMRESULT,"2","New Import")>
	<CFSET StructInsert(DOMRESULT,"3","Locally Assembled")>
<CFELSEIF Attributes.DOMAIN IS "VHTYRETYPE">
	<CFQUERY NAME=q_domdata DATASOURCE=#Request.MTRDSN#>
		SELECT a.siTTYPEID,a.vaDESC FROM CAT0018 a WITH (NOLOCK) WHERE a.siSTATUS=0 ORDER BY a.vaDESC
	</CFQUERY>
	<CFSET DOMRESULT=StructNew()>
	<CFOUTPUT query=q_domdata>
		<CFSET StructInsert(DOMRESULT,siTTYPEID,vaDESC)>
	</CFOUTPUT>
</CFIF>
<CFSET Caller.DOMVAL="">
<CFIF IsDefined("DOMRESULT") AND IsStruct(DOMRESULT)>
	<CFSET Caller.DOMRESULT=DOMRESULT>
	<CFIF IsDefined("attributes.getval") AND Attributes.getval IS NOT "">
		<CFIF StructKeyExists(DOMRESULT,attributes.getval)><CFSET Caller.DOMVAL=StructFind(DOMRESULT,Attributes.getval)></CFIF>
	</CFIF>
</CFIF>
