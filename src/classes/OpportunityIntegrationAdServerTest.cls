@isTest
public class OpportunityIntegrationAdServerTest{

    public static testMethod void testExtensionOpportunityIntegrationAdServer() {
        AdUnit__c adu = new AdUnit__c(name='test',idDfp__c='adunit1',status__c='ACTIVE');
        insert adu;
    
        Opportunity opp = utilityTest.insertDfpOasOpp();        
        
        PageReference pref = Page.OpportunityIntegrationAdServer;
        pref.getParameters().put('id', opp.Id);
        Test.setCurrentPage(pref);

        ApexPages.StandardController oppStndCtrl = new ApexPages.standardController(opp);
        ExtensionOpportunityIntegrationAdServer ext = new ExtensionOpportunityIntegrationAdServer(oppStndCtrl);
        
        ext.saveAndReload();
        ext.upsertSfdcToDfp();
        ext.reserveSfdcToDfp();
        ext.upsertSfdcToOas();
        Test.startTest();
        ext.doUpsertOas = true;
        ext.upsertSfdcToOas();
        ext.reserveSfdcToOas();
        ext.doUpsertOas = true;
        ext.reserveSfdcToOas();
        Test.stopTest();
    } 
    
    public static testMethod void testExtensionOpportunityOasIntegration(){
        OasIntegrationTest.insertTestAuth();
        Opportunity opp = utilityTest.insertDfpOasOpp();
        Test.startTest();
        ApexPages.StandardController oppStndCtrl = new ApexPages.standardController(opp);
        ExtensionOpportunityOasIntegration ext = new ExtensionOpportunityOasIntegration(oppStndCtrl);
        ext = new ExtensionOpportunityOasIntegration(opp.id);
        ext.upsertSfToOas();
        lineitem__c li = [select id_oas__c from lineitem__c where ad_server__c = 'OAS'];
        li.id_oas__c = 'test';
        update li;
        ext = new ExtensionOpportunityOasIntegration(opp.id);    
        
        ext.upsertSfToOas();
        ext.reserveOrder();
        ext.confirmOrder();
        Test.stopTest();
    }




}