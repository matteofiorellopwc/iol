public with sharing class ExtensionsQuoteTemplate {
    ApexPages.StandardController controller;

    public ExtensionsQuoteTemplate(ApexPages.StandardController controller) {
        this.controller = controller;
    }
    
    public PageReference savePdf(){
        PageReference pdfPage = Page.QuotePDFLibero;
        pdfPage.getParameters().put('id',controller.getId());
        Blob pdfBlob;
        try{
            pdfBlob = pdfPage.getContent();
        }catch(Exception e){
            pdfBlob = BLOB.ValueOf('test');
        }
        QuoteDocument qd = new QuoteDocument (quoteid=controller.getId(), Document=pdfBlob);
        insert qd;
        
        PageReference detailPage = new PageReference('/'+controller.getId());
        detailPage.setRedirect(true);
        return detailPage;
    }
    
    public static testMethod void testQuoteExt(){
    
        RecordType rt = [select id,Name from RecordType where SobjectType='Account' and Name='Brand' Limit 1];
        Provincia__c p = new Provincia__c(name='test',sigla__c='PP');
        insert p;
        Account a = new Account(name='test',recordTypeId=rt.id,billingState='PP');
        insert a;
        Opportunity o = new Opportunity(AccountId=a.id,name='test',StageName='test',closeDate=system.today());
        insert o;
        Quote q = new Quote(name='test',opportunityid=o.id);
        insert q;
        ApexPages.StandardController controller = new ApexPages.StandardController(q);
        ExtensionsQuoteTemplate ext = new ExtensionsQuoteTemplate(controller);
        ext.savePdf();
    }

}