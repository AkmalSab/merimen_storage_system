<CFOUTPUT>
<style>
/*body {
background: url(#request.webroot#MSupport/logo/TMGBG.png) no-repeat;
background-repeat: no-repeat;
background-attachment: fixed;
background-position: right bottom;
/*background-size: 650px 500px;*/
/*background-position: right 0px top 530px;*/
/*height :950px;*/
/*}*/

.watermark {
    position: fixed;
    z-index: -1;
    background: url(#request.webroot#MSupport/logo/TMGBG-IE.jpg);
    right: 0;
    bottom: 0;
    width: 586px;
    height: 567px;
    opacity: 0.5;
}

/*.footer {
position: absolute;
top:900px;
}

.header {
position: absolute;
}*/
@font-face {
    font-family: NewJune;
    src: url(#request.webroot#MSupport/font/NewJune-Regular.otf);
}


body, table td {

	font-family:Trebuchet MS;

}

.NewJune {

font-family:NewJune;

}
</style>
<!--PDFWATERMARK src="#request.webroot#MSupport/logo/TMGBGPDF.png" position="0,0" opacity="10" showonprint="yes" -->
</CFOUTPUT>