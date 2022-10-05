<CFSET Caller.ACSV=ArrayNew(1)>
<CFSET idx=Attributes.LINE>
<CFIF idx IS NOT "">
<CFSET idx=idx&",@@END@@">
<CFLOOP CONDITION="idx IS NOT ""@@END@@""">
	<CFSET pos=FindOneOf(",",idx)>
	<CFIF pos GT 1>
		<CFSET ele=LTrim(Left(idx,pos-1))>
	<CFELSE>
		<CFSET ele="">
	</CFIF>
	<CFSET idx=Right(idx,Len(idx)-pos)>
	<CFIF Left(ele,1) IS """">
		<!--- delim started --->
		<CFIF Len(ele) GT 1>
			<CFSET ele2=Right(ele,Len(ele)-1)>
		<CFELSE>
			<CFSET ele2="">
		</CFIF>
		<CFSET ele="">
		<CFLOOP CONDITION="Right(RTrim(ELE2),1) IS NOT CHR(34)">
			<CFIF idx IS "">
				<!--- No More? --->
				<CFTHROW TYPE="DATA" ErrorCode="BADDATA" EXTENDEDINFO="(Unterminated Quote)">
			</CFIF>
			<CFIF ele IS "">
				<CFSET ele=ele2>
			<CFELSE>
				<CFSET ele=ele&","&ele2>
			</CFIF>
			<CFSET pos=FindOneOf(",",idx)>
			<CFIF pos GT 1>
				<CFSET ele2=Left(idx,pos-1)>
			<CFELSE>
				<CFSET ele2=idx>
			</CFIF>
			<CFSET idx=Right(idx,Len(idx)-pos)>
		</CFLOOP>
		<!--- delim ended --->
		<CFSET ele2=RTrim(ELE2)>
		<CFIF ele2 IS NOT """">
			<CFIF ele IS "">
				<CFSET ele=Left(ele2,Len(ele2)-1)>
			<CFELSE>
				<CFSET ele=ele&","&Left(ele2,Len(ele2)-1)>
			</CFIF>
		</CFIF>
	</CFIF>
	<CFSET ArrayAppend(Caller.ACSV,Replace(ele,"""""","""","ALL"))>
</CFLOOP>
</CFIF>