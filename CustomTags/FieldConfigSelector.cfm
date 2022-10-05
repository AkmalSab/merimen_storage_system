<!---
FieldConfigSelector.cfm

Used to display the Role / Screen / Claim Type selector.
--->
<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCADDFILE.cfm" FNAME="JQuery_Select2_v4">
<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCADDFILE.cfm" FNAME="JQuery_Select2_CSS_Simple_v4">
<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCADDFILE.cfm" FNAME="SARISSA">

<CFPARAM NAME="FORM.selROLE" DEFAULT="">
<CFPARAM NAME="FORM.selSCREEN" DEFAULT="">
<CFPARAM NAME="FORM.selCLAIMTYPE" DEFAULT="">
<CFPARAM NAME="FORM.selUSERID" DEFAULT="">
<CFPARAM NAME="FORM.CASEID" DEFAULT="">

<CFPARAM NAME="Attributes.selROLE" DEFAULT="#FORM.selRole#">
<CFPARAM NAME="Attributes.selSCREEN" DEFAULT="#FORM.selScreen#">
<CFPARAM NAME="Attributes.selCLAIMTYPE" DEFAULT="#FORM.selCLAIMTYPE#">
<CFPARAM NAME="Attributes.selUSERID" DEFAULT="#FORM.selUSERID#">
<CFPARAM NAME="Attributes.caseid" DEFAULT="#FORM.caseid#">

<cfparam name="attributes.defcaseid" default="">
<cfparam name="attributes.defseluserid" default="">
<cfparam name="attributes.defscreen" default="">
<cfparam name="attributes.defrole" default="">


<CFPARAM NAME="Attributes.COID" DEFAULT="0">
<CFPARAM NAME="Attributes.STANDALONE" DEFAULT="0">
<CFPARAM NAME="Attributes.READONLY" DEFAULT="0">
<CFPARAM NAME="Attributes.register" DEFAULT="0">

<cfset disabled_str = "">
<CFIF Attributes.READONLY>
    <cfset disabled_str = " disabled">
</CFIF>

<!--- Get users that we can use for the screen field scraping --->
<cfquery name="q_getusers" datasource="#request.MTRDSN#">
select iusid,vausid,vausname,fulldisp=vausid + ' (' + vausname +')',corole='I',ICLMTYPEACCMASK,c.ilocid from sec0001 a with (nolock) inner join sec0005 c with (nolock) on a.icoid = c.icoid
where a.icoid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.coid#"> and ICLMTYPEACCMASK>0
and a.sistatus=0
and a.iCLMTYPEACCMASK&(select sum(iCLMTYPEMASK) from clmd0010 /* where vaSUPERCLS='MTR' */)>0
order by a.vausid asc
</cfquery>

<cfif q_getusers.RecordCount IS 0>
    <CFTHROW TYPE="EX_SECFAILED" ErrorCode="NOSETUP" ExtendedInfo="No user found.">
</cfif>

<cfquery name="q_rep" datasource="#request.MTRDSN#">
    select top 1 iusid,vausid,vausname,corole='R',ICLMTYPEACCMASK from sec0001 a with (nolock)
        INNER JOIN sec0005 c with (nolock) on a.icoid = c.icoid
    where a.ICLMTYPEACCMASK>0
    and a.sistatus=0 and a.sisuspended=0 and a.silocked=0 and a.sichgpwd=0
    and a.iCLMTYPEACCMASK&(select sum(iCLMTYPEMASK) from clmd0010 /* where vaSUPERCLS='MTR' */)>0
    and c.sicotypeid=1
    and c.ilocid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#q_getusers.ilocid#">
</cfquery>
<cfquery name="q_adj" datasource="#request.MTRDSN#">
    select top 1 iusid,vausid,vausname,corole='A',ICLMTYPEACCMASK from sec0001 a with (nolock)
        INNER JOIN sec0005 c with (nolock) on a.icoid = c.icoid
    where a.ICLMTYPEACCMASK>0
    and a.sistatus=0 and a.sisuspended=0 and a.silocked=0 and a.sichgpwd=0
    and a.iCLMTYPEACCMASK&(select sum(iCLMTYPEMASK) from clmd0010 /* where vaSUPERCLS='MTR' */)>0
    and c.sicotypeid=3
    and c.ilocid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#q_getusers.ilocid#">
</cfquery>


<!--- Claim Types will follow insurer's claim type --->
<cfquery name="q_getclaimtype" datasource="#request.MTRDSN#">
select a.vaSUPERCLS, a.iCLMTYPEMASK, a.vaCLMTYPE from (
	select distinct b.vasupercls,b.iclmtypemask,b.vaclmtype
		from sec0001 a with (nolock) inner join clmd0010 b with (nolock) on a.ICLMTYPEACCMASK&b.iclmtypemask>0

	where a.icoid=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#attributes.coid#">
	and a.sistatus=0 --and b.vasupercls = 'MTR'
) a
order by a.vasupercls, iclmtypemask
</cfquery>

<!--- Fetch screen config --->
<cfquery name="q_screenreg" datasource="#REQUEST.MTRDSN#">
select SCREENCODE=a.vaSCREENCODE, SCREENDESC=a.vaSCREENDESC,ROLE=b.vaCOROLE, b.vaSTATLIST
from SCREEN_REGISTRY a WITH (NOLOCK) inner join SCREEN_REGISTRY_ROLE b with (nolock)
on a.vaSCREENCODE=b.vaSCREENCODE
order by (case when b.vaCOROLE = 'I' then 1 when b.vaCOROLE = 'R' then 2 when b.vaCOROLE = 'A' then 3 end) , a.iorder
</cfquery>
<cfset screenStruct = structNew()>
<cfoutput query="q_screenreg">
    <cfif not structKeyExists(screenStruct, ROLE)>
        <cfset screenStruct[ROLE] = arrayNew(1)>
    </cfif>
    <cfset arrayAppend(screenStruct[ROLE], {"screencode"=screencode,"screendesc"=screendesc,"statlist"=vastatlist})>
</cfoutput>

<cfoutput>
<script>
var _jsonscreen = #Request.DS.FN.SVCSerializeJSON(q_screenreg,"query","upper",false,false,"native")#;
var _jsoniuser = #Request.DS.FN.SVCSerializeJSON(q_getusers,"query","upper",false,false,"native")#;
var _jsonauser, _jsonruser;
_jsonauser= { "COLUMNS" : ["FULLDISP","VAUSID"], "DATA" : [] };
_jsonruser= { "COLUMNS" : ["FULLDISP","VAUSID"], "DATA" : [] };

function initCodeSearch()
{
    if($('##selUserid').length > 0)
      $('##selUserid').select2({ placeholder: 'Select a User ID', width:'50%',allowClear: true });
}
AddOnloadCode("initCodeSearch()");

function checkCaseID() {
    var caseid = $('##caseid').val();
    if(caseid!="" && caseid>0)
    {
        var url = request.webroot + "index.cfm?fusebox=MTRAdmin&fuseaction=json_getcaseuserid&caseid="+caseid+"&insgcoid=#attributes.coid#&"+request.mtoken;
        var oxmlhttp=MRMHTTPRequest("GET",url,null,popuserjson,null,null,null,null);
    }
    else
    {
        screenDisableAll();
    }
}
function popuserjson(resp)
{
    var caseid = $('##caseid').val();
    var jsonresp = JSON.parse(resp.responseText);
    var chk = JSVCqueryGetColNo(jsonresp,'VAUSID');
    if(jsonresp.DATA.length > 0 && jsonresp.DATA[chk] == "" )
    {
        alert("(CaseID = " + caseid + ") " + jsonresp.DATA[JSVCqueryGetColNo(jsonresp,'ERROR')]);
        $('##caseid').val("").trigger("blur");
        return;
    }
    /* else if ( jsonresp.DATA.length == 0 )
    {
        // only accessible by insurer.
        screenDisableRole('R');
        screenDisableRole('A');
        screenDisableRole('I',false);
        popuser('I');
    } */
    else
    {
        var hasR=false, hasA=false; //, _jsonruser.DATA.length = 0, _jsonauser.DATA.length = 0;
        if(_jsonruser.DATA.length>0)
            _jsonruser.DATA.length = 0
        if(_jsonauser.DATA.length>0)
            _jsonauser.DATA.length = 0
        for(var i = 0; i < jsonresp.DATA.length; i ++ )
        {
            if(i==0)
                $('##selClaimType').val( jsonresp.DATA[0][JSVCqueryGetColNo(jsonresp,'CLAIMTYPE')] );

            var jsonrole = jsonresp.DATA[i][JSVCqueryGetColNo(jsonresp,'ROLE')];

            //console.log( jsonresp.DATA[i][JSVCqueryGetColNo(jsonresp,'CLAIMTYPE')] );
            if(jsonrole == 'R')
            {
                hasR=true;
                _jsonruser.DATA[_jsonruser.DATA.length] = [jsonresp.DATA[i][JSVCqueryGetColNo(jsonresp,'FULLDISP')], jsonresp.DATA[i][JSVCqueryGetColNo(jsonresp,'VAUSID')] ] ;
            }
            else
            {
                hasA=true;
                _jsonauser.DATA[_jsonauser.DATA.length] = [ jsonresp.DATA[i][JSVCqueryGetColNo(jsonresp,'FULLDISP')], jsonresp.DATA[i][JSVCqueryGetColNo(jsonresp,'VAUSID')] ];
            }
        }
        screenDisableRole('A',!hasA);
        screenDisableRole('R',!hasR);
        screenDisableRole('I',false)
    }
    <cfif attributes.defrole neq "" and attributes.defscreen neq "">
        $('##selScreen_#attributes.defrole#_#attributes.defscreen#').prop("checked",true).trigger("click");
    </cfif>
}
function ChangeUserID(type){
    if( $('##selUserid').attr('type')!=type )
        popuser(type);
}
function popuser(type) {
    var jsonquery;

    if(type == "I")
        jsonquery = _jsoniuser;
    else if (type == "R")
        jsonquery = _jsonruser;
    else if (type == "A")
        jsonquery = _jsonauser;
    else
        type = ''

    var obj = $('##selUserid')[0];
    obj.options.length = 1;
    if(type!='')
        JSVCjsonCreateSelOptions(obj,jsonquery,'VAUSID','FULLDISP',0);
    $('##selUserid').attr('type',type);
    <cfif attributes.defseluserid neq "">
        $('##selUserid').val("#attributes.defseluserid#").trigger("change");
    </cfif>
    DoReq(document.getElementsByName("selUserid")[0]);
}


function screenDisableRole(type,disable) {
    if(disable == null) disable = true;
    if(disable)
        $('##screen'+type).find("input").each(function(i,o){ $(this).removeAttr("CHKREQUIRED"); $(this).prop("checked",false); $(this).prop("disabled",true); DoReq(o) })
    else
        $('##screen'+type).find("input").each(function(i,o){ $(this).attr("CHKREQUIRED",""); $(this).prop("disabled",false); DoReq(o) })
}
function screenDisableAll() {
    screenDisableAllType('I');
    screenDisableAllType('R');
    screenDisableAllType('A');
    popuser();
    //$('##selUserid').attr('type','');
}
function screenDisableAllType(type) {
    $('##screen'+type).find("input").each(function(i,o){ /* if( o.id != 'selScreen_'+type+'_CREATE_NEW' )  */{ $(this).removeAttr("CHKREQUIRED"); $(this).prop("disabled",true); DoReq(o) } })
}

/* function changeScreen(defval) {

	var res = JSVCqueryFindRows(_jsonscreen, JSVCqueryGetColNo(_jsonscreen,'ROLE'), $('[name="selRole"]').val());
 	var obj = $('[name="selScreen"]')[0];
	JSVCjsonCreateSelOptions(obj,res,'SCREENCODE','SCREENDESC',0);
	if(defval!=null && defval!='')
	{
		$('[name="selScreen"]').val(defval);
    }
    changeUser();
    toggleScreenCase();
    DoReq(obj);
} */
/* function toggleScreenCase()
{
    var obj = $('[name="selScreen"]')[0];
    if(obj.value == "CREATE_NEW" || obj.value == "")
    {
        $('##caseid').val("").trigger("blur").attr("disabled",true).hide();
        $('##caseid_span').hide();
    }
    else
    {
        $('##caseid').attr("disabled",<cfif listfindnocase("0,1",attributes.register) gt 0>false<cfelse>true</cfif>).show().trigger("blur")
        $('##caseid_span').show();
    }

} */
/* function changeUser() {
    var user = "";
    var ROLE = $('##selRole').val();
    var sysdecide = $('##sysdecide').prop("checked");

    if(ROLE == 'R')
        user = "#q_rep.vausid#";
    else if(ROLE == 'A')
        user = "#q_adj.vausid#";
    else if(ROLE == 'I')
        user = "#q_getusers.vausid#";

    if(ROLE == 'R' || ROLE == 'A')
    {
        $('##divsel').hide().find("select").attr("disabled",true);
        $('##divtext').show().find("input").attr("disabled",sysdecide);
    }
    else
    {
        $('##divsel').show().find("select").attr("disabled",sysdecide);
        $('##divtext').hide().find("input").attr("disabled",true);
    }

    if(sysdecide)
    {
        $('[name=selUserid]').each(function(i,o){
            o.removeAttribute("CHKREQUIRED");
            DoReq(o);
        });
    }
    else
    {
        $('[name=selUserid]').each(function(i,o){
            o.setAttribute("CHKREQUIRED","");
            DoReq(o);
        });
    }
    $('##selUserid_hidden').val(user);
} */
/* function getUserID() {
    var inp = $('input##selUserid').val();
    var sel = $('select##selUserid').val();

    if($('##sysdecide').prop("checked"))
        return document.getElementById('selUserid_hidden').value;
    if (inp!="")
        return inp;
    if (sel!="")
        return inp;
} */
function goConfigure(mode) //1:register, 2:configure
{
	if(FormVerify(document.getElementById('form1')))
	{
		var url = request.webroot + "index.cfm?fusebox=MTRadmin&fuseaction=dsp_fieldscraper&coid=#attributes.coid#&nolayout=1&"+request.mtoken;

        var selScreen_val = $('[name=selScreen]:checked').val();
        var selScreen_role = $('[name=selScreen]:checked').prop('id').split("_")[1];

        var selClaimType = document.getElementById('selClaimType');
        var selUserid = ($('##sysdecide').prop("checked")?document.getElementById('selUserid_hidden'):document.getElementById('selUserid'));
        var caseid = document.getElementById('caseid');

        var postdata = [];
        postdata.push(["selRole",selScreen_role]);
        postdata.push(["selScreen",selScreen_val]);
        postdata.push(["selUserid",$('select##selUserid').val()]);
        postdata.push(["caseid",caseid.value]);

        if(selClaimType)
            postdata.push(["selClaimType",selClaimType.value]);

        postdata.push(["config_mode",mode])

		JSVCopenWin("about:blank",0,null,1000,700,false,'window','winConfigField');
		JSVCopenWinPost(url,"winConfigField",postdata);
	}
}

AddOnloadCode("<cfif attributes.READONLY eq 0>MrmPreprocessForm();</cfif><cfif attributes.standalone eq 0>checkCaseID();</cfif>");
</script>

<cfif Attributes.STANDALONE eq 0>
    <h4 class="clsColorNote"  align=center>#request.ds.co[attributes.coid].coname# (GCOID:#attributes.coid#)</h4>
    <form name="form1" id="form1" action="#request.webroot#index.cfm?fusebox=MTRadmin&fuseaction=dsp_fieldscraper&COID=#Attributes.COID#&#Request.MTOKEN#" method="post">
    <!--- <table border="0" cellspacing="0" cellpadding="4" style="width:100%" align="center" class="tableSel"> --->
    <table border="0" cellspacing="0" cellpadding="4" style="width:100%" align="center"<!---  class="tableSel" --->>
    <tr>
        <td width=50% valign=bottom>

            <div align=left><b>Step 1 <span style="color:blue;">-></span> Key in a case ID :</b> <input type="text" name="caseid" id="caseid" CHKNAME="Case ID" size=15 value="#attributes.defcaseid#" CHKREQUIRED onblur="checkCaseID();DoReq(this);"></div>
            <div><br></div>
            <b>Step 2 <span style="color:blue;">-></span> Select a screen :</b>

        </td>

        <td width=50%>

            <b>Step 3 <span style="color:blue;"> -> </span>Select a User ID :</b>
            <select name="selUserid" ui-type="select2"  CHKNAME="Select User ID" CHKREQUIRED onchange="DoReq(this);" id="selUserid" type="" <!--- #disabled_str# --->><option value=""></option></select>
            <br>&nbsp;<br>
            <b>Step 4 <span style="color:blue;"> -> </span>Launch the Field Configure screen : </b> <input type="button" value="Configure  >>"  name="Config" value="Configure" class="clsButton" onclick="goConfigure(2)">
        </td>
    </tr>
    <tr>
        <td colspan=3>
            <table border="0" cellspacing="0" cellpadding="2" style="width:100%" align="center" class="tableSel">
                <!--- <tr><td colspan=3 align=left><b>Step 2 <span style="color:blue;">-></span> Select a screen </b></td></tr> --->
                <tr class="header"><td>Insurer</td><td>Repairer</td><td>Adjuster</td></tr>
                <tr>
                    <td width=33% valign=top id="screenI">
                        <cfloop from=1 to=#arrayLen(screenStruct.I)# index=i>
                            <label for="selScreen_I_#screenStruct.I[i].screencode#"><input type="radio" CHKNAME="Screen" CHKREQUIRED name="selScreen" onclick="ChangeUserID('I');DoReq(this);" id="selScreen_I_#screenStruct.I[i].screencode#" value="#screenStruct.I[i].screencode#"> #screenStruct.I[i].screendesc#</label><br>
                        </cfloop>
                    </td>
                    <td width=33% valign=top id="screenR">
                        <cfloop from=1 to=#arrayLen(screenStruct.R)# index=i>
                            <label for="selScreen_R_#screenStruct.R[i].screencode#"><input type="radio" CHKNAME="Screen" CHKREQUIRED name="selScreen" onclick="ChangeUserID('R');DoReq(this);" id="selScreen_R_#screenStruct.R[i].screencode#" value="#screenStruct.R[i].screencode#"> #screenStruct.R[i].screendesc#</label><br>
                        </cfloop>
                    </td>
                    <td width=33% valign=top id="screenA">
                        <cfloop from=1 to=#arrayLen(screenStruct.A)# index=i>
                            <label for="selScreen_A_#screenStruct.A[i].screencode#"><input type="radio" CHKNAME="Screen" CHKREQUIRED name="selScreen" onclick="ChangeUserID('A');DoReq(this);" id="selScreen_A_#screenStruct.A[i].screencode#" value="#screenStruct.A[i].screencode#"> #screenStruct.A[i].screendesc#</label><br>
                        </cfloop>
                    </td>
                </tr>
            </table>
            <input type="hidden" name="selClaimType" id="selClaimType" value="">
        </td>
    </tr>
</table>
<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkguid.cfm" START>
</form>

<cfelse><!--- show summary / disabled --->

    <tbody>
	<tr class="bottombord">
		<td width="15%" nowrap align=left>
			<b>Role :</b>&nbsp;
			<select name="selRole" onchange="changeScreen();" id="selRole" #disabled_str#  CHKNAME="Role"><cfloop list="I|Insurer,A|Adjuster,R|Repairer" index=i><option value="#listfirst(i,'|')#"<cfif Attributes.selROLE eq listfirst(i,'|')> selected</cfif>>#listlast(i,'|')#</option></cfloop></select>
		</td>
        <td width="20%" nowrap align=center><b>Screen : </b>&nbsp;
            <cfquery name="q_getselscreen" dbtype="query">select * from q_screenreg where screencode = '#form.selSCREEN#'</cfquery>
            <select name="selScreen" CHKNAME="Select Screen" id="selScreen" #disabled_str#><option value="#q_getselscreen.screencode#">#q_getselscreen.screendesc#</option></select>
        </td>
        <td width="20%" nowrap align=center><b>User ID :</b>&nbsp;
            <input type="text" value="#form.selUSERID#" #disabled_str# size=16>
        </td>
        <td width="20%"align=center>
            <b>Claim Type</b>&nbsp;
            <select name="selClaimType" id="selClaimType" #disabled_str#>
                <cfloop query="#q_getclaimtype#"><option value="#iCLMTYPEMASK#"<cfif Attributes.SELCLAIMTYPE eq iCLMTYPEMASK> selected</cfif>>#vaCLMTYPE#</option></cfloop>
            </select>
        </td>
        <td align=center>
            <span id=caseid_span>
                &nbsp; CaseID :
                <cfif form.selSCREEN eq "CREATE_NEW">
                    <input type="text" value="N/A" #disabled_str# size=16>
                <cfelse>
                    <input type="text" value="#attributes.caseid#" onblur="JSVCNumLOC(this,null,0,0,null,'');DoReq(this);" CHKREQUIRED name="caseid" id="caseid" size=6 #disabled_str#>
                </cfif>

            </span>
        </td>
    </tr>
    </tbody>


</cfif>

</cfoutput>





<cffunction name="ListCT">
    <cfargument name="mask">
    <cfset str = "">

    <cfloop query=#q_getclaimtype# >
        <cfif bitAnd(q_getclaimtype.iclmtypemask,mask) gt 0>
            <cfset str = listAppend(str,q_getclaimtype.vaCLMTYPE)>
        </cfif>
    </cfloop>

    <cfreturn str>
</cffunction>