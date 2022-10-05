<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCDISABLEDIRECT.cfm" Path="#GetCurrentTemplatePath()#">
<!--- attributes: TENDERID, MODRESULT, RETURNINCALLER (default=0 (not to return); 1: to return all query's keys into caller) --->

<cfparam name="attributes.MODRESULT" default="MODRESULT">
<cfparam name="attributes.RETURNINCALLER" default=1>
<cfquery datasource=#Request.MTRDSN# name="q_getawardco">
    select iinscoid=a.icoid, a.iawardcoid, a.varegno,
        a.iorigcoid, a.vaorigconame, a.vaorigcobrname, a.vaorigadd1, a.vaorigadd2,
        a.vaorigpostcode, a.vaorigcity, a.vaorigstate, a.VAORIGCOUNTRY, a.aorigtelno, a.aorigfaxno,
        a.vaCLMNO, a.SIVHMANYEAR, a.sitendertype, a.dtANNOUNCEAWARD,
        a.dtACCDATE, b.sibiddertype, a.ICLAIMSCOID,a.vainitby,
        origconname1=a.VAORIGCONNAME1,origconname2=a.VAORIGCONNAME2,
        awardedco=b.icoid, b.vaconame, b.vacobrname, b.vaadd1, b.vaadd2, b.vapostcode, b.icityid, awardedcoconname=b.vaCONNAME1,
        city=c.vadesc, state=d.vadesc, b.vatelno, b.vaconname1,awardedcofaxno=b.vafaxno,
        a.vavar, a.vaman, a.vamodel, a.vapolno, a.vaCHANO, a.vaENGNO, MNTOW=isnull(a.MNTOW,0), MNSTORAGE=isnull(a.MNSTORAGE,0),
        a.mnaward, b.mnbid, insconame=f.vaconame, b.vafaxno,a.VAREFNO, siissuetowauth=ISNULL(a.siissuetowauth,0), TENDERCASEID=a.icaseid,a.vacolor,
        insuredName = isnull(a.vaINSUREDNAME,''), insgcoid=f.igcoid
        ,closedate=a.dtclose
        ,oricntc1=oriws.VACONNAME1
        ,oritelno=oriws.aTELNO
        ,awrdusnm=busr.vausname,awrdustelno=busr.aTELNO
        ,a.vaNOSRTPENARIKAN
        ,a.vaNOSRTJUALBELI
    from trx0070 a WITH (NOLOCK)
        JOIN SEC0005 f WITH (NOLOCK) ON a.icoid = f.icoid
        LEFT JOIN trx0071 b WITH (NOLOCK) ON a.itender=b.itender and a.iawardcoid=b.ibidid
        LEFT JOIN sys0003 c WITH (NOLOCK) ON b.icityid=c.icityid
        LEFT JOIN sys0002 d with (nolock) ON c.istateid=d.istateid
        LEFT JOIN sec0005 oriws WITH(NOLOCK) ON oriws.icoid=a.iorigcoid
        LEFT JOIN SEC0001 busr WITH(NOLOCK) ON b.vabidby=busr.vausid
    where a.itender=<cfqueryparam cfsqltype="cf_sql_integer" value="#Attributes.TENDERID#">
</cfquery>
<!--- cfif NOT(q_getawardco.recordcount IS 1)>
    <CFTHROW TYPE="EX_SECFAILED" ErrorCode="BADCASE" ExtendedInfo="Invalid case or winner for specified case.">
</cfif --->
<CFIF NOT StructKeyExists(Caller,Attributes.MODRESULT) OR NOT IsStruct(StructFind(Caller,Attributes.MODRESULT))>
    <CFSET "Caller.#Attributes.MODRESULT#"=StructNew()>
</CFIF>
<CFSET "Caller.#Attributes.MODRESULT#"=#GetQueryRow(q_getawardco,1)#>
<!--- <cfdump var=#structfind(Caller,Attributes.MODRESULT)#>
<cfabort> --->
<cfif attributes.RETURNINCALLER IS 1>
    <CFSET StructAppend(Caller,structfind(Caller,Attributes.MODRESULT),false)><!--- shouldn't overwrite existing caller vars --->
</cfif>
<!--- tried using QueryGetRow but returning undefined value instead of NULL, instead build own script --->
<cfscript>
    function GetQueryRow(query, rowNumber) {
        var i = 0;
        var rowData = StructNew();
        var cols    = ListToArray(query.columnList);
        for (i = 1; i lte ArrayLen(cols); i = i + 1) {
            rowData[cols[i]] = query[cols[i]][rowNumber];
        }
        return rowData;
    }
</cfscript>