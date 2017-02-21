@isTest
private class ExtensionEditPacchettoOpportunityTest {
    @isTest
    static void testExtension() {
        utilityTest.createFattoreCorrettivoFasce();
    
        Opportunity o = new Opportunity(
            Name = 'Opportunity Test',
            StageName = 'Open',
            CloseDate = date.today(),
            Commissione_Agenzia__c = 0         
        );
        insert o;
        
        Product2 p1 = new Product2(
            Name = 'Test1'
        );
        insert p1;
        
        Product2 p2 = new Product2(
            Name = 'Test2'
        );
        insert p2;
        
        AdUnit__c adUnit1 = new AdUnit__c(
            Name = 'TestAD1',
            IdDfp__c = 'test1'  
        );
        insert adUnit1;
        
        PacchettoCombo__c pc = new PacchettoCombo__c(
            Name = 'Test pac'           
        );
        insert pc;
        
        Pacchetto_Combo_Prodotto__c pcp1 = new Pacchetto_Combo_Prodotto__c(         
            PacchettoCombo__c = pc.Id,
            Product__c = p1.Id,
            Listino__c = 1000,
            Modificabile_in_line_item__c = 'Date;Quantità;Goal'
        );
        insert pcp1;
        
        Pacchetto_Combo_Prodotto__c pcp2 = new Pacchetto_Combo_Prodotto__c(         
            PacchettoCombo__c = pc.Id,
            Product__c = p2.Id,
            Listino__c = 1000,
            Modificabile_in_line_item__c = 'Date;Quantità;Goal'
        );
        insert pcp2;
        
        Test.startTest();
        
        Test.setCurrentPage(new PageReference('/apex/editPacchettoOpportunity?oppId=' + o.Id + '&pacId=' + pc.Id));
        ExtensionEditPacchettoOpportunity eepo = new ExtensionEditPacchettoOpportunity(new ApexPages.StandardController(new Pacchetto_Combo_Opportunity__c()));
        eepo.customCancel();
        eepo.customSave();  
        eepo.fieldEdited = 'totale';
        eepo.updateCalc();
        System.debug(ApexPages.getMessages());  
        
        Test.setCurrentPage(new PageReference('/apex/editPacchettoOpportunity?oppId=' + o.Id + '&id=' + eepo.pco.Id));
        eepo = new ExtensionEditPacchettoOpportunity(new ApexPages.StandardController(eepo.pco));
        eepo.customSave();                  
        try {
            eepo.CheckAvailability();
        } catch(Exception e) {}     
        
        ControllerRevenueApplication cra = new ControllerRevenueApplication(eepo.pco);
        cra.setParentValues(eepo.pco);
        
        Test.stopTest();
        
    }
}