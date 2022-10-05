<CFSET bankname = "Affin Bank , Alliance Bank, Ambank, AmFinance, Bank Simpanan Nasional, Bumiputra-Commerce Bank, Citibank, Hong Leong Bank, Hong Leong Finance, HSBC Bank, Maybank, Maybank Finace, Public Bank, Public Finance, RHB Bank, Southern Bank, Standard Charted Bank, United Overseas Bank (UOB)">
<CFOUTPUT>
 	<CFLOOP from=1 to=#ListLen(bankname)# index="counter"> 	
		<OPTION value="#counter#">#ListGetAt(bankname,counter)#</OPTION><BR>	 
	</CFLOOP> 
</CFOUTPUT>

