<!---
Update signatory to all letters.

Attributes:
COID: The company.

Return Values :
--->
<CFIF IsDefined("SESSION.VARS.ORGID")>
<CFPARAM NAME=Attributes.COID DEFAULT=#SESSION.VARS.ORGID#>
</CFIF>

<!--- Putting extra logic to ease maintenance for templates --->
<cfparam NAME=Attributes.OBJID type=numeric default=0>
<cfparam NAME=Attributes.IBIDID type=numeric default=0>
<cfparam NAME=Attributes.ITENDER type=numeric default=0>
<CFPARAM NAME=Attributes.USERID DEFAULT="#SESSION.VARS.USERID#">
<CFPARAM NAME=Attributes.NOSIGN DEFAULT=0>
<cfparam NAME=Attributes.WIDTH DEFAULT="100%">
<cfparam NAME=Attributes.LAYOUT DEFAULT=0>
<cfparam NAME=Attributes.cellPadding DEFAULT=1>
<cfparam NAME=Attributes.cellSpacing DEFAULT=1>

<CFQUERY NAME=q_trx DATASOURCE=#Request.MTRDSN#>
SELECT co.iCOID, co.iGCOID, co.vaCONAME,pic.iUSID,pic.vaUSID,PICNAME=vaUSName,PICDESG=rol.vaDESC,PICDEPT=pic.vaDEPT
FROM sec0005 co 
INNER JOIN sec0001 pic on co.iCOID=pic.iCOID
INNER JOIN sec0002 rol on rol.siCOTYPEID=co.siCOTYPEID and rol.siROLE=pic.siROLE
WHERE pic.vaUSID=<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Attributes.USERID#"> and pic.iCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.COID#">
</CFQUERY>

<CFQUERY NAME=q_co DATASOURCE=#Request.MTRDSN#>
SELECT a.iGCOID,insname=a.vaCONAME,a.vaCOBRNAME,a.vaCOREGNO,a.vaADD1,a.vaADD2,a.vaADD3,a.vaPOSTCODE,a.aTELNO,a.aFAXNO,a.vaTAXREGNO,
		cologo=a.vaLOGO,CITY=b.vaDESC,a.iSTATEID,STATE=c.vaDESC,a.vaEMAIL,vaCOTAGLINE,a.iCITYID,a.iPCOID,
		PICNAME=pic.vaUSNAME,PICDSGN=pic.vaDESIGNATION,PICTEL=pic.aTELNO,PICDEPT=pic.vaDEPT,PICEMAIL=pic.vaEMAIL
FROM TRX0008 d WITH (NOLOCK)INNER JOIN SEC0001 pic WITH (NOLOCK) ON (d.vaOWNER=pic.vaUSID OR ((d.vaOWNER IS NULL OR d.vaOWNER='') AND pic.vaUSID=<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Attributes.USERID#">))
INNER JOIN SEC0005 a WITH (NOLOCK) ON d.iCOID=a.iCOID
INNER JOIN SYS0003 b WITH (NOLOCK) ON a.iCITYID=b.iCITYID
INNER JOIN SYS0002 c WITH (NOLOCK) ON b.iSTATEID=c.iSTATEID 
WHERE d.iCASEID=<cfqueryparam value="#Attributes.OBJID#" cfsqltype="CF_SQL_INTEGER">
</CFQUERY>

<cfif Attributes.ITENDER GT 0>
<CFQUERY NAME=q_tender DATASOURCE=#Request.MTRDSN#>
SELECT TOP 1 g.iGCOID,
	insconame=g.vaconame, inscobrname=g.vacobrname, insadd1=g.vaadd1, insadd2=g.vaadd2, inspostcode=g.vapostcode, inscity=h.vadesc, insstate=i.vadesc, instelno=g.atelno,d.icaseid, iinscoid=d.icoid,
	PICNAME=pic.vaUSNAME,PICDSGN=pic.vaDESIGNATION,PICTEL=pic.aTELNO,PICDEPT=pic.vaDEPT,PICEMAIL=pic.vaEMAIL
FROM trx0071 a WITH (NOLOCK)
INNER JOIN trx0070 d WITH (NOLOCK) on a.itender=d.itender
INNER JOIn sec0001 pic WITH (NOLOCK) on pic.vaUSID=<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Attributes.USERID#">
INNER JOIN sec0005 g WITH (NOLOCK) on d.icoid=g.icoid
INNER JOIN sys0003 h WITH (NOLOCK) on g.icityid=h.icityid
INNER JOIN sys0002 i WITH (NOLOCK) on g.istateid=i.istateid 
WHERE a.itender=<cfqueryparam value="#Attributes.ITENDER#" cfsqltype="CF_SQL_INTEGER">
<cfif Attributes.IBIDID GT 0>
AND a.ibidid=<cfqueryparam value="#Attributes.IBIDID#" cfsqltype="CF_SQL_INTEGER">
</cfif>
</CFQUERY>
</CFIF>

<CFIF q_co.recordcount GT 0>
<CFOUTPUT query=q_co>
<table class=clsTablePrint border="0" cellPadding="#Attributes.cellPadding#" cellSpacing="#Attributes.cellSpacing#" style= "WIDTH:#Attributes.WIDTH#;font-size:100%" align="center">
<cfif iGCOID is 200039>	
	<tr><td>Yours faithfully</td></tr>
	<tr><td>&nbsp;</td></tr>
	<CFIF PICNAME IS NOT ""><tr><td colspan=3>#ucase(PICNAME)#</td></tr></cfif>
	<tr><td>General Claims</td></tr>
	<tr><td>#vaCONAME#</td></tr>
	<tr><td>Tel: #PICTEL#</td></tr>
	<tr><td>Fax: 6327 3014</td></tr>
	<tr><td>Email: <a href=email>#PICEMAIL#</a></td></tr>
	<tr><td>&nbsp;</td></tr>
<cfelseif iGCOID is 203273>
	<tr><td>Yours Sincerely,</td></tr>
	<tr><td>&nbsp;</td></tr>
	<tr><td>ECICS Limited</td></tr>
	<tr><td>Claims Department</td></tr>
	<tr><td>&nbsp;</td></tr>
<cfelseif iGCOID is 69>
	<tr><td>Yours faithfully,</td></tr>
    <tr><td style="font-weight:bold;">#insname#</td></tr>
    <tr><td>&nbsp;</td></tr>
	<tr><td>&nbsp;</td></tr>
    <tr><td>#PICNAME#</td></tr>
    <tr><td>#PICDSGN#</td></tr>
    <tr><td>#PICDEPT#</td></tr>
    <tr><td>Tel : #PICTEL#</td></tr>
    <tr><td>Email : #PICEMAIL#</td></tr>
	<tr><td>&nbsp;</td></tr>
	<cfif #Attributes.NOSIGN# EQ 1>
		<tr><td style="font-weight:bold">(This is a computer generated letter, no signature is required)</td></tr>
		<tr><td>&nbsp;</td></tr>
	</cfif>
<cfelseif iGCOID is 29>
	<tr><td>Yours faithfully,</td></tr>
	<tr><td>&nbsp;</td></tr>
	<tr><td><b>#PICNAME#</b></td></tr>
	<tr>
		<td>
			<b>AIG</b>
			<br>
			Complex Claim
			<br>
			Consumer Claims
		</td>
	</tr>
	<tr><td>&nbsp;</td></tr>
	<tr><td>Tel +6 03 2118 03___ | Fax +6 03 2118 0399</td></tr>
<cfelseif iGCOID is 203018>
	<tr><td>Yours sincerely</td></tr>
	<tr><td>&nbsp;</td></tr>
	<tr><td><b>#PICNAME#</b></td></tr>
	<tr>
		<td>
			Executive
			<br>Claims Department
			<br>DID: 6922 6019
			<br><cfif PICEMAIL neq "">Email: <a href=email>#PICEMAIL#</a></cfif>
		</td>
	</tr>
</cfif>
</table>
</CFOUTPUT>
<CFELSEIF Attributes.ITENDER GT 0>
<CFIF q_tender.recordcount GT 0>
<CFOUTPUT query=q_tender> <!--- for tender letter --->
<table class=clsTablePrint border="0" cellPadding="1" cellSpacing="1" style= "WIDTH:#Attributes.WIDTH#;font-size:100%" align="center">
<cfif iGCOID is 200039>	
	<tr><td>Yours faithfully</td></tr>
	<tr><td>&nbsp;</td></tr>
	<CFIF PICNAME IS NOT ""><tr><td colspan=3>#ucase(PICNAME)#</td></tr></cfif>
	<tr><td>General Insurance (Claims)</td></tr>
	<tr><td>#insconame#</td></tr>
	<tr><td>Tel.: 6248 2638 | DID: #PICTEL#</td></tr>
	<tr><td><a href=email>#PICEMAIL#</a></td></tr>
	<tr><td>&nbsp;</td></tr>
<cfelseif iGCOID is 29>
	<tr><td>Yours faithfully,</td></tr>
	<tr><td>&nbsp;</td></tr>
	<tr><td><b>#PICNAME#</b></td></tr>
	<tr>
		<td>
			<b>AIG</b>
			<br>
			Complex Claim
			<br>
			Consumer Claims
		</td>
	</tr>
	<tr><td>&nbsp;</td></tr>
	<tr><td>Tel +6 03 2118 03___ | Fax +6 03 2118 0399</td></tr>
</cfif>
</table>
</CFOUTPUT>
</CFIF>
<CFELSE>
	<table class=clsTablePrint border="0" cellPadding="1" cellSpacing="1" style= "WIDTH:#Attributes.WIDTH#;font-size:100%" align="center">
	<tr><td>Yours faithfully,</td></tr>
	<cfif q_trx.recordcount GT 0>
	<cfoutput query=q_trx>
	<tr><td style="font-weight:bold">#UCASE(vaCONAME)#<br><br><br><br></td></tr>
	<tr><td style="font-weight:bold">#PICNAME#</td></tr>
	<tr><td>#PICDEPT#</td></tr>
	</cfoutput>
	<cfelse>
	<tr><td style="font-weight:bold">&lt;CONAME&gt;<br><br><br><br></td></tr>
	<tr><td style="font-weight:bold">&lt;PICNAME&gt;</td></tr>
	<tr><td>&lt;PICDEPT&gt;</td></tr>
	</cfif>
	</table>
</CFIF>
<table class=clsTablePrint border="0" cellPadding="1" cellSpacing="1" style="WIDTH:#Attributes.WIDTH#;font-size:100%" align="center">
<cfif #Attributes.NOSIGN# EQ 1 AND Attributes.COID NEQ 69>
	<tr><td colspan=2 >(This is a computer generated letter, no signature is required)</td></tr>
	<tr><td colspan=2>&nbsp;</td></tr>
</cfif>
<cfif IsDefined("attributes.CCLIST")>
	<cfloop array=#attributes.CCLIST# index="value">
		<tr style=line-height:30%><td colspan=2>&nbsp;</td></tr>
		<tr><td width="5%" valign="top">cc.</td><td>#value#</td></tr>
	</cfloop>
</cfif>
</table>
