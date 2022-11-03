<cfmodule template="#request.apppath#services/CustomTags\SVCDisableDirect.cfm" Path="#GetCurrentTemplatePath()#"> 
<cfparam name="attributes.coid" default="0">
<cfparam name="attributes.labelid" default="0">
<cfparam name="attributes.labelcoid" default="0">
<cfparam name="attributes.labelstat" default="">
<cfparam name="attributes.labelcostat" default="">

<cfset urlback="#request.webroot#index.cfm?fusebox=tag&fuseaction=dsp_labelmanadd&coid=#attributes.coid#&#Request.MToken#">
<cfset urlf="#request.webroot#index.cfm?fusebox=tag&fuseaction=act_labelmanadd&labelcoid=#attributes.labelcoid#&coid=#attributes.coid#&labelid=#attributes.labelid#&#Request.MToken#">

<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCADDFILE.cfm" FNAME="underscore"> 
<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCADDFILE.cfm" FNAME="underscore-mrm"> 
<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCADDFILE.cfm" FNAME="ko"> 
<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCADDFILE.cfm" FNAME="ko-mrm"> 
<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCADDFILE.cfm" FNAME="svcselector"> 

<cfset custom_tab = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;">
<cfquery name="qry_co" datasource="#request.mtrdsn#">
    select icoid,vaconame,ilocid,igcoid 
    from sec0005 with (nolock) 
    where icoid in (<cfqueryparam value="#attributes.coid#" CFSQLType = "cf_sql_integer" null="no">,0)
</cfquery>

<cfset gcoids = '0'>
<cfset gcoids = ListAppend(gcoids,qry_co.igcoid)>
<cfset killfields = 'no'>
<cfif application.db_mode eq 'PROD' and not (attributes.coid eq 700469)><!--- for ACA ID labelling, allow windi to create. --->
    <cfset killfields = 'yes'>
</cfif>

<cfquery name="qry_labels" datasource="#request.mtrdsn#">
    SELECT 
        def.ILBLDEFID 
        ,def.IDOMAINID
        ,def.ILOCID
        ,def.SIPRIVATE
        ,def.BCOCREATE
        ,def.BCOREAD
        ,def.ICOLORTXT
        ,def.ICOLORBGRND
        ,def.VALBLNAME
        ,VALBLDESC = isnull(def.VALBLDESC,'-- No Desc --')
        ,def.SISTATUS 
		,def.vaLBLNAME_LOCALLANG
		,def.vaLBLDESC_LOCALLANG
        ,labelco.ILBLDEFID as tielabelco 
        ,labelco.iGCOID
        ,labelco.siSTATUS as deactivatelabelco
        ,labelco.iGROUPPRIORITY
        ,iSELECTOR = isnull(labelco.iSELECTOR,-1) -- check the actual use case of null
        ,labelco.vaSELECTOR
    FROM fobjb3020 def 
    LEFT JOIN fobjb3022 labelco on labelco.iLBLDEFID = def.ILBLDEFID 
    AND labelco.iGCOID IN (<cfqueryparam value="#gcoids#" CFSQLType = "cf_sql_integer" null="no" list="yes" separator=",">) 
    WHERE def.ILBLDEFID = <cfqueryparam value="#attributes.labelid#" CFSQLType = "cf_sql_integer" null="no">
    ORDER BY labelco.igcoid DESC
</cfquery>

<cfquery name="qry_label" dbtype='query'>
    select * from qry_labels 
    <cfif attributes.labelcoid gte 0>
        where igcoid = <cfqueryparam value="#attributes.labelcoid#" CFSQLType = "cf_sql_integer" null="no"> 
    </cfif>
</cfquery>
<cfquery name="qry_islands" datasource="#request.mtrdsn#">
    SELECT St=MIN(ILBLDEFID), En=MAX(ILBLDEFID)
    FROM (
        SELECT ILBLDEFID
            ,rn=ILBLDEFID-ROW_NUMBER() OVER (ORDER BY ILBLDEFID)
        FROM fobjb3020)a
    GROUP BY rn ORDER BY ST,EN;
</cfquery>
<cfset locale = request.ds.locales[qry_co.ilocid]>
<cfset locid = qry_co.ilocid>

<!---    START IMPORT MERIMEN FRAMEWORK      --->
<CFSET DS=StructNew()>
<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCcffunctions.cfm" DS=#DS#>
<CFSET Request.DS=DS>
<CFSET Request.DS.FN.SVCSvrFileDSUpdate()>
<style>
.code {color:blue; font-family: 'courier sans ms'}
.quest { color:red;}
</style>
<!--- Include these using AddFile --->
<script>
    var request=new Object();
    <CFOUTPUT>
    request.apppath="#request.apppath#";
    request.approot="#request.approot#";
    </CFOUTPUT>
    sysdt=new Date();
</script>
<CFMODULE TEMPLATE="#request.apppath#services/CustomTags/SVCaddfile.cfm" FNAME="JQUERY">
<CFMODULE TEMPLATE="#request.apppath#services/CustomTags/SVCaddfile.cfm" FNAME="SVCMAIN">
<CFMODULE TEMPLATE="#request.apppath#services/CustomTags/SVCaddfile.cfm" FNAME="SVCCAL">
<CFMODULE TEMPLATE="#request.apppath#services/CustomTags/SVCaddfile.cfm" FNAME="SVCCSS">
<script>AddOnloadCode("MrmPreprocessForm()");</script>
<!--- END IMPORT MERIMEN FRAMEWORK --->

<cfoutput>
<h3 class=clsColorNote align=center>#Server.SVClang("Create/ Update Labels",27077)#</h3>
<script>
    function formsubmit(mode){
        var f = document.getElementById('labeladdf')
        var flag = document.getElementById('insertflag')
        if (mode==1) flag.value = 1
        f.submit()
    }

    function confirmation(){
        var isvalidated = false
        var message = 'This will add <br>[LBL ID:{{labelid}}] <span style="background:##{{bgcol}};color:##{{txcol}}">&nbsp;{{labelname}}&nbsp;</span> to <br>[CO ID:{{coid}}] {{coname}}  collection of labels.'
        message = message
        .replace('{{bgcol}}',adder.bgcol())
        .replace('{{txcol}}',adder.txcol())
        .replace('{{labelname}}',adder.labelname())
		.replace('{{localename}}',adder.localename())
        .replace('{{labelid}}',adder.labelid())
        .replace('{{coname}}',adder.theownerobj().name)
        .replace('{{coid}}',adder.theownerobj().val)
        SVCconfirm(message,formsubmit(1))
    }

    // GenerateMenubar("ClaimMenu",90,true);
    // AddToMenubar("ClaimMenu","<< " + JSVClang("Back (Co-Profile)",27033),"#urlback#");
    // AddToMenubar("ClaimMenu",JSVClang("Save",6804),"javascript:formsubmit(2)");
    // AddOnloadCode("MrmPreprocessForm();");
</script>

<table class="clsClmTable" align="center" width="90%" style="table-layout:fixed">
    <thead>
        <tr class="header">
            <td>
                <span align=center class="clsColorNote">WARNING</span>
            </td>
            <td>
                <div style="width:50%;float:left">
                    <span class="clsColorNote">Notes on General Usage:</span>
                </div>
                <div style="width:50%;float:left" align=right>
                    <input type="button" class="clsButton" value="Hide Warning/ Notes" onclick="$('##helptext').toggle()">
                </div>
            </td>
        </tr>
    </thead>
    <tbody id="helptext">
        <tr style="font-weight:bold">
            <td style="vertical-align:top">
                <ul>
                    <cfif qry_labels.recordcount gt 1>
                    <li>
                        This label is tied 
                        to <em class="clsColorNote">General for All</em> 
                        and <em class="clsColorNote">#qry_co.vaconame#</em>
                        (#gcoids#)
                    </li>
                    </cfif>
					<cfif attributes.labelcostat neq "">
                    <li class="clsColorNote">
                        <cfif attributes.labelstat eq 'C'>
                            NEW LABEL CREATED (Please refresh the application cache once created.)
                        <cfelseif attributes.labelstat eq 'U'>
                            LABEL UPDATED
                        <cfelseif attributes.labelstat eq 'D'>
                            LABEL DELETED
                        <!--- 
                        <cfelseif attributes.labelstat eq 'R'>
                            EXISTING LABEL 
                        <cfelse>
                            NEW LABEL 
                        --->
                        </cfif>
                    </li>
                    <li class="clsColorNote">
                        <cfif attributes.labelcostat eq 'C'>
                            NEW LABEL-COMPANY LINK CREATED
                        <cfelseif attributes.labelcostat eq 'U'>
                            LABEL-COMPANY LINK UPDATED
                        <cfelseif attributes.labelcostat eq 'D'>
                            LABEL-COMPANY LINK DELETED
                        <!--- 
                        <cfelseif attributes.labelcostat eq 'R'>
                            EXISTING LABEL-COMPANY LINK 
                        <cfelse>
                            NEW LABEL-COMPANY LINK
                        --->
                        </cfif>
                    </li>
					</cfif>
                </ul>
            </td>
            <td style="vertical-align:top">
                <ol>
                    <br>TWO(2) Sections
                    <li>Label Definition: FOBJB3020</li>
                    <li>Label-Company Link: FOBJB3022</li>
                </ol>

                <ol>
                    Fill in relevant fields in this form.
                    <br>On submission, system will detect if the label id/ label-co linkage already existed in database.
                    <li>if already exist, will perform record update.</li>
                    <li>if not already exist, will perform record insert.</li>
                </ol>

                <ol>You can search for all existing Labels using the "Select Existing Label" selector.
                    <br>Once selected
                    <li>Label Definition will be populated</li>
                    <li>Label-Company Link will be populated (if label already linked)</li>
                </ol>

                <ol>However, some restriction are applied as below:
                    <li>Create labels (DEV only)</li>
                    <li>Update labels definition (LIVE,TRAIN,UAT: Domain and location will NOT be updated)</li>
                    <li>Create/ Update/ Delete Link (ALL environments)</li>
                </ol>
            </td>
        </tr>
    </tbody>
</table>

<div align=center id="mainpad">
<br>
<form id="labeladdf" method="post" action="#urlf#">
    <input type="button" class="clsButton" onclick="javascript:formsubmit(2)" value="Saves"/>
    <table class="clsClmTable" align="center" width="90%" style="table-layout:fixed" >
        <colgroup>
            <col class="clsClmEstTone1">
            <col class="clsClmEstTone2">
            <col class="clsClmEstTone1">
            <col class="clsClmEstTone2">
        </colgroup>
        <tbody>
            <tr class="header">
                <td colspan=2>Label Definition</td>
                <td colspan=2>
                    <script>
                        function populatelabeldata (a) {
                            var colsequence = [
                                'labelname' ,'labeldesc' ,'theloc' ,'thedom' ,'labelid' ,'deactivatelabel' ,'txcol' ,'bgcol' ,'readers' ,'creators' ,'isprivate' ,'localename' , 'localedesc' ,'tielabelco' ,'theowner' ,'deactivatelabelco' ,'claimtypes' ,'grouporder' ,'selector2','listed'
                            ]
                            //propagate selection from search popup to page
                            var cols = _.object(colsequence,a)
                            adder.theloc            ( cols.theloc.toString())
                            adder.thedom            ( cols.thedom.toString())
                            adder.labelid           ( cols.labelid.toString())
                            adder.deactivatelabel   ( Number(cols.deactivatelabel)==1?true:false)
                            adder.labelname         ( cols.labelname.toString())
                            adder.labeldesc         ( cols.labeldesc.toString())
                            adder.txcol             ( cols.txcol.toString())
                            adder.bgcol             ( cols.bgcol.toString())
                        	adder.localename         ( cols.localename.toString())
                            adder.localedesc         ( cols.localedesc.toString())

                            var readers = Number(cols.readers)
                            adder.readerinverted    ( readers<0?true:false)
                            adder.readers           ( explodeBits(readers<0?(~readers):(readers),{toString:true}))

                            var creators = Number(cols.creators)
                            adder.creatorinverted   ( Number(cols.creators)<0?true:false)
                            adder.creators           ( explodeBits(creators<0?(~creators):(creators),{toString:true}))

                            adder.isprivate         ( Number(cols.isprivate)==1?true:false)
                            adder.tielabelco        ( Number(cols.tielabelco)!=0?true:false)
                            adder.theowner          ( cols.theowner.toString())
                            adder.deactivatelabelco ( Number(cols.deactivatelabelco)==1?true:false)

                            var claimtypes = Number(cols.claimtypes)
                            adder.claimtypeinverted ( claimtypes<0?true:false)
                            adder.claimtypes        ( explodeBits(claimtypes<0?(~claimtypes):(claimtypes),{toString:true}))
                            adder.grouporder        ( cols.grouporder)
                            //adder.readerval         ( cols.readers)
                            //adder.creatorval        ( cols.creators)
                        }
                    </script>

    				<input name=labeldisp id=labeldisp type=hidden tabindex=-1 style=background-color:silver size=40 onblur=DoReq(this)>
    				<input name=labeldata id=labeldata type=hidden>
    				<cfmodule template="#request.logpath#index.cfm" fusebox="SVCobj" fuseaction="dsp_SVCSelector"
    					URL="#request.webroot#index.cfm?fusebox=SVCobj&fuseaction=xml_SVCGetLabeldef&coid=#attributes.coid#&keyword="
    					TYPE="POPUP" 
                        SHOWCHECKBOX="0" 
                        TEXTOBJID="labeldisp" 
                        VALUEOBJID="labeldata" 
                        SRCTEXTFIELD="labeldesc" 
                        SRCVALUEFIELD="labelid"
    					JCALLBACK="populatelabeldata" 
                        BUTTONTEXT="Select Existing Labels"
                        BUTTON_DISABLED=0>
                </td>
            </tr>
            <tr>
                <td>Domain</td>
                <td>
                    <cfif killfields>
                        <span data-bind="html:thedomlong().name"> </span>
                        <input type="hidden" name="thedom" data-bind="value:thedom">
                    <cfelse>                        
                        <select id="thedom" name="thedom" data-bind="options:data.doms,optionsText:'name',optionsValue:'val',value:thedom">
                        </select>
                    </cfif>
                </td>
                <td>Location</td>
                <td> 
                    <cfif killfields>
                        <span data-bind="html:thelocobj().name"> </span>
                        <input type="hidden" name="theloc" data-bind="value:$root.theloc">
                    <cfelse>
                        <div>
                        <!-- ko foreach:loclist -->
                        <label>
                            <input type="radio" name="theloc" data-bind="attr:{value:val},checked:$root.theloc">
                            <span data-bind="html:name"> </span>
                        </label>
                        <br>
                        <!-- /ko -->
                        </div>
                    </cfif>
                </td>
            </tr>
            <tr>
                <td>Label id
                    <style>
                        .isused{ background:darkred ;color:white }
                    </style>
                    <input type="button" class="clsButton" value="Show used Sequence" data-bind="click:toggleSeq">
                    <div class="clsColorNote" data-bind="visible:showSeq">
                        <!-- ko foreach:data.usedseq -->
                        <span data-bind="css:$data===$root.isusedlabelid()?'isused':''">
                        <br><span data-bind="html:ST"> </span>~<span data-bind='html:EN'> </span>
                        </span>
                        <!-- /ko -->
                    </div>
                </td>
                <td>
                    <input type=#killfields?"hidden":"text"# name="labelid" data-bind="value:labelid">
                    <span data-bind="visible:killfields,html:labelid"> </span>
                    <span data-bind="visible:isusedlabelid" class="clsColorNote"><br>Label id is already used! </span>
                    <span data-bind="visible:isusedlabelid" class="clsColorNote"><br>Save will update label </span>
                    <span data-bind="visible:!isusedlabelid()" class="clsColorNote"><br>Save will create label </span>
                </td>
                <td>De-activate?</td>
                <td>
                    <input type="checkbox" name="deactivatelabel" value=1 data-bind="checked:deactivatelabel">
                    <span class="clsColorNote"> De-activate label for <span data-bind="html:thelocobj().name"></span> </span>
                </td>
            </tr>
            <tr>
                <td>Label name</td>
                <td><input type="text" name="labelname" data-bind="value:labelname"></td>
                <td>Label desc</td>
                <td><input type="text" name="labeldesc" data-bind="value:labeldesc" maxlength=316></td>
            </tr>
			<tr>
				<td>Locale name (translated)</td>
                <td><input type="text" name="localename" data-bind="value:localename"></td>
				<td>Locale name desc</td>
                <td><input type="text" name="localedesc" data-bind="value:localedesc"></td>
			</tr>
            <tr>
                <td rowspan=2>Sample label</td>
                <td rowspan=2><span data-bind="style:{color:'##'+txcol(),background:'##'+bgcol()},html:'&nbsp;'+labelname()+'&nbsp;'"></span></td>
                <td>Text colour</td>
                <td><input type="text" name="txcol" data-bind="value:txcol"></td>
            </tr>
            <tr>
                <td>Background colour</td>
                <td><input type="text" name="bgcol" data-bind="value:bgcol"></td>
            <tr>
            <tr>
                <td>Creator
                    <br><span>[value:<span data-bind="html:creatorval"> </span>]</span>
                    <br><input type="hidden" name="creatorval" data-bind="value:creatorval">
                </td>
                <td colspan=3>
                    <input type="button" class="clsButton" data-bind="attr:{value:creatorinverted()?'Select all EXCEPT below:':'Select all below:'},click:invertcreator">
                    <br>
                    <!-- ko foreach:theroles -->
                    <div style="float:left;width:24em">
                    <label>
                        <input type="checkbox" name="creators" data-bind="attr:{value:val},checked:$root.creators">
                        <span data-bind="html:'['+code+'] '+name"> </span>
                    </label>
                    </div>
                    <!-- /ko -->
                </td>
            </tr>
            <tr>
                <td>Reader
                    <br><span>[value:<span data-bind="html:readerval"> </span>]</span>
                    <br><input type="hidden" name="readerval" data-bind="value:readerval">
                </td>
                <td colspan=3>
                    <input type="button" class="clsButton" data-bind="attr:{value:readerinverted()?'Select all EXCEPT below:':'Select all below:'},click:invertreader">
                    <br>
                    <!-- ko foreach:theroles -->
                    <div style="float:left;width:24em">
                    <label>
                        <input type="checkbox" name="readers" data-bind="attr:{value:val},checked:$root.readers">
                        <span data-bind="html:'['+code+'] '+name"> </span>
                    </label>
                    </div>
                    <!-- /ko -->
                </td>
            </tr>
            <tr>
                <td>Is private?</td>
                <td><input type="checkbox" name="isprivate" value="1" data-bind="checked:isprivate"></td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
            </tr>
            <tr>
                <td>TSQL</td>
                <td colspan=3>
                    <code>
                        IF NOT EXISTS (SELECT 1 FROM FOBJB3020 WITH (NOLOCK) WHERE ILBLDEFID=<span data-bind="html:labelid"></span>)<br>
                        BEGIN<br>
                            #custom_tab#INSERT INTO FOBJB3020 (ILBLDEFID, IDOMAINID, ILOCID, SIPRIVATE, BCOCREATE, BCOREAD, ICOLORTXT, ICOLORBGRND, VALBLNAME, VALBLDESC, ICRTBY, DTCRTON, SISTATUS, vaLBLNAME_LOCALLANG, vaLBLDESC_LOCALLANG)<br>
                            #custom_tab#VALUES (<span data-bind="html:TSQLtext"></span>)<br>
                        END<br>
                        GO
                    </code>
                </td>
            </tr>
        </tbody>
    </table>
    <br><br>
    <table class="clsClmTable" align="center" width="90%" style="table-layout:fixed" >
        <colgroup>
            <col class="clsClmEstTone1">
            <col class="clsClmEstTone2">
            <col class="clsClmEstTone1">
            <col class="clsClmEstTone2">
        </colgroup>
        <tbody>
            <tr class="header">
                <td colspan=2>Label-Company Linkage</td>
                <td colspan=2>
                    <input type="checkbox" value='1' name="tieco" data-bind="checked:tielabelco">
                    Include Label into <span data-bind="html:theownerobj().name"></span>
                    <br>
                    <span class="clsColorNote">Note: Uncheck to remove link from <span data-bind="html:theownerobj().name"></span></span>
                </td>
            </tr>
            <tr>
                <td>Owner</td>
                <td> <!-- ko foreach:ownerlist -->
                    <label>
                        <input type="radio" name="owner" data-bind="attr:{value:val},checked:$root.theowner">
                        <span data-bind="html:name"> </span>
                    </label>
                    <br>
                    <!-- /ko -->
                </td>
                <td>De-activate</td>
                <td><input type="checkbox" value="1" name="deactivate" data-bind="checked:deactivatelabelco">
                    <span class="clsColorNote"> De-activate label for <span data-bind="html:theownerobj().name"></span> </span>
                </td>
            </tr>
            <tr>
                <td>Claim type 
                    <br><span>[value:<span data-bind="html:claimtypeval"> </span>]</span>
                    <br><input type="hidden" name="claimtypeval" data-bind="value:claimtypeval">
                </td>
                <td colspan=3>
                <input type="button" class="clsButton" data-bind="attr:{value:claimtypeinverted()?'Select all EXCEPT below:':'Select all below:'},click:invertClaimtype">
                <div data-bind="foreach:data.claimtypes">
                    <div style="float:left;width:12em">
                        <label>
                            <input type="checkbox" data-bind="attr:{value:val},checked:$root.claimtypes">
                            <span data-bind="html:code"> </span>
                        </label>
                    </div>
                </div>
                </td>
            </tr>
            <tr>
                <td>Group Order</td>
                <td><input type="text" name="grouporder" data-bind="value:grouporder"></td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
            </tr>
            <tr>
                <td>TSQL</td>
                <td colspan="3">
                    <code>
                        IF NOT EXISTS (SELECT 1 FROM FOBJB3022 WITH (NOLOCK) WHERE iLBLDEFID=<span data-bind="html:labelid"></span> AND IGCOID=<span data-bind="html:theowner"></span>)<br>
                        BEGIN<br>
                            #custom_tab#INSERT INTO FOBJB3022 (iLBLDEFID, iGCOID, iCRTBY, dtCRTON, siSTATUS, iGROUPPRIORITY, iSELECTOR, vaSELECTOR)<br>
                            #custom_tab#VALUES (<span data-bind="html:TSQLtext2"></span>)<br>
                        END<br>
                        GO
                    <code>
                </td>
            </tr>
        </tbody>
    </table>
    <br> <br>
    <cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkguid.cfm" START>
</form>
</div>

<script>
    var ds = {
        usedseq: jsonify(#serializeJSON(qry_islands)#)
        ,countries: [{name:'All'     ,code:'All'} 
                ,{name:'Malaysia'     ,code:'MYR'} 
                ,{name:'Singapore'    ,code:'SGD'} 
                ,{name:'Brunei'       ,code:'BND'} 
                ,{name:'India'        ,code:'INR'} 
                ,{name:'Motorbiz'     ,code:'MYR'} 
                ,{name:'Pakistan'     ,code:'PAK'} 
                ,{name:'Indonesia'    ,code:'IDR'} 
                ,{name:'Algeria'      ,code:'DZD'} 
                ,{name:'UAE'          ,code:'AED'} 
                ,{name:'Philippines'  ,code:'PHP'} 
                ,{name:'Thailand'     ,code:'THB'} 
                ,{name:'China'        ,code:'CNY'} 
                ,{name:'Saudi'        ,code:'SAR'} 
                ,{name:'Hong Kong'    ,code:'HK' } 
                ,{name:'Vietnam'      ,code:'VN' } 
                ]
        ,doms: 
            [{val:1,	name:'Claims Subfolder'}
            ,{val:2	,name:'eTender'}
            ,{val:5	,name:'Repair Card'}
            ,{val:6	,name:'ESource Order'}
            ,{val:7	,name:'Accident Reporting'}
            ,{val:8	,name:'NCD Policy'}
            ,{val:9	,name:'Claims Notification'}
            ,{val:10	,name:'Company'}
            ,{val:11	,name:'User'}
            ,{val:12	,name:'Merimen Mail'}
            ,{val:13	,name:'Arbitration Case'}
            ,{val:14	,name:'Merimen Mail (Inbox)'}
            ,{val:15	,name:'Policy Record Table BIZ_POL'}
            ,{val:17	,name:'External Mail'}
            ,{val:20	,name:'Repair Card Reminder Letter'}
            ,{val:901	,name:'Storage Item'}
            <!---  
            ,{val:22	,name:'Topup'}
            ,{val:23	,name:'Adjustment'}
            ,{val:30	,name:'Framework: Account'}
            ,{val:31	,name:'Framework: Customer'}
            ,{val:32	,name:'Framework: Task'}
            ,{val:33	,name:'Framework: User Group'}
            ,{val:34	,name:'Framework: Payment'}
            ,{val:35	,name:'Framework: Integration'}
            ,{val:40	,name:'Client Person'}
            ,{val:50	,name:'DMS'}
            ,{val:51	,name:'Vehicle Type'}
            ,{val:52	,name:'Colour of Vehicle'}
            ,{val:100	,name:'Company Profile'}
            ,{val:101	,name:'Edit Policy Class'}
            ,{val:102	,name:'Insurer Claim Subfolder'}
            ,{val:103	,name:'IFE Claim'}
            ,{val:104	,name:'IFE Incident'}
            ,{val:105	,name:'IFE Task'}
            ,{val:106	,name:'Policy Class Level 1'}
            ,{val:107	,name:'Policy Class Level 2'}
            ,{val:108	,name:'Policy Class Level 3'}
            ,{val:201	,name:'IC21 Policy'}
            ,{val:202	,name:'IC21 Claim'}
            ,{val:203	,name:'IC21 Product'}
            ,{val:204	,name:'EPL Manual Renewal'}
            ,{val:205	,name:'SAS Solicitor'}
            ,{val:206	,name:'SAS Solicitor Sub'}
            ,{val:207	,name:'Pay Services'}
            ,{val:208	,name:'Pay Services Batch'}
            ,{val:301	,name:'Framework: Table Management'}
            ,{val:302	,name:'Framework: Dynamic Report'}
            ,{val:400	,name:'PARS: Workshop Profile'}
            ,{val:401	,name:'PARS: Main Flow'}
            ,{val:402	,name:'PARS: E-Balloting'}
            ,{val:403	,name:'PARS: Quarter'}
            ,{val:500	,name:'Panel Management'}
            --->                  
            ]
        ,roles: 
            [{domain:1	,val:1	    ,code:'R'   	,name:"Repairer"}
            ,{domain:1	,val:2	    ,code:'I'   	,name:"Handling Insurer"}
            ,{domain:1	,val:4	    ,code:'A'   	,name:"Adjuster"}
            ,{domain:1	,val:8	    ,code:'TP'  	,name:"KFK Insurer"}
            ,{domain:1	,val:16	    ,code:'C'   	,name:"Client Agent"}
            ,{domain:1	,val:32	    ,code:'S'   	,name:"Supplier"}
            ,{domain:1	,val:64	    ,code:'G'   	,name:"Insurer Agent"}
            ,{domain:1	,val:128	,code:'GR'  	,name:"Recovery Agent (Salvage)"}
            ,{domain:1	,val:256	,code:'LC'  	,name:"Claimant's Solicitor"}
            ,{domain:1	,val:512	,code:'LI'  	,name:"Insurer's Solicitor"}
            ,{domain:1	,val:1024	,code:'EA'  	,name:"External Administrator"}
            ,{domain:1	,val:2048	,code:'RC'  	,name:"Recovery Agent (Claims)"}
            ,{domain:1	,val:4096	,code:'CC'  	,name:"Corporate Client"}
            ,{domain:1	,val:8192	,code:'AB'  	,name:"Arbitrator"}
            ,{domain:2	,val:1	    ,code:'R'   	,name:"Tenderers"}
            ,{domain:2	,val:2	    ,code:'I'   	,name:"Insurer"}
            ,{domain:2	,val:4	    ,code:'A'   	,name:"Adjuster"}
            ,{domain:2	,val:8	    ,code:'O'   	,name:"Orig. Workshop"}
            ,{domain:5	,val:1	    ,code:'R'   	,name:"Repairer"}
            ,{domain:5	,val:2	    ,code:'I'   	,name:"Insurer"}
            ,{domain:6	,val:1	    ,code:'B'   	,name:"Buyer"}
            ,{domain:6	,val:2	    ,code:'S'   	,name:"Supplier"}
            ,{domain:6	,val:4	    ,code:'R'   	,name:"Receiver"}
            ,{domain:7	,val:1	    ,code:'R'   	,name:"Creator"}
            ,{domain:7	,val:2	    ,code:'I'   	,name:"Insurer"}
            ,{domain:7	,val:4	    ,code:'A'   	,name:"Adjuster"}
            ,{domain:7	,val:8	    ,code:'TP'      ,name:"TP Insurer"}
            ,{domain:7	,val:16	    ,code:'G'   	,name:"GIA"}
            ,{domain:7	,val:32	    ,code:'EC'      ,name:"EClaims User"}
            ,{domain:7	,val:64	    ,code:'PC'      ,name:"Report Buyer"}
            ,{domain:9	,val:1	    ,code:'AC'      ,name:"Agency Call Centre"}
            ,{domain:9	,val:2	    ,code:'I'   	,name:"Handling Insurer"}
            ,{domain:9	,val:64	    ,code:'G'   	,name:"Insurer Agent/Broker"}
            ,{domain:9	,val:4096	,code:'CC'      ,name:"Corporate/Retail Client"}
            ,{domain:10	,val:1	    ,code:'C'   	,name:"Company"}
            ,{domain:12	,val:1	    ,code:'S'   	,name:"Mail Sender"}
            ,{domain:12	,val:2	    ,code:'R'   	,name:"Mail Receiver"}
            ,{domain:13	,val:16	    ,code:'A'   	,name:"Arbitrator"}
            ,{domain:14	,val:1	    ,code:'R'   	,name:"Mail Receiver"}
            ,{domain:17	,val:1	    ,code:'S'   	,name:"Mail Sender"}
            ,{domain:17	,val:2	    ,code:'R'   	,name:"Mail Receiver"}
            ]  
        ,claimtypes:
            [ {code:'LU'     , val:262144}
            , {code:'NM'     , val:8192}
            , {code:'NM ENG' , val:8388608}
            , {code:'NM EXW' , val:67108864}
            , {code:'NM FR'  , val:131072}
            , {code:'NM HS'  , val:524288}
            , {code:'NM LB'  , val:16777216}
            , {code:'NM MC'  , val:2097152}
            , {code:'NM MH'  , val:4194304}
            , {code:'NM MSC' , val:268435456}
            , {code:'NM PA'  , val:32768}
            , {code:'NM RP'  , val:134217728}
            , {code:'NM TR'  , val:33554432}
            , {code:'NM WC'  , val:1048576}
            , {code:'OD'     , val:1}
            , {code:'OD BI'  , val:16384}
            , {code:'EXW'    , val:512}
            , {code:'GRG'    , val:128}
            , {code:'OD KFK' , val:8}
            , {code:'MNT'    , val:64}
            , {code:'OD TAC' , val:256}
            , {code:'OD TFR' , val:32}
            , {code:'SC'     , val:65536}
            , {code:'TF'     , val:16}
            , {code:'TP'     , val:2}
            , {code:'TP BI'  , val:4096}
            , {code:'TP KFK' , val:536870912}
            , {code:'TP PD'  , val:2048}
            , {code:'TP SB'  , val:1073741824}
            , {code:'TP UL'  , val:1024}
            , {code:'WS'     , val:4}
            ]
    }

    function Adder (data,preset) {
        var self = this;
        this.data = data;
        this._preset = preset||{};
        this.showSeq= ko.observable(false)
        this.toggleSeq = function(m,e){
            var curr = self.showSeq()
            self.showSeq(!curr)
        }
        //first table
        this.loclist = [
            {name:'General for All',val:'0'}
            ,{name:'#locale.locshortcode#',val:'#locid#'}
        ]
        this.killfields = #killfields?'true':'false'#
        this.theloc = ko.observable(self._preset.theloc)
        this.thelocobj = ko.computed(function(){
            return _.find(self.loclist,function(item,pointer,list){ return item.val==Number( self.theloc() )})
        })
        this.thedom = ko.observable(self._preset.thedom)
        this.thedomlong = ko.computed(function(){
            return _.find(self.data.doms,function(item,pointer,list){ return item.val==Number( self.thedom() ) })
        })
        this.labelid = ko.observable(self._preset.labelid)
        this.isusedlabelid = ko.computed(function(){
            var curr = self.labelid()
            return _.find(data.usedseq,function(item,pointer,list){ return curr>=item.ST && curr<=item.EN }) 
        })
        this.deactivatelabel = ko.observable(self._preset.deactivatelabel)
        this.labelname = ko.observable(self._preset.labelname)
		this.localename = ko.observable(self._preset.localename)
        this.labeldesc = ko.observable(self._preset.labeldesc)
		this.localedesc = ko.observable(self._preset.localedesc)
        this.txcol = ko.observable(self._preset.txcol)
        this.bgcol = ko.observable(self._preset.bgcol)
        this.theroles = ko.computed(function(){
            return _.filter(self.data.roles,function(item,pointer,list){ return item.domain == Number(self.thedom())})
        })

        this.readerinverted = ko.observable(self._preset.readerinverted)
        this.readers = ko.observableArray(self._preset.readers)
        this.readerval = ko.computed(function(){
            var theval = _.reduce(self.readers(),function(memo,item,pointer,list){ return memo+Number(item) },0)
            return self.readerinverted()? (~theval):(theval)
        })
        this.invertreader = function (m,e){
            var curr = self.readerinverted()
            self.readerinverted( !curr )
        }
        this.creatorinverted = ko.observable(self._preset.creatorinverted)
        this.creators = ko.observableArray(self._preset.creators)
        this.creatorval = ko.computed(function(){
            var theval = _.reduce(self.creators(),function(memo,item,pointer,list){ return memo+Number(item) },0)
            return self.creatorinverted()? (~theval):(theval)
        })
        this.invertcreator = function (m,e){
            var curr = self.creatorinverted()
            self.creatorinverted( !curr )
        }
        this.isprivate = ko.observable(self._preset.isprivate)

        //second table
        this.tielabelco = ko.observable(self._preset.tielabelco)
        this.editowner = ko.observable(false)
        this.ownerlist = [
             {name:'General for All',val:'0'}
            ,{name:'#qry_co.vaconame#',val:'#qry_co.icoid#'}
        ];
        this.theowner     = ko.observable(self._preset.theowner);
        this.theownerobj = ko.computed(function(){
            return _.find(self.ownerlist,function(item,pointer,list){ return Number(item.val) == Number( self.theowner() )})
        })
        this.deactivatelabelco = ko.observable(self._preset.deactivatelabelco);
        this.claimtypeinverted = ko.observable(self._preset.claimtypeinverted); 
        this.claimtypes   = ko.observableArray(self._preset.claimtypes);
        this.claimtypeval = ko.computed(function () {
            var theval = _.reduce(self.claimtypes(),function(memo,item,pointer,list){ return memo+Number(item) },0)
            return self.claimtypeinverted()? (~theval):(theval)
        })
        this.invertClaimtype = function (m,e){
            var curr = self.claimtypeinverted()
            self.claimtypeinverted( !curr )
        }
        this.grouporder   = ko.observable(self._preset.grouporder)
        this.TSQLtext2 = ko.computed(function(){
            return [
                self.labelid()
                ,self.theowner()
                ,1
                <!--- ,"'"+"#dateformat(now(),'yyyy-mm-dd')#"+"'" --->
                ,'GETDATE()'
                ,0
                ,self.grouporder()
                ,self.claimtypeval()
                ,'NULL'
            ].join(',')
        })
        this.TSQLtext = ko.computed(function(){
            return [
                self.labelid()
                ,self.thedom()
                ,self.theloc()
                ,self.isprivate()?'1':'0'
                ,self.creatorval()
                ,self.readerval()
                ,"'"+self.txcol()+"'"
                ,"'"+self.bgcol()+"'"
                ,"'"+self.labelname()+"'"
                ,"'"+self.labeldesc()+"'"
                ,1
                <!--- ,"'"+"#dateformat(now(),'yyyy-mm-dd')#"+"'" --->
                ,"GETDATE()"
                ,self.deactivatelabel()?'1':'0'
				,"N'"+self.localename()+"'"
				,"N'"+self.localedesc()+"'"
            ].join(',')
        })
    }

    <cfif qry_label.recordcount gt 0>
        <cfset readerval = qry_label.BCOREAD lt 0?BitNot(qry_label.BCOREAD):qry_label.BCOREAD>
        <cfset creatorval = qry_label.BCOcreate lt 0?BitNot(qry_label.BCOcreate):qry_label.BCOcreate>
        <cfset claimtypeval = qry_label.iSELECTOR lt 0?BitNot(qry_label.iSELECTOR):qry_label.iSELECTOR>

        var preset = {
            theloc:'#qry_label.ILOCID#'
            ,thedom:'#qry_label.IDOMAINID#'
            ,labelid:'#qry_label.ILBLDEFID#'
            ,deactivatelabel:#qry_label.SISTATUS eq 1?'true':'false'#
            ,labelname:'#qry_label.VALBLNAME#'
    		,localename:'#qry_label.vaLBLNAME_LOCALLANG#'
            ,labeldesc:'#qry_label.VALBLDESC#'
    		,localedesc:'#qry_label.vaLBLDESC_LOCALLANG#'
            ,txcol:'#qry_label.ICOLORTXT#'
            ,bgcol:'#qry_label.ICOLORBGRND#'
            ,readerinverted:#qry_label.BCOREAD lt 0?'true':'false'#
            ,readers:explodeBits(#readerval#,{toString:true})
            ,readerval:'#readerval#'
            ,creatorinverted:#qry_label.BCOCREATE lt 0?'true':'false'#
            ,creators:explodeBits(#creatorval#,{toString:true})
            ,creatorval:'#creatorval#'
            ,isprivate:#qry_label.siprivate eq 1?'true':'false'# 

            ,tielabelco:#qry_label.tielabelco neq ''?'true':'false'#
            ,theowner:'#qry_label.igcoid#'
            ,deactivatelabelco:#qry_label.DEACTIVATELABELCO eq 1?'true':'false'#
            ,claimtypeinverted:#qry_label.iSELECTOR lt 0?'true':'false'#
            ,claimtypes: explodeBits(#claimtypeval#,{toString:true})
            ,claimtypeval:'#claimtypeval#'
            ,grouporder:'#qry_label.iGROUPPRIORITY#'
        }
    <cfelse>
        var preset = {
        	<cfif attributes.coid eq 700469>
    		<cfquery name=q_getmax datasource=#request.mtrdsn#>select useid=max(ilbldefid)+1 from fobjb3020 with (nolock) where ilbldefid<=10000</cfquery>
            theloc:'7'
            ,thedom:'1'
            ,labelid:'#q_getmax.useid#'
            ,deactivatelabel:false
            ,labelname:'SS - '
    		,localename:''
            ,labeldesc:'ACA Label - SS '
    		,localedesc:''
            ,txcol:'FFFFFF'
            ,bgcol:'191970'
            ,readerinverted:false
            ,readers:explodeBits(2,{toString:true})
            ,readerval:'0'
            ,creatorinverted:false
            ,creators:explodeBits(2,{toString:true})
            ,creatorval:'0'
            ,isprivate:true
            ,tielabelco:true
            ,theowner:'700469'
            ,deactivatelabelco:false
            ,claimtypeinverted:true
            ,claimtypes: explodeBits(0,{toString:true})
            ,claimtypeval:'0'
            ,grouporder:''		
        	<cfelse>
            theloc:'0'
            ,thedom:'1'
            ,labelid:'-1'
            ,deactivatelabel:false
            ,labelname:'label name'
    		,localename:'locale name'
            ,labeldesc:'label desc'
    		,localedesc:'locale name desc'
            ,txcol:'FF0000'
            ,bgcol:'00FFFF'
            ,readerinverted:false
            ,readers:explodeBits(0,{toString:true})
            ,readerval:'0'
            ,creatorinverted:false
            ,creators:explodeBits(0,{toString:true})
            ,creatorval:'0'
            ,isprivate:false

            ,tielabelco:false
            ,theowner:'0'
            ,deactivatelabelco:false
            ,claimtypeinverted:false
            ,claimtypes: explodeBits(0,{toString:true})
            ,claimtypeval:'0'
            ,grouporder:'0'
            </cfif>
        }
    </cfif>
    
    var adder = new Adder(ds,preset)
    ko.applyBindings(adder,document.getElementById('mainpad'))
</script>
</cfoutput> 

<br>