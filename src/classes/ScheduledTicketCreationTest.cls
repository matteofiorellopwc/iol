/**
 *  Date:   2012/11/22
 *  Description:    ScheduledTicketCreation Test Class
 *  Author: Ivano Cortese
 */
 
@isTest
private class ScheduledTicketCreationTest {

    static void printLimits(){
        system.debug('Limits.getQueries(): '+Limits.getQueries());
    }

    static testMethod void myUnitTest() {
        
        utilityTest.createFattoreCorrettivoFasce();
        
        LineItemTriggerHandler.skipUpdateLineItem = true;
        LineItemTriggerHandler.skipValidationTotali = true;
        LineItemTriggerHandler.skipValidationAdServer = true; 
        RevenueApplicationTriggerHandler.skipUpdateRevenues = true;   

        Date dataOdierna = Date.today();
        Date dataChiusuraRicavoDate = Date.newInstance(dataOdierna.year(),dataOdierna.month(),1);
        dataChiusuraRicavoDate = dataChiusuraRicavoDate.addYears(-4).addDays(-1);
        
        DataChiusuraRicavo__c dataChiusuraRicavo = new DataChiusuraRicavo__c();
        dataChiusuraRicavo.Name = 'nazionale';
        dataChiusuraRicavo.data__c = dataChiusuraRicavoDate;
        insert dataChiusuraRicavo;
        
        DataChiusuraRicavo__c dataChiusuraRicavoLocal = new DataChiusuraRicavo__c();
        dataChiusuraRicavoLocal.Name = 'local';
        dataChiusuraRicavoLocal.data__c = dataChiusuraRicavoDate;
        insert dataChiusuraRicavoLocal;
        
        EmailLog__c el = new EmailLog__c(name='Amministrazione',emails__c='test@test.com');
        insert el;
        
        Provincia__c prov = new Provincia__c(
            Name = 'Sondrio',
            Sigla__c = 'SO',
            Regione__c = 'Lombardia');
        insert prov;
        
        printLimits();
        
        RecordType brandRT = [select Id from RecordType where DeveloperName = 'Brand' AND SobjectType = 'Account'];
        
        Account brand = new Account(
            Name = 'Test Account',
            RecordTypeId = brandRT.Id,
            BillingStreet = 'via Dolzino 114',
            BillingCity = 'Sondrio',
            BillingState = 'SO',
            BillingPostalCode = '23022',
            BillingCountry = 'Italia',
            Ragione_sociale__c = 'Test Brand',
            //Partita_IVA__c = '80090012345',
            Codice_fiscale__c = '80090012345');
        insert brand;
        
        printLimits();
        
        RecordType anagFattRT = [select Id from RecordType where DeveloperName = 'Anagrafica_di_Fatturazione' AND SobjectType = 'Account'];
        
        Indirizzo_Spedizione__c address = new Indirizzo_Spedizione__c (
            Via__c = 'via Dolzino 114',
            Citta__c = 'Chiavenna',
            Cap__c = '23022',
            Stato__c = 'Italia',
            Provincia__c = prov.Id,
            Email_di_Spedizione__c = 'test@email.com');
        insert address;
        
        printLimits();
        
        Account a = new Account(
            Name = 'Test Account',
            RecordTypeId = anagFattRT.Id,
            BillingStreet = 'via Torino 2',
            BillingCity = 'Milano',
            //BillingState = 'MI',
            BillingPostalCode = '20100',
            BillingCountry = 'Italia',
            Ragione_sociale__c = 'Test Account S.p.a.',
            Partita_IVA__c = '80090012345',
            Codice_fiscale__c = '80090012345',
            check_amministrativo__c=true); 
        insert a;
        
        printLimits();
        
        Product2 prod = new Product2(
            Name = 'Test Product',
            BasePrice__c = 0.1110,
            Breakeven_cost__c = 0.1000);
        insert prod;
        
        Product2 prodPac = new Product2(
            Name = 'Test Product Pacchetto1',
            BasePrice__c = 0.1110,
            Breakeven_cost__c = 0.1000);
        insert prodPac;
        
        PacchettoCombo__c pc = new PacchettoCombo__c(
            Name = 'Test pacchetto',
            //Dimensione_Prodotto__c = '',
            Sconto_applicabile__c = true
            );
        insert pc;
        
        Pacchetto_Combo_Prodotto__c pcp = new Pacchetto_Combo_Prodotto__c(
            PacchettoCombo__c = pc.Id,
            Product__c = prodPac.Id,
            Start_Date__c = Date.today()+5,
            End_Date__c = Date.today()+5,
            Quantita__c = 1000,
            Listino__c = 100,
            Modificabile_in_line_item__c = 'Date;Quantità;');
        insert pcp;
                        
        printLimits();
        
        AdUnit__c adu = new  AdUnit__c(
            Name = 'Test \nit',
            Status__c = 'ACTIVE',
            IdDFP__c = 'test');
        insert adu;
        
        printLimits();
        
        Opportunity opty = new Opportunity(
            AccountId = brand.Id,
            Anagrafica_di_Fatturazione__c = a.Id,
            Name = 'Test Opty',
            StageName = '50%',
            HiddenValidation__c = true,
            CloseDate = Date.today()+5,
            Canale_di_vendita__c = 'DIRETTA',
            Commissione_Agenzia__c = 0,
            Email_agenzia_creativa__c = 'asd@asd.it');
        insert opty;

        Pacchetto_Combo_Opportunity__c pco = new Pacchetto_Combo_Opportunity__c(
            Name = 'Test pacchetto',
            Data_inizio__c = Date.today(),
            Data_fine__c = Date.today()+5,
            Listino_pacchetto__c = 100,
            Opportunity__c = opty.Id,
            PacchettoCombo__c = pc.Id,
            Quantita_totale__c = 10000);
        insert pco;
        
        printLimits();
        
        
        prod = UtilProduct.getProductsByIds(new set<id>{prod.id}).get(0);
        LineItem__c li = ExtensionAddProduct.addProducts(new list<Product2>{prod},null,opty.Id)[0];
        
        li.Start_Date__c = Date.newInstance(2013, 12, 1);
        li.End_Date__c = Date.newInstance(2013, 12, 1);
        li.Prezzo_net_net__c = 0.100;
        li.Quantita__c = 100000;
        li.skipValidationAdServer__c = true;
        update li;
        
        li = [select Id, Totale__c, Start_Date__c, End_Date__c, Quantita__c from LineItem__c where Opportunity__c = :opty.Id AND Product__c = :prod.Id];
        Revenue_application__c ra1 = new Revenue_application__c(Mese__c = 'Dicembre', Anno__c = '2013', Valore__c = li.totale__c, Percentuale_applicata__c = 100, Line_Item__c = li.Id);
        insert ra1;  
        
        ControllerRicavi ctrlRicavi = new ControllerRicavi(li);
        ctrlRicavi.setParentValues(li);
        ctrlRicavi.creaRicaviDaDate();
        ctrlRicavi.customSave();      
        
        printLimits();
        
        Test.startTest();
        
        Test.setCurrentPage(new PageReference('/apex/editPacchettoOpportunity?oppId=' + opty.Id + '&pacId=' + pc.Id));
        ExtensionEditPacchettoOpportunity eepo = new ExtensionEditPacchettoOpportunity(new ApexPages.StandardController(new Pacchetto_Combo_Opportunity__c()));
        
        eepo.customSave(false);  //false -> throw exception

        LineItemTriggerHandler.skipValidationTotali = true;
        Revenue_application__c ra2 = [select id,Line_Item__r.totale__c from revenue_application__c where Line_Item__r.Product__c =: prodPac.id and mese__c <> 'Totale'];
        system.debug('ra2 = '+ra2);
        ra2.Mese__c = 'Dicembre';
        ra2.Anno__c = '2013';
        ra2.Valore__c = ra2.Line_Item__r.totale__c;
        ra2.Percentuale_applicata__c = 100;
        update ra2;

        printLimits();
        
        system.debug([select id,mese__c,valore__c from revenue_application__c where line_item__r.opportunity__c =: opty.id]);
        

        
        opty.Approvata_commercialmente__c =true;
        opty.StageName = 'Chiusa vinta';
        update opty;
        printLimits();
                
        Quote q = new Quote(
            Indirizzo_Spedizione_Alternativo__c = address.Id,
            OpportunityId = opty.Id,
            Name = 'Test Quote',
            Metodo_di_pagamento__c = 'BONIF',
            Modalita_di_spedizione__c = 'PDF');
        insert q;
        printLimits();
        opty.Check_amministrativo__c = true;
        update opty;
        printLimits();
        
        Test.stopTest();
        
        ScheduledTicketCreation stc = new ScheduledTicketCreation();
        stc.execute(null);
        
        printLimits();
    }

    @isTest static void areRevenueADXProcessed() {
        LineItem__c liAdx = new LineItem__c(
            Type_DFP__c = 'AD_EXCHANGE'
        );

        List<Revenue_application__c> listRAok = new List<Revenue_application__c>{
            new Revenue_application__c(ADXPlacementUpdated__c=true, Line_Item__r = liAdx),
            new Revenue_application__c(ADXPlacementUpdated__c=true, Line_Item__r = liAdx)
        };
        List<Revenue_application__c> listRAko = new List<Revenue_application__c>{
            new Revenue_application__c(ADXPlacementUpdated__c=false, Line_Item__r = liAdx),
            new Revenue_application__c(ADXPlacementUpdated__c=true, Line_Item__r = liAdx)
        };

        Test.startTest(); 
        Boolean isProcessed = true;
        for(Revenue_application__c ra : listRAok){
            if(!ScheduledTicketCreation.isRevenueADXCPCProcessed(ra)){
                isProcessed = false;
            }
        }
        Boolean isNotProcessed = true;
        for(Revenue_application__c ra : listRAko){
            if(!ScheduledTicketCreation.isRevenueADXCPCProcessed(ra)){
                isNotProcessed = false;
            }
        }
        //Boolean isProcessed = ScheduledTicketCreation.areRevenueADXCPCProcessed(listRAok);
        //Boolean isNotProcessed = ScheduledTicketCreation.areRevenueADXCPCProcessed(listRAko);
        Test.stopTest();

        System.assert(isProcessed);
        System.assert(!isNotProcessed);
    }
}