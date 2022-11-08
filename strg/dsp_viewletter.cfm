<!--- If the user is viewing current item --->
	<cfif isDefined('URL.Id')>
		<!--- Query to fetch specific item --->
		<cfquery name="q_main_storage_select_specific" datasource="#Request.MTRDSN#">
			SELECT *
			FROM STRG_DATA WITH (NOLOCK)
			WHERE iSTRGID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.id#">
		</cfquery>
<!--- <cfdump  var="#q_main_storage_select_specific#"> --->
	</cfif>
<cfdocument format="pdf">
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Document</title>
    </head>
    <body>
        <cfoutput>#q_main_storage_select_specific.vaTEXTFIELD#</cfoutput>
    </body>
    </html>    
</cfdocument>