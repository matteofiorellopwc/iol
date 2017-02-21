@isTest
private class TestExtensionMinorRicavoParziale {
    
    @isTest static void run() {
        Date dataOdierna = Date.today();

        Opportunity opportunity = new Opportunity(
                    name = 'test',
                    CloseDate = dataOdierna,
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

        Date dataInizioLineItem = Date.newInstance(dataOdierna.year(), dataOdierna.month(), 1).addMonths(-1);
        Date dataFineLineItem = dataInizioLineItem.addMonths(4);
        
        // La data di chiusura dei ricavi è prima della data di inizio del line item, ricavi su mesi aperti altrimenti non mi fa salvare il line item, corretto
        Date dataChiusuraRicavi = dataInizioLineItem;
        dataChiusuraRicavi = dataChiusuraRicavi.addMonths(-10);
        DataChiusuraRicavo__c dataChiusuraRicavo = new DataChiusuraRicavo__c(
                                Name = 'nazionale',
                                data__c = dataChiusuraRicavi 
        );
        insert dataChiusuraRicavo;
        
        // La data di chiusura dei ricavi local è creata qui solo per correttezza, non utilizzata nel test ma va in errore se tolta perché ci sono controlli su questa data
        DataChiusuraRicavo__c dataChiusuraRicavoLocal = new DataChiusuraRicavo__c(
                                Name = 'local',
                                data__c = dataChiusuraRicavi 
        );
        insert dataChiusuraRicavoLocal;

        LineItemTriggerHandler.skipValidationTotali = true;
        LineItemTriggerHandler.skipValidationAdServer = true;
        LineItem__c lineitem = new LineItem__c(
                    Product__c = product.Id,
                    Opportunity__c = opportunity.Id,
                    start_Date__c = dataInizioLineItem,
                    end_Date__c = dataFineLineItem,
                    End_Hour__c = '0',
                    End_Minute__c = '0',
                    quantita__c = 1,      
                    Ultima_modifica_prezzo__c='Totale',
                    ModalitaEditRicavo__c = 'Valore',
                    Data_sospensione_erogazione__c = dataInizioLineItem.addMonths(1),
                    Type_dfp__c = 'STANDARD',
                    id_DFP__c = 123,
                    Status__c = 'PAUSED',
                    totale__c = 1000
        );
        insert lineitem; 

        ControllerRevenueApplication ctrlRevenue = new ControllerRevenueApplication(lineitem);
        ctrlRevenue.setParentValues(lineitem);
        ctrlRevenue.creaRevenueApplicationDaDate();
        ctrlRevenue.customSave();

        ControllerRicavi ctrlRicavi = new ControllerRicavi(lineitem);
        ctrlRicavi.setParentValues(lineitem);
        ctrlRicavi.creaRicaviDaDate();
        ctrlRicavi.customSave();

        insert new Ricavo__c(Line_Item__c=lineItem.Id,Custom__c=true, Modificato__c = true, MinorRicavo__c = true, Mese__c = 'Dicembre', Anno__c=String.valueOf(dataOdierna.year()), Valore__c = 1);

        LineItemTriggerHandler.skipValidationTotali = false;
        LineItemTriggerHandler.skipValidationAdServer = false;
        
        // La data di chiusura dei ricavi è un mese dopo la data di inizio del line item, ricavi su mesi chiusi e aperti
        dataChiusuraRicavo.data__c = dataInizioLineItem.addMonths(2).addDays(-1); 
        update dataChiusuraRicavo;

        ApexPages.StandardController standardController = new ApexPages.standardController(lineitem);
        ExtensionMinorRicavoParziale extension = new ExtensionMinorRicavoParziale(standardController);
        extension.bloccaLineItemMinorRicavo();
        extension.addRicaviCustom();
        for(Ricavo__c ricavoNegativo : extension.ricaviNegativi){
            if(ricavoNegativo.Valore__c == 0){
                ricavoNegativo.Mese__c = 'Dicembre';
                ricavoNegativo.Anno__c = String.valueOf(dataOdierna.year()+1);
                ricavoNegativo.Valore__c = 1;
            }
        }
        
        extension.indexRicavoToDelete = 0;
        extension.deleteRicaviCustom();

        extension.customSave();

        extension.goBack();

        System.assert([SELECT Id FROM Ricavo__c WHERE MinorRicavo__c = true and Line_Item__c = :lineitem.Id].size() > 0);
    }
        
}