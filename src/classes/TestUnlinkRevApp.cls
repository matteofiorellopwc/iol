/**
 *  Date:   2013/02/19
 *  Description:    Test for ExtensionEditTickets class and viewTicket VF page
 *  Author: Ivano Cortese
 */
@isTest
private class TestUnlinkRevApp {

    static testMethod void myUnitTestTicket() {
        Provincia__c prov = new Provincia__c(
            Name = 'Sondrio',
            Sigla__c = 'SO',
            Regione__c = 'Lombardia');
        insert prov;
        
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
        
        Indirizzo_Spedizione__c address = new Indirizzo_Spedizione__c (
            Via__c = 'via Dolzino 114',
            Citta__c = 'Chiavenna',
            Cap__c = '23022',
            Stato__c = 'Italia',
            Provincia__c = prov.Id,
            Email_di_Spedizione__c = 'test@email.com');
        insert address;
        
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
            StageName = '50%',
            CloseDate = Date.today()+5,
            Canale_di_vendita__c = 'DIRETTA',
            Commissione_Agenzia__c = 0);
        insert opty;
        
        LineItem__c li = new LineItem__c(
            Opportunity__c = opty.Id);
        insert li;
        
        Revenue_application__c ra = new Revenue_application__c(
            Anno__c = Date.today().year()+'',
            Mese__c = Date.today().month()+'',
            Line_Item__c = li.Id);
        insert ra;
        
        Quote q = new Quote(
            OpportunityId = opty.Id,
            Name = 'Test Quote',
            Modalita_di_spedizione__c = 'PDF');
        insert q;
        
        //Check Amministrativo
        opty.Check_amministrativo__c = true;
        update opty;
        
        Ticket_Fatturazione__c tkt = new Ticket_Fatturazione__c(
            Ticket_manuale__c = true,
            Opportunity__c = opty.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(tkt);
        
        insert tkt;
        ra.Ticket_Fatturazione__c = tkt.Id;
        update ra;
        PageReference pageRef = new PageReference('/apex/viewTicket?Id='+tkt.Id);
        Test.setCurrentPageReference(pageRef);
        ExtensionEditTicket eet = new ExtensionEditTicket(sc);
        eet.table.get(0).sel = true;
        eet.delRaRef();
    }
}