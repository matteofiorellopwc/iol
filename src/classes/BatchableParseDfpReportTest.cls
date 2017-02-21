@isTest
public class BatchableParseDfpReportTest{
/*
    public class getReportJobMock implements WebServiceMock {
       public void doInvoke(Object stub,Object request,Map<String, Object> response,String endpoint,String soapAction,String requestName,String responseNS,String responseName,String responseType) {
            DfpReportService.getReportJobResponse_element response_x = new DfpReportService.getReportJobResponse_element();
            response_x.rval = new DfpReportService.ReportJob();
            response_x.rval.reportJobStatus = 'COMPLETED';
            response.put('response_x', response_x);
       }
    }
    
    public class getReportDownloadUrlWithOptionsMock implements WebServiceMock {
       public void doInvoke(Object stub,Object request,Map<String, Object> response,String endpoint,String soapAction,String requestName,String responseNS,String responseName,String responseType) {
            DfpReportService.getReportDownloadUrlWithOptionsResponse_element response_x = new DfpReportService.getReportDownloadUrlWithOptionsResponse_element();
            response_x.rval = 'http://test.com/xxxxx';
            response.put('response_x', response_x);
       }
    }

    public static testMethod void testParseDfpReport(){
        //Test.setMock(WebServiceMock.class, new getReportDownloadUrlWithOptionsMock());
        
        Opportunity o = new Opportunity(Name='test',stageName='test',CloseDate=date.today());
        insert o;
        LineItem__c li = new LineItem__C(opportunity__c=o.id,id_dfp__c=1234567890);
        insert li;
        
        ReportLogger__c rl = new ReportLogger__c(Name = '0123456', Stato__c = 'IN_PROGRESS', Tipo__c='Mensile', AdUnitView__c='FLAT', Data_generazione__c=date.today());
        insert rl;
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new getReportJobMock());
        
        Database.executeBatch(new BatchableCheckReportStatus(),1);
        
        Test.stopTest();
    }
*/

    public static testMethod void testParseDfpReport(){
        utilityTest.insertDfpOasOpp();
        
        
        LineItem__c li = [select id_dfp__c from lineitem__c where ad_server__c = 'DFP'];
        li.id_dfp__c=1234567890;
        update li;
        
        Adunit__c ad = new AdUnit__c(iddfp__c = 'testadunit');
        insert ad;
        ad = new AdUnit__c(iddfp__c = 'testadunit2');
        insert ad;
        
        ReportLogger__c rl = new ReportLogger__c(Name = '0123456', Stato__c = 'READY', Tipo__c='Mensile', AdUnitView__c='FLAT', Data_generazione__c=date.today());
        insert rl;
        
        String s = 'Dimension.AD_UNIT_ID,Dimension.LINE_ITEM_ID,Dimension.MONTH,Dimension.AD_UNIT_NAME,Column.TOTAL_LINE_ITEM_LEVEL_IMPRESSIONS,Column.TOTAL_LINE_ITEM_LEVEL_CLICKS,Column.TOTAL_LINE_ITEM_LEVEL_CPM_AND_CPC_REVENUE';
        s += '\ntestadunit,1234567890,5,test,100,10,500';   
        s += '\ntestadunit2,1234567890,5,test,100,10,500';   
        
        Attachment a = new Attachment(Name='assets.csv',body=blob.valueOf(s),parentId=rl.id);
        insert a;
        
        Test.startTest();
        
        Database.executeBatch(new BatchableParseDfpReport(),100);
        
        Test.stopTest();
        
        list<asset> assets = [select impressions__c,SommaImpressionLineItem__c from asset];
        system.assertEquals(2,assets.size());
        system.assertEquals(100,assets[0].impressions__c);
        system.assertEquals(200,assets[0].SommaImpressionLineItem__c);
        
    
    }


}