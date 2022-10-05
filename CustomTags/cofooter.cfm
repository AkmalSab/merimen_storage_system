<!---
Generates company letterheads for printing.

Attributes:
COID: The company's letterhead.

Return Values :
--->
<CFIF IsDefined("SESSION.VARS.ORGID")>
<CFPARAM NAME=Attributes.COID DEFAULT=#SESSION.VARS.ORGID#>
</CFIF>

<!--- Putting extra logic into this coheader, to ease maintenance pain for templates --->
<cfparam NAME=Attributes.DOMID type=numeric default=0>
<cfparam NAME=Attributes.OBJID type=numeric default=0>
<cfparam NAME=attributes.manufacturer default="">
<cfparam NAME=Attributes.WIDTH DEFAULT="100%">
<cfparam NAME=Attributes.LAYOUT DEFAULT=0>
<cfparam NAME=Attributes.CUSTOM DEFAULT=0>
<cfparam NAME=Attributes.PICCASEID DEFAULT="">

<cfset CLAIMTYPE="">
<cfif Attributes.DOMID IS 1 AND Attributes.OBJID GT 0>
	<cfquery NAME=q_trx DATASOURCE=#Request.MTRDSN#>
	SELECT aCLAIMTYPE=UPPER(RTRIM(a.aCLAIMTYPE))
	FROM TRX0001 a WITH (NOLOCK)
	WHERE a.iCASEID=<cfqueryparam value="#Attributes.OBJID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif q_trx.recordcount IS NOT 1>
		<CFTHROW TYPE="EX_DBERROR" ErrorCode="COHEADER">
	</cfif>
	<cfset CLAIMTYPE=q_trx.aCLAIMTYPE>
</cfif>

<cfquery NAME=q_gco DATASOURCE=#Request.MTRDSN#>
	select iGCOID from SEC0005 WITH (NOLOCK)
		where iCOID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.COID#">
</cfquery>

<!--- for Uni.Asia (Liberty), always use HQ --->
<cfif q_gco.iGCOID IS 61>
	<cfset Attributes.COID = 61>
</cfif>

<!--- MPIB --->
<cfif q_gco.iGCOID IS 37>
	<cfif CLAIMTYPE IS "TP" OR CLAIMTYPE IS "TP PD" OR CLAIMTYPE IS "TP BI">
		<cfset Attributes.COID=37>
	</cfif>
</cfif>

<!--- #30424 WSLIM START--->
<CFIF q_gco.iGCOID is 64 or q_gco.iGCOID is 54>
	<CFIF #attributes.PICCASEID# gt 0>
		<CFIF Attributes.DOMID IS 1 OR Attributes.DOMID IS 0> <!--- 0 defaulted to 1 --->
			<CFQUERY NAME=q_getpicco DATASOURCE=#Request.MTRDSN#>
				Select c.iCOID FROM TRX0008 b WITH (NOLOCK)
					INNER JOIN SEC0001 c WITH (NOLOCK) ON b.vaowner = c.vaUSID 
					WHERE b.icaseid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.PICCASEID#"> AND b.vaOWNER IS NOT NULL
			</CFQUERY>

			<CFIF q_getpicco.RecordCount gt 0>
				<cfset Attributes.COID = q_getpicco.iCOID>
			</CFIF>
		<cfelseif Attributes.DOMID IS 2>
			<!--- Tender can use TRX0070.iCOID as branch COID will be recorded here --->
			<CFQUERY NAME=q_getpicco DATASOURCE=#Request.MTRDSN#>
				Select iCOID FROM TRX0070 b WITH (NOLOCK)
					WHERE b.ITENDER = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Attributes.PICCASEID#">
			</CFQUERY>

			<CFIF q_getpicco.RecordCount gt 0>
				<cfset Attributes.COID = q_getpicco.iCOID>
			</CFIF>
		</cfif>
	</CFIF>
</CFIF>
<!--- #30424 WSLIM END --->

<style>
	.clsContentLtr {
		padding-bottom: 60px;
  		box-sizing: border-box;
	}

	@media print {
		.clsFooterBottom {
			height: 60px;
			position: fixed;
			overflow: hidden;
			right: 0;
			bottom: 0;
			left: 0;
			z-index: 9999;
		}
	}
</style>

<CFQUERY NAME=q_co DATASOURCE=#Request.MTRDSN#>
SELECT a.iGCOID,a.vaCONAME,a.vaCOBRNAME,a.vaCOREGNO,a.vaADD1,a.vaADD2,a.vaADD3,a.vaPOSTCODE,a.aTELNO,a.aFAXNO,a.vaTAXREGNO,a.vasvcregno,
		cologo=a.vaLOGO,CITY=b.vaDESC,a.iSTATEID,STATE=c.vaDESC,a.vaEMAIL,vaCOTAGLINE,a.iCITYID,a.iPCOID, COUNTRY = d.vaDESC
FROM SEC0005 a,SYS0003 b,SYS0002 c, SYS0005 d
WHERE a.iCOID=<cfqueryparam value="#Attributes.COID#" cfsqltype="CF_SQL_INTEGER"> AND a.iCITYID=b.iCITYID AND b.iSTATEID=c.iSTATEID
	AND d.iCOUNTRYID = c.iCOUNTRYID
</CFQUERY>
<!---CFIF q_co.iGCOID IS 44 AND (Attributes.COID IS 27 OR q_co.iPCOID IS 27)>
	<!--- MSIG: For HLA & BRANCHES use HQ (suspended 15th Mar 2012 email clarification from hamidah) --->
	<CFQUERY NAME=q_co DATASOURCE=#Request.MTRDSN#>
	SELECT a.iGCOID,a.vaCONAME,a.vaCOBRNAME,a.vaCOREGNO,a.vaADD1,a.vaADD2,a.vaPOSTCODE,a.aTELNO,a.aFAXNO,
			cologo=a.vaLOGO,CITY=b.vaDESC,a.iSTATEID,STATE=c.vaDESC,a.vaEMAIL,vaCOTAGLINE,a.iCITYID,a.iPCOID
	FROM SEC0005 a,SYS0003 b,SYS0002 c
	WHERE a.iCOID=44 AND a.iCITYID=b.iCITYID AND b.iSTATEID=c.iSTATEID
	</CFQUERY>
</CFIF--->
<CFOUTPUT query=q_co>
	<CFIF iGCOID IS 27>
		<!---<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:75%" align=center>
			<tr><td align=center>Untuk sebarang pertanyaan atau laporan tuntutan, sila hubungi cawangan HLA yang terdekat atau nombor talian perkhidmatan pelanggan kami: 03-76501288<br>
				<span style="font-style:italic">For any queries or to report a claim, kindly contact our nearest branch or our Customer Services Hotline: 03-76501288</span><br>
				Ibu Pejabat / <span style="font-style:italic">Head Office</span>: Level 26, Menara HLA, 3 Jalan Kia Peng, 50450 Kuala Lumpur, Malaysia: URL: www.hla.com.my</td></tr>
		</table>--->

	<CFELSEIF iGCOID IS 29>
		</td></tr></table>
		<!---<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:90%;font-family:Arial" align=center>
			<!---<tr><td align="center" style="font-size:80%">#HTMLEditFormat(vaADD1)#<CFIF #vaADD2# IS NOT "">, #HTMLEditFormat(vaADD2)#</cfif>&nbsp;#HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(city)#, #HTMLEditFormat(state)#</td></tr>
			<CFIF #Attributes.COID# IS 29><tr><td  align="center" style="font-size:80%">P.O. Box 11768, 50756 #HTMLEditFormat(city)#</td></tr></cfif>
			<tr><td align="center" style="font-size:80%">Tel: <CFIF #Attributes.COID# IS 29>03-2058 5000 (Non-Auto)&nbsp;&nbsp;&nbsp;03-2058 5073 (Auto)<cfelseif #Attributes.COID# is 465>04-2288335<cfelseif #Attributes.COID# is 468>07-2243340/2247310<CFELSEIF #Attributes.COID# IS 469>088-234711/234878/235118/233590</cfif></td></tr>
			<tr><td align="center" style="font-size:80%">Fax: <CFIF #Attributes.COID# IS 29>03-2058 5500 (Non-Auto)&nbsp;&nbsp;&nbsp;03-2058 5074 (Auto)<cfelseif #Attributes.COID# is 465>04-2283259<cfelseif #Attributes.COID# is 468>07-2246418<CFELSEIF #Attributes.COID# IS 469>088-234278</cfif></td></tr>--->
			<!---<tr><td align=center><b>#HTMLEditFormat(vaCONAME)#</b> <span style="font-size:85%">(#vaCOREGNO#)</span></td><td align=center style="font-style:italic;font-weight:bold">Customer Service Tollfree: 1-800-88-8811</td><td align=center style="font-style:italic;font-weight:bold">Visit our website: www.aiggeneral.com.my</td></tr>--->
			<tr><td align="left"><IMG SRC="#request.webroot#MSupport/logo/aiggi_footer.gif"></td></tr>
			<tr><td align="left">P.O. Box 11768, 50756 Kuala Lumpur</td></tr>
		</table>--->
	<!---<cfelseif iGCOID IS 30>
		<!--- Commerce Assurance, formerly of AMI, amended on 23 Feb 2005 --->
		<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:90%" align=center>
		<tr><!---<td width="5%">&nbsp;</td>--->
		    <td width="95%" align="center"><b>#HTMLEditFormat(vaCONAME)#</b> <span style="font-size:70%">(#vaCOREGNO#)</span></td>
		</tr>
		<tr><td width="95%" align="center" style="font-size:60%">(#HTMLEditFormat(vaCOTAGLINE)#)</td></tr>
		<!---<tr style="line-height:6px"><td width="5%" rowspan=6 valign=center><IMG SRC="#request.webroot#MSupport/logo/ami-footer.gif"></td>
		    <td width="95%" align="center" style="font-size:60%; font-style: italic">#HTMLEditFormat(vaCOTAGLINE)#</td></tr>--->
		<tr><td align="center" style="font-size:70%"><b><cfif Attributes.COID IS iGCOID><b>Head Office</b><cfelse>#vaCOBRNAME#</cfif>&nbsp;</b>#HTMLEditFormat(vaADD1)#, <CFIF vaADD2 IS NOT "">#HTMLEditFormat(vaADD2)#, </cfif> #HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(city)#</td><tr>
		<tr><td align="center" style="font-size:70%"><cfif Attributes.COID IS iGCOID>P.O. Box 12155, 50768 Kuala Lumpur</cfif> Tel: +603-2264 0400 / +603-2264 0600 Fax: #HTMLEditFormat(aFAXNO)#</td></tr>
		<tr><td align="center" style="font-size:70%">Website: www.commerce-assurance.com.my</td></tr>
		<tr><td align="center" style="font-size:70%"><b>Customer Sevice:</b> 2A-G-1, Ground Floor, Plaza Sentral. Tel: +603-2264 0700 &nbsp;Fax: +603-22640602 &nbsp;Toll Free Line: #HTMLEditFormat(aTELNO)#</td></tr>
		<tr><td align="center" style="font-size:70%">E-mail: #HTMLEditFormat(vaEMAIL)#</td></tr>
		</table>--->
		<!--- <table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style=WIDTH:90% align=center>
		<tr><td width="5%" rowspan=3><IMG SRC="#request.webroot#MSupport/logo/ami-footer.gif"></td>
		<td width="95%" align="center" style="font-size:80%;color=##990000">#HTMLEditFormat(vaADD1)#, <CFIF vaADD2 IS NOT "">#HTMLEditFormat(vaADD2)#, </cfif> #HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(city)#</td>
		<tr><td align="center" style="font-size:80%;color=##990000"><cfif Attributes.COID IS iGCOID>P.O. Box 12155, 50768 Kuala Lumpur</cfif> Tel: #HTMLEditFormat(aTELNO)# Fax: #HTMLEditFormat(aFAXNO)#</td></tr>
		<tr><td align="center" style="font-size:80%;color=##990000">Website: www.ami.com.my&nbsp;&nbsp;e-mail:amigen.com.my</td></tr>
		</table> --->
	<CFELSEIF iGCOID IS 30 OR iGCOID IS 35>
		<!--- Allianz & CAB--->
		<!--- #30926 WSLIM START --->
		<table id=COFOOTER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial;font-size:75%" align=center>
	 	<tr><td colspan=3>HEAD OFFICE - CLAIMS</td><td colspan=2>CUSTOMER SERVICE</td></tr>
		<tr><td width=28%>Level 21, Menara Allianz Sentral </td><td width=4%>Tel:</td><td width=18%>03-2264 1188</td><td width=28%>Allianz Arena, Ground Floor, Block 2A, </td></tr>
		<tr><td>203 Jalan Tun Sambanthan</td><td></td><td>03-2264 0688</td><td>Plaza Sentral, Jalan Stesen Sentral 5,</td><td colspan=2>Allianz Contact Centre : 1 300 22 5542</td></tr>
		<tr><td>Kuala Lumpur Sentral</td><td>Fax:</td><td>03-2264 0402</td><td>Kuala Lumpur Sentral</td><td>Fax:</td><td>03-2264 0602</td></tr>
		<tr><td>50470 Kuala Lumpur</td><td colspan=2>Website: <u style="color: ##0000FF;">www.allianz.com.my</u></td><td>50470 Kuala Lumpur</td><td colspan=2>Email: <u style="color: ##0000FF;">customer.service@allianz.com.my</u></td></tr>
		</table>
		<!--- #30926 WSLIM END --->
	<CFELSEIF iGCOID IS 1600001>
		<!--- etiqa cambodia --->
		<cfset insadd1=#request.ds.co[iGCOID].add1#>
		<cfset insadd2=#request.ds.co[iGCOID].ADD2#>
		<cfset inscountry=#request.ds.countries[request.ds.co[iGCOID].COUNTRYID].NAME#>
		<cfset inspcode=#request.ds.co[iGCOID].postcode#>
		<cfset insfaxno=#request.ds.co[iGCOID].faxno#>
		<cfset inscity=""><cfset insstate="">
		<cfif request.ds.co[iGCOID].CITYID GT 0>
			<cfset inscity=#request.ds.cities[request.ds.co[iGCOID].CITYID]#>
			<cfset insstate=#request.ds.states[request.ds.citystate[request.ds.co[iGCOID].CITYID]]#>
		</cfif>
		<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:90%; font-family:Arial" align=center>
			<tr><td width="70%" style="font-size: 10px; font-weight: bold;">#request.ds.co[iGCOID].coname#</td><td  width="30%" align="right" style="font-weight: bold; color: ##FFC200;"><!--- Claims Careline 1300 88 1007 ---></td></tr>
			<!--- <tr><td style="font-size: 9px;">(Formerly known as Etiqa Insurance Berhad) <br>(Licensed under Financial Services Act 2013 and regulated by Bank Negara Malaysia)</td><td>&nbsp;</td></tr> --->
			<tr><td style="font-size: 9px;" colspan=2>#insadd1#<cfif insadd2 NEQ "">, #insadd2#</cfif>, #inspcode#<cfif inscity NEQ ""> #inscity#<cfif insstate NEQ inscity>, #insstate#</cfif></cfif>, #inscountry#</td></tr>
			<tr><td style="font-size: 9px">Claim Assist : &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<!--- 1300 88 1007 ---> Fax : #insfaxno# E: info@etiqa.com.my <span style="font-weight:bold;font-size: 9px;color:##FFC200;">&nbsp;&nbsp;&nbsp;www.etiqa.com.my</span></td><td align="right">Ahli Kumpulan <IMG SRC="#request.webroot#MSupport/logo/my-etiqa_btm.gif"></td></tr>
			<tr><td colspan="2"></td></tr>
		</table>
	<CFELSEIF igcoid is 1003198>
		<!--- etiqa philippines --->
		<cfparam name="attributes.nofooter" default=0>
		<cfif attributes.nofooter IS 0>
			<cfif Attributes.CUSTOM IS 1>			
				<table id=COFOOTER border="0" cellPadding="0" cellSpacing="0" width="100%" align=center>
			<cfelse>
				<div class="clsFooterBottom" style="display: block; width:100%">
				<table border="0" cellPadding="0" cellSpacing="0" width="100%" align=center>
			</cfif>
			<tr><td align="left" width="70%">
				<table style="height:40px;width:293px"  border="0" cellPadding="0" cellSpacing="0">
				<tr><td>
					<span style="font-size:8pt;color:##8c8c8c;"><b>#HTMLEditFormat(vaCONAME)#</b></span>
					<span style="font-size:7pt;color:##999999;">(Formerly: AsianLife and General Assurance Corporation)</span>
							<br/>
					<span style="font-size:8pt;color:##999999;">
						#HTMLEditFormat(vaADD1)#
						<br> 
						#HTMLEditFormat(vaADD2)#, #city# #vaPOSTCODE#<br/>
						<span style="color:##999999;">Tel</span>. No: #aTELNO#<br/>
						<span style="color:##ffd11a">www.etiqa.com.ph</span>
					</span>
					</td>
				</tr>
				</table>
				</td>
				<td align="right" width="30%">
					<span>A Member of </span><img src="#request.webroot#MSupport/logo/Maybank.png" width=30% height="33px" align="middle"> Group
				</td>	
			</tr>
			</table>
			<cfif Attributes.CUSTOM EQ 0>
				</div>
			</cfif>
		</cfif>
	<CFELSEIF iGCOID IS 36 OR  iGCOID IS 28 OR iGCOID IS 1710 OR iGCOID IS 78 OR iGCOID IS 3060>
		<!--- Mayban & MNI &  Mayban Takaful & Takaful Nasional--->
		<!--- Etiqa need standardize footer. layout is 2 will apply same footer as cfelse --->
		<!---cfif Isdefined("attributes.layout") AND attributes.layout IS 2---><!--- layout=1 as footer for tender award letter / tow auth letter / wreck disposal letter --->
			<!--- <table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:90%; font-family:Arial" align=center>
			<tr><td style="font-size:12px;font-weight: bold;">Claims Care Department</td></tr>
			<tr><td style="font-size:10px"><span style="font-weight: bold;">#vaCONAME# (#vaCOREGNO#)</span></td></tr>
			<tr><td style="font-size:9px"><cfif Attributes.COID IS 9516 OR Attributes.COID IS 1710 OR Attributes.COID IS 78>(Licensed under Islamic Financial Services Act 2013 and regulated by Bank Negara Malaysia)<cfelse>(Formerly known as Etiqa Insurance Berhad) <br>(Licensed under Financial Services Act 2013 and regulated by Bank Negara Malaysia)</cfif></td></tr>
			<tr><td style="font-size:9px">Level 12, Tower B, Dataran Maybank, No 1, Jalan Maarof, 59000 Kuala Lumpur, Malaysia</td></tr>			
			<tr><td style="font-size:9px">Claim Assist: 03-22972888 Fax: 03-27855999 E:#vaEMAIL# <br>Etiqa Oneline 1300 88 1007 Etiqa Online: www.etiqa.com.my</td></tr>
			<tr><td style="font-size:80%">
				<div style="float:left;width:15%;text-align:left">Ahli Kumpulan</div>
				<div style="float:left;width:45%;text-align:left"><IMG SRC="#request.webroot#MSupport/logo/my-etiqa_btm.gif"> </div>
			</td></tr>
			</table> --->
		<cfif Isdefined("attributes.layout") AND attributes.layout IS 3><!--- general footer 100% width--->
			<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%; font-family:Arial" align=center>
				<tr><td width="65%" style="font-size: 12px; font-weight: bold;">Claims Care Department</td><td width="35%" align="right" style="font-weight: bold;font-size: 120%; color: ##FFC200;">Claims Careline 1300 88 1007</td></tr>
				<tr><td style="font-size: 10px; font-weight: bold;">#vaCONAME# (#vaCOREGNO#)</td><td>&nbsp;</td></tr>
				<tr><td style="font-size: 9px;"><cfif Attributes.COID IS 9516 OR Attributes.COID IS 1710 OR Attributes.COID IS 78>(Licensed under Islamic Financial Services Act 2013 and regulated by Bank Negara Malaysia)<cfelse>(Formerly known as Etiqa Insurance Berhad) <br>(Licensed under Financial Services Act 2013 and regulated by Bank Negara Malaysia)</cfif></td><td></td></tr>
				<tr><td style="font-size: 9px;">Level 12, Tower B, Dataran Maybank, No 1, Jalan Maarof, #vaPOSTCODE# #city#, Malaysia</td><td>&nbsp;</td></tr>
				<tr><td style="font-size: 9px;">Tel: #aTELNO# Fax: #aFAXNO# E:info@etiqa.com.my <span style="font-weight:bold;font-size: 9px;color:##FFC200;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;www.etiqa.com.my</span></td><td align="right">Ahli Kumpulan <IMG SRC="#request.webroot#MSupport/logo/my-etiqa_btm.gif"></td></tr>
			</table>
		<cfelse><!--- general footer 90% width --->
			<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:90%; font-family:Arial" align=center>
				<tr><td width="65%" style="font-size: 12px; font-weight: bold;">Claims Care Department</td><td width="35%" align="right" style="font-weight: bold;font-size: 120%; color: ##FFC200;">Claims Careline 1300 88 1007</td></tr>
				<tr><td style="font-size: 10px; font-weight: bold;">#vaCONAME# (#vaCOREGNO#)</td><td>&nbsp;</td></tr>
				<tr><td style="font-size: 9px;"><cfif Attributes.COID IS 9516 OR Attributes.COID IS 1710 OR Attributes.COID IS 78>(Licensed under Islamic Financial Services Act 2013 and regulated by Bank Negara Malaysia)<cfelse>(Formerly known as Etiqa Insurance Berhad) <br>(Licensed under Financial Services Act 2013 and regulated by Bank Negara Malaysia)</cfif></td><td></td></tr>
				<tr><td style="font-size: 9px;">Level 12, Tower B, Dataran Maybank, No 1, Jalan Maarof, #vaPOSTCODE# #city#, Malaysia</td><td>&nbsp;</td></tr>
				<tr><td style="font-size: 9px;">Tel: #aTELNO# Fax: #aFAXNO# E:info@etiqa.com.my <span style="font-weight:bold;font-size:9px;color:##FFC200;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;www.etiqa.com.my</span></td><td align="right">Ahli Kumpulan <IMG SRC="#request.webroot#MSupport/logo/my-etiqa_btm.gif"></td></tr>
			</table>
		</cfif>
	<CFELSEIF iGCOID IS 37>
		<!--- Multi-Purpose --->
		<!--- </div> --->
		</td></tr>
		</table>
		<cfparam name="attributes.nofooter" default=0>
		<cfif attributes.nofooter IS 0>
			<CFIF ListFind("DEV",Application.DB_MODE)>
				<div class="clsFooterBottom">
				<!-- FOOTSTART -->
			</CFIF>
			<!--- #45812 - Nazri remove footer for all letter
				<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="font-family:arial;" align=center>
				<!--- <table class=clsFooter border=0 cellPadding=0 cellSpacing=0 style="font-family:arial" align=center> --->
				<tr><td></td><td style="border-top:1px solid red;line-height:10px">&nbsp;</td></tr>
				<tr><td style="width:58px">&nbsp;</td>
					<td style="width:966px;font-size:6pt;text-align:justify">
					MPI Generali Insurans Bhd is a strategic partnership between Multi-Purpose Capital Holdings Berhad, which is a wholly-owned subsidiary of MPHB Capital Berhad, a public listed company, and Generali Asia N.V., an indirect subsidiary of the Generali Group, one of the largest global insurance providers with a rich heritage going back to 1831. MPI Generali&##39;s core business is underwriting of general insurance business.
					</td>
				</tr>
				</table>
			 --->
			<CFIF ListFind("DEV",Application.DB_MODE)>
				<!-- FOOTEND --> 
				</div>
			</CFIF>
		</cfif>
	<CFELSEIF iGCOID IS 18206>
		<!--- Multi-Purpose --->
		<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-family:arial;color:dimgray" align=center>
		<tr style="font-size:90%" align="center"><td><b>#vaCONAME#</b></td></tr>
		<tr style="font-size:75%" align="center"><td>(#vaCOREGNO#)</td></tr>
		<tr style="font-size:75%" align="center"><td>#vaADD1#,<cfif #vaADD2# neq ""> #vaADD2#,</cfif> #vaPOSTCODE# #city#,<cfif #Attributes.COID# IS 37> P.O. Box 10122, 50704 Kuala Lumpur,</cfif> Malaysia</td></tr>
		<tr style="font-size:75%" align="center"><td>Tel: #aTELNO# Fax: #aFAXNO# Website: http://www.mpib.com.my</td></tr>
		</table>
	<CFELSEIF iGCOID IS 7651 AND Attributes.COID IS 51>
		<!--- Kurnia --->
		<CFIF Attributes.CUSTOM eq 1>
		<style>.clsFooter td {font-family: Arial,Verdana,'Sans-Serif'; padding-top:0px; padding-bottom:0px; line-height:1.2em;}</style>
		<table class=clsfooter id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%" align=center> <!---;font-family:arial;color:dimgray--->
		<!---><tr style="font-size:75%"><td><IMG SRC="#request.webroot#MSupport/logo/kurnia-footer.jpg"> Company Number : #vaCOREGNO#</td><td rowspan=4><IMG SRC="#request.webroot#MSupport/logo/sirim-full-logo.jpg"></td></tr>
		<tr style="font-size:75%"><td>(A member of the Kurnia Group of Companies)</td></tr>
		<tr style="font-size:75%"><td><b><cfif #Attributes.COID# IS 51>HEAD OFFICE:</CFIF></b> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; #vaADD1#,<cfif #vaADD2# neq ""> #vaADD2#,</cfif> #vaPOSTCODE# #city#. P.O. Box 8607, 46792 Petaling Jaya, #state#</td></tr>
		<tr style="font-size:75%"><td>Tel: #aTELNO# &nbsp;&nbsp;&nbsp; Fax: #aFAXNO# &nbsp;&nbsp;&nbsp; E-mail: #vaEMAIL# &nbsp;&nbsp;&nbsp; Website: http://www.kurnia.com.my</td></tr>
		--->
		<tr><td align="left" style="font-size: 15px"><b>AmGeneral Insurance Berhad</b> (#vaCOREGNO#)</td></tr>
		<CFIF vaCOTAGLINE IS NOT ""><tr><td align="left" style="font-size: 8px">#vaCOTAGLINE#</td></tr></CFIF>
		<tr><td align="left" style="font-size: 14px"><i>A member of the AmBank Group</i></td></tr>
		<tr><td align="left" style="font-size: 14px">#vaADD1#<CFIF #vaADD2# IS NOT "">, #vaADD2#</cfif>, #vaPOSTCODE#, #city#, Malaysia PO Box 11228, GPO Kuala Lumpur, 50740 W.P. #city#, Malaysia</td></tr>
	    <tr><td align="left" style="font-size: 14px"><b>Tel:</b> #aTELNO# &nbsp;&nbsp;&nbsp; <b>Email:</b> #vaEMAIL# &nbsp;&nbsp;&nbsp; <b>Web:</b> www.kurnia.com</td></tr>
	    <tr><td align="left" style="font-size: 14px">(Service Tax Registration No: B16-1808-31015443)</td></tr>			
		<cfelse>
		<!--@marginBottom="1"-->
		<!--PDFfooterTop-->
		<style>.clsFooter td {font-family: Arial,Verdana,'Sans-Serif'; padding-top:0px; padding-bottom:0px; line-height:1.2em;}</style>
		<table class=clsfooter id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%" align=center> <!---;font-family:arial;color:dimgray--->
		<!---><tr style="font-size:75%"><td><IMG SRC="#request.webroot#MSupport/logo/kurnia-footer.jpg"> Company Number : #vaCOREGNO#</td><td rowspan=4><IMG SRC="#request.webroot#MSupport/logo/sirim-full-logo.jpg"></td></tr>
		<tr style="font-size:75%"><td>(A member of the Kurnia Group of Companies)</td></tr>
		<tr style="font-size:75%"><td><b><cfif #Attributes.COID# IS 51>HEAD OFFICE:</CFIF></b> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; #vaADD1#,<cfif #vaADD2# neq ""> #vaADD2#,</cfif> #vaPOSTCODE# #city#. P.O. Box 8607, 46792 Petaling Jaya, #state#</td></tr>
		<tr style="font-size:75%"><td>Tel: #aTELNO# &nbsp;&nbsp;&nbsp; Fax: #aFAXNO# &nbsp;&nbsp;&nbsp; E-mail: #vaEMAIL# &nbsp;&nbsp;&nbsp; Website: http://www.kurnia.com.my</td></tr>
		--->
		<tr><td align="left" style="font-size: 10px"><b>AmGeneral Insurance Berhad</b> (#vaCOREGNO#)</td></tr>
		<CFIF vaCOTAGLINE IS NOT ""><tr><td align="left" style="font-size: 8px">#vaCOTAGLINE#</td></tr></CFIF>
		<tr><td align="left" style="font-size: 9.5px"><i>A member of the AmBank Group</i></td></tr>
		<tr><td align="left" style="font-size: 9.5px">#vaADD1#<CFIF #vaADD2# IS NOT "">, #vaADD2#</cfif>, #vaPOSTCODE#, #city#, Malaysia<br>PO Box 11228, GPO Kuala Lumpur, 50740 W.P. #city#, Malaysia</td></tr>
	    <tr><td align="left" style="font-size: 9.5px"><b>Tel:</b> #aTELNO# &nbsp;&nbsp;&nbsp; <b>Email:</b> #vaEMAIL# &nbsp;&nbsp;&nbsp; <b>Web:</b> www.kurnia.com</td></tr>
	    <tr><td align="left" style="font-size: 9.5px">(Service Tax Registration No: B16-1808-31015443)</td></tr>
		</CFIF>
		</table>
		<!--/PDFfooterTop-->
	<cfelseif iGCOID IS 61>
		<!--- liberty insurance --->
		<!-- PDFFOOTMARGIN = 0.9 -->
		<table id=COHEADER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:80%" align=center>
		<tr><td><span style="font-weight:bold;font-size:140%;color:##00008B">#HTMLEditFormat(vaCONAME)#</span> (#vaCOREGNO#)</td></tr>
		<CFIF vaCOTAGLINE IS NOT ""><tr><td align="left" style="font-style:italic">(#vaCOTAGLINE#)</td></tr></CFIF>
		<tr><td>#HTMLEditFormat(vaADD1)#, #HTMLEditFormat(vaADD2)#, #vaPOSTCODE# #city#, Malaysia</td></tr>
		<CFIF Attributes.COID IS 61><tr><td>P.O. Box 6120 Pudu, 55916 Kuala Lumpur</td></tr></CFIF>
		<tr><td>Tel: #aTELNO# &nbsp;Fax: #aFAXNO#</td></tr>
		<tr><td><span style="font-weight:bold;color:##00008B">www.libertyinsurance.com.my</span> <!---22/7/14><span style="font-weight:bold;font-size:120%">a DRB-HICOM & UOB company</span>---></td></tr>
		</table>
	<cfelseif iGCOID IS 293>
	<!--- Wellesley --->
		<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:90%;font-family:arial narrow" align=center>
			<tr style="font-size:80%" align="center"><td><b>#vaCONAME# (#vaCOREGNO#)</b></td></tr>
			<tr style="font-size:80%" align="center"><td>#vaADD1#,<cfif #vaADD2# IS NOT ""> #vaADD2#,</cfif> #vaPOSTCODE# #city#, Malaysia</td></tr>
			<tr style="font-size:80%" align="center"><td>Tel: #aTELNO# Fax: #aFAXNO# <!---#vaEMAIL#---></td></tr>
		</table>
	<!----<CFELSEIF iGCOID IS 1710 OR iGCOID IS 78>
		<!--- Mayban Takaful & Takaful Nasional--->
		<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:90%;font-family:arial narrow" align=center>
		<tr style="font-size:80%"><td>Claims Department</td></tr>
		<tr style="font-size:80%"><td><span>#vaCONAME# (#vaCOREGNO#)</span> #vaCOTAGLINE#</td></tr>
		<tr style="font-size:80%"><td>#vaADD1#,<cfif #vaADD2# IS NOT ""> #vaADD2#,</cfif> #vaPOSTCODE# #city#, Malaysia</td></tr>
		<tr style="font-size:80%"><td>Claim Assist: #aTELNO# Fax: #aFAXNO# #vaEMAIL#</td></tr>
		</table>---->
	<CFELSEIF iGCOID IS 368>
		<!--- MCIS Zurich --->
		<!--- #13065,commented as MCIS renamed into TPIB --->
		<!--- <table id=COFOOTER border=0 cellPadding=1 cellSpacing=1 style=WIDTH:95% align=center>
		<tr><td align="center" style="font-size:80%">#ucase(vaCONAME)# <span style="font-size:80%">(#vaCOREGNO#)</span></td></tr>
		<CFIF vaCOTAGLINE IS NOT ""><tr><td align="center" style="font-size:70%">(#vaCOTAGLINE#)</td></tr></CFIF>
		<tr><td align="center" style="font-size:70%"><span style=text-decoration:underline><CFIF #Attributes.COID# IS 368>HEAD OFFICE<cfelse>#ucase(vaCOBRNAME)#</cfif>:</span> #HTMLEditFormat(vaADD1)#<CFIF #vaADD2# IS NOT "">, #HTMLEditFormat(vaADD2)#,</cfif>&nbsp;#vaPOSTCODE# #city#, <cfif #state# IS NOT #city#>#state#, </cfif>Malaysia</td></tr>
		<CFIF #Attributes.COID# IS 368><tr><td align="center" style="font-size:70%"><span style=text-decoration:underline>POSTAL ADDRESS:</span> P.O. Box 345, Jalan Sultan, 46916 Petaling Jaya, Selangor Darul Ehsan, Malaysia</td></tr></cfif>
		<tr><td align="center" style="font-size:70%"><span style=text-decoration:underline>TEL:</span> #HTMLEditFormat(aTELNO)# <span style=text-decoration:underline>FAX:</span> #HTMLEditFormat(aFAXNO)# <span style=text-decoration:underline>E-MAIL:</span> info@mcis.my <span style=text-decoration:underline>HOMEPAGE:</span> http://www.mcis.my</td></tr>
		</table> --->
	<CFELSEIF iGCOID IS 44>
		<!--- Mitsui --->
		<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:85%" align=center>
		<tr><td><b>#vaCONAME#</b> <span style="font-size:80%">(#vaCOREGNO#)</span></td></tr>
		<CFIF vaCOTAGLINE IS NOT ""><tr><td style="font-size:80%;font-style:italic">#vaCOTAGLINE#</td></tr></CFIF>
		<tr><td>#HTMLEditFormat(vaADD1)#<CFIF vaADD2 IS NOT "">, #HTMLEditFormat(vaADD2)#</CFIF>, #HTMLEditFormat(vaPOSTCODE)# <cfif #Attributes.COID# IS 1409>Pulau Pinang<cfelseif #Attributes.COID# IS 1410>Melaka<cfelse>#HTMLEditFormat(city)#, #HTMLEditFormat(state)#</cfif>, Malaysia</td></tr>
		<!---<cfif Attributes.COID IS iGCOID OR #Attributes.COID# IS 1409><tr><td><cfif Attributes.COID IS iGCOID>P.O. Box 11034, 50732 Kuala Lumpur<cfelseif #Attributes.COID# IS 1409>P.O. Box 931, 10820 Penang</cfif></td></tr></cfif>--->
		<tr><td>Tel: #aTELNO# &nbsp;&nbsp;Fax: #aFAXNO# &nbsp;&nbsp;Email: myMSIG@my.msig-asia.com &nbsp;&nbsp;Website: www.msig.com.my</td></tr>
		</table>
		<!---><table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:80%;font-family:Trebuchet MS" align=center>
		<tr><td <CFIF Attributes.COID IS NOT iGCOID>rowspan=5</cfif> valign=bottom><img SRC="#request.webroot#MSupport/logo/MY-MSIG-footer.png"></td>
			<CFIF Attributes.COID IS NOT iGCOID>
					<td><span style="color:##191970;font-weight:bold">#vaCONAME#</span> <span style="font-size:80%">(#vaCOREGNO#)</span></td></tr>
				<tr><td>Head Office: Customer Service Centre, Level 22</td></tr>
				<tr><td><CFIF Attributes.COID IS iGCOID>Menara Weld<CFELSE>#HTMLEditFormat(vaADD1)#</cfif><CFIF vaADD2 IS NOT "">, #HTMLEditFormat(vaADD2)#</CFIF>, #HTMLEditFormat(vaPOSTCODE)# <cfif #Attributes.COID# IS 1409>Pulau Pinang<cfelseif #Attributes.COID# IS 1410>Melaka<cfelse>#HTMLEditFormat(city)#, #HTMLEditFormat(state)#</cfif>, Malaysia</td></tr>
				<tr><td>Tel: #aTELNO# &nbsp;&nbsp;Fax: #aFAXNO# &nbsp;&nbsp;Customer Service Hotline 1 800 88 MSIG (6744)</td></tr>
				<tr><td><span style="color:##FF0000">www.msig.com.my</span></td></tr>
			<cfelse>
				</tr>
			</cfif>
		<!---><tr><td><b>#vaCONAME#</b> <span style="font-size:80%">(#vaCOREGNO#)</span></td></tr>
		<CFIF vaCOTAGLINE IS NOT ""><tr><td style="font-size:80%;font-style:italic">#vaCOTAGLINE#</td></tr></CFIF>
		<tr><td>#HTMLEditFormat(vaADD1)#<CFIF vaADD2 IS NOT "">, #HTMLEditFormat(vaADD2)#</CFIF>, #HTMLEditFormat(vaPOSTCODE)# <cfif #Attributes.COID# IS 1409>Pulau Pinang<cfelseif #Attributes.COID# IS 1410>Melaka<cfelse>#HTMLEditFormat(city)#, #HTMLEditFormat(state)#</cfif>, Malaysia</td></tr>
		<tr><td>Tel: #aTELNO# &nbsp;&nbsp;Fax: #aFAXNO# &nbsp;&nbsp;Email: myMSIG@my.msig-asia.com &nbsp;&nbsp;Website: www.msig.com.my</td></tr>--->
		</table>--->

	<CFELSEIF iGCOID IS 46>
		<!--- #38987: [MY] Tune NM & Motor - Amend Header & Footer --->
		<!--- UOA/OCA --->
		<cfif CLAIMTYPE IS "NM FR">
			<table id="COFOOTER" border=0 cellPadding=0 cellSpacing=0 style="HEIGHT:1px;WIDTH:100%;font-size:85%" align=center>
				<tr ><td width=60% >&nbsp;</td><td align="center" width=40% rowspan="5"><IMG SRC="#request.webroot#MSupport/logo/logofTUNE.png" width="100px" height="85px"></td></tr>
				<tr ><td><span style="font-size:120%;font-weight:bold;color:red">#vaCONAME#</span></td></tr>
				<tr ><td><span style="font-style:italic;font-size:75%">#vaCOTAGLINE#</td></tr>
					<tr ><td><cfif vaCOREGNO NEQ ""><span style="font-style:italic;font-size:80%">Company No: #htmleditformat(vaCOREGNO)# </span></cfif></td></tr>
				<!--- <CFIF vaCOTAGLINE IS NOT ""><tr><td style="font-style:italic">#vaCOTAGLINE#</td></tr></CFIF> --->
				<!--- <CFIF isDefined('LAYOUT') and LAYOUT NEQ 1> --->
					<tr ><td><span>#HTMLEditFormat(vaADD1)#, <CFIF vaADD2 IS NOT "">#HTMLEditFormat(vaADD2)#,</CFIF> <CFIF vaADD3 IS NOT "">#HTMLEditFormat(vaADD3)#,</CFIF> #HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(city)#, #COUNTRY#</span></td></tr>
					<tr ><td><span style="color:red">T :</span> #aTELNO# &nbsp;&nbsp;<span style="color:red">F:</span> #aFAXNO# &nbsp;&nbsp;<span style="color:red">W:</span> tuneprotect.com</td></tr>
				<!--- </CFIF> --->
			</table>
		<cfelse>
			<table id="COFOOTER" border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:85%" align=center>
				<tr ><td width=60% >&nbsp;</td><td align="center" width=40% rowspan="8"><IMG SRC="#request.webroot#MSupport/logo/logofTUNE.png" width="150px" height="140px"></td></tr>
				<tr ><td><span style="font-size:120%;font-weight:bold;color:red">#vaCONAME#</span></td></tr>
				<tr ><td><span style="font-style:italic;font-size:75%">#vaCOTAGLINE#</td></tr>	
				<tr ><td><cfif vaCOREGNO NEQ ""><span style="font-style:italic;font-size:80%">Company No: #htmleditformat(vaCOREGNO)# </span></cfif></td></tr>
				<!--- <CFIF vaCOTAGLINE IS NOT ""><tr><td style="font-style:italic">#vaCOTAGLINE#</td></tr></CFIF> --->
				<!--- <CFIF isDefined('LAYOUT') and LAYOUT NEQ 1> --->
					<tr ><td><span>#HTMLEditFormat(vaADD1)#, <CFIF vaADD2 IS NOT "">#HTMLEditFormat(vaADD2)#,</CFIF> <CFIF vaADD3 IS NOT "">#HTMLEditFormat(vaADD3)#,</CFIF> #HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(city)#, #COUNTRY#</span></td></tr>
					<tr ><td><span style="color:red">T :</span> #aTELNO# &nbsp;&nbsp;<span style="color:red">F:</span> #aFAXNO# &nbsp;&nbsp;<span style="color:red">W:</span> tuneprotect.com</td></tr>
				<!--- </CFIF> --->
			</table>
		</cfif>

	<CFELSEIF iGCOID IS 49>
		<!--- Multi-Purpose --->
		<table class=clsfooter id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-family:'Source Sans Pro'; font-size:8pt; color:##8080c8;" align=center>
		<tr><td></td></tr>
		<tr style="font-size:90%" align="justify"><td><b>#vaCONAME# <span style="font-size:80%">(#vaCOREGNO#)</span></b> - <span>#HTMLEditFormat(vaADD1)#, <CFIF vaADD2 IS NOT "">#HTMLEditFormat(vaADD2)#,</CFIF> <CFIF vaADD3 IS NOT "">#HTMLEditFormat(vaADD3)#</CFIF>#HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(city)#</span></td></tr>
		<!--- <CFIF vaCOTAGLINE IS NOT ""><tr style="font-size:80%" align="center"><td>(#vaCOTAGLINE#)</td></tr></CFIF> --->
		<!--- <tr style="font-size:80%" align="center"><td>Ground Floor Wisma Goldhill, 67 Jalan Raja Chulan, 50200 Kuala Lumpur, PO Box 12200 50770 Kuala Lumpur</td></tr>
		<tr style="font-size:80%" align="center"><td>General Line: (603) 2170 8282&nbsp;&nbsp;&nbsp;Claims Fax: (603) 2031 6393 Customer Service Line: (603) 2170 8383</td></tr>
		<tr style="font-size:80%" align="center"><td>E-mail: customer.service@axa.com.my&nbsp;&nbsp;&nbsp;Website: www.axa.com.my</td></tr> --->
		<tr style="font-size:90%" align="justify"><td><span>Telephone : #aTELNO# </span> &nbsp;<span>-&nbsp; Fax: #aFAXNO#</span> &nbsp;<span>-&nbsp; Email: customer.service@axa.com.my</span>&nbsp;<span><b>-&nbsp; www.axa.com.my</b></span>&nbsp;<span>-&nbsp; Service Tax Reg. No.:#vasvcregno#</span></td></tr>
		</table>
	<!--- <CFELSEIF iGCOID IS 49>
		<!--- AXA --->
		<!--- <table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-family:comic sans MS" align=center>
			<tr style="font-size:80%" align="center"><td>The integration process between AXA Affin General Insurance Berhad and BH Insurance (M) Berhad which was acquired in April 2010 has been completed. As of 1 January 2011, we are officially one legal entity, operating as AXA Affin General Insurance Berhad.</td></tr>
		</table>--->
<!--- 		<table class=clsFooter id=COFOOTER border="1" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial;text-align:center">
		<tr><td align="center"><IMG SRC="#request.webroot#MSupport/logo/axa-v4_footer.jpg"></td></tr>
		</table>
		 --->
<!--- 		<div id=COFOOTER style="text-align:center">
			<div style="margin:0px auto;width:680px;height:71px">
			<IMG SRC="#request.webroot#MSupport/logo/axa-v4_footer.jpg" style="margin:0px auto;">
			</div>
		</div> --->
		<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%" align=center>
		<tr><td align="center"><IMG SRC="#request.webroot#MSupport/logo/axa-v4_footer.jpg"></td></tr>
		</table> --->
	<CFELSEIF iGCOID IS 50>
		<!--- Jerneh --->
			<cfif Attributes.COID NEQ iGCOID><!--- is branch company, show footer --->
			<table class=clsFooter id=COFOOTER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial;text-align:center">
			<tr><td align="center" style="font-family:arial;font-size:10px">
			Head Office: #request.ds.co[igcoid].ADD1#, #request.ds.co[igcoid].ADD2#, #request.ds.co[igcoid].POSTCODE# Kuala Lumpur Malaysia &nbsp; Tel: #request.ds.co[igcoid].TELNO# &nbsp;Fax: #request.ds.co[igcoid].FAXNO#

<!---
			ACE Jerneh Insurance Berhad <span style="font-size:8px;line-height:115%;padding-bottom:1px">(9827-A)</span><br>
			<cfif vaADD1 NEQ "">#HTMLEditFormat(thisadd1)#<br></cfif>
			<cfif vaADD2 NEQ "">#HTMLEditFormat(vaADD2)#<br></cfif>
			<cfif vaADD3 NEQ "">#HTMLEditFormat(vaADD3)#<br></cfif>
			<cfif vaPOSTCODE NEQ "" OR city NEQ "">#HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(thiscity)#<cfif attributes.coid IS iGCOID><br>Malaysia<cfelseif thiscity NEQ thisstate><cfif len(thiscity)+len(thisstate) GT 20><br><cfelse>, </cfif>#thisstate#</cfif></cfif>
			</td>
			<td valign="top" align=left width="20%" <!--- width="115px" ---> style="font-family:arial;font-size:10px;line-height:125%">
			#HTMLEditFormat(aTELNO)# <i>tel</i><br>
			#HTMLEditFormat(aFAXNO)# <i>fax</i><br>
			www.acejerneh.com.my

 --->
			</td></tr>
			</table>
			</cfif>
	<CFELSEIF iGCOID IS 64 OR iGCOID IS 54>
			<!--- in case any place missing this font --->
			<style>
				@font-face {
					font-family: NewJune;
					src: url(#request.webroot#MSupport/font/NewJune-Regular.otf);
				}
			</style>
			<!--- Tokio Marine --->
			<div class="NewJune" style="display: block; width:100%;font-family:NewJune;">
			<table class="NewJune" id=NewJune border="0" cellPadding="0" cellSpacing="0" width="100%"  align=center>
			<tr>
				<td align="left" width="70%">
				<!--- <img SRC="#request.webroot#MSupport/logo/TMG_add.png " height="40px" width="293px"> --->
					<table style="height:40px;width:100%"  border="0" cellPadding="0" cellSpacing="0" style="font-family:NewJune;">
					<tr>
						<td>
							<span style="font-size:8pt;color:0096A9;"><b>#HTMLEditFormat(vaCONAME)#</b></span>
							<span style="font-size:65%;color:0096A9;">#vaCOREGNO#</span>
							<br/>
							<span style="font-size:6pt;">
							#HTMLEditFormat(vaADD1)# #HTMLEditFormat(vaADD2)# <CFIF attributes.layout EQ 0><br></CFIF>#vaPOSTCODE# #city#, #COUNTRY#.<br/>
							<span style="color:0096A9;font-weight:bold">T</span> : #aTELNO# <span style="color:0096A9;font-weight:bold">F</span> : #aFAXNO#
							<cfif CompareNoCase(attributes.CUSTOM,'ClaimForm') EQ 0>
								<span style="color:0096A9;font-weight:bold">Customer Service Hotline</span> : 1800 88 0812
							</cfif>
							<br/>
							tokiomarine.com</span>
						</td>
					</tr>
					</table>
				</td>
				<td align="right" width="30%">
					<img src="#request.webroot#MSupport/logo/TMG_2.png" height="26.5" width="117">
				</td>
				<!---td align="right" width="30%">&nbsp;</td--->
			</tr>
			<cfif Attributes.CUSTOM is 1>
				<tr>
					<td colspan=2 align=right><img src="#request.webroot#MSupport/QR_code_TMIM_claims_survey1.png" width="100" height="50"></td>
				</tr>
			</cfif>
			</table>
			</div>

<!--- 			<table class=COFOOTER id=COFOOTER border="0" cellPadding="0" cellSpacing="0" style="width:100%;font-family:Serif" align=center>
			<tr>
				<td style="text-align:left;width:70%" align="left">
					<table style="width:100%">
					<tr><td><span style="font-size:120%;letter-spacing:1px"><b>#HTMLEditFormat(vaCONAME)#</b></span><span style="font-size:60%">(149520-U)</span></td></tr>
					<tr><td><span style="font-size:80%">
					#HTMLEditFormat(vaADD1)# #HTMLEditFormat(vaADD2)# #vaPOSTCODE# #city#, Malaysia<br/>
					Tel No : #aTELNO# Fax No : #aFAXNO#<br/>
					www.tokiomarine.com.my
					</td></tr>
					</table>
				</td>
				<td align="right" style="width:30%"><img SRC="#request.webroot#MSupport/logo/tokio_marine_group.gif"></td>
			</tr>
			</table> --->

	<CFELSEIF iGCOID IS 415>
		<!--- ACE --->
		<cfif DateDiff("d",DateFormat(Now(), "yyyy-mm-dd"), "2012-01-04") LTE 0>
			<!--- table class=clsFooter id=COFOOTER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial;text-align:center">
			<tr><td align="center" style="font-family:arial;font-size:10px">
			Head Office: Wisma ACE Jerneh, 38 Jalan Sultan Ismail, 50250 Kuala Lumpur Malaysia &nbsp; Tel: 03 2116 3300 &nbsp;Fax: 03 2142 6672
			</td></tr>
			</table --->
		<cfelseif DateDiff("d",DateFormat(Now(), "yyyy-mm-dd"), "2012-01-01") LTE 0><!--- from 1st jan 2012 til 3rd jan 2012 --->
			<table class=clsFooter id=COFOOTER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial;text-align:center">
			<tr><td align="center" style="font-family:arial;font-size:10px">
			Head Office: Wisma Jerneh, 38 Jalan Sultan Ismail, 50250 Kuala Lumpur Malaysia &nbsp; Tel: 03 2116 3300 &nbsp;Fax: 03 2142 6672
			</td></tr>
			</table>
		</cfif>
	<CFELSEIF iGCOID IS 57>
		<!--- Pacific --->
		<!---<table id="COFOOTER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 90%;font-family:arial narrow" align="center" background="">
		<tr style="font-size:80%" align="left"><td><b>#vaCONAME#</b> (#vaCOREGNO#)</td><td>&nbsp;</td></tr>
		<tr style="font-size:80%" align="left"><td>#vaADD1#<cfif #vaADD2# neq "">,&nbsp;#vaADD2#,&nbsp;</cfif></td><td>&nbsp;</td></tr>
		<tr style="font-size:80%" align="left"><td>P.O. Box 12490, #vaPOSTCODE# #city#, Malaysia.</td><td>&nbsp;</td></tr>
		<tr style="font-size:80%" align="left"><td>Tel: #aTELNO# Fax: #aFAXNO# #vaEMAIL#</td><td>&nbsp;</td></tr>
		</table>---><!---<br><br><br>--->
	<CFELSEIF iGCOID IS 69 OR iGCOID IS 74>
		<!--- OAC --->
		<table id=COFOOTER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:95%;color:darkblue" align="center">
		<tr><td style="font-size:75%"><CFIF iGCOID IS 74>Great Eastern General Insurance<CFELSE>#HTMLEditFormat(vaCONAME)#</CFIF> (#vaCOREGNO#)</td></tr>
	<!--- 	<tr><td style="font-size:80%;border-bottom:1px solid darkblue">(Formerly known as Overseas Assurance Corporation (Malaysia) Berhad)</td></tr> --->
		<tr><td align="right" style="font-size:75%">#HTMLEditFormat(vaADD1)#<CFIF #vaADD2# IS NOT "">, #HTMLEditFormat(vaADD2)#</cfif>&nbsp;#HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(city)#</td></tr>
		<tr><td align="right" style="font-size:75%">Tel: #HTMLEditFormat(aTELNO)# Fax: #HTMLEditFormat(aFAXNO)# website: www.greateasterngeneral.com</td></tr>
		</table>
	<CFELSEIF iGCOID IS 70 OR iGCOID IS 9616>
		<!--- MAA --->
		<!--- v1 : table id=COFOOTER border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 90%" align="center" background="" style="font-size:90%">
		<tr class=clsRow><td colspan=3>&nbsp;</td></tr>
		<tr style="font-size:80%"><td rowspan=2><img src="#request.webroot#MSupport/logo/maa-sirim.gif"></td><td style="font-style:italic;border-bottom-style:solid;border-bottom-color:black;border-bottom-width:1px" align=center>THIS IS A COMPUTER GENERATED DOCUMENT AND NO SIGNATURE IS REQUIRED</td><td rowspan=2><img src="#request.webroot#MSupport/logo/maa-aiia.jpg"></td></tr>
		<tr><td align=center style="font-size:70%"><img src="#request.webroot#MSupport/logo/maa-smalllogo.gif"> A Melewar Group Company</td></tr>
		</table --->
		<table id=COFOOTER border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 90%" align="center" background="">
		<tr class=clsRow><td colspan=3>&nbsp;</td></tr>
		<tr style="font-size:80%">
			<td width="10%" rowspan=2>&nbsp;<!--- img src="#request.webroot#MSupport/logo/maa-sirim.gif" ---></td>
			<td width="80%" style="font-style:italic;font-size:8pt;font-face:time new roman;border-bottom-style:solid;border-bottom-color:black;border-bottom-width:1px" align=center>THIS IS A COMPUTER GENERATED DOCUMENT AND NO SIGNATURE IS REQUIRED</td>
			<td width="10%" rowspan=2 style="padding-left:15px"><!---><img src="#request.webroot#MSupport/logo/maa-sirim_v2.gif">---></td>
		</tr>
		<!--- <tr><td align=center style="font-size:8pt;font-family:times new roman"><img src="#request.webroot#MSupport/logo/maa-smalllogo.gif"> A Melewar Group Company</td></tr> --->
		</table>
	<!----<CFELSEIF iGCOID IS 72>
		<!--- Sykt Takaful Malaysia --->
		<table id=COFOOTER border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 90%" align="center" background="">
		<tr><td align=right><img src="#request.webroot#MSupport/logo/takafulmy_footer.gif"></td></tr>
		</table>---->
	<!---<CFELSEIF iGCOID IS 74>
		<!--- Tahan --->
		<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:90%;font-size:75%" align=center>
		<tr><td align=center style="font-weight:bold;font-size:120%">Overseas Assurance Corporation (Malaysia) Berhad <span style="font-size:100%">(#vaCOREGNO#)</span></td></tr>
		<tr><td align=center>#HTMLEditFormat(vaADD1)#<CFIF #vaADD2# IS NOT "">, #HTMLEditFormat(vaADD2)#</cfif>, #HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(city)#, <!---<cfif #attributes.coid# IS 74>P.O. Box 7784, 40728 Shah Alam, </cfif> --->#HTMLEditFormat(state)#</td></tr>
		<tr><td align=center>Tel: #aTELNO# &nbsp;Fax: #aFAXNO# &nbsp;Website: www.tahaninsurance.com</td></tr>
		</table>--->
	<CFELSEIF iGCOID IS 7651 AND Attributes.COID IS 76>
		<!--- AmAssurance --->
		<!--@marginBottom="1"-->
		<!--PDFfooterTop-->
		<style>.clsFooter td {font-family: Arial,Verdana,'Sans-Serif'; padding-top:0px; padding-bottom:0px; line-height:1.2em;}</style>
		<table class=clsFooter id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%" align=center>
		<!--- <tr><td align="left" style="font-size: 130%"><b>#vaCONAME#</b></td></tr> --->
		<!---><tr><td align="left" style="font-size: 80%"><b>#vaCONAME#</b><i> (#vaCOREGNO#)&nbsp;&nbsp;&nbsp;&nbsp;Penanggung Insurans Berlesen&nbsp;&nbsp;&nbsp;&nbsp;A Member of the AmBank Group</i></td></tr>
		<tr><td align="left" style="font-size: 65%">#vaADD1#<CFIF #vaADD2# IS NOT "">, #vaADD2#</cfif>, #vaPOSTCODE# #city#, Malaysia. GPO P.O Box 10956, 50730 Kuala Lumpur.</td></tr>
	    <tr><td align="left" style="font-size: 65%"><CFIF #aTELNO# IS NOT "">Tel: <cfif iSTATEID eq 12>(6088)<cfelseif iSTATEID eq 13>(6082)<cfelse>(603)</cfif> #aTELNO#</cfif><CFIF #aFAXNO# IS NOT "">&nbsp; Fax: <cfif iSTATEID eq 12>(6088)<cfelseif iSTATEID eq 13>(6082)<cfelse>(603)</cfif> #aFAXNO#</cfif>&nbsp;&nbsp;Call Centre: (603) 217 88000&nbsp;&nbsp;&nbsp;Accident Assistance Hotline: 1-300-880-898&nbsp;&nbsp;&nbsp;Email:amassurance@ambg.com.my&nbsp;&nbsp;&nbsp;Website: www.ambg.com.my</td></tr>
		--->
		<tr><td align="left" style="font-size: 10px"><b>AmGeneral Insurance Berhad</b> (#vaCOREGNO#)</td></tr>
		<CFIF vaCOTAGLINE IS NOT ""><tr><td align="left" style="font-size: 8px">#vaCOTAGLINE#</td></tr></CFIF>
		<tr><td align="left" style="font-size: 9.5px"><i>A member of the AmBank Group</i></td></tr>
		<tr><td align="left" style="font-size: 9.5px">#vaADD1#<CFIF #vaADD2# IS NOT "">, #vaADD2#</cfif>, #vaPOSTCODE#, #city#, Malaysia<br>PO Box 11228, GPO Kuala Lumpur, 50740 W.P. #city#, Malaysia</td></tr>
	    <tr><td align="left" style="font-size: 9.5px"><b>Tel:</b> #aTELNO# &nbsp;&nbsp;&nbsp; <b>Email:</b> #vaEMAIL# &nbsp;&nbsp;&nbsp; <b>Web:</b> www.amassurance.com.my</td></tr>
	    <tr><td align="left" style="font-size: 9.5px">(Service Tax Registration No: B16-1808-31015443)</td></tr>
		</table>
		<!--/PDFfooterTop-->

	<!---<CFELSEIF iGCOID IS 77>
		<!--- AIA --->
		<table id=COFOOTER border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 100%" align="center">
		<tr><td colspan=2 align="right"><IMG SRC="#request.webroot#MSupport/logo/aia_newfooter.gif"></td><td width=17%>&nbsp;</td></tr></table>--->
	<!---<CFELSEIF iGCOID IS 78>
		<!--- Takaful Nasional --->
		<table id=COFOOTER border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 100%" align="center" background="">
		<tr><td align="center"><IMG SRC="#request.webroot#MSupport/logo/tnsbfooter.gif"></td></tr>
		</table>--->

	<!---CFELSEIF iGCOID IS 1342>
		<cfif StructKeyExists(Attributes, "aligntype") and Attributes.aligntype EQ "center">
		<!--- Prudential --->
		<table id=COFOOTER border="0" cellspacing="1" cellpadding="1" align="center" style="WIDTH: 100%; font-size: 75%">
		<tr><td align="center"><font color=##990000>#vaCONAME#</font> (#vaCOREGNO#)</td></tr>
		<tr><td align="center">#vaADD1#<CFIF #vaADD2# IS NOT "">, #vaADD2#</cfif>, #vaPOSTCODE# #city#, P.O. Box 10025, 50700 Kuala Lumpur</td></tr>
		<tr><td align="center">Customer Service Hotline: 03-2116 0228, <CFIF #aFAXNO# IS NOT "">&nbsp; Fax: #aFAXNO#,</cfif> <cfif #vaEMAIL# is not "">&nbsp; Email: #vaEMAIL#</cfif></td></tr>
	    <!---<tr><td align="center" style="font-size: 90%">Part of Prudential plc (United Kingdom)</td>--->
		</table>
		<cfelse>
		<!--- Prudential --->
		<table id=COFOOTER border="0" cellspacing="1" cellpadding="1" align="center" style="WIDTH: 100%; font-size: 75%">
		<tr><td align="left"><font color=##990000>#vaCONAME#</font> (#vaCOREGNO#) #vaADD1#<CFIF #vaADD2# IS NOT "">, #vaADD2#</cfif>, #vaPOSTCODE# #city#, Malaysia.</td></tr>
		<tr><td align="left">P.O. Box 10025, 50700 Kuala Lumpur. Call Centre: 03-2116 0228 <CFIF #aFAXNO# IS NOT "">&nbsp; Fax: #aFAXNO#</cfif>&nbsp;&nbsp;www.prudential.com.my</td></tr>
	    <tr><td align="left" style="font-size: 90%">Part of Prudential plc (United Kingdom)</td>
		</table>
		</cfif--->
	<CFELSEIF iGCOID IS 1713>
	<!--- Takaful Ikhlas --->
		<!---><table id=COFOOTER border="0" cellspacing="1" cellpadding="1" align="center" style="WIDTH: 95%;color:darkgreen">
		<tr><td style="font-size:7.5pt"><b>#UCASE(vaCONAME)#</b><span style=font-size:70%> (593075-U)</span></td></tr>
		<tr><td style="font-size:7.5pt">#vaADD1#<CFIF #vaADD2# IS NOT "">, #vaADD2#</cfif>, Locked Bag 11094, #vaPOSTCODE# #city#</td></tr>
		<tr><td style="font-size:7.5pt">tel: #aTELNO# &nbsp;&nbsp;&nbsp;&nbsp; fax: #aFAXNO# &nbsp;&nbsp;&nbsp;&nbsp; website:www.takaful-ikhlas.com.my</td></tr>
		<tr><td style="font-size:7.5pt">(A subsidiary of Malaysian Nasional Reinsurance Berhad)</td></tr>
		</table>	--->

		<!--- Start #30949 kofam --->
		<table id=COFOOTER border="0" cellspacing="0" cellpadding="0" align="center" style="WIDTH: 95%;">
		<tr><td style="font-size:7.5pt"><b>#UCASE(vaCONAME)#<span style=font-size:70%> (1233870-A)</span></b></td></tr>
		<tr><td>&nbsp;</td></tr>
		<tr><td style="font-size:7.5pt">#vaADD1#<CFIF #vaADD2# IS NOT "">, #vaADD2#</cfif>, #vaPOSTCODE# #city#</td></tr>
		<tr><td style="font-size:7.5pt"><b>Tel</b>: #aTELNO# &nbsp;&nbsp; <b>Fax</b>: #aFAXNO# &nbsp;&nbsp; <b>IKHLAS Care</b>: 03 2723 9696 &nbsp;&nbsp; <b>Website</b>: www.takaful-ikhlas.com.my</td></tr>
		<tr><td>&nbsp;</td></tr>
		<tr><td><img width=100% SRC="#request.webroot#MSupport/logo/tIkhlas-footer.png"><td></tr>
		</table>
		<!--- End #30949 kofam --->

	<CFELSEIF iGCOID IS 152> <!---modified by Siew on 7 July 2004 to reflect current address instead of hardcoded value--->
		<!--- EPOng customization --->
		<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style=WIDTH:100%;color:blue>
		<tr><td align="center" style="font-size:80%;border-top:1px solid blue">#vaADD1# <CFIF #vaADD2# IS NOT "">, #vaADD2#</cfif>, #vaPOSTCODE# #city#</td></tr>
		<tr><td align="center" style="font-size:80%">Tel: #aTELNO# Fax: #aFAXNO# E-mail: #RTrim(vaEMAIL)#</td></tr>
		</table>
	<CFELSEIF iGCOID IS 3062>
		<!--- Prudential BSN Takaful--->
		<table id=COFOOTER border="0" cellspacing="1" cellpadding="1" align="center" style="WIDTH: 100%; font-size: 75%">
		<tr><td align="left"><font color=##990000>#vaCONAME#</font> (#vaCOREGNO#) #vaADD1#<CFIF #vaADD2# IS NOT "">, #vaADD2#</cfif>, #vaPOSTCODE# #city#, Malaysia.</td></tr>
		<tr><td align="left">Tel: #aTELNO#&nbsp; Fax: #aFAXNO#&nbsp;&nbsp;www.prubsn.com.my</td></tr>
		</table>

	<cfelseif iGCOID IS 2943>
		<table id=COFOOTER border="0" cellPadding="0" cellSpacing="0" style="border-top:2px solid black;border-bottom:2px solid black;width:90%;font-size:6pt" align="center">
			<tr>
				<td>Branch Office :</td>
				<td colspan="3"><b>No. : 18A, Jalan Indah 16/5,<br/>Taman Bukit Indah, <br/>81200 Johor Bahru, Johor.</b></td>
				<td style="width:10%">&nbsp;</td><td valign="top">*Office Hours :</td>
				<td>Monday &##8660; Friday<br>Saturday<br>Lunch Hour</td><td>:<br/>:<br/>:</td>
				<td>8.30 a.m. &##8660; 5.00 p.m.<br/>8.30 a.m. &##8660; 1.00 p.m.<br/>1.00 p.m. &##8660; 2.00 p.m.</td>
			</tr>
			<tr>
				<td>&nbsp;</td><td>No. Tel<br/>No. Fax<br/>E-mail</td><td>:<br/>:<br/>:</td>
				<td>07-2366195<br/>07-2356196<br/>ckyandcojb@gmail.com</td><td>&nbsp;</td>
				<td colspan="3" valign="top"><b><i>*Closed on every gazette holidays</i></b></td>
				<td>&nbsp;</td>
			</tr>
		</table>
	<CFELSEIF iGCOID IS 7775><!---7775--->
		<!--- Dass, Jainab (Solitor)--->
		<table id=COFOOTER border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 100%" align="center" background="">
		<tr><td align="center"><IMG SRC="#request.webroot#MSupport/logo/dassjainabft.jpg"></td></tr>
		</table>
	<CFELSEIF iGCOID IS 8598>
		<!--- AG Claim --->
		<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:90%" align=center>
			<tr><td align=center style="border-bottom:2px solid black">&nbsp;</td></tr>
			<tr><td align=center>#vaADD1#, #vaADD2#, #vaPOSTCODE# #city#, #state#</td></tr>
			<tr><td align=center>Tel : #aTELNO# &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Fax : #aFAXNO# &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; E-mail: enquiry@agclaims.com.my</td></tr>
			<tr><td align=center>Online Claim Services http://www.agclaims.com.my</td></tr>

		</table>
	<CFELSEIF iGCOID IS 200005>
		<!--- AIG Singapore --->
		<!---<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-family:Tahoma;font-size:6pt" align=center>
			<!---tr><td align=center>#HTMLEditFormat(vaADD1)#<CFIF #vaADD2# IS NOT "">, #HTMLEditFormat(vaADD2)#</cfif>, Singapore #HTMLEditFormat(vaPOSTCODE)# Tel: #aTELNO# Website: www.aig.com.sg</td></tr--->
			<!---<tr><td align=left><IMG SRC="#request.webroot#MSupport/logo/SG-AIG2.gif"></td><td align=right><IMG SRC="#request.webroot#MSupport/logo/SG-AIG3.gif"></td></tr>--->
			<tr><td align=right>Incorporated in the United States with Liability Limited</td></tr>
		</table>--->
	<CFELSEIF iGCOID IS 200023>
		<!--- orix fleet management --->
		<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-family:Tahoma;font-size:7pt" align=center>
			<tr><td align=left>
				<span style="font-size:18px">#UCASE(vaCONAME)#</span><span>&nbsp;&nbsp;&nbsp;
				<Cfif vaADD1 NEQ "">#vaADD1#</Cfif><cfif vaADD2 NEQ ""><cfif vaADD1 NEQ "">, </cfif>#vaADD2#</cfif>, SINGAPORE #vaPOSTCODE#. Website : http://www.orix.com.sg</span>
				<div>Company Registration No. #vaCOREGNO#</div>
			</td></tr>
		</table>
	<CFELSEIF iGCOID IS 200024>
		<!--- AIG Singapore --->
		<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:5.5pt;color:000333;font-weight:bold" align=center>
			<tr><td align=center>Our equipment include the latest and reliable CAR-O-LINER MARK 5 repair bench, draw aligner and the support dolly system to provide accurate re-alignment and speedy repairs.</td></tr>
		</table>
	<!--- Aisyah #44384 --->
	<CFELSEIF iGCOID IS 206209>
		<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:90%;position: fixed;left: 0;bottom: 0;" align=center>
			<tr><td valign=top width=18% style=font-size:10px;color:##003780;><b style=font-size:12px;color:##003780;>#REQUEST.DS.CO[IGCOID].CONAME#</b> | UEN #vaCOREGNO#</td></tr>
			<tr>
				<td style=font-size:10px;color:##003780;>#vaADD1# #vaADD2# #vaADD3# Singapore #vaPOSTCODE# | Tel: +65 #aTELNO# | Website: <a href="www.allianz.sg">www.allianz.sg</a> | Email: <a href="mailto:claims@allianz.sg">claims@allianz.sg</a></td>
			</tr>
		</table>
	<CFELSEIF iGCOID IS 200028>
		<cfif attributes.layout IS 2>
			<!--- Aisyah #44065 --->
			<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:90%" align=center>
				<tr><td valign=top width=18%>#REQUEST.DS.CO[IGCOID].CONAME# | #vaCOREGNO#</td></tr>
				<tr>
					<!--- <td>12 Marina View ##14-01 Asia Square Tower 2 Singapore #vaPOSTCODE# | Tel: #aTELNO# | Website: www.allianz.sg | Email: claims@allianz.sg </td> --->
					<td>#vaADD1# #vaADD2# #vaADD3# Singapore #vaPOSTCODE# | Tel: #aTELNO# | Website: www.allianz.sg | Email: claims@allianz.sg </td>
				</tr>
			</table>
		<cfelse>
			<!--- Allianz Singapore --->
			<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:90%" align=center>
				<tr><td width=35%>#vaADD1#</td><td width=8%>Phone</td><td>#aTELNO#</td></tr>
				<tr><td>#vaADD2#</td><td>Fax</td><td>#aFAXNO#</td></tr>
				<tr><td colspan=3>Singapore #vaPOSTCODE#</td></tr>
			</table>
		</cfif>
	<CFELSEIF iGCOID IS 200029>
		<!--- Axa Singapore --->
		<font size="0.8">
			<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:#attributes.WIDTH#;font-size:90%" align=center>
				<tr><td>#UCASE(vaCONAME)# (Company/GST Reg. No.: #vaTAXREGNO#)</td></tr>
				<tr><td>#htmleditformat(vaADD1)# #htmleditformat(vaADD2)#<cfif vaADD3 NEQ ""> #htmleditformat(vaADD3)#</cfif>, Singapore #vaPOSTCODE#</td></tr>
				<tr><td>AXA Customer Centre ##01-21/22</td></tr>
				<tr><td>Telephone: #Request.DS.LOCALES[session.vars.LOCID].HPHONEPREFIXLIST# #aTELNO#&nbsp;-&nbsp;axa.com.sg</tr>
			</table>
		</font>
	<CFELSEIF iGCOID IS 200031>
		<!---SG First Capital --->
		<table id=COFOOTER class="clsFooter" border=0 cellpadding=0 cellspacing=0 style="width:100%" align=center>
			<tr><td style="text-align:center;font-size:7pt;font-family:arial">
			<b>Main Office</b>: 6 Raffles Quay ##21-00 Singapore 048580 &nbsp;Tel: 65-6222 2311 &nbsp;Fax: 65-6222 3547 &nbsp;Web-site: http://www.first-insurance.com.sg<br>
			<b>Claims Departments & Motor Underwriting Department</b>: 36 Robinson Road ##16-01 City House Singapore 068877 Tel: 65-6507 3848 Fax: 65-6507 3849
			</td></tr>
		</table>
	<cfelseif iGCOID IS 200033>
	<cfparam name="attributes.nofooter" default=0>
		<cfif attributes.nofooter IS 0>
			<table class=clsFooter border=0 cellPadding=0 cellSpacing=0 style="align:left;">
				<tr>
					<td style="width:15%"><IMG SRC="#request.webroot#MSupport/logo/SG-200033_footer.jpg" height="110"></td>
				</tr>
			</table>
		</cfif>

		<!---table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
			<col style="text-align:left;line-height:120%">
			<tr><td>
			<div style="font-size:9pt;font-family:arial;color:1c3e8d;font-weight:bold;margin-bottom:2px">#htmleditformat(vaconame)#</div>
			<div style="font-size:8pt;font-family:arial;color:1c3e8d">CO. REG. NO.: #VACOREGNO#</div>
			<div>
			<table cellspacing=0 cellpadding=0 width=100% style="font-size:8pt;font-family:arial;color:1c3e8d">
			<tr><td width="45%">#HTMLEDITFORMAT(vaADD1)# #HTMLEDITFORMAT(vaADD2)# Singapore #vaPOSTCODE#</td>
				<td width="38%">TEL: 6347 6100 &nbsp; FAX: 6224 4174 . 6225 7743</td>
				<td width="17%">WEB: www.iii.com.sg</td>
			</table>
			</div>
			<div style="font-size:8pt;font-family:arial;color:1c3e8d">POSTAL ADDRESS: ROBINSON ROAD P.O. BOX NO. 738 SINGAPORE 901438</div>
			</td></tr>
		</table--->
	<cfelseif iGCOID IS 200034>
	<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:90%;font-size:90%" align=center>
		<tr>
			<td>
				#vaCONAME# <br>
				#vaADD1#<cfif #vaADD2# IS NOT ""> | #vaADD2#</cfif> | Singapore #vaPOSTCODE#<br>
				Tel: #aTELNO# | Fax: #aFAXNO# <br>
				Web: www.libertyinsurance.com.sg
				<!--- Tel: #aTELNO# | DID: &lt;&lt;Claims Handler DID&gt;&gt; | &lt;Web: http://www.libertyinsurance.com.sg/&gt;<br>
				www.libertyinsurance.com.sg --->
			</td>
		</tr>
	</table>
	<CFELSEIF iGCOID IS 200035 OR iGCOID IS 204702>
		<!--- SG etiqa --->
		<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:90%" align=center>
		<tr><td style="vertical-align:bottom">
			<b>#vaCONAME#</b><br>
			<div style="padding-bottom:3px">
			#vaADD1#<cfif #vaADD2# IS NOT ""><br>
			#vaADD2#</cfif><br>
			Singapore #vaPOSTCODE#<br>
			</div>
			<div><b>T:</b> #aTELNO#</div>
			<div><b>F:</b> #aFAXNO#</div>
			<div style="padding-top:3px;font-weight:bold">www.etiqa.com.sg</div>
			Company Reg No.: #vaCOREGNO#
			</td>
			<td style="width:190px;vertical-align:bottom;text-align:right;font-family:Arial;font-size:6.5pt;">A Member of the <img src="#request.webroot#MSupport/logo/sg-etiqa_btm.gif"> Group&nbsp;</td>
		</tr>
		</table>
	<cfelseif iGCOID IS 200036 OR iGCOID IS 200037 OR IGCOID IS 200115>
		<br>
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
			<col align=left>
			<tr>
				<!---td style="width:75%" style="font-family:arial;line-height:90%">
				<!--- <div style="font-size:8.5pt;font-weight:bold">MSIG Insurance (Singapore) Pte. Ltd.<!--- #vaCONAME# ---></div>
				<!---div style="font-size:7.5pt">(Company Registration No. #vaCOREGNO#)</div --->
				<div style="font-size:7.5pt">#vaADD1#<cfif #vaADD2# IS NOT ""> #vaADD2#</cfif> Singapore #vaPOSTCODE#</div>
				<div style="font-size:7.5pt">Tel: #aTELNO# &nbsp;&nbsp;&nbsp; Fax: #aFAXNO# &nbsp;&nbsp;&nbsp; www.msig.com.sg</div>
				<div style="font-size:7.5pt">Co. Reg. No. #vaCOREGNO#</div> --->
				<div style="padding-top:10px;font-size:7pt;margin-top:0px">A Member of <span style="padding:0px;background-color:006559;color:white;font-size:7.5pt">&nbsp;<b>MS</b> & <b>AD</b>&nbsp;</span> <span style="color:006559">INSURANCE GROUP</span></div>
				</td--->
				<td style="width:15%"><IMG SRC="#request.webroot#MSupport/logo/SG-MSIG-footer_v2.png" width="150px" height="13px"></td>
				<!---td style="width:15%"><IMG SRC="#request.webroot#MSupport/logo/SG-MSIG_footer.gif"></td--->
			</tr>
		</table>
	<cfelseif iGCOID IS 200038><!--- SG-NTUC --->
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
			<col style="line-height:120%">
			<tr><td style="font-size:9pt;font-family:arial">
			<div><span style="font-weight:bold">#htmleditformat(vaconame)#</span> <span style="font-size:80%; font-weight:">| UEN: 202135698W </span></div> 
			<!--- <div style="font-weight:bold">Income Insurance Limited | <span style="font-size:80%"> UEN: 202135698W </span></div> --->
			<div style="font-size:80%">#HTMLEDITFORMAT(vaADD2)# #HTMLEDITFORMAT(vaADD1)# Singapore #vaPOSTCODE# <span style="font-weight:bold">&##183;</span> Tel: 6788 1777 <span style="font-weight:bold">&##183;</span> Fax: 6338 1500 <span style="font-weight:bold">&##183;</span> Enquiries:income.com.sg/enquiry <span style="font-weight:bold"></span></div>
			<!--- <div><IMG style="width:100%" SRC="#request.webroot#MSupport/logo/NTUCfooter.jpg"></div> --->
			</td></tr>
		</table>
	<CFELSEIF iGCOID IS 200040><!--- SG-QBE --->
		<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
			<tr><td style="font-size:9pt;font-family:arial">
			<div style="font-weight:bold">A member of the worldwide QBE Insurance Group</div>
			</td></tr>
		</table>
    <CFELSEIF iGCOID IS 200042>
	    <!--- SHC Singapore --->
				<style type="text/css" media="print">
					@media print {
							body {
									margin: 0;
									padding: 0;
									height: 20mm;
							}
			
							.footer {
									position: absolute;
									bottom: 0;
									left: 0;
									right: 0;
							}
					}
			</style>
			<div class="footer">
				<table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
					<tr><td align="center" style="text-align:center;width:100%;font-size:7pt;">#vaCONAME#&nbsp;&nbsp; Co. Reg. No.: #vaCOREGNO#&nbsp;&nbsp; GST Reg. No.: #vaTAXREGNO#</td></tr>
					<tr><td align="center" style="text-align:center;width:100%;font-size:7pt;">#vaADD1# #vaADD2# Singapore #vaPOSTCODE# Tel: +65  <CFIF aTELNO neq "">#aTELNO#<CFELSE>6829 9199</CFIF>&nbsp;&nbsp; Email: <cfif vaemail NEQ "">#RTrim(vaEMAIL)#<cfelse>commercialclaims@ergo.com.sg </cfif> Weblink: www.ergo.com.sg</td></tr>
				</table>
			</div>
    <CFELSEIF iGCOID IS 200045>
        <!--- Tokio marine Singapore --->
        <div <!---class="clsFooter"---> style="text-align:left;width:100%;font-weight:bold">
        <br><br>Please note that all personal information provided to Tokio Marine Insurance Singapore Ltd. is subject to the Personal Data Protection Policy Statement posted at www.tokiomarine.com
        </div>
    <CFELSEIF iGCOID IS 200039 AND Attributes.COID IS NOT 200676><!--- SG-OAC (already renamed to SG-GEG) --->
		<!--- v1 :
		<table id=COFOOTER border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 100%" align="center" background="">
		<tr><td align="center"><IMG SRC="#request.webroot#MSupport/logo/SG-OAC-footer.gif"></td></tr>
		</table>
		--->
		<!--- v2 --->
		<table id=COFOOTER border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 100%" align="center" background="">
		<tr><td width=60% valign="bottom" style="font-size:8pt"><!--- <IMG SRC="#request.webroot#MSupport/logo/SG-OAC-footer.gif"> --->
		Great Eastern General Insurance Limited (Reg. No. #vaCOREGNO#)<br>
		(A wholly-owned subsidiary of Great Eastern Holdings Limited)<br>
		#vaadd1#, #vaadd2#, Singapore #vaPOSTCODE#<br>
		Tel +65 6248 2888 Fax +65 6327 3080 greateasterngeneral.com
		</td></tr>
		</table>
	<CFELSEIF iGCOID IS 200049><!--- Lonpac Singapore --->
        <table id=COFOOTER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
			<tr><td align="left" width="20%" valign="middle">
				<IMG SRC="#request.webroot#MSupport/logo/SG-lonpac-b1_v2.gif">
				</td>
				<td align="center" width="60%" valign="middle">
				#vaADD1# #vaADD2# Singapore #vaPOSTCODE#<br>
				Tel: (65) 6250 7388 Fax: (65) 6296 3767<br>
				Website: www.lonpac.com.sg
				</td>
				<td align="right" width="20%" valign="middle">
				<IMG SRC="#request.webroot#MSupport/logo/SG-lonpac-b2_v2.gif">
				</td>
			</tr>
        </table>
    <cfelseif iGCOID IS 200059>
        <table id=COHEADER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;" align="center" background="">
            <tr><td align="right"><cfif UCASE(attributes.manufacturer) IS "LEXUS">
				<IMG SRC="#request.webroot#MSupport/logo/SG-borneomtr_footer_lexus.gif">
				<cfelse>
				<IMG SRC="#request.webroot#MSupport/logo/SG-borneomtr_footer.gif">
                </cfif></td></tr>
        </table>
	<CFELSEIF iGCOID IS 200098>
		<table id=COFOOTER border="0" cellspacing="01" cellpadding="0" align="center" style="WIDTH: 100%; font-size:80%;font-weight:bold;<!--- background:url(#request.webroot#MSupport/logo/SG-eqi_foot7.png) no-repeat center z-index=1 --->">
			<tr>
				<td valign="bottom" width="80%">
					<br><b>#vaconame#</b><br>
					<font color="cyan">#vaADD1# #vaADD2# Singapore #vaPOSTCODE#<br>
					tel: #aTELNO# | Fax: #afaxNO# | www.eqinsurance.com.sg<br>
		 			reg no. : #vaCOREGNO#</font>
				</td>
			</tr>
			<tr>
				<td valign="bottom"><img src="#request.webroot#MSupport/logo/SG-eqi_foot-left.png"></td></tr>
		</table>
	<CFELSEIF iGCOID IS 200112>
		<!--- SG-REP : su brothers --->
		<div <!---class="clsFooter"---> style="text-align:right;width:100%"><IMG SRC="#request.webroot#MSupport/logo/SG-subrothers_btm.gif"></div>
	<CFELSEIF iGCOID IS 200118>
		<!--- SG-REP : Falcon-Air --->
		<div <!---class="clsFooter"---> style="text-align:center;width:100%"><IMG SRC="#request.webroot#MSupport/logo/SG-falconair_footer.gif"></div>
	<!--- CFELSEIF iGCOID IS 200123>
		<!--- SG-REP : SME Auto --->
		<div <!---class="clsFooter"---> style="text-align:left;width:100%;font-size:9pt;font-weight:bold;color:2a3f91">
		#vaADD1#<cfif vaADD2 NEQ "">, #vaADD2#</cfif>, Singapore #vaPOSTCODE#. <cfif aTELNO NEQ "">Tel: #aTELNO# (6 Lines)</cfif> &nbsp; <cfif afaxNO NEQ "">Fax: #afaxNO#</cfif><br>
		<cfif vaemail NEQ "">Email: #RTrim(vaEMAIL)#</cfif> &nbsp; Website: www.smeauto.com.sg
		<cfif vaCOREGNO NEQ ""><br>Co. Reg. No.: #vaCOREGNO#</cfif>
		<br>GST Regn No.: 53091788B
		</div --->
	<CFELSEIF iGCOID IS 200138>
		<!--- SG-REP : Ban Hock Hin --->
		<div <!---class="clsFooter"---> style="text-align:center;width:100%;font-size:9pt;font-weight:bold">
		ONE-STOP MOTORCYCLE ACCESSORIES &amp; SERVICE CENTRE<br>FULL MAINTENANCE, LEASING, RENTALS, MODIFICATIONS, FLEET, SALES
		</div>
	<CFELSEIF iGCOID IS 200144>
		<cfif Attributes.COID IS 202733>
			<!--- SG-ADJ : Aspectus --->
			<div <!---class="clsFooter"---> style="text-align:center;width:100%;font-size:9pt;font-family:Garamond,verdana;">
				<div style="font-weight:bold;font-size:11pt">#vaconame# (Affiliated to JP Knights Pte Ltd)</div>
				<div style="margin-top:2px">#vaADD1# <CFIF #vaADD2# IS NOT ""> #vaADD2#</cfif> #city# Singapore #vaPOSTCODE#. Tel: (65) 6345 0068 Fax: (65) 6344 5328<br>
						Email: admin@aspectus.sg &nbsp;Website: www.aspectus.sg &nbsp; Co. Reg. No. #vacoregno#</div>
			</div>
		<cfelse>
			<!--- SG-ADJ : JPknights (HQ) --->
			<div <!---class="clsFooter"---> style="text-align:center;width:100%;font-size:9pt;font-family:Garamond,verdana;">
				<div style="font-weight:bold;font-size:11pt">JP KNIGHTS PTE LTD</div>
				<div style="margin-top:2px">#vaADD1# <CFIF #vaADD2# IS NOT ""> #vaADD2#</cfif> #city# Singapore #vaPOSTCODE#. Tel: (65) 6345 0068 Fax: (65) 6344 5328<br>
						Email: admin@jpknights.com &nbsp;Website: www.jpknights.com &nbsp; Co. Reg & GST No. 200723763Z</div>
			</div>
		</cfif>
	<CFELSEIF iGCOID IS 200147>
		<!--- SG-ADJ : Insight Adjusters and Surveyors Pte Ltd --->
		<div <!----class="clsFooter"---> style="text-align:center;width:100%;font-size:7pt;font-family:arial;line-height:12px">
		<b>ASIA REGIONAL OFFICE</b> for <span style="background-color:de6f51">&nbsp;<b>vrs uni<span style="color:1b60c1;font-size:9pt">&raquo;</span>verse</b>&nbsp;</span> adjusters network LLC<br>
		ASIA &##8226; AUSTRALASIA &##8226; AFRICA &middot; EUROPE &##8226; LATIN AMERICA &##8226; MIDDLE EAST &##8226; NORTH AMERICA<br>
		<span style="color:222bbb">Office : Singapore &##8226; China &middot; Hong Kong &##8226; Malaysia &##8226; Philippines &##8226; Indonesia &##8226; Middle East</span>
		</div>
	<CFELSEIF iGCOID IS 200149>
		<!--- SG-REP : tan lim motor --->
		<div <!---class="clsFooter"---> style="text-align:center;width:100%;font-family:arial;font-size:12px">
		#vaADD1#<cfif vaADD2 NEQ ""> #vaADD2#</cfif> Singapore #vaPOSTCODE#<br>
		Tel : #aTELNO# (24 hours) &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Fax : #aFAXNO#<br>
		email@tlmotor.com.sg &nbsp;www.tlmotor.com.sg<br>
		<div style="font-weight:bold">Co. Reg. No.: #vaCOREGNO# &nbsp; GST Reg. No. : M2-8922054-2</div>
		</div>
	<CFELSEIF iGCOID IS 200197>
		<!--- SG : S & H Motor Pte Ltd --->
		<div style="border-top:1px solid black;padding-top:10px;text-align:center;font-size:8px">
		Workshop: #vaADD1#<CFIF #vaADD2# IS NOT "">, #vaADD2#</cfif>, #city# #vaPOSTCODE#. Tel: #aTELNO#&nbsp; Fax: #aFAXNO#&nbsp;&nbsp;E-mail: shmotor@singnet.com.sg<br>
		Co. Reg. No.: #vaCOREGNO# &nbsp;&nbsp; GST Reg. No.: M2-0076269-0
		</div>
	<cfelseif igcoid IS 200128>
        <table id=COFOOTER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial;font-size:7pt;line-height:100%" align="center" background="">
			<tr><td align="left"><img SRC="#request.webroot#MSupport/logo/SG_MITSUBISHI_F.png"></td></tr>
		</table>
    <cfelseif IGCOID IS 201622>
        <table id=COFOOTER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial;font-size:7pt;line-height:100%" align="center" background="">
			<tr><td valign="bottom"><img SRC="#request.webroot#MSupport/logo/SG-LWG_footer.gif"></td>
			     <td style="font-weight:bold;line-height:105%" valign="bottom" align="right">
        #vaconame#<br>#vaADD1#<br>#vaADD2#<br>Singapore #vaPOSTCODE#<br>www.wlgconsulting.com<br><br>
		Tel&nbsp; #aTELNO#<br>Fax&nbsp; #aFAXNO#
				</td>
			</tr>
		</table>
	<CFELSEIF iGCOID IS 200224>
		<!--- SG-REP : CYS auto --->
		<div style="text-align:center">
		#vaADD1#<cfif vaADD2 IS NOT "">, #vaADD2#</cfif>, Singapore #vaPOSTCODE#<br>
		<b>Tel: #aTELNO# (3 lines)&nbsp; Fax: #aFAXNO#</b>&nbsp;&nbsp;E-mail: <b>#vaEMAIL#</b><br>
		</div>
	<CFELSEIF iGCOID IS 200248>
		<!--- SG : goldbell eng --->
		<div style="text-align:center;padding-bottom:7px"><img SRC="#request.webroot#MSupport/logo/SG-goldbell_footer_v2.gif"></div>
		<div style="text-align:center;background-color:##fac513;border-top:1px solid ##fbd546">&nbsp;</div>
	<CFELSEIF iGCOID IS 200317>
		<!--- Allied Auto Appraisal --->
		<div style="border-top:1px solid black;padding-top:10px;text-align:center;font-size:8pt;line-height:100%">
		<b>#vaconame#</b><br>
		#vaADD1# &##8226;<!--- &##9744; ---> #vaADD2# &##8226;<!--- &##9744;---> Singapore #vaPOSTCODE#<br>
		Mobile : 65 9093 7344  &##8226;<!--- &##9744; ---> Email : #RTrim(vaEMAIL)#<br>
		Company Registration No. : #vaCOREGNO#
		</div>
	<!---CFELSEIF iGCOID IS 200384>
		<!--- 200384:AJAX adjusters --->
		<div style="font-family:Book Antiqua Bold;color:##00284a;padding-top:10px;text-align:center;font-size:12pt;line-height:100%"><b>#vaconame#</b></div>
		<div style="font-family:Book Antiqua Bold;color:##60798e;text-align:center;font-size:7pt"><cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" TARGET="ONELINE" NOCOREGNO=1 ADD1=#vaADD1# ADD2=#vaADD2# POSTCODE=#vaPOSTCODE# CITYID=#iCITYID#> T:#aTELNO# F:#aFAXNO# Business Reg. No.: #vaCOREGNO#</div--->
	<!--- <CFELSEIF iGCOID IS 200703>
		<!--- STA Inspection --->
		<div style="text-align:center"><img SRC="#request.webroot#MSupport/logo/SG-sta_footer.gif"></div> ---> <!--- #36560 --->
	<CFELSEIF iGCOID IS 200009>
		<!--- ST Kinetics --->
		<div style="text-align:center"><img SRC="#request.webroot#MSupport/logo/SG-sta_footer2.gif"></div>
	<CFELSEIF iGCOID IS 200798>
		<!--- aviva ltd --->
		<div style="text-align:center;font-size:8pt;float:left"><span style="font-weight:bold">#vaconame#</span> &nbsp; #vaADD1#<cfif vaADD2 NEQ "">, #vaADD2#</cfif>, Singapore<cfif vaPOSTCODE NEQ "">, #vaPOSTCODE#</cfif>.</div>
		<div style="text-align:center;font-size:8pt;float:right">Company Reg. No.: #vaCOREGNO#</div>
		<div style="clear:both"></div>
	<CFELSEIF iGCOID IS 200877>
		<!--- motorviva --->
		<div style="height:20px;background-color:##f0c425">&nbsp;</div>
	<CFELSEIF iGCOID IS 201278>
		<!--- vicom --->
        <!--- <cfif Right(Application.ApplicationName,6) EQ "_train"><!--- training mode ---> --->
        <table id=COFOOTER border="0" cellPadding="0" cellSpacing="0" style="WIDTH:100%;font-family:arial;font-size:8pt;line-height:100%" align="center" background="">
            <tr><td align="center">
				 <div style="font-weight:bold">Sin Ming</div>
				 385 Sin Ming Drive Singapore 575718<br>
				 Tel: (65) 6455 5358 &nbsp; Fax: (65) 6455 8638
                </td>
				<td align="center">
                 <div style="font-weight:bold">Bukit Batok</div>
                 511 Bukit Batok St 23 Singapore 659545<br>
                 Tel: (65) 6560 3312 &nbsp; Fax: (65) 6569 0722
				</td>
                <td align="center">
                 <div style="font-weight:bold">Kaki Bukit</div>
                 23 Kaki Bukit Ave 4 Singapore 415933<br>
                 Tel: (65) 6741 6697 &nbsp; Fax: (65) 6749 2305
                </td>
            </tr>
        </table>
<!--- 		<cfelse>
		      <div style="font-style:italic;text-align:center">#UCASE(vaADD1)# #UCASE(vaADD2)# SINGAPORE TEL: #aTELNO# &nbsp;FAX: #aFAXNO#</div>
	       </cfif> --->
	<CFELSEIF iGCOID IS 203148>
		<table id=COFOOTER border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 100%" align="center" background="">
		<tr><td align="center"><IMG SRC="#request.webroot#MSupport/logo/SG-203148-footer.gif"></td></tr>
		</table>
	<CFELSEIF iGCOID IS 700001>
	<!--- Adira --->
		<table id=COFOOTER border="0" cellspacing="01" cellpadding="0" align="center" style="WIDTH: 100%; font-size:80%;font-weight:bold">
		<tr><td colspan=2>#vaCONAME#</td></tr>
		<tr><td colspan=2>#vaCOBRNAME#</td></tr>
		<tr><td colspan=2>#vaADD1#</td></tr>
		<CFIF vaADD2 IS NOT ""><tr><td colspan=2>#vaADD2#</td></tr></CFIF>
		<tr><td colspan=2>#state# #vaPOSTCODE#</td></tr>
		<tr><td colspan=2>&nbsp;</td></tr>
		<tr><td width=6%>Tel.</td><td>#aTELNO#</td></tr>
		<tr><td>Fax.</td><td>#aFAXNO#</td></tr>
		<tr><td colspan=2>&nbsp;</td></tr>
		<tr><td colspan=2><img SRC="#request.webroot#MSupport/logo/autocillin_contact.gif"></td></tr>
		</table>
	<CFELSEIF iGCOID IS 700004>
	<!--- raksa --->
		<table id=COFOOTER border="0" cellspacing="01" cellpadding="0" align="center" style="WIDTH: 90%; font-size:75%">
			<tr>
				<td width="35%">
				<!--- first row --->
				<li><span style="font-weight:bold">Jakarta Pusat, </span>&nbsp;<span>(021) 3859007-8</span></li>
				<li><span style="font-weight:bold">Jakarta Selatan, </span>&nbsp;<span>(021) 7226805</span></li>
				<li><span style="font-weight:bold">Jakarta Tangerang, </span>&nbsp;<span>(021) 53124288</span></li>
				<li><span style="font-weight:bold">Jakarta Bogor, </span>&nbsp;<span>(0251) 248000</span></li>
				<li><span style="font-weight:bold">Jakarta Bandung, </span>&nbsp;<span>(022) 7315916</span></li>
				</td>
				<td width="33%">
				<!--- 2nd row --->
				<li><span style="font-weight:bold">Surabaya, </span>&nbsp;<span>(031) 54 767 53</span></li>
				<li><span style="font-weight:bold">Malang, </span>&nbsp;<span>(0341) 410890</span></li>
				<li><span style="font-weight:bold">Semarang, </span>&nbsp;<span>(0241) 3587501</span></li>
				<li><span style="font-weight:bold">Solo, </span>&nbsp;<span>(0271) 743127</span></li>
				<li><span style="font-weight:bold">Lampung, </span>&nbsp;<span>(0721) 7460095</span></li>
				</td>
				<td width="32%">
				<!--- 3rd row --->
				<li><span style="font-weight:bold">Medan, </span>&nbsp;<span>(061) 4525739</span></li>
				<li><span style="font-weight:bold">Pekanbaru, </span>&nbsp;<span>(0761) 862226</span></li>
				<li><span style="font-weight:bold">Palembang, </span>&nbsp;<span>(0711) 370478</span></li>
				<li><span style="font-weight:bold">Balikpapan, </span>&nbsp;<span>(0542) 8879330</span></li>
				<li><span style="font-weight:bold">Denpasar, </span>&nbsp;<span>(0361) 227210</span></li>
				</td>
			</tr>
			<tr><td colspan="5%" style="padding-top:5px;font-weight:bold" align="center">The Certification ISO 9001 is only applicable to the head office</td></tr>
		</table>
	<CFELSEIF iGCOID IS 700051>
	<!--- MSIG --->
		<table id=COFOOTER border="0" cellspacing="01" cellpadding="0" align="center" style="WIDTH: 100%; font-size:80%">
		<tr><td><b><span style="font-size:120%">#vaCONAME#</span> (TDP No. #vaCOREGNO#)</b></td></tr>
		<tr><td>A Member of Mitsui Sumitomo Insurance Group</td></tr>
		<tr><td>#vaADD1#<CFIF vaADD1 IS NOT "" AND vaADD2 IS NOT "">, </CFIF>#vaADD2#, #state# #vaPOSTCODE#</td></tr>
		<tr><td> Tel.: #aTELNO# Fax.: #aFAXNO# (Claims Department)</td></tr>
		</table>
	<CFELSEIF iGCOID IS 700125>
	<!--- Harta --->
		<table id=COFOOTER border="0" cellspacing="01" cellpadding="0" align="center" style="WIDTH: 100%; font-size:80%">
		<tr><td colspan=2 align=center><b>#vaCONAME#</b></td></tr>
		<tr><td colspan=2 align=center>#vaADD1#<CFIF vaADD1 IS NOT "" AND vaADD2 IS NOT "">, </CFIF>#vaADD2#, #state# #vaPOSTCODE# Telp.: #aTELNO# Fax.: #aFAXNO#</td></tr>
		<tr><td colspan=2 align=center>Homepage : www.asuransi-harta.co.id &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; E-mail : harta@asuransi-harta.co.id</td></tr>
		</table>
	<CFELSEIF iGCOID IS 700140>
	<!--- PT Asuransi Artarindo --->
		<style>
		.containCen{
			text-align:center;
			color:blue;
			font-size:75%
		}
		</style>
		<table id='COFOOTER' border="0" cellspacing="01" cellpadding="0" align="center" style="WIDTH: 100%;">
		<tr><td colspan=2 align=left style="font-size:75%;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;WO0200000ILG.RPT / Afiani --</td></tr>
		<tr><td colspan=2 class='containCen'>HEAD OFFICE : Gedung Hermina Tower Lt.12, JL. HBR. Motik Blok B-10 Kav.4, Gunung Sahari Selatan, Kemayoran, Jakarta Pusat 10610 Telp.(021) 39710999 Fax. (021) 397110013</td></tr>
		<tr><td colspan=2 class='containCen'>BRANCH OFFICE : BANDUNG : Komplek Ruko Metro Trade CEnter Blok J 18 JL.Soekarno Hatta 590 Bandung 40286 Telp.(022) 7536424 Fax. (022) 7536434  SEMARANG : JL.MT.Haryono No.573 Semarang Telp.(024) 8419883-84</td></tr>
		<tr><td colspan=2 class='containCen'>Fax.(024) 8419885 SURABAYA : Gedung Bumi Mandiri, Tower II 8th Floor Room 805 JL.Panglima Sudirman No.66-68 Surabaya Telp. (031) 5351233 Fax. (031) 5351255</td></tr>
		<tr><td colspan=2 class='containCen'>MEDAN : Ruko Sentosa Land JL.T.Amir Hamzah No.9F Kel.Silalas, Kec.Medan Barat, Medan Telp. (061) 66931402 Fax. (061) 6632665</td></tr>
		<tr><td colspan=2 class='containCen'>LAMPUNG : JL.Diponegoro No.59A, Teluk Betung Bandar Lampung Tel. (0721) 482696 Fax. (0721) 488553</td></tr>
		<tr><td colspan=2 class='containCen'>Kantor Pemasaran Makassar : Gedung Graha Pena Lt.1 Kav.105 H  JL.Urip Sumorarjo No.20 Kel.Karusiwi Utara, Pannakukang Makassar Telp. (0411) 421934 Fax. (0411) 421934</td></tr>
		</table>
	<CFELSEIF iGCOID IS 700170>
	<!--- MAG --->
	<cfif Attributes.LAYOUT IS 1>
		<table id=COFOOTER border="0" cellspacing="01" cellpadding="0" align="center" style="WIDTH: 100%; font-size:90%">
		<tr><td>
		Catatan penting : Pembayaran atas "Manfaat Biaya Transportasi" akan diproses/ditransfer ke rekening tersebut diatas dalam waktu maksimum 30 hari
		sejak kwitansi ini ditandatangani. Terima kasih.
		</td></tr>
		</table>
	<cfelse>
		<tr><td>
		<table id=COFOOTER border="0" cellspacing="01" cellpadding="0" align="center" style="WIDTH: 100%; font-size:80%">
		<tr><td colspan=2 align=center><b>#vaCONAME#</b></td></tr>
		<tr><td colspan=2 align=center> #vaADD1#, #vaADD2#, #state# #vaPOSTCODE# Tel.: #aTELNO# Fax.: #aFAXNO# Email: #vaEMAIL#</td></tr>
		</table>
	</cfif>


	<CFELSEIF iGCOID IS 700389>
	<!--- tias jaya --->
		<table id=COFOOTER border="0" cellspacing="01" cellpadding="0" align="center" style="WIDTH: 100%; font-size:80%">
		<!--- tr><td colspan=2 align=center><b>#vaCONAME#</b></td></tr --->
		<tr><td colspan=2 align=center style="color:3a3a3a">
		Jl. Taman Mutiara Prima No. 10 Gili Samping - Kemanggisan Jakarta Barat<br>
		Telp. (021) 5303849, 5303087 &nbsp; Fax. (021) 5362160<br>
		E-mail : tiasjaya_mtr08@yahoo.com
		</td></tr>
		</table>
	<!--- CFELSEIF iGCOID IS 700425>
	<!--- felix auto service --->
		<table id=COFOOTER border="0" cellspacing="01" cellpadding="0" align="center" style="WIDTH: 100%; font-size:80%">
		<!--- tr><td colspan=2 align=center><b>#vaCONAME#</b></td></tr --->
		<tr><td colspan=2 align=center style="font-weight:bold">
		<div style="color:0049aa">PT. FELIX AUTO SERVICE</div>
		<div>Jl. Dl. Panjaitan Kav. 5, Jakarta Timur 13350, Telp.: (021) 8190026 (HUNTING) Fax. : (021) 8570111</div>
		</td></tr>
		</table --->
	<CFELSEIF iGCOID IS 700467>
		<!--- PT Buana --->
		<table id=COFOOTER border="0" cellspacing="0" cellpadding="0" align="center" style="WIDTH: 100%">
			<tr><td><img SRC="#request.webroot#MSupport/logo/ID-Buana-Footer.gif"></td></tr>
		</table>
	<!--- start #39476 --->
	<CFELSEIF iGCOID IS 700488>
		<table id=COFOOTER border="0" cellspacing="0" cellpadding="0" align="center" style="WIDTH: 100%">
			<tr>
				<td colspan=2 align=center style="color:808080">
					<div>PT Asuransi Maximus Graha Persada Tbk</div>
					<div>(d/h. PT Asuransi Kresna Mitra Tbk)</div>
					<div>Gedung Graha Kirana Lantai 6, Jl. Yos Sudarso Kav 88, Sunter Jakarta Utara 14350, Indonesia</div>
					<div>T: +62 21 6531 1150     F: +62 21 6531 1160</div>
				</td>
			</tr>
		</table>
	<!--- end #39476 --->
	<CFELSEIF iGCOID IS 700509>
		<!--- PT Umum Mega --->
		<table id=COFOOTER border="0" cellspacing="0" cellpadding="0" align="center" style="WIDTH: 100%">
			<tr><td align=center>PT. ASURANSI UMUM MEGA MENERAPKAN PRINSIP GOOD CORPORATE GOVERNANCE<BR>
					PETUGAS KAMI TIDAK DIPERKENANKAN MENERIMA PEMBERIAN DALAM BENTUK APAPUN</td></tr>
		</table>
	<CFELSEIF iGCOID IS 700513>
		<!--- PT Chubb General Insurance Indonesia--->
		<table id=COFOOTER border="0" cellspacing="0" cellpadding="0" align="center" style="WIDTH: 100%">
			<tr>
				<td align=left style="width:45%"><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>

			</tr>
		</table>
	<cfelseif iGCOID is 703921>
		<!--- PT Chubb Syariah Insurance Indonesia--->
		<table id=COFOOTER border="0" cellspacing="0" cellpadding="0" align="center" style="WIDTH: 100%">
			<tr>
				<td align=left style="width:45%"><img SRC="#request.webroot#MSupport/logo/#cologo#"></td>

			</tr>
		</table>
	<CFELSEIF iGCOID IS 700519>
	<!--- ID Kurnia --->
		<table id=COFOOTER border="0" cellspacing="1" cellpadding="0" align="left" WIDTH=100% style="font-size:80%">
		<tr><td style="font-size:120%;color:##0000CD"><b>#vaCONAME#</b></td></tr>
		<tr><td style="WIDTH: 100%; font-size:90%">(A member of the Kurnia Group of Companies)</td></tr>
		<tr><td><cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" ADD1=#vaADD1# ADD2=#vaADD2# POSTCODE=#vaPOSTCODE# CITYID=#iCITYID# TARGET=ONELINE></td></tr>
		<tr><td><span style="color:##0000CD">Tel.</span>: #aTELNO# <span style="color:##0000CD">Fax.</span>: #aFAXNO# <span style="color:##0000CD">Email</span>: insure@kurnia.com <span style="color:##0000CD">Website</span>: www.kurnia.com/indonesia</td></tr>
		</table>
	<CFELSEIF iGCOID IS 700675>
	<!--- ID auto klinik --->
		<table id=COFOOTER border="0" cellspacing="1" cellpadding="0" align="center" style="WIDTH: 100%; font-size:80%">
		<!--- tr><td colspan=2 align=center><b>#vaCONAME#</b></td></tr --->
		<tr><td align="center"><cfif vaADD2 NEQ "">#vaADD2#</cfif><cfif state NEQ "" OR vaPOSTCODE NEQ ""> - #CITY#</cfif></td></tr>
		<tr><td align="center">Telp. #aTELNO#, Fax: #aFAXNO#, E-mail: #HTMLEditFormat(vaEMAIL)#</td></tr>
		</table>
	<CFELSEIF iGCOID IS 700719>
	<!--- ID Karya Nusantara Motor --->
		<table id=COFOOTER border="0" cellspacing="1" cellpadding="0" align="center" style="WIDTH: 100%; font-size:80%;">
		<!--- tr><td colspan=2 align=center><b>#vaCONAME#</b></td></tr --->
		<tr><td align="center" style="background-color:##3a54a9;color:white;font-size:9.5pt;padding:9px"><cfif vaADD2 NEQ "">#vaADD2#</cfif> JAKARTA #vaPOSTCODE# TELP. 79198278-79198279 (FAX) 79170257, JAKARTA</td></tr>
		</table>
	<CFELSEIF iGCOID IS 700938>
	<!--- ID CV MUSTIKA BUANA --->
		<table id=COFOOTER border="0" cellspacing="01" cellpadding="0" align="center" style="WIDTH: 100%; font-size:100%;font-weight:bold">
		<tr><td align="center">
			<cfif vaADD1 NEQ "">#vaadd1#</cfif><cfif vaADD2 NEQ "">, #vaadd2#</cfif>, Bekasi Timur <cfif vaPOSTCODE NEQ ""> #vaPOSTCODE#</cfif> Telp. : #aTELNO# , Fax. : #aFAXNO#<br>
			<cfif vaEMAIL NEQ "">e-mail. : #HTMLEditFormat(vaEMAIL)#</cfif>
		</td>
		</td></tr>
		</table>
	<cfelseif iGCOID IS 703734>
		<!---<table id=COFOOTER border="0" cellspacing="01" cellpadding="0" align="center" style="WIDTH: 100%; font-size:100%;font-weight:bold">
		<tr>
			<td align="center"><IMG SRC="#request.webroot#MSupport/logo/fairfax_footer.gif"></td>
		</table>--->
		<cfif Attributes.LAYOUT IS 1>
			<table id=COFOOTER border="0" cellspacing="01" cellpadding="0" align="center" style="WIDTH: 100%; font-size:90%">
			<tr><td>
			Catatan penting : Pembayaran atas "Manfaat Biaya Transportasi" akan diproses/ditransfer ke rekening tersebut diatas dalam waktu maksimum 30 hari
			sejak kwitansi ini ditandatangani. Terima kasih.
			</td></tr>
			</table>
		<cfelse>
			<tr><td>
			<table id=COFOOTER border="0" cellspacing="01" cellpadding="0" align="center" style="WIDTH: 100%; font-size:80%">
			<tr><td colspan=2 align=center><b>#vaCONAME#</b></td></tr>
			<tr><td colspan=2 align=center> #vaADD1#, #vaADD2#, #state# #vaPOSTCODE# Tel.: #aTELNO# Fax.: #aFAXNO# Email: #vaEMAIL#</td></tr>
			</table>
		</cfif>
	<CFELSEIF iGCOID IS 1000001>
	<!--- PH - BPI/MS --->
		<table class="clsFooterBottom" id="COFOOTER" align="center" border="0" cellpadding=0 cellspacing=0 style="width:100%">
			<tr><td style="font-size:85%" align="center">#Trim(vaADD1)#, <cfif Trim(vaADD2) IS NOT "">#Trim(vaADD2)#, </CFIF> <cfif #vaADD3# neq ""> #vaADD3#,</cfif></td></tr>
			<tr><td style="font-size:85%" align="center">City of Makati, NCR, Fourth District, Philippines 1209</td></tr>
			<tr><td style="font-size:85%" align="center">Tel. No. (632) 8840-9000 | www.bpims.com</td></tr>
		</table>
	<cfelseif igcoid is 1000615>
		<!--- MAA PH --->
		<table id=COFOOTER cellpadding=0 cellspacing=0 align="center" border=0 style="width:100%">
			<tr><td align=center valign=top><img SRC="#request.webroot#MSupport/logo/PH_MAA_footer.png" width="400" height="56"></td></tr>
		</table>
	<CFELSEIF iGCOID IS 1500001>
		</td></tr></table>
	<cfelseif iGCOID IS 7865>
		<table id=COHEADER align="center" border="0" width=100% cellpadding=3 cellspacing=0>
		<tr>
			<td align=left colspan=6><div style="font-size:100%;font-weight:normal;color:black"><cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" TARGET="TWOLINE" ADD1=#vaADD1# ADD2=#vaADD2# POSTCODE=#vaPOSTCODE# CITYID=#iCITYID#></div></td>
		</tr>
		<tr>
			<td nowrap><div style="font-size:70%;font-weight:normal;color:black">Insurance</div></td>
			<td nowrap><div style="font-size:70%;font-weight:normal;color:black">: 6 03 7784 7255</div></td>
			<td nowrap><div style="font-size:70%;font-weight:normal;color:black"><b>F</b>: 6 03 7781 7255</div></td>
			<td nowrap><div style="font-size:70%;font-weight:normal;color:black"><b>E</b>: adrian@jhj.com.my</div></td>
			<td nowrap rowspan=2 width=60%><div style="font-size:80%;font-weight:normal;color:black"><b>www.jhj.com.my</b></div></td>
			<td nowrap rowspan=2 align=right><div style="font-size:90%;font-weight:normal;color:black"><b>also at Kuala Lumpur & Kota Bharu</b></div></td>
		</tr>
		<tr>
			<td nowrap><div style="font-size:70%;font-weight:normal;color:black">Banking</div></td>
			<td nowrap><div style="font-size:70%;font-weight:normal;color:black">: 6 03 7784 2315</div></td>
			<td nowrap><div style="font-size:70%;font-weight:normal;color:black"><b>F</b>: 6 03 7784 8315</div></td>
			<td nowrap><div style="font-size:70%;font-weight:normal;color:black"><b>E</b>: sree@jhj.com.my</div></td>
		</tr>
		</table>
	<cfelseif iGCOID IS 8070>
		<table id=COFOOTER align="center" border="0" width="#Attributes.WIDTH#" cellpadding=3 cellspacing=0>
		<tr>
			<td align=left><span style="font-size:70%;font-weight:bold;color:gray">#HTMLEditFormat(vaCONAME)#</span><span style="font-size:60%;font-weight:normal;color:gray"> (#HTMLEditFormat(vaCOREGNO)#)</span></td>
		</tr>
		<tr>
			<td align=left><span style="font-size:70%;font-weight:normal;color:gray"><cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" TARGET="ONELINE" ADD1=#vaADD1# ADD2=#vaADD2# POSTCODE=#vaPOSTCODE# CITYID=#iCITYID#></span></td>
		</tr>
		<tr>
			<td align=left><span style="font-size:70%;font-weight:normal;color:gray"><b>Tel</b>&nbsp;#HTMLEditFormat(aTELNO)# &nbsp;&nbsp;<b>Fax</b>#HTMLEditFormat(aFAXNO)#&nbsp;&nbsp;www.hlmsigtakaful.com.my</span></td>
		</tr>
		</table>
	<CFELSEIF iGCOID IS 1100001>
		<!--- MSIG Thailand --->
		<!--- <table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:85%" align=center>
		<tr><td><b>#vaCONAME#</b></td></tr>
		<tr><td>#HTMLEditFormat(vaADD1)#<CFIF vaADD2 IS NOT "">, #HTMLEditFormat(vaADD2)#</CFIF>, #HTMLEditFormat(vaPOSTCODE)# #HTMLEditFormat(city)#, Thailand</td></tr>
		<tr><td>Tel: #aTELNO# &nbsp;&nbsp;Fax: #aFAXNO# &nbsp;&nbsp;Email: claimthailand@th.msig-asia.com &nbsp;&nbsp;Website: www.msig-thai.com</td></tr>
		</table> --->
		<!--- 44432 --->
		<CFIF ATTRIBUTES.LAYOUT EQ 1>
			<table id=COFOOTER border=0 cellPadding=0 cellSpacing=0 style="WIDTH:100%;font-size:85%" align=center>
				<tr>
	      			<td><img src="#request.webroot#MSupport/logo/TH-MSIG_Delivery_form_footer.png" width="100%;"></td>
				</tr>
			</table>
		</CFIF>
		<!--- 44432 --->
	<cfelseif iGCOID IS 700510 AND Attributes.LAYOUT IS 1>
	<!--- ID aswata --->
		<table id=COFOOTER align="center" border="0" width="#Attributes.WIDTH#" height="100%" cellpadding=3 cellspacing=0>
			<tr>
				<td align="left"><div><img src="#request.webroot#MSupport/logo/ID-aswata-lfooter.gif" height="20%" width="20%"></div></td>
				<td align="right"><div><img src="#request.webroot#MSupport/logo/ID-aswata-rfooter.gif" height="20%" width="20%"></div></td>
			</tr>
		</table>
	<cfelseif igcoid is 1510010> <!--- 19013/19486 UIC Vietnam --->
		<!---<cfif IsDefined("Attributes.FOOTERTYPE") and Attributes.FOOTERTYPE is 1>--->
			<table id=COFOOTER align="center" border="0" width="#Attributes.WIDTH#" style="border-top:1px solid black" cellpadding=0 cellspacing=0>
				<tr>
					<td width=45% style="font-size:7px">HEAD OFFICE<br>#vaADD1#,#vaADD2#,#vaADD3#<br>Tel: #aTELNO# &nbsp;&nbsp;&nbsp; Fax: #afaxNO# &nbsp;&nbsp;&nbsp; Email: #vaemail#</td>
					<td width=45% style="font-size:7px">BRANCH OFFICE<br>16th Floor, Vincom Center, 72 Le Thanh Ton St., Dist 1, Hochiminh City, Vietnam<br>Tel: (84-8) 38219036 &nbsp;&nbsp;&nbsp; Fax: (84-8) 38219248 &nbsp;&nbsp;&nbsp; Email: hcm@uicvn.com</td>
					<td width=10% style="font-size:7px" align=right>www.uicvn.com</td>
				</tr>
			</table>
	<cfelseif igcoid is 204324>
			<table id=COFOOTER align="center" border="0" width="#Attributes.WIDTH#" style="border-top:1px solid black" cellpadding=0 cellspacing=0>
				<tr>
					<td align="center" style="font-size:90%">Auto & General Insurance (Singapore) Pte. Limited (Co. Reg. No. 201626103G), trading as <b>Budget Direct Insurance</b><br/> 190 Clemenceau Avenue, ##03-01, Singapore Shopping Centre, Singapore 239924  Tel: 6221 2111  budgetdirect.com.sg</td>
				</tr>
			</table>
	<CFELSEIF iGCOID IS 700527>
		<div align=left><img src="#request.webroot#MSupport/logo/ptsompo_left_quarter_circle.png" height=100px width=95px></div>
		<div style="float:left;margin-left:20px;"><span style="font-size:15px">#HTMLEditFormat(vaCONAME)#</span><br><span style="font-size:10px;"><cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" TARGET="ONELINE" ADD1=#vaADD1# ADD2=#vaADD2# POSTCODE=#vaPOSTCODE# CITYID=#iCITYID#><br>T: (021) 572 5772 F: (021) 572 4007, (021) 572 4010(CLAIM) W: tokiomarine.com<br>Contact Center 24/7,14006</span></div>
		<div style="text-align:center;font-size:13px;float:right;border-top:1px solid black;padding:5px:">A Member of Tokio Marine Group</div>
		<div style="clear:both"></div>
			<!--- <table width=100%>
				<tr>
					<td valign=left><img src="#request.webroot#MSupport/logo/ptsompo2_left_quarter_circle.png"></td>
				</tr>
				<tr>
					<td></td>
				</tr>
			</table> --->
	<cfelseif igcoid is 1402014>
		<table id=COFOOTER align="center" border="0" cellpadding=0 cellspacing=0>
			<tr>
				<td align="center"><img src="#request.webroot#MSupport/logo/hkliberty-footer.png"></td>
			</tr>
		</table>
	<cfelseif igcoid is 1000830>
		<style>.ftr {
			display:block;
	        width:100%;        
	        position:absolute;
	        right:0px;
	        bottom:0px; 	      
		}
		</style>
		<table class=ftr id=COFOOTER border="0" cellPadding="1" cellSpacing="1" style="WIDTH: 90%" align="center"> 
			<tr><td align="center"><img src="#request.webroot#MSupport/logo/ph_paramount_footer.PNG" width="200px"></td></tr>
			<tr><td style="font-size:85%" align="center">14th & 15th Floor, Sage House110 V. A. Rufino Street, Legaspi Village, Makati City 1229, Philippines</td></tr>
			<tr><td style="font-size:85%" align="center"> &bull;Trunkline No(s). +632 7729200  &bull;Fax No(s). +632 7729290 / +632 7729291 / +632 7729293   &bull;www.paramount.com.ph</td></tr>
		</table>
	<cfelseif igcoid is 1000920>
		<table id=COFOOTER align="center" border="0" cellpadding=0 cellspacing=0>
			<tr>
				<cfif attributes.layout is 1>
					<td align="center"><img src="#request.webroot#MSupport/logo/ph_cgic_footer.jpg" width=100%></td>
				<cfelse>
					<td align="center"><img src="#request.webroot#MSupport/logo/ph_cgic_footer_1.png" width=100%></td>
				</cfif>
			</tr>
		</table>
	<CFELSEIF iGCOID IS 203273>
		<div class="clsFooter" style="text-align:center;width:100%;font-size:7pt;font-family:arial;line-height:12px;color:##A9A9A9">
		10 EUNOS ROAD 8 &num;09-04A SINGAPORE POST CENTRE SINGAPORE 408600   TEL: (65) 6337 4779  FAX: (65) 63386951 <br>
		COMPANY REGISTRATION NO: 198901301C WEBSITE: http://www.ecics.com.sg
		</div>
	<CFELSEIF iGCOID IS 325>
		<div align="center" style="width:100%">
			<table border="0" cellspacing="0" cellpadding="0" width="100%">
				<tr><td>Offices at: Alor Setar . Penang . Ipoh . Kuala Lumpur . Johor Bharu . Kota Bharu . Melaka . Kuching . Miri . Kota Kinabalu . Kuantan</td></tr>
			</table>
		</div>
	<CFELSEIF iGCOID IS 215>
		<p style="text-align: center;"><strong><span style="font-size: 10.0pt; font-family: 'Calibri',sans-serif;">Crawford &amp; Company Adjusters (Malaysia) Sdn Bhd</span></strong> <em><span style="font-size: 9.0pt; font-family: 'Calibri',sans-serif;">(9271-W)</span></em></p>
<p style="text-align: center;"><span style="font-size: 9.0pt; font-family: 'Calibri',sans-serif;">Level 6 Wisma Goldhill 67 Jalan Raja Chulan 50200 Kuala Lumpur</span></p>
<p style="text-align: center;"><span style="font-size: 8.0pt; font-family: 'Calibri',sans-serif; color: black;">Tel : (03) 2072 1055 &nbsp;&nbsp;&nbsp;&nbsp; Fax : (03) 2072 1731&nbsp;&nbsp;&nbsp;&nbsp; E-mail : admin@crawford.com.my&nbsp;&nbsp;&nbsp;&nbsp; Website : </span><span style="font-size: 8.0pt; font-family: 'Calibri',sans-serif; color: black;">www.crawfordandcompany.com</span></p>
<p style="text-align: center; line-height: 80%;"><span style="font-size: 8.0pt; line-height: 80%; font-family: Wingdings;">w</span><span style="font-size: 8.0pt; line-height: 80%; font-family: 'Calibri',sans-serif;"> &nbsp;Alor Setar &nbsp;</span><span style="font-size: 8.0pt; line-height: 80%; font-family: Wingdings;">w</span><span style="font-size: 8.0pt; line-height: 80%; font-family: 'Calibri',sans-serif;"> &nbsp;Penang &nbsp;</span><span style="font-size: 8.0pt; line-height: 80%; font-family: Wingdings;">w</span><span style="font-size: 8.0pt; line-height: 80%; font-family: 'Calibri',sans-serif;"> &nbsp;Ipoh &nbsp;</span><span style="font-size: 8.0pt; line-height: 80%; font-family: Wingdings;">w</span><span style="font-size: 8.0pt; line-height: 80%; font-family: 'Calibri',sans-serif;"> &nbsp;Kuantan &nbsp;</span><span style="font-size: 8.0pt; line-height: 80%; font-family: Wingdings;">w</span><span style="font-size: 8.0pt; line-height: 80%; font-family: 'Calibri',sans-serif;"> &nbsp;Kuala Lumpur &nbsp;</span><span style="font-size: 8.0pt; line-height: 80%; font-family: Wingdings;">w</span><span style="font-size: 8.0pt; line-height: 80%; font-family: 'Calibri',sans-serif;"> &nbsp;Sri Petaling &nbsp;</span><span style="font-size: 8.0pt; line-height: 80%; font-family: Wingdings;">w</span><span style="font-size: 8.0pt; line-height: 80%; font-family: 'Calibri',sans-serif;"> &nbsp;Melaka &nbsp;</span><span style="font-size: 8.0pt; line-height: 80%; font-family: Wingdings;">w</span><span style="font-size: 8.0pt; line-height: 80%; font-family: 'Calibri',sans-serif;"> &nbsp;Johor Bahru &nbsp;</span><span style="font-size: 8.0pt; line-height: 80%; font-family: Wingdings;">w</span><span style="font-size: 8.0pt; line-height: 80%; font-family: 'Calibri',sans-serif;"> &nbsp;Kuching &nbsp;</span><span style="font-size: 8.0pt; line-height: 80%; font-family: Wingdings;">w</span><span style="font-size: 8.0pt; line-height: 80%; font-family: 'Calibri',sans-serif;"> &nbsp;Kota Kinabalu</span></p>
	<CFELSEIF iGCOID IS 594>
			<table width="100%">
				<tr><td>
					<table width=100% cellpadding="0" cellspacing="0">
						<col width=40%><col><col width=40%>
						<tr><td ><table width=100%><tr><td style="border-bottom:2px solid;border-color: ##204879">&nbsp;</td></tr><tr><td>&nbsp;</td></tr></table></td><td >
						<strong><span style="font-size: 10.5pt; line-height: 107%; font-family: FrutigerBold; color: ##204879;">Century Independent Loss Adjusters Sdn. Bhd.</span></strong>
							<span style="font-size: 7.0pt; line-height: 107%; font-family: FrutigerRoman; color: ##204879;">(114182-W)</span></td>
							<td ><table width=100%><tr><td style="border-bottom:2px solid;border-color: ##204879">&nbsp;</td></tr><tr><td>&nbsp;</td></tr></table></td>
					</tr></table>
					</td></tr>
				<tr><td>
					<p style="margin-bottom: .0001pt; text-align: center; line-height: normal;">
						<span style="font-size: 7.0pt; font-family: FrutigerRoman; color: ##204879;" >No. 7, Jalan 2/66, Off Jalan Kent 3 Jalan Semarak, 54000 Kuala Lumpur</span></p>
					<p style="margin-bottom: .0001pt; text-align: center; line-height: normal;">
						<span style="font-size: 7.0pt; font-family: ZapfDingbats; color: ##204879;" >n</span>
						<span style="font-size: 7.0pt; font-family: FrutigerRoman; color: ##204879;"> Tel : 603 - 2692 8188 (24 hrs)&nbsp;&nbsp;&nbsp; &nbsp;</span>
						<span style="font-size: 7.0pt; font-family: ZapfDingbats; color: ##204879;">n</span>
						<span style="font-size: 7.0pt; font-family: FrutigerRoman; color: ##204879;"> Fax : 603 - 2698 1688</span></p>
					<p style="margin-bottom: .0001pt; text-align: center; line-height: normal;">
						<span style="font-size: 7.0pt; font-family: ZapfDingbats; color: ##204879;">n</span>
						<span style="font-size: 7.0pt; font-family: FrutigerRoman; color: ##204879;"> E-mail : admingen@centuryadjusters.com&nbsp;&nbsp;&nbsp; </span>
						<span style="font-size: 7.0pt; font-family: ZapfDingbats; color: ##204879;">n</span>
						<span style="font-size: 7.0pt; font-family: FrutigerRoman; color: ##204879;"> Website: www.centuryadjusters.com</span></p>
				</td></tr>
		</table>
	<CFELSEIF iGCOID IS 81>
		<ul style="list-style-type:none">
<li style="text-align: center;"><span style="font-size: 9.0pt; color: gray;">&##x25CF;</span><span style="font-size: 9.0pt; font-family: 'Cambria',serif; color: gray;"> Ipoh </span><span style="font-size: 9.0pt; color: gray;">&##x25CF;</span><span style="font-size: 9.0pt; font-family: 'Cambria',serif; color: gray;"> Johor Bharu </span><span style="font-size: 9.0pt; color: gray;">&##x25CF;</span><span style="font-size: 9.0pt; font-family: 'Cambria',serif; color: gray;">&nbsp; Kota Kinabalu </span><span style="font-size: 9.0pt; color: gray;">&##x25CF;</span><span style="font-size: 9.0pt; font-family: 'Cambria',serif; color: gray;">&nbsp; Kuantan </span><span style="font-size: 9.0pt; color: gray;">&##x25CF;</span><span style="font-size: 9.0pt; font-family: 'Cambria',serif; color: gray;">&nbsp; Melaka </span><span style="font-size: 9.0pt; color: gray;">&##x25CF;</span><span style="font-size: 9.0pt; font-family: 'Cambria',serif; color: gray;">&nbsp; Penang </span><span style="font-size: 9.0pt; color: gray;">&##x25CF;</span><span style="font-size: 9.0pt; font-family: 'Cambria',serif; color: gray;">&nbsp; Kuching </span><span style="font-size: 9.0pt; color: gray;">&##x25CF;</span></li>
<li style="text-align: center;"><span style="font-size: 9.0pt; color: gray;">&##x25CF;</span><span style="font-size: 9.0pt; font-family: 'Cambria',serif; color: gray;"> Kota Bharu </span><span style="font-size: 9.0pt; color: gray;">&##x25CF;</span><span style="font-size: 9.0pt; font-family: 'Cambria',serif; color: gray;"> Kuala Terengganu </span><span style="font-size: 9.0pt; color: gray;">&##x25CF;</span><span style="font-size: 9.0pt; font-family: 'Cambria',serif; color: gray;">&nbsp; Alor Setar </span><span style="font-size: 9.0pt; color: gray;">&##x25CF;</span><span style="font-size: 9.0pt; font-family: 'Cambria',serif; color: gray;">&nbsp; Miri </span><span style="font-size: 9.0pt; color: gray;">&##x25CF;</span></li>
</ul>
<CFELSEIF iGCOID IS 32 AND ListFind("DEV,UAT",Application.DB_MODE)>
	<CFIF Attributes.CUSTOM eq 1> 
		<!--- BEGIN Lim Soon Eng #44937 --->
		<!--- For Footer that support Puppeteer PDF --->
		<style>
			.BISfooter{
				position:fixed;
				bottom:0;
				left:0%; <!--- For PDF render alignment --->
				transform: translate(0%, 0%); <!--- For preview display alignment. --->
				width:100%;
			}
		</style>
		<div class="BISfooter" align='center' width="100%">
			<table class=clsfooter id=COFOOTER border=0 cellPadding=0 cellSpacing=0>
				<tr><td align='center' style="font-size:10px"><b>#vaCONAME#</b>&nbsp;<span style="valign:bottom">(#vaCOREGNO#)</span></td></tr>
				<tr><td align='center' style="font-size:12px"><b>Address:</b>&nbsp;<span style="valign:bottom"><cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" TARGET="ONELINE" ADD1=#vaADD1# ADD2=#vaADD2# POSTCODE=#vaPOSTCODE# CITYID=#iCITYID#></span></td></tr>
				<tr><td align='center' style="font-size:12px"><b>Toll Free:</b> <span style="valign:bottom">1-800-889-933</span> <b>Tel:</b> <span style="valign:bottom">#aTELNO#</span> <b>Fax:</b> <span style="valign:bottom">#aFAXNO#</span> <b>E-mail:</b> <span style="valign:bottom">info@bsompo.com.my</span> <b>Website:</b> <span style="valign:bottom">www.berjayasompo.com.my</span></td></tr>
			</table>
		</div>
		<!--- END Lim Soon Eng #44937 --->
	<CFELSE>
		<table border="0" cellspacing="0" cellpadding="0" width="90%" align="center" style="text-align:center;font-size:85%">
			<tr><td style="font-size:100%"><b>#vaCONAME#</b>&nbsp;<span style="valign:bottom">(#vaCOREGNO#)</span></td></tr>
			<tr><td><b>Address:</b>&nbsp;<span style="valign:bottom"><cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCaddr.cfm" TARGET="ONELINE" ADD1=#vaADD1# ADD2=#vaADD2# POSTCODE=#vaPOSTCODE# CITYID=#iCITYID#></span></td></tr>
			<tr><td><b>Toll Free:</b> <span style="valign:bottom">1-800-889-933</span> <b>Tel:</b> <span style="valign:bottom">#aTELNO#</span> <b>Fax:</b> <span style="valign:bottom">#aFAXNO#</span> <b>E-mail:</b> <span style="valign:bottom">info@bsompo.com.my</span> <b>Website:</b> <span style="valign:bottom">www.berjayasompo.com.my</span></td></tr>
		</table>
	</CFIF>
<CFELSEIF iGCOID IS 1101213 AND ListFind("DEV,UAT",Application.DB_MODE)><!--- #36806 --->
	<cfif Attributes.Layout EQ 'PAYDEL'>
		<table id="COFOOTER" border="0" cellPadding="0" cellSpacing="0" style="WIDTH: 90%; HEIGHT:10%; margin: 0 auto;">
			<tr><td valign=bottom><img width="100%" SRC="#request.webroot#MSupport/logo/TH_SITH_footer.png"></td></tr>
 		</table>
 	</cfif>
<cfelseif igcoid is 204147>
	<div class="clsFooterBottom">
		<!-- FOOTSTART -->
		<CFIF Attributes.Layout EQ 1>
			<table id="COFOOTER" align="center" border="0" cellpadding=0 cellspacing=0>
				<tr><td align="center" style="color:##ED7D31">#vaCONAME#</td></tr>
				<tr><td style="font-size:85%" align="center">#vaADD1#,<cfif #vaADD2# neq ""> #vaADD2#,</cfif> #request.ds.countries[request.ds.co[iGCOID].COUNTRYID].NAME# #vaPOSTCODE#</td></tr>
				<tr><td style="font-size:85%" align="center">I: #aTELNO# | Registration No.: #vaCOREGNO# | #vaEMAIL#</td></tr>
			</table>
		</CFIF>
		<!-- FOOTEND --> 
	</div>
<cfelseif igcoid is 48111>
	<div class="clsFooterBottom" style="height: 90px !important;">
		<table id="COFOOTER" align="center" border="0" cellpadding=0 cellspacing=0>
			<!--- <tr><td align="center" style="color:##ED7D31"><img src="#request.webroot#MSupport/logo/zahidah&partnes_Footer_V2.png" width=100% align="middle"> </td></tr> --->
			<br><br>
			<hr width=70% style="border: 1px solid;">
			<tr><td align="center">
					#vaADD1#,<cfif #vaADD2# neq ""> #vaADD2#,</cfif> #vaPOSTCODE# #CITY#
					<br>Tel/Fax: #aTELNO# <span style="height: 5px;width: 5px;background-color: black;border-radius: 50%;display: inline-block;vertical-align:middle;"></span> Email: #vaEMAIL#
					<br>Office Hours: Monday to Fridays: 9.00am to 6.00pm, Saturdays:By appointment only
				</td></tr>
		</table>
	</div>
<!--- Start #33414 kofam --->
<cfelseif Attributes.COID is 1000798>
	<CFIF Attributes.LAYOUT IS 0>
		<style type="text/css" media="print">
			@media print {
				body {
		            margin: 0;
		            padding: 0;
		            height: 20mm;
	        	}
	        	
		        .footer {
		            position: fixed;
		            right: 0;
					left: 0;
					bottom: 0;
		        }
	    }
		</style>
		
		<div class="footer">
			<table id="COFOOTER" align="center" border="0" cellpadding=0 cellspacing=0>
				<tr><td align="center" style="font-weight:bold;font-size:120%;">#vaCOBRNAME#</td></tr>
					<tr><td align="center">#vaADD1#,<cfif #vaADD2# neq ""> #vaADD2#,</cfif> #vaPOSTCODE# #CITY#</td></tr>
					<tr><td align="center"><img src="#request.webroot#MSupport/logo/phone.png" width=15px align="top"> #aTELNO# &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <img src="#request.webroot#MSupport/logo/web.png" width=15px align="top"> <b>www.malayan.com</b></td></tr>
			</table>
		</div>
	<CFELSEIF Attributes.LAYOUT IS 1>
		<style type="text/css" media="print">
			@media print {
				body {
		            margin: 0;
		            padding: 0;
		            height: 20mm;
	        	}

		        .footer {
		            position: absolute;
		            bottom: 0;
		            left: 0;
		            right: 0;
		        }
	    	}
		</style>

		<table class="footer" border="0" cellpadding=0 cellspacing=0>
			<tr><td width="50%">&nbsp;</td>
				<td width="50%">
					<table style="border: 1px solid" cellpadding=0 cellspacing=0>
						<tr><td align="center" style="font-weight:bold;font-size:120%;">NOTICE</td></tr>
						<tr><td>&nbsp;</td></tr>
						<tr><td>To expedite payment, please return attached documents - duly signed/accomplished with your service billing</td></tr>
						<tr><td>&nbsp;</td></tr>
						<tr><td>&##9711; Release of Claim and Subrogation Receipt</td></tr>
						<tr><td>&##9711; Affidavit of Desistance</td></tr>
						<tr><td>&##9711; Satisfaction of Repair</td></tr>
						<tr><td>&##9711; Claims Customer Satisfaction Survey</td></tr>
						<tr><td>&##9711; Valid ID of Signatory</td></tr>
						<tr><td>&##9711; Others     ___________________</td></tr>
						<tr><td>&nbsp;</td></tr>
					</table>
				</td>
			</tr>
			<tr><td colspan=2>DISCLAIMER: Malayan Insurance-Tokio Marine Division, shall not be liable to any party 60 days from the date indicated above, in the event that this LOA is not used to repair the Insured Vehicle within the said period.</td></tr>
			<tr><td colspan=2>&nbsp;</td></tr>
			<tr><td colspan=2>Note: Please surrender the replaced parts, if any, in exchange of our check payment.</td></tr>
		</table>
	</CFIF>
<!--- End #33414 kofam --->
<cfelseif igcoid is 56799>
	<div class="clsFooterBottom">
		<table id="COFOOTER" align="center" width="90%" style="border-top:1px solid black;font-family:Times New Roman" cellpadding=0 cellspacing=0>
			<tr><td colspan="5">&nbsp;</td></tr>
			<tr><td width=10%>&nbsp;</td><td width=30%>#vaADD1#</td><td width=10%>&nbsp;</td><td width=30%>Tel No.: #aTELNO#</td><td width=10%>&nbsp;</td></tr>
			<tr><td>&nbsp;</td><td>#vaADD2#</td><td>&nbsp;</td><td>Fax No.: #aFAXNO#</td><td>&nbsp;</td></tr>
			<tr><td>&nbsp;</td><td>#vaPOSTCODE# #CITY#, #STATE#</td><td>&nbsp;</td><td>Email : #vaEMAIL#</td><td>&nbsp;</td></tr>
		</table>
	</div>
<cfelseif igcoid is 700088>
	<!--- PT Allianz (indonesia) --->
	<cfif attributes.layout eq 1>
		<table id="COFOOTER" align="center" width="100%" cellpadding=0 cellspacing=0>
			<tr><td colspan="5">&nbsp;</td></tr>
			<tr><td align=left>#vaCONAME#</td></tr>
			<tr>
				<td align=left>#Trim(vaADD1)#</td><cfif Trim(aTELNO) IS NOT "">
				<td align=left>Call Centre: #Trim(aTELNO)#</td></CFIF>
			</tr>
			<cfif Trim(vaADD2) IS NOT "">
				<tr>
					<td align=left>#Trim(vaADD2)#</td>
					<cfif Trim(aFAXNO) IS NOT ""><td align=left>Fax: #Trim(aFAXNO)#</td></CFIF>
				</tr>
			</CFIF>
			<tr>
				<td align=left>#HTMLEditFormat(CITY)# #Trim(vaPOSTCODE)#, Indonesia</td>
				<cfif Trim(vaEMAIL) IS NOT ""><td align=left>#Trim(vaEMAIL)#</td></CFIF>
			</tr>
		</table>
	<cfelse>
		<table id="COFOOTER" align="center" width="90%" cellpadding=0 cellspacing=0>
			<tr><td colspan="5">&nbsp;</td></tr>
			<tr><td align=left>#vaCONAME#</td></tr>
			<tr>
				<td align=left>#Trim(vaADD1)#</td><cfif Trim(aTELNO) IS NOT "">
				<td align=left>Call Centre: #Trim(aTELNO)#</td></CFIF>
			</tr>
			<cfif Trim(vaADD2) IS NOT "">
				<tr>
					<td align=left>#Trim(vaADD2)#</td>
					<cfif Trim(aFAXNO) IS NOT ""><td align=left>Fax: #Trim(aFAXNO)#</td></CFIF>
				</tr>
			</CFIF>
			<tr>
				<td align=left>#HTMLEditFormat(CITY)# #Trim(vaPOSTCODE)#, Indonesia</td>
				<cfif Trim(vaEMAIL) IS NOT ""><td align=left>#Trim(vaEMAIL)#</td></CFIF>
			</tr>
		</table>
	</cfif>
<cfelseif igcoid is 203018>
	<CFIF Attributes.LAYOUT IS 0>
		<style type="text/css" media="print">
			@media print {
				body {
		            margin: 0;
		            padding: 0;
		            height: 20mm;
	        	}
	        	
		        .footer {
		            position: fixed;
		            right: 0;
					left: 0;
					bottom: 0;
		        }
	    }
		</style>
		
		<div class="footer">
			<table id="COFOOTER" align="center" border="0" cellpadding=0 cellspacing=0 width=100%>
				<tr><td align="left"><IMG SRC="#request.webroot#MSupport/logo/sg-hlas-footer.png" height=35px width=584px></td></tr>
			</table>
		</div>
	<CFELSEIF Attributes.LAYOUT IS 1>
		<style type="text/css" media="print">
			@media print {
				body {
		            margin: 0;
		            padding: 0;
		            height: 20mm;
	        	}

		        .footer {
		            position: absolute;
		            bottom: 0;
		            left: 0;
		            right: 0;
		        }
	    	}
		</style>

		<table class="footer" border="0" cellpadding=0 cellspacing=0 width=100%>
			<tr><td align="left"><IMG SRC="#request.webroot#MSupport/logo/sg-hlas-footer.png" height=35px width=584px></td></tr>
		</table>
	</CFIF>
</CFIF>
</CFOUTPUT>
