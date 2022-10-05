<cfset CustomExcelTitle = "Panel Rate Management Upload Template">
<cfif upltype EQ 1>
	<cfset CustomExcel = ["Manufacturer", "Model", "Priority", "Vehicle Age (Symbol)", "Vehicle Age (Year)", "Vehicle Class", "Part Discount (%)", "Labour Rate (RM/hr)"]>
	<cfset CustomMapTitle = {"Manufacturer"="Manufacturer", "Model"="Model", "Priority"="Priority", "Vehicle Age (Symbol)"="Vehicle Age (Symbol)"
		                   , "Vehicle Age (Year)"="Vehicle Age (Year)", "Vehicle Class"="Vehicle Class"
						   , "Part Discount (%)"="Part Discount (%)", "Labour Rate (RM/hr)"="Labour Rate (RM/hr)", "Vehicle_Age_Symbol"="Vehicle Age (Symbol)" 
						   , "Vehicle_Age_Year"="Vehicle Age (Year)", "Vehicle_Class"="Vehicle Class", "Part_Discount"="Part Discount (%)"
						   , "Labour_Rate"="Labour Rate (RM/hr)"}>
<cfelse>
	<cfset CustomExcel = ["PanelID","Manufacturer", "Model", "Priority", "Vehicle Age (Symbol)", "Vehicle Age (Year)", "Vehicle Class", "Part Discount (%)", "Labour Rate (RM/hr)"]>
	<cfset CustomMapTitle = {"PanelID"="PanelID","Manufacturer"="Manufacturer", "Model"="Model", "Priority"="Priority", "Vehicle Age (Symbol)"="Vehicle Age (Symbol)"
		                   , "Vehicle Age (Year)"="Vehicle Age (Year)", "Vehicle Class"="Vehicle Class"
						   , "Part Discount (%)"="Part Discount (%)", "Labour Rate (RM/hr)"="Labour Rate (RM/hr)", "Vehicle_Age_Symbol"="Vehicle Age (Symbol)" 
						   , "Vehicle_Age_Year"="Vehicle Age (Year)", "Vehicle_Class"="Vehicle Class", "Part_Discount"="Part Discount (%)"
						   , "Labour_Rate"="Labour Rate (RM/hr)"}>
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