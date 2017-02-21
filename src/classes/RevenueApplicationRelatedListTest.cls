@isTest
private class RevenueApplicationRelatedListTest {
	
	@isTest static void saveRecords() {
		Opportunity opp = utilityTest.insertDfpOasOpp();
		LineItem__c li = [SELECT Id FROM LineItem__c WHERE Opportunity__c = :opp.Id	AND Ad_Server__c = 'DFP' LIMIT 1];
		PageReference pg = Page.RevenueApplicationADXUpdateFlag;
		Test.setCurrentPage(pg);
		ApexPages.currentPage().getParameters().put('id',li.Id);
		Revenue_Application__c ra = new Revenue_Application__c(ADXPlacementUpdated__c=false, Line_Item__c = li.Id);
		insert ra;

		Test.startTest();
		RevenueApplicationRelatedListController ctrl = new RevenueApplicationRelatedListController();
		ctrl.listRA.get(0).ADXPlacementUpdated__c = true;
		ctrl.saveRecords();
		Test.stopTest();

		ra = [SELECT Id, ADXPlacementUpdated__c FROM Revenue_Application__c WHERE Id = :ra.Id];
		system.assert(ra.ADXPlacementUpdated__c);
	}
	
}