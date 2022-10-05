<CFIF attributes.DOMAINID eq 7>
<style>
.tbl1 td{padding:0px 0px 0px 0px;}
.tbl1 td:last-child{padding-bottom:0px;padding-left:0px;}
.arheader{font-size:12.5px;font-weight:bold;}
.arheaderLate{font-size:12.5px;font-weight:bold;}
.tbl2 td{padding:1px; font-size:9.5px;}
span.important-nl {font-size:10px;}
span.important {font-size:10px;border-bottom: 1.25px solid black; }
span.vimportant {font-weight:bold;border-bottom: 1.25px solid black;}
span.line {border-bottom:1.25px solid black;}
.tbl2{margin-bottom:4px;}
.tbl3 td{padding:4px 3px 3px 3px;}
tr{page-break-inside:avoid;}
table.tbl3 td:nth-child(2) {text-transform:uppercase;}
</style>

<CFELSEIF attributes.DOMAINID eq 1>
	<cfif isdefined("attributes.GCOID") and attributes.GCOID eq 1510001>
		<style>
		tr{page-break-inside:avoid;}
		#COHEADER td {padding:1px; font-size:8px;}
		.clsSVCClmBorder td {font-size:9.5px;}
		.tbl2 td{padding:2px 1px 1px 1px;} 
		#qty {padding-right:2px;}
		</style>	
	<cfelse>
		<style>
		.clsBody td { font-size:12px; }
		.clsRptCoverPage td { font-size:12px; }
		.clsNewBorder { border:1px solid darkgray;border-collapse:separate; }
		tr{page-break-inside:avoid;}
		</style>	
	</cfif>
</CFIF>