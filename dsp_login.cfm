<cfinclude TEMPLATE="act_mrmframework.cfm">
<cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCADDFILE.cfm" FNAME="SVCLOGIN">
<cfset currenttime="#DateFormat(now(),'mm/dd/yyyy')# #TimeFormat(now(),'HH:mm:ss')#">
<cfset nonce=ToBase64(currenttime&Hash(currenttime&"boo$ga56"))>
<script>
var globalnonce="<cfoutput>#nonce#</cfoutput>";
var globalTimeout=300000;
var SVCchkmultilog = 0;
function submitLogin()
{
	var slcform=document.getElementById('myform');
	if(SVCchkmultilog==0){
		SVCchkmultilog=1;
		var cslt='';
		var nonce;
		var pwd=(slcform.slePassword.value).toUpperCase();
		document.getElementById("slePassword").value='';	
		while(pwd.charAt(0) == " ")
			pwd = pwd.slice(1);
		while(pwd.charAt(pwd.length - 1) == " ")
			pwd = pwd.substr(0,pwd.length - 1);
		var usrid=escape(slcform.sleUserName.value);
		if(pwd!=""){
			cslt=SHA512(slcform.sleUserName.value.replace(/(\$.*)/gi,'').toUpperCase()+"bing$748wOLly").toUpperCase();
			//p2=SHA512(SHA512(pwd).toString().toUpperCase()).toUpperCase();
			//pwd=calcMD5(calcMD5(pwd)+globalnonce).toUpperCase();
			pwd=SHA512(calcMD5(pwd)+cslt).toUpperCase();
			nonce=globalnonce.substr(0,27)+SHA512(pwd+globalnonce.substr(28,globalnonce.length-1)).toUpperCase();
		}
		document.getElementById("slePassword").value=pwd;
		document.getElementById("Nonce").value=nonce;	
		slcform.action=request.webroot+'index.cfm?fusebox=MTRsec&fuseaction=act_login&'+request.mtoken;
		//firefox back button fix
		// $(window).unload(function () { SVCchkmultilog=0;});

        console.log('request.webroot = ' + request.webroot)
        console.log('request.mtoken = ' + request.mtoken)
        console.log(slcform.sleUserName.value)
        console.log(slcform.slePassword.value)
		// FormSubmit(slcform);
	} 

}
$(document).ready(function(){$("#sleUserName").focus()});
</script>

<table cellspacing="0" cellpadding="0" width="100%" height="100%" border="0" style="margin-top:-14">
  <tr>
    <td valign="top">
      <!-- Top -->
      <table border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="white" width="100%">
        <tr>
          <td align="center">
            <form name="myform" id="myform" method=post>
              <table cellspacing="0" cellpadding="3" border="0">
                <tr>
                  <td style="color:#FF0000" colspan="2">
                    <cfif arguments.retryid eq 1>
                      Invalid UserID or Password.<br>
                      Please enter your UserID and Password again.
                    <cfelseif arguments.retryid eq 2>
                      Invalid UserID or Password. Bad login quotas exceeded.<br>
                      The account will be locked for 30 minutes.<br>
                      Please try again in 30 minutes, or contact <cfoutput>#Application.APPFULLNAME#</cfoutput> Online.
                    <cfelse>
                      <!--- Please enter your User ID and Password. --->
                    </cfif>
                  </td>
                </tr>
                <tr>
                  <td colspan="2"> Please Enter Your Username &amp; Password,<br />
                    <br />
                  </td>
                </tr>
                <tr>
                  <th scope="row">
                    <label for="email" style="color: #4596cb; font-size: 14px; font-weight: bold; font-family: arial; letter-spacing: 1px;"> username </label>
                  </th>
                  <td id="email">
                    <input id="sleUserName" name="sleUserName" title="Username" type="text" size="20" style="font-size: 8pt; font-family: tahoma;" value="" />
                  </td>
                </tr>
                <tr>
                  <th scope="row">
                    <label for="password" style="color: #4596cb; font-size: 14px; font-weight: bold; font-family: arial; letter-spacing: 1px;"> password </label>
                  </th>
                  <td id="password">
                    <input id="slePassword" name="slePassword" title="Password" type="password" size="20" style="font-size: 8pt; font-family: tahoma;" value="" onkeydown="if(event.keyCode==13)submitLogin()" />
                  </td>
                </tr>
                <tr>
                  <th scope="row">&nbsp; </th>
                  <td>
                    <input type=hidden id=Nonce name=Nonce><input id="btnsubmit" title="Submit" name="submit_button" value="Login" type="button" style="font-size:100%" onclick="submitLogin()" />
                  </td>            
              </table>
            </form>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>