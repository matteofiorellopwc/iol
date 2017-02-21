/**
*   Author: Luca Venanzetti
*   Create date: 2014-07-08
*   Description: Test del workflow di ripianificazione dei ricavi di un line item
*/
@isTest
private class TestMinorRicavoEsteso {
	
	private static Opportunity opportunity;
    private static Product2 product;

    /**
    *   Scenario 2: Ripianificazione di un line item che ha solo ricavi su mesi chiusi.
    *   I ricavi di storno vengono generati sulla base delle date del Line item di ripianificazione
    */
   static testMethod void testMethod1(){
        LineItem__c lineItem = creaLineItemMesiApertiNoRevenueFatturate();
        lineItem.Status__c = 'READY';
        update lineItem;
        lineItem = [SELECT Id,Integrato_con_DFP_formula__c,NonIntegratoAdServer__c,Product__r.Family,Product__c,start_Date__c,
        					end_Date__c,End_Minute__c,End_Hour__c,quantita__c,Ultima_modifica_prezzo__c,Id_DFP__c,ModalitaEditRicavo__c,Type_dfp__c,
        					Delivery_Model__c,Ad_Server__c,Ripianificato__c,RimozioneParteNonErogata__c,ImpressionErogateMinorRicavo__c,Status__c,
        					Id_oas__c,ApprovazioneMinorRicavo__c,Status_oas__c,Stato_lavorazione_OAS__c,QuantitaRipianificabileRichiesta__c,Totale__c,
        					ProductFamily__c,TotaleRipianificabileRichiesto__c,Totale_ripianificato_positivo__c,ValoreRipianificabileRichiesto__c,
        					Data_sospensione_erogazione__c,ValoreRipianificabileApprovatoFormula__c,Opportunity__r.Local__c,TotaleRipianificabile__c,
        					Prezzo_net_net__c,Duration__c,StartDateTimeFormula__c
        			FROM LineItem__c
        			WHERE Id = :lineItem.Id];
        

        ApexPages.StandardController stdController = new ApexPages.StandardController(LineItem);
        ApexPages.currentPage().getParameters().put('id',lineItem.Id);
        ExtensionMinorRicavo controller = new ExtensionMinorRicavo(stdController);
        System.assert(controller.errorOccurred); // line item su mesi aperti senza revenue fatturate, no ripianificazione/minor ricavo

        DataChiusuraRicavo__c dataChiusuraRicavo = DataChiusuraRicavo__c.getValues('nazionale');
        dataChiusuraRicavo.data__c = Date.newInstance(lineItem.End_Date__c.year(), lineItem.End_Date__c.month(), 1).addMonths(2);
        update dataChiusuraRicavo;

        controller = new ExtensionMinorRicavo(stdController);
		System.assert(controller.errorOccurred);        
        
        System.assert(!controller.hideButtons);
        ApexPages.currentPage().getParameters().put('endDateLineItemAdServer','notSameOfSalesforce');
        System.assert(controller.errorOccurred);

        ApexPages.currentPage().getParameters().put('fakeEndDate','today');
        controller = new ExtensionMinorRicavo(stdController);
        System.assert(!controller.errorOccurred);

        controller = new ExtensionMinorRicavo(stdController);
        System.assert(!controller.errorOccurred);
        System.assert(!controller.hideRipianificaButton);

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
                    Totale__c = 200,
                    Line_Item_Ripianificato__c = null
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

		controller.setMaxValoriStorno();
        ApexPages.currentPage().getParameters().put('fieldModified','TotaleRipianificabile');
        controller.aggiornaValoriStorno();
        ApexPages.currentPage().getParameters().put('fieldModified','ImpressionsRipianificabili');
        controller.aggiornaValoriStorno();
        
        Revenue_application__c[] fattureStorno = ControllerRevenueApplication.getMinorRicavi(lineItem);

        try{
        	ControllerRevenueApplication.checkAndFixLineItemRevenues(fattureStorno,lineItem.Totale__c,true);
        }catch(Exception e){
        }

        ControllerRicavi.isLineItemSoloSuMesiApertiStorno(lineItemDiRipianificazione);

        LineItemTriggerHandler.skipValidationAdServer = false;
        Test.stopTest();
    }



	// metodi di utile per la creazione dei line item
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
            Family = 'DEM',
            BasePrice__c = 0,
            Breakeven_cost__c = 0,
            ConsentiModificaSeMesiChiusi__c = false,
            Local__c = false       
        );
        insert product;
    }

    static testMethod void testMethod2(){
        LineItem__c lineItem = creaLineItemMesiApertiNoRevenueFatturate();
        lineItem.Status__c = 'READY';
        update lineItem;
        lineItem = [SELECT Id,Integrato_con_DFP_formula__c,NonIntegratoAdServer__c,Product__r.Family,Product__c,start_Date__c,
        					end_Date__c,End_Minute__c,End_Hour__c,quantita__c,Ultima_modifica_prezzo__c,Id_DFP__c,ModalitaEditRicavo__c,Type_dfp__c,
        					Delivery_Model__c,Ad_Server__c,Ripianificato__c,RimozioneParteNonErogata__c,ImpressionErogateMinorRicavo__c,Status__c,
        					Id_oas__c,ApprovazioneMinorRicavo__c,Status_oas__c,Stato_lavorazione_OAS__c,QuantitaRipianificabileRichiesta__c,Totale__c,
        					ProductFamily__c,TotaleRipianificabileRichiesto__c,Totale_ripianificato_positivo__c,ValoreRipianificabileRichiesto__c,
        					Data_sospensione_erogazione__c,ValoreRipianificabileApprovatoFormula__c,Opportunity__r.Local__c,TotaleRipianificabile__c,
        					Prezzo_net_net__c,Duration__c
        			FROM LineItem__c
        			WHERE Id = :lineItem.Id];
        
        DataChiusuraRicavo__c dataChiusuraRicavo = DataChiusuraRicavo__c.getValues('nazionale');
        dataChiusuraRicavo.data__c = Date.newInstance(lineItem.End_Date__c.year(), lineItem.End_Date__c.month(), 1).addMonths(2);
        update dataChiusuraRicavo;

        ApexPages.StandardController stdController = new ApexPages.StandardController(LineItem);
        ApexPages.currentPage().getParameters().put('id',lineItem.Id);
        ExtensionMinorRicavo controller = new ExtensionMinorRicavo(stdController);

        PageReference p = controller.rimozioneParteNonErogata();
        System.assertNotEquals(null,p);

        System.assert(controller.canBeApproved);
        System.assert(!controller.isApprovalPendingOrRejected);
        
        PageReference pr = controller.requireApproval();
        System.assertEquals(pr.getUrl(),'/apex/MinorRicavo?id='+lineItem.Id);
    }	

    
    /**
    * Crea un line item con ricavi solo su mesi aperti e senza revenue fatturate
    */
    private static LineItem__c creaLineItemMesiApertiNoRevenueFatturate(){
        prepareData();

        Date dataOdierna = Date.today();
        Date dataInizioLineItem = Date.newInstance(dataOdierna.year(), dataOdierna.month(), dataOdierna.day()).addDays(-10);
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
        UtilityTrigger.skipTrigger = true;
        LineItem__c lineitem = new LineItem__c(
                    Product__c = product.Id,
                    Opportunity__c = opportunity.Id,
                    start_Date__c = dataInizioLineItem,
                    end_Date__c = dataFineLineItem,
                    End_Hour__c = '0',
                    End_Minute__c = '0',
                    quantita__c = 1000000000,      
                    Ultima_modifica_prezzo__c='Totale',
                    Id_DFP__c = 1234,
                    ModalitaEditRicavo__c = 'Valore',
                    Type_dfp__c = 'STANDARD',
                    Delivery_Model__c = 'CPM',
                    Ad_Server__c = 'DFP',
                    NonIntegratoAdServer__c = false,
                    totale__c = 1000,
                    ImpressionErogateMinorRicavo__c = 10,
                    Prezzo_net_net__c  = 1,
                    Duration__c = 'NONE'

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

        return lineitem;    
    }

  

}