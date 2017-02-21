@isTest
private class ControllerCheckAdminTest {

    static void printLimits(){
        system.debug('Limits.getQueries(): '+Limits.getQueries());
        system.debug('Limits.getLimitQueries(): '+Limits.getLimitQueries());
    }

    static testMethod void myUnitTest() {
        Test.startTest();
        Provincia__c provSO = new Provincia__c(
            Name = 'Sondrio',
            Sigla__c = 'SO',
            Regione__c = 'Lombardia');
        insert provSO;
        
        Provincia__c provMI = new Provincia__c(
            Name = 'Milano',
            Sigla__c = 'MI',
            Regione__c = 'Lombardia');
        insert provMI;
        
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
        
        RecordType anagFattRT = [select Id from RecordType where DeveloperName = 'Anagrafica_di_Fatturazione' AND SobjectType = 'Account'];
        
        Account a = new Account(
            Name = 'Test Account',
            RecordTypeId = anagFattRT.Id,
            //BillingStreet = 'via Torino 2',
            //BillingCity = 'Milano',
            //BillingState = 'MI',
            //BillingPostalCode = '20100',
            //BillingCountry = 'Italia',
            Ragione_sociale__c = 'Test Account S.p.a.',
            Ragione_sociale_fattura__c = 'Test Account S.p.a.',
            Partita_IVA__c = '80090012345',
            Codice_fiscale__c = '80090012345');
        insert a;
        
        Product2 prod = new Product2(
            Name = 'Test Product',
            BasePrice__c = 0.1110,
            Breakeven_cost__c = 0.1000);
        insert prod;
        
        AdUnit__c adu = new  AdUnit__c(
            Name = 'Test AdUnit',
            Status__c = 'ACTIVE');
        insert adu;
        
        Opportunity opty = new Opportunity(
            AccountId = brand.Id,
            Anagrafica_di_Fatturazione__c = a.Id,
            Name = 'Test Opty',
            StageName = 'Chiusa vinta',
            HiddenValidation__c=true,
            CloseDate = Date.today()+5,
            Canale_di_vendita__c = 'DIRETTA',
            Commissione_Agenzia__c = 0);
        insert opty;
        
        Quote q = new Quote(
            //Indirizzo_Spedizione_Alternativo__c = address.Id,
            OpportunityId = opty.Id,
            Name = 'Test Quote',
            //Metodo_di_pagamento__c = 'BON',
            Modalita_di_spedizione__c = 'PDF');
        insert q;
        
        
        //First controller
        PageReference pageRef = new PageReference('checkAdm?Id='+opty.Id);
        Test.setCurrentPageReference(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(opty);
        ControllerCheckAdm cca = new ControllerCheckAdm(sc);
        
        
        //Second controller
        a.BillingStreet = 'via Torino 2';
        a.BillingCity = 'Milano';
        a.BillingState = 'MI';
        a.BillingPostalCode = '20100';
        a.BillingCountry = 'Italia';
        update a;
        
        
        Indirizzo_Spedizione__c address = new Indirizzo_Spedizione__c (
            Via__c = 'via Dolzino 114',
            Citta__c = 'Chiavenna',
            Cap__c = '23022',
            Stato__c = 'Italia',
            Provincia__c = provSO.Id,
            Email_di_Spedizione__c = 'test@email.com');
        insert address;
        
        Quote q2 = new Quote(
            Indirizzo_Spedizione_Alternativo__c = address.Id,
            OpportunityId = opty.Id,
            Name = 'Test Quote',
            Metodo_di_pagamento__c = 'BONIF',
            Modalita_di_spedizione__c = 'PDF/EMAIL');
        insert q2;
        opty.SyncedQuoteId = q2.Id;
        opty.StageName = 'Chiusa vinta';
        update opty;
        Test.stopTest();
        
        ControllerCheckAdm cca1 = new ControllerCheckAdm(sc);
        cca1.checkFlag();
        cca1.back();
        cca1.resetCheckAdm();
        cca1.excludeFatt();
        cca1.includeFatt();
    }
}