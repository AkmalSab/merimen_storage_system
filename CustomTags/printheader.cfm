<cfparam NAME=Attributes.Title DEFAULT="#Application.APPFULLNAME#">
<cfparam NAME=Attributes.FontSize DEFAULT="75%">
<cfparam NAME=Attributes.FontFamily DEFAULT="arial">
<cfparam NAME=Attributes.FontSizeCover DEFAULT="100%">
<cfset Server.SVClangSet(0,5)><!--- Set default language based on LOCID --->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html><head><title><cfoutput>#Attributes.Title#</cfoutput></title>
<style ID=PAGEBREAKID MEDIA=PRINT>
	.clsPageBreak { page-break-after:always;margin:0px 0px 0px .0001pt;line-height:0.0001pt }
</style>
<style MEDIA=PRINT>
	.clsPageBreakFixed { page-break-after:alwayss;margin:0px 0px 0px .0001pt;line-height:0.0001pt }
	.clsNoPrint { display:none }
</style>
<style>
	.header { background-color:lightsteelblue;font-size:105%;font-weight:bold;color:navy;border:1px solid darkgray }
	.clsClmTable { border-collapse:collapse;border:1px solid darkgray }
	.clsClmTable TD { padding-left:3px;padding-right:3px;line-height:125% }
	.clsClmBorder { border:1px solid darkgray;border-collapse:collapse }
	.clsTblNoBorder { }
	.clsTblNoBorder TD { border:0px }
	.clsRptItemDesc { color:darkred;font-weight:bold;text-align:right }
	.clsRptSubTitle { color:darkred;text-align:left;font-size:160% }
	.clsRptCmt { font-size:80%;font-weight:normal }
	.clsRptTone1 { }
	.clsRptTone2 { background-color:gainsboro }
	.clsRptTone2 TD { border-bottom:1px solid gainsboro }
	.clsRptNote { color:darkred;font-size:80%;font-weight:normal;font-style:italic }
	.clsRptTotal { background-color:silver;font-weight:bold }
	.clsRptWarning { color:red;font-weight:bold }
	.clsRptFixed { font-family:courier }
	.clsRptTitle { font-weight:bold;text-decoration:underline }
	<CFOUTPUT>
	.clsBody { color:black;margin:0;font-family:#Attributes.FontFamily# }
	.clsRptBody { FONT-SIZE:#Attributes.FontSize# }
	.clsRptCoverPage { FONT-SIZE:#Attributes.FontSizeCover# }
	</cfoutput>
	.clsRptBody TABLE { FONT-SIZE:100% }
	BLOCKQUOTE { text-align:center;border:2px solid;font-weight:bold }
</style>
</head><body class=clsBody><div class=clsRptBody>