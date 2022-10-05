<cfif attributes.COID eq 7651>
	<cfset CustomExcelTitle = "MRP Agent Listing">
	<cfset CustomExcel = ["NO.", "AGENT CODE", "AGENT NAME", "H/P NO", "AGENT EMAIL ADDRESS"
	                   , "CATEGORY ACHIEVED", "EFFECTIVE FROM (DD/MM/YYYY)"
					   , "EFFECTIVE TO (DD/MM/YYYY)", "MRP STATUS (A=Active, I=Inactive)", "BRANCH", "BRANCH CODE"]>
	<cfset CustomMapTitle = {"Code 1"="Agent Code", "Name"="Agent Name", "Mobile No"="H/P No", "Email"="Agent Email Address"
		                   , "Code 2"="Category Achieved", "Effective From"="Effective From (DD/MM/YYYY)"
						   , "Effective To"="Effective To (DD/MM/YYYY)", "Status"="MRP Status (A=Active, I=Inactive)", "Branch Name"="BRANCH", "Code 3"="BRANCH CODE"}>
	<cfset defcotype = "6">
	<cfset defsubcotype = "4">
</cfif>

<cffunction name="getColName" output="false">
	<cfargument name="item">
	<cfif structCount(CustomMapTitle) gt 0 and StructKeyExists(CustomMapTitle,item)>
		<cfreturn "<span style='font-style:italic;color:blue;'>(" & UCASE(CustomMapTitle[item]) &")</span>">
	<cfelse>
		<cfreturn "">
	</cfif>
</cffunction>
<cffunction name="getcolname2" output="false">
	<cfargument name="item">
	<cfif structCount(CustomMapTitle) gt 0 and StructKeyExists(CustomMapTitle,item)>
		<cfreturn CustomMapTitle[item]>
	<cfelse>
		<cfreturn item>
	</cfif>
</cffunction>