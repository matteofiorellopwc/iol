@isTest
private class ADXPlacementLoaderControllerTest {

	@isTest static void import() {
		//Data preparation
		Date refDate = Date.newinstance(Integer.valueOf('2020'), Integer.valueOf('2'), 2);
    	Date refDateNextMonth = refDate.addMonths(1).addDays(-4);
		Opportunity opp = utilityTest.insertDfpOasOpp();
		LineItem__c li = [SELECT Id FROM LineItem__c WHERE Opportunity__c = :opp.Id	AND Ad_Server__c = 'DFP' LIMIT 1];
		li.ADX_Placement_ID__c = 'x666';
		li.Start_date__c = refDateNextMonth;
		li.End_date__c = refDate;
		li.Totale__c = 200;
		Revenue_application__c raJan = new Revenue_application__c(Anno__c='2020', Mese__c='Gennaio', Line_Item__c=li.Id, Percentuale_applicata__c = 50, Valore__c=100, ADXPlacementUpdated__c=false);
		//insert raJan;
		Revenue_application__c raFeb = new Revenue_application__c(Anno__c='2020', Mese__c='Febbraio', Line_Item__c=li.Id, Percentuale_applicata__c = 50, Valore__c=100, ADXPlacementUpdated__c=false);
		//insert raFeb;
		Revenue_application__c raTOT = new Revenue_application__c(Anno__c='2020', Mese__c=ADXPlacementLoaderController.REVENUE_TOTAL, Percentuale_applicata__c = 100, Line_Item__c=li.Id);
		//insert raTOT;
		list<Revenue_application__c> raList = new list<Revenue_application__c>{raJan,raFeb,raTOT}; 
		insert raList;
		update li;
		System.debug('ListRA: '+[SELECT Id, Percentuale_applicata__c, Valore__c, ADXPlacementUpdated__c, Mese__c, Anno__c FROM Revenue_application__c]);
		//File Preparation
		String testFile = 'ID;Value\n'+ //Header
            'x666;300\n';
        //Calling controller and setting parameters (User insert simulation)
		ADXPlacementLoaderController ctrl = new ADXPlacementLoaderController();
	    ctrl.fileName = 'file';
	    ctrl.fileBody = Blob.valueOf(testFile);
	    ctrl.month = '2';
	    ctrl.year = '2020';

	    Test.startTest();
	    ctrl.upload();
	    ctrl.import();
	    Test.stopTest();

	    System.assertEquals(1, ctrl.wrappers.size());
	    System.assertEquals(1, ctrl.wrapSize);
	    System.assert(ctrl.setADXId.contains('x666'));
	    System.assertEquals(1, ctrl.mapIdADXListLI.size());
	    System.assertEquals(3, ctrl.mapRAUpdateList.get('x666').size());
	    System.assertEquals(0, ctrl.mapRAInsertList.get('x666').size());
	    System.assertEquals(1, ctrl.mapLIUpdateList.get('x666').size());
	    System.assertEquals(3, ctrl.mapRicavoInsertList.get('x666').size());
	    System.assertEquals(0, ctrl.mapRicavoUpdateList.get('x666').size());
//	    li = [SELECT Id, Totale__c FROM LineItem__c WHERE Id = :li.Id];
//	    System.assertEquals(400, li.Totale__c);
//	    raJan = [SELECT Id, Percentuale_applicata__c, Valore__c, ADXPlacementUpdated__c FROM Revenue_application__c WHERE Id = :raJan.Id];
//	    System.assertEquals(25, raJan.Percentuale_applicata__c);
//	    System.assertEquals(100, raJan.Valore__c);
//	    System.assert(raJan.ADXPlacementUpdated__c);
	}

	@isTest static void uploadFile() {
		String testFile = 'ID;Value\n'+ //Header
            'x666;66.6\n';

		ADXPlacementLoaderController ctrl = new ADXPlacementLoaderController();
	    ctrl.fileName = 'file';
	    ctrl.fileBody = Blob.valueOf(testFile);
	    ctrl.month = '2';
	    ctrl.year = '2020';

	    Test.startTest();
	    ctrl.upload();
	    Test.stopTest();

	    System.debug('ctrl.wrappers: '+ctrl.wrappers);
	    System.assertEquals(1, ctrl.wrappers.size());
	    System.assertEquals(Decimal.valueOf('66.6'), ctrl.wrappers.get('x666').valueADX);
	}

	@isTest static void getMapProportionalValues() {
		ADXPlacementLoaderController ctrl = new ADXPlacementLoaderController();
		LineItem__c li0 = new LineItem__c(Id='a0811000000uPqt');
		LineItem__c li1 = new LineItem__c(Id='a0811000000uXqt');
		LineItem__c li2 = new LineItem__c(Id='a0811000000uKqt');
		ctrl.mapIdADXListLI.put('key0', new List<LineItem__c>{li0});
		ctrl.mapIdADXListLI.put('key1', new List<LineItem__c>{li1, li2});
		ctrl.mapIdLIImpressions.put(li0.Id, 30);
		ctrl.mapIdLIImpressions.put(li1.Id, 10);
		ctrl.mapIdLIImpressions.put(li2.Id, 40);
		Map<String, ADXPlacementLoaderController.ADXWrapper> wrappers = new Map<String, ADXPlacementLoaderController.ADXWrapper>();
		wrappers.put('key0', new ADXPlacementLoaderController.ADXWrapper('key0', 10));
		wrappers.put('key1', new ADXPlacementLoaderController.ADXWrapper('key1', 10));
		ctrl.wrappers = wrappers;

		Test.startTest();
		Map<Id, Decimal> mapProp = ctrl.getMapProportionalValues();
		Test.stopTest();

		System.assertEquals(3, mapProp.size());
		System.assertEquals(1, mapProp.get(li0.Id));
		System.assertEquals(0.2, mapProp.get(li1.Id));
		System.assertEquals(0.8, mapProp.get(li2.Id));
	}

	@isTest static void getLITotalUpdate() {
		ADXPlacementLoaderController ctrl = new ADXPlacementLoaderController();
		LineItem__c li = new LineItem__c(Id='a0811000000uPqt', Totale__c=10);
		Map<Id, ADXPlacementLoaderController.LIWrapper> mapIdLIW = new Map<Id, ADXPlacementLoaderController.LIWrapper>();
		mapIdLIW.put('a0811000000uPqt', new ADXPlacementLoaderController.LIWrapper(li));
		Map<String, ADXPlacementLoaderController.ADXWrapper> mapW = new Map<String, ADXPlacementLoaderController.ADXWrapper>();
		ADXPlacementLoaderController.ADXWrapper adxW = new ADXPlacementLoaderController.ADXWrapper('key0', 20);
		adxW.mapIdLIW = mapIdLIW;
		mapW.put('key0', adxW);
		ctrl.wrappers = mapW;
		String month = '2';
		ctrl.month = month;
		//Data Preparation - All revenues are present
		Decimal raValue = 400;
		List<Revenue_application__c> listRA = new List<Revenue_application__c>{
			new Revenue_application__c(Line_Item__c=li.Id, Valore__c=100, Mese__c=ADXPlacementLoaderController.mapMonths.get(1)),
			new Revenue_application__c(Line_Item__c=li.Id, Valore__c=300, Mese__c=ADXPlacementLoaderController.mapMonths.get(Integer.valueOf(month))),
			new Revenue_application__c(Line_Item__c=li.Id, Valore__c=400, Mese__c=ADXPlacementLoaderController.REVENUE_TOTAL)
		};

		Test.startTest();
		Decimal totalLI = ctrl.getLITotal(li, listRA, raValue, 'key0');
		Test.stopTest();

		System.assertEquals(500, totalLI);
		System.assertEquals(0, ctrl.mapRAInsertList.get('key0').size());
		System.assertEquals(3, ctrl.mapRAUpdateList.get('key0').size());
		for (Revenue_application__c ra : ctrl.mapRAUpdateList.get('key0')) {
			if (ra.Mese__c == ADXPlacementLoaderController.mapMonths.get(1)) {
				System.assertEquals(100, ra.Valore__c);
				System.assertEquals(20, ra.Percentuale_applicata__c);
			} else if (ra.Mese__c == ADXPlacementLoaderController.mapMonths.get(Integer.valueOf(month))){
				System.assertEquals(400, ra.Valore__c);
				System.assertEquals(80, ra.Percentuale_applicata__c);
			} else if (ra.Mese__c == ADXPlacementLoaderController.REVENUE_TOTAL){
				System.assertEquals(500, ra.Valore__c);
				System.assertEquals(100, ra.Percentuale_applicata__c);
			}
		}
	}

	@isTest static void getLITotalInsert() {
		ADXPlacementLoaderController ctrl = new ADXPlacementLoaderController();
		String month = '2';
		ctrl.month = month;
		//Data Preparation - Revenue of Selected month is not present
		Decimal raValue = 400;
		LineItem__c li = new LineItem__c(Id='a0811000000uPqt');
		List<Revenue_application__c> listRA = new List<Revenue_application__c>{
			new Revenue_application__c(Line_Item__c=li.Id, Valore__c=100, Mese__c=ADXPlacementLoaderController.mapMonths.get(1)),
			//No RA for Selected month
			new Revenue_application__c(Line_Item__c=li.Id, Valore__c=100, Mese__c=ADXPlacementLoaderController.REVENUE_TOTAL)
		};

		Test.startTest();
		Decimal totalLI = ctrl.getLITotal(li, listRA, raValue, 'key0');
		Test.stopTest();

		System.assertEquals(500, totalLI);
		System.assertEquals(1, ctrl.mapRAInsertList.get('key0').size());
		System.assertEquals(2, ctrl.mapRAUpdateList.get('key0').size());
		System.assertEquals(400, ctrl.mapRAInsertList.get('key0').get(0).Valore__c);
		System.assertEquals(80, ctrl.mapRAInsertList.get('key0').get(0).Percentuale_applicata__c);
		for (Revenue_application__c ra : ctrl.mapRAUpdateList.get('key0')) {
			if (ra.Mese__c == ADXPlacementLoaderController.mapMonths.get(1)) {
				System.assertEquals(100, ra.Valore__c);
				System.assertEquals(20, ra.Percentuale_applicata__c);
			} else if (ra.Mese__c == ADXPlacementLoaderController.REVENUE_TOTAL){
				System.assertEquals(500, ra.Valore__c);
				System.assertEquals(100, ra.Percentuale_applicata__c);
			}
		}
	}


	@isTest static void getLITotalInsertFull() {
		ADXPlacementLoaderController ctrl = new ADXPlacementLoaderController();
		String month = '2';
		ctrl.month = month;
		//Data Preparation - Revenue of Selected month is not present
		Decimal raValue = 400;
		LineItem__c li = new LineItem__c(Id='a0811000000uPqt');
		List<Revenue_application__c> listRA = new List<Revenue_application__c>{
			new Revenue_application__c(Line_Item__c=li.Id, Valore__c=100, Mese__c=ADXPlacementLoaderController.mapMonths.get(1))
			//No RA for Selected month
			//No RA Total
		};

		Test.startTest();
		Decimal totalLI = ctrl.getLITotal(li, listRA, raValue, 'key0');
		Test.stopTest();

		System.assertEquals(500, totalLI);
		System.assertEquals(2, ctrl.mapRAInsertList.get('key0').size());
		System.assertEquals(1, ctrl.mapRAUpdateList.get('key0').size());
		System.assertEquals(100, ctrl.mapRAUpdateList.get('key0').get(0).Valore__c);
		System.assertEquals(20, ctrl.mapRAUpdateList.get('key0').get(0).Percentuale_applicata__c);
		for (Revenue_application__c ra : ctrl.mapRAInsertList.get('key0')) {
			if (ra.Mese__c == ADXPlacementLoaderController.mapMonths.get(Integer.valueOf(month))) {
				System.assertEquals(400, ra.Valore__c);
				System.assertEquals(80, ra.Percentuale_applicata__c);
			} else if (ra.Mese__c == ADXPlacementLoaderController.REVENUE_TOTAL){
				System.assertEquals(500, ra.Valore__c);
				System.assertEquals(100, ra.Percentuale_applicata__c);
			}
		}
	}

	@isTest static void populateMapsRicavi() {
		ADXPlacementLoaderController ctrl = new ADXPlacementLoaderController();
		String month = '2';
		ctrl.month = month;
		Id liId = 'a0811000000uPqt';
		LineItem__c li = new LineItem__c(Id=liId);
		Revenue_application__c raUpdate = new Revenue_application__c(Id='a0I11000001ItMQ', Anno__c='2014', Mese__c='Febbraio', Line_Item__c=li.Id, Valore__c=666, Percentuale_applicata__c=66);
		Revenue_application__c raInsert = new Revenue_application__c(Anno__c='2014', Mese__c='Gennaio', Line_Item__c=li.Id, Valore__c=333, Percentuale_applicata__c=33);
		Id ricavoId =  Ricavo__c.SObjectType.getDescribe().getKeyPrefix()+'000000000666';
		Ricavo__c rcUpdate = new Ricavo__c(Id=ricavoId, Anno__c='2014', Mese__c='Febbraio', Line_Item__c=li.Id);
		ctrl.mapRAUpdateList.put('adx01', new List<Revenue_Application__c>{raUpdate});
		ctrl.mapRAInsertList.put('adx01', new List<Revenue_Application__c>{raInsert});
		ctrl.mapKeyRicavo.put(liId+'_2014_Febbraio', rcUpdate);
		System.Debug('PuntoDebug - ctrl.mapKeyRicavo: '+ctrl.mapKeyRicavo);
		Map<String, ADXPlacementLoaderController.ADXWrapper> wrappers = new Map<String, ADXPlacementLoaderController.ADXWrapper>();
		wrappers.put('adx01', new ADXPlacementLoaderController.ADXWrapper('adx01', 10));
		ctrl.wrappers = wrappers;

		Test.startTest();
		ctrl.populateMapsRicavi();
		Test.stopTest();

		System.assertNotEquals(null, ctrl.mapRicavoInsertList.get('adx01'));
		System.assertNotEquals(null, ctrl.mapRicavoUpdateList.get('adx01'));
		System.assertEquals(1, ctrl.mapRicavoInsertList.get('adx01').size());
		System.assertEquals(1, ctrl.mapRicavoUpdateList.get('adx01').size());
		//Check for insert
		System.assertEquals('2014', ctrl.mapRicavoInsertList.get('adx01').get(0).Anno__c);
		System.assertEquals('Gennaio', ctrl.mapRicavoInsertList.get('adx01').get(0).Mese__c);
		System.assertEquals(333, ctrl.mapRicavoInsertList.get('adx01').get(0).Valore__c);
		System.assertEquals(33, ctrl.mapRicavoInsertList.get('adx01').get(0).Percentuale_applicata__c);
		//Check for update
		System.assertEquals(666, ctrl.mapRicavoUpdateList.get('adx01').get(0).Valore__c);
		System.assertEquals(66, ctrl.mapRicavoUpdateList.get('adx01').get(0).Percentuale_applicata__c);	
	}

	@isTest static void compensatePercent() {
		List<Revenue_application__c> listRA = new List<Revenue_application__c>();
		listRA.add(new Revenue_application__c(Percentuale_Applicata__c= 90.1));
		listRA.add(new Revenue_application__c(Percentuale_Applicata__c= 6.9));
		listRA.add(new Revenue_application__c(Percentuale_Applicata__c= 3.1));
		List<Revenue_application__c> listRAOK = new List<Revenue_application__c>(); //No adjustment needed
		listRAOK.add(new Revenue_application__c(Percentuale_Applicata__c= 90));
		listRAOK.add(new Revenue_application__c(Percentuale_Applicata__c= 6.9));
		listRAOK.add(new Revenue_application__c(Percentuale_Applicata__c= 3.1));

		Test.startTest();
		ADXPlacementLoaderController.compensatePercent(listRA);
		Test.stopTest();

		System.assertEquals(90, listRA[0].Percentuale_Applicata__c);
		System.assertEquals(6.9, listRA[1].Percentuale_Applicata__c);
		System.assertEquals(3.1, listRA[2].Percentuale_Applicata__c);
		System.assertEquals(90, listRAOK[0].Percentuale_Applicata__c);
		System.assertEquals(6.9, listRAOK[1].Percentuale_Applicata__c);
		System.assertEquals(3.1, listRAOK[2].Percentuale_Applicata__c);
	}
}