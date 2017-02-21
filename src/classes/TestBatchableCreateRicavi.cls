@isTest
private class TestBatchableCreateRicavi {

    static testMethod void run() {
        Test.startTest();
        
        Opportunity opportunity = new Opportunity(
                    name = 'test',
                    CloseDate = Date.today(),
                    stageName = 'test'
        );
        insert opportunity;
        
        Product2 product = new Product2(  
            Name = 'Test',
            Family = 'Banner',
            BasePrice__c = 0,
            Breakeven_cost__c = 0       
        );
        insert product;
        
        Date dataOdierna = Date.today();
        Date dataInizioLineItem = Date.newInstance(dataOdierna.year(), dataOdierna.month(), dataOdierna.day()).addDays(1);
        Date dataFineLineItem = dataInizioLineItem.addMonths(2);
        
        Date dataChiusuraRicavi = Date.newInstance(dataOdierna.year(),dataOdierna.month(),1);
        dataChiusuraRicavi = dataChiusuraRicavi.addMonths(-4).addDays(-1);
        
        DataChiusuraRicavo__c dataChiusuraRicavo = new DataChiusuraRicavo__c();
        dataChiusuraRicavo.Name = 'nazionale';
        dataChiusuraRicavo.data__c = dataChiusuraRicavi;
        insert dataChiusuraRicavo;
        
        DataChiusuraRicavo__c dataChiusuraRicavoLocal = new DataChiusuraRicavo__c();
        dataChiusuraRicavoLocal.Name = 'local';
        dataChiusuraRicavoLocal.data__c = dataChiusuraRicavi;
        insert dataChiusuraRicavoLocal;
        
        LineItem__c lineitem = new LineItem__c(
                    Product__c = product.Id,
                    Opportunity__c = opportunity.Id,
                    start_Date__c = dataInizioLineItem,
                    end_Date__c = dataFineLineItem,
                    quantita__c = 1,      
                    Ultima_modifica_prezzo__c='Totale',
                    ModalitaEditRicavo__c = 'Valore',
                    Type_dfp__c = 'STANDARD',
                    totale__c = 1000
        );
        insert lineitem;
        
        ControllerRevenueApplication ctrlRevenue = new ControllerRevenueApplication(lineitem);
        ctrlRevenue.setParentValues(lineitem);
        ctrlRevenue.creaRevenueApplicationDaDate();
        ctrlRevenue.customSave();
        
        Database.executeBatch(new BatchableCreateRicavi());
        Test.stopTest();
        
        System.assertEquals(
            [SELECT Id FROM Revenue_application__c WHERE Line_Item__c = :lineitem.Id].size(),
            [SELECT Id FROM Ricavo__c WHERE Line_Item__c = :lineitem.Id].size()
        );
    }
}