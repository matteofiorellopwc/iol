/**
 *  Date:   2014/07/02
 *  Description:   Test class for trigger handler RicavoTriggerHandler
 *  Author: Luca Venanzetti
 */
@isTest
public class TestRicavoTriggerHandler {

    public static LineItem__c li;
    public static Opportunity opportunity;
    
    /**
    * Test popolamento dei field storico sui ricavi nel caso di opportunity chiusa vinta
    */
    static testMethod void testUpdateFieldsStorico() {
        
        prepareData();
        
        ControllerRicavi ctrlRicavi = new ControllerRicavi(li);
        ctrlRicavi.setParentValues(li);
        ctrlRicavi.creaRicaviDaDate();
        ctrlRicavi.customSave();
        
        Test.startTest();
        
        // simulo la il Close&Win sulla opportunity
        RicavoTriggerHandler.updateRicavoStorico = true;
        
        // trigger before update
        update [SELECT Id FROM Ricavo__c WHERE Line_Item__c = :li.Id];
        
        LineItem__c lineItemAllFields = [SELECT
                                            Start_Date__c, 
                                            End_Date__c, 
                                            Quantita__c,
                                            (
                                                SELECT Id,
                                                        LiStartDateStorico__c,
                                                        LiEndDate__c,
                                                        RiValore__c,
                                                        Valore__c,
                                                        RiPercentuale_applicata__c,
                                                        Percentuale_applicata__c,
                                                        RiAnno__c,
                                                        Anno__c,
                                                        RiMese__c,
                                                        Mese__c,
                                                        RiDataPrimoMeseStorico__c,
                                                        Data_primo_mese__c,
                                                        LiQuantitStorico__c
                                                FROM Ricavi__r
                                            )
                                        FROM LineItem__c
                                        WHERE Id = :li.Id
                                    ];
        
        for(Ricavo__c ricavo : lineItemAllFields.Ricavi__r){
            System.assertEquals(ricavo.LiStartDateStorico__c,lineItemAllFields.Start_Date__c);
            System.assertEquals(ricavo.LiEndDate__c,lineItemAllFields.End_Date__c);
            System.assertEquals(ricavo.RiValore__c,ricavo.Valore__c);
            System.assertEquals(ricavo.RiPercentuale_applicata__c,ricavo.Percentuale_applicata__c);
            System.assertEquals(ricavo.RiAnno__c,ricavo.Anno__c);
            System.assertEquals(ricavo.RiMese__c,ricavo.Mese__c);
            System.assertEquals(ricavo.RiDataPrimoMeseStorico__c,ricavo.Data_primo_mese__c);
            System.assertEquals(ricavo.LiQuantitStorico__c,lineItemAllFields.Quantita__c);
        }
        
        Test.stopTest();
        
        
    }
    
    /**
    * Test: I ricavi su mesi chiusi non possono essere inseriti/aggiornati/eliminati
    */
    static testMethod void testPreventDmlOperationsOnRicaviMesiChiusi() {

        prepareData();
        
        ControllerRicavi ctrlRicavi = new ControllerRicavi(li);
        ctrlRicavi.setParentValues(li);
        ctrlRicavi.creaRicaviDaDate();
        ctrlRicavi.customSave();
        
        Test.startTest();
        
        // I ricavi su mesi chiusi non possono essere inseriti
        boolean insertionFailed = false;
        try{
            Ricavo__c ra = new Ricavo__c(
                Line_Item__c=li.Id,
                Custom__c=true, 
                Modificato__c = true,
                Anno__c = String.valueOf(Date.today().year()-2),
                Mese__c = 'Gennaio',
                Valore__c = 2
            );
            ctrlRicavi.ricavi.add(ra);
            ctrlRicavi.indexApplicaDifferenza = 0;
            Apexpages.currentPage().getParameters().put('updatedRicavo','0');
            ctrlRicavi.applicaDifferenza();
            ctrlRicavi.customSave();
        }catch(System.DMLException e){
            System.debug(e);
            if(e.getDmlType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION && e.getDmlMessage(0).contains('Non si possono inserire ricavi di mesi chiusi')){
                insertionFailed = true;
                for(integer i=0; i<ctrlRicavi.ricavi.size(); i++){
                    Ricavo__c r = ctrlRicavi.ricavi.get(i);
                    if(r.Anno__c == String.valueOf(Date.today().year()-2) && r.Mese__c == 'Gennaio'){
                        ctrlRicavi.ricavi.remove(i);
                        break;
                    }
                }
            }
        }
        System.assert(insertionFailed);
        
        // I ricavi su mesi chiusi non possono essere modificati
        
        boolean updateFailed = false;
        
        // chiudo il mese sull'unico ricavo del line item
        Date nuovaDataChiusuraRicavi = Date.newInstance(Date.today().year(),Date.today().month(),1);
        nuovaDataChiusuraRicavi = nuovaDataChiusuraRicavi.addMonths(2).addDays(-1); 
        DataChiusuraRicavo__c dataChiusuraRicavi = DataChiusuraRicavo__c.getValues('nazionale');  
        dataChiusuraRicavi.data__c = nuovaDataChiusuraRicavi;
        update dataChiusuraRicavi;
        
        Date dataRicavoToInsert = nuovaDataChiusuraRicavi;
        dataRicavoToInsert = dataRicavoToInsert.addMonths(1);
        try{
            Ricavo__c ra = new Ricavo__c(
                Line_Item__c=li.Id,
                Custom__c=true, 
                Modificato__c = true,
                Anno__c = String.valueOf(dataRicavoToInsert.year()+1),
                Mese__c = 'Gennaio',
                Valore__c = 20
            );
            ctrlRicavi.ricavi.add(ra);
            ctrlRicavi.ricavi[0].Valore__c -= ra.Valore__c;
            ctrlRicavi.customSave(); 
        }catch(System.DMLException e){
            System.debug(e);
            if(e.getDmlType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION && e.getDmlMessage(0).contains('Non si possono modificare ricavi di mesi chiusi')){
                updateFailed = true;
                for(integer i=0; i<ctrlRicavi.ricavi.size(); i++){
                    Ricavo__c r = ctrlRicavi.ricavi.get(i);
                    if(r.Anno__c == String.valueOf(dataRicavoToInsert.year()+1) && r.Mese__c == 'Gennaio'){
                        ctrlRicavi.ricavi.remove(i);
                        break;
                    }
                }
            }
        }
        System.assert(updateFailed);

        // testo la cancellazione per verificare che non è possibile su ricavi su mesi chiusi
        boolean deletionFailed = false;
        try{
            delete ctrlRicavi.ricavi[0];
        }catch(System.DMLException e){
            System.debug(e);
            if(e.getDmlType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION && e.getDmlMessage(0).contains('Non si possono eliminare ricavi di mesi chiusi')){
                deletionFailed = true;
            }
        }
        System.assert(deletionFailed);
        
        Test.stopTest();
    }
    
    public static void prepareData(){
        
        // popolamento data chiusura ricavi sul custom setting
        Date dataOdierna = Date.today();
        Date precedenteDataChiusuraRicavi = Date.newInstance(dataOdierna.year(),dataOdierna.month(),1);
        precedenteDataChiusuraRicavi = precedenteDataChiusuraRicavi.addMonths(-4).addDays(-1);
        
        DataChiusuraRicavo__c dataChiusuraRicavo = new DataChiusuraRicavo__c();
        dataChiusuraRicavo.Name = 'nazionale';
        dataChiusuraRicavo.data__c = precedenteDataChiusuraRicavi;
        insert dataChiusuraRicavo;
        
        DataChiusuraRicavo__c dataChiusuraRicavoLocal = new DataChiusuraRicavo__c();
        dataChiusuraRicavoLocal.Name = 'local';
        dataChiusuraRicavoLocal.data__c = precedenteDataChiusuraRicavi;
        insert dataChiusuraRicavoLocal;
        
        // dati di test (opportunity, lineitem, ricavo) 
        Account a = utilityTest.insertBrand();
        
        opportunity = new Opportunity(
                            Name = 'Opportunity test',
                            AccountId = a.id, 
                            StageName = 'Chiusa vinta', 
                            CloseDate = dataOdierna,
                            Canale_di_vendita__c = 'DIRETTA',
                            Commissione_Agenzia__c = 0,
                            Tipo_Opportunity__c = 'Accordo Captive'

                        );
        insert opportunity; 
        
        Product2 product = new Product2(
            Name = 'Test',
            Family = 'Banner',
            BasePrice__c = 0,
            Breakeven_cost__c = 0       
        );
        insert product;
        
        li = new LineItem__c(
            Product__c = product.Id,
            Opportunity__c = opportunity.Id,
            Start_Date__c = dataOdierna.addDays(1),
            End_Date__c = dataOdierna.addDays(1),  
            quantita__c = 1,      
            Ultima_modifica_prezzo__c='Totale',
            Type_dfp__c = 'STANDARD',
            totale__c = 100
        );
        insert li;   
        
        ControllerRevenueApplication ctrlRevenue = new ControllerRevenueApplication(li);
        ctrlRevenue.setParentValues(li);
        ctrlRevenue.creaRevenueApplicationDaDate();
        ctrlRevenue.customSave();
        
    }
}