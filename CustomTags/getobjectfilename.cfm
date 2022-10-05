<!--- 
Custom Tag <CFMODULE TEMPLATE="#Request.LOGPATH#CustomTags\getobjectfilename.cfm">
Attributes
----------
	drive : specify the drive letter where the object will be stored
CALLER
------
	destinationdir : destination directory
	destinationfile : destination file name
	destinationfullfilepath	 : full pathname
	
Author 	: Isaac Chong
Date	: 16 May 2000
Revision: 1

Example 
-------

	<cfset destinationdir = "">
	<cfset destinationfile = "">
	<cfset destinationfullfilepath	 = "">

	<CFMODULE TEMPLATE="#Request.LOGPATH#CustomTags\getobjectfilename.cfm" drive="K:">
	<...>

Purpose
-------
Get the filename and the path to the directory where we are writing the object
to.
The file extension is not included in this function. You can append to it.

Make sure the CALLER define "destinationfile" as the variable to receive the 
filename.
--->
<cfset returnvalue = -1>
<!--- Find out which directory to put the object to --->
<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCgetsysteminteger.cfm" Varname="OBJDIR">
<!--- Construct the filename for the object to be stored --->
<cfset caller.destinationdir = "FS" & returnvalue & "\">
<cfset yearpart = Right(DatePart("yyyy", Now()), 2)>
<cfset daypart  = DayOfYear(Now())>
<cfif daypart lt 10>
    <cfset daypart="00" & daypart>
<cfelseif daypart gte 10 and daypart lt 100>
	<cfset daypart="0" & daypart>	
</cfif>					
<cfset returnvalue = -1>					
<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCgetsysteminteger.cfm" Varname="OBJFILE">
<cfset filepart = returnvalue>
<cfif filepart lt 10>
	<cfset filepart = "00000" & filepart>
<cfelseif filepart lt 100>
	<cfset filepart = "0000" & filepart>
<cfelseif filepart lt 1000>
	<cfset filepart = "000" & filepart>
<cfelseif filepart lt 10000>
	<cfset filepart =  "00" & filepart>
<cfelseif filepart lt 100000>
	<cfset filepart =  "0" & filepart>
</cfif>
<!--- Construct the full path to the object --->
<cfset filepart =  yearpart & daypart & filepart>
<cfset filepart = Left(filepart, 8) & "." & Right(filepart, 3)>
<cfset caller.destinationfile = filepart>
