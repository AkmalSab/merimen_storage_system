<!--- Defaults specified here --->
<cfparam name="attributes.grouped" default="true">
<cfparam name="attributes.width" default="100%">
<cfparam name="attributes.actfile" default="">

<script>
var Groups = new Array();
var List1 = new Array();
var List2 = new Array();
var OrigList1 = new Array();
var OrigList2 = new Array();
function SubmitForm(location, submitform)
{
var deletelist="",obj;
var origlen=OrigList2.length;
var len=List2.length;
var todelete=true;
if (submitform==null) submitform=true; //true: form submitted at the end of function; false: don't submit
for (n=0;n<origlen;n++)
	{
	for (m=0;m<len;m++)
		{
		if (OrigList2[n].id==List2[m].id && List2[m].ismoved==false)
			{
			todelete=false;
			break;
			}			
		}
	if (todelete) 
		deletelist += OrigList2[n].id+",";	
	else 
		todelete=true;
	}
		
var insertlist="";	
var toinsert=true;
for (n=0;n<len;n++)
	{
	var found=false;
	for (m=0;m<origlen;m++)
		{
		if (List2[n].id==OrigList2[m].id) {found=true; break;}
		}
	if (found) 
		toinsert=false;
	if (found==false && List2[n].ismoved==true)
		toinsert=false; 
	if (toinsert) 
		insertlist += List2[n].id+","; 
	else 
		toinsert=true;
	}
	document.getElementById("deletelist").value=deletelist;
	document.getElementById("insertlist").value=insertlist;
	document.getElementById("location").value=location;
	if (submitform) {
		obj=document.getElementsByName('listform');
		obj=(obj!=null&&obj.length>0?obj[0]:null);
		obj.submit();
	}
}
function Drag(obj)
{
	if (event.srcElement.tagName.toUpperCase()!='INPUT') 
	{	
		var followHTML="<table CELLPADDING=2 CELLSPACING=0 style='width:"+document.getElementById("div1").scrollWidth+"'><tr>"+obj.innerHTML+"</tr></table>";
		var followobj = document.getElementById("followmouse");
		StartDrag(obj, 'lightsteelblue', followobj, followHTML);
	}
}
function Drop(obj)
{
	var followobj = document.getElementById("followmouse");
	StartDrop(obj, followobj);
	var orig=obj.id.split("@");
	if (orig[0]=="list1") var target=document.getElementById("div2");
	else var target=document.getElementById("div1");
	var targetpos = FindObjPos(target);
	var minleft = targetpos[0];
	var mintop = targetpos[1];
	var maxleft = minleft + target.scrollWidth;
	var maxtop = mintop + target.style.posHeight;
	var mouseleft = document.body.scrollLeft+event.clientX;
	var mousetop = document.body.scrollTop+event.clientY;
	if (mouseleft>minleft && mouseleft<maxleft && mousetop>mintop && mousetop<maxtop)
	{
		var sourcelist=new Array();
		var targetlist=new Array();
		var temp=new Array();
		sourcelist=(orig[0]=="list1"?List1:List2);
		targetlist=(orig[0]=="list1"?List2:List1);
		sourcelist[orig[1]].ismoved=true;
		sourcelist[orig[1]].ispendmove=false;
		var found=false;
		for (m=0;m<targetlist.length;m++) 
			{
				if (sourcelist[orig[1]].id==targetlist[m].id) 
				{
					targetlist[m].ismoved=false;
					found=true;
					break;
				}
			}
		if (found==false)
			temp[0]=new cList(sourcelist[orig[1]].id, sourcelist[orig[1]].name, sourcelist[orig[1]].TDhtml, sourcelist[orig[1]].groupid, sourcelist[orig[1]].groupname, false, false, true);
		var group = document.getElementsByName("checkgroup")[0].checked;
		if (orig[0]=="list1") 
			{
			Groups[sourcelist[orig[1]].groupid].groupselected++;
			Groups[0].groupselected++;
			List2=temp.concat(List2); 
			List2.sort((group?AscGroupName:AscName));
			Groups[sourcelist[orig[1]].groupid].openlist2=true;
			}
		else 
			{
			Groups[sourcelist[orig[1]].groupid].groupselected--;
			Groups[0].groupselected--;
			List1=temp.concat(List1);
			List1.sort((group?AscGroupName:AscName));
			Groups[sourcelist[orig[1]].groupid].openlist1=true;
			}
		DrawTable(1,group);
		DrawTable(2,group);
	}	
}
function SelectItem(obj)
{
	var n=parseInt(obj.id);
	if (Trim(obj.name)=="List1Item")
	{
		List1[n].ispendmove=obj.checked;
		Groups[List1[n].groupid].openlist2=true;
	}
	else
	{
		List2[n].ispendmove=obj.checked;
		Groups[List2[n].groupid].openlist1=true;
	}
}
function SelectGroupAll(obj)
{
if (obj.name=="List1") var curlist=List1; else var curlist=List2;
for (n=0; n<curlist.length; n++) 
	if (curlist[n].groupid==obj.id && !curlist[n].ismoved) curlist[n].ispendmove=obj.checked;
var nextobj=obj.parentElement.parentElement.nextSibling.lastChild.firstChild;
while(nextobj!=null && nextobj.tagName=="INPUT")
	{
	nextobj.checked=obj.checked;
	obj=nextobj;
	try {nextobj=obj.parentElement.parentElement.nextSibling.lastChild.firstChild;}
	catch(e){nextobj=null;}
	}
}
function MoveSelected(sourcelistname)
{
	var sourcelist=new Array();
	var targetlist=new Array();
	sourcelist=(sourcelistname==1?List1:List2); 
	targetlist=(sourcelistname==2?List1:List2);
	var len=sourcelist.length;
	var temp=new Array();
	count=0;
	for (n=0;n<len;n++)	
	{
		if (sourcelist[n].ispendmove)
		{
			var found=false;
			for (m=0;m<targetlist.length;m++) 
			{
				if (sourcelist[n].id==targetlist[m].id) 
				{
					targetlist[m].ismoved=false;
					found=true;
					break;
				}
			}
			if (found==false)
			{
				temp[count]=new cList(sourcelist[n].id, sourcelist[n].name, sourcelist[n].TDhtml, sourcelist[n].groupid, sourcelist[n].groupname, false, false, true);
				count++;
			}
			sourcelist[n].ismoved=true;
			sourcelist[n].ispendmove=false;
			if (sourcelistname==1)
			{
				Groups[sourcelist[n].groupid].groupselected++;
				Groups[0].groupselected++;
			}
			else 
			{
				Groups[sourcelist[n].groupid].groupselected--;
				Groups[0].groupselected--;
			}
		}
	}
	var group = document.getElementsByName("checkgroup")[0].checked;
	if (sourcelistname==1) 
		{
		List2=temp.concat(List2); 
		List2.sort((group?AscGroupName:AscName));
		}
	else 
		{
		List1=temp.concat(List1);
		List1.sort((group?AscGroupName:AscName));
		}
	DrawTable(1,group);
	DrawTable(2,group);
}
function MoveAll(sourcelistname)
{
	if (sourcelistname==1)
	{
		for (n=0;n<List1.length;n++)
			if (!List1[n].ismoved) List1[n].ispendmove=true;
	}
	else
	{
		for (n=0;n<List2.length;n++)
			if (!List2[n].ismoved) List2[n].ispendmove=true;
	}
	MoveSelected(sourcelistname);
}
function CheckGroup(obj)
{
if (obj.value=="group") {DrawTable(1,true); DrawTable(2,true);}
else {DrawTable(1,false); DrawTable(2,false);}
}
function AscName(a,b) 
{
if (Trim(a.name)>Trim(b.name)) {return 1} 
else {if (Trim(a.name)<Trim(b.name)) return -1 
	else return 0}
}
function AscGroupName(a,b) 
{
if (Trim(a.groupname)>Trim(b.groupname)) {return 1} 
else {if (Trim(a.groupname)<Trim(b.groupname)) return -1 
	else return 0}
}
function cList(id, name, TDhtml, groupid, groupname, ispendmove, ismoved, isnew)
{
	this.id=id;
	this.name=name;
	this.TDhtml=TDhtml;
	this.groupid=groupid;
	this.groupname=groupname;
	this.ispendmove=ispendmove;
	this.ismoved=ismoved;
	this.isnew=isnew;		
}
function cGroups(groupname, openlist1, openlist2, grouptotal, groupselected)
{
	this.groupname=groupname;
	this.openlist1=openlist1;
	this.openlist2=openlist2;
	this.grouptotal=grouptotal;
	this.groupselected=groupselected;
}
function GenRows(list, group)
{
	var htmRows="";
	if (list==1) 
		var curlist=List1; 
	else 
		var curlist=List2;
	var len=curlist.length;
	var curgroupid;
	var rowcnt=0;
	var groupcnt=0;
	var shown;
	var isIE = /*@cc_on!@*/false || !!document.documentMode;
	if (group) curlist.sort(AscGroupName);
	else curlist.sort(AscName);
	for (n=0;n<len;n++)
	{	
		if (curlist[n].ismoved==false)
		{
			if (curgroupid!=curlist[n].groupid && group)
			{
				if (curgroupid!=null) 
				{
					htmRows += "</tbody>";
					groupcnt=0;
				}
				curgroupid=curlist[n].groupid;
				if (list==2) var numselected="<span style='font-weight:normal;font-size:80%;vertical-align:middle;text-align:right;'>&nbsp;("+Groups[curlist[n].groupid].groupselected+"/"+Groups[curlist[n].groupid].grouptotal+")</span>";
				else var numselected="";
				shown=eval("Groups[curlist[n].groupid].openlist"+list);
				htmRows+="<tr id=List"+list+"Group"+curlist[n].groupid+" onclick='Groups["+curlist[n].groupid+"].openlist"+list+"=!Groups["+curlist[n].groupid+"].openlist"+list+";Toggle2(this);' class=clsDetail3 style='cursor:pointer;font-size=115%;font-weight:bold'>"+
							"<td colspan=2><img id=GF  src='"+request.webroot+"common/"+(shown?"minus.gif":"plus.gif")+"'>&nbsp; "+curlist[n].groupname+" "+numselected+"</td>"+
							"</tr><tr></tr>"+
							"<tbody style='display:"+(shown?"block":"none")+"'>"+
							"<tr class=clsDetail"+((rowcnt%2)+1)+">"+
							"<td width=5% style='font-weight:bold'>Select All</td>"+
							"<td width=5%><input type=checkbox id="+curgroupid+" name=List"+list+" onclick=SelectGroupAll(this)></td>"+
							"</tr>";
				rowcnt++;
			}
			if(isIE){
					htmRows+="<tr eventoffsetX='-999' eventoffsetY='-999' backgroundcolor='' cursorstyle='' onmousemove=FollowMouse(this,document.getElementById('followmouse'));  onmousedown='Drag(this)'  onmouseup='Drop(this)' style='cursor:default' class=clsDetail"+((rowcnt%2)+1)+" id=list"+list+"@"+n+">"
					+"<td width=95% style='color:"+(curlist[n].isnew?"red":"black")+"'>"+curlist[n].TDhtml
					+"</td>"
					+"<td width=5%><input type=checkbox id="+n+"  name=List"+list+"Item "+(curlist[n].ispendmove?" checked":"")+" onclick=SelectItem(this)></td></tr>";
			} else{
					htmRows+="<tr eventoffsetX='-999' eventoffsetY='-999' backgroundcolor='' cursorstyle='' onmousemove=FollowMouse(this,document.getElementById('followmouse')); style='cursor:default' class=clsDetail"+((rowcnt%2)+1)+" id=list"+list+"@"+n+">"
					+"<td width=95% style='color:"+(curlist[n].isnew?"red":"black")+"'>"+curlist[n].TDhtml
					+"</td>"
					+"<td width=5%><input type=checkbox id="+n+"  name=List"+list+"Item "+(curlist[n].ispendmove?" checked":"")+" onclick=SelectItem(this)></td></tr>";
			}
			groupcnt++;
			rowcnt++;
		}
	}
	return htmRows;	
}

function DrawTable(list, group)
{
	var htmRows = GenRows(list, group);
	document.getElementById("div"+list).innerHTML="<table name=table"+list+" CELLPADDING=2 CELLSPACING=0 WIDTH=100%>"+
									htmRows+"</tbody></table>";
	if (list==2) document.getElementById("totalselected").innerHTML=Groups[0].groupselected;
}
function SetDivHeight(fit)
{
	var tabletopheightA = (fit?parseInt(document.getElementById("Row1").offsetHeight)+parseInt(document.getElementById("Row2A").offsetHeight):60);
	var tabletopheightB = (fit?parseInt(document.getElementById("Row1").offsetHeight)+parseInt(document.getElementById("Row2B").offsetHeight):60);
	var height=document.body.clientHeight;
	if (height>tabletopheightA)
		document.getElementById("div1").style.height = height-tabletopheightA;
	if (height>tabletopheightB)	
		document.getElementById("div2").style.height = height-tabletopheightB;
}
function FitToScreen()
{
window.navigate("##tabletop");
SetDivHeight(true);
}
</script>

<cfoutput>
<cfif attributes.actfile is not "">
	<form method=post action="#attributes.actfile#" name=listform id="listform">
		<CFMODULE TEMPLATE="#request.apppath#services/CustomTags\SVCchkguid.cfm" START>
		<input type=hidden name=deletelist id="deletelist">
		<input type=hidden name=insertlist id="insertlist">
		<input type=hidden name=location id="location">
	</form>
</cfif>
<div id=followmouse style='visibility:hidden;position:absolute;'></div>
<a name="tabletop"></a>
<table cellspacing=0 cellpadding=0 border=0 width=#attributes.width# align=center style="table-layout:fixed;">
<col width=47%><col width=6%><col width=47%>
	<tr id="Row1" class=header>
		<td colspan=2 style="padding:2 2 2 2;" width=80%>
			#attributes.title# &nbsp;&nbsp;&nbsp;
			<a href="Javascript:FitToScreen()"><span style="font-size=80%">[fit to screen]</span></a>
		</td>
		<td colspan=1 align=right style="padding:2 2 2 2;font-size=80%" width=20%>
			<input style="height:4ex" type=radio value="group" name="checkgroup" onclick='CheckGroup(this)' <cfif attributes.grouped>checked</cfif>> Group By States
			<input style="height:4ex" type=radio value="ungroup" name="checkgroup" onclick='CheckGroup(this)' <cfif not attributes.grouped>checked</cfif>> Order Alphabetically
		</td>
	</tr>
	<tr valign=top>
		<td>
			<table id="Row2A" class=clsColumnHeader CELLPADDING=0 CELLSPACING=0 WIDTH=100%>
			<tr><td align=center >#attributes.List1Title# &nbsp;&nbsp;&nbsp;<input type=button onclick='MoveAll(1);' value="All >>"></td></tr>
			</table>
			<div id="div1" style="overflow-y:scroll;background-color:gainsboro;"> 
			</div>
		</td>
		<td bgcolor="lightsteelblue">
			<table border=0 CELLPADDING="0"  CELLSPACING="0" WIDTH="100%">
				<tr><td align=center>&nbsp;</td></tr>
				<tr><td>&nbsp;</td></tr>
				<tr><td>&nbsp;</td></tr>
				<tr><td align=center><input type=button value=" >> " onclick=MoveSelected("1")></td></tr>
				<tr><td>&nbsp;</td></tr>
				<tr><td>&nbsp;</td></tr>
				<tr><td>&nbsp;</td></tr>
				<tr><td align=center><input type=button value=" << " onclick=MoveSelected("2")></td></tr>
			</table>
		</td>
		<td>
			<table id="Row2B" class=clsColumnHeader CELLPADDING=0  CELLSPACING=0 WIDTH=100%>
			<tr><td align=center ><input type=button onclick='MoveAll("2");' value="<< All">&nbsp;&nbsp;&nbsp; #attributes.List2Title# (<span id=totalselected></span> selected)</td></tr>
			</table>
			<div id="div2" style="overflow-y:scroll;background-color:gainsboro;">
			</div>
		</td>
	</tr>
</table>  

<script>
AddOnloadCode("window.onresize=SetDivHeight;SetDivHeight();DrawTable(1, #attributes.grouped#);DrawTable(2, #attributes.grouped#);");
</script>
</cfoutput> 