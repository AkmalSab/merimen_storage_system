<!---
	Gets the list of claimtypes available. Takes into
	consideration URL.CT for claimtype filtering.

	Attributes:
	ShowSelector: Shows CT selector if exist and not 0
	URL.CT: Bit pattern for claims:
		1 - OD
		2 - TP
		4 - WS
		8 - OD KFK
		16 - TF
		32 - OD TFR
	Return Values :
	Caller.Clmtypelist: List of all clmtypes applicable
--->
<cfparam NAME=Attributes.ShowSelector DEFAULT=0>
<cfparam NAME=Attributes.CLMTYPEMASK DEFAULT=#SESSION.VARS.CLMTYPEACCMASK#>
<cfparam NAME=Attributes.CLISTONLY DEFAULT=0>
<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCADDFILE.cfm" FNAME="SVCTAB">
<cfset CCAN=Attributes.CLMTYPEMASK>
<cfset CLO=Attributes.CLISTONLY>
<cfif SESSION.VARS.ORGTYPE IS "D"><cfset CCAN=-1></cfif>
<cfif IsDefined("URL.CT")><cfset CT=BitAnd(Val(CT),CCAN)><cfelse><cfset CT=CCAN></cfif>
<cfset Caller.CLMTYPEMASK=CT>
<cfset CLIST=""><cfset CURCLASS="">
<CFSET ITMS=Request.DS.CLMTYPELIST>
<!---cfset ITMS=ListSort(StructKeyList(Request.DS.CLMTYPENAMES),"numeric")--->
<cfloop LIST=#ITMS# INDEX=ITM>
	<cfif ITM LTE 4096 OR ITM IS 16384 OR ITM IS 65536 OR ITM IS 262144 OR ITM IS 536870912 OR ITM IS 1073741824>
		<cfset CLMCLASS=#Server.SVClang("Motor",8795)#>
	<cfelse>
		<cfset CLMCLASS=#Server.SVClang("NonMotor",25340)#>
	</cfif>
	<!---CFLOOP COLLECTION=#Request.DS.CLMTYPENAMES# ITEM=ITM--->
	<cfif BitAnd(ITM,CT) GT 0>
		<cfif CURCLASS IS NOT CLMCLASS>
			<cfset CURCLASS=CLMCLASS>
			<cfif CLIST IS NOT "">
				<cfset CLIST=CLIST & "<br>">
			</cfif>
			<CFIF CLO EQ 0>
					<cfset CLIST=CLIST & "<u>" & CURCLASS & "</u>: ">
			</CFIF>
		<cfelse>
			<cfset CLIST=CLIST & ",">
		</cfif>
		<cfset CLIST=CLIST & StructFind(Request.DS.CLMTYPENAMES,ITM)>
	</cfif>
</cfloop>
<cfset CURCLASS="">
<cfparam name="responsiveview" default="0">
<cfif isdefined("request.mobile") AND request.mobile is 2>
	<cfset responsiveview=1>
</cfif>
<cfif Attributes.SHOWSELECTOR GT 0>
	<cfoutput>
		<cfif responsiveview is 1>
			<cfset MTRCNT=0><cfset NMCNT=0>
			<cfset MTRLEFT=""><cfset MTRRIGHT="">
			<cfset NMLEFT=""><cfset NMRIGHT="">
			<cfloop LIST=#ITMS# INDEX=ITM>
				<cfif BitAnd(CCAN,ITM) GT 0>
					<cfif ITM LTE 4096 OR ITM IS 16384 OR ITM IS 65536 OR ITM IS 262144 OR ITM IS 536870912 OR ITM IS 1073741824>
						<cfset CURCLASS=#Server.SVClang("Motor",8795)#>
						<cfif MTRCNT IS 0>
							<cfset MTRLEFT = MTRLEFT & "<div class='row'><div class='col-xs-12'><u>#CURCLASS#</u></div></div>">
						<cfelseif MTRCNT is 1>
							<cfset MTRRIGHT = MTRRIGHT & "<div class='row'><div class='col-xs-12'><span style='font-size:80%;cursor:pointer;color:navy' onclick=MTRtoggleClmCls('#CURCLASS#')>... [#Server.SVClang('Select All',2523)#]</span><input type=hidden ID=MTRCTLTOGGLE#CURCLASS# value=0></div></div>">
						</cfif>
						<cfif MTRCNT MOD 2 IS 0>
							<cfset MTRLEFT = MTRLEFT & "<div class=row><div class=col-xs-12><input name=chkclmtype ID='MTRCTL' type=checkbox CLMCLS=#CURCLASS# VALUE=#ITM#">
							<CFIF BITAND(CT,ITM) GT 0><cfset MTRLEFT = MTRLEFT &" CHECKED"></CFIF>
							<cfset MTRLEFT = MTRLEFT &"><span class=label-checkbox>#StructFind(Request.DS.CLMTYPENAMES,ITM)#</span></div></div>">
						<cfelse>
							<cfset MTRRIGHT = MTRRIGHT & "<div class=row><div class=col-xs-12><input name=chkclmtype ID='MTRCTL' type=checkbox CLMCLS=#CURCLASS# VALUE=#ITM#">
							<CFIF BITAND(CT,ITM) GT 0><cfset MTRRIGHT = MTRRIGHT &" CHECKED"></CFIF>
							<cfset MTRRIGHT = MTRRIGHT &"><span class=label-checkbox>#StructFind(Request.DS.CLMTYPENAMES,ITM)#</span></div></div>">
						</cfif>
						<cfset MTRCNT=MTRCNT+1>
					<cfelse>
						<cfset CURCLASS=#Server.SVClang("NonMotor",25340)#>
						<cfif NMCNT IS 0>
							<cfset NMLEFT = NMLEFT & "<div class='row'><div class='col-xs-12'><u>#CURCLASS#</u></div></div>">
						<cfelseif NMCNT is 1>
							<cfset NMRIGHT = NMRIGHT & "<div class='row'><div class='col-xs-12'><span style='font-size:80%;cursor:pointer;color:navy' onclick=MTRtoggleClmCls('#CURCLASS#')>... [#Server.SVClang('Select All',2523)#]</span><input type=hidden ID=MTRCTLTOGGLE#CURCLASS# value=0></div></div>">
						</cfif>
						<cfif NMCNT MOD 2 IS 0>
							<cfset NMLEFT = NMLEFT & "<div class=row><div class=col-xs-12><input name=chkclmtype ID='MTRCTL' type=checkbox CLMCLS=#CURCLASS# VALUE=#ITM#">
							<CFIF BITAND(CT,ITM) GT 0><cfset NMLEFT = NMLEFT &" CHECKED"></CFIF>
							<cfset NMLEFT = NMLEFT &"><span class=label-checkbox>#StructFind(Request.DS.CLMTYPENAMES,ITM)#</span></div></div>">
						<cfelse>
							<cfset NMRIGHT = NMRIGHT & "<div class=row><div class=col-xs-12><input name=chkclmtype ID='MTRCTL' type=checkbox CLMCLS=#CURCLASS# VALUE=#ITM#">
							<CFIF BITAND(CT,ITM) GT 0><cfset NMRIGHT = NMRIGHT &" CHECKED"></CFIF>
							<cfset NMRIGHT = NMRIGHT &"><span class=label-checkbox>#StructFind(Request.DS.CLMTYPENAMES,ITM)#</span></div></div>">
						</cfif>
						<cfset NMCNT=NMCNT+1>
					</cfif>
				</cfif>
			</cfloop>
			
			<script>SkinBorderBegin(12)</script>
				<div class="btn-group">
					<input TYPE=button CLASS="clsButton btn btn-mrm btn-xs dropdown-toggle" VALUE=#Server.SVClang("ClmTypes",25341)# onclick="JSVCshowCtxMenuEv(event,'MTRCTContextMenu',1,111,1);">
					<ul class="ct-menu" ctxVal=0 id="MTRCTContextMenu" role="menu">
						<li>
							<div class="container">
								<div class="header">#Server.SVClang("Claim Types",3581)#</div>
								<cfif MTRCNT IS NOT 0>
									<div>
										<div class="col-xs-6">
											#MTRLEFT#
										</div>
										<div class="col-xs-6">
											#MTRRIGHT#
										</div>
									</div>
								</cfif>
								<cfif NMCNT IS NOT 0>
									<br clear="all">
									<div>
										<div class="col-xs-6">
											#NMLEFT#
										</div>
										<div class="col-xs-6">
											#NMRIGHT#
										</div>
									</div>
								</cfif>
								<div class="row">
									<div class="col-xs-12 ct-done">
										<input TYPE=button class="clsButton btn btn-mrm btn-xs" value="#Server.SVClang("Done",2316)#" onclick=MTRClmTypeSel(#CT#)>
									</div>
								</div>
							</div>
						</li>
					</ul>
				</div>
				<cfif CLIST IS "">#Server.SVClang("None",1760)#<cfelse>#Replace(CLIST,",",", ","ALL")#</cfif>
			<script>SkinBorderEnd(12)</script>
		<cfelse>
			<div class=clsSVCCtxMenuBox ctxVal=0 id=MTRCTContextMenu style="width:30ex;z-index:1;cursor:auto;">
				<div align=center style=background-color:maroon;color:white;font-weight:bold>#Server.SVClang("Claim Types",3581)#</div>
				<table width="100%">
					<cfset CNT=0>
					<cfloop LIST=#ITMS# INDEX=ITM>
						<cfif BitAnd(CCAN,ITM) GT 0>
							<cfif ITM LTE 4096 OR ITM IS 16384 OR ITM IS 65536 OR ITM IS 262144 OR ITM IS 536870912 OR ITM IS 1073741824>
								<cfset CLMCLASS=Server.SVClang("Motor",8795)>
							<cfelse>
								<cfset CLMCLASS=Server.SVClang("NonMotor",25340)>
							</cfif>
							<cfif CURCLASS IS NOT CLMCLASS>
								<cfset CURCLASS=CLMCLASS>
								<cfif CNT MOD 2 IS 1>
									<td></td></tr>
								</cfif>
								<tr>
									<td><u>#curclass#</u></td>
									<td valign=bottom align=right>... 
										<span style="font-size:80%;cursor:pointer;color:navy" onclick="MTRtoggleClmCls('#CURCLASS#')">
											[#Server.SVClang("Select All",2523)#]
										</span>
									</td>
									<input type=hidden ID=MTRCTLTOGGLE#CURCLASS# value=0>
								</tr>
								<cfset CNT=0>
							</cfif>
							<cfif CNT MOD 2 IS 0>
								<cfif CNT IS NOT 0>
									</TR>
								</cfif>
								<tr>
							</cfif>
							<cfset CNT=CNT+1>
							<td style=border:0px>
								<input TYPE=CHECKBOX<CFIF BitAnd(CCAN,ITM) IS 0> DISABLED<CFELSE> ID=MTRCTL CLMCLS="#CURCLASS#" VALUE=#ITM#<CFIF BITAND(CT,ITM) GT 0> CHECKED</CFIF></CFIF>> #StructFind(Request.DS.CLMTYPENAMES,ITM)#<br>
							</td>
						</cfif>
					</cfloop>
					<cfif CNT MOD 2 IS 0 AND CNT GT 0>
						</TR><tr><td></td>
					</cfif>
					<td><input TYPE=button class=clsButton value="#Server.SVClang("Done",2316)#" onclick=MTRClmTypeSel(#CT#)></td></TR>
				</table>
			</div>
			<!---div ID=ClmTypesBox class="clsSearchBox"><input TYPE=BUTTON CLASS=clsButton VALUE="ClmTypes" onclick="JSVCshowCtxMenu('MTRCTContextMenu',1,0,1);"> <cfif CLIST IS "">#Server.SVClang("None",1760)#<cfelse>#CLIST#</cfif></div--->
			<!--- MIKE:Skin 12 --->
			<script>SkinBorderBegin(12)</script>
				<div><input TYPE=button CLASS=clsButton VALUE=#Server.SVClang("ClmTypes",25341)# onclick="JSVCshowCtxMenuEv(event,'MTRCTContextMenu',1,0,1);">&nbsp;<cfif CLIST IS "">#Server.SVClang("None",1760)#<cfelse>#Replace(CLIST,",",", ","ALL")#</cfif></div>
			<script>SkinBorderEnd(12)</script>
		</cfif>
	</cfoutput><!---script>AddOnloadCode("if(ClmTypesBox.parentNode&&ClmTypesBox.parentNode.className!='clsSearchBox'){ClmTypesBox.className='clsSearchBox'};");</script--->
</cfif>
<cfset Caller.CLMTYPEMASK=CT>
<cfset Caller.CLMTYPELIST=CLIST>