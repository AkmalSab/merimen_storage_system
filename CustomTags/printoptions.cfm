<STYLE MEDIA=PRINT>
	.clsNoPrint { display:none }
</STYLE>
<CFSET show=1>
<CFIF IsDefined("Attributes.CO")>
	<CFIF IsDefined("Request.DS.CO") AND StructKeyExists(Request.DS.CO,SESSION.VARS.ORGID) AND StructKeyExists(Request.DS.CO[SESSION.VARS.ORGID],"CHCOLIST")>
		<CFSET COLIST=Request.DS.CO[SESSION.VARS.ORGID].CHCOLIST>
	<CFELSE>
		<CFSET COLIST=SESSION.VARS.ORGID>
	</CFIF>
	<CFIF Find(",#Attributes.CO#,",",#CoList#,") LTE 0>
		<CFSET Show=0>
	</CFIF>
</cfif>
<CFPARAM NAME=Attributes.Lines DEFAULT="5">
<div class=clsNoPrint style="width:100%;padding:3px;border:2px solid black;background-color:silver">
<div style=font-weight:bold;text-decoration:underline><cfoutput>#Server.SVClang("Printing Options",1544)#</cfoutput></div>
<CFIF show IS 1>
<input id=CHKNOHEAD onclick=ClickNoHead(this) type=checkbox>&nbsp;<cfoutput>#Server.SVClang("Hide Company Header - Leave {0} lines blank",1545,0,"<input id=TXTLINES type=text value='#Attributes.Lines#' maxlength=2 size=3 onkeyup=ChangeLines(this) onBlur=ChangeLines(this.value)>")#</cfoutput><br>
</CFIF>
<input id=CHKNOBREAKS onclick=ClickNoBreaks(this) type=checkbox>&nbsp;<cfoutput>#Server.SVClang("Print continuously - Do not break pages",1546)#</cfoutput><br>
<CFIF IsDefined("Attributes.MOREINFO")>
<CFOUTPUT>#Attributes.MOREINFO#</CFOUTPUT>
</CFIF>
</div>
<script>
window.onload = function()
{
	if(!(window.closed))
		window.self.focus();
}
function ClickNoBreaks(obj)
{
	var ss=document.all("PAGEBREAKID");
	if(ss!=null)
		ss.disabled=obj.checked;
}
<CFIF show IS 1>
var printspacenode=document.createElement("DIV");
printspacenode.id = 'PRINTHEADERSPACE';
<CFOUTPUT>ChangeLines(#Attributes.Lines#,true);</cfoutput>
function ClickNoHead(obj)
{
	if(obj.checked==true)
	{
		IterateAll("COHEADER","none",1);
		IterateAll("COFOOTER","none");
	}
	else
	{
		IterateAll("COHEADER","block",2);
		IterateAll("COFOOTER","block");
	}
}
function ChangeLines(val,noiterate)
{
	var str="";
	var maxcnt=parseInt(val);
	if(!(maxcnt>=0))
		maxcnt=0;
	for(var i=0;i<maxcnt;i++)
		str=str+"&nbsp;<br>";
	printspacenode.innerHTML=str;
	if(noiterate!=true)
		IterateAll("PRINTHEADERSPACE",null,3)
}
function ApplyObj(obj,val,mode)
{
	if(mode==1)
	{
		obj.style.display=val;
		var obj2=printspacenode.cloneNode(true);
		obj.insertAdjacentElement("afterEnd",obj2);
	} else if(mode==2)
	{
		obj.style.display=val;
		obj=obj.nextSibling;
		if(obj.id=="PRINTHEADERSPACE")
			obj.removeNode(true);
	} else if(mode==3)
	{
		var str="";
		var maxcnt=parseInt(document.all("TXTLINES").value);
		if(!(maxcnt>=0))
			maxcnt=0;
		for(var i=0;i<maxcnt;i++)
			str=str+"&nbsp;<br>";
		obj.innerHTML=str;
	} else
	{
		obj.style.display=val;
	}
}
function IterateAll(id,val,mode)
{
	var col = document.all(id);
	var obj;
	if (col!=null)
	{
		var vlen = col.length;
		if(vlen!=null && col.tagName == null)
		{
        	for (var i=0; i<vlen; i++)
				ApplyObj(col[i],val,mode);
		} else
			ApplyObj(col,val,mode);
	}	
}
</CFIF>
</script>