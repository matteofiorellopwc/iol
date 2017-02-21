@isTest
public class CPCUpdateAutomationControllerTest {

    public static DfpLineItemService.LineItemPage testDfpResult; //Fake Answer
    static {
        testDfpResult = new DfpLineItemService.LineItemPage();
        testDfpResult.results = new List<DfpLineItemService.LineItem>();
        DfpLineItemService.LineItem dfpLI = new DfpLineItemService.LineItem();
        dfpLI.id = 100;
        DfpLineItemService.Stats stats = new DfpLineItemService.Stats();
        stats.clicksDelivered = 100;
        dfpLI.stats = stats;
        testDfpResult.results.add(dfpLI);
    }

    public static LineItem__c getLIPrepared() {
        Opportunity opp = utilityTest.insertDfpOasOpp();
        LineItem__c li = [SELECT Id FROM LineItem__c WHERE Opportunity__c = :opp.Id AND Ad_Server__c = 'DFP' LIMIT 1];
        li.Delivery_Model__c = 'CPC';
        li.Duration__c = 'LIFETIME';
        li.Type_DFP__c = 'PRICE_PRIORITY';
        li.Id_DFP__c = 666;
        li.CPCQuantityAutomationUpdated__c = false;
        Integer currYear = System.today().year();
        li.Start_date__c = Date.newInstance(currYear+1, 1, 1);
        li.End_date__c = li.Start_Date__c;
        insert new dataChiusuraRicavo__c(Name='local', Data__c = Date.newInstance(currYear-1,01,01)); //Custom Setting
        insert new dataChiusuraRicavo__c(Name='nazionale', Data__c = Date.newInstance(currYear-1,01,01)); //Custom Setting
        return li;
    }
	
    @isTest static void setLIEmpty() {
        Test.startTest();
        CPCUpdateAutomationController ctrl = new CPCUpdateAutomationController();
        ctrl.month = '1';
        ctrl.setLI();
        Test.stopTest();

        System.assertEquals(0, ctrl.mapWrappers.size());
    }

    @isTest static void setLI() {
        //Valid LI
        LineItem__c liOK = getLIPrepared();
        update liOK;

        Test.startTest();
        CPCUpdateAutomationController ctrl = new CPCUpdateAutomationController();
        ctrl.month = '1';
        ctrl.year = String.valueOf(liOK.Start_Date__c.year());
        ctrl.setLI();
        Test.stopTest();

        System.assertEquals(1, ctrl.mapWrappers.size());
    }

    @isTest static void checkLIConfigurationOK() {
        //Valid LI
        LineItem__c liOK = getLIPrepared();
        String currYear = String.valueOf(System.now().year()+1);
        update liOK;
        insert new Revenue_application__c(Mese__c='Gennaio', Line_Item__c=liOK.Id, Percentuale_applicata__c = 100, Anno__c=currYear);
        insert new Revenue_application__c(Mese__c=CPCUpdateAutomationController.REVENUE_TOTAL, Percentuale_applicata__c = 100, Line_Item__c=liOK.Id);
        insert new Ricavo__c(Mese__c='Gennaio', Line_Item__c=liOK.Id, Percentuale_applicata__c = 100, Anno__c=currYear);
        insert new Ricavo__c(Mese__c=CPCUpdateAutomationController.REVENUE_TOTAL, Percentuale_applicata__c = 100, Line_Item__c=liOK.Id);

        Test.startTest();
        CPCUpdateAutomationController ctrl = new CPCUpdateAutomationController();
        ctrl.month = '1';
        ctrl.year = String.valueOf(liOK.Start_Date__c.year());
        ctrl.setLI(); //Needed to populate Map
        ctrl.mapWrappers.get(liOK.Id).isUpdatable = true; //Remains true
        ctrl.checkLIConfiguration();
        Test.stopTest();

        System.assertEquals('', ctrl.mapWrappers.get(liOK.Id).error);
        System.assert(ctrl.mapWrappers.get(liOK.Id).isUpdatable);
    }

    @isTest static void checkLIConfigurationKO() {
        //Not valid LI, date in different month
        LineItem__c liKO = getLIPrepared();
        Date firstDayOfMonth = liKO.Start_Date__c.toStartOfMonth();
        Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month())-1);
        liKO.End_Date__c = lastDayOfMonth;
        update liKO;

        Test.startTest();
        CPCUpdateAutomationController ctrl = new CPCUpdateAutomationController();
        ctrl.month = '1';
        ctrl.year = String.valueOf(liKO.Start_Date__c.year());
        ctrl.setLI(); //Needed to populate Map
        ctrl.mapWrappers.get(liKO.Id).isUpdatable = true;
        ctrl.checkLIConfiguration();
        Test.stopTest();

        System.assertNotEquals('', ctrl.mapWrappers.get(liKO.Id).error);
        System.assert(!ctrl.mapWrappers.get(liKO.Id).isUpdatable);
    }

    @isTest static void checkLIConfigurationKORevenue() {
        //Not valid LI, date in different month
        LineItem__c liKOforRevenue = getLIPrepared();
        update liKOforRevenue;
        insert new Revenue_application__c(Mese__c='Febbraio', Line_Item__c=liKOforRevenue.Id, Percentuale_applicata__c = 100);
        insert new Revenue_application__c(Mese__c=CPCUpdateAutomationController.REVENUE_TOTAL, Percentuale_applicata__c = 100, Line_Item__c=liKOforRevenue.Id);

        Test.startTest();
        CPCUpdateAutomationController ctrl = new CPCUpdateAutomationController();
        ctrl.month = '1';
        ctrl.year = String.valueOf(liKOforRevenue.Start_Date__c.year());
        ctrl.setLI(); //Needed to populate Map
        ctrl.mapWrappers.get(liKOforRevenue.Id).isUpdatable = true;
        ctrl.checkLIConfiguration();
        Test.stopTest();

        System.assertNotEquals('', ctrl.mapWrappers.get(liKOforRevenue.Id).error);
        System.assert(!ctrl.mapWrappers.get(liKOforRevenue.Id).isUpdatable);
    }

    @isTest static void checkLIConfigurationKORicavo() {
        //Not valid LI, date in different month
        LineItem__c liKOforRevenue = getLIPrepared();
        String currYear = String.valueOf(System.now().year()+1);
        update liKOforRevenue;
        insert new Revenue_application__c(Mese__c='Gennaio', Line_Item__c=liKOforRevenue.Id, Percentuale_applicata__c = 100, Anno__c=currYear);
        insert new Revenue_application__c(Mese__c=CPCUpdateAutomationController.REVENUE_TOTAL, Percentuale_applicata__c = 100, Line_Item__c=liKOforRevenue.Id);
        insert new Ricavo__c(Mese__c='Febbraio', Line_Item__c=liKOforRevenue.Id, Percentuale_applicata__c = 100, Anno__c=currYear);
        insert new Ricavo__c(Mese__c=CPCUpdateAutomationController.REVENUE_TOTAL, Percentuale_applicata__c = 100, Line_Item__c=liKOforRevenue.Id);

        Test.startTest();
        CPCUpdateAutomationController ctrl = new CPCUpdateAutomationController();
        ctrl.month = '1';
        ctrl.year = String.valueOf(liKOforRevenue.Start_Date__c.year());
        ctrl.setLI(); //Needed to populate Map
        ctrl.mapWrappers.get(liKOforRevenue.Id).isUpdatable = true;
        ctrl.checkLIConfiguration();
        Test.stopTest();

        System.assertNotEquals('', ctrl.mapWrappers.get(liKOforRevenue.Id).error);
        System.assert(!ctrl.mapWrappers.get(liKOforRevenue.Id).isUpdatable);
    }

    @isTest static void getInfoFromDFP() {
        LineItem__c liOK = getLIPrepared();
        String currYear = String.valueOf(System.now().year()+1);
        liOK.Id_DFP__c=100;
        update liOK;
        insert new Revenue_application__c(Mese__c='Gennaio', Line_Item__c=liOK.Id, Percentuale_applicata__c = 100, Anno__c=currYear);
        insert new Revenue_application__c(Mese__c=CPCUpdateAutomationController.REVENUE_TOTAL, Percentuale_applicata__c = 100, Line_Item__c=liOK.Id);
        insert new Ricavo__c(Mese__c='Gennaio', Line_Item__c=liOK.Id, Percentuale_applicata__c = 100, Anno__c=currYear);
        insert new Ricavo__c(Mese__c=CPCUpdateAutomationController.REVENUE_TOTAL, Percentuale_applicata__c = 100, Line_Item__c=liOK.Id);

        Test.startTest();
        CPCUpdateAutomationController ctrl = new CPCUpdateAutomationController();
        ctrl.month = '1';
        ctrl.year = String.valueOf(liOK.Start_Date__c.year());
        ctrl.setLI(); //Needed to populate Map
        ctrl.mapWrappers.get(liOK.Id).isUpdatable = true;
        ctrl.checkLIConfiguration();
        ctrl.getInfoFromDFP();
        Test.stopTest();

        System.assertEquals(100, ctrl.mapWrappers.get(liOK.Id).clickDFP);
    }

@isTest static void updateLI1() {
        LineItem__c liOK = getLIPrepared();
        liOK.Id_DFP__c=100;
        liOK.sconto__c = 0;
        liOK.Quantita__c = 10;
        liOk.Prezzo_listino__c = 10;
        liOK.Prezzo_net__c = 10;
        liOK.Prezzo_net_net__c = 10;
        liOK.Totale__c = 100;
        liOK.clicksDelivered__c = 10;
        liOK.Ultima_modifica_prezzo__c = 'netnetprice';
        LineItemTriggerHandler.skipValidationTotali = true;
        update liOK;
        Revenue_application__c raJ = new Revenue_application__c(Mese__c='Gennaio', Line_Item__c=liOK.Id, Percentuale_applicata__c = 100, Valore__c=100, Anno__c=String.valueOf(System.today().year()+1));
        insert raJ;
        Revenue_application__c raT = new Revenue_application__c(Mese__c=CPCUpdateAutomationController.REVENUE_TOTAL, Percentuale_applicata__c = 100, Line_Item__c=liOK.Id, Valore__c=100, Anno__c=String.valueOf(System.today().year()+1));
        LineItemTriggerHandler.skipValidationTotali = true;
        LineItemTriggerHandler.skipUpdateLineItem = false;      
        insert raT;
        List<Revenue_application__c> revenuesToInsert = new List<Revenue_application__c>();
        revenuesToInsert.add(raJ);
        revenuesToInsert.add(raT);
        //insert revenuesToInsert;
        Ricavo__c rcJ = new Ricavo__c(Mese__c='Gennaio', Line_Item__c=liOK.Id, Percentuale_applicata__c = 100, Valore__c=100, Anno__c=String.valueOf(System.today().year()+1));
        //insert rcJ;
        Ricavo__c rcT = new Ricavo__c(Mese__c=CPCUpdateAutomationController.REVENUE_TOTAL, Percentuale_applicata__c = 100, Line_Item__c=liOK.Id, Valore__c=100, Anno__c=String.valueOf(System.today().year()+1));
        LineItemTriggerHandler.skipValidationTotali = true;
        LineItemTriggerHandler.skipUpdateLineItem = false;      
        //insert rcT;
        List<Ricavo__c> ricaviToInsert = new List<Ricavo__c>();
        ricaviToInsert.add(rcJ);
        ricaviToInsert.add(rcT);
        //insert ricaviToInsert;
        
        Test.startTest();

        CPCUpdateAutomationController ctrl = new CPCUpdateAutomationController();
        ctrl.month = '1';
        ctrl.year = String.valueOf(liOK.Start_Date__c.year());
        ctrl.setLI(); //Needed to populate Map
        ctrl.checkLIConfiguration();
        ctrl.getInfoFromDFP();
        ctrl.mapWrappers.get(liOK.Id).toUpdate = true;
        ctrl.updateLI();

        LineItem__c li = [SELECT Id, Duration__c, Quantita__c, clicksDelivered__c, Totale__c, Prezzo_net_net__c, CPCQuantityAutomationUpdated__c FROM LineItem__c WHERE Id = :liOK.Id];
        System.assertEquals('LIFETIME', li.Duration__c);
        System.assertEquals(10, li.Quantita__c);
        System.assertEquals(10, li.clicksDelivered__c);
        System.assertEquals(li.Prezzo_net_net__c * li.Quantita__c, li.Totale__c);
        //System.assert(li.CPCQuantityAutomationUpdated__c);
        raJ = [SELECT Id, Percentuale_applicata__c, Valore__c, Numero_click__c FROM Revenue_application__c WHERE Id=:raJ.Id];
        System.assertEquals(100, raJ.Percentuale_applicata__c);
        System.assertEquals(100, raJ.Numero_click__c);
        //System.assertEquals(li.Totale__c, raJ.Valore__c);
        raT = [SELECT Id, Percentuale_applicata__c, Valore__c, Numero_click__c FROM Revenue_application__c WHERE Id=:raT.Id];
        System.assertEquals(100, raT.Percentuale_applicata__c);
        System.assertEquals(100, raT.Numero_click__c);
        //System.assertEquals(li.Totale__c, raT.Valore__c);
        

        Test.stopTest();
    }
    @isTest static void updateLI2() {
        LineItem__c liOK = getLIPrepared();
        liOK.Id_DFP__c=100;
        liOK.sconto__c = 0;
        liOK.Quantita__c = 100;
        liOk.Prezzo_listino__c = 1;
        liOK.Prezzo_net__c = 1;
        liOK.Prezzo_net_net__c = 1;
        liOK.Totale__c = 100;
        liOK.Ultima_modifica_prezzo__c = 'netnetprice';
        LineItemTriggerHandler.skipValidationTotali = true;
        update liOK;
        Revenue_application__c raJ = new Revenue_application__c(Mese__c='Gennaio', Line_Item__c=liOK.Id, Percentuale_applicata__c = 100, Valore__c=100, Anno__c=String.valueOf(System.today().year()+1));
        //insert raJ;
        Revenue_application__c raT = new Revenue_application__c(Mese__c=CPCUpdateAutomationController.REVENUE_TOTAL, Percentuale_applicata__c = 100, Line_Item__c=liOK.Id, Valore__c=100, Anno__c=String.valueOf(System.today().year()+1));
        LineItemTriggerHandler.skipValidationTotali = true;
        LineItemTriggerHandler.skipUpdateLineItem = true;      
        //insert raT;
        List<Revenue_application__c> revenuesToInsert = new List<Revenue_application__c>();
        revenuesToInsert.add(raJ);
        revenuesToInsert.add(raT);
        //insert revenuesToInsert;
        Ricavo__c rcJ = new Ricavo__c(Mese__c='Gennaio', Line_Item__c=liOK.Id, Percentuale_applicata__c = 100, Valore__c=100, Anno__c=String.valueOf(System.today().year()+1));
        insert rcJ;
        Ricavo__c rcT = new Ricavo__c(Mese__c=CPCUpdateAutomationController.REVENUE_TOTAL, Percentuale_applicata__c = 100, Line_Item__c=liOK.Id, Valore__c=100, Anno__c=String.valueOf(System.today().year()+1));
        LineItemTriggerHandler.skipValidationTotali = true;
        LineItemTriggerHandler.skipUpdateLineItem = false;      
        //insert rcT;
        List<Ricavo__c> ricaviToInsert = new List<Ricavo__c>();
        ricaviToInsert.add(rcJ);
        ricaviToInsert.add(rcT);
        //insert ricaviToInsert;
        
        Test.startTest();
        CPCUpdateAutomationController ctrl = new CPCUpdateAutomationController();
        ctrl.month = '1';
        ctrl.year = String.valueOf(liOK.Start_Date__c.year());
        ctrl.setLI(); //Needed to populate Map
        ctrl.checkLIConfiguration();
        ctrl.getInfoFromDFP();
        //ctrl.mapWrappers.get(liOK.Id).toUpdate = true;
        ctrl.updateLI();
         LineItem__c li = [SELECT Id, Duration__c, Quantita__c, clicksDelivered__c, Totale__c, Prezzo_net_net__c, CPCQuantityAutomationUpdated__c FROM LineItem__c WHERE Id = :liOK.Id];
        rcJ = [SELECT Id, Percentuale_applicata__c, Valore__c FROM Ricavo__c WHERE Id=:rcJ.Id];
        System.assertEquals(100, rcJ.Percentuale_applicata__c);
        System.assertEquals(li.Totale__c, rcJ.Valore__c);
         Test.stopTest();
    }
    
    @isTest static void updateLI3() {
        LineItem__c liOK = getLIPrepared();
        liOK.Id_DFP__c=100;
        liOK.sconto__c = 0;
        liOK.Quantita__c = 100;
        liOk.Prezzo_listino__c = 1;
        liOK.Prezzo_net__c = 1;
        liOK.Prezzo_net_net__c = 1;
        liOK.Totale__c = 100;
        liOK.Ultima_modifica_prezzo__c = 'netnetprice';
        LineItemTriggerHandler.skipValidationTotali = true;
        update liOK;
        Revenue_application__c raJ = new Revenue_application__c(Mese__c='Gennaio', Line_Item__c=liOK.Id, Percentuale_applicata__c = 100, Valore__c=100, Anno__c=String.valueOf(System.today().year()+1));
        //insert raJ;
        Revenue_application__c raT = new Revenue_application__c(Mese__c=CPCUpdateAutomationController.REVENUE_TOTAL, Percentuale_applicata__c = 100, Line_Item__c=liOK.Id, Valore__c=100, Anno__c=String.valueOf(System.today().year()+1));
        LineItemTriggerHandler.skipValidationTotali = true;
        LineItemTriggerHandler.skipUpdateLineItem = true;      
        //insert raT;
        List<Revenue_application__c> revenuesToInsert = new List<Revenue_application__c>();
        revenuesToInsert.add(raJ);
        revenuesToInsert.add(raT);
        //insert revenuesToInsert;
        Ricavo__c rcJ = new Ricavo__c(Mese__c='Gennaio', Line_Item__c=liOK.Id, Percentuale_applicata__c = 100, Valore__c=100, Anno__c=String.valueOf(System.today().year()+1));
        //insert rcJ;
        Ricavo__c rcT = new Ricavo__c(Mese__c=CPCUpdateAutomationController.REVENUE_TOTAL, Percentuale_applicata__c = 100, Line_Item__c=liOK.Id, Valore__c=100, Anno__c=String.valueOf(System.today().year()+1));
        LineItemTriggerHandler.skipValidationTotali = true;
        LineItemTriggerHandler.skipUpdateLineItem = false;      
        insert rcT;
        List<Ricavo__c> ricaviToInsert = new List<Ricavo__c>();
        ricaviToInsert.add(rcJ);
        ricaviToInsert.add(rcT);
        //insert ricaviToInsert;
        
        Test.startTest();
        CPCUpdateAutomationController ctrl = new CPCUpdateAutomationController();
        ctrl.month = '1';
        ctrl.year = String.valueOf(liOK.Start_Date__c.year());
        ctrl.setLI(); //Needed to populate Map
        ctrl.checkLIConfiguration();
        ctrl.getInfoFromDFP();
        ctrl.mapWrappers.get(liOK.Id).toUpdate = true;
        ctrl.updateLI();
         LineItem__c li = [SELECT Id, Duration__c, Quantita__c, clicksDelivered__c, Totale__c, Prezzo_net_net__c, CPCQuantityAutomationUpdated__c FROM LineItem__c WHERE Id = :liOK.Id];
        rcT = [SELECT Id, Percentuale_applicata__c, Valore__c FROM Ricavo__c WHERE Id=:rcT.Id];
        System.assertEquals(100, rcT.Percentuale_applicata__c);
        System.assertEquals(li.Totale__c, rcT.Valore__c);
         Test.stopTest();
    }
}