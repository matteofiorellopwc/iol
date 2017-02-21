public with sharing class ViewMultiReport {

    public String url1 {get;set;}
    public String url2 {get;set;}

    public String body1 {get;set;}
    public String body2 {get;set;}   
    
    String htmlTable1 = '<table class="reportTable tabularReportTable" border="0" cellspacing="0" cellpadding="0">';
    String htmlTable2 = '<table cellspacing="0" cellpadding="0" border="0" class="reportTable matrixReportTable">';
    
    public String localeKey {get{ return UserInfo.getLocale(); }set;} 

    public ViewMultiReport(){
        url1 = '';
        url2 = '';

        string id1 = apexpages.currentpage().getparameters().get('rep1');
        if(id1 != null){
            url1 = '/'+id1+'?isdtp=nv';
        }
        
        string id2 = apexpages.currentpage().getparameters().get('rep2');
        if(id2 != null){
            url2 = '/'+id2+'?isdtp=nv';
        }
    }

    public PageReference getReportContent() {
        
        PageReference pdfPage = new PageReference(url1);
        Blob b = null;
        if(!Test.isRunningTest()){
            b = pdfPage.getContent();
        }else{
            b = Blob.valueof('<div class="reportOutput">aaaaaaa</div>');
        }
        body1 = b.toString();

        if(body1.indexOf(htmlTable1) > 0){
            body1 = body1.substring(body1.indexOf(htmlTable1));
            body1 = body1.substring(0,body1.indexOf('</table>')+8);        
        }else if(body1.indexOf(htmlTable2) > 0){
            body1 = body1.substring(body1.indexOf(htmlTable2));
            body1 = body1.substring(0,body1.indexOf('</table>')+8);        
        }
        
        pdfPage = new PageReference(url2);
        b = null;
        if(!Test.isRunningTest()){
            b = pdfPage.getContent();
        }else{
            b = Blob.valueof('<div class="reportOutput">aaaaaaa</div>');
        }
        body2 = b.toString();

        if(body2.indexOf(htmlTable1) > 0){
            body2 = body2.substring(body2.indexOf(htmlTable1));
            body2 = body2.substring(0,body2.indexOf('</table>')+8);        
        }else if(body2.indexOf(htmlTable2) > 0){
            body2 = body2.substring(body2.indexOf(htmlTable2));
            body2 = body2.substring(0,body2.indexOf('</table>')+8);        
        }       
        
        return null;
    }

}