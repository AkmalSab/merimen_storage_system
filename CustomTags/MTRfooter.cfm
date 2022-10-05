<cfif structKeyExists(Application, "APPLOCID")>
	<cfparam name=APPLOCID default=#Application.APPLOCID#>
<CFELSE>
	<cfset APPLOCID = 1>
</CFIF>
<cfif Not StructKeyExists(Caller,"RSVShowFooter") OR Caller.RSVShowFooter IS NOT 1><CFEXIT METHOD=EXITTEMPLATE></CFIF>
<cfif APPLOCID IS 5>
	<script>
	MTOOLCompleteMenubar();
	<cfif NOT StructKeyExists(Request,"nolayout")>MTOOLFooter();</cfif>
	</script>
	</div></body></html><CFSET Caller.RSVShowFooter=0>
<cfelse>

	<cfif structKeyExists(request,"mobile")>

		<CFIF NOT StructKeyExists(Request,"nolayout")>
			</div><!--- end of clsDocBody --->
			<!--- <script>MTOOLFooterNew();</script> --->
			<div class=footerpush></div>
		</div><!--- end of MRMmaintable --->
		<script>MTOOLFooterNew();</script>
		<CFELSE>
		</div><div class=footerpush></div></div>
		</CFIF>



	<cfelse>
		</div></td>
	</tr>
	<cfif NOT StructKeyExists(Request,"nolayout")>
	<tr>
	  <td><!---div class=clsDocBody--->
			<script>MTOOLFooter();</script>
	  <!---/div---></td>
	</tr>
	</cfif>
	</table>
	</cfif>
	<script>
	if(MTOOLCompleteMenubar)MTOOLCompleteMenubar();
	</script>
	<cfif Application.DB_MODE NEQ "PROD">
		<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVClivechatComm.cfm">
	</cfif>
	</body></html><CFSET Caller.RSVShowFooter=0>
</cfif>