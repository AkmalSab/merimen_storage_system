<!---
FILENAME : coheader.cfm
DESCRIPTION :
Generates company letterheads for printing.


INPUT/ATTR:
COID - The company's letterhead.

OUTPUT : None.

CREATED BY : Andrew
CREATED ON : Jan 2002

REVISION HISTORY
BY          ON          REMARKS
=========   ==========  ======================================================================================
Mike		02 Nov 2007	Added layout 1,2 for GCOID=1
--->

<cfif IsDefined("SESSION.VARS.ORGID")>
	<cfparam NAME=Attributes.COID DEFAULT=#SESSION.VARS.ORGID#>
</cfif>
<cfparam NAME=Attributes.ALIGN DEFAULT=CENTER>
<cfparam NAME=Attributes.ADDTEXT DEFAULT="">
<cfparam NAME=Attributes.LAYOUT DEFAULT=0>
<cfparam NAME=Attributes.SHOWTAXNO DEFAULT=0>
<cfparam NAME=Attributes.MANUFACTURER DEFAULT="">
<!--- Putting extra logic into this coheader, to ease maintenance pain for templates --->
<cfparam NAME=Attributes.DOMID type=numeric default=0>
<cfparam NAME=Attributes.OBJID type=numeric default=0>
<cfparam NAME=Attributes.WIDTH DEFAULT="100%">
<cfparam name=Attributes.isGST default=0>
<cfparam NAME=ATTRIBUTES.MEMOCHB DEFAULT="">
<cfparam name="ATTRIBUTES.NOWATERMARK" default="0">
<cfparam name=Attributes.corp default=0>

<CFSET CLAIMTYPE="">
<cfset CHBMEMO=#ATTRIBUTES.MEMOCHB#>

<cfquery NAME=q_gco DATASOURCE=#Request.MTRDSN#>
	select iGCOID from SEC0005 WITH (NOLOCK)
		where iCOID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.COID#">
</cfquery>

<cfif (attributes.DOMID IS 0 OR Attributes.OBJID IS 0) AND q_gco.iGCOID IS NOT 500004>
	<cfif Isdefined("URL.domainid") AND Isdefined("URL.objid") AND URL.domainid GT 0 AND URL.objid GT 0 AND IsNumeric(URL.domainid) AND IsNumeric(URL.objid) >
		<Cfset attributes.DOMID=#URL.domainid#><Cfset attributes.OBJID=#URL.objid#>
	<cfelseif Isdefined("URL.caseid") AND URL.caseid GT 0 AND IsNumeric(URL.caseid)>
		<Cfset attributes.DOMID=1><Cfset attributes.OBJID=#URL.caseid#>
	</cfif>
</cfif>

<cfif Attributes.DOMID IS 1 AND Attributes.OBJID GT 0>
	<cfquery NAME=q_trx DATASOURCE=#Request.MTRDSN#>
	SELECT aCLAIMTYPE=UPPER(RTRIM(a.aCLAIMTYPE))
	FROM TRX0001 a WITH (NOLOCK)
	WHERE a.iCASEID=<CFQUERYPARAM value="#Attributes.OBJID#" CFSQLTYPE=CF_SQL_INTEGER>
	</cfquery>
	<cfif q_trx.recordcount IS NOT 1>
		<CFTHROW TYPE="EX_DBERROR" ErrorCode="COHEADER">
	</cfif>
	<cfset CLAIMTYPE=q_trx.aCLAIMTYPE>
</cfif>
<cfset APPLOCID=Application.APPLOCID>

<!--- for ACE Synergy, always use HQ --->
<cfif q_gco.iGCOID IS 415>
	<cfset Attributes.COID = 415>
</cfif>

<!--- MPIB --->
<cfif q_gco.iGCOID IS 37>
	<cfif CLAIMTYPE IS "TP" OR CLAIMTYPE IS "TP PD" OR CLAIMTYPE IS "TP BI">
		<cfset Attributes.COID=37>
	</cfif>
</cfif>

<cfset BnP_CoList="">
<cfif q_gco.iGCOID IS 1424>
	<cfquery NAME=q_child DATASOURCE=#Request.MTRDSN#>
	SELECT iCHCOID FROM SEC0015 WITH (NOLOCK) WHERE iCOID=29506 AND siHIERARCHY>0
	</cfquery>
	<cfset BnP_CoList=ValueList(q_child.iCHCOID)>
</cfif>

<cfquery NAME=q_co DATASOURCE=#Request.MTRDSN#>
SELECT a.iLOCID,a.iCOID, a.iGCOID,a.vaCONAME,a.vaCOBRNAME,a.vaCOTAGLINE,a.vaCOREGNO,a.vaCOREGNO_OLD,a.vaADD1,a.vaADD2,a.vaADD3,a.vaPOSTCODE,a.aTELNO,a.aFAXNO,
		cologo=a.vaLOGO,CITY=b.vaDESC,STATE=c.vaDESC,a.vaEMAIL, a.vaCOTAGLINE ,a.vaTAXREGNO,a.iCITYID,siLOGOTYPE=IsNull(a.siLOGOTYPE,0),
		GCONAME=d.vaCONAME,GCOREGNO=d.vaCOREGNO, datetaxregistered = a.dtTAXREG, datetaxterminate = a.dtTAXKILL
        , isTaxEff = case when
        a.vataxregno is not null and
        datediff(dd,a.dtvateffective,getdate()) > 0 and
        datediff(dd,getdate(), isNull(a.dttaxkill,dateadd(d,1,getdate())) )>0 then 1 else 0 end
        , a.vaTAXREGNO,a.iPCOID,a.vataxbranch,a.vaSVCREGNO
        ,hq_cologo=d.vaLOGO,hq_vacoregno=d.vacoregno, hq_vaconame=d.vaconame, hq_vaADD1=d.vaADD1, hq_vaADD2=d.vaADD2, hq_vaADD3=d.vaADD3, hq_vaPOSTCODE=d.vaPOSTCODE, hq_city=e.vaDESC, hq_aTELNO=d.aTELNO, hq_aFAXNO=d.aFAXNO, hq_vaEMAIL=d.vaEMAIL, hq_vasvcregno=d.vasvcregno, hq_vacoregno_old=d.vacoregno_old
FROM SEC0005 a WITH (NOLOCK)
	INNER JOIN SEC0005 d WITH (NOLOCK) ON d.iCOID=a.iGCOID
    left join SYS0003 b WITH (NOLOCK) on a.iCITYID=b.iCITYID
    left join SYS0003 e WITH (NOLOCK) on d.iCITYID=e.iCITYID
    left join SYS0002 c WITH (NOLOCK) on b.iSTATEID=c.iSTATEID
WHERE a.iCOID =<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.COID#">
</cfquery>

<cfoutput query=q_co>
	<cfset CALLER.CONAME=vaCONAME>
	<cfset CALLER.TAXREGNO=vaTAXREGNO>
	<cfset CALLER.TAXBRANCH=vataxbranch>
	<cfset CALLER.SVCREGNO=vaSVCREGNO>
	<cfset LOCALE=Request.DS.LOCALES[iLOCID]>
	<cfif iGCOID IS 1>
		<CFIF isdefined('ATTRIBUTES.OLD_SG_ADDRESS') and ATTRIBUTES.OLD_SG_ADDRESS eq 1>
			<cfset q_co.vaADD1 = "10 Anson Road">
			<cfset q_co.vaADD2 = "##06-16 International Plaza">
			<cfset q_co.vaPOSTCODE = "079903">
		</CFIF>
		<CFIF Attributes.LAYOUT IS 1>
		<div id=COHEADER>
			<cfif q_co.iLOCID eq 11><span style="width:65%;float:left"><cfelse><span style="width:60%;float:left"></cfif><img SRC="#request.webroot#MSupport/logo/<cfif APPLOCID IS 5>mbz.png<cfelse>fermionmerimen_sm_inv.png</cfif>" border=0><br>
				<cfif q_co.iLOCID eq 11><span style="font-weight:bold;font-size:150%"><cfelse><span style="font-weight:bold;font-size:150%"></cfif>#HTMLEditFormat(vaCONAME)#</span>
				<cfif q_co.iLOCID eq 2>
					<br><span style="font-size:100%;;font-weight:bold">UEN & GST Reg. No.: 200706671H</span>
				<cfelse>
					<cfif Trim(vaCOREGNO) IS NOT "" AND Trim(vaCOREGNO) IS NOT "-" and q_co.iLOCID neq 11><br><span style="font-size:100%;;font-weight:bold">Co. Reg. No. : #HTMLEditFormat(vaCOREGNO)#</span></cfif>
					<cfif Trim(vaSVCREGNO) IS NOT "" AND Trim(vaSVCREGNO) IS NOT "-"><br><span style="font-size:100%;;font-weight:bold">#LOCALE.SVCTAXNAME# Reg. No. : #HTMLEditFormat(vaSVCREGNO)#</span>
					<cfelseif Trim(vaTAXREGNO) IS NOT "" AND Trim(vaTAXREGNO) IS NOT "-"><br><span style="font-size:100%;;font-weight:bold">#LOCALE.VATTAXNAME# Reg. No. : #HTMLEditFormat(vaTAXREGNO)#</span></cfif>
				</cfif>
				<cfif q_co.iLOCID eq 11 and TRIM(vataxbranch) neq ""><br><span style="font-size:100%;;font-weight:bold">Place of Business: #HTMLEditFormat(vataxbranch)#</span></cfif>
				<!---br><u><i><cfif APPLOCID IS 5>www.motobiz.net.my<cfelse>www.merimen.com</cfif></i></u--->
			</span>
			<cfif q_co.iLOCID eq 11><span style="width:35%;color:gray;font-weight:bold;font-size:90%;float:right"><cfelse><span style="width:40%;color:gray;font-weight:bold;font-size:90%;float:right"></cfif>
			<cfif Trim(vaCOTAGLINE) IS NOT ""><span class=clsCoTagLine>#HTMLEditFormat(vaCOTAGLINE)#</span><br></cfif>
			<cfif Trim(vaADD1) IS NOT "">#HTMLEditFormat(vaADD1)#,<br></cfif>
			<cfif Trim(vaADD2) IS NOT ""> #HTMLEditFormat(vaADD2)#,<br></cfif><cfif STATE IS "Singapore">Singapore #Trim(vaPOSTCODE)#.<cfelse>#Trim(vaPOSTCODE)# #CITY#, #STATE#.</cfif><br>
			<cfif Trim(aTELNO) IS NOT "">Tel: #HTMLEditFormat(Trim(aTELNO))#<br></cfif>
			<cfif Trim(aFAXNO) IS NOT "">Fax: #HTMLEditFormat(Trim(aFAXNO))#<br></cfif>
			<cfif Trim(vaEMAIL) IS NOT "">Email: #HTMLEditFormat(Trim(vaEMAIL))#<br></cfif>
			<!---#TAXNo("HTML","","","YES")#--->
			</span>
		</div>
		<br clear=all>
		<CFELSEIF Attributes.LAYOUT IS 2>
		<table id=COHEADER border=0 cellPadding=1 cellSpacing=1 style="WIDTH:100%;font-size:100%" align=center>
		<tr><td valign=top><img SRC="#request.webroot#MSupport/logo/<cfif APPLOCID IS 5>mbz.png<cfelse>fermionmerimen_sm_inv.png</cfif>" border=0></td></tr>
		<tr><td><span style="font-weight:bold;font-size:120%">#HTMLEditFormat(vaCONAME)#</span><cfif Trim(vaCOREGNO) IS NOT "" AND Trim(vaCOREGNO) IS NOT "-"> <span style="font-size:50%;color:black">(#HTMLEditFormat(vaCOREGNO)#)</span></cfif></td></tr>
		<tr>
			<td style="color:gray;font-size:90%;font-weight:bold">
			<cfif Trim(vaSVCREGNO) IS NOT "" AND Trim(vaSVCREGNO) IS NOT "-"><span>#LOCALE.SVCTAXNAME# Reg. No. : #HTMLEditFormat(vaSVCREGNO)#</span><br>
			<cfelseif Trim(vaTAXREGNO) IS NOT "" AND Trim(vaTAXREGNO) IS NOT "-"><span>#LOCALE.VATTAXNAME# Reg. No. : #HTMLEditFormat(vaTAXREGNO)#</span><br></cfif>
			<cfif Trim(vaCOTAGLINE) IS NOT ""><span class=clsCoTagLine>#HTMLEditFormat(vaCOTAGLINE)#</span><br></cfif>
			<cfif Trim(vaADD1) IS NOT "">#HTMLEditFormat(vaADD1)#,<br></cfif>
			<cfif Trim(vaADD2) IS NOT ""> #HTMLEditFormat(vaADD2)#,<br></cfif><cfif STATE IS "Singapore">Singapore #Trim(vaPOSTCODE)#.<cfelse>#Trim(vaPOSTCODE)# #CITY#, #STATE#.</cfif><br>
			<cfif Trim(aTELNO) IS NOT "">Tel: #HTMLEditFormat(Trim(aTELNO))#</cfif><cfif Trim(aFAXNO) IS NOT "">&nbsp;&nbsp;Fax: #HTMLEditFormat(Trim(aFAXNO))#</cfif>
			<cfif Trim(vaEMAIL) IS NOT "">Email: <u>#HTMLEditFormat(Trim(vaEMAIL))#</u></cfif>
			<!---#TAXNo("HTML","","","YES")#--->
			</td>
		</tr>
		</table>
		<CFELSE>
		<table id=COHEADER border=0 cellPadding=1 cellSpacing=1 style="WIDTH:100%;font-size:100%" align=center>
			<tr>
				<td valign=top><img SRC="#request.webroot#MSupport/logo/<cfif APPLOCID IS 5>mbz.png<cfelse>fermionmerimen_sm_inv.png</cfif>" border=0></td>
			</tr>
			<tr>
				<td>
				<b>#HTMLEditFormat(vaCONAME)#<cfif vaCOREGNO IS NOT ""> <span style="font-size:50%;color:black">(#HTMLEditFormat(vaCOREGNO)#)</span></cfif></b><br>
				<cfif Trim(vaSVCREGNO) IS NOT "" AND Trim(vaSVCREGNO) IS NOT "-"><span>#LOCALE.SVCTAXNAME# Reg. No. : #HTMLEditFormat(vaSVCREGNO)#</span><br>
				<cfelseif Trim(vaTAXREGNO) IS NOT "" AND Trim(vaTAXREGNO) IS NOT "-"><span>#LOCALE.VATTAXNAME# Reg. No. : #HTMLEditFormat(vaTAXREGNO)#</span><br></cfif>
				<cfif q_co.iLOCID IS 11><span>#Server.SVClang("Place of Business",0)#: <cfif Trim(vaTAXBRANCH) IS "">HEAD OFFICE<cfelse>#HTMLEditFormat(vaTAXBRANCH)#</cfif></span><br></cfif>
				<cfif Trim(vaCOTAGLINE) IS NOT ""><span class=clsCoTagLine>#HTMLEditFormat(vaCOTAGLINE)#</span><br></cfif>
				<cfif Trim(vaADD1) IS NOT "">#HTMLEditFormat(vaADD1)#,<br></cfif>
				<cfif Trim(vaADD2) IS NOT ""> #HTMLEditFormat(vaADD2)#,<br></cfif><cfif STATE IS "Singapore">Singapore #Trim(vaPOSTCODE)#.<cfelse>#Trim(vaPOSTCODE)# #CITY#, #STATE#.</cfif><br>
				<cfif Trim(aTELNO) IS NOT "">Tel: #HTMLEditFormat(Trim(aTELNO))#</cfif><cfif Trim(aFAXNO) IS NOT "">&nbsp;&nbsp;Fax: #HTMLEditFormat(Trim(aFAXNO))#</cfif>
				<cfif Trim(vaEMAIL) IS NOT "">&nbsp;&nbsp;Email: #HTMLEditFormat(Trim(vaEMAIL))#</cfif>
				<!---#TAXNo("HTML","","","YES")#--->
				</td>
			</tr>
		</table>
		</CFIF>
	<cfelseif iGCOID IS 27>
	<!--- Hong Leong WIDTH:95%;font-size:90% --->
		<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="font-size:80%;color:black"  align="right" background="">
		<tr><td>&nbsp;</td><td align="left" colspan=2><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
 		<tr><td>&nbsp;</td><td style="width:43px">&nbsp;</td><td nowrap style="width:205px">#vaCONAME# <span style="font-size:90%">(#vaCOREGNO#)</span></td></tr>
		<tr><td colspan=2>&nbsp;</td><td></td></tr>
		<tr style="line-height:50%"><td colspan=3>&nbsp;</td></tr>
		<tr><td colspan=2>&nbsp;</td><td>#HTMLEditFormat(vaADD1)#</td></tr>
		<CFIF vaADD2 IS NOT ""><tr><td colspan=2>&nbsp;</td><td>#HTMLEditFormat(vaADD2)#</td></tr></CFIF>
		<tr><td colspan=2>&nbsp;</td><td>#vaPOSTCODE# #city#, Malaysia</td></tr>
		<cfif iCOID IS 27><tr><td colspan=2>&nbsp;</td><td>P.O.Box 12495, 50780 Kuala Lumpur</td></tr></CFIF>
		<tr style="line-height:50%"><td colspan=3>&nbsp;</td></tr>
		<tr><td colspan=2>&nbsp;</td><td><b>Telephone</b> &nbsp; #aTELNO#</td></tr>
		<tr><td colspan=2>&nbsp;</td><td><b>Facsimile</b> &nbsp;&nbsp;&nbsp; #aFAXNO#</td></tr>
		<tr><td colspan=2>&nbsp;</td><td><b>Website</b> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; www.hla.com.my</td></tr>
		<tr><td colspan=2>&nbsp;</td><td><b>Customer Service Hotline</b> &nbsp;03-7650 1288</td></tr>
		<tr><td colspan=2>&nbsp;</td><td><b>Customer Service Hotfax</b> &nbsp;&nbsp;03-7650 1299</td></tr>
		<tr><td colspan="2">&nbsp;</td><td>#TAXNo("HTML","","font-weight:bold;")#</td></tr>
		</table>
		<BR Clear=all>
		<!---<table id=COHEADER style="WIDTH:100%;font-size:80%" align=center border=0 cellPadding=0 cellSpacing=0>
		<!---<tr><td width="65%" rowspan=2><img SRC="#request.webroot#MSupport/logo/#cologo#"></td><td valign="top" colspan=2><img SRC="#request.webroot#MSupport/logo/hlagrp.gif"></td></tr>
 		<tr><td width="9%"></td><td style="font-size:70%;color:MidnightBlue"><b>Head Office</b></td><td></td></tr>
		<tr><td>&nbsp;</td><td></td><td style="font-size:65%;color:MidnightBlue">Level 26, Menara HLA, No.3 Jalan Kia Peng,<br>50450 Kuala Lumpur, Malaysia. P.O. Box 12495,<br>50780 Kuala Lumpur, Malaysia.<br>
									Tel: 03-7650 1818 Fax: 03-7650 1991<br>URL: www.hla.com.my</td></tr>
		--->
		<tr><td rowspan=3 style="width:115ex">&nbsp;</td><td colspan=3><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
		<!---<tr><td style="width:11.5ex">&nbsp;</td><td colspan=2>#HTMLEditFormat(vaCONAME)# <span style="font-size:70%">(#HTMLEditFormat(vaCOREGNO)#)</span><br><br>
				Level 26, Menara HLA, No.3 Jalan Kia Peng,<br>
				50450 Kuala Lumpur, Malaysia.<br>
				P.O. Box 12495, 50780 Kuala Lumpur.<br><br></td></tr>
		<tr><td>&nbsp;</td><td style="width:10%">Telephone<br>
										Facsimile<br>
										URL</td><td>03-7650 1818<br>
													03-7650 1881<br>
													www.hla.com.my</td></tr>--->
		<!---<tr><td colspan=3><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
		<tr><td style="width:7ex">&nbsp;</td><td colspan=2>#HTMLEditFormat(vaCONAME)# <span style="font-size:70%">(#HTMLEditFormat(vaCOREGNO)#)</span><br><br>
				Level 26, Menara HLA, No.3 Jalan Kia Peng,<br>
				50450 Kuala Lumpur, Malaysia.<br>
				P.O. Box 12495, 50780 Kuala Lumpur.<br><br></td></tr>
		<tr><td>&nbsp;</td><td style="width:10%">Telephone<br>
										Facsimile<br>
										URL</td><td>03-7650 1818<br>
													03-7650 1881<br>
													www.hla.com.my</td></tr>--->
	</table>--->
	<cfelseif iGCOID IS 29>
		<cfif attributes.layout IS 2><!--- specific customisation for etender on tax invoice / tax credit note --->
		<table id=COHEADER border="0" cellPadding="1" cellSpacing="1" style="WIDTH:100%" align="center">
			<tr><td width=80%>
				#vaCONAME# (#vaCOREGNO#)
				<br>#HTMLEditFormat(vaADD1)#<cfif vaADD2 IS NOT "">, #HTMLEditFormat(vaADD2)#</cfif>, #Trim(vaPOSTCODE)# #CITY#, Malaysia.
				<br>Telphone 6 (03) 2118 0188 &nbsp;&nbsp;&nbsp; Facsimile 6 (03) 2118 0288
				<br>GST Registration No: #vaTAXREGNO#
			</td><td width=20% align="right"><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
		</table>
		<br>
		<cfelseif attributes.layout IS 3>
			<table id=COHEADER style="width:100%;vertical-align:top;">
				<tr>
					<td style="width:90%;">
						AIG Malaysia Insurance Berhad (795492-W)<br />
						Level 18, Menara Worldwide, 198 Jalan Bukit Bintang, 55100 Kuala Lumpur, Malaysia<br />
						Telephone : 1 800 88 8811 &nbsp;&nbsp;&nbsp; Facsimile : 603 2685 4896
					</td>
					<td style="width:10%;" align=right><img SRC="#request.webroot#MSupport/logo/AIG-ClaimFormTFright.gif"></td>
				</tr>
			</table>
		<cfelse>
	<table id=COHEADER border="0" cellPadding="1" cellSpacing="1" style="WIDTH:100%" align="center">
		<tr><td align=left valign=top><img SRC="#request.webroot#MSupport/logo/#cologo#"><br>&nbsp;</td></tr>
	</table>
	<table border="0" cellPadding="1" cellSpacing="1" style="WIDTH:100%;font-size:100%" align="center">
	<tr><td id="COHEADER" valign=top width=150px><img SRC="#request.webroot#MSupport/logo/AIG-new-MYHQaddress.png"></td>
		<td valign=top>
			<!---><table border="0" cellPadding="1" cellSpacing="1" style="WIDTH:100%;font-size:100%" align="center">
				<tr style="line-height:20px"><td>&nbsp;</td></tr>
			</table>--->
	<!--- old format - unwanted --->
	<!---table id=COHEADER border="0" cellPadding="1" cellSpacing="1" style="WIDTH:100%" align="left">
		<tr><td align=left><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr--->
		<!---><tr><td><br><br>&nbsp;</td></tr>
		<tr><td align=left><img SRC="#request.webroot#MSupport/logo/AIG-new-MYHQaddress.png"></td></tr>--->
	<!---></table>--->
	<!--- end of 29 --->
		</cfif>

	<!----<cfelseif iGCOID IS 28>
		<!--- MNI --->
		<cfif Attributes.COID IS 1615>
		<!--- MNI:Oneline --->
		<table border="0" cellPadding="1" cellSpacing="1" style="WIDTH:95%" align="center">
		<tr><td rowspan=2><b>#Attributes.ADDTEXT#</b></td><td align=right><img src="#request.webroot#MSupport/logo/mnioneline.gif"></td></tr>
		<tr><td align=right>#HTMLEditFormat(vaADD1)#<Br>#HTMLEditFormat(vaADD2)#<br>#HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(city)#<br>
		Tel: #aTELNO#<br>Fax: #aFAXNO#<br>Email: info@mnioneline.com.my</td></tr>
		<cfelse>
		<table id=COHEADER border=0 cellPadding=1 cellSpacing=1 style=WIDTH:100%;font-size:75% align=center>
		<tr style=line-height:90%><td rowspan=9 valign=top><img SRC="#request.webroot#MSupport/logo/#cologo#"></td><td width=38% style="font-size:120%"><b>#vaCONAME# (#vaCOREGNO#)</b></td></tr>
		<CFIF vaCOTAGLINE IS NOT ""><tr style=line-height:90%><td>#vaCOTAGLINE#</td></tr></CFIF>
		<tr style=line-height:90%><td>#vaADD1#</td></tr>
		<tr style=line-height:90%><td>#vaADD2#</td></tr>
		<tr style=line-height:90%><td>#HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(city)#</td></tr>
		<tr style=line-height:70%><td>&nbsp;</td></tr>
		<tr style=line-height:90%><td>Telephone: #aTELNO#</td></tr>
		<tr style=line-height:90%><td>Facsimile: #aFAXNO#</td></tr>
		<tr style=line-height:90%><td>Website: www.etiqa.com.my</td></tr>
		</cfif>
		</table>
		<!---Level 16 Tower 2, MNI Twins, 11, Jalan Pinang<br>50450 Kuala Lumpur Wilayah Persekutuan<br>
		Tel: 03-2176 5000<br>Fax: 03-2176 5050<br>Email: info@mnioneline.com.my
		</td></tr--->
		<!---tr><td align=right><img src="#request.webroot#MSupport/logo/mnioneline.gif"></td></tr>
		<tr><td align=right>
		Level 16 Tower 2, MNI Twins, 11, Jalan Pinang<br>50450 Kuala Lumpur Wilayah Persekutuan<br>
		Tel: 03-2176 5000<br>Fax: 03-2176 5050<br>Email: info@mnioneline.com.my
		</td></tr--->
		<!---/table>
		<cfelse>
		<table id=COHEADER border=0 cellPadding=1 cellSpacing=1 style=WIDTH:100%;font-size:75% align=center>
		<tr style=line-height:90%><td rowspan=10 valign=top><img SRC="#request.webroot#MSupport/logo/#cologo#"></td><td width=30%>#vaCONAME# (#vaCOREGNO#)</td></tr>
		<cfif #Attributes.COID# IS 28>
		<tr style=line-height:90%><td>Level 26, Tower 1, MNI Twins</td></tr>
		<tr style=line-height:90%><td>11, Jalan Pinang</td></tr>
		<cfelse>
		<tr style=line-height:90%><td>#vaADD1#</td></tr>
		<tr style=line-height:90%><td>#vaADD2#</td></tr>
		</cfif>
		<tr style=line-height:90%><td>#HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(city)#</td></tr>
		<tr style=line-height:70%><td>&nbsp;</td></tr>
		<tr style=line-height:90%><td>Telephone: <cfif #Attributes.COID# IS 28>03-2176 9000<cfelse>#aTELNO#</cfif></td></tr>
		<tr style=line-height:90%><td>Facsimile: <cfif #Attributes.COID# IS 28>03-2176 9090<cfelse>#aFAXNO#</cfif></td></tr>
		<tr style=line-height:90%><td>Website: www.mni.com.my</td></tr>
		</table>
		</cfif--->
		---->
	<!---<cfelseif iGCOID IS 30 OR iGCOID IS 35>
		<!--- Commerce Assurance, formerly of AMI, amended on 23 Feb 2005 --->
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style=WIDTH:90% align=center>
		<tr><td align="center"><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr></table>--->
		<!--- <table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%" align="center">
		<tr><td align=center valign=top><IMG SRC="#request.webroot#MSupport/logo/ami.gif" width=100px></td></tr>
		<tr style=line-height:200%><td align=center><span style="font-size:180%;font-weight:bold;text-decoration:underline">AMI Insurans Berhad</span><span style=font-size:80%> (59131-M)</span></td></tr>
		<tr class=clsAdd><td align=center style="font-size:80%"><b>HEAD OFFICE :</b> Suite 3A-15, Level 15, Block 3A, Plaza Sentral, Jalan Sentral 5, Kuala Lumpur Sentral, 50470 Kuala Lumpur.</td></tr>
		<tr class=clsAdd><td align=center style="font-size:80%">Tel: 03-2730 0400 / 03-2730 0600 Customer Service Number: 03-2730 0700 Fax: 03-2730 0500</td></tr>
		<tr style=line-height:150%><td>&nbsp;</td></tr>
		</TABLE> --->
	<cfelseif iGCOID IS 2622>
		<!--- Commerce Takaful --->
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style=WIDTH:90% align=center>
		<tr>
			<td witdh=70%>
				<table cellPadding=1 cellSpacing=0 style="font-size:80%">
	      			<tr><td><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
					<tr><td><b>#HTMLEditFormat(UCase(vaCONAME))#</b><cfif vaCOREGNO IS NOT ""> <span style="font-size:90%">(#vaCOREGNO#)</span></cfif></td></tr>
					<cfif vaCOTAGLINE IS NOT ""><tr><td>#HTMLEditFormat(vaCOTAGLINE)#</td></tr></cfif>
					<tr><td>#HTMLEditFormat(vaADD1)#</td></tr>
					<cfif #vaADD2# IS NOT ""><tr><td>#HTMLEditFormat(vaADD2)#</td></tr></cfif>
					<tr><td>#HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(city)#</td></tr>
					<!---tr><td>P O Box 12292, 50772 Kuala Lumpur</td></tr--->
					<!---tr><td>Tel:+6#HTMLEditFormat(aTELNO)#  Fax:+6#HTMLEditFormat(aFAXNO)#</td></tr--->
					<tr><td>Tel: #HTMLEditFormat(aTELNO)# &nbsp; Fax: #HTMLEditFormat(aFAXNO)#</td></tr>
					<tr><td>Website: http://www.cimbaviva.com</td></tr>
					#TAXNo("TABLE")#
				</table>
			</td>
			<!---td align="right" valign="top"><img SRC="#request.webroot#MSupport/logo/#cologo#"></td--->
		</tr>
		</table>
	<cfelseif iGCOID IS 32>
		<!--- Berjaya --->
		<CFIF ListFind("DEV,UAT",Application.DB_MODE)>
			<CFIF ATTRIBUTES.LAYOUT EQ 0>
				<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style=WIDTH:90% align=center>
				<tr><td align="center"><img SRC="#request.webroot#MSupport/logo/bsi_v4.PNG" <CFIF IsDefined('ATTRIBUTES.IMGHEIGHT') AND IsDefined('ATTRIBUTES.IMGWIDTH')>WIDTH=#ATTRIBUTES.IMGWIDTH# HEIGHT=#ATTRIBUTES.IMGHEIGHT#</CFIF>></td></tr>
				<!---tr><td align="center" style="font-size:medium; color: ##50609C; text-transform: uppercase"><b><!---#HTMLEditFormat(vaCONAME)#---> <cfif #vaCOREGNO# IS NOT "">&nbsp;(#vaCOREGNO#)</cfif></b></td></tr--->
				<!----tr><td align="center"><div style="line-height:7px">&nbsp;</div></td></tr>
				<tr><td align="center" style="font-size:70%"><b>#HTMLEditFormat(vaADD1)#<cfif #vaADD2# IS NOT "">, #HTMLEditFormat(vaADD2)#</cfif>,&nbsp;#HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(city)#, #HTMLEditFormat(state)#</b></td></tr>
				<tr><td align="center" style="font-size:70%"><b>Telephone:&nbsp;#HTMLEditFormat(aTELNO)#&nbsp;<cfif #aFAXNO# IS NOT "">Fax:&nbsp;#HTMLEditFormat(aFAXNO)#</cfif></b></td></tr>
				#TAXNo("TABLE","align=center","font-size:70%;font-weight:bold")#---->
				</table>
			<CFELSEIF ATTRIBUTES.LAYOUT EQ 1>
				<div style="text-align: center;"><img SRC="#request.webroot#MSupport/logo/bsi_v4.png"></div>
				<table id=COHEADER border=0 style=WIDTH:99% align=center>
						<!--- <tr><td align="center"><cfoutput><img SRC="#request.webroot#MSupport/logo/BSI.png"></cfoutput></td></tr> --->
						<!--- <tr><td align="center"><div style="line-height:7px">&nbsp;</div></td></tr> --->
						<tr><td align="center" style="font-size:5pt;font-family:Arial, Helvetica, sans-serif">Address: <cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" TARGET="ONELINE" ADD1=#vaADD1# ADD2=#vaADD2# POSTCODE=#vaPOSTCODE# CITYID=#iCITYID#>.
							<br>Toll Free No.: 1-800-889-933 &nbsp;Tel: #aTELNO# &nbsp;Fax: #aFAXNO# (Customer Service)
							<br>Website: http://www.berjayasompo.com.my &nbsp;Email: info@bsompo.com.my
							<br><br>Branch: Penang 04-899 4340 (Tel) 04-899 0018 (Fax), Alor Setar 04-771 6123 (Tel) 04-771 6121 (Fax), Ipoh 05-241 3895 (Tel) 05-241 3904 (Fax)
							<br>Taiping 05-805 3895/7 (Tel) 05-807 3904 (Fax), Sitiawan 05-688 1895 (Tel) 05-688 4897 (Fax), Melaka 06-281 3382 (Tel) 06-281 2762 (Fax)
							<br>Johor Bahru 07-387 1066 (Tel) 07-387 3166 (Fax), Kota Bahru 09-747 6444 (Tel) 09-747 7357 (Fax), Kuantan 09-516 5620/621 (Tel) 09-516 5622 (Fax)
							<br>Kuching 082-417 858 (Tel) 082-428 857 (Fax), Bintulu 086-312 575, 313 576/7 (Tel) 086-313 578 (Fax), Kota Kinabalu 088-701 000 (Tel) 088-701 005 (Fax)
							<br>Tawau 089-777 811/812 (Tel) 089-777 813 (Fax), Batu Pahat 07-433 1066 (Tel) 07-435 1066 (Fax), Butterworth 04-323 4200 (Tel) 088-701 005 (Fax)
							<br>Klang 03-3324 9896 (Tel) 03-3324 9946 (Fax), Kuala Terengganu 09-631 8550/9550 (Tel) 09-631 7550 (Fax) Sandakan 089-272 168 (Tel) 089-272 163 (Fax)
							<br>Kluang 07-771 1066 (Tel) 07-772 1066 (Fax), Miri 085-321 453/4 (Tel) 085-321 403 (Fax), Petaling Jaya 03-7710 0016 (Tel) 03-7710 0032 (Fax)
							<br><br>
							<span  style="font-size:8pt;">&nbsp;&nbsp;<b>MOTOR ACCIDENT ADVICE FORM</b></span>
							</td></tr>
				</table>
			<CFELSEIF ATTRIBUTES.LAYOUT EQ 2 >
				<table border="0" cellPadding="0" cellSpacing="0" style="WIDTH:90%" align="center">
					<!---tr><td style="font-size:130%;font-weight:bold" align=center>#ucase(insurer)# (62605-U)</td></tr>
					<tr><td>&nbsp;</td></tr>
					<tr><td style="font-size:130%;font-weight:bold" align=center>E-PAYMENT REGISTRATION FORM</td></tr>
					<tr><td style="font-weight:bold" align=center>[ Payment will be made through interbank GIRO (IGB) transfer into your or your Mortgagee / Leasing / Finance company bank account in the event claim is payable ]</td></tr--->
					<tr><td width="70%" align="right" valign="top"><img SRC="#request.webroot#MSupport/logo/bsi_v4.png" WIDTH=500 HEIGHT=67></td>
						<td width="30%" align="bottom">(62605-U)</td></tr>
					<tr><td>&nbsp;</td></tr>
					<tr><td colspan="2" style="font-size:120%" align="center"><b>GST No : #vataxregno#</b></td></tr>
					<tr><td colspan="2" style="font-size:130%" align="center"><b>E-payment &amp; GST Details Registration Form</b></td></tr>
				</table>
			<CFELSEIF ATTRIBUTES.LAYOUT EQ 3>
				<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style=WIDTH:90% align=center>
				<tr><td align="center"><img SRC="#request.webroot#MSupport/logo/bsi_v4.PNG" <CFIF IsDefined('ATTRIBUTES.IMGHEIGHT') AND IsDefined('ATTRIBUTES.IMGWIDTH')>WIDTH=#ATTRIBUTES.IMGWIDTH# HEIGHT=#ATTRIBUTES.IMGHEIGHT#</CFIF>></td></tr>
				</table>
			</CFIF>
		<CFELSE>
			<CFIF ATTRIBUTES.LAYOUT EQ 3>
				<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style=WIDTH:90% align=center>
				<tr><td align="center"><img SRC="#request.webroot#MSupport/logo/bsi_v4.PNG" <CFIF IsDefined('ATTRIBUTES.IMGHEIGHT') AND IsDefined('ATTRIBUTES.IMGWIDTH')>WIDTH=#ATTRIBUTES.IMGWIDTH# HEIGHT=#ATTRIBUTES.IMGHEIGHT#</CFIF>></td></tr>
				</table>
			<CFELSE>
				<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style=WIDTH:90% align=center>
					<tr><td align="center"><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
					<!---tr><td align="center" style="font-size:medium; color: ##50609C; text-transform: uppercase"><b><!---#HTMLEditFormat(vaCONAME)#---> <cfif #vaCOREGNO# IS NOT "">&nbsp;(#vaCOREGNO#)</cfif></b></td></tr--->
					<tr><td align="center"><div style="line-height:7px">&nbsp;</div></td></tr>
					<tr><td align="center" style="font-size:70%"><b>#HTMLEditFormat(vaADD1)#<cfif #vaADD2# IS NOT "">, #HTMLEditFormat(vaADD2)#</cfif>,&nbsp;#HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(city)#, #HTMLEditFormat(state)#</b></td></tr>
					<tr><td align="center" style="font-size:70%"><b>Telephone:&nbsp;#HTMLEditFormat(aTELNO)#&nbsp;<cfif #aFAXNO# IS NOT "">Fax:&nbsp;#HTMLEditFormat(aFAXNO)#</cfif></b></td></tr>
					#TAXNo("TABLE","align=center","font-size:70%;font-weight:bold")#
				</table>
			</CFIF>
		</CFIF>
	<cfelseif iGCOID IS 34>
		<!--- Lonpac --->
		<!--- 41027 ziv --->
		<table id='COHEADER' border=0 cellPadding=0 cellSpacing=0 style=WIDTH:100% align=center>
		<tr><td align="center" rowspan=3><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
			<td>
				<table width=100% border=0 cellPadding=0 cellSpacing=0>
					<tr>
						<td>
							<span style="font-size:180%;font-weight:bold">#HTMLEditFormat(vaCONAME)#</span>
							<cfif #vaCOREGNO# IS NOT ""><span style="color:darkgray;font-weight:bold">&nbsp;#vaCOREGNO#</cfif></span>
						</td>
						<td style="width:40%">
							<span style="border: 1px solid black;text-align: center;padding-right:10px;padding-left:10px;">CONFIDENTIAL</span>
						</td>
					</tr>
					<cfif Attributes.LAYOUT IS 0>
						<tr><td colspan=2 align="left" style="font-size:75%;font-family:Arial"><b>Head Office</b>: LG, 6th, 7th, 21st-26th Floor, Bangunan Public Bank Bhd. No.6, Jln Sultan Sulaiman, 50000 Kuala Lumpur.<br>P.O.Box 10708, 50722 Kuala Lumpur</td></tr>
						<tr><td colspan=2 align="left" style="font-size:75%;font-family:Arial"><b>Tel</b>: (03) 2262 8688 / 2723 7888 <b>Fax</b>: (03) 2715 1332, 2078 7455, 2034 2654, 2715 0722, 2072 3385, 2715 0696, 2723 7886  <!---2715 0696, 2072 3385, 2715 0722, 2034 2654, 2078 7455--->
							<br><b>Website</b>: www.lonpac.com<br>
							<!---b>(GST Reg No. : #vaTAXREGNO#)</b--->
							<b>(SST Reg. No. : #HTMLEditFormat(vaSVCREGNO)#)</b>
							</td></tr>
					</cfif>
 				</table>
			</td></tr>
		</table>
	<cfelseif iGCOID IS 35 and Attributes.LAYOUT IS 1>
		<!---Allianz e-Payment Form Header--->
		<table style="width:90%" align="center">
			<tr>
				<td><img src="#request.webroot#MSupport/logo/AllianzPaymentFormHeader.png" style="width:65%;height:auto"></td>
			</tr>
		</table>
	<cfelseif iGCOID IS 30 OR iGCOID IS 35>
		<!--- Allianz & CAB --->
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial"  align="center" background="">
		<tr><td>&nbsp;</td><td align=right><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
		<tr style=font-size:140%><td colspan=2><b>#HTMLEditFormat(vaconame)#</b> <span style="font-size:80%"><b>(#vaCOREGNO#)</b></span><cfif vaCOREGNO_OLD NEQ ""><span style="font-size:80%"><b>(#vaCOREGNO_OLD#)</b></span></cfif></td></tr>
		<tr style=font-size:95%><td colspan=2>
            <cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" TARGET="TWOLINE" NOCOREGNO=0 CONAMEATTR="style=color:darkred;text-align:left;font-size:160%" COREGNO=#vaCOREGNO# COTAGLINE=#vaCOTAGLINE# ADD1=#vaADD1# ADD2=#vaADD2# POSTCODE=#vaPOSTCODE# CITYID=#iCITYID#><br>
        </td></tr>
		#TAXNo("TABLE","colspan=2","font-size:70%")#
		<!---<tr><td style="font-size:110%">(Formerly known as Malaysia British Assurance Berhad)</td></tr>--->
		</table>
	<cfelseif iGCOID IS 1400001>
		<cfif Attributes.LAYOUT IS 0>
			<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%"  align="center" background="">
			<tr><td valign="top" width=50%>
				<div style="margin-top:23px">
					<img SRC="#request.webroot#MSupport/logo/AIG-new-logo-blue.png" width="100px">
				</div>
			</tr>
			<tr><td valign="top" width=50%>
				<div style="margin-top:23px">
					<div style="font-weight:bold;font-size:9pt;font-family:arial">#request.ds.co[1400001].coname# <!--- <span style="font-weight:normal;font-size:6pt">(#request.ds.co[37].coregno#)</span> ---> </div>
					<div style="margin-top:5px;font-size:7pt;line-height:8pt;font-family:arial">
					#request.ds.co[1400001].add1#,
					<br>#request.ds.co[1400001].add2#,
					<br><CFIF #request.ds.co[1400001].add3# NEQ "">#request.ds.co[1400001].add3#,</cfif>Hong Kong
					<!--- <br>#request.ds.co[1400001].postcode# #request.ds.cities[request.ds.co[1400001].cityid]#, Hong Kong --->
					<br>www.aig.com.hk  <!--- T #request.ds.co[1400001].telno# F #request.ds.co[1400001].faxno# --->
					</div>
				</div>
			</tr>
			</td></tr>
			</table>

		<cfelseif Attributes.LAYOUT IS 1>
			<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:90%"  align="center" background="">
			<tr>
				<td valign="top" width=29%>
				<div style="margin: 23px 0 35px 0;">
					<img SRC="#request.webroot#MSupport/logo/AIG-new-logo-blue.png" width="100px">
				</div>
				</td>
				<td valign="top"></td>
			</tr>
			<tr>
				<td valign="top"></td>
				<td valign="top">Date: ##CURRENTDATE##</td>
			</tr>
			<tr>
				<td valign="top">
					<div>
						<div style="color:##4286f4;font-size:8pt;font-family:arial">#request.ds.co[1400001].coname#</div>
						<div style="color:grey;font-size:8pt;font-family:arial">
							#request.ds.co[1400001].add1#,
							<br>#request.ds.co[1400001].add2#,
							<br><CFIF #request.ds.co[1400001].add3# NEQ "">#request.ds.co[1400001].add3#,</cfif>Hong Kong
							<br>www.aig.com.hk
						</div>
						</div>
					</div>
				</td>
				<td valign="top"></td>
			</tr>
			</table>
		<cfelse>
			<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:90%"  align="center" background="">
			<tr><td valign="top" width=50%>
				<div style="margin-top:23px">
					<img SRC="#request.webroot#MSupport/logo/AIG-new-logo-blue.png" width="100px">
				</div>
			<td valign="top" align="right" width=50%>
				<div style="margin-top:23px">
					<div style="font-weight:bold;font-size:9pt;font-family:arial">#request.ds.co[1400001].coname# <!--- <span style="font-weight:normal;font-size:6pt">(#request.ds.co[37].coregno#)</span> ---> </div>
					<div style="margin-top:5px;font-size:7pt;line-height:8pt;font-family:arial">
					#request.ds.co[1400001].add1#,
					<br>#request.ds.co[1400001].add2#, Hong Kong
					<!--- <br>#request.ds.co[1400001].postcode# #request.ds.cities[request.ds.co[1400001].cityid]#, Hong Kong --->
					<br>T #request.ds.co[1400001].telno# F #request.ds.co[1400001].faxno#
					</div>
				</div>
			</tr>
			</td></tr>
			</table>
		</cfif>
	<cfelseif iGCOID IS 37>
		<!--- Multi-Purpose --->
		<!--- attributes.layout v2 : 0 - logo + HQ address + PIC details (default), 1 - logo + HQ address, 2 - logo only, 3 - PIC details only, 4 - no header, but reserve space on top of the header  --->

<!--- 		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:95%;font-size:130%"  align="center" background="">
		<tr><td align=center><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
		<tr style=line-height:50%><td>&nbsp;</td></tr>
		<tr style=font-size:120%;font-weight:bold;color:darkblue><td align=center>MULTI-PURPOSE INSURANS</td></tr>
		#TAXNo("TABLE","align=center","font-size:120%;font-weight:bold;color:darkblue")#
		</table> --->
		<cfif attributes.layout NEQ 4>
			<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%"  align="center" background="">
			<tr><td valign="top" width="210px">
			<div style="margin-top:20px">
			<!--- <img SRC="#request.webroot#MSupport/logo/#cologo#"> --->
			<cfif attributes.layout NEQ 3><img SRC="#request.webroot#MSupport/logo/my-mpig-v2.png" width="192px"></cfif>
			</div>
			</td>
			<td valign="top" width="180px">
			<cfif attributes.layout IS 0 OR attributes.layout IS 1>
			<div style="font-weight:bold;font-size:7pt;font-family:arial">
				#request.ds.co[37].coname# 
				<br><span style="font-weight:normal;font-size:6pt">Reg No: #request.ds.co[37].coregno# <cfif q_co.hq_vacoregno_old neq "">(#q_co.hq_vacoregno_old#)</cfif></span> 
			</div>
			<!--- <div style="font-size:5pt;line-height:85%;font-family:arial">(Formerly known as Multi-Purpose Insurans Bhd)</div> --->
			<div style="margin-top:5px;font-size:6pt;line-height:8pt;font-family:arial">
			Head Office: #request.ds.co[37].add1#,
			<br>#request.ds.co[37].add2#
			<br>#request.ds.co[37].postcode# #request.ds.cities[request.ds.co[37].cityid]#, Malaysia
			<br>Postal Address: P.O. Box 10122
			<br>50704 Kuala Lumpur, Malaysia
			<br>P #request.ds.co[37].telno#
			<br>F #request.ds.co[37].faxno#
			<br><b>mpigenerali.com</b>
			<cfif Attributes.SHOWTAXNO IS 1><br>#TAXNo("HTML","","","YES")#</cfif>
			</div>
			</cfif>&nbsp;
			</td>
			<td valign="top">
				<cfif (attributes.layout IS 0 OR attributes.layout IS 3) AND (attributes.DOMID IS 0 OR Attributes.OBJID IS 0)>
					<cfif Isdefined("URL.domainid") AND Isdefined("URL.objid") AND URL.domainid GT 0 AND URL.objid GT 0 AND IsNumeric(URL.domainid) AND IsNumeric(URL.objid) >
						<Cfset attributes.DOMID=#URL.domainid#><Cfset attributes.OBJID=#URL.objid#>
					<cfelseif Isdefined("URL.caseid") AND URL.caseid GT 0 AND IsNumeric(URL.caseid)>
						<Cfset attributes.DOMID=1><Cfset attributes.OBJID=#URL.caseid#>
					</cfif>
				</cfif>
				<cfif ((attributes.layout IS 0 OR attributes.layout IS 3) AND Attributes.DOMID IS 1 AND Attributes.OBJID GT 0)>
					<cfquery NAME=q_c DATASOURCE=#Request.MTRDSN#>
					SELECT m.icoid, c.vausname,c.vaDESIGNATION, c.aTELNO, c.vaEMAIL, c.vausid, c.vaMPHONE
					FROM TRX0008 a JOIN TRX0008 m ON a.imaincaseid=m.icaseid
					LEFT JOIN SEC0001 c ON m.vaowner=c.vausid
					where a.icaseid=<CFQUERYPARAM value="#Attributes.OBJID#" CFSQLTYPE=CF_SQL_INTEGER>
					</cfquery>
					<cfif q_c.recordcount GT 0 AND q_c.vausid GT 0>
						<cfset pic_inscoid=#q_c.icoid#>
						<cfset pic_name=#q_c.vausname#>
						<cfset pic_desg=#q_c.vaDESIGNATION#>
						<cfif q_c.vaMPHONE NEQ "">
							<cfset pic_phone=#q_c.vaMPHONE#>
						<cfelse>
							<cfset pic_phone=#q_c.aTELNO#>
						</cfif>
						<cfif LEFT(pic_phone,2) NEQ "+6"><cfset pic_phone="+6#pic_phone#"></cfif>
						<cfset pic_email=#q_c.vaEMAIL#>
					</cfif>
					<cfif Isdefined("pic_name")>
					<table cellspacing=0 cellpadding=0 width="100%">
					<tr><td valign="top" width="140px">
						<div style="font-weight:bold;font-size:7pt">#pic_name#</div>
						<div style="margin-top:5px;font-size:6pt;font-family:arial">
							#pic_desg#
							<br><br>M #pic_phone#
							<br>F <cfif iGCOID IS Attributes.COID>+603 2692 4716<cfelse>#request.ds.co[Attributes.COID].faxno#</cfif>
							<br>#pic_email#

						</div>
						</td><td valign="top">
						<div style="font-weight:bold;font-size:7pt"><cfif CLAIMTYPE IS "NM HS">Claims, Health<cfelseif LEFT(CLAIMTYPE,2) IS "NM">Claims, Non-Motor<cfelse>Motor Claims Department</cfif></div>
						<div style="font-size:6pt;font-family:arial">
							<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" COID=#pic_inscoid# NOCONAME=1 NOCOREGNO=1>
						</div>
						</td>
					</tr>
					</table>
					</cfif>
				</cfif>&nbsp;<!--- customisation --->
			</td>
			</tr>
			</table>
		<cfelse>
		<br><br><br><br><br>
		</cfif>
		<cfparam name="attributes.LTRBODYMARGINLEFT" default="48px">
		<table cellpadding=0 cellspacing=0 width=100%>
		<tr><td width="#attributes.LTRBODYMARGINLEFT#">&nbsp;</td>
			<td>
		<!--- <div id="MYMPI_LTRBODY" style="margin-left:#attributes.LTRBODYMARGINLEFT#;margin-right:0px"> --->
	<cfelseif iGCOID IS 38>
		<!--- P&O --->
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%"  align="center" background="">
		<tr><!---<td><IMG SRC="#request.webroot#MSupport/logo/#cologo#"></td>---><td align=center><span style="font-weight:bold;font-size:180%;font-family:Times New Roman">#ucase(vaconame)#</span><br><span style="font-size:80%">(No. #vaCOREGNO#)</span></td></tr>
		<tr><td style="font-style:italic;font-size:80%" align=center>A Member Of The Pacific & Orient Group</td></tr>
		<tr style="font-size:80%"><td align=center>#vaADD1#<cfif #vaADD2# IS NOT "">, #vaADD2#</cfif>, #vaPOSTCODE# #city#. <cfif #Attributes.COID# IS 38>P.O.Box 10953, 50730 Kuala Lumpur, Malaysia</cfif></td></tr>
		<tr style="font-size:80%"><td align=center>Telephone: #aTELNO# &nbsp;&nbsp;Fax: #aFAXNO# &nbsp;&nbsp;Toll Free No: 1 800 88 2121 &nbsp;&nbsp;Internet: www.poi2u.com</td></tr>
		#TAXNo("TABLE","align=center","font-size:80%")#
		</table>
	<cfelseif iGCOID IS 39>
		<!--- PICM --->
		<div id=COHEADER style=width:100% align=center><img SRC="#request.webroot#MSupport/logo/#cologo#">
		</div>
	<cfelseif iGCOID IS 41>
		<!--- QBE --->
<!--- 	<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 WIDTH=90% style="font-size:80%" align=center>
			<tr><td width=15% valign=top><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
				<td valign=bottom>
					<table style="WIDTH:100%" cellPadding="0" cellSpacing="0">

						<tr><td><span style="font-size:130%;font-weight:bold">QBE Insurance (Malaysia) Berhad</span></td></tr>
						<tr><td><span style="font-size:90%">Reg. No. 161086-D </td></tr>
						<tr><td>No 638, Level 6, Block B1, Leisure Commerce Square, No 9, Jalan PJS 8/9, 46150 Petaling Jaya, Selangor Darul Ehsan</td></tr>
						<tr><td>Phone: 03-7861 8400&nbsp;&nbsp;&nbsp;Fax: 03-7877 0485</td></tr>
						<tr><td>www.qbe.com.my &nbsp;&nbsp;&nbsp; Email: info.mail@qbe.com</td></tr>
						<tr style="line-height:10%"><td style="border-top:1px solid ##ADD8E6">&nbsp;</td></tr>
					</table>
				</td></tr>
		</table> --->


	<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 WIDTH=90% style="font-size:100%" align=center>
		<tr><td width=15% valign=top><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
			<td valign=bottom>
		<table style="WIDTH:100%" cellPadding="0" cellSpacing="0">
			<tr><span style="font-size:130%;font-family:Arial"><b>#HTMLEditFormat(vaconame)#</b>&nbsp;</tr>
			<tr><span style="font-size:90%;font-family:Arial;"><b>(Reg. No.: #HTMLEditFormat(vacoregno)#)</b></tr>
			<tr><td><span style="font-size:110%;font-family:Arial;">#HTMLEditFormat(vaCOTAGLINE)# <br></td></tr><br>
			<tr><td><b><span style="font-size:110%;font-family:Arial;">#HTMLEditFormat(vaADD1)#, #HTMLEditFormat(vaADD2)#, #HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(city)#<br>
					<span style="font-size:100%;font-family:Arial;">Postal Address P.O. Box 10637, 50720 Kuala Lumpur, Malaysia.</b></td></tr>
			<tr><td><b><span style="font-size:110%;font-family:Arial;">Telephone: +6#HTMLEditFormat(aTELNO)# &nbsp; &nbsp; &bull; &nbsp; &nbsp; Facsimile: +6#HTMLEditFormat(aFAXNO)#<br></b></td></tr>
			<tr><td><b><span style="font-size:110%;font-family:Arial;">SST Reg No: #HTMLEditFormat(q_co.vasvcregno)# <br>
				<span style="font-size:110%;font-family:Arial; color:deepskyblue;"> www.qbe.com/my &emsp; e-mail: info.mal@qbe.com</b>
				<tr style="line-height:50%"><td style="border-top:2px solid ##ADD8E6">&nbsp;</td></tr>
		</table>
			</td>
		</tr>
	</table>

	<cfelseif iGCOID IS 42>
		<!--- Royal & Sunalliance --->
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 WIDTH=90% align=center>
		<tr><td valign=top><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
		<td width=50% valign=bottom>
			<table border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;color:darkblue;font-size:90%" align=center>
				<tr><td colspan=3 style="font-family:Palatino LinoType;"><span style="font-size:14pt;font-weight:bold">#vaconame#</span> <span style="font-size:7pt;font-family:Palatino LinoType;">#vacoregno#</span></td></tr>
				<tr><td colspan=3 style="font-family:Palatino LinoType;font-size:7pt;font-style:italic">#vaCOTAGLINE#</td></tr>
				<tr><td style="font-family:Palatino LinoType;font-size:7pt;">Registered Office</td><td  style="font-family:Palatino LinoType;font-size:7pt;" width=10%>Tel</td><td style="font-family:Palatino LinoType;font-size:7pt;" width=30%>: #aTELNO#</td></tr>
				<tr><td style="font-family:Palatino LinoType;font-size:7pt;" width=60%>#vaADD1#</td><td style="font-family:Palatino LinoType;font-size:7pt;">Fax</td><td style="font-family:Palatino LinoType;font-size:7pt;">: #aFAXNO#</td></tr>
				<tr><td style="font-family:Palatino LinoType;font-size:7pt;" colspan=3>#vaADD2#</td></tr>
				<tr><td style="font-family:Palatino LinoType;font-size:7pt;" colspan=3>#vaPOSTCODE# #city#</td></tr>
				#TAXNo("TABLE","colspan=3","font-family:Palatino LinoType;font-size:7pt;")#
			</table>
		</td></tr>
		</table>
	<cfelseif iGCOID IS 44>
		<!--- Mitsui Sumitomo --->
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:80%;font-family:Trebuchet MS" align=center>
		<tr>
			<td colspan=4><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
			<cfif IsDefined("Attributes.DISPMODE") and Attributes.DISPMODE is 1>
				<td align="right">Version March 2017</td>
			<cfelseif IsDefined("Attributes.DISPMODE") and Attributes.DISPMODE is 2>
				<td align="right">Versi Mac 2017</td>
			<cfelseif IsDefined("Attributes.DISPMODE") and Attributes.DISPMODE is 3>
				<td>
					<b>MSIG Insurance (Malaysia) Bhd</b> (46983-W)<br>
					Head Office: Customer Service Center, Level 15,<br>
					Menara Hap Seng 2, Plaza Hap Seng, No. 1, Jalan P.Ramlee, 50250 Kuala Lumpur<br>
					Tel +603 2050 8228, Fax +603 2026 8086, Customer Service Hotline 1800 88 MSIG(6744)<br>
					<b>www.msig.com.my</b>
				</td>
			</cfif>
		</tr>
		#TAXNo("TABLE","colspan=4")#
		<!---><tr><td rowspan=5 width=30%><img SRC="#request.webroot#MSupport/logo/#cologo#"></td><td><span style="color:##191970;font-weight:bold">#vaCONAME#</span> <span style="font-size:80%">(#vaCOREGNO#)</span></td></tr>
		<CFIF Attributes.COID IS iGCOID><tr><td>Head Office: Customer Service Centre, Level 22</td></tr></CFIF>
		<tr><td><CFIF Attributes.COID IS iGCOID>Menara Weld<CFELSE>#HTMLEditFormat(vaADD1)#</cfif><CFIF vaADD2 IS NOT "">, #HTMLEditFormat(vaADD2)#</CFIF>, #HTMLEditFormat(vaPOSTCODE)# <cfif #Attributes.COID# IS 1409>Pulau Pinang<cfelseif #Attributes.COID# IS 1410>Melaka<cfelse>#HTMLEditFormat(city)#, #HTMLEditFormat(state)#</cfif>, Malaysia</td></tr>
		<tr><td>Tel: #aTELNO# &nbsp;&nbsp;Fax: #aFAXNO# &nbsp;&nbsp;Customer Service Hotline 1 800 88 MSIG (6744)</td></tr>
		<tr><td><span style="color:##FF0000">www.msig.com.my</span></td></tr>--->
		</table>
	<cfelseif iGCOID IS 46>
	    <!--- Oriental Capital / Tune --->
	    <table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:95%;font-size:90%" align="center" background="">
		    <tr><td align=right><img SRC="#request.webroot#MSupport/logo/MY-tune-v3.png"></td></tr>
		    #TAXNo("TABLE","colspan=4")#
		<!---><tr><td valign=top width=44%>
		    <table>
			   <tr><td><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
		    </table>
		    </td>
		    <td width=25%>
			<table>
			   <tr><td>#HTMLEditFormat(vaADD1)#</td></tr>
			   <cfif vaADD2 neq ""><tr><td>#HTMLEditFormat(vaADD2)#</td></tr></cfif>
			   <tr><td>#vaPOSTCODE# #city#</td></tr>
			   <tr><td>Malaysia</td></tr>
			</table>
			</td>
			<td width=42%>
			<table>
			   <cfif aTELNO neq ""><tr><td>Tel: 6#aTELNO#</td></tr></cfif>
			   <cfif aFAXNO neq ""><tr><td>Fax: 6#aFAXNO#</td></tr></cfif>
			   <cfif vaEMAIL neq ""><tr><td>Email: #vaEMAIL#</td></tr></cfif>
			   <tr><td>www.oricap.com.my</td></tr>
			</table>
			</td>
	   </tr>--->
	   </table>

	<cfelseif iGCOID IS 49>
		<!--- Axa Affin --->
		<cfif Attributes.LAYOUT IS 1><!--- old logo --->
			<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:95%;font-family:arial"  align="center" background="">
			<tr><td align=center><img SRC="#request.webroot#MSupport/logo/axa.gif"></td></tr>
			#TAXNo("TABLE","align=center")#
			</table>
		<cfelseif Attributes.LAYOUT IS 2><!--- old logo on the left --->
			<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:95%;font-family:arial"  align="center" background="">
			<tr><td align=left><img SRC="#request.webroot#MSupport/logo/axa.gif"></td></tr>
			#TAXNo("TABLE","align=center")#
			</table>
		<cfelseif Attributes.LAYOUT IS 3> <!--- 43555 Aisyah --->
			<!--- 32472 Atk --->
			<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%"  align="center" background="">
				<tr>
					<td valign="bottom" align=left><img SRC="#request.webroot#MSupport/logo/#hq_cologo#" width="70px"></td>
					<td valign="center" align=left width="42%" style="font-family:'Source Sans Pro';font-size:12px;line-height:100%;color: ##1d3168">
						<b>#htmleditformat(hq_vaconame)#</b>
						<span style="font-family:'Source Sans Pro';font-size:10px;line-height:115%;padding-bottom:1px">(#htmleditformat(hq_vacoregno)#)</span><br>
						<cfif hq_vaADD1 NEQ "">#HTMLEditFormat(hq_vaADD1)#<br></cfif>
						<cfif hq_vaADD2 NEQ "">#HTMLEditFormat(hq_vaADD2)#</cfif>
						<cfif hq_vaADD3 NEQ ""><br>#HTMLEditFormat(hq_vaADD3)#<br></cfif>
						<cfif hq_vaPOSTCODE NEQ "" OR hq_city NEQ "">#HTMLEditFormat(hq_vaPOSTCODE)# #HTMLEditFormat(hq_city)#<br></cfif>
						O #HTMLEditFormat(hq_aTELNO)#<br>
						F #HTMLEditFormat(hq_aFAXNO)#<br>
						E #HTMLEditFormat(hq_vaEMAIL)#<br>
						www.axa.com.my<br>
						Service Tax Reg. No.:#HTMLEditFormat(hq_vasvcregno)#
					</td>
				</tr>
			</table>
			<br><br>
		<cfelse><!--- default --->
			<!--- <table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:95%;font-family:arial"  align="center" background="">
			<tr><td align=center><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
			<!--- #TAXNo("TABLE","align=center")# --->
			</table> --->
			<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%"  align="center" background="">
				<tr>
					<td valign="bottom" align=left><img SRC="#request.webroot#MSupport/logo/#hq_cologo#" width="70px"></td>
				</tr>
			</table>
		</cfif>
	<cfelseif iGCOID IS 50>
		<!--- Jerneh --->
		<!--- Memo text added for #19202# --->
		<cfset thisstate=#TRIM(REReplace(REReplace(state,"\((.*?)\)","","ALL"),"Darul(.*?)\Z","","ALL"))#>
		<cfset thiscity=#TRIM(city)#>
		<cfif attributes.coid IS iGCOID><cfset thisadd1=#TRIM(REReplace(vaadd1,"(?i)12TH FLOOR,","","ALL"))#><cfelse><cfset thisadd1=#vaadd1#></cfif>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%"  align="center" background="">
		<tr>
			<td valign="top" align=left <cfif CHBMEMO EQ 1>width="30%"<cfelse>width="50%"</cfif>>
			<div>
			<img SRC="#request.webroot#MSupport/logo/chubb.gif" width="125px">
			</div>
			</td>
			<cfif CHBMEMO EQ 1><td valign="top" align=left width="20%"><span style="font-family:Georgia;font-size:30px">Memo</span></td></cfif>
			<td valign="top" align=left width="30%"<!--- width="150px" ---> style="font-family:Georgia;font-size:12px;line-height:120%"><!--- address --->
			#htmleditformat(vaconame)#
			<br><span style="font-family:Georgia;font-size:9px"><i><!---(#vaCOTAGLINE#)--->(formerly known as ACE Jerneh Insurance<br>Berhad)</i></span> <span style="font-family:Georgia;font-size:9px;line-height:115%;padding-bottom:1px">(#htmleditformat(vacoregno)#)</span><br>
			<cfif vaADD1 NEQ "">#HTMLEditFormat(thisadd1)#<br></cfif>
			<cfif vaADD2 NEQ "">#HTMLEditFormat(vaADD2)#<br></cfif>
			<cfif vaADD3 NEQ "">#HTMLEditFormat(vaADD3)#<br></cfif>
			<cfif vaPOSTCODE NEQ "" OR city NEQ "">#HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(thiscity)#<cfif attributes.coid IS iGCOID><br>Malaysia<cfelseif thiscity NEQ thisstate><cfif len(thiscity)+len(thisstate) GT 20><br><cfelse>, </cfif>#thisstate#</cfif></cfif>
			</td>
			<td valign="top" align=left width="20%" <!--- width="115px" ---> style="font-family:Georgia;font-size:12px;line-height:125%">
			O #HTMLEditFormat(aTELNO)#<br>
			F #HTMLEditFormat(aFAXNO)#<br>
			#TAXNo("HTML","","font-style:italic")#
			www.chubb.com/my
			</td>
		</tr>
		</table>
		<br><br><br><br>
	<cfelseif iGCOID IS 56>
		<!--- OUI --->
		<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 90%"  align="center" background="">
		<tr><td align="left" rowspan=5 witdh="5%"><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
		   <td align="left" witdh="95%" style="color=##663300">
		   <table border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 100%"  align="center" background="">
		   <tr><td align="left" style="font-size:170%;color=##663300"><b>#HTMLEditFormat(UCase(vaCONAME))#</b></td></tr>
           <tr><td align="center" style="font-size:72%;color=##663300"><b>(Incorporated in Malaysia #vaCOREGNO#)</b></td></tr>
		   <tr><td align="left" style="font-size:72%;color=##663300"><b>#HTMLEditFormat(vaADD1)#<cfif #vaADD2# IS NOT "">, #HTMLEditFormat(vaADD2)#</cfif>&nbsp;P.O. Box 12730, #HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(city)#, Malaysia.</b></td></tr>
		    <tr><td align="center" style="font-size:72%;color=##663300"><b>Tel #HTMLEditFormat(aTELNO)# Fax #HTMLEditFormat(aFAXNO)# Fax 03-20709046 (Marketing) Fax 03-20342378 (Finance)</b></td><tr></tr>
		    <tr><td align="left" style="font-size:72%;color=##663300"><b>Penang Tel 04-2273525 Fax 04-2273526 JB Tel 07-2234908 Fax 07-2234958 Kuching Tel 089-341133 Fax 082-341199</b></td></tr>
		    #TAXNo("TABLE","align=center","font-size:72%")#
		    </table>
		   </td>
		</table>
	<cfelseif iGCOID IS 57>
		<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 95%" align="center" background="">
		<tr><td width="35%" rowspan=6><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
		<td width="25%">&nbsp;</td>
		<td width="40%" align="left">
		<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 100%;font-family:arial narrow" align="center" background="">
        <tr style="font-size:120%" align="left"><td><b>#vaCONAME#</b></td><td>&nbsp;</td></tr>
        <tr style="font-size:95%" align="left"><td>Co.Reg (New) 198201011878 (Old: 91603-K)</td><td>&nbsp;</td></tr>
		<tr style="font-size:95%" align="left"><td>40-01, Q Sentral, 2A, Jalan Stesen Sentral 2,</td><td>&nbsp;</td></tr>
        <tr style="font-size:95%" align="left"><td>Kuala Lumpur Sentral, 50470 Kuala Lumpur, Malaysia.</td><td>&nbsp;</td></tr>
        <tr style="font-size:95%" align="left"><td>(P.O.Box 12490, 50780 Kuala Lumpur, Malaysia.)</td><td>&nbsp;</td></tr>
        <tr style="font-size:95%" align="left"><td>Tel: #request.ds.co[igcoid].TELNO# Fax: #request.ds.co[igcoid].FAXNO#</td><td>&nbsp;</td></tr>
        <tr style="font-size:95%" align="left"><td>Website: www.pacificinsurance.com.my</td><td>&nbsp;</td></tr>
		#TAXNo("TABLE","align=left","font-size:95%")#
        </table>
		</td>
		</table>
	<cfelseif iGCOID IS 58>
		<!--- PanGlobal Insurance --->
	<!---table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH:99%" align="center" background="">
	<tr><td valign=top width="35%" rowspan=6><IMG SRC="#request.webroot#MSupport/logo/#cologo#"></td>
	<td width="25%">&nbsp;</td>
	<td width="40%" align="left">
	<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial;font-size:100%" align="center" background="">
       <tr align="left"><td>PanGlobal Insurance Berhad (9538-M) </td><td>&nbsp;</td></tr>
	   <tr align="left"><td>Level 12B, Menara PanGlobal, No. 8, Lorong P. Ramlee,</td><td>&nbsp;</td></tr>
       <tr align="left"><td>P.O. Box 12448, 50778 Kuala Lumpur, Malaysia.</td><td>&nbsp;</td></tr>
       <tr align="left"><td>Tel: 03-2078 2090 Fax: 03-2026 7876</td><td>&nbsp;</td></tr>
	   <tr align="left"><td>Customer Service Call Centre: 1-800-88-1111</td><td>&nbsp;</td></tr>
       </table>
	</td>
	</tr>
	</TABLE--->
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:90%" align=center>
		<tr><td rowspan=5 width="58%" valign="top"><img SRC="#request.webroot#MSupport/logo/#cologo#"></td><td width="50%">#vaCONAME# (#vaCOREGNO#)</td></tr>
		<tr><td>Level 12B, Menara PanGlobal #HTMLEditFormat(vaADD2)#</td></tr>
		<tr><td>P.O Box 12448 #HTMLEditFormat(vaPOSTCODE)# #city#</td></tr>
		<tr><td>Tel: #aTELNO# &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Fax: #aFAXNO#</td></tr>
		<tr><td>First Contact Center: 1-800-88-1111</td></tr>
		#TAXNo("TABLE")#
		</table>
	<cfelseif iGCOID IS 61>
		<!--- Liberty Insurance --->
		<CFIF attributes.layout IS 1> <!--- Used in clmform-MNAllRisk --->
			<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:80%" align=center>
			<tr><td align=center><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
			<tr><td align=center><cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" FORMAT="HTML" NOCOREGNO=0 CONAMEATTR="style=color:black;text-align:center;font-size:200%" CONAME=#vaCONAME# COREGNO=#vaCOREGNO# ADD1=#vaADD1# ADD2=#vaADD2# POSTCODE=#vaPOSTCODE# CITYID=#iCITYID# TARGET="TWOLINE" SHOWCONTACTNO=1 TELNO=#aTELNO# FAXNO=#aFAXNO# WEBSITE="www.libertyinsurance.com.my" ADDSEPARATOR="" AFTERADDSEPARATOR="</br>" SKIPCONTACTSEPARATOR=1></td></tr>
			</table>
		<CFELSEIF attributes.layout IS 2>
			<table id=COHEADER cellPadding=0 cellSpacing=0 style="WIDTH:100%;" align=center border=0>
			<tr><td><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
			<td><cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" FORMAT="HTML" NOCOREGNO=0 CONAMEATTR="style=color:black;text-align:left;font-size:200%;font-weight:bold" CONAME=#vaCONAME# COREGNO=#vaCOREGNO# ADD1=#vaADD1# ADD2=#vaADD2# POSTCODE=#vaPOSTCODE# CITYID=#iCITYID# TARGET="TWOLINE" SHOWCONTACTNO=1 TELNO=#aTELNO# FAXNO=#aFAXNO# WEBSITE="www.libertyinsurance.com.my" ADDSEPARATOR="" AFTERADDSEPARATOR="</br>" SKIPCONTACTSEPARATOR=1></td></tr>
			</table>
		<CFELSEIF attributes.layout IS 3>
            <cfoutput>
			<table id=COHEADER cellPadding=0 cellSpacing=0 style="WIDTH:100%;" align=center border=0>
			<tr><td colspan=2><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
			<tr><td colspan=2><br></td></tr>
            <tr> <td colspan=2> <b>LIBERTY INSURANCE BERHAD</b> (#vacoregno#) </td> </tr>
<!---
            <tr> <td colspan=2> (formerly known as Uni. Asia General Insurance Berhad) </td> </tr>
--->
            <tr> <td colspan=2> #vaadd1# #vaadd2# #vaadd3# #vapostcode# #Request.DS.CITIES[icityid]#</td> </tr>
            <tr> <td colspan=2> #taxno(type="html",span="",brFront="no",brEnd="no")# </td> </tr>
            <tr> <td colspan=2> Tel:#atelno# FAX: #afaxno# Website: www.libertyinsurance.com.my</td> </tr>
            </cfoutput>
			</table>

		<CFELSE> <!--- Default --->
			<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:80%" align=center>
			<tr><td align=right><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
			<!---<tr style=line-height:50%><td>&nbsp;</td></tr>
			<tr><td align=center><span style="font-weight:bold;font-size:140%">#HTMLEditFormat(vaCONAME)#</span> (#vaCOREGNO#)</td></tr>
			<tr><td align=center style="font-style:italic">(formerly known as South East Asia Insurance Berhad)</td></tr>
			<tr><td align=center>#HTMLEditFormat(vaADD1)#, #HTMLEditFormat(vaADD2)#, #vaPOSTCODE# #city#, Malaysia.<cfif #Attributes.COID# IS 61> P.O. Box 6120 Pudu, 55916 Kuala Lumpur</cfif></td></tr>
			<tr><td align=center>Tel: #aTELNO# &nbsp;Fax: #aFAXNO# &nbsp;<b>www.uniasiageneral.com.my</b> a DRB-HICOM & UOB company</td></tr>
			--->
			</table>
		</CFIF>
	<cfelseif (iGCOID IS 64 OR iGCOID IS 54)>
		<!--- Tokio Marine --->
		<!--- new header disable for now --->
		<!--- #35723 --->

		<cfif attributes.layout IS 1>
			<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;margin-top:23px;" align="center" background="">
			<tr>
				<td align=right><img SRC="#request.webroot#MSupport/logo/TMG2.jpg" ></td>
			</tr>
			</table>

			<cfif ATTRIBUTES.NOWATERMARK EQ 0>
				<CFMODULE TEMPLATE="#Request.LOGPATH#CustomTags\watermark.cfm" COID=#iGCOID#>
			</cfif>
		<cfelseif attributes.layout IS 2>
			<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
			<tr>
				<td align=left valign=top><img SRC="#request.webroot#MSupport/logo/TMG3.jpg"></td>
				<td align=right><img SRC="#request.webroot#MSupport/logo/TMG2.jpg" ></td>
			</tr>
			</table>

			<cfif ATTRIBUTES.NOWATERMARK EQ 0>
				<CFMODULE TEMPLATE="#Request.LOGPATH#CustomTags\watermark.cfm" COID=#iGCOID#>
			</cfif>
		<cfelse>
			<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;margin-top:23px;" align="center" background="">
			<tr>
				<td align=left valign=top><img SRC="#request.webroot#MSupport/logo/TMG3.jpg"></td>
				<td align=right><img SRC="#request.webroot#MSupport/logo/TMG2.jpg" ></td>
			</tr>
			</table>

			<cfif ATTRIBUTES.NOWATERMARK EQ 0>
				<CFMODULE TEMPLATE="#Request.LOGPATH#CustomTags\watermark.cfm" COID=#iGCOID#>
			</cfif>
		</cfif>

		<!--- 	<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%" align="center" background="">
			<tr><td align=left><table><tr><td><img SRC="#request.webroot#MSupport/logo/tokio_olympic.gif"></td><td><span style="font-size:75%">Official Insurance Partner of</span><br/><b style="font-size:90%">Olympic Council of Malaysia</b></td></tr></table></td>
			<td align=right><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>

			<tr><td colspan=2>&nbsp;</td><td align="right" rowspan=10><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
	 		<tr style="font-size:100%;font-family:arial narrow"><td width="45%">&nbsp;</td><td valign="top"><b>TOKIO MARINE</b><br><b>INSURANS (MALAYSIA) BERHAD</b> (Co. No. #vaCOREGNO#)</td></tr>
			<tr><td colspan=2>&nbsp;</td></tr>
			<tr style="font-size:75%"><td>&nbsp;</td><td>#HTMLEditFormat(vaADD1)#</td></tr>
			<tr style="font-size:75%"><td>&nbsp;</td><td>#HTMLEditFormat(vaADD2)#</td></tr>
			<tr style="font-size:75%"><td>&nbsp;</td><td>#vaPOSTCODE# #city#, Malaysia</td></tr>
			<tr style="font-size:75%"><td>&nbsp;</td><td>Tel No : #aTELNO#</td></tr>
			<tr style="font-size:75%"><td>&nbsp;</td><td>Fax No : #aFAXNO#</td></tr>
			<tr style="font-size:75%"><td>&nbsp;</td><td>Website : www.tokiomarine.com.my</td></tr>
			</table> --->


	<cfelseif iGCOID IS 67>
		<!--- 39391 --->
		<!--- 
			Layout 0 : Default
			Layout 1 : E-Payment Form (Offer Letter/DV)
		 --->
		<cfif Attributes.layout EQ 0>
			<!--- RHB Insurance --->
			<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:75%" align=center>
			<tr><td><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
			<cfif LEFT(CLAIMTYPE,2) IS "NM"><!--- #45173 --->
				<tr><td>&nbsp;</td></tr>
				<tr><td>&nbsp;</td></tr>
				<tr><td>&nbsp;</td></tr>
			</cfif>			
			<!--- <tr><td><b><span style="font-size:110%">#HTMLEditFormat(vaCONAME)#</span></b> <span style="font-size:70%">&nbsp;(#vaCOREGNO#)</span></td></tr>--->
			<tr>
				<td>#HTMLEditFormat(vaADD1)# <CFIF vaADD2 IS NOT "">#HTMLEditFormat(vaADD2)#</CFIF> #vaPOSTCODE# #city#.
				</td>
			</tr>
			<tr>
				<td nowrap>Customer Relationship Centre: 1300 220 007, WhatsApp: 012-6031978, Email: rhbi.general@rhbgroup.com</td>
			</tr>
			<!---<tr><td><b>TEL #aTELNO# &nbsp;&nbsp; FAX <CFIF iGCOID EQ iCOID AND LEFT(CLAIMTYPE,2) EQ "NM">03-9281 2729<CFELSE>#aFAXNO#</CFIF></b></td></tr>
			#TAXNo("TABLE","","font-weight:bold")#
			--->
			<!---<tr><td align=right>#HTMLEditFormat(vaADD1)#</td></tr>
			<tr><td align=right>#HTMLEditFormat(vaADD2)#</td></tr>
			<tr><td align=right>P.O.Box 10835</td></tr>
			<tr><td align=right>#vaPOSTCODE# #city#</td></tr>
			<tr><td align=right>Tel : #aTELNO#</td></tr>
			<tr><td align=right>Fax (General) : 03-92812729</td></tr>
			<tr><td align=right>Fax (Claims Dept) : 03-92812729</td></tr>
			<tr><td align=right>(Pause 403)</td></tr>
			<tr><td align=right>Fax (RI Dept) : 03-92812729</td></tr>
			<tr><td align=right>(Pause 374)</td></tr>
			<tr><td align=right>Website: www.rhbinsurance.com.my</td></tr>--->
			</table>
		<cfelseif Attributes.layout EQ 1>
			<!--- RHB Insurance --->
			<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:75%" align=center>
				<tr><td style="font-size: 20px;font-weight: bold;"><img  SRC="#request.webroot#MSupport/logo/rhbinsurance.gif">&nbsp;&nbsp;&nbsp;RHB INSURANCE BHD (38000-U)</td></tr>
			</table>
		</cfif>
		<!--- 39391 --->
	<cfelseif iGCOID IS 69 OR iGCOID IS 74>
		<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH:90%" align="center" background="">
			<tr><td align="right"><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr><tr></tr><tr></tr></tr><tr></tr>
		</table>
	<cfelseif iGCOID IS 70>
		<!--- MAA --->
		<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 100%" align="center" background="">
		<tr><td align="center"><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
	 	<!--- tr><td align="center" style="font-size:medium; text-transform: uppercase"><b>#HTMLEditFormat(vaCONAME)# <cfif #vaCOREGNO# IS NOT ""><span style="font-size:50%">&nbsp;(#vaCOREGNO#)</span></cfif></b></td></tr --->
		<!--- tr class=clsSmallRow><td align="center" style="font-size:70%">#HTMLEditFormat(vaADD1)#<cfif #vaADD2# IS NOT "">, #HTMLEditFormat(vaADD2)#</cfif>,&nbsp;#HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(city)# </td></tr>
		<tr class=clsSmallRow><td align="center" style="font-size:70%">Tel:&nbsp;#HTMLEditFormat(aTELNO)#/9000&nbsp;<cfif #aFAXNO# IS NOT "">Fax No:&nbsp;#HTMLEditFormat(aFAXNO)#/21433642</cfif> Home page : http://www.maa.com.my </td></tr --->
		<!----><tr><td>
		<table border="0" cellPadding="0" cellSpacing="1" style="WIDTH:100%" align="center">
		<!--- tr><td align="center" style="font-family:arial black"><span style="font-size:170%">MALAYSIAN ASSURANCE ALLIANCE BERHAD </span><span style="font-size:100%">(8029-A)</span></td></tr --->
	 	<!--- tr class=clsEndRow><td style=font-size:70% align=center><span style="font-weight:bold">Head Office/Pen. M'sia:</span> Menara MAA, 11th Floor, 12, Jalan Dewan Bahasa, 50460 Kuala Lumpur. Tel: 03-21468000 Fax: 03-21425863 Call Centre : 2-300-88-8622</td></tr>
		<tr class=clsEndRow><td style=font-size:70% align=center><span style="font-weight:bold">Sabah:</span> Menara MAA, No 6, Lorong Api-Api 1, 88000 Kota Kinabalu, Sabah. Tel: 088-218000 Fax: 088-217763</td></tr>
		<tr class=clsEndRow><td style=font-size:70% align=center><span style="font-weight:bold">Sarawak:</span> Menara MAA, Level 8, Lot 86, Section 53, Jalan Ban Hock/Central Timur, 93300 Kuching, Sarawak. Tel: 082-233232 Fax: 082-429070</td></tr --->

		<tr class=clsSmallRow><td align="center" style="font-size:70%">#HTMLEditFormat(vaADD1)#<cfif #vaADD2# IS NOT "">, #HTMLEditFormat(vaADD2)#</cfif>,&nbsp;#HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(city)# </td></tr>
		<tr class=clsSmallRow><td align="center" style="font-size:70%">Tel:&nbsp;#HTMLEditFormat(aTELNO)#/9000&nbsp;<cfif #aFAXNO# IS NOT "">Fax No:&nbsp;#HTMLEditFormat(aFAXNO)#/21433642</cfif> Home page : http://www.maa.com.my </td></tr>

		</table>
		</td></tr>---->
 		</table>
	<cfelseif iGCOID IS 72>
		<!--- Syarikat Takaful --->
		<CFIF ATTRIBUTES.layout EQ 0 OR ATTRIBUTES.layout EQ 1>

		<div style="margin-left: 40px;margin-right: 40px;">
			<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" width=100% align="center">
				<tr><td align="center"><IMG SRC="#request.webroot#MSupport/logo/STMB_header.png" style="width:680px; height:70px;"></tr>
				<tr>
					<td valign=top align="center">
						<table border="0" cellPadding="0" cellSpacing="0" width=100%>
							<colgroup><col style="width:12.5%"><col style="width:63.5%"><col style="width:24%"></colgroup>
							<tr>
								<td style="font-family:Arial;font-size:6.5pt;" align=left><b>HEAD OFFICE:</b></td>
								<td align=left>
									<table border="0" cellPadding="0" cellSpacing="0" width=100% style="font-size:7.5pt;">
										<tr>
											<td style="font-family:Arial;" align=left><b>#vaconame#</b><span style="font-size:90%"> [#vacoregno#(#vaCOREGNO_OLD#)]</span></td>
										</tr>
										<tr>
											<td style="font-family:Arial;" align=left>#vaadd1# Menara Takaful Malaysia</td>
										</tr>
										<tr><td>No. 4, Jalan Sultan Sulaiman, 50000 Kuala Lumpur</td></tr>
										<tr><td colspan=2>P.O.Box 11483, 50746 Kuala Lumpur</td></tr>
										<tr><td colspan=2>#TAXNo("HTML","","font-weight:bold")#</td></tr>
									</table>
								</td>
								<td align=left style="font-size:7.5pt;"><b>E</b>&nbsp;<span>csu@takaful-malaysia.com.my</span></td>
							</tr>
						</table>
					</td>
				</tr>
			</table><br>
		</div>
		
		<!--- <CFELSEIF ATTRIBUTES.LAYOUT EQ 1>

		<div style="margin-left: 40px;margin-right: 40px;">
			<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" width=100% align="center">
				<tr><td align="center"><IMG SRC="#request.webroot#MSupport/logo/STMB_header.png" style="width:680px; height:70px;"></tr>
				<tr>
					<td valign=top align="center">
						<table border="0" cellPadding="0" cellSpacing="0" width=100%>
							<colgroup><col style="width:12.5%"><col style="width:63.5%"><col style="width:24%"></colgroup>
							<tr>
								<td style="font-family:Arial;font-size:6.5pt;" align=left><b>HEAD OFFICE/<br>IBU PEJABAT:</b></td>
								<td align=left>
									<table border="0" cellPadding="0" cellSpacing="0" width=100% style="font-size:7.5pt;">
										<tr>
											<td style="font-family:Arial;" align=left><b>#vaconame#</b><span style="font-size:90%"> [#vacoregno#(#vaCOREGNO_OLD#)]</span></td>
										</tr>
										<tr>
											<td style="font-family:Arial;" align=left>#vaadd1# Menara Takaful Malaysia</td>
										</tr>
										<tr><td>No. 4, Jalan Sultan Sulaiman, 50000 Kuala Lumpur</td></tr>
										<tr><td colspan=2>P.O.Box 11483, 50746 Kuala Lumpur</td></tr>
										<tr><td colspan=2>#TAXNo("HTML","","font-weight:bold")#</td></tr>
									</table>
								</td>
								<td align=left style="font-size:7.5pt;">
									<b>W</b>&nbsp;<span> takaful-malaysia.com.my</span><br>
									<b>T</b>&nbsp;<span> 1-300 88 252 385</span><br>
									<b>F</b>&nbsp;<span> 603-2274 0237</span><br>
									<b>E</b>&nbsp;<span>csu@takaful-malaysia.com.my</span>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table><br>
		</div> --->

		</CFIF>
	<!---CFELSEIF iGCOID IS 74--->
		<!--- Tahan --->
		<!--- Uses default logo --->
	<cfelseif iGCOID IS 7651 AND (Attributes.COID IS 76 or Attributes.COID IS 51)>
		<!--- AmAssurance --->
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%" align=center>
			<tr><td><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
		</table>
	<cfelseif iGCOID IS 77>
		<!--- AIA --->
		<!--- old --->
		<!---><table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-family:arial;font-size:7.5pt" align=center>
			<tr><td align=left rowspan=9 valign=top><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
				<td width=250px><b><span>#vaCONAME#</span></b><cfif #vaCOREGNO# IS NOT "">&nbsp;<span style="font-size:80%">(#vaCOREGNO#)</span></cfif></td></tr>
			<tr style="line-height:50%"><td>&nbsp;</td></tr>
			<tr><td>Menara AIA, 99 Jalan Ampang</td></tr>
			<tr><td>50450 Kuala Lumpur</td></tr>
			<tr><td>P.O.Box 10140</td></tr>
			<tr><td>50704 Kuala Lumpur</td></tr>
			<tr><td>General line : 03-20561111</td></tr>
			<!---><tr><td>T : #aTELNO#</td></tr>
			<tr><td>F : #aFAXNO#</td></tr>--->
			<tr style="line-height:50%"><td>&nbsp;</td></tr>
			<tr><td>AIA.COM.MY</td></tr>
			<tr><td><br><br><br>&nbsp;</td></tr>
		</table>--->
		<!--- new --->
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-family:arial;font-size:7.5pt" align=center>
			<tr><td align=left rowspan=11 valign=top><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
				<td width=260px><b><span>#vaCONAME#</span></b><cfif #vaCOREGNO# IS NOT "">&nbsp;<span style="font-size:7.0pt">(#vaCOREGNO#)</span></cfif></td></tr>
			<tr style="line-height:50%"><td>&nbsp;</td></tr>
			<tr><td>#vaADD1# #vaADD2#</td></tr>
			<tr><td>#vaPOSTCODE# #CITY#</td></tr>
			<tr><td>T: #HTMLEditFormat(Trim(aTELNO))#</td></tr>
			#TAXNo("TABLE")#
			<tr style="line-height:50%"><td>&nbsp;</td></tr>
			<tr><td>AIA.COM.MY</td></tr>
			<tr><td>&nbsp;</td></tr>
		</table>
	<!----<cfelseif iGCOID IS 78>
		<!--- Takaful Nasional --->
		<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 100%" align="center" background="">
			<tr><td rowspan=8><img SRC="#request.webroot#MSupport/logo/#cologo#"></td><td align="right" style="font-size:90%"><b>#vaCONAME#<cfif #vaCOREGNO# IS NOT "">&nbsp;(#vaCOREGNO#)</cfif> </b></td></tr>
	 		<CFIF vaCOTAGLINE IS NOT ""><tr><td align="right" style="font-size:80%">#vaCOTAGLINE#</td></tr></CFIF>
			<tr><td align="right" style="font-size:80%">#vaADD1#</td></tr>
			<cfif #vaADD2# IS NOT ""><tr><td align="right" style="font-size:80%">#vaADD2#</cfif></td></tr>
 		    <tr><td align="right" style="font-size:80%">#HTMLEditFormat(vaPOSTCODE)# #city#</td></tr>
		    <tr><td>&nbsp;</td></tr>
		    <tr><td align="right" style="font-size:80%">Telephone:&nbsp;#HTMLEditFormat(aTELNO)#</td></tr>
			<cfif #aFAXNO# IS NOT ""><tr><td align="right" style="font-size:80%">Facsimile:&nbsp;#HTMLEditFormat(aFAXNO)#</td></tr></cfif>
		</table>---->
<!--- 	<cfelseif iGCOID IS 152>
		<!--- EP Ong --->
		<div id=COHEADER align=center style=width:100%>
		<span class=clsRptSubTitle style=color:blue>#HTMLEditFormat(UCase(vaCONAME))#<cfif vaCOREGNO IS NOT ""> <span style="font-size:50%;color:black">(#HTMLEditFormat(UCase(vaCOREGNO))#)</span></cfif></span>
		</div> --->
	<!---cfelseif iGCOID IS 293>
	<!--- Wellesley --->
	<table id=COHEADER width=100% cellPadding="1" cellSpacing="1" >
		<tr><td><img SRC="#request.webroot#MSupport/logo/wellesley.gif"></td><td align=right><img SRC="#request.webroot#MSupport/logo/honda.gif"></td></tr>
	</table>--->

	<cfelseif iGCOID IS 335>
		<!--- Show HQ address for all branches as well - 14 May 09 --->

		<table id=COHEADER width=100% cellPadding="1" cellSpacing="1" >
		<tr><td width=7%>
		    <table><tr><td width=80% rowspan=4><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr></table>
		    </td>
			<td width=93%>
			<table>
			<tr>
			    <td width=78% style="text-transform:uppercase; border-bottom:1px solid black">
				<b><span style="font-size:160%;color:black">#HTMLEditFormat(vaCONAME)#</span></b><cfif vaCOREGNO IS NOT ""> <span style="font-size:70%;color:black">(#HTMLEditFormat(vaCOREGNO)#)</span></cfif>
				</td>
				<td width=13% style="border-bottom:1px solid black"><cfif TRIM(aTELNO) neq ""><span style="font-size:70%;color:black">Tel: #HTMLEditFormat(Trim(aTELNO))#</span></cfif></td>
			    <td width=2%>&nbsp;</td>
			</tr>
			<tr>
			   <td><cfif vaADD1 IS NOT ""><span style="font-size:70%;color:black">#HTMLEditFormat(vaADD1)#,</cfif><cfif vaADD2 IS NOT ""> #HTMLEditFormat(vaADD2)#,</cfif> #Trim(vaPOSTCODE)# #CITY#</span></td>
			   <td><cfif Trim(aFAXNO) IS NOT ""><span style="font-size:70%;color:black">Fax: #HTMLEditFormat(Trim(aFAXNO))#</cfif></span></td>
		       <td>&nbsp;</td>
			</tr>
			#TAXNo("TABLE","colspan=3")#
			<cfif iCOID IS 335><!---Wan & Ahmad Adjuster HQ--->
			<tr style="line-height:19px">
			   <td colspan="3" valign="bottom"><span style="font-size:70%;color:black"><!---Branches:  PENANG  IPOH   MALACCA  KUANTAN  K.TERENGGANU  KOTA BHARU  KOTA KINABALU--->Email Address: #HTMLEditFormat(vaEMAIL)#</span></td>
			</tr>
			<cfelse><!---Wan & Ahmad Adjuster branches--->
			<tr valign="bottom" style="line-height:19px">
			   <cfquery name=q_hqco DATASOURCE=#Request.MTRDSN#>
               SELECT a.vaADD1,a.vaADD2,a.vaPOSTCODE,a.aTELNO,a.aFAXNO,
		       CITY=b.vaDESC,STATE=c.vaDESC, a.vaEMAIL
               FROM SEC0005 a WITH (NOLOCK),SYS0003 b WITH (NOLOCK),SYS0002 c WITH (NOLOCK)
               WHERE a.iCOID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iGCOID#">  AND a.iPCOID=0 AND a.iCITYID=b.iCITYID AND b.iSTATEID=c.iSTATEID
               </cfquery>
			   <td colspan="3" style="text-transform:uppercase"><span style="font-size:80%;color:black">
			   Head Office:
			   <cfloop query="q_hqco"><span style="font-size:80%;color:black">
			   <cfif vaADD1 IS NOT "">#HTMLEditFormat(vaADD1)#,</cfif><cfif vaADD2 IS NOT ""> #HTMLEditFormat(vaADD2)#,</cfif> #Trim(vaPOSTCODE)# #CITY#.
			   &nbsp;&nbsp;<cfif TRIM(aTELNO) neq "">Tel: #HTMLEditFormat(Trim(aTELNO))#</cfif>
			   &nbsp;&nbsp;<cfif Trim(aFAXNO) IS NOT "">Fax: #HTMLEditFormat(Trim(aFAXNO))#</cfif>
			   </cfloop></span></td>
			</tr>
			</cfif>
			</table>
			</td>
	    </tr>
		</table>
	<cfelseif iGCOID IS 368>
		<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 95%" align="center" background="">
		<tr><td width="35%" rowspan=6><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
		<td width="25%">&nbsp;</td>
		<td width="40%">
			<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="display:inline;WIDTH: 100%;font-family:arial narrow" align="center">
	        <tr style="font-size:120%" align="left"><td><b>The Pacific Insurance Bhd</b> <span style="font-size:80%">(91603-K)</span></td></tr>
			<!--- tr style="font-size:95%" align="left" style="letter-spacing:5px"><td>????????????</td><td>&nbsp;</td></tr --->
			<tr><td><img SRC="#request.webroot#MSupport/logo/pacific_chco.gif"></td></tr>
			<!---cfif Attributes.LAYOUT IS 1--->
			<tr style="font-size:95%" align="left"><td>40-01, Q Sentral 2A, Jalan Stesen Sentral 2, Kuala Lumpur Sentral</td><td>&nbsp;</td></tr>
       		<tr style="font-size:95%" align="left"><td>P.O. Box 12490, 50470 Kuala Lumpur, Malaysia.</td><td>&nbsp;</td></tr>
	        <tr style="font-size:95%" align="left"><td>Tel: #request.ds.co[57].TELNO# Fax: #request.ds.co[57].faxno#</td></tr>
	        <tr style="font-size:95%" align="left"><td>Website: www.pacificinsurance.com.my</td></tr>
			<!---cfelse>
			<tr style="font-size:95%" align="left"><td><cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" NOCOREGNO=0 CONAMEATTR="style=color:darkred;text-align:left;font-size:160%" ADD1=#vaADD1# ADD2=#vaADD2# POSTCODE=#vaPOSTCODE# CITYID=#iCITYID#></td></tr>
			<tr style="font-size:95%" align="left"><td>Tel: #HTMLEditFormat(Trim(aTELNO))# <cfif aFAXNO NEQ "">Fax: #HTMLEditFormat(Trim(aFAXNO))#</cfif></td></tr>
	        <tr style="font-size:95%" align="left"><td>Website: www.pacificinsurance.com.my</td></tr>
			</cfif--->
	        </table>
	        #TAXNo("TABLE","align=left","font-size:95%")#
		</td>
		</tr>
		</table>
		<!--- MCIS Zurich --->
		<!--- <div id=COHEADER style=width:100% align=center><img SRC="#request.webroot#MSupport/logo/#cologo#">
		</div> --->
	<cfelseif iGCOID IS 393>
		<!--- Auto consultant --->
		<div id=COHEADER style="width:100%;clear:both;" align="center"><table cellspacing=1 cellpadding=1 border=0 width="100%" align="center">
		<tr><td align="center">
		<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" NOCOREGNO=0 CONAMEATTR="style=color:darkred;text-align:left;font-size:160%" CONAME=#vaCONAME# COREGNO=#vaCOREGNO# COTAGLINE=#vaCOTAGLINE# ADD1=#vaADD1# ADD2=#vaADD2# POSTCODE=#vaPOSTCODE# CITYID=#iCITYID#><br>
		<cfif Trim(aTELNO) IS NOT "">Tel: #HTMLEditFormat(Trim(aTELNO))#</cfif><cfif Trim(aFAXNO) IS NOT "">&nbsp;&nbsp;Fax: #HTMLEditFormat(Trim(aFAXNO))#</cfif>
		<cfif Trim(vaEMAIL) IS NOT "">&nbsp;&nbsp;Email: #HTMLEditFormat(Trim(vaEMAIL))#</cfif>
		#TAXNo("HTML","","","YES")#
		</td></tr>
		</table>
		</div>

		<!--- <tr><td align="center">#fAddrOut(q_co)#</td></tr> --->
		<!--- <div id=COHEADER align=center style=font-size:medium;width:100%><b>#ucase(vaconame)#</b></div> --->
		<!--- <table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial"  align="center" background="">
		<tr><td  style="font-size:170%;color:darkred;text-align:center"><b>#ucase(vaconame)#</b></td></tr>
		<tr>
			<td style=font-size:medium;width:100%;text-align:center>
				#HTMLEditFormat(vaADD1)#<cfif vaADD2 NEQ ""><br/>#HTMLEditFormat(vaADD2)#</cfif><cfif vaADD3 NEQ ""><br/>#HTMLEditFormat(vaADD3)#</cfif>
				<cfif vaPOSTCODE NEQ ""><br/>#HTMLEditFormat(vaPOSTCODE)# #TRIM(city)#</cfif>
			</td>
		</tr>
		<tr><td style=font-size:medium;width:100%;text-align:center>
			<cfif TRIM(aTELNO) neq "">Tel: #HTMLEditFormat(Trim(aTELNO))#</cfif>&nbsp;<cfif Trim(aFAXNO) IS NOT "">Fax: #HTMLEditFormat(Trim(aFAXNO))#</cfif>&nbsp;<cfif vaEMAIL IS NOT "">Email: #HTMLEditFormat(vaEMAIL)#</cfif>
		</td></tr>
		</table> --->
	<cfelseif iGCOID IS 415>
		<!--- ACE Synergy --->
		<cfset thisstate=#TRIM(REReplace(REReplace(state,"\((.*?)\)","","ALL"),"Darul(.*?)\Z","","ALL"))#>
		<cfset thiscity=#TRIM(city)#>
		<cfif attributes.coid IS iGCOID><cfset thisadd1=#TRIM(REReplace(vaadd1,"(?i)12TH FLOOR,","","ALL"))#><cfelse><cfset thisadd1=#vaadd1#></cfif>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%"  align="center" background="">
		<tr>
			<td valign="top" align=left width="50%">
			<div>
			<img SRC="#request.webroot#MSupport/logo/chubb.gif" width="125px">
			</div>
			</td>
			<td valign="top" align=left width="30%"<!--- width="150px" ---> style="font-family:Georgia;font-size:12px;line-height:120%"><!--- address --->
			#htmleditformat(vaconame)#
			<br><span style="font-family:Georgia;font-size:9px"><i><!---(#vaCOTAGLINE#)--->(formerly known as ACE Jerneh Insurance<br>Berhad)</i></span> <span style="font-family:Georgia;font-size:9px;line-height:115%;padding-bottom:1px">(#htmleditformat(vacoregno)#)</span><br>
			<cfif vaADD1 NEQ "">#HTMLEditFormat(thisadd1)#<br></cfif>
			<cfif vaADD2 NEQ "">#HTMLEditFormat(vaADD2)#<br></cfif>
			<cfif vaADD3 NEQ "">#HTMLEditFormat(vaADD3)#<br></cfif>
			<cfif vaPOSTCODE NEQ "" OR city NEQ "">#HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(thiscity)#<cfif attributes.coid IS iGCOID><br>Malaysia<cfelseif thiscity NEQ thisstate><cfif len(thiscity)+len(thisstate) GT 20><br><cfelse>, </cfif>#thisstate#</cfif></cfif>
			</td>
			<td valign="top" align=left width="20%" <!--- width="115px" ---> style="font-family:Georgia;font-size:12px;line-height:125%">
			O #HTMLEditFormat(aTELNO)#<br>
			F #HTMLEditFormat(aFAXNO)#<br>
			#TAXNo("HTML","","font-style:italic")#
			www.chubb.com/my
			</td>
		</tr>
		</table>
		<br><br><br><br>
	<cfelseif iGCOID IS	519>
		<!--- Naza Kia ---> <!--- NTSERVER1: 654 Live: 519 --->
		<table id=COHEADER style="WIDTH:100%" align=center border=0 cellPadding=0 cellSpacing=0>
		<tr><td align=center><img SRC="#request.webroot#MSupport/logo/naza.gif">
		</td>
		<td align="center">
		<span class=clsRptSubTitle style=color:black>#HTMLEditFormat(UCase(vaCONAME))#</span><br>
		<cfif Trim(vaCOTAGLINE) IS NOT ""><span class=clsCoTagLine style=font-size:90%>#HTMLEditFormat(vaCOTAGLINE)#</span><br></cfif>
		<cfif Trim(vaCOREGNO) IS NOT "">(Co.No. #HTMLEditFormat(vaCOREGNO)#)<br></cfif>
		Central Parts and Service Centre<br>
		<cfif Trim(vaADD1) IS NOT "">#HTMLEditFormat(vaADD1)#,</cfif><cfif Trim(vaADD2) IS NOT ""> #HTMLEditFormat(vaADD2)#,</cfif><br>
		#Trim(vaPOSTCODE)# #CITY#, #STATE#<br>
		<cfif Trim(aTELNO) IS NOT "">Tel: #HTMLEditFormat(Trim(aTELNO))#</cfif><cfif Trim(aFAXNO) IS NOT "">&nbsp;&nbsp;Fax: #HTMLEditFormat(Trim(aFAXNO))#</cfif>
		#TAXNo("HTML","","","YES")#
		</td>
		<td align=center><img SRC="#request.webroot#MSupport/logo/kiamotors.gif">
		</td></tr>
		</table>
	<cfelseif iGCOID IS 594>
		<!--- Century and Branches --->
		<table id=COHEADER width=100%>
		<tr><td style=text-transform:uppercase><b>#HTMLEditFormat(vaCONAME)#<cfif vaCOREGNO IS NOT ""> <span style="font-size:70%;color:black">(#HTMLEditFormat(vaCOREGNO)#)</span></cfif></b><br>
		<cfif vaADD1 IS NOT "">#HTMLEditFormat(vaADD1)#,</cfif><cfif vaADD2 IS NOT ""> #HTMLEditFormat(vaADD2)#,</cfif> #Trim(vaPOSTCODE)# #CITY#, Malaysia<br>
		<cfif Trim(aTELNO) IS NOT "">Tel: #HTMLEditFormat(Trim(aTELNO))#</b></cfif><cfif Trim(aFAXNO) IS NOT "">&nbsp;&nbsp;Fax: #HTMLEditFormat(Trim(aFAXNO))#</cfif>
		<cfif Trim(vaEMAIL) IS NOT "">&nbsp;&nbsp;Email: #HTMLEditFormat(Trim(vaEMAIL))#</b></cfif>
		#TAXNo("HTML","","","YES")#
		</td><td width=20% align=right><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr></table>
	<cfelseif iGCOID IS	650> <!---NTSERVER: 693 LIVE:650--->
		<!---Perodua--->
		<table id=COHEADER style="WIDTH:100%" align=center border=0 cellPadding=0 cellSpacing=0>
		<tr><td rowspan=6 width=40%><img SRC="#request.webroot#MSupport/logo/perodua2.gif">
		</td>
		<td align=right style="font-style: italic; font-size: 110%; font-weight: bold">#HTMLEditFormat(UCase(vaCONAME))#&nbsp;<font size="-3">(#HTMLEditFormat(vaCOREGNO)#)</font></td>
		<CFIF iPCOID NEQ 38668><!--- Do not display for B&P branches --->
		<tr align=right><td>(wholly owned subsidiary of PERUSAHAAN OTOMOBIL KEDUA SDN BHD)</td></tr>
		</CFIF>
		<tr align=right><td>Perodua Automotive Centre,</td></tr>
		<tr align=right><td><cfif vaADD1 neq "">#HTMLEditFormat(vaADD1)#</cfif><cfif vaADD2 neq "">, #HTMLEditFormat(vaADD2)#</cfif></td></tr>
		<tr align=right><td>#Trim(vaPOSTCODE)#,&nbsp;#HTMLEditFormat(CITY)#,&nbsp;#HTMLEditFormat(STATE)#,&nbsp;Malaysia</td></tr>
		<cfif aTELNO neq "" or aFAXNO neq "">
		<tr align=right><td><cfif aTELNO neq "">Tel: 6#HTMLEditFormat(aTELNO)#<cfif aFAXNO neq "">&nbsp;Fax: 6#HTMLEditFormat(aFAXNO)#</cfif><cfelse>&nbsp;</cfif></td></tr>
		</cfif>
		#TAXNo("TABLE","align=right")#
		<!--- <cfif vaEMAIL neq ""><tr><td><span style=font-size:80%>#HTMLEditFormat(vaEMAIL)#</span></td></tr></cfif>--->
		</table>
	<cfelseif iGCOID IS 1342>
		<!--- Prudential --->
		<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 95%" align="center" background="">
		<tr><td width="35%" rowspan=6><img SRC="#request.webroot#MSupport/logo/pacific_v2.gif"></td>
		<!--- <tr><td width="35%" rowspan=6><img SRC="#request.webroot#MSupport/logo/#cologo#"></td> --->
		<td width="25%">&nbsp;</td>
		<td width="40%" align="left">
		<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 100%;font-family:arial narrow" align="center" background="">
        <tr style="font-size:120%" align="left"><td><b>The Pacific Insurance Berhad</b> <span style="font-size:80%">(91603-K)</span></td><td>&nbsp;</td></tr>
        <!--- <tr style="font-size:120%" align="left"><td><b>#vaCONAME#</b> <span style="font-size:80%">(#vaCOREGNO#)</span></td><td>&nbsp;</td></tr> --->
		<!--- tr style="font-size:95%" align="left" style="letter-spacing:5px"><td>????????????</td><td>&nbsp;</td></tr --->
		<tr><td colspan="2"><img SRC="#request.webroot#MSupport/logo/pacific_chco.gif"></td></tr>
		<tr style="font-size:95%" align="left"><td>40-01, Q Sentral 2A, Jalan Stesen Sentral 2, Kuala Lumpur Sentral</td><td>&nbsp;</td></tr>
        <tr style="font-size:95%" align="left"><td>P.O. Box 12490, 50470 Kuala Lumpur, Malaysia.</td><td>&nbsp;</td></tr>
        <tr style="font-size:95%" align="left"><td>Tel: #request.ds.co[igcoid].TELNO# Fax: #request.ds.co[igcoid].FAXNO#</td><td>&nbsp;</td></tr>
        <tr style="font-size:95%" align="left"><td>Website: www.pacificinsurance.com.my</td><td>&nbsp;</td></tr>
		#TAXNo("TABLE","align=left","font-size:95%")#
        </table>
		</td>
		</table>
		<!---table id=COHEADER style="WIDTH:100%" align=center border=0 cellPadding=0 cellSpacing=0>
			<tr><td align=RIGHT><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
			#TAXNo("TABLE","align=right","")#
		</table--->


	<cfelseif iGCOID IS	2333 OR iGCOID IS 19239> <!---NTSERVER: 618 LIVE:2333--->
		<!--- UMW Toyota--->
		<table id=COHEADER style="WIDTH:100%" align=center border=0 cellPadding=0 cellSpacing=0>
		<tr>
		<td widt="25%" rowspan=5 align="left" valign="top">
		<img SRC="#request.webroot#MSupport/logo/#cologo#">
		</td>
		<td width="75%" align="left">
		<table id=COHEADER style="WIDTH:97%" align=center border=0 cellPadding=0 cellSpacing=0>
		<tr><td width="80%" style="font-size:150%;font-weight: bold" cellpadding="0" cellspacing="0"><cfif iCOID IS 18832 OR iCOID IS 12569>#HTMLEditFormat(UCase(GCONAME))#&nbsp;<font size="-2">(#HTMLEditFormat(GCOREGNO)#)</font><cfelse>#HTMLEditFormat(UCase(vaCONAME))#&nbsp;<font size="-2">(#HTMLEditFormat(vaCOREGNO)#)</font></cfif></td></tr>
 		<cfif Trim(vaCOTAGLINE) IS NOT "" and iCOID is 2629><tr><td><span class=clsCoTagLine>#HTMLEditFormat(vaCOTAGLINE)#</span></td></tr></cfif>
		<tr><td><span style="font-size:100%">SERVICE DIVISION (#HTMLEditFormat(vaCOBRNAME)#)</span></td></tr>
		<tr><td><cfif vaADD1 neq "">#HTMLEditFormat(vaADD1)#<cfif vaADD2 neq "">,</cfif><cfelse>&nbsp;</cfif></td></tr>
	    <cfif vaADD2 neq ""><tr><td>#HTMLEditFormat(vaADD2)#</cfif></tr></td>
		<tr><td>#Trim(vaPOSTCODE)#,&nbsp;#HTMLEditFormat(CITY)#,&nbsp;#HTMLEditFormat(STATE)#,&nbsp;Malaysia</td></tr>
		<tr><td><cfif aTELNO neq "">Tel: +6#HTMLEditFormat(aTELNO)#<cfif aFAXNO neq "">&nbsp;Fax: +6#HTMLEditFormat(aFAXNO)#</cfif><cfelse>&nbsp;</cfif></td></tr>
	    <cfif vaEMAIL neq ""><tr><td><span style=font-size:80%>#HTMLEditFormat(vaEMAIL)#</span></td></tr></cfif>
	    #TAXNo("TABLE","","font-size:80%;")#
		</table>
		</td></tr></table>

	<cfelseif iGCOID IS	1424 AND (ListFind(BnP_CoList,iCOID) GT 0 OR iPCOID EQ 57345)>
		<table id=COHEADER style="WIDTH:100%" align=center border=0 cellPadding=0 cellSpacing=0>
        <tr><td align="center"><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
        <tr><td align="center">#fAddrOut(q_co)# </td></tr>
		</table>

	<cfelseif iGCOID IS	1424 AND ListFind(BnP_CoList,iCOID) IS 0>
		<!---Proton Edar & branches (exclude B&P branch) --->
		<table id=COHEADER style="WIDTH:100%" align=center border=0 cellPadding=0 cellSpacing=0>
		<tr>
		<td width="80%">
		<table style="WIDTH:97%" align=center border=0 cellPadding=0 cellSpacing=0>
		<tr><td width="80%" style="font-size:130%; font-weight: bold" cellpadding="2" cellspacing="2">Proton Edar Sdn. Bhd. (#HTMLEditFormat(vaCOBRNAME)#)</td></tr>
 		<tr><td><span style=font-size:80%><i>(Company No. #HTMLEditFormat(vaCOREGNO)#)</i></span></td></tr>
		<tr><td>&nbsp;</td></tr>
		<tr><td><cfif vaADD1 neq "">#HTMLEditFormat(vaADD1)#<cfif vaADD2 neq "">,</cfif><cfelse>&nbsp;</cfif></td></tr>
	    <cfif vaADD2 neq ""><tr><td>#HTMLEditFormat(vaADD2)#,</td></tr></cfif>
		<tr><td>#Trim(vaPOSTCODE)#,&nbsp;#HTMLEditFormat(CITY)#,&nbsp;#HTMLEditFormat(STATE)#,&nbsp;Malaysia</td></tr>
		<tr><td><cfif aTELNO neq "">Tel: +6#HTMLEditFormat(aTELNO)#<cfif aFAXNO neq "">&nbsp;Fax: +6#HTMLEditFormat(aFAXNO)#</cfif><cfelse>&nbsp;</cfif></td></tr>
	    <cfif vaEMAIL neq ""><tr><td><span style=font-size:80%>#HTMLEditFormat(vaEMAIL)#</span></td></tr></cfif>
	    #TAXNo("TABLE","","font-size:80%")#
		</table></td>
		<td widt="20%" rowspan=4 align="right">
		<img SRC="#request.webroot#MSupport/logo/#cologo#">
		</td></tr></table>
		<!---CFELSEIF iGCOID IS 2333>
	   <table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:80%" align=center>
		<tr><td colspan=5 align="left"><IMG SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
		<tr><td width="3%">&nbsp;</td><td colspan=4><b><font size="+1">#ucase(vaCONAME)#</font> (#vaCOREGNO#)</b></td></tr>
		<tr><td>&nbsp;</td><td colspan=4>SERVICE DIVISION&nbsp;<cfif #ucase(vaCOBRNAME)# IS "HQ">(H.Q.)<cfelse>(#ucase(vaCOBRNAME)#)</cfif></td></tr>
		<cfif #vaADD1# neq "">
		<tr><td>&nbsp;</td><td colspan=4>#HTMLEditFormat(vaADD1)#
		</cfif>
		<cfif #vaADD2# neq "">
		<tr><td>&nbsp;</td><td colspan=4>#HTMLEditFormat(vaADD2)#</td></tr>
		</cfif>
		<tr><td>&nbsp;</td><td colspan=4>#HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(city)#, #HTMLEditFormat(state)#, Malaysia</td></tr>
		<cfif #aTELNO# neq "" OR #aFAXNO# neq "">
		<tr><td>&nbsp;</td><td colspan=2><cfif #aTELNO# neq ""> Tel No: #aTELNO#</cfif><cfif #aFAXNO# neq "">&nbsp;&nbsp;Fax No: #aFAXNO#</cfif></td></tr>
		</cfif>
		</TABLE--->
	<cfelseif iGCOID IS 1713>
		<!--- Takaful Ikhlas --->
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:90%" align=center>
			<!---><tr><td align=right><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>--->
			<!--- Start #30949 kofam --->
			<cfif attributes.layout IS 2>
			<tr><td width=100px><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
				<td valign=bottom><table id=COFOOTER border="0" cellspacing="0" cellpadding="0" align="center" style="WIDTH: 95%;color:darkgreen">
						<tr><td style="font-size:9.5pt"><b>#UCASE(vaCONAME)#</b><span style=font-size:70%> (#UCASE(vaCOREGNO)#)</span></td></tr>
						<!---cfif Trim(vaTAXREGNO) IS NOT ""><tr><td><span style="font-size:8.5pt">GST No: #HTMLEditFormat(vaTAXREGNO)#</td></span><td>&nbsp;</td></tr></cfif--->
						<tr><td style="font-size:8.5pt;font-style:italic">Licensed under Islamic Financial Services Act 2013 and regulated by Bank Negara Malaysia</td></tr>
						<tr><td style="font-size:8.5pt">&nbsp;</td></tr>
						<tr><td style="font-size:8.5pt"><b>Corporate Head Office</b></td></tr>
						<tr><td style="font-size:8.5pt"><b>IKHLAS Point</b>, #HTMLEditFormat(Replace(vaADD1,"IKHLAS Point, ",""))#<cfif vaADD2 neq "">, </cfif> #HTMLEditFormat(vaADD2)#, #Trim(vaPOSTCODE)# #HTMLEditFormat(CITY)#.</td></tr>
						<tr><td style="font-size:8.5pt"><b>T</b>: #aTELNO# &nbsp;&nbsp;&nbsp;&nbsp; <b>F</b>: #aFAXNO# &nbsp;&nbsp;&nbsp;&nbsp; <b>Website</b>: www.takaful-ikhlas.com.my</td></tr>
						#TAXNo("TABLE","","font-size:8.5pt;font-weight:bold")#
						<tr style="line-height:110%"><td style="font-size:8.5pt">&nbsp;</td></tr>
					</table>
					</td></tr>
			<cfelse>
			<tr><td width=90%></td><td width=10% align=right><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
			</cfif>
			<!--- End #30949 kofam --->
		</table>
	<cfelseif iGCOID IS 1770>
		<!--- Honda --->
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:100%" align=center>
			<tr>
				<td width=35% align=center><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
				<td valign=top>
					<div align=left style=width:100%>
					<span class=clsRptSubTitle>#HTMLEditFormat(vaCONAME)#<cfif vaCOREGNO IS NOT ""> <span style="font-size:50%;color:black">(#HTMLEditFormat(vaCOREGNO)#)</span></cfif></span><br>
					<cfif Trim(vaCOTAGLINE) IS NOT ""><span class=clsCoTagLine>#HTMLEditFormat(vaCOTAGLINE)#</span><br></cfif>
					<cfif Trim(vaADD1) IS NOT "">#HTMLEditFormat(vaADD1)#,<br></cfif>
					<cfif Trim(vaADD2) IS NOT ""> #HTMLEditFormat(vaADD2)#,<br></cfif><cfif STATE IS "Singapore">Singapore #Trim(vaPOSTCODE)#.<cfelse>#Trim(vaPOSTCODE)# #CITY#, #STATE#.</cfif><br>
					<cfif Trim(aTELNO) IS NOT "">Tel: #HTMLEditFormat(Trim(aTELNO))#</cfif><cfif Trim(aFAXNO) IS NOT "">&nbsp;&nbsp;Fax: #HTMLEditFormat(Trim(aFAXNO))#</cfif>
					<cfif Trim(vaEMAIL) IS NOT "">&nbsp;&nbsp;Email: #HTMLEditFormat(Trim(vaEMAIL))#</cfif>
					#TAXNo("HTML","","","YES")#
					</div>
				</td>
			</tr>
		</table>
	<cfelseif iGCOID IS 1026>
		<!--- Daihatsu --->
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:100%" align=center>
			<tr>
				<td width=16% align=left valign=top><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
				<td valign=top>
					<div align=left style=width:100%>
					<span class=clsRptSubTitle><span style="font-size:100%; color:black; font-weight: bold; line-height: 2px"> #HTMLEditFormat(UCase(vaCONAME))#</span><cfif vaCOREGNO IS NOT ""> <span style="font-size:60%;color:black">(#HTMLEditFormat(vaCOREGNO)#)</span></cfif></span><br>
					<span style="font-weight: bold"><cfif iCOID eq 1026>HEAD OFFICE<cfelse>#HTMLEditFormat(UCase(vaCOBRNAME))#</cfif> :</span><br>
					<span style="font-size:90%">
					<cfif iCOID eq 1026> <!---for HQ setting--->
						<cfif Trim(vaADD1) IS NOT "">#HTMLEditFormat(UCase(vaADD1))#, <cfif Trim(vaADD2) IS NOT ""> #HTMLEditFormat(UCase(vaADD2))#,</cfif><cfif STATE IS "Singapore">Singapore #Trim(vaPOSTCODE)#.<cfelse> #Trim(UCase(vaPOSTCODE))# #UCase(CITY)#, #UCase(STATE)#.</cfif><br></cfif>
						(P.0. BOX 7014, 40700 SHAH ALAM)<br>
					<cfelse>
					    <cfif Trim(vaADD1) IS NOT "">#HTMLEditFormat(UCase(vaADD1))#,  <cfif Trim(vaADD2) IS NOT ""> #HTMLEditFormat(UCase(vaADD2))#,</cfif><br></cfif>
					    <cfif STATE IS "Singapore">Singapore #Trim(vaPOSTCODE)#.<cfelse> #Trim(UCase(vaPOSTCODE))# #UCase(CITY)#, #UCase(STATE)#.<br></cfif>
					</cfif>
					<cfif Trim(aTELNO) IS NOT "">Tel: #HTMLEditFormat(Trim(aTELNO))#<br></cfif>
					<cfif Trim(aFAXNO) IS NOT "">Fax: #HTMLEditFormat(Trim(aFAXNO))#</cfif>
					#TAXNo("HTML","","","YES")#
					</span>
					</div>
				</td>
			</tr>
		</table>
	<cfelseif iGCOID IS 619>
	    <!--- Auto Bavaria --->
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:100%" align=center>
			 <div align=left style=width:100%>
			 <tr><td width=80% align=left valign=bottom><span style="font-size:210%; color:black; font-weight: bold; font-family: Arial, Helvetica, sans-serif">#HTMLEditFormat(vaCONAME)#</span></td>
				 <td align=right valign=top ><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
		         <td>&nbsp;</td>
			 </tr>
			 <tr><td><span style="font-size:100%; color:black; font-weight: bold; font-family: Arial, Helvetica, sans-serif">#vaCOTAGLINE#</span></td>
			     <td>&nbsp;</td>
			 </tr>
			 <tr><td><span style="font-size:70%; color:black; font-weight: bold; font-family: Arial, Helvetica, sans-serif">Company No. #HTMLEditFormat(vaCOREGNO)#</span></td>
			     <td>&nbsp;</td>
			 </tr>
			 <cfif Trim(vaADD1) IS NOT ""><tr><td><span style="font-size:70%; font-family: Arial, Helvetica, sans-serif"><cfif icoid IS NOT igcoid>#HTMLEditFormat(vaCOBRNAME)#:&nbsp;<cfelse>Head Office:&nbsp;</cfif>#HTMLEditFormat(vaADD1)#,<cfif Trim(vaADD2) IS NOT ""> #HTMLEditFormat(vaADD2)#,</cfif> <cfif STATE IS "Singapore">Singapore #Trim(vaPOSTCODE)#.<cfelse> #Trim(vaPOSTCODE)# #CITY#, #STATE#.</cfif></td></span><td>&nbsp;</td></tr></cfif>
			 <cfif Trim(aTELNO) IS NOT ""><tr><td><span style="font-size:70%; font-family: Arial, Helvetica, sans-serif">Tel: #HTMLEditFormat(Trim(aTELNO))#&nbsp;&nbsp;<cfif Trim(aFAXNO) IS NOT "">Fax: #HTMLEditFormat(Trim(aFAXNO))#</cfif></td></span><td>&nbsp;</td></tr></cfif>
			 <cfif Trim(vaEMAIL) IS NOT ""><tr><td><span style="font-size:70%; font-family: Arial, Helvetica, sans-serif">Website: #HTMLEditFormat(Trim(vaEMAIL))#</td></span><td>&nbsp;</td></tr></cfif>
			 <!--- <cfif Trim(vaTAXREGNO) IS NOT ""><tr><td><span style="font-size:70%; font-family: Arial, Helvetica, sans-serif">GST No: #HTMLEditFormat(vaTAXREGNO)#</td></span><td>&nbsp;</td></tr></cfif> ---><!--- #13506 --->
			 #TAXNo("TABLE","","font-size:70%;font-family:arial,helvetica,sans-serif;","")# <!--- #28803 --->
			 </div>
		</table>
	<cfelseif iGCOID IS 304>
	    <!--- Bengkel Memateri Kenderaan Tek Yee Sdn Bhd, authorised EON dealer --->
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:100%" align=center>
			 <div align=left style=width:100%>
			 <tr><td align=left valign=top ><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
		     </tr>
			 <tr><td><span style="font-size:100%; color:black; font-weight: bold; font-family: Arial, Helvetica, sans-serif">#HTMLEditFormat(UCase(vaCONAME))#</span>&nbsp;<span style="font-size:70%; color:black; font-weight: bold; font-family: Arial, Helvetica, sans-serif">(#HTMLEditFormat(vaCOREGNO)#)</span></td>
			 </tr>
			 <tr style="font-size:80%"><td>#UCase(vaADD1)#,<cfif #vaADD2# IS NOT ""> #UCase(vaADD2)#,</cfif></td></tr>
			 <tr style="font-size:80%"><td>#vaPOSTCODE# #UCase(city)#, #UCase(state)#.</td></tr>
			 <tr style="font-size:80%"><td>TEL: #aTELNO# FAX: #aFAXNO# <!--- #vaEMAIL# ---></td></tr>
			 #TAXNo("TABLE","","font-size:80%")#
			 </div>
		</table>
	<!--- 37446 --->
	<!--- <cfelseif iGCOID IS 3060 and attributes.layout IS 1>
            <!--- ETIQA's nonmotor cases using attributes.layout=1 --->
            <table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:100%" align=center>
                <tr><td align=center valign=top ><img SRC="#request.webroot#MSupport/logo/Etiqa.gif"></td></tr>
                #TAXNo("TABLE","align=center valign=top")#
            </table>
	<cfelseif iGCOID IS 3060 and attributes.layout IS 2>
		<div id=COHEADER style="width:100%;clear:both;" align="center"><table cellspacing=1 cellpadding=1 border=0 width="100%" align="center">
			<tr><td align="center"><img SRC="#request.webroot#MSupport/logo/etiqaInsuranceTakaful.gif"> </td></tr>
            <tr> #TAXNo(type="TABLE",style="text-align:center;font-weight:bold")# </tr>
		</table></div> --->
	<cfelseif iGCOID IS 3060>
		<cfif attributes.layout IS 1>
			<!--- ETIQA's nonmotor cases using attributes.layout=1 --->
            <table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:100%" align=center>
                <tr><td align=center valign=top ><img SRC="#request.webroot#MSupport/logo/Etiqa.gif"></td></tr>
                #TAXNo("TABLE","align=center valign=top")#
            </table>
		<cfelseif attributes.layout IS 2>
			<div id=COHEADER style="width:100%;clear:both;" align="center"><table cellspacing=1 cellpadding=1 border=0 width="100%" align="center">
				<tr><td align="center"><img SRC="#request.webroot#MSupport/logo/etiqaInsuranceTakaful.gif"> </td></tr>
	            <tr> #TAXNo(type="TABLE",style="text-align:center;font-weight:bold")# </tr>
			</table></div>
		<cfelse>
			<cfif LEFT(vaCOBRNAME,2) IS "ET" OR LEFT(vaCOBRNAME,2) IS "MT" OR LEFT(vaCOBRNAME,2) IS "TN">
				<!--- ETIQA's nonmotor cases using attributes.layout=1 --->
	            <table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:100%" align=center>
	                <tr><td align=center valign=top ><img SRC="#request.webroot#MSupport/logo/EtiqaTakaful.gif"></td></tr>
	                #TAXNo("TABLE","align=center valign=top")#
	            </table>
			<cfelseif LEFT(vaCOBRNAME,2) IS "EI" OR LEFT(vaCOBRNAME,2) IS "MG" OR LEFT(vaCOBRNAME,2) IS "MNI">
				<!--- ETIQA's nonmotor cases using attributes.layout=1 --->
	            <table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:100%" align=center>
	                <tr><td align=center valign=top ><img SRC="#request.webroot#MSupport/logo/EtiqaInsurance.gif"></td></tr>
	                #TAXNo("TABLE","align=center valign=top")#
	            </table>
			<cfelse>
				<!--- ETIQA's nonmotor cases using attributes.layout=1 --->
	            <table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:100%" align=center>
	                <tr><td align=center valign=top ><img SRC="#request.webroot#MSupport/logo/Etiqa.gif"></td></tr>
	                #TAXNo("TABLE","align=center valign=top")#
	            </table>
			</cfif>
		</cfif>
	<!--- 37446 --->
	<cfelseif iGCOID IS 1600001 and attributes.layout IS 1>
		<!--- etiqa cambodia layout=1 --->
            <table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:100%" align=center>
                <tr><td align=center valign=top ><img SRC="#request.webroot#MSupport/logo/Etiqa.gif"></td></tr>
                #TAXNo("TABLE","align=center valign=top")#
            </table>
	<cfelseif iGCOID IS 1600001 and attributes.layout IS 2>
		<!--- etiqa cambodia layout=2 --->
		<div id=COHEADER style="width:100%;clear:both;" align="center"><table cellspacing=1 cellpadding=1 border=0 width="100%" align="center">
			<tr><td align="center"><img SRC="#request.webroot#MSupport/logo/etiqaInsuranceTakaful.gif"> </td></tr>
            <tr> #TAXNo(type="TABLE",style="text-align:center;font-weight:bold")# </tr>
		</table></div>
	<cfelseif iGCOID IS 1003198>
    	<!--- etiqa philippines --->
    	<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 100%;border-style:hidden" align="center">
    		<tr><td align=center valign=top>
        		<IMG SRC="#request.webroot#MSupport/logo/Etiqa.GIF">    
        		</td></tr>
		</table>
	<cfelseif iGCOID IS 9517><!--- Etiqa Insurance --->
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:100%" align=center>
			<tr><td align=center valign=top ><img SRC="#request.webroot#MSupport/logo/EtiqaInsurance.gif"></td></tr>
			#TAXNo("TABLE","align=center valign=top")#
		</table>
	<cfelseif  iGCOID IS 9516><!--- Etiqa Takaful --->
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:100%" align=center>
			<tr><td align=center valign=top ><img SRC="#request.webroot#MSupport/logo/EtiqaTakaful.gif"></td></tr>
			#TAXNo("TABLE","align=center valign=top")#
		</table>
	<cfelseif iGCOID IS 3062>
	    <!--- prudential BSN Takaful --->
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:100%" align=center>
			 <tr><td align=right valign=top ><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
			 #TAXNo("TABLE","align=center valign=top")#
		</table>
	<cfelseif iGCOID IS 7412>
	    <!--- MMIP --->
		<table id=COHEADER border=0 cellPadding=3 cellSpacing=1 style="WIDTH:100%;font-size:100%" align=center>
			 <tr><td align=center valign=top ><b>#ucase("Malaysian Motor Insurance Pool")#</b></td></tr>
			 <tr><td style="border:2px double black">
					<table width=100% cellPadding=2 cellSpacing=1>
						<CFIF Attributes.COID IS NOT 7412><tr><td align=center><br>NAME & ADDRESS OF SERVICING INSURER TO WHOM ALL CORRESPONDENCE SHALL BE SENT:-<br>&nbsp;</td></tr></CFIF>
						<tr><td align=center>
							<CFIF Attributes.COID IS 18205>#ucase("Liberty Insurance Berhad")#<br><CFIF vaCOTAGLINE IS NOT "">(#vaCOTAGLINE#)</CFIF>
						    <cfelseif Attributes.COID IS 18206>#ucase("MPI Generali Insurans Berhad")#<br><!---<CFIF vaCOTAGLINE IS NOT "">(#vaCOTAGLINE#)</CFIF> #33512--->
						    <CFELSEIF Attributes.COID IS 7412>#ucase("ADMINISTERED BY MMIP SERVICES SDN BHD")#</CFIF>
						</td></tr>
						<!--- <tr><td align=center>#HTMLEditFormat(vaADD1)#<cfif #vaADD2# IS NOT "">, #HTMLEditFormat(vaADD2)#</cfif>,</td></tr>
						<tr><td align=center>#HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(city)#<CFIF city IS not state>, #state#</CFIF></td></tr> --->
						<tr><td align=center>#HTMLEditFormat(vaADD1)#,</td></tr>
						<cfif #vaADD2# IS NOT ""><tr><td align=center>#HTMLEditFormat(vaADD2)#,</td></tr></cfif>
						<cfif #vaADD3# IS NOT ""><tr><td align=center>#HTMLEditFormat(vaADD3)#,</td></tr></cfif>
						<tr><td align=center>#HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(city)#</td></tr>
						<tr><td align=center>Tel:&nbsp;#HTMLEditFormat(aTELNO)#&nbsp; Fax No:&nbsp;#HTMLEditFormat(aFAXNO)#&nbsp;<br>&nbsp;</td></tr>
						#TAXNo("TABLE","align=center")#
					</table></td></tr>
		</table>

	<cfelseif iGCOID IS 2943>
		<style>
		.clsBorder-left-top-right {
			border-left:1px solid black;
			border-top:1px solid black;
			border-right:1px solid black;
			width:10%
		}

		.clsBorder-all {
			border:1px solid black;
		}
		</style>
		<table id=COHEADER border=0 cellPadding=3 cellSpacing=1 style="WIDTH:90%" align=center>
			<tr><td style="width:100%" colspan="2" align="center">
				<table style="width:60%" align="center">
				<tr><td style="border-top:2px solid black;border-bottom:2px solid black" align="center">
					<div style="font-size:14pt"><b>CHYE KWEE YEOW & CO.</b></div>
					&##34081; &##36149; &##32768; &##24459; &##24072; &##27004;<br/><!--- 蔡 贵 耀 律 师 楼 --->
					<div style="font-size:7pt">Peguambela & Peguamcara</div>
					<div style="font-size:7pt">Advocates & Solicitors</div>
				</td></tr>
				</table>
			</td></tr>
			<tr>
				<td style="width:60%">
					<table style="width:100%" cellpadding="0" cellspacing="0">
					<tr><td colspan="4" style="font-size:6pt">CHYE KWEE YEOW  &##34081; &##36149; &##32768; &##24459; &##24072; &##27004;</td></tr><!--- 蔡 贵 耀 律 师 楼 --->
					<tr><td colspan="4" style="font-size:6pt">LIM CHI HOU  &##26519;&##24535;&##35946; &##24459;&nbsp;&##24072;</td></tr> <!--- 林志豪律 师 --->
					<tr><td colspan="4" style="font-size:6pt">ABDULLAH BIN MOHAMAD NAWAWI</td></tr>
					<tr><td colspan="4">&nbsp;</td></tr>
					<tr><td class="clsBorder-left-top-right">&nbsp;</td><td style="font-size:6pt">&nbsp;By Fax</td><td class="clsBorder-left-top-right">&nbsp;</td><td style="font-size:6pt">&nbsp;By A.R. Registered</td></tr>
					<tr><td class="clsBorder-left-top-right">&nbsp;</td><td style="font-size:6pt">&nbsp;By Hand</td><td class="clsBorder-left-top-right">&nbsp;</td><td style="font-size:6pt">&nbsp;By Registered</td></tr>
					<tr><td class="clsBorder-all">&nbsp;</td><td style="font-size:6pt">&nbsp;By Ordinary Post</td><td class="clsBorder-all">&nbsp;</td><td style="font-size:6pt">&nbsp;By Courier</td></tr>
					<tr><td class="clsBorder-all">&nbsp;</td><td style="font-size:6pt">&nbsp;By Email</td><td class="clsBorder-all">&nbsp;</td><td style="font-size:6pt">&nbsp</td></tr>
					<!--- <tr><td colspan="4">&nbsp;</td></tr> --->
					</table>
				</td>
				<td style="width:40%" valign="top">
					<table style="width:100%">
					<tr><td colspan="3" style="font-size:6pt"><!--- solicitor here --->
						<b>
							#vaADD1#,<br/>#vaADD2#,<br/>#vaPOSTCODE# #CITY#, #STATE#.<br/><br/>
						</b>
					</td></tr>
					<tr><td style="font-size:6pt">No. Tel</td><td style="font-size:6pt">:</td><td style="font-size:6pt">07-7761978 / 07-7764978 / 07-7768978</td></tr>
					<tr><td style="font-size:6pt">No. Fax</td><td style="font-size:6pt">:</td><td style="font-size:6pt">07-7765978</td></tr>
					<tr><td style="font-size:6pt">E-mail</td><td style="font-size:6pt">:</td><td style="font-size:6pt">ckyacc2@gmail.com</td></tr>
					#TAXNo("TABLE","colspan=3","font-size:6pt")#
					<tr><td colspan="3" style="font-size:6pt"><i>( When replying, kindly quote our reference )</i></td></tr>
					</table>
				</td>
			</tr>
		</table>
	<cfelseif iGCOID IS 18205>
	    <!--- MMIP --->
		<!---><table id=COHEADER border=0 cellPadding=3 cellSpacing=1 style="WIDTH:100%;font-size:100%" align=center>
			 <tr><td align=center valign=top ><b>#ucase("Malaysian Motor Insurance Pool")#</b></td></tr>
			 <tr><td style="border:2px double black">
					<table width=100% cellPadding=2 cellSpacing=1>
						<tr><td align=center><br>NAME & ADDRESS OF SERVICING INSURER TO WHOM ALL CORRESPONDENCE SHALL BE SENT:-<br>&nbsp;</td></tr>
						<tr><td align=center>#ucase("Uni.Asia General Insurance Berhad")#</td></tr>
						<tr><td align=center>#HTMLEditFormat(vaADD1)#<cfif #vaADD2# IS NOT "">, #HTMLEditFormat(vaADD2)#</cfif>,</td></tr>
						<tr><td align=center>#HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(city)#<CFIF city IS not state>, #state#</CFIF></td></tr>
						<tr><td align=center>Tel:&nbsp;#HTMLEditFormat(aTELNO)#&nbsp; Fax No:&nbsp;#HTMLEditFormat(aFAXNO)#&nbsp;<br>&nbsp;</td></tr>
					</table></td></tr>
		</table>--->

	<cfelseif iGCOID IS 9616>
		<!--- Zurich Takaful--->
		<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 100%" align="center" background="">
		<tr><td align="center" valign=bottom><img SRC="#request.webroot#MSupport/logo/#cologo#"><span style="font-size:70%"></span></td></tr>
	 	<tr><td>
		<table border="0" cellPadding="0" cellSpacing="1" style="WIDTH:100%" align="center">
		<!---   18286   <tr class=clsSmallRow><td align="center" style="font-size:70%">#HTMLEditFormat(vaADD1)#<cfif #vaADD2# IS NOT "">,&nbsp;&nbsp; #HTMLEditFormat(vaADD2)#</cfif>,&nbsp;&nbsp; #HTMLEditFormat(vaPOSTCODE)#&nbsp;&nbsp; #HTMLEditFormat(city)#</td></tr>
		<tr class=clsSmallRow><td align="center" style="font-size:70%">Tel:&nbsp;#HTMLEditFormat(aTELNO)#&nbsp; <cfif #aFAXNO# IS NOT "">Fax No:&nbsp;#HTMLEditFormat(aFAXNO)#&nbsp; </cfif><!---> Call Center: 1-300-888-MAA/622---></td></tr>
		#TAXNo("TABLE","align=center","font-size:70%")#--->
		</table>
		</td></tr>
		<tr><td>&nbsp</td></tr>
		<tr><td>&nbsp</td></tr>

 		</table>

    <!--- carina: temporary solution for this one particular nasim branch --->
   <cfelseif iGCOID IS 5754 and (
           iCOID IS 30369
        OR iCOID IS 30368
        OR iCOID IS 26385
    )>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial" align="center" background="">
            <tr> <td style="text-align:center"><span style="font-size:150%;color:darkred;">#vaCONAME#</span> <span style="font-size:80%">(Co. Reg. No. #vaCOREGNO#)</span></td> </tr>
            <cfif vaadd1 neq ""><tr> <td style="text-align:center">#vaadd1# </td> </tr> </cfif>
            <cfif vaadd2 neq ""><tr> <td style="text-align:center">#vaadd2# </td> </tr> </cfif>
            <cfif vaadd3 neq ""><tr> <td style="text-align:center">#vaadd3# <td> </tr>  </cfif>
            <tr> <td style="text-align:center">#vaPOSTCODE# #city# #state#<td> </tr>
            <tr> <td style="text-align:center"><b>GST No: #vataxregno#</b></td> </tr>
            <tr> <td style="text-align:center">
                <cfif atelno neq "">Tel: #atelno#    </cfif>
                <cfif afaxno neq "">Fax: #afaxno#    </cfif>
                <cfif vaemail neq "">Email:#vaemail# </cfif>
            </td> </tr>
		</table>

   <cfelseif iGCOID IS 342>
	    <!--- Klinik Kereta Tampin, authorised Perodua dealer --->
		<table id=COHEADER style="WIDTH:100%" align=center border=0 cellPadding=0 cellSpacing=0>
		<tr>
		<td width="25%" rowspan=5 align="left" valign="top">
		<cfif Attributes.MANUFACTURER IS "PERODUA"><img SRC="#request.webroot#MSupport/logo/#cologo#"></cfif>
		</td>
		<td width="75%" align="right">
		<table id=COHEADER style="WIDTH:97%" align=center border=0 cellPadding=0 cellSpacing=0>
		<tr align="right" style="font-size:110%"><td width="80%" style="font-weight: bold; font-style: italic" cellpadding="0" cellspacing="0">#HTMLEditFormat(UCase(vaCONAME))#&nbsp;(#HTMLEditFormat(vaCOREGNO)#)</td></tr>
 		<cfif Attributes.MANUFACTURER IS "PERODUA"><tr align="right" style="font-size:110%"><td style="font-weight: bold; font-style: italic"><!--- #HTMLEditFormat(UCase(vaCOTAGLINE))# --->PERODUA SERVIS DAN ALAT GANTI (223047)</td></tr></cfif>
		<tr style="font-size:80%" align="right"><td><cfif vaADD1 neq "">#HTMLEditFormat(vaADD1)#<cfelse>&nbsp;</cfif></td></tr>
	    <cfif vaADD2 neq ""><tr style="font-size:80%" align="right"><td>#HTMLEditFormat(vaADD2)#</cfif></tr></td>
		<tr style="font-size:80%" align="right"><td>#Trim(vaPOSTCODE)#,&nbsp;#HTMLEditFormat(CITY)#,&nbsp;#HTMLEditFormat(STATE)#,&nbsp;Malaysia</td></tr>
		<tr style="font-size:80%" align="right"><td><cfif aTELNO neq "">Tel: #HTMLEditFormat(aTELNO)#<cfif aFAXNO neq "">&nbsp;&nbsp;Fax: #HTMLEditFormat(aFAXNO)#</cfif><cfelse>&nbsp;</cfif></td></tr>
	    <tr align="right"><td style="font-size:90%;font-weight:bold">Claim Department :  06-441 4412&nbsp;&nbsp;Fax : 06-441 9894</td></tr>
	    #TAXNo("TABLE","align=right","font-size:90%;font-weight:bold;")#
		</table>
		</td></tr></table>
	<cfelseif iGCOID IS	2274>
		<!--- euromobil --->
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:100%" align=center>
			 <div align=left style=width:100%>
			 <tr><td width=33% align=left valign=bottom ><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
			 <td align=center valign=center> <table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:100%" align=center>
				 <tr><td><span style="font-size:100%; color:black; font-weight: bold; font-family: Arial, Helvetica, sans-serif">#HTMLEditFormat(UCase(vaCONAME))#</span>&nbsp;<span style="font-size:70%; color:black; font-weight: bold; font-family: Arial, Helvetica, sans-serif">(#HTMLEditFormat(vaCOREGNO)#)</span></td></tr>
				 <tr style="font-size:80%"><td>#UCase(vaADD1)#</td></tr>
				 <cfif #vaADD2# IS NOT ""> <tr style="font-size:80%"><td> #UCase(vaADD2)#</td></tr></cfif>
				 <tr style="font-size:80%"><td>#vaPOSTCODE# #UCase(city)#, #UCase(state)#.</td></tr>
				 <tr style="font-size:80%"><td>TEL: 1-300-13-3333, +(603) 7688 7688 </td></tr>
				 <tr style="font-size:80%"><td>FAX: +(603) 7628 0020, +(603) 7628 0021</td></tr>
				 #TAXNo("TABLE","","font-size:80%")#
			 </table> </td>
			 <td width=33% align=right valign=top ><img SRC="#request.webroot#MSupport/logo/audi.gif"></td></tr>
			 </div>
		</table>
	<cfelseif iGCOID IS	3348>
		<!--- sapura-auto --->
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:100%" align=center>
			 <div align=left style=width:100%>
			 <tr><td width=45% align=left valign=top ><span style="font-size:200%;color:black; font-weight: bold; font-family: Arial, Helvetica, sans-serif">Sapura Auto</span><br><span style="font-size:160%;color:gray; font-weight: bold; font-family: Arial, Helvetica, sans-serif">Kuala Lumpur</span></td>
			 	<td valign=top> <table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;" align=right>
				 <tr><td><span style="font-size:90%; color:black; font-weight:bold; font-family: Arial, Helvetica, sans-serif">Address</span></td></tr>
				 <tr><td><span style="font-size:80%; color:black; font-family: Arial, Helvetica, sans-serif">#HTMLEditFormat(UCase(vaCONAME))#</span>&nbsp;<span style="font-size:70%; color:black; font-family: Arial, Helvetica, sans-serif">(#HTMLEditFormat(vaCOREGNO)#)</span></td></tr>
				  <tr><td><span style="font-size:75%; color:black; font-family: Arial, Helvetica, sans-serif">(formerly Sapura VC Sdn Bhd)</td></tr>
				 <tr style="line-height:20%"><td>&nbsp;</td></tr>
				 <tr style="font-size:80%; color:black; font-family: Arial, Helvetica, sans-serif"><td>#UCase(vaADD1)#</td></tr>
				 <cfif #vaADD2# IS NOT ""><tr style="font-size:80%; color:black; font-family: Arial, Helvetica, sans-serif"><td>#UCase(vaADD2)#</td></tr></cfif>
				 <tr style="font-size:80%; color:black; font-family: Arial, Helvetica, sans-serif"><td>#vaPOSTCODE# #UCase(city)#, #UCase(state)#.</td></tr> </table> </td>
				<td width=1%>&nbsp;</td><td valign=top width=16%> <table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:100%" align=right>
				<tr> <td ><span style="font-size:90%; color:black; font-weight:bold; font-family: Arial, Helvetica, sans-serif">Telephone</span></td></tr>
				 <tr style="font-size:80%; font-family: Arial, Helvetica, sans-serif"><td>+6 03-2056 4269</td></tr>
				 <tr style="line-height:20%; "><td>&nbsp;</td></tr>
				 <tr> <td><span style="font-size:90%; color:black; font-weight:bold; font-family: Arial, Helvetica, sans-serif">Fax</span></td></tr>
				 <tr style="font-size:80%; font-family: Arial, Helvetica, sans-serif"><td>+6 03-2163 0269</td></tr>
				 <tr style="line-height:20%"><td>&nbsp;</td></tr>
				 #TAXNo("TABLE","","line-height:20%")#
				 <tr> <td><span style="font-size:90%; color:black; font-weight:bold; font-family: Arial, Helvetica, sans-serif">Website</span></td></tr>
				 <tr><td style="font-size:80%; font-family: Arial, Helvetica, sans-serif">www.sapura-auto.com</td></tr>
			 </table> </td>
			 <td align=right valign=top ><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
			 </div>
		</table>
	<cfelseif iGCOID IS 8070>
		<!--- HLTMT --->
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:#Attributes.WIDTH#" align="center">
		<tr><td align=left style="padding-top:5px;padding-bottom:5px"><IMG SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
		#TAXNo("TABLE")#
		</table>
		<!---cfset thisstate=#TRIM(REReplace(REReplace(state,"\((.*?)\)","","ALL"),"Darul(.*?)\Z","","ALL"))#>
		<div style="text-align:right"><IMG SRC="#request.webroot#MSupport/logo/#cologo#">
			<table align="right" width="246px" border=0 cellspacing=0 cellpadding=1 style="font-size:6pt;letter-spacing:1px;color:red;font-family:arial">
			<tr><td style="font-size:6pt;letter-spacing:0px;color:red;font-family:arial;line-height:150%;padding-top:10px;padding-bottom:10px" colspan=2>
				#vaconame# (#vacoregno#)<Br>
				<cfif vaadd1 NEQ "">#vaadd1#<Br></cfif>
				<cfif vaadd2 NEQ "">#vaadd2#<br></cfif>#vaPOSTCODE# #city#, #thisstate#<br>
				Malaysia.
				</td>
			</tr>
			<tr><td style="font-weight:bold;width:30%;font-size:6pt">Telephone</td>
				<td style="width:70%;font-size:6pt">#aTELNO#<!--- +603-2164 2339 ---></td>
			</tr>
			<tr><td style="font-weight:bold;font-size:6pt">Facsimile</td>
				<td style="font-size:6pt">#aFAXNO#<!--- +603-2163 0224 ---></td>
			</tr>
			<tr><td style="font-weight:bold;font-size:6pt">Website</td>
				<td style="font-size:6pt">www.hlmsigtakaful.com.my</td>
			</tr>
			</table>
		</div>
		<!--- 		<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="font-size:90%;color:##B22222"  align="right" background="">
				<tr><td align="right"><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr> --->
				<!---><tr><td>&nbsp;</td><td align="right" colspan=2><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
				<tr><td colspan=3>&nbsp;</td></tr>
		 		<tr><td>&nbsp;</td><td style="width:45px">&nbsp;</td><td nowrap style="width:225px">#vaCONAME# (#vaCOREGNO#)</td></tr>
				<tr><td colspan=2>&nbsp;</td><td>#HTMLEditFormat(vaADD1)#</td></tr>
				<tr><td colspan=2>&nbsp;</td><td>#HTMLEditFormat(vaADD2)# #vaPOSTCODE# #city#</td></tr>
				<tr><td colspan=2>&nbsp;</td><td>Malaysia</td></tr>
				<tr style="line-height:100%"><td colspan=3>&nbsp;</td></tr>
				<tr><td colspan=2>&nbsp;</td><td><b>Telephone</b> &nbsp; #aTELNO#</td></tr>
				<tr><td colspan=2>&nbsp;</td><td><b>Facsimile</b> &nbsp;&nbsp;&nbsp; #aFAXNO#</td></tr>
				<tr><td colspan=2>&nbsp;</td><td><b>Website</b> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; www.hlmsigtakaful.com.my</td></tr>
				--->
		<!--- 		</table> --->
				<BR Clear=all--->
	<cfelseif iGCOID IS 8598>
	<!--- AG Claim --->
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:570px"  align="center" background="">
		<tr><td align=right><IMG SRC="#request.webroot#MSupport/logo/#cologo#"></td><td align=right><span style="font-family:times new roman;font-size:20pt">#ucase(vaCONAME)#</span><br><span style="font-family:times new roman;font-size:10pt">(#vaCOREGNO#)</span></td></tr>
		#TAXNo("TABLE","align=right")#
		</table>
	<cfelseif iGCOID IS 8669>
	<!--- UMW toyota PDC --->
		<div id=COHEADER style="text-align:center">
			<div style="width:400px;text-align:left">
				<div style="padding-bottom:2px"><IMG SRC="#request.webroot#MSupport/logo/#cologo#"></div>
				<div style="font-weight:bold">#ucase(vaCONAME)#<cfif vaCOREGNO NEQ ""> (Co.Reg. No:#vaCOREGNO#)</cfif></div>
				<cfif vaCOTAGLINE NEQ ""><div>#vaCOTAGLINE#</div></cfif>
				#HTMLEditFormat(vaADD1)#<cfif vaADD2 NEQ "">, #HTMLEditFormat(vaADD2)#</cfif><br>
				#vaPOSTCODE# #city#, #STATE#<br>
				Tel: #aTELNO# &nbsp; Fax: #aFAXNO#
				#TAXNo("HTML","","","YES")#
			</div>
		</div>
	<cfelseif iGCOID IS 16652>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%"  align="center" background="">
		<tr><td align=center colspan="2" style="padding-bottom:20px"><IMG SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
		<tr><td style="font-family:arial;font-size:8pt;width:50%;vertical-align:top">
		<b>HAJJARAL ASWANI TUAN IBRAHIM</b> <i>LL.B (Hons), Malaysia</i><br><br>
		<b>NOORIZWA JURISH</b> <i>LL.B (Hons), Malaya</i></td>
		<td style="font-family:arial;font-size:7pt;width:50%;text-align:right;vertical-align:top">
					No. 187, 4th Floor,<br>
			Puteri Park Plaza, Jalan 28,<br>
			Taman Putra, 68000 Ampang,<br>
			Selangor Darul Ehsan.<br>
			Tel: 03 42932660 Fax: 03 42932661<br>
			Mobile: 0123780961/0192008931<br>
			Email: m.haijco@gmail.com<br>
		</td>
		</tr>
<!--- 		<td align=right><span style="font-family:times new roman;font-size:20pt">#ucase(vaCONAME)#</span><br><span style="font-family:times new roman;font-size:10pt">(#vaCOREGNO#)</span></td></tr> --->
		</table>
	<cfelseif iGCOID IS 7865 OR iGCOID IS 13056>
		<!--- Jayadeep --->
		<table id=COHEADER align="center" border="0" width=100%>
		<tr>
			<td align=left valign=top width=120><img SRC="#request.webroot#MSupport/logo/MY-7865.png"></td>
			<td align=left valign=top><div style="font-size:190%;font-weight:bold;color:black;padding-top:10px">Jayadeep Hari & Jamil</div><div style="font-size:120%;font-weight:bold;color:black;padding-top:5px">Advocates and Solicitors</div>
			#TAXNo(type="HTML",span="",BRFront="yes",BRend='no')#</td>
		</tr>
		</table>
	<cfelseif iGCOID IS 6407>
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%" align=center>
		<tr>
		 	<td width=35% align=left valign=top><img SRC="#request.webroot#MSupport/logo/perodua2.gif"></td>
			<td align=right>
			 	<table border=0 cellPadding=0 cellSpacing=0 align=center>
				<tr><td colspan=2><span style="font-weight:bold;font-size:140%">#HTMLEditFormat(UCase(vaCONAME))#</span>&nbsp;<span style="font-size:90%;color:black;font-weight:bold;">(#HTMLEditFormat(vaCOREGNO)#)</span></td></tr
				< tr style="font-size:100%"><td colspan=2>(SERVICE & PARTS CENTRE)</td></tr>
				<tr style="font-size:100%"><td colspan=2>#vaADD1#</td></tr>
				<tr style="font-size:100%"><td colspan=2>#vaADD2#</td></tr>
				<tr style="font-size:100%"><td colspan=2>#vaPOSTCODE# #city#, #state#, Malaysia.</td></tr>
				<tr style="font-size:100%"><td colspan=2>Tel: 03-4295 0197 / 03-4295 0877 Fax: 03-4297 3720</td></tr>
				<tr style="font-size:100%"><td width=65>Office Tel:</td><td align=left>012-643 5083 / 012-631 0581</td></tr>
				<tr style="font-size:100%"><td></td><td>012-980 7012 / 012-980 1370</td></tr>
				<tr style="font-size:100%"><td colspan=2>Parts Dept Tel: 012-635 9581</td></tr>
			 	</table>
			</td>
		</tr>
		</table>
	<cfelseif iGCOID IS 200005>
		<cfif DateDiff("d",DateFormat(Now(), "yyyy-mm-dd"), "2013-04-01") LTE 0><!--- begin 2013-04-01 --->
			<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%" align="center">
			<tr><td align=left><img SRC="#request.webroot#MSupport/logo/AIG_logo_purple.png"></td></tr>
			<cfif attributes.layout IS 0>
			<tr><td style="font-family:arial;font-size:8pt;text-align:left">
			<div style="height:55px">&nbsp;</div>
			<div style="line-height:110%">
			<span style="color:blue;">#vaconame#</span><br>
			<!--- #vaadd1#<br>
			#vaadd2#<br> --->
			<!--- #42591: [SG] AIG - eClaims - Update details in Letters --->
			<cfif iCOID IS 200005>
				#vaadd1#<br>
				#vaadd2#<br>
			<cfelse>
				AIG Building, 78 Shenton Way<br>
				##09-16<br>
			</cfif>
			<!--- #42591: [SG] AIG - eClaims - Update details in Letters --->
			Singapore #vaPOSTCODE#<br>
			T : (65) 6419 3000<br>
			www.aig.sg<br>
			</div>
			</td></tr>
			</cfif>
			</table>
		<cfelse>
			<!--- AIG Singapore --->
			<table id=COHEADER border="0" cellPadding="1" cellSpacing="1" style="WIDTH:100%;font-family:Tahoma;font-size:8pt"  align="center" background="">
					<tr><td>#vaconame#<br>CHARTIS Building<br>78 Shenton Way<br>##07-16<br>Singapore 079120</td><td rowspan=3 valign=top align=right><IMG SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
					<tr><td>&nbsp;</td></tr>
					<tr><td>Tel: #aTELNO# (Call Centre)<br>Fax: #aFAXNO# (Claims Department)<br>WebSite: <u>www.chartisinsurance.com.sg</u><br>Co. Reg. No. #HTMLEditFormat(vaCOREGNO)#</td></tr>
			</table>
		</cfif>

	<cfelseif iGCOID IS 200006 OR Attributes.COID IS 200676>
		<!--- Crawford Singapore / Crawford on behalf of OAC --->
		<!--- with attributes.layout : 0: default , 1: without header address, logo aligned to right --->
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:times new roman;font-size:90%"  align="center" background="">
		<tr><td align=<cfif attributes.layout IS 1>RIGHT<cfelse>center</cfif>><IMG SRC="#request.webroot#MSupport/logo/#cologo#" width="238px" height="87px"></td></tr>
		<cfif Attributes.LAYOUT IS 0>
			<tr><td align=center style="font-weight:bold;font-size:110%">#vaconame#</td></tr>
			<!---tr><td align=center>No. 8 Shenton Way ##33-01 <span style="font-weight:bold">-</span> UIC Building <span style="font-weight:bold">-</span> Singapore 068808</td></tr--->
			<tr><td align=center><cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" TARGET="ONELINE" ADD1=#vaADD1# ADD2=#vaADD2# POSTCODE=#vaPOSTCODE# CITYID=#iCITYID#></td></tr>
			<tr><td align=center>Tel : 65 6225 4211   Fax : 65 6222 8310   E-mail : admin@crawford.com.sg</td></tr>
			<tr><td align=center>URL : www.crawford.com.sg</td></tr>
			<tr><td align=center>Company Registration No. 197101412E</td></tr>
			<!---tr><td align=center>GST Registration No. M200868412</td></tr--->
		</cfif>
		</table>

	<!--- Aisyah #44384 --->
	<cfelseif iGCOID IS 206209>
		<!--- SG Allianz 206209  --->
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial"  align="center" background="">
		<tr><td align=right><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
		<tr style=font-size:16px;color:##003780;><td colspan=2><b>#HTMLEditFormat(vaconame)#</b></td></tr>
		<tr><td>&nbsp;</td></tr>
		<!--- <tr><td colspan=2>Company's Registration No: #vaCOREGNO#</span></td></tr> --->
		</table>
	<cfelseif iGCOID IS 200028>
		<!--- SG Allianz  --->
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial"  align="center" background="">
		<tr><td>&nbsp;</td><td align=right><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
		<tr style=font-size:140%><td colspan=2><b>#HTMLEditFormat(vaconame)#</b></td></tr>
		<tr><td colspan=2>Company's Registration No: #vaCOREGNO#</span></td></tr>
		<!---<tr><td style="font-size:110%">(Formerly known as Malaysia British Assurance Berhad)</td></tr>--->
		</table>

		<!--- Allianz Singapore, Crawford on behalf of Allianz --->
		<!---
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:times new roman;font-size:90%"  align="center" background="">
		<tr><td align=center><IMG SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
		<tr><td align=center style="font-weight:bold;font-size:110%"><!---#vaconame#--->Crawford & Company International Pte Ltd</td></tr>
		<tr><td align=center>No. 5 Shenton Way ##33-01 <span style="font-weight:bold">-</span> UIC Building <span style="font-weight:bold">-</span> Singapore 068808</td></tr>
		<tr><td align=center>Tel : 65 6225 4211   Fax : 65 6222 8310   E-mail : admin@crawford.com.sg</td></tr>
		<tr><td align=center>URL : www.crawford.com.sg</td></tr>
		<tr><td align=center>Company Registration No. 197101412E</td></tr>
		</table>--->
	<!--- cfelseif iGCOID IS 200030>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;background:url(#request.webroot#MSupport/logo/SG-chinataiping_line.gif);background-repeat:repeat-x" align="center">
			<tr><td style="height:82px;WIDTH:50%;background:url(#request.webroot#MSupport/logo/SG-chinataiping_logo.gif);background-repeat:no-repeat;text-align:right">
				<td align="right"><img src="#request.webroot#MSupport/logo/SG-chinataiping_add.gif"></td>
			</tr>
		</table>
		<!--- table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;background:url(#request.webroot#MSupport/logo/SG-chinataiping_line.gif);background-repeat:repeat-x" align="center">
			<tr><td style="WIDTH:100%;background:url(#request.webroot#MSupport/logo/SG-chinataiping_logo.gif);background-repeat:no-repeat;text-align:right">
				<div style="width:240px;text-align:left;font-size:6pt;font-family:arial;line-height:105%;color:464646;font-weight:bold;"><img src="#request.webroot#MSupport/logo/SG-chinataiping_co.gif">
				<div style="padding-top:2px">
				105 Cecil Street ##19-00 The Octagon, Singapore 06953<br>
				Tel: #aTELNO# &nbsp; Fax: #aFAXNO#<br>
				Website: www.sg.cntaiping.com<br>
				Co. Reg. No. #vaCOREGNO#
				</div>
				</div>
			</td></tr>
		</table --->   --->
	<!--- cfelseif iGCOID IS 200035><!--- SG etiqa --->
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="width:100%" align="center" background="">
		<tr><td style="width:145px;vertical-align:top"><img src="#request.webroot#MSupport/logo/#cologo#"></td>
			<td style="vertical-align:top;font-family:Arial;font-size:6.5pt;line-height:120%">
			<b>#vaCONAME#</b><br>
			#vaADD1#<cfif #vaADD2# IS NOT "">, #vaADD2#</cfif>, Singapore #vaPOSTCODE#<br>
			<b>T:</b> #aTELNO# &nbsp; <b>F:</b> #aFAXNO#<br>
			Robinson Road P.O. Box 1690 Singapore 903340 &nbsp;<span style="color:fadc00;font-weight:bold">www.etiqa.com.sg</span><br>
			Company Reg No.: #vaCOREGNO# &nbsp; GST Reg No.: M2-0005141-6
			</td>
			<td style="width:190px;vertical-align:bottom;text-align:right;font-family:Arial;font-size:6.5pt;">A Member of the <img src="#request.webroot#MSupport/logo/sg-etiqa_btm.gif"> Group&nbsp;</td>
		</tr>
		</table --->

	<cfelseif iGCOID IS 200031>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:90%;" align="center" background="">
			<tr>
			<td valign=top align=left><IMG SRC="#request.webroot#MSupport/logo/FirstCapheader_left.gif" height="50"></td>
			<td valign=top align=right>
				<IMG SRC="#request.webroot#MSupport/logo/FirstCapheader_right.gif" height="120"></td>
			</tr>
		</table>

	<cfelseif iGCOID IS 200033>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
		<tr>
			<td valign=top align="left"><IMG SRC="#request.webroot#MSupport/logo/SG-200033.gif" height="90"></td>
			<td valign=top align="right"><IMG SRC="#request.webroot#MSupport/logo/SG-200033_right.gif" height="110" ></td>
		</tr>
		</table>
	<cfelseif iGCOID IS 200036 OR iGCOID IS 200037 OR IGCOID IS 200115>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family: 'Ubuntu', sans-serif;font-size:10pt" align="center" background="">
			<col align=left>
			<tr><td valign=top rowspan=5 width=150><IMG SRC="#request.webroot#MSupport/logo/#cologo#"></td>
				<td style="width:35px">&nbsp;</td>
				<td><span style="color:##102F6D;font-weight:bold">#vaCONAME#</span><span> (Co. Reg. No. #vaCOREGNO#)</span><br>
				#vaADD1#<cfif #vaADD2# IS NOT "">, #vaADD2#</cfif>, Singapore #vaPOSTCODE#<br>
				Tel #aTELNO#, Fax #aFAXNO#<br>
				<b style="color:##BB3F2B">msig.com.sg</b>
				</td>
			</tr>
			<!--- tr><td><span style="font-size:130%;border-bottom:1px solid black;font-weight:bold">#vaCONAME#</span></td></tr>
			<tr><td style="font-size:85%">(Company Registration No. #vaCOREGNO#)</td></tr>
			<tr><td>#vaADD1#<cfif #vaADD2# IS NOT "">, #vaADD2#</cfif>, Singapore #vaPOSTCODE#</td></tr>
			<tr><td>Tel: #aTELNO# &nbsp;&nbsp;&nbsp; Fax: #aFAXNO# &nbsp;&nbsp;&nbsp; www.ms-ins.com.sg</td></tr --->
		</table>
		<br><br>
		<CFIF iGCOID IS 200036>
			<CFSET APPLYHTML="YES">
			<CFIF (IsDefined("Caller.Attributes.TEMPLATENAME") AND Caller.Attributes.TEMPLATENAME EQ "dsp_geninsrpt.cfm") OR CLAIMTYPE IS "NM HS"><!--- #41422 CY --->
				<CFSET APPLYHTML="NO">
			</CFIF>

			<!--- #39319/ #39307 kofam /#41422 CY --->
			<CFIF NOT(listFindNoCase("NM TR,NM PA,NM HS", CLAIMTYPE) AND APPLYHTML EQ "NO")>
				<cfmodule template="#request.apppath#claims/Secured/template/#iGCOID#/general_style.cfm" APPLYHTML=#APPLYHTML#>
			</CFIF>
		</CFIF>
	<cfelseif iGCOID IS 200043>
		<CFIF CLAIMTYPE EQ 'NM WC'>
			<style MEDIA=PRINT>
				body {
				font-size:12pt !important;
			}
			</STYLE>
		</CFIF>
		<table id=COHEADER border=0 cellPadding=3 cellSpacing=1 style="WIDTH:100%;font-size:100%" align=center>
			<tr><td align=left valign=top ><img SRC="#request.webroot#MSupport/logo/#cologo#" width="200px"></td>
				<td align=right>
					<table>
						<tr><td align=right><span style="font-weight:bold;font-size:10pt;color:black;;font-family:arial">#ucase(vaconame)#</span></td></tr>
						<tr><td align=right style="font-size:8pt;font-family:arial">#vaADD1#,&nbsp;#vaADD2#</td></tr>
						<tr><td align=right style="font-size:8pt;font-family:arial">#STATE#&nbsp;#vaPOSTCODE#</td></tr>
						<tr><td align=right style="font-size:8pt;font-family:arial">Tel:&nbsp;#aTELNO#&nbsp;|&nbsp;#vaEMAIL#</td></tr>
						<tr><td align=right style="font-size:8pt;font-family:arial">Co. Reg No. #vaCOREGNO#&nbsp;|&nbsp;GST Reg.No: #vaTAXREGNO#</td></tr>
					</table>
				</td>
			</tr>
		</table>
		<table>
			<tr><td><img SRC="#request.webroot#MSupport/logo/Red_Line.png" width="1280px"></td>
		</table>

		
		<!---<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" width="#Attributes.WIDTH#" align="center" background="">
			<col style="text-align:center;line-height:100%">
			<tr><td><IMG SRC="#request.webroot#MSupport/logo/SG-sompo-v8.JPG"></td></tr>
		</table>--->
		<!---cfif DateDiff("d",DateFormat(Now(), "yyyy-mm-dd"), "2013-01-01") LTE 0><!--- begin 2013-01-01 --->
			<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
				<col style="text-align:center;line-height:100%">
				<tr><td><IMG SRC="#request.webroot#MSupport/logo/SG-sompo_v2.gif"></td></tr>
			</table>
		<cfelse>
			<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
				<col style="text-align:center;line-height:100%">
				<tr><td><IMG SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
				<tr><td style="font-size:8pt;font-family:arial">
				(Incorporated in Singapore) - Co Reg No #UCASE(vaCOREGNO)#<br>
				#HTMLEDITFORMAT(vaADD1)# <cfif #vaADD2# IS NOT "">, #HTMLEDITFORMAT(vaADD2)#</cfif>, Singapore #vaPOSTCODE# Tel: #aTELNO# Fax: #aFAXNO# Website: www.sompojapan.com.sg
				</td></tr>
			</table>
		</cfif--->
	<cfelseif iGCOID IS 200040><!--- SG-QBE --->
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
			<tr>
				<td style="font-family:arial;color:2e2e2e;border-bottom:1px solid ##006bb6;padding-bottom:3px" valign="bottom">
				<div style="font-weight:bold;font-size:12pt">QBE Insurance (Singapore) Pte Ltd</div>
				<div style="font-size:7pt">
				A member of the worldwide QBE Insurance Group  Unique Entity No. 198401363C</div>
				<div style="font-size:8pt">
				1 Raffles Quay ##29-10 South Tower Singapore 048583<br>
				Tel: 65-6224 6633 Fax: 65-6533 3270 <br>
				<span style="font-weight:bold;color:##0096CF;">www.qbe.com.sg</span>
				</div>
			</td>
			<td width="125px" style="text-align:center;line-height:100%"><IMG SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
		</table>
	<cfelseif iGCOID IS 200045><!--- SG-Tokio Marine --->
		<!--- <table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
			<col style="width:35%"></col>
			<col style="width:20%"></col>
			<col style="width:45%"></col>
			<tr><td>&nbsp;</td><td valign="top"><IMG SRC="#request.webroot#MSupport/logo/#cologo#"></td>
				<td style="font-size:8pt;font-family:arial">
				<img src="#request.webroot#MSupport/logo/SG-tokio_coname.gif">
				<div style="font-size:6pt;font-family:times new roman">Company Reg. No. : #UCASE(vaCOREGNO)#</div>
				<div style="font-size:9pt;font-family:times new roman">
				#HTMLEDITFORMAT(vaADD1)#
				<cfif #vaADD2# IS NOT "">,<br>#HTMLEDITFORMAT(vaADD2)#</cfif>,
				<br>Singapore #vaPOSTCODE#
				<br>Tel : #aTELNO# &nbsp;Fax : #aFAXNO#
				<br>Email : #HTMLEditFormat(Trim(vaEMAIL))#
				<br>Website : www.tokiomarine.com
				</div>
			</td></tr>
		</table> --->
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
			<tr><td valign="top" align=left><IMG style="width:auto" SRC="#request.webroot#MSupport/logo/tmis_header_left.png"></td><td>&nbsp;</td>
			<td valign="top" align=right><IMG style="width:auto" SRC="#request.webroot#MSupport/logo/tmis_header_right.png"></td></tr>
		</table>
	<cfelseif iGCOID IS 200050>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
			<col align=left>
			<tr><td valign=top align="center"><table border="0" cellPadding="0" cellSpacing="0">
				<tr><td><IMG SRC="#request.webroot#MSupport/logo/#cologo#"></td>
					<td style="padding:5px"></td>
					<td align="center"><span style="font-size:12pt;text-align:center;font-weight:bold">#UCASE(vaCONAME)#</span><br>
						<span style="font-size:7pt;text-align:center;margin:2px">SINGAPORE BRANCH</span><br>
						<span style="font-size:7pt;text-align:center;line-height:125%">
						COMPANY REGISTRATION NO: #UCASE(vaCOREGNO)#<br>
						#UCASE(vaADD1)#<cfif #vaADD2# IS NOT "">, #UCASE(vaADD2)#</cfif>, SINGAPORE #vaPOSTCODE#<br>
						TEL: #aTELNO# &nbsp;&nbsp;&nbsp; FAX: #aFAXNO#
						</span>
					</td>
				</tr></table>
				</td></tr>
		</table>
	<cfelseif iGCOID IS 200051>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
			<col align=left>
			<tr><td valign=top rowspan=5 width=150><IMG SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
			<tr><td style="font-size:110%"><b>#vaCONAME#</b></td></tr>
			<tr><td>#vaADD1#<cfif #vaADD2# IS NOT "">, #vaADD2#</cfif>,</td></tr>
			<tr><td>Singapore #vaPOSTCODE#</td></tr>
			<tr><td>Co. Reg. No. : #vaCOREGNO#</td></tr>
		</table>
    <cfelseif iGCOID IS 200059>
<!---         <table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
            <col align=left width="65%"><col align=left width="35%">
			<tr><td valign="top"><IMG SRC="#request.webroot#MSupport/logo/#cologo#"></td>
			    <td valign="top"><b>#vaCONAME#</b>
					<br>Pandan Toyota Car Bodycare Centre
					<br>#vaADD1#<cfif #vaADD2# IS NOT "">, #vaADD2#</cfif>
					<br>Singapore #vaPOSTCODE#
					<br>Tel: #HTMLEditFormat(aTELNO)#
					<br>Fax: #HTMLEditFormat(aFAXNO)#
					<br><b>www.borneomotors.com.sg</b>
				</td>
			</tr>
        </table> --->
        <table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
            <col align=left width="65%"><col align=left width="35%">
			<tr><td valign="top"><IMG SRC="#request.webroot#MSupport/logo/#cologo#"></td>
			    <td valign="top"><b>Borneo Motors (Singapore) Pte Ltd</b>
					<br>Pandan Toyota Car Bodycare Centre
					<br>2 Pandan Crescent
					<br>Singapore 128462
					<br>Tel: +65 6631 1855
					<br>Fax: +65 6773 3094
					<br><b>www.borneomotors.com.sg</b>
				</td>
			</tr>
        </table>
<!--- 	<cfelseif iGCOID IS 200073><!--- RT appraisal --->
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
			<col align=right>
			<tr><td style="border-bottom:1px solid black">
			<div style="font-family:times new roman;font-size:22pt;font-style:italic;font-weight:bold">#vaCONAME#</div>
			<div style="font-family:times new roman;font-size:11pt;">
#vaADD1#<cfif #vaADD2# IS NOT ""> #vaADD2#</cfif> Singapore #vaPOSTCODE#<br>
Tel: #HTMLEditFormat(aTELNO)# &nbsp;&nbsp; Fax: #HTMLEditFormat(aFAXNO)#<br>
Email: #HTMLEditFormat(Trim(vaEMAIL))#<br>
Company Registration Nos. #HTMLEditFormat(vaCOREGNO)#
			</div><br>
			</td></tr>
		</table>		 --->
	<cfelseif iGCOID IS 200095>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
		<tr><td style="font-size:30pt;font-weight:bold;font-style:italic;color:008000;text-align:center;font-family:times new roman"><b>#HTMLEditFormat(vaCONAME)#</b></td></tr>
		<tr><td style="font-size:12pt;font-weight:bold;text-align:center;font-family:times new roman">
			#vaADD1# #vaADD2#<br>
			Singapore #vaPOSTCODE#<br>
			Tel: #HTMLEditFormat(aTELNO)# &nbsp;&nbsp; Fax: #HTMLEditFormat(aFAXNO)#<br>
			Email: #HTMLEditFormat(Trim(vaEMAIL))#<br>
			Company Reg. No: #HTMLEditFormat(vaCOREGNO)# &nbsp;GST Reg.No: #vaTAXREGNO#
			</td></tr>
		</table>
	<cfelseif iGCOID IS 200099>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
		<tr><td style="font-size:22pt;font-weight:bold;text-align:center;font-family:times new roman"><b>#UCASE(vaCONAME)#</b></td></tr>
		<tr><td style="font-size:10pt;text-align:center;font-family:arial">
		<cfif vaCOREGNO NEQ "">Reg. No:#HTMLEditFormat(vaCOREGNO)#<br></cfif>
		<cfif vaADD1 NEQ "">#vaADD1#<br></cfif>
		<cfif vaADD2 NEQ "">#vaADD2#<br></cfif>
		Singapore #vaPOSTCODE#<br>
		Tel: #HTMLEditFormat(aTELNO)#  Fax:#HTMLEditFormat(aFAXNO)#<br>
		Gst Reg No: #vaTAXREGNO#
		</td></tr>
		</table>
	<cfelseif iGCOID IS 200123 AND DateDiff("d",DateFormat(Now(), "yyyy-mm-dd"), "2011-10-01") LTE 0>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
		<tr><td style="font-size:15pt;font-weight:bold;text-align:center;font-family:arial;color:5d7ced;line-height:150%"><b>#UCASE(vaCONAME)#</b></td></tr>
		<tr><td style="font-size:10pt;text-align:center;font-family:arial;font-weight:bold;line-height:130%">
		#vaADD1#<cfif vaADD2 NEQ "">, #vaADD2#</cfif>, Singapore #vaPOSTCODE#<br>
		Tel: #HTMLEditFormat(aTELNO)# &nbsp; Fax: #HTMLEditFormat(aFAXNO)#<br>
		Email: #listgetat(Trim(vaEMAIL),1,";")# &nbsp; Website: www.smemotor.com.sg<br>
		Co. & GST Reg. No: #vaTAXREGNO#
		</td></tr>
		</table>
<!--- 	<cfelseif iGCOID IS 200144><!--- SG-JPknights --->
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%" align="center" background="">
			<col align=left width="70%" valign="middle"><col align=left width="1%" valign="middle"><col align=left width="29%" valign="middle">
			<tr><td valign=top>
				<div style="border-bottom:1.5pt solid black"><IMG SRC="#request.webroot#MSupport/logo/#cologo#" vspace="18"></div>
				</td>
				<td>&nbsp;</td>
				<td style="border-left:1.5pt solid black;padding-left:10px;font-family:Garamond,verdana;font-size:9pt;font-weight:bold">
					<!--- div><b>#vaCONAME#</b></div --->
					<cfif vaADD1 NEQ ""><div>#vaADD1#</div></cfif>
					<cfif vaADD2 NEQ ""><div>#vaADD2#</div></cfif>
					<div>Singapore #vaPOSTCODE#</div><br>
					<div style="clear:both"><span style="float:left;width:30px">Tel</span><span style="float:left">: #aTELNO#</span></div>
					<div style="clear:both"><span style="float:left;width:30px">Fax</span><span style="float:left">: #aFAXNO#</span></div>
					<br><br>
					<div>Email: #vaEMAIL#</div>
					<div>www.jpknights.com</div>
					<br>
					<div>Co.Reg No: #vacoregno#</div>
				</td></tr>
		</table> --->
	<!---CFELSEIF iGCOID IS 200187><!--- SG vertex auto, has two logos; valogo's first list=vertex(default), 2nd list='haifet' --->
		<cfif UCASE(attributes.MANUFACTURER) IS "HAFEI"><!--- hafei ---><cfset cologotemp=#listgetat(cologo,2,";")#><cfelse><!--- default or Chery ---><cfset cologotemp=#listgetat(cologo,1,";")#></cfif>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
			<tr><td align="center"><IMG SRC="#request.webroot#MSupport/logo/#cologotemp#" vspace="3"></td></tr>
		</table--->
	<!--- CFELSEIF iGCOID IS 200195><!--- i-spex --->
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:770px;" align="center" background="">
			<tr><td align="center" valign="middle"><IMG SRC="#request.webroot#MSupport/logo/#cologo#"></td>
				<td style="font-family:times new roman" valign="middle">
					<div><span style="font-size:18pt;color:##f51814;font-weight:bold;border-bottom:3px solid ##1c2e9a;padding-bottom:0px">#UCASE(vaconame)#</span></div>
					<div style="font-size:8pt;padding-top:5px">(Co. Reg No. #vacoregno#)</div><br>
					<div style="font-size:12pt">
					<cfif vaADD1 NEQ "">#vaADD1#</cfif> <cfif vaADD2 NEQ "">#vaADD2#</cfif><br>
					Singapore #vaPOSTCODE#.<br>
					Tel: #aTELNO# &nbsp;&nbsp; Fax: #aFAXNO#<br>
					E-mail: #HTMLEditFormat(Trim(vaEMAIL))#<br>
					</div>
				</td>
			</tr>
		</table --->
	<CFELSEIF iGCOID IS 200197>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
			<tr><td>
			<div style="position:absolute;z-index:-1;left:0;width:100%;text-align:right"><IMG SRC="#request.webroot#MSupport/logo/#cologo#" vspace="3"></div>
			<div style="height:80px">&nbsp;</div>
			</td></tr>
		</table>
	<CFELSEIF iGCOID IS 200042>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
			<tr><td>
			<div style="position:absolute;z-index:-1;left:0;width:99%;text-align:right"><IMG SRC="#request.webroot#MSupport/logo/#cologo#" height="54px" width="121px"></div>
			<div style="height:80px">&nbsp;</div>
			</td></tr>
		</table>
	<cfelseif iGCOID IS 200175><!--- SG-UAS Services --->
		<div style="text-align:center;width:100%;font-family:times;">
			<div style="font-size:25pt;font-weight:bold">#UCASE(vaCONAME)#</div>
			<div style="font-size:7pt;font-style:italic;margin-bottom:2px">Business Reg. No. #vacoregno#</div>
		</div>
		<div style="text-align:center;width:100%;font-family:times;line-height:140%">
			<div style="font-size:11pt;font-style:italic"><cfif vaADD1 NEQ "">#vaADD1#</cfif><cfif vaADD2 NEQ "">, #vaADD2#</cfif>, Singapore #vaPOSTCODE#.</div>
			<div style="font-size:11pt;font-style:italic">Tel: #aTELNO# &nbsp; Fax: #aFAXNO# &nbsp; Handphone: 9636 4731</div>
		</div>
	<CFELSEIF iGCOID IS 200273>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
			<tr><td>
			<div style="text-align:center;font-size:26pt">#UCASE(vaCONAME)#</div>
			<div style="text-align:center;font-size:9pt">
			<cfif vaADD2 NEQ "">#vaADD2#</cfif> <cfif vaADD1 NEQ "">#vaADD1#</cfif> Singapore #vaPOSTCODE# Tel/Fax:#aTELNO#<br>
			Reg.No: #vacoregno# Insurance Loss Adjuster Licensed Appraiser<br>
			(Member of Singapore Automobile Appraisers Association)
			</div>
			</td></tr>
		</table>
	<CFELSEIF iGCOID IS 200274>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%" align="center">
		<tr><td align=left rowspan=2 width=25% style="padding-right:2px"><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
		<tr><td align=left width=75%>
			<span style="font-size:130%;font-weight:bold">GENERAL INSURANCE ASSOCIATION OF SINGAPORE<br>RECORDS MANAGEMENT CENTRE</span><br>
			<!---138 Robinson Road ##07-09, The Corporate Office, Singapore 068906<br>--->
			<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" COID=1 NOCONAME=1 NOCOREGNO=1 TARGET="ONELINE"><br>
			Phone: +65 6224 0010 Fax: +65 6224 0030<br>
			Operating Hours: Monday to Friday 9am to 5pm<br>
			GST Registration No: M400017735
		</td></tr>
		</table>
	<CFELSEIF iGCOID IS 200245>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:Times New Roman;font-weight:bold" align="center" background="">
			<tr><td align="center">
				<div style="font-size:30pt;">#UCASE(vaCONAME)#</div><br>
                <div style="font-size:12pt;line-height:120%">
				<cfif vaADD1 NEQ "">#UCASE(vaADD1)#</cfif><cfif vaADD2 NEQ ""><br>#UCASE(vaADD2)#</cfif> Singapore #vaPOSTCODE#<br>
                Tel: #HTMLEditFormat(aTELNO)# &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Fax: #HTMLEditFormat(aFAXNO)#  &nbsp;&nbsp; Email: #HTMLEditFormat(Trim(vaEMAIL))#<br>
                GST Reg No: #HTMLEditFormat(vaTAXREGNO)#
				</div>
			</td></tr>
		</table>
	<CFELSEIF iGCOID IS 200517>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:Times New Roman;font-weight:bold" align="center" background="">
			<tr><td align="center">
				<div style="font-size:19px;">#UCASE(vaCONAME)#</div>
                <div style="font-size:11px;line-height:120%">
				<cfif vaADD1 NEQ "">#UCASE(vaADD1)#</cfif><cfif vaADD2 NEQ ""><br>#UCASE(vaADD2)#</cfif><br>Singapore #vaPOSTCODE#<br>
                Tel: #HTMLEditFormat(aTELNO)# &nbsp; Fax: #HTMLEditFormat(aFAXNO)#<br>Email: #HTMLEditFormat(Trim(vaEMAIL))#<br>
				</div>
			</td></tr>
		</table>
	<CFELSEIF iGCOID IS 200703>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial" align="center" background="">
			<tr><td valign="top"><img SRC="#request.webroot#MSupport/logo/sg_sta_logo2.jpg"></td>
				<td style="font-size:8pt;color:##666666;width:150px">
				<div style="padding:10px"></div>
				<div style="font-weight:bold">#UCASE(vaCONAME)#</div>
                <div>
				<cfif vaADD1 NEQ "">#vaADD1#</cfif><cfif vaADD2 NEQ ""><br>#vaADD2#</cfif><br>Singapore #vaPOSTCODE#<br>
                Tel: (65) 6452 1398<br>Fax: (65) 6453 8244<br>http://www.stai.com.sg<br>(<i>Regn. No.: #vaCOREGNO#</i>)
				</div>
				</td>
			</tr>
		</table>
	<CFELSEIF iGCOID IS 201089>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial" align="center" background="">
			<tr><td valign="top"><img SRC="#request.webroot#MSupport/logo/sg_sta_logo.png"></td>
				<td style="font-size:8pt;color:##666666;width:150px">
				<div style="padding:10px"></div>
				<div style="font-weight:bold">#UCASE(vaCONAME)#</div>
                <div>
				<cfif vaADD1 NEQ "">#vaADD1#</cfif><cfif vaADD2 NEQ ""><br>#vaADD2#</cfif><br>Singapore #vaPOSTCODE#<br>
                Tel: (65) 6452 1398<br>Fax: (65) 6453 8244<br>http://www.stai.com.sg<br>(<i>Regn. No.: #vaCOREGNO#</i>)
				</div>
				</td>
			</tr>
		</table>
	<CFELSEIF iGCOID IS 200707>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:Times New Roman;font-weight:bold;line-height:20px" align="center" background="">
			<tr><td style="text-align:center;font-size:12pt">
				<div style="font-size:16pt">#UCASE(vaCONAME)#</div>
				<div style="font-size:13pt">
				<cfif vaADD1 NEQ "">#HTMLEditFormat(UCASE(vaADD1))#</cfif><cfif vaADD2 NEQ "">, #HTMLEditFormat(UCASE(vaADD2))#</cfif>, Singapore #HTMLEditFormat(TRIM(vaPOSTCODE))#.<br>
				(Business Reg.No. #HTMLEditFormat(vaCOREGNO)#)<br>
				Tel: #HTMLEditFormat(Trim(aTELNO))#, &nbsp;Fax: #HTMLEditFormat(Trim(aFAXNO))#<br>
				E-mail: #HTMLEditFormat(Trim(vaEMAIL))#
			</td></tr>
		</table>
	<CFELSEIF iGCOID IS 200750>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial" align="center" background="">
			<tr><td valign="top">
					<img SRC="#request.webroot#MSupport/logo/#cologo#">
					<div style="font-size:8pt">Co. Reg: #HTMLEditFormat(vacoregno)#</div>
				</td>
			</tr>
			<tr><td>
				<div style="text-align:center;font-size:8pt;align:center">#vaADD2#<cfif vaADD1 NEQ ""> #vaADD1#</cfif> (S) <cfif vaPOSTCODE NEQ "">#vaPOSTCODE#</cfif>
				<br>&##8226; Tel: (65) 6555 2909 &##8226; Fax: (65) 6841 7181 &##8226; Web: www.autoncars.com.sg
				</div>
			</td></tr>
				<!--- td style="font-size:8pt;color:##666666;width:150px">
				<div style="padding:10px"></div>
				<div style="font-weight:bold">#UCASE(vaCONAME)#</div>
				<div style="font-size:8pt">Co. Reg: #HTMLEditFormat(vacoregno)#</div>
                <div>
				<cfif vaADD1 NEQ "">#vaADD1#</cfif><cfif vaADD2 NEQ ""><br>#vaADD2#</cfif><br>Singapore #vaPOSTCODE#<br>
                Tel: (65) 6452 1398<br>Fax: (65) 6453 8244<br>http://www.stai.com.sg<br>(<i>Regn. No.: #vaCOREGNO#</i>)
				</div>
				</td--->
			</tr>
		</table>
	<!---CFELSEIF iGCOID IS 200402>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:Times New Roman;font-weight:bold" align="center" background="">
			<tr><td align="center">
			<div style="width:450px">
				<div style="font-size:20pt;text-align:left">#UCASE(vaCONAME)#</div>
                <div style="font-size:10pt;line-height:120%;text-align:left">
				<cfif vaADD1 NEQ "">#UCASE(vaADD1)#</cfif> <cfif vaADD2 NEQ "">#UCASE(vaADD2)#</cfif> Singapore #vaPOSTCODE#<br>
                Tel: #HTMLEditFormat(aTELNO)# &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Fax: #HTMLEditFormat(aFAXNO)#  &nbsp;&nbsp; Email: #HTMLEditFormat(Trim(vaEMAIL))#
				</div>
			</div>
			</td></tr>
		</table--->
    <CFELSEIF iGCOID IS 200800>
        <table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:sans-serif" align="center" background="">
            <tr><td valign="middle" align="left" width="90%">
                    <div style="text-align:left;font-weight:bold;font-size:8pt;margin-top:0px;margin-bottom:0px">#vaCONAME# (Singapore Branch) <span style="font-size:6pt;font-weight:normal">(Incorporated in Switzerland with limited liability)</span></div>
					<div style="text-align:left;font-size:7pt">
                    #Trim(vaADD1)# <cfif Trim(vaADD2) IS NOT "">#Trim(vaADD2)#</CFIF>, Singapore <cfif TRIM(vaPOSTCODE) NEQ "">#Trim(vaPOSTCODE)#</cfif><br>
					Tel #Trim(aTELNO)# &nbsp;Fax #Trim(aFAXNO)#<br>
					</div>
					<div style="text-align:left;font-size:6pt">
					Co Reg No: #HTMLEditFormat(vacoregno)#
					</div>
                </td>
				<td valign="middle" align="right" width="10%"><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
            </tr>
        </table>
	<cfelseif iGCOID IS 201154>
        <table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:sans-serif" align="center" background="">
            <tr><td width="70%" valign="middle" align="center">
				<div style="text-align:left"><img SRC="#request.webroot#MSupport/logo/#cologo#" style="width:194px;height:90px;"></div>
                </td>
                <td width="30%" align="right"><div style="text-align:left;font-weight:bold;font-size:10pt;margin-top:0px;margin-bottom:0px">Contact us at<br>Hotline: (65) 6532 1818 <br> E-mail: claim@DirectAsia.com</div></td>
            </tr>
            <tr><td colspan=2><div style="text-align:center;font-weight:bold;font-size:12pt;margin-top:0px;margin-bottom:0px">#vaCONAME#</div></td></tr>
        </table>
    <CFELSEIF iGCOID IS 201278>
       <!---  <cfif Right(Application.ApplicationName,6) EQ "_train" ><!--- training mode ---> --->
        <table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial" align="center" background="">
            <tr><td align="right">
                    <img SRC="#request.webroot#MSupport/logo/#cologo#">
                    <div style="text-align:right;font-weight:bold;font-size:11pt;margin-top:0px;margin-bottom:0px">#vaCONAME#</div>
                    <div style="text-align:right;font-size:8pt">
                    #Trim(vaADD1)# <cfif Trim(vaADD2) IS NOT "">#Trim(vaADD2)#</CFIF> Singapore <cfif TRIM(vaPOSTCODE) NEQ "">#Trim(vaPOSTCODE)#</cfif>
                    </div>
                    <div style="text-align:right;font-size:8pt;margin-top:5px;margin-bottom:5px">
                    Mainline &nbsp;#Trim(aTELNO)#
                    <br>Facsimile &nbsp;#Trim(aFAXNO)#
                    </div>
                    <div style="text-align:right;font-size:8pt;margin-top:5px;margin-bottom:0px">
                    www.vicom.com.sg
                    <br>Company Registration No: #HTMLEditFormat(vacoregno)#
                    </div>
                </td>
            </tr>
        </table>
<!--- 	    <cfelse><!--- live mode --->
        <table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%"  align="center" background="">
        <tr><td align=right><IMG SRC="#request.webroot#MSupport/logo/SG-vicom.gif"></td></tr>
        </table>
	    </cfif>	 --->
    <cfelseif IGCOID IS 201622>
        <table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial" align="center" background="">
            <tr><td align="left"><img SRC="#request.webroot#MSupport/logo/#cologo#"></td><td align="right" valign="bottom">Co. Reg. No. #HTMLEditFormat(vacoregno)#</td>
            </tr>
        </table>
	<cfelseif iGCOID IS 400002><!--- live is 400002 --->
	    <!--- Chola MS --->
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:100%" align=center>
			<!---<tr><td width=50% style="font-size:140%;font-weight:bold;color:dimgray;border-bottom:1px solid dimgray">Cholamandalam MS General Insurance<br>Company Limited</td><td align=right valign=top ><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>--->
			<tr><td align=left><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>

		</table>
	<!--- Start #29522 kofam --->
	<cfelseif iGCOID IS 205647>
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:100%" align=right>
			<tr><td align=left><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
			<tr>
				<td style="font-size:8pt;color:##666666;width:150px">
					<cfif vaADD1 NEQ "">#HTMLEditFormat(ucase(vaADD1))#,</cfif><cfif vaADD2 NEQ ""> #HTMLEditFormat(ucase(vaADD2))#</cfif> SINGAPORE #HTMLEditFormat(ucase(vaPOSTCODE))#
					<br>Co Reg No: #HTMLEditFormat(vaCOREGNO)#
					<br>GST Reg No: #HTMLEditFormat(vaTAXREGNO)#
				</td>
			</tr>
		</table>
	<!--- End #29522 kofam  --->
	<cfelseif iGCOID IS 500004>
		<!--- P&O (Motobiz) --->
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%"  align="center" background="">
		<tr><!---<td><IMG SRC="#request.webroot#MSupport/logo/#cologo#"></td>---><td align=center><span style="font-weight:bold;font-size:180%;font-family:Times New Roman">#ucase(vaconame)#</span><br><span style="font-size:80%">(No. #vaCOREGNO#)</span></td></tr>
		<tr><td style="font-style:italic;font-size:80%" align=center>A Member Of The Pacific & Orient Group</td></tr>
		<tr style="font-size:80%"><td align=center>#vaADD1#<cfif #vaADD2# IS NOT "">, #vaADD2#</cfif>, #vaPOSTCODE# #city#. <cfif #Attributes.COID# IS 38>P.O.Box 10953, 50730 Kuala Lumpur, Malaysia</cfif></td></tr>
		<tr style="font-size:80%"><td align=center>Telephone: #aTELNO# &nbsp;&nbsp;Fax: #aFAXNO# &nbsp;&nbsp;Toll Free No: 1 800 88 2121 &nbsp;&nbsp;Internet: www.poi2u.com</td></tr>
		</table>
	<cfelseif iGCOID IS 600559 OR iGCOID IS 900559>

		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%"  align="center" background="">
		<tr><td align=left width=15%><IMG SRC="#request.webroot#MSupport/logo/#cologo#"></td><td style="font-weight:bold;font-size:120%">#HTMLEditFormat(ucase(vaCONAME))#</td></tr>
		</table>
	<!---<CFELSEIF iGCOID IS 4>
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:100%" align=center>
			<tr style=line-height:500%>
				<td style=background-color:blue width=3%>&nbsp;</td>
				<td valign=top><IMG SRC="#request.webroot#MSupport/logo/msi.jpg"></td>
				<td valign=top style="font-size:210%;font-weight:bold">Mitsui Sumitomo Insurance</td>
				<td>
					<table border=0 cellPadding=0 cellSpacing=0 align=right style="WIDTH:100%;font-size:75%">
					<tr><td><br>&nbsp;</td></tr>
					<tr><td><b>Mitsui Sumitomo Insurance (M) Bhd</b> <span style="font-size:50%">(46883-W)</span></td></tr>
					<tr><td>Level 22, Menara Weld,</td></tr>
					<tr><td>No.76, Jalan Raja Chulan</td></tr>
					<tr><td>50200 Kuala Lumpur, Malaysia</td></tr>
					<tr><td>P.O. Box 11034, 50990 Kuala Lumpur</td></tr>
					<tr><td>Tel: 03-2050 8228</td></tr>
					<tr><td>Fax: 03-2070 1454</td></tr>
					<tr><td>E-mail: customerservice@ms-ins.com.my</td></tr>
					<tr><td>Website: www.ms-ins.com.my</td></tr>
					</table>
					</td></tr>
			<tr style=line-height:200%><td style=background-color:blue>&nbsp;</td><td colspan=3>&nbsp;</td></tr>
		</table>--->
	<cfelseif igcoid is 700004>
	<!---
	sdfsefsdfsdfdsfds
		<!--- asuransi raksa (indonesia) --->
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%"  align="center" background="">
		<tr><!---<td><IMG SRC="#request.webroot#MSupport/logo/#cologo#"></td>---><td align=center><span style="font-weight:bold;font-size:180%;font-family:Times New Roman">#ucase(vaconame)#</span> <span style="font-size:80%">(No. #vaCOREGNO#)</span></td></tr>
		<tr><td style="font-style:italic;font-size:80%" align=center>A Member Of The Pacific & Orient Group</td></tr>
		<tr style="font-size:80%"><td align=center>#vaADD1#<cfif #vaADD2# IS NOT "">, #vaADD2#</cfif>, #vaPOSTCODE# #city#. <cfif #Attributes.COID# IS 38>P.O.Box 10953, 50730 Kuala Lumpur, Malaysia</cfif></td></tr>
		<tr style="font-size:80%"><td align=center>Telephone: #aTELNO# &nbsp;&nbsp;Fax: #aFAXNO# &nbsp;&nbsp;Toll Free No: 1 800 88 2121 &nbsp;&nbsp;Internet: www.pacific-orient.com</td></tr>
		</table>
		--->
		<table id=COHEADER align="center" border="0">
			<tr><td colspan=3><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
			<tr><td width="10%" valign="top">Jakarta</td><td width="3%" valign="top">:</td><td width="87%">
			<cfif Trim(vaADD1) IS NOT "">#HTMLEditFormat(vaADD1)#,</cfif><cfif Trim(vaADD2) IS NOT ""> #HTMLEditFormat(vaADD2)#,</cfif><cfif STATE IS "Singapore">Singapore #Trim(vaPOSTCODE)#<cfelse>#Trim(vaPOSTCODE)# #CITY#<cfif CITY IS NOT STATE>, #STATE#</cfif></cfif><br>
			<cfif Trim(aTELNO) IS NOT "">Tel: #HTMLEditFormat(Trim(aTELNO))#</cfif><cfif Trim(aFAXNO) IS NOT "">&nbsp;&nbsp;Fax: #HTMLEditFormat(Trim(aFAXNO))#</cfif>
			<cfif Trim(vaEMAIL) IS NOT "">&nbsp;&nbsp;Email: #HTMLEditFormat(Trim(vaEMAIL))#</cfif>
			</div>
			</td></tr>
		</table>
	<cfelseif igcoid is 700088>
		<!--- PT Allianz (indonesia) --->
		<CFIF Attributes.LAYOUT IS 1>
			<table id=COHEADER align="center" border="0" style="font-size:90%;width:100%">
				<!--- <tr><td align=right><img SRC="#request.webroot#MSupport/logo/PTALZ.PNG"></td></tr> --->
				<tr> <!---#41275--->
					<td align=left><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
					<td align=right>#vaCONAME#</td>
				</tr>
				<!--- <tr><td align=right>#vaCONAME#</td></tr>
				<tr><td align=right>World Trade Centre 3</td></tr>
				<tr><td align=right>Jl. Jendral Sudirman Kav. 29-31</td></tr>
				<tr><td align=right>Jakarta Selatan 12920, Indonesia</td></tr>
				<tr><td align=right>Call Center: 1-500-136</td></tr>
				<tr><td align=right>cs@allianz.co.id</td></tr> --->
			</table>
		<CFELSEIF Attributes.LAYOUT IS 8>
			<table id=COHEADER align="center" border="0" style="width:100%">
				<!--- <tr><td align=right><img SRC="#request.webroot#MSupport/logo/CLMFORM_IDALZ.PNG"></td></tr> --->
				<tr> <!---#41275--->
					<td align=left><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
					<td align=right>#vaCONAME#</td>
				</tr>
			</table>
		<CFELSE>
			<table id=COHEADER align="center" border="0" style="font-size:90%;width:100%">
				<tr> <!---#41275--->
					<td align=left><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
					<td align=right>#vaCONAME#</td>
				</tr>
				<!--- <tr><td align=right>#vaCONAME#</td></tr>
				<tr><td align=right>#Trim(vaADD1)#</td></tr>
				<cfif Trim(vaADD2) IS NOT ""><tr><td align=right>#Trim(vaADD2)#</td></tr></CFIF>
				<tr><td align=right>#HTMLEditFormat(CITY)# #Trim(vaPOSTCODE)#, Indonesia</td></tr>
				<cfif Trim(aTELNO) IS NOT ""><tr><td align=right>Call Centre: #Trim(aTELNO)#</td></tr></CFIF>
				<!--- <cfif Trim(aFAXNO) IS NOT ""><tr><td align=right>Fax: #Trim(aFAXNO)#</td></tr></CFIF> --->
				<cfif Trim(vaEMAIL) IS NOT ""><tr><td align=right>#Trim(vaEMAIL)#</td></tr></CFIF> --->
			</table>
		</CFIF>

	<cfelseif igcoid is 700479>
		<!--- PT Indrapura --->
		<table id=COHEADER align="center" border="0" style="font-size:90%;width:100%">
			<tr><td width=70%></td><td rowspan=6 width=30% align=right><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
			<tr><td width=70%><b>#vaCONAME#</b></td></tr>
			<tr><td>#Trim(vaADD1)#</td></tr>
			<cfif Trim(vaADD2) IS NOT ""><tr><td>#Trim(vaADD2)# #HTMLEditFormat(STATE)# #Trim(vaPOSTCODE)# Indonesia</td></tr></CFIF>
			<tr><td>Telp: #Trim(aTELNO)# Fax: #Trim(aFAXNO)#</td></tr>
			<cfif Trim(vaEMAIL) IS NOT ""><tr><td>Email: #Trim(vaEMAIL)#</td></tr></CFIF>
			<tr><td>AAUI Member No. B.0082.2002</td></tr>
		</table>
	<cfelseif igcoid is 700503>
		<!--- PT Indrapura --->
		<table id=COHEADER align="center" border="1" style="font-size:90%;width:90%;border-collapse:collapse;" cellPadding=5>
			<tr><td align="center" style="width:20%">
					<img SRC="#request.webroot#MSupport/logo/#cologo#">
				</td>
    			<td style="text-align:justify">
	    			<p><b>#vaCONAME#</b><br />
	        		<span class="fAll">
	        			#Trim(vaADD1)#<cfif Trim(vaADD2) IS NOT "">, #Trim(vaADD2)#</cfif>, #HTMLEditFormat(STATE)# #Trim(vaPOSTCODE)#
	        		</span></p>
        		</td>
        		<td>
        			Telp.<br />
      				Fax.
        		</td>
        		<td style="text-align:justify">
        			#Trim(aTELNO)#<br />
        			#Trim(aFAXNO)#
        		</td>
			</tr>
		</table>
	<cfelseif igcoid is 700508>
		<!--- PT Indrapura --->
		<table id=COHEADER align="center" border="0" style="font-size:90%;width:100%">
			<tr><td><img SRC="#request.webroot#MSupport/logo/#cologo#" <cfif Attributes.Layout EQ 1>style="width:100px;height:100px"</cfif>></td>
			<cfif Attributes.Layout NEQ 1>
    			<td align="right"><p><b>#vaCONAME#</b><br />
        		<span class="fAll">#Trim(vaADD1)#<cfif Trim(vaADD2) IS NOT "">, #Trim(vaADD2)#</cfif>, #HTMLEditFormat(STATE)# #Trim(vaPOSTCODE)#<br />
      		Telp. : #Trim(aTELNO)#  (Hunting System)<br />
      		Fax. : #Trim(aFAXNO)#</span></p>
    		</td>
			</cfif>
			</tr>
		</table>
	<cfelseif igcoid is 701593>
		<table id=COHEADER align="center" border="0" style="font-size:85%;width:100%">
			<tr><td>
			<table border="0" style="font-size:85%;width=30%" align=right>
			 <tr><td>&nbsp;</td><td width="30px"><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
			<tr><td>&nbsp;</td><td>#vaCONAME#<BR>
			#Trim(vaADD1)#<BR>
			<cfif Trim(vaADD2) IS NOT "">#Trim(vaADD2)#, #HTMLEditFormat(STATE)# #Trim(vaPOSTCODE)#</cfif><br>
			T #Trim(aTELNO)# &nbsp;&nbsp; F #Trim(aFAXNO)#<br>
			www.avrist.com | bb.avrist.com
			</td></tr>
			</table>
			</td></tr>

		</table>
	<cfelseif iGCOID IS 702933>
		<cfif attributes.layout is 1>
			<table width="90%" border="0" cellspacing="0" align=center>
			  <tr>
			    <td colspan="8" align="center">&nbsp;</td>
			    <td width="165" rowspan="4" align="right"><img src="#request.webroot#MSupport/logo/MTI.jpg"></td>
			  </tr>
			</table>
		<cfelse>
			<table width="90%" border="0" cellspacing="0" align=center>
			  <tr>
			    <td colspan="8" align="center">&nbsp;</td>
			    <td width="165" rowspan="4" align="right"><img src="#request.webroot#MSupport/logo/ID-702933.gif"></td>
			  </tr>
			</table>
		</cfif>
	<cfelseif igcoid is 703035>
		<table id=COHEADER align="center" border="0" style="font-size:85%;width:100%">
			<tr><td>
			<table border="0" style="font-size:85%;width=30%" align=right>
		        <tr><td>&nbsp;</td><td width="30px"><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
			<tr><td>&nbsp;</td><td>#vaCONAME#<BR>
			#Trim(vaADD1)#<BR>
			<cfif Trim(vaADD2) IS NOT "">#Trim(vaADD2)#, #HTMLEditFormat(STATE)# #Trim(vaPOSTCODE)#</cfif><br>
			Tel: #Trim(aTELNO)# &nbsp;&nbsp; Fax: #Trim(aFAXNO)#<br>
			</td></tr>
			</table>
			</td></tr>
		</table>
	<cfelseif igcoid is 703734>
		<table id=COHEADER align="center" border="0" width=100% style="width:100%">
			<!---tr><td align="center"><img SRC="#request.webroot#MSupport/logo/#cologo#"></td--->
			<tr><td align="center"><img src="#request.webroot#MSupport/logo/#cologo#"></td>
		</table>
	<CFELSEIF iGCOID IS 700513 OR IGCOID IS 703921>

		<table id=COHEADER border="0" cellspacing="0" cellpadding="0" align="center" style="width:100%;font-family:Georgia,Times,Times New Roman,serif;font-size:12px">
			<tr>
				<td align=left valign=top style="width:40%"><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
				<td align=right style="width:60%">
					<table>
					<tr>
						<td width="60%">#vaCONAME#<br><span style="font-size:9px">(#vaCONAME# terdaftar dan diawasi oleh Otoritas Jasa Keuangan)</span><br><cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" COID=#igcoid# TARGET="TWOLINE" NOCONAME=1></td>
						<td width="60%" valign=top style="padding-left:16px;font-size:12px"><span style="display:inline-block;width:12px">O</span>&nbsp;&nbsp;#aTELNO#<br><span style="display:inline-block;width:12px">F</span>&nbsp;&nbsp;#aFAXNO#<br><span style="display:inline-block;width:12px">W</span>&nbsp;&nbsp;<cfif iGCOID IS 700513>www.chubb.com/id<cfelse>www.chubbsyariah.co.id</cfif></td>
					</tr>
					</table>
				</td>
			</tr>
		</table>
	<cfelseif igcoid is 800003>
		<!--- Toyota Algerie --->
		<table id=COHEADER align="center" border="0" width=100% style="width:100%">
			<tr><td align=left valign=top><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
			<td align=right style=width:50ex><table border=0 cellspacing=0 align=left style=width:50ex><tr><td><b>Si�ge social : </b></td><td>#HTMLEditFormat(Trim(vaADD1))#</td></tr>
			<tr><td><b>Code postal : </b></td><td>#HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(STATE)#, Alg�rie</td></tr>
			<tr><td><b>Tel : </b></td><td>#HTMLEditFormat(aTELNO)#</td></tr>
			<tr><td><b>Fax : </b></td><td>#HTMLEditFormat(aFAXNO)#</td></tr>
			<tr><td colspan=2><b>Site Web : </b> www.toyota-algerie.com</td></tr>
			<tr><td colspan=2 style="border-bottom:2px solid black;line-height:8px">&nbsp;</td></tr>
			<tr><td colspan=2 style="font-family:arial;font-size:200%;font-weight:bold">TOYOTA ALGERIE</td></tr></table></td></tr>
		</table>
	<cfelseif igcoid is 1000001>
		<!--- BPI/MS --->
		<table id=COHEADER align="center" border="0" width=100% style="width:100%;font-size:80%">
			<tr><td colspan=2 align=center valign=top><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
			<!---><tr><td style=width:18ex>&nbsp;</td><td>#Trim(vaADD1)#, <cfif Trim(vaADD2) IS NOT "">#Trim(vaADD2)#, </CFIF> #vaPOSTCODE# #city# Tel. No. #HTMLEditFormat(aTELNO)#</td></tr>--->
		</table>
	<cfelseif igcoid is 1000615>
		<!--- MAA PH --->
		<table id=COHEADER cellpadding=0 cellspacing=0 align="center" border="0" width=100% style="width:100%;font-size:80%">
			<tr><td align=center valign=top><img SRC="#request.webroot#MSupport/logo/#cologo#" height="40"></td></tr>
			<tr><td align=center valign=top style="font-family:Optima,times new roman">
			<div style="font-size:10pt;font-weight:bold">#htmleditformat(vaCONAME)#</div>
			<div style="font-size:8pt;font-weight:bold">
				#HTMLEditFormat(Trim(vaADD1))#<cfif trim(vaADD2) NEQ "">, #HTMLEditFormat(Trim(vaADD2))#</cfif>, #HTMLEditFormat(city)# #HTMLEditFormat(vaPOSTCODE)#
				<br>Tel: #htmleditformat(aTELNO)# &nbsp;&nbsp; Fax: #htmleditformat(aFAXNO)#
			</div>
			</td></tr>
			<!---><tr><td style=width:18ex>&nbsp;</td><td>#Trim(vaADD1)#, <cfif Trim(vaADD2) IS NOT "">#Trim(vaADD2)#, </CFIF> #vaPOSTCODE# #city# Tel. No. #HTMLEditFormat(aTELNO)#</td></tr>--->
		</table>
	<cfelseif igcoid is 1100001>
		<!--- Thai MSI --->
		<CFIF ATTRIBUTES.LAYOUT EQ 0>
		<table id=COHEADER align="center" border="0" width=100% style="width:100%;font-size:75%">
			<tr><td colspan=2 align=left valign=top width=180px><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
				<td><b>#vaCONAME#</b> <br>
					#HTMLEditFormat(vaADD1)#<CFIF vaADD2 IS NOT "">, #HTMLEditFormat(vaADD2)#</CFIF>, #HTMLEditFormat(city)# #HTMLEditFormat(vaPOSTCODE)#, Thailand<br>
					Tel #aTELNO#, &nbsp;&nbsp;Fax #aFAXNO#, &nbsp;&nbsp;Service Feedback +66(0) 2679 6699<br>
					<b>www.msig-thai.com</b></td></tr>

		</table>
		<CFELSEIF ATTRIBUTES.LAYOUT EQ 1>
		<table id=COHEADER border="0">
			<tr><td align=left valign=top width=180px><img SRC="#request.webroot#MSupport/logo/MSI_RepairOrder.gif" style="height:100px;width:1000px"></td></tr>
		</table>
		</CFIF>
	<cfelseif igcoid is 1101177>
		<!--- Thai TMI --->
		<table id=COHEADER align="center" border="0" width=100% style="width:100%">
			<tr><td>
				<table celllspacing=0 cellpadding=0 align="center">
				<tr><td align=left valign=top width=160px><img SRC="#request.webroot#MSupport/logo/TMG2.jpg"></td>
					<td width=700px><b>บริษัท โตเกียวมารีนประกันภัย (ประเทศไทย) จำกัด (มหาชน)<br>
							Tokio Marine Insurance (Thailand) Public Company Limited<br></b>
							เลขที่ 1 อาคารเอ็มไพร์ทาวเวอร์ ชั้น 40 ถนนสาทรใต้ แขวงยานนาวา เขตสาทร กรุงเทพฯ 10120<br>
							1 Empire Tower 40th Fl., South Sathom Rd., Yannawa,Sathorn, Bangkok 10120<br>
							Tel.: (02) 686 8888 Fax.:(02) 686 8601/ (02) 686 8603<br>
							Email: info@tokiomarine.co.th  <b>http://www.tokiomarine.com/th</b>
					</td>
				</tr>
				</table>
			</td></tr>
		</table>
	<cfelseif iGCOID IS 201279>
		<div id=COHEADER align=#Attributes.ALIGN# style=width:100%>
		<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" TARGET="TWOLINE" NOCOREGNO=0 CONAMEATTR="style=color:darkred;text-align:left;font-size:160%" CONAME=#vaCONAME# COREGNO=#vaCOREGNO# COTAGLINE=#vaCOTAGLINE# ADD1=#vaADD1# ADD2=#vaADD2# POSTCODE=#vaPOSTCODE# CITYID=#iCITYID#><br>
		<cfif Trim(aTELNO) IS NOT "">Tel: #HTMLEditFormat(Trim(aTELNO))#</cfif>
		<cfif Trim(aFAXNO) IS NOT ""><br>Fax: #HTMLEditFormat(Trim(aFAXNO))#</cfif>
		<cfif Trim(vaEMAIL) IS NOT ""><br>Email: #HTMLEditFormat(Trim(vaEMAIL))#</cfif>
		</div>
	<cfelseif iGCOID IS 203156>
		<div id=COHEADER align=center style="width:100%;font-style:italic">
		<img SRC="#request.webroot#MSupport/logo/SG-203156.png"><br>
		<div style="color:black;font-size:220%;font-family:times new roman;font-weight:bold">#vaCONAME#</div>
		<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" TARGET="ONELINE" NOCONAME=1 NOCOREGNO=1 CONAMEATTR="style=color:black;text-align:left;font-size:160%" CONAME=#vaCONAME# COREGNO=#vaCOREGNO# COTAGLINE=#vaCOTAGLINE# ADD1=#vaADD1# ADD2=#vaADD2# POSTCODE=#vaPOSTCODE# CITYID=#iCITYID#>
		<cfif Trim(aTELNO) IS NOT "">Tel: #HTMLEditFormat(Trim(aTELNO))#</cfif>
		<cfif Trim(vaEMAIL) IS NOT "">Email: #HTMLEditFormat(Trim(vaEMAIL))#</cfif>
		<cfif Trim(vaCOREGNO) IS NOT ""><br>Company Register No. #HTMLEditFormat(Trim(vaCOREGNO))#</cfif>
		</div>
	<cfelseif iGCOID IS 1500001>
		<!---><table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 100%" align="center" background="">
			<tr><td rowspan=8 width=20%><img SRC="#request.webroot#MSupport/logo/#cologo#"></td><td align="left" style="font-size:90%"><b>#vaCONAME#<cfif #vaCOREGNO# IS NOT "">&nbsp;(#vaCOREGNO#)</cfif> </b></td></tr>
	 		<tr><td align="left" style="font-size:80%">#vaADD1#</td></tr>
			<cfif #vaADD2# IS NOT ""><tr><td align="left" style="font-size:80%">#vaADD2#</cfif></td></tr>
 		    <tr><td align="left" style="font-size:80%">#HTMLEditFormat(vaPOSTCODE)# #city#</td></tr>
		    <tr><td align="left" style="font-size:80%">Telephone:&nbsp;#HTMLEditFormat(aTELNO)#</td></tr>
			<cfif #aFAXNO# IS NOT ""><tr><td align="left" style="font-size:80%">Facsimile:&nbsp;#HTMLEditFormat(aFAXNO)#</td></tr></cfif>
		</table>--->
		<table id=COHEADER border="0" cellPadding="1" cellSpacing="1" style="WIDTH:100%" align="center">
		<tr><td align=left valign=top><img SRC="#request.webroot#MSupport/logo/#cologo#"><br>&nbsp;</td></tr>
		</table>
		<table border="0" cellPadding="1" cellSpacing="1" style="WIDTH:100%;font-size:100%" align="center">
			<tr><td id="COHEADER" valign=top width=150px><img SRC="#request.webroot#MSupport/logo/AIG-new-MYHQaddress.png"></td>
			<td valign=top>
	<cfelseif iGCOID IS 1510001>
		<!--- Mitsui Sumitomo --->
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:80%;font-family:Trebuchet MS" align=center>
            <tr>
                <td rowspan=2 style="width:20%;vertical-align:top"><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
                <td colspan=2 ><h2><b>MSIG Insurance (Vietname) Company Limited</h2></td>
            </tr>
            <tr>
                <td style="width:40%;vertical-align:top">
                    <b>Hanoi Head Office</b>
                    <br>10th Floor, CornerStone Building
                    <br>No. 16, Phan Chu Trinh Street, Phan Chu Trinh Ward, Hoan Kiem District, Hanoi, Vietnam
                    <br>Tel: (84.4) 3936 9188 | Fax: (84.4) 3936 9187
                    <br>Email: Claims@vn.msig-asia.com
                </td>
                <td style="width:50%;vertical-align:top">
                    <b>HoChiMinh City Branch</b>
                    <br>19th Floor, Vincom Center
                    <br>72 Le Thanh Ton Street, District 1, Ho Chi Minh City, Vietnam
                    <br>Tel:(84.8) 3821 9030 | Fax: (84.8) 3821 9029
                    <br>Website: www.msig.com.vn
                </td>
            </tr>
		</table>
	<cfelseif iGCOID IS 1500111>
		<!--- Toyota Hadong VN --->
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:100%;font-family:Trebuchet MS" align=center>
            <tr>

                <td><span style="font-size:10pt;font-weight:bold;"><b>#vaCONAME#</b><!--- TOYOTA  HÀ ĐÔNG ---></span>
					<br>#HTMLEditFormat(vaADD1)#<CFIF vaADD2 IS NOT "">, #HTMLEditFormat(vaADD2)#</CFIF><!--- Do Lộ - Yên Nghĩa - Hà Đông - Hà Nội --->
                    <br><!--- Tell: 04.3353.5858 ---> <!--- -  Fax: 04.3353.5859 --->
					<cfif Trim(aTELNO) IS NOT ""> Tel: #HTMLEditFormat(REReplace(Trim(aTELNO)," ",".","ALL"))#  </CFIF><cfif Trim(aFAXNO) IS NOT "">Fax: #HTMLEditFormat(REReplace(Trim(aFAXNO)," ",".","ALL"))#</cfif>
					<br>MST: 0500585974
				</td>
				<td rowspan=2 style="width:20%;vertical-align:top;text-align:right"><img SRC="#request.webroot#MSupport/logo/toyota_VN.GIF"  height="50px" width="350px"></td>
            </tr>
 		</table>
	<cfelseif iGCOID IS 325 AND listFindNoCase("DEV,UAT", APPLICATION.DB_MODE)>
		<div id=COHEADER align=#Attributes.ALIGN# style=width:100%>
			<table cellpadding="0" cellspacing="0" border="0" align=center width=80%>
				<tr><td align=left><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
				<tr><td align=left><b>#vaCONAME#</b> (#vaCOREGNO#)
				<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" TARGET="TWOLINE" ADD1=#vaADD1# ADD2=#vaADD2# POSTCODE=#vaPOSTCODE# CITYID=#iCITYID#>
				<cfif Trim(aTELNO) IS NOT "">Tel: #HTMLEditFormat(Trim(aTELNO))#</cfif><cfif Trim(aFAXNO) IS NOT "">&nbsp;&nbsp;Fax: #HTMLEditFormat(Trim(aFAXNO))#</cfif>
				<cfif Trim(vaEMAIL) IS NOT "">&nbsp;&nbsp;Email: #HTMLEditFormat(Trim(vaEMAIL))#</cfif><BR>
		         #TAXNo(type="HTML",span="",BRFront="no",BRend='yes')#</td></tr>

	    	</table>
		</div>
	<cfelseif iGCOID IS 203443>
	 	<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial" align="center" background="">
			<tr><td valign="top" align='center'>
					<img SRC="#request.webroot#MSupport/logo/#cologo#">
					<div style="font-size:8pt;text-align:center">(Co. Reg. No: #HTMLEditFormat(vacoregno)#)</div>
				</td>
			</tr>
			<tr><td>
				<div style="text-align:center;font-size:8pt;align:center">#vaADD2#<cfif vaADD1 NEQ ""> #vaADD1#</cfif> (S) <cfif vaPOSTCODE NEQ "">#vaPOSTCODE#</cfif>
				<br><cfif Trim(aTELNO) IS NOT "">Tel: #HTMLEditFormat(Trim(aTELNO))#</cfif><cfif Trim(aFAXNO) IS NOT "">&nbsp;&nbsp;Fax: #HTMLEditFormat(Trim(aFAXNO))#</cfif>
				<br><cfif Trim(vaEMAIL) IS NOT "">&nbsp;&nbsp;Email: #HTMLEditFormat(Trim(vaEMAIL))#</cfif><br>
				</div>
			</td></tr>
			</tr>
		</table>
	<cfelseif iGCOID IS 203148>
	 	<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial" align="center" background="">
			<tr><td valign="top" align='center' style="border-bottom:1px solid black">
					<img SRC="#request.webroot#MSupport/logo/#cologo#">
				</td>
			</tr>
		</table>
	<!--- <cfelseif iGCOID IS 703921>
	 	<!---<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial" align="center" background="">
			<tr><td style="vertical-align:center">
                    <div style="float:left;width:10%">
                        <img SRC="#request.webroot#MSupport/logo/japrotakaful_marimari3.jpg" width=130%>
                    </div>
                    <div style="float:left;width:85%" align=right>
                            <img SRC="#request.webroot#MSupport/logo/#cologo#" width=40%>
<!---
                        <br> <img SRC="#request.webroot#MSupport/logo/japrotakaful_address.jpg" width=60%>
--->
                    <div>
				</td>
			</tr>
			<tr><td>
			</tr>
		</table>--->
		<!--- 20054 Revised header. Comment out the table block below to disable --->
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial" align="center" background="">
			<tr>
				<td style="vertical-align:center" width=50%>
                    <div style="float:left;width:100%">
						<!--- #cologo# --->
						<img SRC="#request.webroot#MSupport/logo/ID-703921_V_NEW.png" width=30%>
                    <div>
				</td>
				<td valign=top width=50%>
					<div style="float:right;font-family:Georgia">
						PT. Asuransi Chubb Syariah Indonesia<br>
						Jl. Mangga Dua Raya,<br>Komp. Ruko Grand Boutique Centre Blok E/2-4,<br>Jakarta 14430, Indonesia
					</div>
				</td>
			</tr>
			<tr>
				<td></td>
				<td></td>
			</tr>
		</table> --->
		<!--- 20054 end --->
	<cfelseif iGCOID IS 700510 and Attributes.LAYOUT IS 1>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial" align="center" background="">
			<tr>
				<td align="center"><img SRC="#request.webroot#MSupport/logo/ID-aswata-header.jpg" width="100%"></td>
			</tr>
			<tr><td align="center" style="font-family:tahoma">CLAIM HANDLING MV & HE DEPARTMENT</td></tr>
		</table>
	<cfelseif iGCOID IS 704145>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:90%;font-family:arial" align="center" background="">
			<tr>
                <td style="vertical-align:top;font-size:80%">#fAddrOut(q_co)#</td>
				<td style="text-align:right"><img SRC="#request.webroot#MSupport/logo/ptmustika.png" width=30%></td>
			</tr>
		</table>
	<cfelseif iGCOID IS 200029>
        <table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:90%;font-family:arial" align="center" background="">
            <tr>
				<!--- <td align="left"><img SRC="#request.webroot#MSupport/logo/SG-axa-left.jpg"> </td>
				<td>&nbsp;</td>
				<td align="right"><img SRC="#request.webroot#MSupport/logo/SG-axa-right.jpg"> </td> --->
				<td align="left"><img SRC="#request.webroot#MSupport/logo/SG-axa-left3.jpg"> </td>
				<!--- <td align="right"><img SRC="#request.webroot#MSupport/logo/SG-axa-right2.jpg" width="70%"> </td> --->
			</tr>
        </table>
	<cfelseif iGCOID IS 700456>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial" align="center" background="">
			<tr>
				<td align="left"><img src="#request.webroot#MSupport/logo/ID-Asoka-v2.png"></td>
				<td></td>
				<td align="right"><div><img src="#request.webroot#MSupport/logo/ID-mari-berasuransi.gif" width="20%" height="20%"></div></td>
			</tr>
		</table>
	<cfelseif iGCOID IS 705997>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial" align="center" background="">
			<tr>
				<td align="center"><img src="#request.webroot#MSupport/logo/ID-705997.jpg"></td>
			</tr>
		</table>
	<cfelseif iGCOID IS 200078>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial" align="center" background="">
			<tr>
				<td align=center><img src="#request.webroot#MSupport/logo/SG-motorimage.png" width="180px" height="45px"></td>
				<td align=center style="width:70%;">#fAddrOut(q_co)#</td>
				<td align=center><img src="#request.webroot#MSupport/logo/subaru.jpg" width="180px" height="108px"></td>
			</tr>
		</table>
	<cfelseif iGCOID IS 204147>
		<cfif attributes.layout IS 1 >
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial" align="center" background="">
			<tr>
				<td align="left"><img src="#request.webroot#MSupport/logo/sg_fwd.png" height="118px" width="317px"></td>
			</tr>
		</table>
		<cfelseif attributes.layout IS 2 >
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial" align="center" background="">
			<tr>
				<td align="right"><img src="#request.webroot#MSupport/logo/sg_fwd_logo.png" height="63" width="149px"></td>
			</tr>
		</table>
		<cfelse>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:90%;font-family:arial" align="center" background="">
			<tr>
				<td align="left"><img src="#request.webroot#MSupport/logo/sg_fwd.png" height="118px" width="317px"></td>
			</tr>
		</table>
		</cfif>
	<cfelseif igcoid IS 1510012 OR igcoid IS 1510007>
		<cfif igcoid IS 1510007>
		<table id=COHEADER border="0" style="WIDTH:100%;font-family:arial;" align="center" background="">
			<tr style="WIDTH:100%;font-family:Times new roman;font-size:15;" >
				<td align="center" width="20%"><img SRC="#request.webroot#MSupport/logo/#hq_cologo#" height="80px" width="200px" align="center"></td>
				<td width="10%">&nbsp;</td>
				<td width="70%"><b>CỘNG HOÀ XÃ HỘI CHỦ NGHĨA VIỆT NAM
				<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<u>Độc lập – Tự do – Hạnh phúc</u></b></td>
			</tr>
			<tr><td colspan="3" style="font-size: 8px">&nbsp;</td></tr>
			<tr><td colspan="3"><b>Đơn vị: ..........................</b></td></tr>
			<tr><td colspan="3" style="font-size: 10px;">&nbsp;</td></tr>
			<!--- <tr>
				<td width="20%">&nbsp;</td>
				<td width="20%">&nbsp;</td>
				<td width="50%">#fAddrOut(q_co)#</td>
				<td width="10%">&nbsp;</td>
			</tr> --->
		</table>
		<cfelseif igcoid IS 1510012>
			<table id=COHEADER border="0" style="WIDTH:100%;font-family:arial;" align="center" background="">
			<tr style="WIDTH:100%;font-family:Times new roman;font-size:15;" >
				<td align="center" width="20%"><img SRC="#request.webroot#MSupport/logo/#hq_cologo#" height="80px" width="200px" align="center"></td>
				<td width="20%">&nbsp;</td>
				<td width="50%"><b>CỘNG HOÀ XÃ HỘI CHỦ NGHĨA VIỆT NAM
				<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<u>Độc lập – Tự do – Hạnh phúc</u></b></td>
				<td width="10%">&nbsp;</td>
			</tr>
		</table>
		</cfif>
	<cfelseif iGCOID IS 704714>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:90%;font-family:arial" align="center" background="">
			<tr>
				<td align="center"><img SRC="#request.webroot#MSupport/logo/#cologo#" height="118px" width="317px"></td>
			</tr>
		</table>
	<cfelseif iGCOID IS 701479><!--- #19334 --->
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial" align="center" background="">
			<tr>
				<td align="right"><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
				<td>&nbsp;</td>
			</tr>
		</table>
	<cfelseif iGCOID IS 1510010><!--- #19334 --->
		<!---<cfif IsDefined("Attributes.HEADERTYPE") and Attributes.HEADERTYPE eq 1>--->
			<table id=COHEADER border="0" cellPadding="5" cellSpacing="0" style="WIDTH:100%;font-family:arial;border-bottom:1px solid black" align="center" background="">
				<tr>
					<td width=13%><img height=49px width=80px SRC="#request.webroot#MSupport/logo/#cologo#"></td>
					<td width=1%></td>
					<td valign=bottom width=86%><span style="color:##1D548B;font-size:20px">United Insurance Company of Vietnam</span></td>
				</tr>
			</table>
	<cfelseif iGCOID IS 204324>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:90%;font-family:arial" align="center" background="">
            <tr>
				<td align="left"><img SRC="#request.webroot#MSupport/logo/ag_bd.png"></td>
				<td>&nbsp;</td>
				<td align="right"><table><tr><td>Contact us at: </td></tr><tr><td><b><font color="red">T: </font></b>+65 6221 2199</td></tr><tr><td><b><font color="red">F:</font></b> +65 6725 0605</td></tr><tr><td><b><font color="red">E:</font></b> motorclaims@budgetdirect.com.sg</td></tr></table></td>
			</tr>
        </table>
		<!---</cfif>--->
	<CFELSEIF iGCOID IS 200098>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%";align="right" background="">
            <tr>
				<td align="right"><img SRC="#request.webroot#MSupport/logo/SG_EQ_header_v2.jpg"></td>
			</tr>
        </table>
	<CFELSEIF iGCOID IS 1402015 AND IsDefined("ATTRIBUTES.CONTENT1") AND IsDefined("ATTRIBUTES.CONTENT2") AND IsDefined("ATTRIBUTES.CONTENT3")>
		<table border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%";align="LEFT" background="">
        <tr>
			<td align="right" colspan=3><table border="0" id=COHEADER align="right"><tr><td><img SRC="#request.webroot#MSupport/logo/hkzurich_head.png" width="100px"></td>
			</tr></table></td>
		</tr>
		<tr>
			<td>#ATTRIBUTES.CONTENT1#</td>
			<td width="20px">&nbsp;</td>
			<td align="left" colspan=2 valign=top>#ATTRIBUTES.CONTENT2#</td>
		</tr>
		<tr>
			<td id="removeWidth" width="15%"><table  border="0" id=COHEADER align="right"><tr><td align="right"><b>Zurich Insurance Company Ltd</b> <br>(a company incorporated in Switzerland)<br><br>25-26/F, One Island East<br>18 Westlands Road<br>Island East, Hong Kong<br><br>Telephone +852 2968 2222<br>Fax +852 2968 0988<br>
				http://www.zurich.com.hk</td></tr></table></td>
			<td width="15px">&nbsp;</td>
			<td>#ATTRIBUTES.CONTENT3#</td>
		</tr>
		</table>
	<CFELSEIF iGCOID IS 1402015>
		<!--- Text and Logo Only --->
		<table border="0" id=COHEADER align="right"><tr><td><img SRC="#request.webroot#MSupport/logo/hkzurich_head.png" width="100px"></td>
			</tr></table>
		<div id=COHEADER align=#Attributes.ALIGN# style=width:100%>
			#fAddrOut(q_co)#
		</div>
		<!--- <table border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%";align="LEFT" background="">
        <tr>
			<td align="right" colspan=3><table border="0" id=COHEADER align="right"><tr><td><img SRC="#request.webroot#MSupport/logo/hkzurich_head.png" width="100px"></td>
			</tr></table></td>
		</tr>
		</table> --->
	<cfelseif iGCOID IS 1402014>
		<!--- Liberty HK --->
		<table id=COHEADER border=0 cellPadding=3 cellSpacing=1 style="WIDTH:100%;font-size:100%" align=center>
			<tr><td align=left><img SRC="#request.webroot#MSupport/logo/liberty_hk1.jpg" width="200px"></td>
				<td align=right>
					<table>
						<tr><td><img SRC="#request.webroot#MSupport/logo/liberty_hk2.jpg" width="200px"></td></tr>
						<tr><td style="font-size:85%">13/F, Berkshire House,</td></tr>
						<tr><td style="font-size:85%">25 Westlands Road,</td></tr>
						<tr><td style="font-size:85%">Quarry Bay, Hong Kong</td></tr>
						<tr><td style="font-size:85%">Tel:&nbsp;(852)2892 3888&nbsp; Fax:&nbsp;(852)2577 9578&nbsp;</td></tr>
						<tr><td style="font-size:85%">www.libertyinsurance.com.hk</td></tr>
					</table>
				</td>
			</tr>
		</table>
	<cfelseif igcoid is 1000835>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial" align="center" background=""> <tr><td align=center><img SRC="#request.webroot#MSupport/charter-etender.gif" height="50%" width="90%"></td></tr> </table>
	<cfelseif igcoid is 700469>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial" align="center" background=""> <tr><td align=center><img SRC="#request.webroot#MSupport/logo/ID-ACA.jpg" height="50%"></td></tr> </table>
	<cfelseif igcoid is 1000830>
		<table id=COHEADER  border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%">
			<tr>
				<cfif attributes.layout IS 1>
					<td width="5%">&nbsp;</td>
				</cfif>
				<td align="left"><img SRC="#request.webroot#MSupport/logo/ph_paramount.png" width="170px"></td>
			</tr>
		</table>
	<cfelseif igcoid is 700480>
		<table id=COHEADER  border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%">
			<tr>
				<td align="center"><img SRC="#request.webroot#MSupport/logo/IntraAsia.png" width="150px"></td>
			</tr>
		</table>
	<!--- start #39476 --->
	<cfelseif igcoid is 700488>
		<table id=COHEADER  border="0" cellPadding="0" cellSpacing="0" style="WIDTH:90%" align=center>
			<tr><td><img SRC="#request.webroot#MSupport/logo/ID-mari-berasuransi.gif" width="70px"></td>
				<td align=right><img SRC="#request.webroot#MSupport/logo/ID-maximus.jpg" width="200px"></td>
			</tr>
		</table>
	<!--- end #39476 --->
	<cfelseif igcoid is 40><!--- #22567 --->
		<table id=COHEADER  border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%">
			<tr>
				<td colspan="2" align="center"><img SRC="#request.webroot#MSupport/logo/#hq_cologo#" width="30%"></td>
			</tr>
			<tr>
				<td colspan="2" align="center"><b>#Server.SVClang("Registration No.",3001)#: #vaCOREGNO#/(#vaCOREGNO_OLD#)</b></td>
			</tr>
			<tr>
				<td>&nbsp</td>
			</tr>
			<tr >
				<td style="font-size:60%;font-style:italic"><b>HEAD OFFICE</b></td>
				<td style="font-size:60%;">6th,  9th & 10th Floors, Menara Cosway Plaza Berjaya, No.12, Jalan Imbi, 55100 Kuala Lumpur, P.O.Box 10028, 50700 Kuala Lumpur Tel :03-21188000 Fax: 03-21188098, 21188100 </td>
			</tr>
			<tr>
				<td style="font-size:60%;font-style:italic"><b>KOTA KINABALU OFFICE</b></td>
				<td style="font-size:60%;">Ground & 7th Floor, Wisma Perkasa, Jalan Gaya, P.O. Box 13936, 88845 Kota Kinabalu, Sabah. Tel: 088-244216 Fax: 088-218004	</td>
			</tr>
			<tr>
				<td style="font-size:60%;font-style:italic"><b>KUCHING OFFICE</b></td>
				<td style="font-size:60%;">Sublot 11 & 12 Lots 9966 & 9967, First Floor, Premier 101, Jalan Tun Jugah, 93350 Kuching P.O. Box 2749, 93754 Kuching, Sarawak Tel: 082-572019,572030 & 572031 Fax:082-572013</td>
			</tr>
			<tr>
				<td style="font-size:60%;font-style:italic"><b>SANDAKAN OFFICE</b></td>
				<td style="font-size:60%;">1st Floor, Lot 1, Block 3, Bandar Indah, Mile 4, North Road, 90000 Sandakan, Sabah. Tel: 089-238810  Fax:089-237709</td>
			</tr>
			<tr>
				<td style="font-size:60%;font-style:italic"><b>BUTTERWORTH OFFICE</b></td>
				<td style="font-size:60%;">2755, Ground & 1st Floor, Jalan Chain Ferry, Taman Inderawasih, 13600 Prai, Seberang Prai Tengah, Penang.  Tel: 04-3977128  Fax: 04-3977126</td>
			</tr>
			<tr>
				<td style="font-size:60%;font-style:italic"><b>JOHOR BAHRU OFFICE</b></td>
				<td style="font-size:60%;">No. 17-01, Jalan Kebun Teh 1, Pusat Perdagangan Kebun Teh, 80250 Johor Bahru, Johor. Tel: 07-2270991 / 2   Fax: 07-2270996                                        </td>
			</tr>
			<tr>
				<td style="font-size:60%;font-style:italic"><b>MELAKA OFFICE</b></td>
				<td style="font-size:60%;">13-A, Jalan Melaka Raya 24, Taman Melaka Raya, 75000 Melaka.  Tel: 06-2883831  Fax: 06-2883832</td>
			</tr>
		</table>
	<cfelseif igcoid is 1000920>
		<table id=COHEADER align="center" border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%">
			<tr>
				<cfif attributes.layout IS 1>
					<td width="5%">&nbsp;</td>
				</cfif>
				<cfif attributes.layout IS 2>
					<td align="left"><img SRC="#request.webroot#MSupport/logo/ph_cgic_header002.png" width="100%"></td>
				<cfelse>
					<td align="left"><img SRC="#request.webroot#MSupport/logo/ph_cgic_header.PNG" width="100%"></td></td>
				</cfif>
			</tr>
		</table>
	<cfelseif igcoid is 705604>
		<table id=COHEADER  border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%">
			<tr><td align="center"><img SRC="#request.webroot#MSupport/logo/#cologo#" width="10%"></td></tr>
			<tr><td align="center" style="font-size:85%">Graha Mustika Ratu, Lantai 1, Jl. Jend. Gatot Subroto Kav 74-75, Jakarta 12870. Indonesia</td></tr>
			<tr><td align="center" style="font-size:85%">Phone:(62-21)83709055(Hunting),830 6575 Fax.:(62-21)8306620,8306741</td></tr>
			<tr><td align="center" style="font-size:85%">http://www.videi-insurance.co.id e-mail: kp@videi-insurance.co.id</td></tr>
		</table>
	<cfelseif igcoid is 203273>
		<table id=COHEADER  border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%">
			<tr>
				<cfif attributes.layout IS 1>
					<td width="5%">&nbsp;</td>
				</cfif>
				<td align="left"><img SRC="#request.webroot#MSupport/logo/SG_ECICS.jpg" width="170px"></td>
			</tr>
		</table>
	<CFELSEIF igcoid is 216 AND listFindNoCase("DEV,UAT", APPLICATION.DB_MODE)>
		<div width="90%" align="center">
			<!--- <img SRC="#request.webroot#MSupport/logo/MSM.png">
			 --->
			 <span style="font-family: Century Gothic;font-size: 300%">International</span>
			 <br>
			 <span style="font-family: Century Gothic;font-size: 300%;font-weight: bold;font-">International</span>
			 <br>
			 <span style="font-family: Century Gothic;font-size: 150%"><b>MSM International Adjuster (Malaysia) Sdn. Bhd. (14645-T)</b><br>Suite 3A-08, Level 8 Block 3A, Plaza Sentral,<br>Jalan Stesen Sentral 5, 50470 Kuala Lumpur, Malaysia.</span>
		</div>
	<CFELSEIF igcoid is 81 AND listFindNoCase("DEV,UAT", APPLICATION.DB_MODE)>
		<div width="100%" align="center">
			<table width=100%>
				<col width=80%><col><col>
				<tr><td>&nbsp;</td><td>
					<!---cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" TARGET="" NOCOREGNO=0 CONAMEATTR="style=color:black;text-align:right;font-size:130%" CONAME=#vaCONAME# COREGNO=#vaCOREGNO#  ADD1=#vaADD1# ADD2=#vaADD2# POSTCODE=#vaPOSTCODE# CITYID=#iCITYID#--->
		<span style="font-size: 160%;font-family: cambria"><strong>#vaCONAME#</strong></span> <span style="font-family: cambria">(#vaCOREGNO#)</span><br>
		<CFIF vaADD1 NEQ ""><span style="font-family: cambria">#vaADD1#</span></CFIF>
		<CFIF vaADD2 NEQ ""><Br><span style="font-family: cambria">#vaADD2#</span></CFIF> <span style="font-family: cambria"><cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" NOCOREGNO=1 POSTCODE=#vaPOSTCODE# CITYID=#iCITYID#></span>
		<cfif Trim(aTELNO) IS NOT ""><br>Tel: #HTMLEditFormat(Trim(aTELNO))#</cfif>
		<cfif Trim(aFAXNO) IS NOT ""><br>Fax: #HTMLEditFormat(Trim(aFAXNO))#</cfif>
		</td><td><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
			</table>
		</div>
	<CFELSEIF igcoid is 166>
		<CFIF attributes.layout EQ 0>
			<div id=COHEADER align=#Attributes.ALIGN# style=width:100%>
				#fAddrOut(q_co)#
			</div>
		<CFELSEIF attributes.layout EQ 1>
		<CFIF Attributes.width EQ "100%"><cfset margin="0%"><cfelse><cfset margin="4%"></CFIF>
			<table width="100%" align="center" style="margin-left:#margin#">
				<tr><td width="10%" style="text-align:right"><img SRC="#request.webroot#MSupport/logo/EliteAdj_cologo.jpg"></td>
				<td width=2%>&nbsp;</td>
				<td width="65%" style="text-align:center;">#fAddrOut(q_co)#</td>
				<td width=23%>&nbsp;</td>
				</tr>
			</table>
		</CFIF>
	<CFELSEIF igcoid is 45705>
		<table id=COHEADER  border="0" cellPadding="0" cellSpacing="0" style="WIDTH:90%" align="center">
			<tr>
				<td align="center"><img SRC="#request.webroot#MSupport/logo/syeliza&partners_header.PNG"></td>
			</tr>
		</table>
	<CFELSEIF igcoid is 1511995>
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:80%;font-family:Times New Roman">
			<tr>
				<td width=10%></td>
				<td width=10% rowspan=3 style="vertical-align:bottom" align="center">
					<img width="75" height="100" style="margin-left: 0.6em;margin-right: 0.6em; padding-bottom:0.3em;" SRC="#request.webroot#MSupport/logo/#cologo#">
				</td>
				<td width=80% style="color:red;font-weight:bold;padding-left:10px">
					<span style="font-size:10px">TỔNG CÔNG TY CỔ PHẦN BẢO MINH</span>
					<br><span style="font-size:24px">BẢO MINH</span>
				</td>
			</tr>
			<tr>
				<td style="background:red;color:white;font-size:8px;">&nbsp;ISO 9001: 2000</td>
				<td style="background:red;color:white;font-size:8px;">
					&emsp;26 Tôn Thất Đạm, Quận 1, Tp.HCM - ĐT: 84.8.8294180 - Fax: 84.8.8294185 * Email: baominh.com.vn – Website: www.baominh.com.vn
				</td>
            </tr>
		</table>
	<!--- Start #33414 kofam --->
	<CFELSEIF icoid is 1000798>
		<CFIF Attributes.LAYOUT IS 0>
			<table id=COHEADER  border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%">
				<tr><td>&nbsp;</td></tr>
				<tr><td align="left"><img SRC="#request.webroot#MSupport/logo/#cologo#" height="130%"></td></tr>
				<tr><td>&nbsp;</td></tr>
			</table>
		<CFELSEIF Attributes.LAYOUT IS 1>
			<table id=COHEADER  border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%">
				<tr><td align=left width="100px"><img SRC="#request.webroot#MSupport/logo/PH_Malayan_Div_LOA.png" height="130%"></td>
				<td align=left>
					<table>
						<tr><td style="font-size:100%"><b>MALAYAN INSURANCE</b></td></tr>
						<tr><td style="font-size:80%">A YCG Member</td></tr>
						<tr><td style="font-size:90%;text-transform: uppercase;"><b>#vaCOBRNAME#</b></td></tr>
						<tr><td style="font-size:75%">#vaADD1#,<cfif #vaADD2# neq ""> #vaADD2#,</cfif> </td></tr>
						<tr><td style="font-size:75%">#vaPOSTCODE# #CITY# • P.O. Box 3137 MCC Makati</td></tr>
						<tr><td style="font-size:75%">Tel. Nos: #aTELNO#&nbsp; • Fax Nos: #aFAXNO#</td></tr>
						<tr><td style="font-size:75%">Website: http://www.malayan.com • E-mail: #vaEMAIL#</td></tr>
					</table>
				</td>
				</tr>
			</table>
		</CFIF>
	<!--- End #33414 kofam --->
	<cfelseif iGCOID IS 1101213>
		<!--- TH SOMPO HANI 34603--->
		<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 80%; margin: 0 auto;" align="center" background="">
			<tr>
				<cfif IsDefined("Attributes.DISPMODE") and Attributes.DISPMODE is 1>
					<td align="center" valign=bottom><img width="100%" SRC="#request.webroot#MSupport/logo/SOMPO_header_1.jpg"></td>
				<cfelse>
					<td align="center" valign=bottom><img width="100%" SRC="#request.webroot#MSupport/logo/TH_SOMPO_header.jpg"></td>
				</cfif>
			</tr>
 		</table>
	<cfelseif iGCOID IS 200038>
		<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 100%;">
			<tr>
				<td><img width="190px" height="58px" SRC="#request.webroot#MSupport/logo/NTUC.jpg"></td> <!---#44945 [SG] Income - Update Logo and Company Header + Footer --->
			</tr>
 		</table>
	<cfelseif iGCOID IS 56799>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:Times New Roman;"  align="center" background="">
			<tr><td align=center><span style="font-weight:bold;font-size:180%;">#ucase(vaconame)#</span></td></tr>
			<tr><td align=center style="font-weight:bold;font-size:180%;">蔡珮昱律師樓</td></tr>
			<tr><td align=center style="font-weight:bold;font-size:120%;">Peguambela & Peguamcara</td></tr>
			<tr><td align=center style="font-weight:bold;font-size:120%;">Advocates & Solicitors</td></tr>
		</table>
		<!--- Aidil #44694 --->	
	<cfelseif iGCOID IS 200047>
			<!--- SG UOI --->
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:100%" align=center>
			<tr><td align=left valign=top ><img SRC="#request.webroot#MSupport/logo/#cologo#" width="200px"></td>
				<td align=right>
					<table cellPadding=0 cellSpacing=1>
						<tr><td align=right><span style="font-weight:bold;font-size:100%;color:rgb(31, 31, 104);">#ucase(vaconame)#</span></td></tr>
						<tr><td style="font-size:85%">#vaADD1#&nbsp;#vaADD2#</td></tr>
						<tr><td style="font-size:85%">#STATE#&nbsp;#vaPOSTCODE#</td></tr>
						<tr><td style="font-size:85%">&nbsp;</td></tr>
						<tr><td style="font-size:85%">Tel:&nbsp;(65) #aTELNO#&nbsp;</td></tr>
						<tr><td style="font-size:85%">Fax:&nbsp;(65) #aFAXNO#</td></tr>
						<tr><td style="font-size:85%">Fax:&nbsp;(65) 6327 3872 (Claims)</td></tr>
						<tr><td style="font-size:85%">Email:&nbsp;#vaEMAIL#</td></tr>
						<tr><td style="font-size:85%">uoi.com.sg</td></tr>
						<tr><td style="font-size:85%">&nbsp;</td></tr>
						<tr><td style="font-size:85%">Co. Reg No. #vaCOREGNO#</td></tr>
					</table>
				</td>
			</tr>
		</table>
		<!--- SG UOI --->
		
		
		<!--- Aidil #44694 --->	
 	<cfelseif iGCOID IS 1000152>
	 	<!--- S: #39392 --->
	 	<cfif Attributes.layout EQ 1>
			<table id="COHEADER" border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:75%" align=center>
				<tr>
					<td align=right style="width:35%">
						<img width="30px" height="30px" SRC="#request.webroot#MSupport/logo/PH_Malayan.jpg">
					</td>
					<td style="width:2%">&nbsp;</td>
					<td style="width:60%">
						<table border=0 cellPadding=0 cellSpacing=0 style="WIDTH:55%" align=left>
							<tr><td style="font-size:14px;width:50%" align=center><b>CLIENT INFORMATION SHEET</b></td></tr>
							<cfif Attributes.corp EQ 1>
							<tr><td style="font-size:14px;width:50%" align=center><b>(For Corporate Client)</b></td></tr>
							<cfelseif Attributes.corp EQ 2>
							<tr><td style="font-size:14px;width:50%" align=center><b>(For Individual Client)</b></td></tr>
							</cfif>
						</table>
					</td>
				</tr>
			</table>
		<!--- E: #39392 --->
		<cfelse>
			<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 100%">
				<tr>
					<td><img width="400px" height="100px" SRC="#request.webroot#MSupport/logo/PH_Malayan_YGC.png"></td>
				</tr>
			</table>	
		 </cfif>
	<cfelseif iGCOID IS 200798>
		<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="width:100%;" align="center">
			<tr>
				<td align="right"><img src="#request.webroot#MSupport/logo/SG_SINGLIFE_HEADER.png"></td>
			</tr>
		</table>
	<cfelseif iGCOID IS 700170 AND Attributes.layout EQ 1><!--- #22_143 --->
		<!--- NM etender --->
		<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="width:100%;" align="center">
			<tr>
				<td align="right"><IMG width="100%" align="center" SRC="#request.webroot#MSupport/logo/ID-MAG2.png"></td>
			</tr>
		</table>
	<!--- Aisyah #45210 --->
	<cfelseif iGCOID IS 700170 AND Attributes.layout EQ 2>
		<table id="COHEADER" border="0" cellPadding="0" cellSpacing="0" style="width:100%;" align="center">
			<tr>
				<td align="right"><IMG width="100%" align="left" SRC="#request.webroot#MSupport/logo/fairfax_header.jpg"></td>
				<td align="right"><IMG width="65%" align="right" SRC="#request.webroot#MSupport/logo/mag_logo.gif"></td>
			</tr>
		</table><br>
	<cfelseif cologo IS NOT "" OR siLOGOTYPE GT 0>
		<!--- Refer to dsp_coprofile.cfm for the logo type --->
		<!---
		1-Left Banner
		2-Center Banner
		3-Right Banner
		4-Left Logo / Left Address
		5-Left Logo / Center Address
		6-Right Logo / Right Address
		7-Center Logo / Center Address Below
		8-Right Logo / Right Address Below --->
		<cfset _align="center">
		<cfif siLOGOTYPE IS 1 OR siLOGOTYPE IS 4><cfset _align="left">
		<cfelseif siLOGOTYPE IS 2 OR siLOGOTYPE IS 5><cfset _align="center">
		<cfelseif siLOGOTYPE IS 3 OR siLOGOTYPE IS 6 OR siLOGOTYPE IS 8><cfset _align="right">
		<cfelseif siLOGOTYPE IS 7><cfset _align="center"></cfif>
		<cfset _addr=0>
		<cfif siLOGOTYPE IS 4 OR siLOGOTYPE IS 5 OR siLOGOTYPE IS 6 OR siLOGOTYPE IS 7 OR siLOGOTYPE IS 8><cfset _addr=1></cfif>
		<div id=COHEADER style="width:100%;clear:both;" align="center"><table cellspacing=1 cellpadding=1 border=0 width="#Attributes.WIDTH#" align="center">
		<cfif _addr IS 1>
			<cfif siLOGOTYPE IS 7>
			<tr><td align=#_align#><img SRC="#request.webroot#MSupport/logo/#cologo#"><br>#fAddrOut(q_co)#</td></tr>
			<cfelseif siLOGOTYPE IS 8>
			<tr><td width=70%></td><td align=#_align#><img SRC="#request.webroot#MSupport/logo/#cologo#"><br>#fAddrOut(q_co)#</td></tr>
			<cfelse>
			<tr><cfif _align IS "right"><td align=#_align#>#fAddrOut(q_co)#</td></cfif>
			<td align=#_align#><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>
			<cfif _align IS NOT "right"><td>#fAddrOut(q_co)#</td></cfif></tr>
			</cfif>
		<cfelse>
			<tr><td align="#_align#"><img SRC="#request.webroot#MSupport/logo/#cologo#"></td></tr>
            <tr> #TAXNo(type="TABLE",style="text-align:center;font-weight:bold")# </tr>
		</cfif>
		</table></div>
	<cfelse>
		<!--- Default: Text Only --->
		<div id=COHEADER align=#Attributes.ALIGN# style=width:100%>
		<!---cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" TARGET="TWOLINE" NOCOREGNO=0 CONAMEATTR="class=clsRptSubTitle" CONAME=#HTMLEditFormat(vaCONAME)# COREGNO=#HTMLEditFormat(vaCOREGNO)# COTAGLINE=#HTMLEditFormat(vaCOTAGLINE)# ADD1=#HTMLEditFormat(vaADD1)# ADD2=#HTMLEditFormat(vaADD2)# POSTCODE=#HTMLEditFormat(vaPOSTCODE)# CITYID=#iCITYID#><Br--->
		<!---cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" TARGET="TWOLINE" NOCOREGNO=0 CONAMEATTR="style=color:darkred;text-align:left;font-size:160%" CONAME=#vaCONAME# COREGNO=#vaCOREGNO# COTAGLINE=#vaCOTAGLINE# ADD1=#vaADD1# ADD2=#vaADD2# POSTCODE=#vaPOSTCODE# CITYID=#iCITYID#><Br>
		<cfif Trim(aTELNO) IS NOT "">Tel: #HTMLEditFormat(Trim(aTELNO))#</cfif><cfif Trim(aFAXNO) IS NOT "">&nbsp;&nbsp;Fax: #HTMLEditFormat(Trim(aFAXNO))#</cfif>
		<cfif Trim(vaEMAIL) IS NOT "">&nbsp;&nbsp;Email: #HTMLEditFormat(Trim(vaEMAIL))#</cfif--->
		#fAddrOut(q_co)#
		</div>
	</CFIF>

</cfoutput>
<cffunction name="fAddrOut">
	<cfargument name="q_co">
	<cfargument name="TARGET" default="TWOLINE">
	<cfoutput query=q_co>
		<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" TARGET="#Arguments.TARGET#" NOCOREGNO=0 CONAMEATTR="style=color:darkred;text-align:left;font-size:160%" CONAME=#vaCONAME# COREGNO=#vaCOREGNO# COTAGLINE=#vaCOTAGLINE# ADD1=#vaADD1# ADD2=#vaADD2# POSTCODE=#vaPOSTCODE# CITYID=#iCITYID#><br>
         #TAXNo(type="HTML",span="",BRFront="no",BRend='yes')#
		<cfif Trim(aTELNO) IS NOT "">Tel: #HTMLEditFormat(Trim(aTELNO))#</cfif><cfif Trim(aFAXNO) IS NOT "">&nbsp;&nbsp;Fax: #HTMLEditFormat(Trim(aFAXNO))#</cfif>
		<cfif Trim(vaEMAIL) IS NOT "">&nbsp;&nbsp;Email: #HTMLEditFormat(Trim(vaEMAIL))#</cfif>
	</cfoutput>
</cffunction>

<cffunction name="TAXNo">
		<cfargument name="Type" default="TABLE">
		<cfargument name="Span" default="">
		<cfargument name="Style" default="font-weight:bold">
		<cfargument name="BRFront" default="NO">
		<cfargument name="BREnd" default="NO">

		<cfif Attributes.isGST IS 1>
	        <cfset mygstcheck = request.ds.fn.SVCgetcovateff(Attributes.COID)>
	        <cfset mygsteff = mygstcheck.myeff>
	        <cfset cogsteff = mygstcheck.coeff>

			<cfoutput>
			<cfif  mygsteff and cogsteff>
				<cfif Arguments.Type IS "TABLE">
					<td #Arguments.Span# style="#Arguments.Style#">GST No: #q_co.vaTAXREGNO#</td>
				<cfelseif Arguments.Type IS "DIV">
					<cfif BRFront IS "YES"></br></cfif><div style="#Arguments.Style#">GST No: #q_co.vaTAXREGNO#</div><cfif Arguments.BREnd IS "YES"></br></cfif>
				<cfelseif Arguments.Type IS "HTML">
					<cfif Arguments.BRFront IS "YES"></br></cfif><span style="#Arguments.Style#">GST No: #q_co.vaTAXREGNO#</span><cfif Arguments.BREnd IS "YES"></br></cfif>
				</cfif>
			</cfif>
			</cfoutput>
		<cfelseif Attributes.isGST IS 50> <!--- flag to show SST No. --->
			<cfoutput>
				<cfif Arguments.Type IS "TABLE">
					<td #Arguments.Span# style="#Arguments.Style#">SST No: #q_co.vasvcregno#</td>
				<cfelseif Arguments.Type IS "DIV">
					<cfif BRFront IS "YES"></br></cfif><div style="#Arguments.Style#">SST No: #q_co.vasvcregno#</div><cfif Arguments.BREnd IS "YES"></br></cfif>
				<cfelseif Arguments.Type IS "HTML">
					<cfif Arguments.BRFront IS "YES"></br></cfif><span style="#Arguments.Style#">SST No: #q_co.vasvcregno#</span><cfif Arguments.BREnd IS "YES"></br></cfif>
				</cfif>
			</cfoutput>
		</cfif>
</cffunction>
