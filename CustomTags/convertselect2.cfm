<cfparam NAME=Attributes.FILENAME DEFAULT="">
<cfparam NAME=Attributes.LOCID    DEFAULT="">
<cfparam NAME=Attributes.INSGCOID DEFAULT="">
<cfparam NAME=Attributes.ORGTYPE  DEFAULT="">

<CFIF Attributes.FILENAME NEQ "">
  <cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCADDFILE.cfm" FNAME="SVCDOC">
  <cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCADDFILE.cfm" FNAME="JQuery_Select2_v4">
  <cfmodule TEMPLATE="#request.apppath#services/CustomTags\SVCADDFILE.cfm" FNAME="JQuery_Select2_CSS_Simple_v4">
  <script>
  <CFIF Attributes.FILENAME IS "dsp_estmain">
      var excludeARR    = ['sleORICOMPADJHRS','sleORICOMPADJMINS'];
      var reqARR        = ['ddlbDCountry','ddlbDState','ddlbDCity','ddlbACCOUNTRYID','ddlbLossState','ddlbLOSSCITY','ddlbCLMState','ddlbCLMCity','ddlbLOSSSUBDISTRICT','ddlbLocClaim'];
      var convertSelect = JSVCGetALLAttributeByTagNameARR('select','id',5,excludeARR,reqARR);
  <CFELSEIF Attributes.FILENAME IS "dsp_clmdtls">
      var convertSelect = ['ddlbLossState','ddlbLOSSCITY','ddlbIState','ddlbICity','ddlbDState','ddlbDCity','ddlbCLMState','ddlbCLMCity'];
  <CFELSEIF Attributes.FILENAME IS "dsp_clmcreationTH">
      var convertSelect = ['iREGNO_STATEID','ddlbLossState','ddlbLOSSCITY','ddlbIState','ddlbICity','ddlbDState','ddlbDCity','ddlbCLMState','ddlbCLMCity'];
  <CFELSEIF Attributes.FILENAME IS "dsp_adddirectpay">
      var convertSelect = ['sleBANKCOID','sleBANKBR'];
  </CFIF>
  if(convertSelect.length!=0){AddOnloadCode("initSelect2(convertSelect);")};
  </script>
</CFIF>