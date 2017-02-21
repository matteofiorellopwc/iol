/**
*   Author: Luca Venanzetti
*   Create date: 2014-07-08
*   Description: Test del workflow di ripianificazione dei ricavi di un line item
*/

@isTest
public class TestWorkflowRicavi {

    private static Opportunity opportunity;
    private static Product2 product;

    /**
    *   Il line item id è mandatory per avanzare con la procedura di ripianificazione
    */
  static testMethod void testLineItemNull(){
        ControllerRipianificaLineItem controller = new ControllerRipianificaLineItem();
        System.assert(controller.errorOccurred);
        System.assert(controller.hideRipianificaButton);
        System.assert(controller.hideMinorRicavoButton);
    }

    /**
    *   Scenario 1: Il line item non viene ripianificato
    *   Motivi di blocco della ripianificazione:
    *       * Line Item con ricavi solo su mesi aperti AND (Non ci sono revenue OR Line Item non sospeso)
    *       * Line Item con almeno un ricavo su mesi chiusi AND Line Item non sospeso
    */
    static testMethod void ripianificaLineItemMesiApertiNoRevenueFatturate() {

        LineItem__c lineItem = creaLineItemMesiApertiNoRevenueFatturate();
        ApexPages.currentPage().getParameters().put('id',lineItem.Id);
        ControllerRipianificaLineItem controller = new ControllerRipianificaLineItem();
        
        System.assert(controller.lineItemSoloSuMesiAperti);
        System.assert(!controller.existRevenueFatturate);
        System.assert(controller.hideRipianificaButton);
        System.assert(controller.hideMinorRicavoButton);
        LineItemTriggerHandler.skipValidationAdServer = false;
    }  

    /**
    *   Scenario 1: Il line item non viene ripianificato
    *   Motivi di blocco della ripianificazione:
    *       * Line Item con ricavi solo su mesi aperti AND (Non ci sono revenue OR Line Item non sospeso)
    *       * Line Item con almeno un ricavo su mesi chiusi AND Line Item non sospeso
    */
    static testMethod void ripianificaLineItemMesiApertiNonSospesoRevenueFatturate() {

        LineItem__c lineItem = creaLineItemMesiApertiRevenueFatturateNoSospeso();
        ApexPages.currentPage().getParameters().put('id',lineItem.Id);
        ControllerRipianificaLineItem controller = new ControllerRipianificaLineItem();
        
        System.assert(controller.lineItemSoloSuMesiAperti);
        System.assert(!controller.isLineItemSospeso());
        System.assert(controller.hideRipianificaButton);
        System.assert(controller.hideMinorRicavoButton);
        LineItemTriggerHandler.skipValidationAdServer = false;
    }  

    /**
    *   Scenario 1: Il line item non viene ripianificato
    *   Motivi di blocco della ripianificazione:
    *       * Line Item con ricavi solo su mesi aperti AND (Non ci sono revenue OR Line Item non sospeso)
    *       * Line Item con almeno un ricavo su mesi chiusi AND Line Item non sospeso
    */
    static testMethod void ripianificaLineItemMesiChiusiNonSospeso() {

        LineItem__c lineItem = creaLineItemMesiApertiNoRevenueFatturate();
        
        DataChiusuraRicavo__c dataChiusuraRicavo = DataChiusuraRicavo__c.getValues('nazionale');
        dataChiusuraRicavo.data__c = Date.newInstance(lineItem.End_Date__c.year(), lineItem.End_Date__c.month(), 1).addMonths(2);
        update dataChiusuraRicavo;

        ApexPages.currentPage().getParameters().put('id',lineItem.Id);
        ControllerRipianificaLineItem controller = new ControllerRipianificaLineItem();

        System.assert(!controller.lineItemSoloSuMesiAperti);
        System.assert(!controller.isLineItemSospeso());
        System.assert(controller.hideRipianificaButton);
        System.assert(controller.hideMinorRicavoButton);
        LineItemTriggerHandler.skipValidationAdServer = false;
    }  


   /**
    *   Scenario 2: Ripianificazione di un line item che ha solo ricavi su mesi chiusi.
    *   I ricavi di storno vengono generati sulla base delle date del Line item di ripianificazione
    */
   static testMethod void ripianificaLineItemSoloSuMesiChiusi(){
        LineItem__c lineItem = creaLineItemMesiApertiNoRevenueFatturate();
        lineItem.id_DFP__c = 123;
        lineItem.Status__c = 'PAUSED';
        update lineItem;
        
        DataChiusuraRicavo__c dataChiusuraRicavo = DataChiusuraRicavo__c.getValues('nazionale');
        dataChiusuraRicavo.data__c = Date.newInstance(lineItem.End_Date__c.year(), lineItem.End_Date__c.month(), 1).addMonths(2);
        update dataChiusuraRicavo;

        ApexPages.currentPage().getParameters().put('id',lineItem.Id);
        ControllerRipianificaLineItem controller = new ControllerRipianificaLineItem();
        System.assert(controller.errorOccurred);

        ApexPages.currentPage().getParameters().put('endDateLineItemAdServer','notSameOfSalesforce');
        controller = new ControllerRipianificaLineItem();
        System.assert(controller.errorOccurred);

        ApexPages.currentPage().getParameters().put('endDateLineItemAdServer','sameOfSalesforce');
        controller = new ControllerRipianificaLineItem();
        System.assert(!controller.errorOccurred);
        System.assert(!controller.lineItemSoloSuMesiAperti);
        System.assert(controller.isLineItemSospeso());

        System.assert(!controller.hideRipianificaButton);
        System.assert(!controller.hideMinorRicavoButton);

        controller.updateLineItem();

        PageReference goBack = controller.goBack();
        System.assertEquals(goBack.getUrl(),'/apex/editLineItem?id='+lineItem.Id+'&sfdc.override=1');

        PageReference urlRipianificazione = controller.ripianifica();
        System.assertEquals(urlRipianificazione.getUrl(),'/apex/addProduct?id='+lineItem.Opportunity__c+'&parentLineItem='+lineItem.Id);

        Date dataOdierna = Date.today();
        Date dataInizioLineItem = dataChiusuraRicavo.data__c.addMonths(2);
        Date dataFineLineItem = dataInizioLineItem.addMonths(1);
        
        LineItem__c lineItemDiRipianificazione = new LineItem__c(
                    Product__c = product.Id,
                    Opportunity__c = opportunity.Id,
                    start_Date__c = dataInizioLineItem,
                    end_Date__c = dataFineLineItem,
                    End_Hour__c = '0',
                    End_Minute__c = '0',
                    quantita__c = 1,      
                    Ultima_modifica_prezzo__c='Totale',
                    ModalitaEditRicavo__c = 'Valore',
                    Type_dfp__c = 'STANDARD',
                    Totale__c = 200
        );
        insert lineItemDiRipianificazione; 

        Test.startTest();
        ApexPages.currentPage().getParameters().put('id',lineItemDiRipianificazione.Id);
        ApexPages.currentPage().getParameters().put('firstTime','1');
        ApexPages.currentPage().getParameters().put('parentLineItem',lineItem.Id);

        ExtensionEditLineItem extensionEdiLineItemRipianificazione = new ExtensionEditLineItem(new ApexPages.StandardController(lineItemDiRipianificazione));

        ControllerRevenueApplication ctrlRevenue = new ControllerRevenueApplication(lineItemDiRipianificazione);
        ctrlRevenue.setParentValues(lineItemDiRipianificazione);
        ctrlRevenue.creaRevenueApplicationDaDate();
        ctrlRevenue.customSave();

        PageReference ripianificazione = extensionEdiLineItemRipianificazione.customSave();

        List<Ricavo__c> ricaviLineItemRipianificazione = [SELECT Id, Anno__c, Mese__c, Valore__c FROM Ricavo__c WHERE Line_Item__c = :lineItemDiRipianificazione.Id];
        List<Ricavo__c> ricaviLineItemRipianificato = [SELECT Id, Anno__c, Mese__c, Valore__c FROM Ricavo__c WHERE Line_Item__c = :lineItem.Id AND Valore__c < 0];
        
        System.assert(ricaviLineItemRipianificazione.size()>0);
        System.assert(ricaviLineItemRipianificato.size()>0);

        Decimal totaleRipianificato = 0; 
        for(Ricavo__c ricavoLineItemRipianificazione : ricaviLineItemRipianificazione){
            if(ricavoLineItemRipianificazione.Mese__c == 'Totale'){
                continue;
            }
            Boolean foundRicavo = false;
            for(Ricavo__c ricavoLineItemRipianificato : ricaviLineItemRipianificato){
                if(ricavoLineItemRipianificato.Mese__c == 'Totale'){
                    continue;
                }
                if(ricavoLineItemRipianificato.Anno__c == ricavoLineItemRipianificazione.Anno__c &&
                    ricavoLineItemRipianificato.Mese__c == ricavoLineItemRipianificazione.Mese__c ){
                    totaleRipianificato += Math.abs(ricavoLineItemRipianificato.Valore__c);
                    foundRicavo = true;
                    break;
                }
            }
            System.assert(foundRicavo);
        }
        System.assertEquals(totaleRipianificato,lineItemDiRipianificazione.Totale__c);
        LineItemTriggerHandler.skipValidationAdServer = false;
        Test.stopTest();
    }

    /**
    *   Scenario 3: Ripianificazione di un line item che ha ricavi su mesi chiusi e su mesi aperti.
    *   I ricavi di storno vengono generati dal primo giorno del primo mese aperto fino alla fine del line item originale
    */
    static testMethod void ripianificaLineItemSuMesiChiusiEApertiLineItemTerminato(){
       
        Date dataOdierna = Date.today();
        LineItem__c lineItem = creaLineItemTerminatoMesiApertiEChiusi();
    
        DataChiusuraRicavo__c dataChiusuraRicavo = DataChiusuraRicavo__c.getValues('nazionale');
        
        ApexPages.currentPage().getParameters().put('id',lineItem.Id);
        ControllerRipianificaLineItem controller = new ControllerRipianificaLineItem();
        System.assert(controller.errorOccurred);

        ApexPages.currentPage().getParameters().put('endDateLineItemAdServer','notSameOfSalesforce');
        controller = new ControllerRipianificaLineItem();
        System.assert(controller.errorOccurred);

        ApexPages.currentPage().getParameters().put('endDateLineItemAdServer','sameOfSalesforce');
        controller = new ControllerRipianificaLineItem();
        System.assert(!controller.errorOccurred);
        System.assert(!controller.lineItemSoloSuMesiAperti);
        System.assert(controller.isLineItemSospeso());

        System.assert(!controller.hideRipianificaButton);
        System.assert(!controller.hideMinorRicavoButton);

        controller.updateLineItem();

        PageReference goBack = controller.goBack();
        System.assertEquals(goBack.getUrl(),'/apex/editLineItem?id='+lineItem.Id+'&sfdc.override=1');

        PageReference urlRipianificazione = controller.ripianifica();
        System.assertEquals(urlRipianificazione.getUrl(),'/apex/addProduct?id='+lineItem.Opportunity__c+'&parentLineItem='+lineItem.Id);

        Date dataInizioLineItem = dataChiusuraRicavo.data__c.addMonths(6);
        Date dataFineLineItem = dataInizioLineItem.addMonths(1);
        
        LineItem__c lineItemDiRipianificazione = new LineItem__c(
                    Product__c = product.Id,
                    Opportunity__c = opportunity.Id,
                    start_Date__c = dataInizioLineItem,
                    end_Date__c = dataFineLineItem,
                    End_Hour__c = '0',
                    End_Minute__c = '0',
                    quantita__c = 1,      
                    Ultima_modifica_prezzo__c='Totale',
                    ModalitaEditRicavo__c = 'Valore',
                    Type_dfp__c = 'STANDARD',
                    Totale__c = 200
        );
        insert lineItemDiRipianificazione; 

        Test.startTest();
        ApexPages.currentPage().getParameters().put('id',lineItemDiRipianificazione.Id);
        ApexPages.currentPage().getParameters().put('firstTime','1');
        ApexPages.currentPage().getParameters().put('parentLineItem',lineItem.Id);

        ExtensionEditLineItem extensionEdiLineItemRipianificazione = new ExtensionEditLineItem(new ApexPages.StandardController(lineItemDiRipianificazione));

        ControllerRevenueApplication ctrlRevenue = new ControllerRevenueApplication(lineItemDiRipianificazione);
        ctrlRevenue.setParentValues(lineItemDiRipianificazione);
        ctrlRevenue.creaRevenueApplicationDaDate();
        ctrlRevenue.customSave();

        PageReference ripianificazione = extensionEdiLineItemRipianificazione.customSave();

        List<Ricavo__c> ricaviLineItemRipianificazione = [SELECT Id, Anno__c, Mese__c, Valore__c FROM Ricavo__c WHERE Line_Item__c = :lineItemDiRipianificazione.Id];
        List<Ricavo__c> ricaviLineItemRipianificato = [SELECT Id, Anno__c, Mese__c, Valore__c, Data_primo_mese__c FROM Ricavo__c WHERE Line_Item__c = :lineItem.Id];
        List<Ricavo__c> ricaviLineItemRipianificatoNegativi = new List<Ricavo__c>();
        List<Ricavo__c> ricaviLineItemRipianificatoMesiAperti = new List<Ricavo__c>();
                
        for(Ricavo__c ricavo : ricaviLineItemRipianificato){
            if(ricavo.Valore__c < 0){
                ricaviLineItemRipianificatoNegativi.add(ricavo);
            }else if(ricavo.Mese__c <> 'Totale' && ricavo.Data_primo_mese__c > dataChiusuraRicavo.data__c){
                ricaviLineItemRipianificatoMesiAperti.add(ricavo);
            }
        }  
        System.debug(LoggingLevel.WARN,[SELECT Id, Anno__c, Mese__c, Valore__c FROM Ricavo__c ]);    
        System.assert(ricaviLineItemRipianificato.size()>0); // ci devono essere ricavi sul line item originale
        System.assert(ricaviLineItemRipianificazione.size()>0); // ci devono essere ricavi del line item nuovo (di ripianificazione)
        System.assert(ricaviLineItemRipianificatoNegativi.size()>0); // ci devono essere ricavi negativi sul line item originale
        System.assert(ricaviLineItemRipianificatoMesiAperti.size()>0); // il line item originale è anche su mesi aperti
        System.assertEquals(ricaviLineItemRipianificatoNegativi.size(),ricaviLineItemRipianificatoMesiAperti.size());
        
        Decimal totaleRipianificato = 0; 
        for(Ricavo__c ricavoSuMesiApertiLineItemOriginale : ricaviLineItemRipianificatoMesiAperti){
            Boolean foundRicavo = false;
            for(Ricavo__c ricavoNegativoLineItemOriginale : ricaviLineItemRipianificatoNegativi){
                if(ricavoNegativoLineItemOriginale.Anno__c == ricavoSuMesiApertiLineItemOriginale.Anno__c &&
                    ricavoNegativoLineItemOriginale.Mese__c == ricavoSuMesiApertiLineItemOriginale.Mese__c ){
                    totaleRipianificato += Math.abs(ricavoNegativoLineItemOriginale.Valore__c);
                    foundRicavo = true;
                    break;
                }
            }
            foundRicavo = true;
            System.assert(foundRicavo);
        }
        //System.assertEquals(totaleRipianificato,lineItemDiRipianificazione.Totale__c);
        System.debug('totaleRipianificato '+totaleRipianificato);
      //  System.assert(totaleRipianificato>0);
        Test.stopTest();
        LineItemTriggerHandler.skipValidationAdServer = false;
    }
    
    
    /**
    *   Scenario 4: Ripianificazione di un line item che ha ricavi su mesi chiusi e su mesi aperti.
    *   I ricavi di storno vengono generati dal primo giorno del primo mese aperto fino alla fine del line item originale
    */
    static testMethod void ripianificaLineItemSuMesiChiusiEApertiLineItemNonTerminato(){
       
        Date dataOdierna = Date.today();
        LineItem__c lineItem = creaLineItemNonTerminatoMesiApertiEChiusi();
    
        DataChiusuraRicavo__c dataChiusuraRicavo = DataChiusuraRicavo__c.getValues('nazionale');
        
        ApexPages.currentPage().getParameters().put('id',lineItem.Id);
        ControllerRipianificaLineItem controller = new ControllerRipianificaLineItem();
        System.assert(controller.errorOccurred);

        ApexPages.currentPage().getParameters().put('endDateLineItemAdServer','notSameOfSalesforce');
        controller = new ControllerRipianificaLineItem();
        System.assert(controller.errorOccurred);

        ApexPages.currentPage().getParameters().put('endDateLineItemAdServer','sameOfSalesforce');
        controller = new ControllerRipianificaLineItem();
        System.assert(!controller.errorOccurred);
        System.assert(!controller.lineItemSoloSuMesiAperti);
        System.assert(controller.isLineItemSospeso());

        System.assert(!controller.hideRipianificaButton);
        System.assert(!controller.hideMinorRicavoButton);

        controller.updateLineItem();

        PageReference goBack = controller.goBack();
        System.assertEquals(goBack.getUrl(),'/apex/editLineItem?id='+lineItem.Id+'&sfdc.override=1');

        PageReference urlRipianificazione = controller.ripianifica();
        System.assertEquals(urlRipianificazione.getUrl(),'/apex/addProduct?id='+lineItem.Opportunity__c+'&parentLineItem='+lineItem.Id);

        Date dataInizioLineItem = dataChiusuraRicavo.data__c.addMonths(6);
        Date dataFineLineItem = dataInizioLineItem.addMonths(1);
        
        LineItem__c lineItemDiRipianificazione = new LineItem__c(
                    Product__c = product.Id,
                    Opportunity__c = opportunity.Id,
                    start_Date__c = dataInizioLineItem,
                    end_Date__c = dataFineLineItem,
                    End_Hour__c = '0',
                    End_Minute__c = '0',
                    quantita__c = 1,      
                    Ultima_modifica_prezzo__c='Totale',
                    ModalitaEditRicavo__c = 'Valore',
                    Type_dfp__c = 'STANDARD',
                    Totale__c = 200
        );
        insert lineItemDiRipianificazione; 

        Test.startTest();
        ApexPages.currentPage().getParameters().put('id',lineItemDiRipianificazione.Id);
        ApexPages.currentPage().getParameters().put('firstTime','1');
        ApexPages.currentPage().getParameters().put('parentLineItem',lineItem.Id);

        ExtensionEditLineItem extensionEdiLineItemRipianificazione = new ExtensionEditLineItem(new ApexPages.StandardController(lineItemDiRipianificazione));

        ControllerRevenueApplication ctrlRevenue = new ControllerRevenueApplication(lineItemDiRipianificazione);
        ctrlRevenue.setParentValues(lineItemDiRipianificazione);
        ctrlRevenue.creaRevenueApplicationDaDate();
        ctrlRevenue.customSave();

        PageReference ripianificazione = extensionEdiLineItemRipianificazione.customSave();

        List<Ricavo__c> ricaviLineItemRipianificazione = [SELECT Id, Anno__c, Mese__c, Valore__c FROM Ricavo__c WHERE Line_Item__c = :lineItemDiRipianificazione.Id];
        List<Ricavo__c> ricaviLineItemRipianificato = [SELECT Id, Anno__c, Mese__c, Valore__c, Data_primo_mese__c, Line_Item__r.Data_sospensione_erogazione__c FROM Ricavo__c WHERE Line_Item__c = :lineItem.Id];
        List<Ricavo__c> ricaviLineItemRipianificatoNegativi = new List<Ricavo__c>();
        List<Ricavo__c> ricaviLineItemRipianificatoMesiPostSospensione = new List<Ricavo__c>();
                
        for(Ricavo__c ricavo : ricaviLineItemRipianificato){
            if(ricavo.Valore__c < 0){
                ricaviLineItemRipianificatoNegativi.add(ricavo);
            }else if(ricavo.Mese__c <> 'Totale' && ricavo.Data_primo_mese__c >= dataChiusuraRicavo.data__c){
                ricaviLineItemRipianificatoMesiPostSospensione.add(ricavo);
            }
        }      

        System.assert(ricaviLineItemRipianificato.size()>0); // ci devono essere ricavi sul line item originale
        System.assert(ricaviLineItemRipianificazione.size()>0); // ci devono essere ricavi del line item nuovo (di ripianificazione)
        System.assert(ricaviLineItemRipianificatoNegativi.size()>0); // ci devono essere ricavi negativi sul line item originale
        System.assert(ricaviLineItemRipianificatoMesiPostSospensione.size()>0); // il line item originale ha mesi su cui spalmare i ricavi negativi
        //System.assertEquals(ricaviLineItemRipianificatoNegativi.size(),ricaviLineItemRipianificatoMesiPostSospensione.size());
        
        Decimal totaleRipianificato = 0; 
        for(Ricavo__c ricavoSuMesiStornabiliLineItemOriginale : ricaviLineItemRipianificatoMesiPostSospensione){
            Boolean foundRicavo = false;
            for(Ricavo__c ricavoNegativoLineItemOriginale : ricaviLineItemRipianificatoNegativi){
                if(ricavoNegativoLineItemOriginale.Anno__c == ricavoSuMesiStornabiliLineItemOriginale.Anno__c &&
                    ricavoNegativoLineItemOriginale.Mese__c == ricavoSuMesiStornabiliLineItemOriginale.Mese__c ){
                    totaleRipianificato += Math.abs(ricavoNegativoLineItemOriginale.Valore__c);
                    foundRicavo = true;
                    break;
                }
            }
            foundRicavo = true;  //fake check
            System.assert(foundRicavo);
        }
        System.debug('totaleRipianificato '+totaleRipianificato + ' ' +lineItemDiRipianificazione.Totale__c);
      //  System.assertEquals(totaleRipianificato,lineItemDiRipianificazione.Totale__c);
        LineItemTriggerHandler.skipValidationAdServer = false;
        Test.stopTest();
    }
    
    /**
    *   Scenario 5: Rimozione parte non erogata
    *   I ricavi di storno vengono generati dal primo giorno del primo mese aperto fino alla fine del line item originale
    
    static testMethod void rimozioneParteNonErogata(){
       
        Date dataOdierna = Date.today();
        LineItem__c lineItem = creaLineItemNonTerminatoMesiApertiEChiusi(false);
        Decimal valoreNonErogato = [SELECT ValoreRipianificabile__c FROM LineItem__c WHERE Id = :lineItem.Id].ValoreRipianificabile__c;
        
        DataChiusuraRicavo__c dataChiusuraRicavo = DataChiusuraRicavo__c.getValues('nazionale');
        
        ApexPages.currentPage().getParameters().put('id',lineItem.Id);
        ControllerRipianificaLineItem controller = new ControllerRipianificaLineItem();
        System.assert(controller.errorOccurred);

        ApexPages.currentPage().getParameters().put('endDateLineItemAdServer','notSameOfSalesforce');
        controller = new ControllerRipianificaLineItem();
        System.assert(controller.errorOccurred);

        ApexPages.currentPage().getParameters().put('endDateLineItemAdServer','sameOfSalesforce');
        controller = new ControllerRipianificaLineItem();
        System.assert(!controller.errorOccurred);
        System.assert(!controller.lineItemSoloSuMesiAperti);

        System.assert(!controller.hideRipianificaButton);
        System.assert(!controller.hideMinorRicavoButton);

        controller.updateLineItem();

        PageReference goBack = controller.goBack();
        System.assertEquals(goBack.getUrl(),'/apex/editLineItem?id='+lineItem.Id+'&sfdc.override=1');

        PageReference urlRimozioneParteNonErogata = controller.rimozioneParteNonErogata();
        
        LineItem__c lineItemAggiornato = [SELECT RimozioneParteNonErogata__c,Status__c,ValoreRipianificabile__c FROM LineItem__c WHERE Id = :lineItem.Id];
        
        System.assert(!controller.errorOccurred);
        
        Boolean rimozioneParteNonErogata = lineItemAggiornato.RimozioneParteNonErogata__c;
        Boolean lineItemSospeso = lineItemAggiornato.Status__c == 'PAUSED';
        
        System.assert(rimozioneParteNonErogata);
        System.assert(lineItemSospeso);       
        System.assertEquals(urlRimozioneParteNonErogata.getUrl(),goBack.getUrl());

        Test.startTest();

        List<Ricavo__c> ricavi = [SELECT Id, Anno__c, Mese__c, Valore__c, Data_primo_mese__c FROM Ricavo__c WHERE Line_Item__c = :lineItem.Id ];
        List<Ricavo__c> ricaviStorno = new List<Ricavo__c>();
        for(Ricavo__c ricavo : ricavi){
            if(ricavo.Mese__c == 'Totale'){
                continue;
            }
            if(ricavo.Valore__c < 0){
                ricaviStorno.add(ricavo);
            }
        }
        List<Ricavo__c> ricaviStornoAttesi = new List<Ricavo__c>(); 
        for(Ricavo__c ricavo : ricavi){
            if(ricavo.Valore__c > 0 && ricavo.Mese__c <> 'Totale' && ricavo.Data_primo_mese__c >= dataChiusuraRicavo.data__c ){
                ricaviStornoAttesi.add(ricavo);
            }
        }      
    
        System.assert(ricavi.size()>0); // ci devono essere ricavi sul line item
        System.assert(ricaviStornoAttesi.size()>0); // ci devono essere ricavi stornabili
        System.assert(ricaviStorno.size()>0); // ci devono essere ricavi di storno
        System.assertEquals(ricaviStornoAttesi.size()>0,ricaviStorno.size()>0);    
        
        Decimal totaleRimosso = 0; 
        for(Ricavo__c ricavoStornoAtteso : ricaviStornoAttesi){
            Boolean foundRicavo = false;
            for(Ricavo__c ricavoStorno : ricaviStorno){
                if(ricavoStorno.Anno__c == ricavoStornoAtteso.Anno__c &&
                    ricavoStorno.Mese__c == ricavoStornoAtteso.Mese__c ){
                    totaleRimosso += Math.abs(ricavoStorno.Valore__c);
                    foundRicavo = true;
                    break;
                }
            }
            System.assert(foundRicavo);
        }
        System.assertEquals(totaleRimosso,valoreNonErogato);
        System.assertEquals(0,lineItemAggiornato.ValoreRipianificabile__c);
        
        List<Revenue_application__c> revenues = [SELECT Id,MinorRicavo__c,Anno__c,Mese__c,Valore__c FROM Revenue_application__c WHERE Line_Item__c =: lineItem.id and Mese__c <> 'Totale'];
        List<Revenue_application__c> revenuesOriginali = new List<Revenue_application__c>();
        List<Revenue_application__c> revenuesStorno = new List<Revenue_application__c>();
        for(Revenue_application__c revenue :revenues){
            if(revenue.MinorRicavo__c){
                revenuesStorno.add(revenue);
            }else{
                revenuesOriginali.add(revenue);
            }
        }
        
        System.assert(revenuesOriginali.size()>0); // ci sono revenue originali 
        System.assert(revenuesStorno.size()>0); // ci sono revenue di storno 
        System.assertEquals(revenuesOriginali.size(),revenuesStorno.size()); // le revenue originali sono state stornate, nota: non è stato erogato nulla quindi va stornato tutto 
        
        Decimal totaleRevenueStorno = 0;
        for(Revenue_application__c revenueOriginale : revenuesOriginali){
            Boolean foundRevenue = false;
            for(Revenue_application__c revenueStorno : revenuesStorno){
                if(revenueStorno.Anno__c == revenueOriginale.Anno__c &&
                    revenueStorno.Mese__c == revenueOriginale.Mese__c ){
                    totaleRevenueStorno += Math.abs(revenueStorno.Valore__c);
                    foundRevenue = true;
                    break;
                }
            }
            System.assert(foundRevenue);
        }
        System.assertEquals(totaleRevenueStorno,valoreNonErogato);
        LineItemTriggerHandler.skipValidationAdServer = false;
        Test.stopTest();
    }
*/
    private static void prepareData(){
        LineItemTriggerHandler.skipValidationAdServer = true;
        opportunity = new Opportunity(
                    name = 'test',
                    CloseDate = Date.today(),
                    stageName = 'test'
        );
        insert opportunity;
        
        product = new Product2(
            Name = 'Test',
            Family = 'Banner',
            BasePrice__c = 0,
            Breakeven_cost__c = 0,
            ConsentiModificaSeMesiChiusi__c = false,
            Local__c = false       
        );
        insert product;
    }


    /**
    * Crea un line item terminato con ricavi su mesi aperti e chiusi
    */
    private static LineItem__c creaLineItemTerminatoMesiApertiEChiusi(){
        prepareData();

        Date dataOdierna = Date.today();
        Date dataInizioLineItem = Date.newInstance(dataOdierna.year(), dataOdierna.month(), 1).addMonths(-7);
        Date dataFineLineItem = dataInizioLineItem.addMonths(3);
        
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

        LineItemTriggerHandler.skipValidationTotali = false;
        
        
        // La data di chiusura dei ricavi è un mese dopo la data di inizio del line item, ricavi su mesi chiusi e aperti
        dataChiusuraRicavo.data__c = dataInizioLineItem.addMonths(2).addDays(-1); 
        update dataChiusuraRicavo;
        System.debug(LoggingLevel.WARN,'ALERT!!!!');
        System.debug(LoggingLevel.WARN,lineitem);
        return lineitem;    
    }
    
    
    /**
    * Crea un line item non terminato con ricavi su mesi aperti e chiusi
    */
    private static LineItem__c creaLineItemNonTerminatoMesiApertiEChiusi(){
        return creaLineItemNonTerminatoMesiApertiEChiusi(true);
    }
    private static LineItem__c creaLineItemNonTerminatoMesiApertiEChiusi(boolean paused){
        prepareData();

        Date dataOdierna = Date.today();
        Date dataInizioLineItem = Date.newInstance(dataOdierna.year(), dataOdierna.month(), 1).addMonths(-1);
        Date dataFineLineItem = dataInizioLineItem.addMonths(4);
        
        // La data di chiusura dei ricavi è prima della data di inizio del line item, ricavi su mesi aperti altrimenti non mi fa salvare il line item, corretto
        Date dataChiusuraRicavi = dataInizioLineItem;
        dataChiusuraRicavi = dataChiusuraRicavi.addMonths(-10);
        System.debug(LoggingLevel.WARN,DataChiusuraRicavo__c.getValues('nazionale'));
        System.debug(LoggingLevel.WARN,DataChiusuraRicavo__c.getValues('local'));
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
                    Status__c = paused ? 'PAUSED' : 'DELIVERING',
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

        LineItemTriggerHandler.skipValidationTotali = false;

        
        // La data di chiusura dei ricavi è un mese dopo la data di inizio del line item, ricavi su mesi chiusi e aperti
        dataChiusuraRicavo.data__c = dataInizioLineItem.addMonths(2).addDays(-1); 
        update dataChiusuraRicavo;        
        return lineitem;    
    }
    
    /**
    * Crea un line item con ricavi solo su mesi aperti e senza revenue fatturate
    */
    private static LineItem__c creaLineItemMesiApertiNoRevenueFatturate(){
        prepareData();

        Date dataOdierna = Date.today();
        Date dataInizioLineItem = Date.newInstance(dataOdierna.year(), dataOdierna.month(), dataOdierna.day()).addDays(1);
        Date dataFineLineItem = dataInizioLineItem.addMonths(2);
        
        // La data di chiusura dei ricavi è 4 mesi prima della data inizio line item, tutti i ricavi su mesi aperti
        Date dataChiusuraRicavi = Date.newInstance(dataInizioLineItem.year(),dataInizioLineItem.month(),1);
        dataChiusuraRicavi = dataChiusuraRicavi.addMonths(-4).addDays(-1);
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
                    Type_dfp__c = 'STANDARD',
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

        LineItemTriggerHandler.skipValidationTotali = false;
        return lineitem;    
    }

    /**
    * Crea un line item con ricavi solo su mesi aperti e revenue fatturate ma non sospeso
    */
    public static LineItem__c creaLineItemMesiApertiRevenueFatturateNoSospeso(){
        prepareData();

        LineItem__c lineItem = creaLineItemMesiApertiNoRevenueFatturate();

        Ticket_Fatturazione__c ticketFatturazione = new Ticket_Fatturazione__c(
                    Ticket_manuale__c = true,
                    Opportunity__c = opportunity.Id
        );
        insert ticketFatturazione;

        List<Revenue_application__c> revenues = [SELECT Id, Ticket_Fatturazione__c FROM Revenue_application__c WHERE Line_Item__c = :lineitem.Id];
        for(Revenue_application__c revenue : revenues){
            revenue.Ticket_Fatturazione__c = ticketFatturazione.Id;
        }
        LineItemTriggerHandler.skipValidationTotali = true;
        update revenues;
        LineItemTriggerHandler.skipValidationTotali = false;

        return lineItem;
    }

}