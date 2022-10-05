<CFPARAM name="ATTRIBUTES.CLAIMTYPE" default="">
<CFPARAM name="ATTRIBUTES.CLMFLOW" default="">
<CFPARAM name="ATTRIBUTES.CLMTYPE_SEL_ALL" default="1">
<CFPARAM name="ATTRIBUTES.CLMTYPEALLOW" default="">
<CFPARAM name="ATTRIBUTES.CURGCOID" default="#SESSION.VARS.GCOID#">
<CFPARAM name="ATTRIBUTES.DISP" default="0">
<CFPARAM name="ATTRIBUTES.LINKCASEID" default="0">
<CFPARAM name="ATTRIBUTES.LOCID" default="#Application.APPLOCID#">
<CFPARAM name="ATTRIBUTES.q_claim" default="QueryNew(1)">
<!--- req --->
<cfparam NAME="ATTRIBUTES.COTYPE" default="I">
<cfparam NAME="ATTRIBUTES.CLMGROUP" default="MTR">
<cfparam NAME="ATTRIBUTES.CASEID" default="0">
<cfparam name="ATTRIBUTES.CLMTYPE" default="">
<CFPARAM NAME="Attributes.NOEMPTY" default=0>
<CFPARAM NAME="Attributes.HIDEESTINFO" default=0>

<CFPARAM name="CLMTYPE_SEL_ALL" default="#Attributes.CLMTYPE_SEL_ALL#"><!--- CLMTYPE_SEL_ALL:0, 1 --->
<CFPARAM name="CLMFLOW" default="#Attributes.CLMFLOW#"><!--- CLMFLOW:MTR,NM,SC --->
<CFPARAM name="DISP" default="#Attributes.DISP#"><!--- DISP:0,1 --->
<CFPARAM name="LOCID" default="#attributes.LOCID#">
<CFPARAM name="LINKCASEID" default="#Attributes.linkcaseid#">
<CFPARAM name="CURGCOID" default="#attributes.CURGCOID#">
<CFPARAM name="CLAIMTYPE" default="#Attributes.CLAIMTYPE#">
<CFPARAM name="q_claim" default="#Attributes.q_claim#">
<CFPARAM name="CLMTYPEALLOW" default="#attributes.CLMTYPEALLOW#">
<CFPARAM name="Attributes.ENQUIRY_CLAIMTYPE_TEXT" DEFAULT="0"><!--- to display particular claim type text by passing in DISP=1 and CLAIMTYPE --->

<cfif isdefined("q_claim") and isdefined("q_claim.dtAuth")>
	<cfset DTAUTH = q_claim.dtAuth>
<cfelse>
	<cfset DTAUTH = "">
</cfif>
<cfif isdefined("q_claim") and isdefined("q_claim.REPFRANCHISE")>
	<cfset REPFRANCHISE = q_claim.REPFRANCHISE>
<cfelse>
	<cfset REPFRANCHISE = "">
</cfif>

<CFSET TOSHOWLIST = "OD,OD KFK,OD TFR,OD TAC,OD WS,BI,OD MNT,OD GRG,WS,LU,TF,OD EXW,TP,TP UL,TP PD,TP BI,TP KFK,TP SB"><!--- 42729 ZIV --->

<!--- End of default vars --->
<cfoutput>

<CFIF Attributes.COTYPE IS "L">
	<CFSET Attributes.CLMTYPE="TP">
</CFIF>
<CFIF CLMFLOW IS "SC" AND Attributes.CONVERTCLAIM IS 1>
	<CFSET CLMTYPE_SEL_ALL=1>
</CFIF>
	<CFSET ClaimTypeList = {
		"OD": 		Server.SVClang("Own Damage (OD)",3460),
		"OD KFK": 	Server.SVClang("Own Damage KFK (OD KFK)",3461),
		"OD TFR":	Server.SVClang("Own Damage Theft Recovered (OD TFR)",3462),
		"OD TAC":	Server.SVClang("Own Damage Theft of Accessories",5944) & " (OD TAC)",
		"OD WS":	Server.SVClang("Own Damage Windscreen (OD WS)",6950),
		"OD MNT":	Server.SVClang("Marine Transit (MNT)",3463),
		"OD GRG":	Server.SVClang("Garage (GRG)",3464),
		"BI":		"Own Damage Bodily Injury (OD BI)",
		"WS":		Server.SVClang("Windscreen (WS)",3466),
		"LU":		Server.SVClang("Loss-of-Use/CART/Misc. (LU/MISC)",7154),
		"TF":		Server.SVClang("Theft (TF)",3465),
		"OD EXW":	Server.SVClang("Extended Warranty",5815) & " (EXW)",
		"TP":		Server.SVClang("Third Party Vehicle Damage (TP)",3467),
		"TP UL":	Server.SVClang("Third Party Uninsured Losses (TP UL)",5991),
		"TP PD":	Server.SVClang("Third Party Property Damage (TP PD)",5992),
		"TP BI":	Server.SVClang("Third Party Bodily Injury (TP BI)",5993),
		"TP KFK":	Server.SVClang("Third Party KFK (TP KFK)",7589),
		"TP SB":	Server.SVClang("Third Party Subrogation (TP SB)",7590),
		"NM":		Server.SVClang("General Non-Motor (NM)",6237),
		"NM ENG":	Server.SVClang("Engineering (NM ENG)",7423),
		"NM FR":	Server.SVClang("Fire (NM FR)",7088),
		"NM LB":	Server.SVClang("Liability (NM LB)",7424),
		"NM MC":	Server.SVClang("Marine Cargo (NM MC)",7476),
		"NM MH":	Server.SVClang("Marine Hull (NM MH)",7591),
		"NM HS":	Server.SVClang("Medical/H&S (NM HS)",7222),
		"NM MSC":	Server.SVClang("Miscellaneous (NM MSC)",7425),
		"NM EXW":	Server.SVClang("Non-Motor Extended Warranty (NM EXW)",7369),
		"NM PA":	Server.SVClang("Personal Accident (NM PA)",7046),
		"NM RP":	Server.SVClang("Retail/Purchase Protection (NM RP)",8818),
		"NM TR":	Server.SVClang("Travel (NM TR)",7592),
	    "NM WC":	Server.SVClang("Workman Compensation (NM WC)",7593),
	    "SC":		Server.SVClang("Standalone Case (SC)",52004)
	}>
<cfif LOCID IS 2><CFSET ClaimTypeList["NM FR"]="Fire/Home (NM FR)"></cfif>

<cfif DISP IS 1>
	<CFIF Attributes.ENQUIRY_CLAIMTYPE_TEXT EQ 1>
		#ClaimTypeList[CLAIMTYPE]#
	</CFIF>
<cfelseif Attributes.CLMGROUP IS "MTR">
	<!--- <cfparam name="CLMTYPELIST" default=""> --->
	<cfset CLMTYPEAVAIL="">
	<CFIF Attributes.CASEID IS 0 AND Attributes.CLMTYPE IS "TP">
		<CFIF (LOCID IS 1 OR LOCID IS 2 OR LOCID IS 5 OR LOCID IS 11) AND Attributes.COTYPE IS "I">
			<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"TP UL,TP SB")>
			<!---cfif LOCID IS 1 OR LOCID IS 5 OR LOCID IS 11>
				<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"TP KFK")>
			</cfif--->
		<cfelseif LOCID IS 1 AND attributes.COTYPE IS "L">
			<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"TP UL")>
		</CFIF>
		<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"TP PD,TP BI,TP")>
	<CFELSEIF Attributes.CASEID IS 0 AND Attributes.CLMTYPE IS "LU">
		<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"LU")>
	<CFELSEIF Attributes.CASEID GT 0 AND CLAIMTYPE IS "OD KFK" AND BitAnd(TPKFKSTAT,8192+16+32) IS 8192+16>
		<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"OD KFK")>
	<CFELSEIF LINKCASEID GT 0 AND CLAIMTYPE IS "TP UL"> <!---Attributes.SRCDOMAINID IS 1 AND Attributes.SRCTYPE IS "TPUL" AND CLAIMTYPE IS "TP UL"--->
		<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"TP UL")>
	<CFELSE>

		<cfif (((Attributes.COTYPE IS "I" AND CLMFLOW IS "TF" AND LOCID IS 11 AND dtAUTH IS "" AND Attributes.HIDEESTINFO IS 0) OR CLMFLOW IS "OD")
		AND CLAIMTYPE IS NOT "OD EXW")
		OR CLMTYPE_SEL_ALL IS 1
		OR (Attributes.SRCDOMAINID IS 1 AND Attributes.COTYPE IS "I")>
			<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"OD")>



			<cfif LOCID IS NOT 4 AND NOT(LOCID IS 6 OR LOCID IS 9)>
				<cfif LOCID IS 1 OR LOCID IS 11>
					<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"OD KFK")>
				</cfif>
				<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"OD TFR")>
				<!---<OPTION value="OD TFA"<CFIF CLAIMTYPE IS "OD TFA"> SELECTED</cfif>>Own Damage Theft on Accessories (OD TFA)--->
			</cfif>
			<cfif NOT(LOCID IS 2)>
				<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"OD TAC")>
			</CFIF>
			<CFIF LOCID IS 2 OR LOCID IS 10 or LOCID is 14>
				<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"OD WS")>
			</CFIF>
			<CFIF NOT(CURGCOID IS 993 OR CURGCOID IS 2304 OR CURGCOID IS 2305 OR LOCID IS 2 OR LOCID IS 10)>
				<cfif (NOT(Attributes.COTYPE IS "R" AND REPFRANCHISE IS 0) AND LOCID IS NOT 5) OR CLAIMTYPE IS "OD MNT" OR CURGCOID IS 1026 OR CURGCOID IS 9887>
					<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"OD MNT")>
				</cfif>
				<cfif (NOT(Attributes.COTYPE IS "R" AND REPFRANCHISE IS 0) AND LOCID IS NOT 5) OR CLAIMTYPE IS "OD GRG">
					<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"OD GRG")>
				</cfif>
			</CFIF>
			<cfif Attributes.COTYPE IS "I" AND LOCID IS 11 AND dtAUTH IS "" AND Attributes.HIDEESTINFO IS 0>
				<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"TF")>
			</cfif>
		</cfif>
		<!--- #23426 show BI claimtype --->
		<cfif Attributes.COTYPE is "I">
			<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"BI")>
		</cfif>
		<cfif Attributes.COTYPE IS NOT "A" AND (CLMTYPE_SEL_ALL IS 1 OR CLAIMTYPE IS "WS") AND LOCID IS NOT 5 AND LOCID IS NOT 7 AND LOCID IS NOT 2 AND LOCID IS NOT 11>
			<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"WS")>
		</cfif>
		<cfif Attributes.COTYPE IS "I" AND (CLMTYPE_SEL_ALL IS 1 OR CLAIMTYPE IS "LU") AND (LOCID IS 1 OR LOCID IS 5 OR LOCID IS 7 OR LOCID IS 10)> <!--- #21221 --->
			<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"LU")>
		</cfif>
		<cfif Attributes.COTYPE IS "I" AND (CLMTYPE_SEL_ALL IS 1 OR CLAIMTYPE IS "SC") AND CURGCOID IS 1512247> <!--- 42729 ZIV --->
			<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"SC")>
			<cfset TOSHOWLIST=LISTAPPEND(TOSHOWLIST,"SC")>
		</cfif>
		<CFIF NOT(CURGCOID IS 993 OR CURGCOID IS 2304 OR CURGCOID IS 2305)>
			<cfif LOCID IS NOT 11 AND (CLMTYPE_SEL_ALL IS 1 AND (Attributes.COTYPE IS NOT "R" OR (Attributes.COTYPE IS "R" AND (REPFINANCE IS NOT "" OR CURGCOID IS 650 OR LOCID IS 7)))) OR CLAIMTYPE IS "TF">
				<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"TF")>
			</cfif>
			<!--- MRC --->
			<CFIF LOCID IS 1 OR LOCID IS 2 OR LOCID IS 4 OR LOCID IS 9 OR LOCID IS 7 OR LOCID IS 10 OR LOCID IS 11 OR LOCID IS 15 OR LOCID IS 14>
				<CFIF LOCID IS 1 OR LOCID IS 4 OR LOCID IS 7>
					<cfif CLAIMTYPE IS "OD EXW" OR CLMTYPE_SEL_ALL IS 1 OR (Attributes.SRCDOMAINID IS 1 AND Attributes.COTYPE IS "I")>
						<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"OD EXW")>
					</CFIF>
				</CFIF>
				<!--- CST(650): Perodua allow TF creation even when not finance --->
				<CFIF NOT(Attributes.CLMTYPE IS "OD") OR (Attributes.CASEID EQ 0 AND (Attributes.CLMTYPE IS "OD" OR Attributes.CLMTYPE IS ""))>
					<cfif LOCID IS 1 OR LOCID IS 7 OR LOCID IS 2 OR LOCID IS 9 OR LOCID IS 10 OR LOCID IS 11 OR LOCID IS 15 OR LOCID IS 14>
						<cfif (CLMTYPE_SEL_ALL IS 1 OR CLAIMTYPE IS "TP")>
							<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"TP")>
							<cfif Attributes.COTYPE IS "I" AND LOCID IS 11 AND dtAUTH IS "">
								<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"TP PD,TP UL")>
							</cfif>
							<cfif Attributes.COTYPE IS "I" AND LOCID IS 15 AND dtAUTH IS ""><!---Enable TP BI, TP SB,TP PD for VN--->
								<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"TP BI,TP SB,TP PD")>
							</cfif>
						</cfif>
					</cfif>
					<cfif (LOCID IS 1 OR LOCID IS 2 OR LOCID IS 7 OR LOCID IS 11 OR LOCID IS 14) AND (Attributes.COTYPE IS "I" OR Attributes.COTYPE IS "A" OR Attributes.COTYPE IS "L" OR Attributes.COTYPE IS "G" OR Attributes.COTYPE IS "EA")><!--- AND NOT(CLMFLOW IS "SC" AND Attributes.CONVERTCLAIM IS 1)--->
						<cfif (CLMTYPE_SEL_ALL IS 1 OR CLAIMTYPE IS "TP UL") AND Attributes.COTYPE IS "I">
							<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"TP UL")>
							<cfif Attributes.COTYPE IS "I" AND LOCID IS 11 AND dtAUTH IS "">
								<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"TP")>
							</cfif>
						</CFIF>
						<cfif (CLMTYPE_SEL_ALL IS 1 OR CLAIMTYPE IS "TP PD")>
							<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"TP PD")>
							<cfif Attributes.COTYPE IS "I" AND LOCID IS 11 AND dtAUTH IS "">
								<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"TP")>
							</cfif>
						</CFIF>
						<cfif (CLMTYPE_SEL_ALL IS 1 OR CLAIMTYPE IS "TP BI")>
							<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"TP BI")>
						</CFIF>
						<!---CFIF (IsDefined("Application.APPDEVMODE") AND Application.APPDEVMODE IS 1) OR Attributes.CASEID GT 0--->
						<cfif (CLMTYPE_SEL_ALL IS 1 OR CLAIMTYPE IS "TP SB") AND Attributes.COTYPE IS "I">
							<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"TP SB")>
						</CFIF>
						<!---/CFIF--->
					<CFELSEIF (LOCID IS 10) AND (Attributes.COTYPE IS "I")><!--- 18956 --->
						<cfif (CLMTYPE_SEL_ALL IS 1 OR CLAIMTYPE IS "TP BI")>
							<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"TP BI")>
						</CFIF>
						<cfif (CLMTYPE_SEL_ALL IS 1 OR CLAIMTYPE IS "TP PD")>
							<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"TP PD")>
						</CFIF>
					</CFIF>
				</CFIF>
				<cfif (CLMTYPE_SEL_ALL IS 1 OR CLAIMTYPE IS "TP KFK") AND Attributes.COTYPE IS "I" AND (LOCID IS 1 OR LOCID IS 5 OR LOCID IS 11)>
					<cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,"TP KFK")>
				</CFIF>

			</CFIF><!--- LOCID = 1 --->
		</CFIF>
	</CFIF><!--- TPUL --->
	<!--- filter with "CLMTYPEALLOW" --->
	<cfif IsDefined("CLMTYPEALLOW") AND LISTLEN(CLMTYPEALLOW) GT 0>
		<cfset CLMTYPEAVAIL=listToArray(CLMTYPEAVAIL)>
		<cfset CLMTYPEAVAIL.retainAll(listToArray(CLMTYPEALLOW))>
		<cfset CLMTYPEAVAIL=arrayToList(CLMTYPEAVAIL)>
	</cfif>
	<cfif CLAIMTYPE NEQ ""><cfset CLMTYPEAVAIL=LISTAPPEND(CLMTYPEAVAIL,CLAIMTYPE)></cfif>
	<CFIF CURGCOID IS 61 AND Attributes.SRCDOMAINID IS 6><!--- Remove TP BI for Uni.Asia if create new tp bi link --->
		<cfset CLMTYPEAVAIL=ReReplace(CLMTYPEAVAIL,"TP BI","","ALL")>
	</CFIF>
	<!--- ******* --->
	<CFIF Attributes.NOEMPTY eq 0><OPTION value=""></option></CFIF>
	<CFLOOP LIST=#TOSHOWLIST# INDEX=CT>
		<cfif LISTFIND(CLMTYPEAVAIL,CT) GT 0>
			<option value="#CT#"<CFIF CLAIMTYPE IS CT> SELECTED</cfif>>#ClaimTypeList[CT]#
		</cfif>
	</CFLOOP>
	<!---
	<cfif LISTFIND(CLMTYPEAVAIL,"OD") GT 0>
	<option value="OD"<CFIF CLAIMTYPE IS "OD"> SELECTED</cfif>>#Server.SVClang("Own Damage (OD)",3460)#
	</cfif>
	<cfif LISTFIND(CLMTYPEAVAIL,"OD KFK") GT 0>
	<option value="OD KFK"<CFIF CLAIMTYPE IS "OD KFK"> SELECTED</cfif>>#Server.SVClang("Own Damage KFK (OD KFK)",3461)#
	</cfif>
	<cfif LISTFIND(CLMTYPEAVAIL,"OD TFR") GT 0>
	<option value="OD TFR"<CFIF CLAIMTYPE IS "OD TFR"> SELECTED</cfif>>#Server.SVClang("Own Damage Theft Recovered (OD TFR)",3462)#
	</cfif>
	<cfif LISTFIND(CLMTYPEAVAIL,"OD TAC") GT 0>
	<option value="OD TAC"<CFIF CLAIMTYPE IS "OD TAC"> SELECTED</cfif>>#Server.SVClang("Own Damage Theft of Accessories",5944)# (OD TAC)
	</cfif>
	<cfif LISTFIND(CLMTYPEAVAIL,"OD WS") GT 0>
	<option value="OD WS"<CFIF CLAIMTYPE IS "OD WS"> SELECTED</cfif>>#Server.SVClang("Own Damage Windscreen (OD WS)",6950)#
	</cfif>
	<cfif LISTFIND(CLMTYPEAVAIL,"OD MNT") GT 0>
	<option value="OD MNT"<CFIF CLAIMTYPE IS "OD MNT"> SELECTED</cfif>>#Server.SVClang("Marine Transit (MNT)",3463)#
	</cfif>
	<cfif LISTFIND(CLMTYPEAVAIL,"OD GRG") GT 0>
	<option value="OD GRG"<CFIF CLAIMTYPE IS "OD GRG"> SELECTED</cfif>>#Server.SVClang("Garage (GRG)",3464)#
	</cfif>
	<cfif LISTFIND(CLMTYPEAVAIL,"WS") GT 0>
	<option value="WS"<CFIF CLAIMTYPE IS "WS"> SELECTED</cfif>>#Server.SVClang("Windscreen (WS)",3466)#
	</cfif>
	<cfif LISTFIND(CLMTYPEAVAIL,"LU") GT 0>
	<option value="LU"<CFIF CLAIMTYPE IS "LU"> SELECTED</cfif>>#Server.SVClang("Loss-of-Use/CART/Misc. (LU/MISC)",7154)#
	</cfif>
	<cfif LISTFIND(CLMTYPEAVAIL,"TF") GT 0>
	<option value="TF"<CFIF CLAIMTYPE IS "TF"> SELECTED</cfif>>#Server.SVClang("Theft (TF)",3465)#
	</cfif>
	<cfif LISTFIND(CLMTYPEAVAIL,"OD EXW") GT 0>
	<option value="OD EXW"<CFIF CLAIMTYPE IS "OD EXW"> SELECTED</cfif>>#Server.SVClang("Extended Warranty",5815)# (EXW)
	</cfif>
	<cfif LISTFIND(CLMTYPEAVAIL,"TP") GT 0>
	<option value="TP"<CFIF CLAIMTYPE IS "TP"> SELECTED</cfif>>#Server.SVClang("Third Party Vehicle Damage (TP)",3467)#
	</cfif>
	<cfif LISTFIND(CLMTYPEAVAIL,"TP UL") GT 0>
	<option value="TP UL"<CFIF CLAIMTYPE IS "TP UL"> SELECTED</cfif>>#Server.SVClang("Third Party Uninsured Losses (TP UL)",5991)#
	</cfif>
	<cfif LISTFIND(CLMTYPEAVAIL,"TP PD") GT 0>
	<option value="TP PD"<CFIF CLAIMTYPE IS "TP PD"> SELECTED</cfif>>#Server.SVClang("Third Party Property Damage (TP PD)",5992)#
	</cfif>
	<cfif LISTFIND(CLMTYPEAVAIL,"TP BI") GT 0>
	<option value="TP BI"<CFIF CLAIMTYPE IS "TP BI"> SELECTED</cfif>>#Server.SVClang("Third Party Bodily Injury (TP BI)",5993)#
	</cfif>
	<cfif LISTFIND(CLMTYPEAVAIL,"TP KFK") GT 0>
	<option value="TP KFK"<CFIF CLAIMTYPE IS "TP KFK"> SELECTED</cfif>>#Server.SVClang("Third Party KFK (TP KFK)",7589)#
	</cfif>
	<cfif LISTFIND(CLMTYPEAVAIL,"TP SB") GT 0>
	<option value="TP SB"<CFIF CLAIMTYPE IS "TP SB"> SELECTED</cfif>>#Server.SVClang("Third Party Subrogation (TP SB)",7590)#
	</cfif> --->
	<!--- ******* --->
<cfelse>
	<CFIF CURGCOID IS 993 OR CURGCOID IS 2304 OR CURGCOID IS 2305>
		<!--- MRC --->
	<CFELSEIF LOCID IS 1 AND CURGCOID IS 8669><!--- EA: UMWT Toyota --->
		<cfset CLMTYPE_SEL_ALL=0><cfset q_claim.CLAIMTYPE="NM MC">
	</CFIF>
	<CFIF Attributes.COTYPE IS "P" AND Request.DS.CO[CURGCOID].SUBCOTYPE IS 8>
		<cfset CLMTYPE_SEL_ALL=0><cfset q_claim.CLAIMTYPE="NM EXW">
	</CFIF>
	<cfparam name="CLMTYPEALLOW" default="">
	<cfif CLMTYPEALLOW NEQ ""><cfset CLMTYPE_SEL_ALL=0></cfif>
	<cfif CLAIMTYPE NEQ ""><cfset CLMTYPEALLOW=LISTAPPEND(CLMTYPEALLOW,CLAIMTYPE)></cfif>
	<cfset CLMTYPEAVAIL=#CLMTYPEALLOW#>
	<!--- Non-motor --->
	<CFIF Attributes.NOEMPTY eq 0><OPTION value=""></option></CFIF>
	<CFLOOP LIST="NM,NM ENG,NM FR,NM LB,NM MC,NM MH,NM HS,NM MSC,NM EXW,NM PA,NM RP,NM TR,NM WC" INDEX=CT>
		<cfif CLMTYPE_SEL_ALL IS 1 OR LISTFIND(CLMTYPEAVAIL,CT) GT 0>
			<option value="#CT#"<CFIF CLAIMTYPE IS CT> SELECTED</cfif>>#ClaimTypeList[CT]#
		</cfif>
	</CFLOOP>
	/*
	<cfif (CLMTYPE_SEL_ALL IS 1 OR LISTFIND(CLMTYPEAVAIL,"NM"))>
		<option value="NM"<CFIF CLAIMTYPE IS "NM"> SELECTED</cfif>>#Server.SVClang("General Non-Motor (NM)",6237)#
	</cfif>
	<cfif (CLMTYPE_SEL_ALL IS 1 OR LISTFIND(CLMTYPEAVAIL,"NM ENG"))>
		<option value="NM ENG"<CFIF CLAIMTYPE IS "NM ENG"> SELECTED</cfif>>#Server.SVClang("Engineering (NM ENG)",7423)#
	</cfif>
	<cfif (CLMTYPE_SEL_ALL IS 1 OR LISTFIND(CLMTYPEAVAIL,"NM FR"))>
		<option value="NM FR"<CFIF CLAIMTYPE IS "NM FR"> SELECTED</cfif>><cfif LOCID IS 2>Fire/Home (NM FR)<cfelse>#Server.SVClang("Fire (NM FR)",7088)#</cfif>
	</cfif>
	<cfif (CLMTYPE_SEL_ALL IS 1 OR LISTFIND(CLMTYPEAVAIL,"NM LB"))>
		<option value="NM LB"<CFIF CLAIMTYPE IS "NM LB"> SELECTED</cfif>>#Server.SVClang("Liability (NM LB)",7424)#
	</cfif>
	<cfif (CLMTYPE_SEL_ALL IS 1 OR LISTFIND(CLMTYPEAVAIL,"NM MC"))>
		<option value="NM MC"<CFIF CLAIMTYPE IS "NM MC"> SELECTED</cfif>>#Server.SVClang("Marine Cargo (NM MC)",7476)#
	</cfif>
	<cfif (CLMTYPE_SEL_ALL IS 1 OR LISTFIND(CLMTYPEAVAIL,"NM MH"))>
		<option value="NM MH"<CFIF CLAIMTYPE IS "NM MH"> SELECTED</cfif>>#Server.SVClang("Marine Hull (NM MH)",7591)#
	</cfif>
	<cfif (CLMTYPE_SEL_ALL IS 1 OR LISTFIND(CLMTYPEAVAIL,"NM HS"))>
		<option value="NM HS"<CFIF CLAIMTYPE IS "NM HS"> SELECTED</cfif>>#Server.SVClang("Medical/H&S (NM HS)",7222)#
	</cfif>
	<cfif (CLMTYPE_SEL_ALL IS 1 OR LISTFIND(CLMTYPEAVAIL,"NM MSC"))>
		<option value="NM MSC"<CFIF CLAIMTYPE IS "NM MSC"> SELECTED</cfif>>#Server.SVClang("Miscellaneous (NM MSC)",7425)#
	</cfif>
	<cfif (CLMTYPE_SEL_ALL IS 1 OR LISTFIND(CLMTYPEAVAIL,"NM EXW"))>
		<option value="NM EXW"<CFIF CLAIMTYPE IS "NM EXW"> SELECTED</cfif>>#Server.SVClang("Non-Motor Extended Warranty (NM EXW)",7369)#
	</cfif>
	<cfif (CLMTYPE_SEL_ALL IS 1 OR LISTFIND(CLMTYPEAVAIL,"NM PA"))>
		<option value="NM PA"<CFIF CLAIMTYPE IS "NM PA"> SELECTED</cfif>>#Server.SVClang("Personal Accident (NM PA)",7046)#
	</cfif>
	<cfif (CLMTYPE_SEL_ALL IS 1 OR LISTFIND(CLMTYPEAVAIL,"NM RP"))>
<!--- 		<option value="NM RP"<CFIF CLAIMTYPE IS "NM RP"> SELECTED</cfif>>#Server.SVClang("Retail Protection (NM RP)",7426)# --->
		<option value="NM RP"<CFIF CLAIMTYPE IS "NM RP"> SELECTED</cfif>>#Server.SVClang("Retail/Purchase Protection (NM RP)",8818)#
	</cfif>
    <cfif (CLMTYPE_SEL_ALL IS 1 OR LISTFIND(CLMTYPEAVAIL,"NM TR"))>
        <option value="NM TR"<CFIF CLAIMTYPE IS "NM TR"> SELECTED</cfif>>#Server.SVClang("Travel (NM TR)",7592)#
    </cfif>
	<cfif (CLMTYPE_SEL_ALL IS 1 OR LISTFIND(CLMTYPEAVAIL,"NM WC"))>
		<option value="NM WC"<CFIF CLAIMTYPE IS "NM WC"> SELECTED</cfif>>#Server.SVClang("Workman Compensation (NM WC)",7593)#
	</cfif>*/
</cfif>
</cfoutput>