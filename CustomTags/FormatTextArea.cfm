<!--- Defaults specified here --->
<cfparam name="attributes.type" default="div">
<cfparam name="attributes.class" default="">
<cfparam name="attributes.width" default="100%">
<cfparam name="attributes.fontfamily" default="arial">
<cfparam name="attributes.fontsize" default="100%">
<cfparam name="attributes.wrap" default="soft">
<cfparam name="attributes.newlineafter" default="no">
<cfparam name="attributes.lineheight" default="100%">
<cfparam name="attributes.background" default="">
<CFOUTPUT>
<cfif attributes.type is "div" OR attributes.type is "span">
	<cfset counter=1>
	<cfset length=#len(attributes.text)#>
	<cfset temp=#HTMLEditFormat(attributes.text)#>
	<cfset pos=1>
	<cfloop index="idx" from=#length# to=2 step=-1>
	<cfset test1=mid(temp, pos, 1)>
	<cfset test2=mid(temp, pos+1, 1)>
		<cfif test1 is Chr(10)><!--- htmleditformat removes carriage return so newline is just linefeed chr(10) --->
			<cfset counter=counter+1>
			<cfset temp = RemoveChars(temp, pos, 1)>
			<cfset temp = Insert("<br>", temp, pos-1)>
			<cfset pos=pos+4>
		<cfelseif test1 is " " and test2 is " ">
			<cfset temp = RemoveChars(temp, pos, 2)>
			<cfset temp = Insert(" &nbsp;", temp, pos-1)>
			<cfset pos=pos+7>
		<cfelse>
			<cfset pos=pos+1>
		</cfif>
	</cfloop>
	<cfset caller.linecount=counter>
	<!--- div class="#attributes.class#" style='line-height:#attributes.lineheight#;word-wrap:break-word; width:#attributes.width#; font-family:#attributes.fontfamily#; font-size=#attributes.fontsize#;' --->
	<#attributes.type# class="#attributes.class#" style='background:#attributes.background#;line-height:#attributes.lineheight#;text-align:justify; width:#attributes.width#; font-family:#attributes.fontfamily#; font-size=#attributes.fontsize#;'>
	#temp#
	</#attributes.type#>
<cfelse>
	<cfset counter=1>
	<cfif attributes.wrap is "hard">
		<cfset length=#len(attributes.text)#>
		<cfset temp=attributes.text>
		<cfset newline=Chr(13) & Chr(10)>
		<cfloop index="idx" from=#length# to=2 step=-1>
			<cfif left(temp,2) is newline>
				<cfset counter=counter+1>
			</cfif>
			<cfset temp=#Right(temp,idx-1)#>
		</cfloop>
		<cfset caller.linecount=counter>
	<cfelse>
		<CFMODULE TEMPLATE="#Request.LOGPATH#CustomTags\addfile.cfm" FNAME="Meri">
		<script>
		try { AddOnloadCode("CheckHeight()") }
		catch(e) { window.onload=new Function("CheckHeight();"); }
		function CheckHeight()
		{
		var obj=document.all("FMTtextarea");
		var len=obj.length; //to make sure that if more there is more than one call to this tag in the same page, tag still works
		if (len==null) {obj[0]=obj;len=1;}
		for (n=0; n<len;n++)
			{
				while (obj[n].scrollHeight>obj[n].offsetHeight)
				{
					obj[n].rows++;
				}
			}
		}
		</script>	
	</cfif>
<textarea id="FMTtextarea" class="#attributes.class#" style='line-height:#attributes.lineheight#;background-color:transparent;top:0%; padding:0; border:none; width=#attributes.width#; overflow:hidden; font-family:#attributes.fontfamily#; font-size=#attributes.fontsize#;' rows=#counter#  READONLY>#HTMLEditFormat(attributes.text)#<cfif attributes.newlineafter is "yes">#Chr(10)##Chr(13)#</cfif></textarea>
</cfif>

</CFOUTPUT>

<!--- 
Summary of problems:
textarea: can set the rows dynamically and hide borders and scrollbars, but doesn't print correctly (the whole text area goest to the next page) in ie 5.5 and above.
div: word-wrap=break-word attribute does not work in ie 5.0
 --->
 
 
