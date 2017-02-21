/**
 *  Date:   2014/05/09
 *  Description:    Controller for ControllerManualBill.cls and ScheduledTicketCreation.cls for both manual and scheduled Ticket creation
 *  Author: Luca Venanzetti
 */

@isTest
private class UtilFatturazioneTest {

	private static Id RT_ID_ACCOUNT_BRAND = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Brand').getRecordTypeId();
	private static Id RT_ID_ACCOUNT_ANAG_FATTURAZIONE = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Anagrafica di Fatturazione').getRecordTypeId();
	
	private static Provincia__c provincia = null;
	private static Account accountBrand = null;
	private static Indirizzo_Spedizione__c indirizzoSpedizione = null;
	private static Account accountAnagFatturazione = null;
	private static Product2 prodotto = null;
	private static AdUnit__c adUnit = null;
	private static Opportunity opportunita = null;

	static {
		
		Test.startTest();

		provincia = new Provincia__c(
            Name = 'Sondrio',
            Sigla__c = 'SO',
            Regione__c = 'Lombardia');
        insert provincia;

        accountBrand = new Account(
            Name = 'Test Account',
            RecordTypeId = RT_ID_ACCOUNT_BRAND,
            BillingStreet = 'via Dolzino 114',
            BillingCity = 'Sondrio',
            BillingState = 'SO',
            BillingPostalCode = '23022',
            BillingCountry = 'Italia',
            Ragione_sociale__c = 'Test Brand',
            Codice_fiscale__c = '80090012345');
        insert accountBrand;

        indirizzoSpedizione = new Indirizzo_Spedizione__c (
            Via__c = 'via Dolzino 114',
            Citta__c = 'Chiavenna',
            Cap__c = '23022',
            Stato__c = 'Italia',
            Provincia__c = provincia.Id,
            Email_di_Spedizione__c = 'test@email.com');
        insert indirizzoSpedizione;

        accountAnagFatturazione = new Account(
            Name = 'Test Account',
            RecordTypeId = RT_ID_ACCOUNT_ANAG_FATTURAZIONE,
            BillingStreet = 'via Torino 2',
            BillingCity = 'Milano',
            BillingPostalCode = '20100',
            BillingCountry = 'Italia',
            Ragione_sociale__c = 'Test Account S.p.a.',
            Partita_IVA__c = '80090012345',
            Codice_fiscale__c = '80090012345');
        insert accountAnagFatturazione;

        prodotto = new Product2(
            Name = 'Test Product',
            BasePrice__c = 0.1110,
            Breakeven_cost__c = 0.1000);
        insert prodotto;

        adUnit = new  AdUnit__c(
            Name = 'Test AdUnit',
            Status__c = 'ACTIVE');
        insert adUnit;

        opportunita = new Opportunity(
            AccountId = accountBrand.Id,
            Anagrafica_di_Fatturazione__c = accountAnagFatturazione.Id,
            Name = 'Test Opty',
            StageName = '50%',
            CloseDate = Date.today()+5,
            Canale_di_vendita__c = 'DIRETTA',
            Commissione_Agenzia__c = 0);
        insert opportunita;

        Test.stopTest();

	}

	@isTest 
	private static void testManualTicketCreation() {
		system.debug(prodotto);
		LineItem__c lineItem = new LineItem__c(
            Opportunity__c = opportunita.Id);
            lineItem.Product__c=prodotto.id; 
        insert lineItem;
        
        Quote q = new Quote(
            OpportunityId = opportunita.Id,
            Name = 'Test Quote',
            Modalita_di_spedizione__c = 'PDF');
        insert q;
        
        //Check Amministrativo
        opportunita.Check_amministrativo__c = true;
        update opportunita;
        
        PageReference pageRef = new PageReference('/apex/manualTicket?optyId='+opportunita.Id);
        Test.setCurrentPageReference(pageRef);

        Ticket_Fatturazione__c ticketFatturazione = new Ticket_Fatturazione__c(
            Ticket_manuale__c = true,
            Opportunity__c = opportunita.Id);

        ApexPages.StandardController sc = new ApexPages.StandardController(ticketFatturazione);
        ControllerManualBill cmb = new ControllerManualBill(sc);
        opportunita.Escludi_da_fatt_auto__c = true;
        update opportunita;

        cmb = new ControllerManualBill(sc);

        cmb.tkt.Anno_riferimento__c = '2013';
        cmb.tkt.Mese_riferimento__c = 'Giugno';
        cmb.saveTkt();

        Ticket_Fatturazione__c tkt = [SELECT Id,Stato__c,Ticket_manuale__c,Quote__c,Account__c,Anno_riferimento__c FROM Ticket_Fatturazione__c WHERE Opportunity__c = :q.OpportunityId];
        System.assertEquals('Draft',tkt.Stato__c);
        System.assertEquals(true,tkt.Ticket_manuale__c);
        System.assertEquals(q.Id,tkt.Quote__c);
        System.assertEquals(accountAnagFatturazione.Id,tkt.Account__c);
        System.assertEquals('2013',tkt.Anno_riferimento__c);

        cmb.back();
        
        //Righe
        insert ticketFatturazione;
        pageRef = new PageReference('/apex/manualRow?Id='+ticketFatturazione.Id);
        Test.setCurrentPageReference(pageRef);
        ControllerManualBillRows cmbR = new ControllerManualBillRows();
        cmbR.saveRows();

        System.debug('RIGHE DI FATT: ' +[SELECT Id FROM Riga_Fatturazione__c WHERE Ticket_Fatturazione__c = :ticketFatturazione.Id]);

        cmbR.table.get(0).sel = true;
        cmbR.saveRows();

        System.debug('RIGHE DI FATT. 2: ' +[SELECT Id FROM Riga_Fatturazione__c WHERE Ticket_Fatturazione__c = :ticketFatturazione.Id]);
        cmbR.back();
        
        //Test Trigger before DeleteRow
        Riga_Fatturazione__c r = new Riga_Fatturazione__c(Ticket_Fatturazione__c = ticketFatturazione.Id);
        insert r;
        system.debug('@@Stato riga: '+r.Stato__c);
        r.Stato__c = 'Da inviare';
        update r;
        delete r;

        //Test Trigger before DeleteTicket
        delete ticketFatturazione;
	}
		
}