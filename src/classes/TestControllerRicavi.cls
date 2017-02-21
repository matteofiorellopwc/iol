@isTest
private class TestControllerRicavi {

    private static Opportunity opportunity;
    private static Product2 product;
    
    /**
    * Devono essere presenti 2 modalità di modifica di un ricavo:
    * 1. Percentuale
    * 2. Valore
    */
   static testMethod void testModalitaEditRicavo() {
        ControllerRicavi c = new ControllerRicavi();
        List<SelectOption> modalitaEdit = c.getModalitaOption();
        System.assertEquals(2,modalitaEdit.size());
        boolean valoreFound = false;
        boolean percentualeFound = false;
        for(SelectOption modalita : modalitaEdit){
            if(modalita.getValue() == 'Valore'){
                valoreFound = true;
            }else if(modalita.getValue() == 'Percentuale'){
                percentualeFound = true;
            }
        }
        System.assert(valoreFound);
        System.assert(percentualeFound);
    }
    
    /**
    * Test crea da date + aggiungi/togli ricavo custom + errori
    */
    static testMethod void testCreaDaDate(){
        
        prepareData();
        
        Date dataOdierna = Date.today();
        Date dataInizioLineItem = Date.newInstance(dataOdierna.year(), dataOdierna.month(), dataOdierna.day()).addDays(1);
        Date dataFineLineItem = dataInizioLineItem.addMonths(2);
        
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
        
        ControllerRicavi ctrlRicavi = new ControllerRicavi(lineitem);
        ctrlRicavi.initRicaviToDelete();
        ctrlRicavi.setParentValues(lineitem);
        ctrlRicavi.creaRicaviDaDate();
        ctrlRicavi.resetRicaviToDelete(lineitem);
        ctrlRicavi.customSave();
        
        // 3 + totale
        System.assertEquals(4,ctrlRicavi.ricavi.size());
        Decimal totaleRicavi = 0;
        for(Ricavo__c ricavo : ctrlRicavi.ricavi){
            if(ricavo.Mese__c == 'Totale'){
                totaleRicavi = ricavo.Valore__c;
                break;
            }
        }
        System.assertEquals(totaleRicavi,lineitem.Totale__c);
        
        ctrlRicavi.updateCheckRicavi(lineitem);
        String incoerenze = ctrlRicavi.checkRicavi(lineitem);
        System.assertEquals(incoerenze,null);
        
        ctrlRicavi.controllaSeEsistonoRicaviPersonalizzati();
        System.assert(!ctrlRicavi.ricaviPersonalizzati);
        
        ctrlRicavi.addRicaviCustom();
        Ricavo__c ricavoCustom = ctrlRicavi.ricavi[ctrlRicavi.ricavi.size()-2];
        ricavoCustom.Anno__c = String.valueOf(dataOdierna.year()+1);
        ricavoCustom.Mese__c = ControllerRicavi.mesiMap.get(dataOdierna.month());
        ricavoCustom.Valore__c = 10;
        
        Apexpages.currentPage().getParameters().put('updatedRicavo',String.valueOf(ricavoCustom.Order__c));
        ctrlRicavi.checkTotaliAndUpdateRicavi();
        
        System.debug(ctrlRicavi.ricavi);
        
        ctrlRicavi.indexApplicaDifferenza = 0;
        ctrlRicavi.applicaDifferenza();
        
        System.debug(ctrlRicavi.ricavi);
        System.debug(lineitem);
        System.debug([SELECT Id, Valore__c FROM Ricavo__c WHERE Line_Item__c = :lineitem.id AND Id NOT IN :ctrlRicavi.ricavi]);
        LineItemTriggerHandler.skipValidationTotali = true;
        ctrlRicavi.customSave();
        
        ctrlRicavi.controllaSeEsistonoRicaviPersonalizzati();
        System.assert(ctrlRicavi.ricaviPersonalizzati);
        
        ctrlRicavi.creaRicaviDaDate();
        ctrlRicavi.customSave();

        ctrlRicavi.indexRicavoToDelete = ctrlRicavi.ricavi.size()-2;    
        ctrlRicavi.deleteRicaviCustom();
        
        boolean errorOccurred = false;      
        ctrlRicavi.saveTmpRicavi();
        try{
            ctrlRicavi.customSave();
        }catch(Exception e){
            errorOccurred = true;
            ctrlRicavi.restoreFromTmpRicavi();
        }
        LineItemTriggerHandler.skipValidationTotali = false;
        update lineitem; // test validazione totali
        System.assert(errorOccurred);
        
    }
    
    
    static testMethod void testRipianificazione(){
        
        prepareData();
        
        Date dataOdierna = Date.today();
        Date dataInizioLineItem = Date.newInstance(dataOdierna.year(), dataOdierna.month(), dataOdierna.day()).addDays(1);
        Date dataFineLineItem = dataInizioLineItem.addMonths(2);
        
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
                    totale__c = 1000,
                    Data_sospensione_erogazione__c = dataOdierna
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
        
        LineItem__c lineitemRipianificazione = new LineItem__c(
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
        insert lineitemRipianificazione;
        
        ControllerRicavi ctrlRicaviRipianificazione = new ControllerRicavi();
        ctrlRicaviRipianificazione.getRicaviNegativi(lineitem.id,lineitemRipianificazione.id);
        ctrlRicaviRipianificazione.calcolaRicavi(lineitem,lineitemRipianificazione);
        
        ControllerRicavi ctrlRicaviOriginale = new ControllerRicavi(lineitem);
        
    }
    
    static testMethod void creaRicaviDaDateVetrina()
    {
        Opportunity o = new Opportunity(name='test',CloseDate=date.today(),stageName='test');
        insert o;
        LineItem__c li = new LineItem__c(Opportunity__c=o.id,start_Date__c=date.newInstance(2013,11,1),end_Date__c=date.newInstance(2014,9,30),totale__c=200);
        insert li;

        String prefixRicavo = Ricavo__c.SObjectType.getDescribe().getKeyPrefix();

        ControllerRicavi c = new ControllerRicavi(li);
        c.setParentValues(li);
        c.ricavi = new List<Ricavo__c>();
        c.ricavi.add(new Ricavo__c(Id=Id.valueOf(prefixRicavo+'000000000000'), Mese__c='Totale'));
        c.ricavi.add(new Ricavo__c(Id=Id.valueOf(prefixRicavo+'000000000666'), Mese__c='Dicembre', Anno__c='2013'));

        Test.startTest();
        c.creaRicaviDaDateVetrina(80);
        Test.stopTest();
        for (Ricavo__c rc : c.ricavi) {
            System.Debug('PuntoDebug - rc: '+rc);
        }

        System.assertEquals(1, c.ricaviToDelete.size());
        System.assertEquals(Id.valueOf(prefixRicavo+'000000000000'), c.ricaviToDelete.get(0).Id);
        System.assertEquals(12, c.ricavi.size());

        for (Ricavo__c rc : c.ricavi) {
            if (rc.Mese__c == 'Totale') { //Totale
                System.assertEquals(200, rc.Valore__c);
                System.assertEquals(100, rc.Percentuale_applicata__c);
            } else if (rc.Mese__c == ControllerRevenueApplication.mesiMap.get(11)) { //First Month
                System.assertEquals(160, rc.Valore__c);
                System.assertEquals(80, rc.Percentuale_applicata__c);
            } else { //Other months
                System.assertEquals(4, rc.Valore__c);
                System.assertEquals(2, rc.Percentuale_applicata__c);
                if (rc.Mese__c == 'Dicembre' && rc.Anno__c == '2013') {
                    System.assertEquals(prefixRicavo+'000000000666', rc.Id);
                }
            }
        }
    }
    
    
    private static void setDataChiusuraRicavi(){
        Date dataOdierna = Date.today();
        
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
    }
    
    private static void prepareData(){
        setDataChiusuraRicavi();
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
            Breakeven_cost__c = 0       
        );
        insert product;
        
    }
}