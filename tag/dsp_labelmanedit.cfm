<cfmodule template="#request.apppath#services/CustomTags\SVCDisableDirect.cfm" Path="#GetCurrentTemplatePath()#"> 
<cfset request.cfc.labels = createObject("component","#application.svcpath#cfc/labels")>
<cfset request.cfc.labels.init(request.mtrdsn)>
<cfparam name="attributes.updated" default="0">

<cfquery name="qry_co" datasource="#request.mtrdsn#">
    select icoid,ilocid,igcoid,vaconame from sec0005 where icoid = <cfqueryparam value="#attributes.coid#" CFSQLType = "cf_sql_integer" null="no">
</cfquery>

<cfset labels = request.cfc.labels.getcolabels(gcoid=qry_co.igcoid,loc=qry_co.ilocid)> 

<cfset urlback="#request.webroot#index.cfm?fusebox=MTRadmin&fuseaction=dsp_coprofile&coid=#attributes.coid#&#Request.MToken#">
<cfset urladdlabel="#request.webroot#index.cfm?fusebox=MTRadmin&fuseaction=dsp_labelmanadd&coid=#attributes.coid#&#Request.MToken#">
<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCADDFILE.cfm" FNAME="underscore"> 
<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCADDFILE.cfm" FNAME="underscore-mrm"> 
<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCADDFILE.cfm" FNAME="ko"> 
<cfmodule TEMPLATE="#request.apppath#services/CustomTags/SVCADDFILE.cfm" FNAME="ko-mrm"> 

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
<h3 class=clsColorNote align=center>#Server.SVClang("View Labels",27078)#</h3>
<script>
    function refresher(){
        var f = JSVCall('frefresh')
        f.submit()
    }
    // GenerateMenubar("ClaimMenu",90,true);
    // AddToMenubar("ClaimMenu","<< " + JSVClang("Back (Co-Profile)",27033),"#urlback#");
    // AddToMenubar("ClaimMenu",JSVClang("Refresh Label",27079),"javascript:refresher()");
    // AddToMenubar("ClaimMenu",JSVClang("Add Label",27080) + " >>","#urladdlabel#");
    // AddOnloadCode("MrmPreprocessForm();");
</script>
<br>
<cfmodule TEMPLATE="#Request.LOGPATH#CustomTags\URLBACK.cfm" new>
<cfset theurl = '#request.webroot#index.cfm?fusebox=MTRadmin&fuseaction=act_labelmanedit&#newurlback#&#request.mtoken#'>
<form method="post" action="#theurl#" id="frefresh" name="frefresh">
    <cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCchkguid.cfm" START>
</form>
<div align=center id="mainpad">
    <cfif attributes.updated gt 0>
        <blockquote class="clsColorNote"> 
        <br>
            Label cache has been refreshed <br>
        <br>
        </blockquote>
    </cfif>
    <table class="clsClmTable" align="center" width="90%" style="table-layout:fixed" >
        <colgroup>
            <col class="clsClmEstTone1">
            <col class="clsClmEstTone2">
            <col class="clsClmEstTone1">
            <col class="clsClmEstTone2">
        </colgroup>
        <tbody>
        <tr>
            <td colspan=4 class="header">Filter by</td>
        </tr>
        <tr>
            <td style="width:25%">Label Ownership</td>
            <td style="width:25%"><label> <input type="checkbox" value="0" data-bind="checked:filtOwnership"> All </label>
                <br> <label> <input type="checkbox" value="#qry_co.icoid#" data-bind="checked:filtOwnership"> #qry_co.vaconame# </label>
            </td>
            <td style="width:25%">Is Active ONLY?</td>
            <td style="width:25%"><input type="checkbox" value=1 data-bind="checked:filtIsActive"></td>
        </tr>
<!--- 
todo: fuzzy search capability
--->
        <tr>
            <td>Label Name</td>
            <td><input type="text" data-bind="value:filtName"></td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td>Claim Type (Strictly AND)</td>
            <td colspan=3>
                <div data-bind="foreach:data.claimtypes">
                    <div style="float:left;width:12em"> <label> 
                        <input name="claimtype" type="checkbox" data-bind="attr:{value:val},checked:$root.filtCtypeArr"><span data-bind="html:code"></span> 
                    </label></div>
                </div>
            </td>
        </tr>
        </tbody>
    </table>
    <div align=left style=width:90%;margin:auto>
    <br> <br>
    <table class="clsClmTable" align="center">
        <thead class="clsColumnHeader">
        <tr>
            <th><span>No.</span></th>
            <th><span>Locale</span></th>
            <th><span>Domain</span></th>
            <th><span>Company</span></th>
            <th><span>Label Name</span></th>
			<th><span>Locale Name</span></th>
            <th><span>Label Desc</span></th>
            <th><span>Claim Type</span></th>
            <th><span>Creator</span></th>
            <th><span>Reader</span></th>
            <th><span>Is Private?</span></th>
            <th><span>Is Active?</span></th>
        </tr>
        </thead>
        <tbody data-bind="foreach:colabels">
            <tr>
                <td> <span data-bind="html:$index()+1"></span></td>
                <td> <span data-bind="html:$root.country(LOC).code,style:{margin:LOC>0?'3em':'0em'}"></span></td>
                <td> <span data-bind="html:$root.dname(DOMAIN).name"></span></td>
                <td> <span data-bind="html:$root.cname(COMPANY),style:{margin:COMPANY>0?'3em':'0em'}"></span></td>
                <td> <a data-bind="attr:{href:$root.seturl(LABEL_ID,COMPANY)}">
                    <span data-bind="html:LABEL_NAME,style:{color:'##'+TXTCOLOR,background:'##'+BGCOLOR}"></span>
                    </a>
                </td>
				<td> <span data-bind="html:LOCALE_NAME"></span></td>
                <td> <span data-bind="html:LABEL_DESC"></span></td>
                <td> <span data-bind="html:$root.claimtype(CLMTYPE)"></span></td>
                <td> <span data-bind="html:$root.role(DOMAIN,CREATOR)"></span></td>
                <td> <span data-bind="html:$root.role(DOMAIN,READER)"></span></td>
                <td> <span data-bind="html:Number(ISPRIVATE)==1?'Private':''"></span></td>
                <td> <span data-bind="html:Number(ISACTIVE)==0?'Active':''"></span></td>
            </tr>
        </tbody>
    </table>
    <br> <br>

    </div>
</div>

<script>
    var ds = {
        raw_colabels: #serializeJSON(labels)#
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
            , {code:'EXW'    , val:512}
            , {code:'GRG'    , val:128}
            , {code:'OD KFK' , val:8}
            , {code:'MNT'    , val:64}
            , {code:'OD TAC' , val:256}
            , {code:'OD TFR' , val:32}
            , {code:'OD WS'  , val:16384}
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

    function Labels (data) {
        var self = this
        this.data = data
        this.seturl = function(labelid,gcoid){
            return request.webroot+'index.cfm?fusebox=MTRadmin&fuseaction=dsp_labelmanadd&coid=#attributes.coid#&labelcoid='+gcoid+'&labelid='+labelid+'&'+request.mtoken
        }
        this.filtName = ko.observable('')
        this.filtOwnership = ko.observableArray(['0','#qry_co.icoid#'])
        this.filtIsActive = ko.observable('')
        this.filtCtypeArr = ko.observableArray([]);
        this.filtCtypeVal = ko.computed(function(){
            return _.reduce( self.filtCtypeArr(), function(memo,item,pointer,list){return memo|Number(item)} ,0)
        });
        this.colabelsAll = ko.observableArray(jsonify(self.data.raw_colabels))
        this.colabels = ko.computed(function(){
            var temp = self.colabelsAll()
            temp = _.filter( self.colabelsAll(), function(item){ 
                var claimtypes = self.filtCtypeVal()
                var owners = self.filtOwnership()
                var activeonly = self.filtIsActive()
                var thename = self.filtName()

                var flag = (claimtypes>0? (item.CLMTYPE&claimtypes)==claimtypes :true)
                        && (owners.length>0? owners.indexOf(item.COMPANY.toString())>-1 :true)
                        && (activeonly? item.ISACTIVE==0 :true)
                        && (thename.length>0? new RegExp(thename,'i').test(item.LABEL_NAME) :true)
                return flag  
            })
            return temp
        })

        // this is hardcoded since there're not many coutries supported 
        this.cname = function (code) {
            return Number(code)==0?'All':code
        }
        this.country = function (idx) {
            return self.data.countries[Number(idx)]
        }
        this.dname = function (val) {
            return _.find(self.data.doms, function(item){ return item.val == Number(val); });
        }
        this.role = function (domain,roleval) {
            if(Number(roleval) == 0) return 'None'
            var temp = _.filter(self.data.roles, function(item){ return Number(domain)==item.domain && ( Number(roleval)&item.val )>0 });
            return _.pluck(temp,'code')
        }
        this.claimtype = function (val) {
            if (Number(val) == -1) return 'All'
            var temp = _.filter(self.data.claimtypes, function(item){ return ( Number(val)&item.val )>0; });
            return _.pluck(temp,'code')
        }
    }
    var l = new Labels(ds)
    ko.applyBindings(l,document.getElementById('mainpad'))

</script>
</cfoutput>  
