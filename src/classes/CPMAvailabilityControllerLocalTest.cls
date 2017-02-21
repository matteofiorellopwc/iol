@isTest
private class CPMAvailabilityControllerLocalTest {
	
	@isTest static void test_method_one() {
		ApexPages.currentPage().getParameters().put('fakeForecast','1');
		utilityTest.createFattoreCorrettivoFasce();
		Product2 p = utilityTest.createBannerDfp();
		p.isActive = true;
		p.Local__c= true;
		update p;
		Account a = utilityTest.insertBrand();

		CPMAvailabilityControllerLocal contr = new CPMAvailabilityControllerLocal();
		contr.formatoSelected = contr.productsMap.values()[0].formato__c;
		contr.prodottoSelected = contr.prodotti.get(contr.formatoSelected)[1].getValue();
		contr.chooseProduct();
		System.assertNotEquals(null,contr.opportunity);
		System.assertNotEquals(null,contr.lineItem);

		contr.startCPMAvailability();

		while(contr.isRunning){
			contr.processForecast();
		}

		contr.productIdForecastDetail = contr.productsMap.values()[0].Id;
		contr.keyForecastDetail = contr.dates[0];
		contr.showForecastDetail();			

		DfpLineItemService.LineItem dfpLi = new DfpLineItemService.LineItem();

		dfpLi.startDateTime = UtilityDataValue.getLineItemDateTime(system.now());
		dfpLi.endDateTime = UtilityDataValue.getLineItemDateTime(system.now());

		contr.forecastMap.values()[0][0].contendingLineItems.values()[0].mergeFields(dfpLi);

		CPMAvailabilityControllerLocal.deleteObsoleteData();
	}
	
}