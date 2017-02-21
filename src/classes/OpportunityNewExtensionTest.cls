@isTest
private class OpportunityNewExtensionTest {

	private static void prepareData(){
		insert new Provincia__c(sigla__c='MI', Regione__c='Milano');
	}

	private static Opportunity getOpty(String optyName) {
        Opportunity opp = new Opportunity(Name=optyName, StageName='Stage', CloseDate=System.today());
        insert opp;

        return opp;
	}

	@isTest static void traceSearchWithAccount() {
		OpportunityNewExtension oe = new OpportunityNewExtension(new ApexPages.StandardController(getOpty('OPTEST')));
		Account acc = new Account(Name='TestAcc');
		insert acc;
		oe.mapAccountFound.put(acc.Id, acc);
		oe.pIva = '12345678901';
		oe.opp.Name = 'OptName';
		oe.localU.isLocalUser = true;

		Test.startTest();
		oe.traceSearchWithAccount();
		Test.stopTest();

		List<LocalOpportunitySearch__c> listLOS = [SELECT Id, Name, Partita_Iva__c, Account__c FROM LocalOpportunitySearch__c];
		System.assertEquals(1, listLOS.size());
		System.assertEquals('OptName', listLOS.get(0).Name);
		System.assertEquals(acc.Id, listLOS.get(0).Account__c);
		System.assertEquals('12345678901', listLOS.get(0).Partita_Iva__c);
	}

	@isTest static void createNewOpportunity_OK() {
		prepareData();
		RecordType rtBrand = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND DeveloperName = 'Brand' LIMIT 1];
		Account brand = new Account(Name='Brand', RecordTypeId=rtBrand.Id,  BillingCity='MI', BillingStreet='street', BillingPostalCode='1234', BillingState='MI', BillingCountry='c');
		insert brand;
		RecordType rtFatt = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND DeveloperName = 'Anagrafica_di_Fatturazione' LIMIT 1];
		Account accFatt = new Account(Name='AnFatt', Metodo_di_pagamento__c='pag', Termini_di_pagamento__c='termini', Codice_IVA__c='666', RecordTypeId = rtFatt.Id, BillingCity='MI', BillingStreet='street', BillingPostalCode='1234', BillingState='MI', BillingCountry='c', Ragione_sociale_fattura__c='regFatt', Email_principale__c = 'test@email.com');
		insert accFatt;

		OpportunityNewExtension oe = new OpportunityNewExtension(new ApexPages.StandardController(getOpty('OPTEST')));
		oe.opp.Name = 'OP-666';
		oe.pIva = '12345678666';

		Test.startTest();
		Id oppId = oe.createNewOpportunity();
		Test.stopTest();

		System.assertNotEquals(null, oppId);
		List<Opportunity> listOpp = [SELECT Id, Name, Partita_IVA_cliente_Local__c, Note_fattura__c, Check_amministrativo__c,AccountId, Anagrafica_di_Fatturazione__c FROM Opportunity WHERE Id = :oppId];
		System.assertEquals(1, listOpp.size());
		System.assert(listOpp.get(0).Name.contains('OP-666'));
		System.assertEquals('12345678666', listOpp.get(0).Partita_IVA_cliente_Local__c);
		System.assertEquals('12345678666', listOpp.get(0).Note_fattura__c);
		System.assert(listOpp.get(0).Check_amministrativo__c);
		System.assertEquals(brand.Id, listOpp.get(0).AccountId);
		System.assertEquals(accFatt.Id, listOpp.get(0).Anagrafica_di_Fatturazione__c);
		List<Quote> listQ = [SELECT Id, Name, Metodo_di_pagamento__c, Termini_di_pagamento__c, Codice_IVA__c FROM Quote WHERE OpportunityId = :oppId];
		System.assertEquals(1, listQ.size());
		System.assertEquals('OP-666', listQ.get(0).Name);
		System.assertEquals('pag', listQ.get(0).Metodo_di_pagamento__c);
		System.assertEquals('termini', listQ.get(0).Termini_di_pagamento__c);
		System.assertEquals('666', listQ.get(0).Codice_IVA__c);
	}

	@isTest static void createNewOpportunity_KOAccount() {
		prepareData();
		List<Opportunity> listOpp;
		List<Quote> listQ;
		Id oppId;
		OpportunityNewExtension oe = new OpportunityNewExtension(new ApexPages.StandardController(getOpty('OPTEST')));
		oe.opp.Name = 'OP-666';
		oe.pIva = '12345678666';
		oe.localU.isLocalUser = true;
		
		//No Anagrafica Fatturazione
		RecordType rtBrand = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND DeveloperName = 'Brand' LIMIT 1];
		Account brand = new Account(Name='Brand', RecordTypeId=rtBrand.Id,  BillingCity='MI', BillingStreet='street', BillingPostalCode='1234', BillingState='MI', BillingCountry='c');
		insert brand;
		oppId = oe.createNewOpportunity();
		System.assertEquals(null, oppId);

		//No Brand
		Test.startTest();
		delete brand;
		RecordType rtFatt = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND DeveloperName = 'Anagrafica_di_Fatturazione' LIMIT 1];
		Account accFatt = new Account(Name='AnFatt', Metodo_di_pagamento__c='pag', Termini_di_pagamento__c='termini', Codice_IVA__c='666', RecordTypeId = rtFatt.Id, BillingCity='MI', BillingStreet='street', BillingPostalCode='1234', BillingState='MI', BillingCountry='c', Ragione_sociale_fattura__c='regFatt');
		insert accFatt;
		oppId = oe.createNewOpportunity();
		System.assertEquals(null, oppId);

		//Final Assert
		listOpp = [SELECT Id, Name, Partita_IVA_cliente_Local__c, Note_fattura__c, Check_amministrativo__c,AccountId, Anagrafica_di_Fatturazione__c FROM Opportunity WHERE Id = :oppId];
		System.assertEquals(0, listOpp.size());
		listQ = [SELECT Id, Name, Metodo_di_pagamento__c, Termini_di_pagamento__c, Codice_IVA__c FROM Quote WHERE OpportunityId = :oppId];
		System.assertEquals(0, listQ.size());
		Test.stopTest();
	}

	@isTest static void createNewOpportunity_KOAccountMore() {
		prepareData();
		List<Opportunity> listOpp;
		List<Quote> listQ;
		Id oppId;
		OpportunityNewExtension oe = new OpportunityNewExtension(new ApexPages.StandardController(getOpty('OPTEST')));
		oe.opp.Name = 'OP-666';
		oe.pIva = '12345678666';
		oe.localU.isLocalUser = true;
		RecordType rtBrand = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND DeveloperName = 'Brand' LIMIT 1];
		Account brand = new Account(Name='Brand', RecordTypeId=rtBrand.Id,  BillingCity='MI', BillingStreet='street', BillingPostalCode='1234', BillingState='MI', BillingCountry='c');
		insert brand;
		RecordType rtFatt = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND DeveloperName = 'Anagrafica_di_Fatturazione' LIMIT 1];
		Account accFatt = new Account(Name='AnFatt', Metodo_di_pagamento__c='pag', Termini_di_pagamento__c='termini', Codice_IVA__c='666', RecordTypeId = rtFatt.Id, BillingCity='MI', BillingStreet='street', BillingPostalCode='1234', BillingState='MI', BillingCountry='c', Ragione_sociale_fattura__c='regFatt');
		insert accFatt;
		
		Test.startTest();
		//More Anagrafica Fatturazione
		Account accFatt1 = new Account(Name='AnFatt1', Metodo_di_pagamento__c='pag', Termini_di_pagamento__c='termini', Codice_IVA__c='6661', RecordTypeId = rtFatt.Id, BillingCity='MI', BillingStreet='street', BillingPostalCode='1234', BillingState='MI', BillingCountry='c', Ragione_sociale_fattura__c='regFatt1');
		insert accFatt1;
		oppId = oe.createNewOpportunity();
		System.assertEquals(null, oppId);

		//More Brand
		Account brand1 = new Account(Name='Brand1', RecordTypeId=rtBrand.Id,  BillingCity='MI', BillingStreet='street', BillingPostalCode='1234', BillingState='MI', BillingCountry='c');
		insert brand1;
		oppId = oe.createNewOpportunity();
		System.assertEquals(null, oppId);

		//Final Assert
		listOpp = [SELECT Id, Name, Partita_IVA_cliente_Local__c, Note_fattura__c, Check_amministrativo__c,AccountId, Anagrafica_di_Fatturazione__c FROM Opportunity WHERE Id = :oppId];
		System.assertEquals(0, listOpp.size());
		listQ = [SELECT Id, Name, Metodo_di_pagamento__c, Termini_di_pagamento__c, Codice_IVA__c FROM Quote WHERE OpportunityId = :oppId];
		System.assertEquals(0, listQ.size());
		Test.stopTest();
	}

	@isTest static void createNewOpportunity_KOpIVA() {
		prepareData();
		OpportunityNewExtension oe = new OpportunityNewExtension(new ApexPages.StandardController(getOpty('OPTEST')));
		oe.opp.Name = 'OP-666';
		oe.pIva = '12345678666';
		oe.localU.isLocalUser = true;
		//Account with same Partita_IVA_Number__c
		RecordType rtBrand = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND DeveloperName = 'Brand' LIMIT 1];
		User otherOwner = [SELECT Id 
						   From User 
						   WHERE ProfileId =: UserInfo.getProfileId() 
						   AND Id <>: UserInfo.getUserId() 
						   AND IsActive = true
						   LIMIT 1]; //vengono esclusi gli account il cui owner è l'utente
		Account brand = new Account(OwnerId=OtherOwner.Id,Partita_IVA__c='12345678666', Name='Brand', RecordTypeId=rtBrand.Id,  BillingCity='MI', BillingStreet='street', BillingPostalCode='1234', BillingState='MI', BillingCountry='c');
		insert brand;

		Test.startTest();
		oe.searchAccount();
		Test.stopTest();

		System.assert(!oe.mapAccountFound.isEmpty());
	}

	@isTest static void doRedirect() {
		prepareData();
		OpportunityNewExtension oeLocal = new OpportunityNewExtension(new ApexPages.StandardController(getOpty('OPTEST')));
		oeLocal.localU.isLocalUser = true;
		OpportunityNewExtension oe = new OpportunityNewExtension(new ApexPages.StandardController(getOpty('OPTEST')));
		oeLocal.localU.isLocalUser = false;

		Test.startTest();
		PageReference pageLocal = oeLocal.doRedirect();
		PageReference pageNotLocal = oe.doRedirect();
		Test.stopTest();

		System.assertNotEquals(null, pageNotLocal);
		//System.assertEquals(null, pageLocal);
	}

	@isTest static void checkPIVAFormat() {
		String pivaOK = '12345678901';
		String pivaKO = 'aa223';

		Test.startTest();
		String resultOK = OpportunityNewExtension.checkPIVAFormat(pivaOK);
		String resutlKO = OpportunityNewExtension.checkPIVAFormat(pivaKO);
		Test.stopTest();

		System.assertEquals(null, resultOK);
		System.assertNotEquals(null, resutlKO);
	}
	
}