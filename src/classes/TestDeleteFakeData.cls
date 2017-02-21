@isTest
private class TestDeleteFakeData {
	
	@isTest static void testDelete() {
		UtilityTrigger.skipTrigger = true;

		Product2 p = utilityTest.createBannerDfp();
		p.isActive = true;
		update p;
		Account a = utilityTest.insertBrand();

		Opportunity opportunity = new Opportunity(
		    Name = 'Test_CPM_availability',
		    AccountId = a.Id,
		    StageName = '0 %',
		    CloseDate = System.today(),
		    Commissione_Agenzia__c = 0,
		    Tipo_Opportunity__c = 'Test'
		);
		insert opportunity;  

		LineItem__c lineitem = new LineItem__c(
            Product__c = p.Id,
            Opportunity__c = opportunity.Id
        );
        insert lineitem; 

        List<LineItem__c> lineItemsToDelete = [SELECT Id FROM LineItem__c WHERE Opportunity__r.Name LIKE '%Test_CPM_availability' AND Opportunity__r.Tipo_Opportunity__c = 'Test' LIMIT 10000];
        System.assertEquals(1,lineItemsToDelete.size());

        DeleteFakeData deleteData = new DeleteFakeData();
        deleteData.execute(null);

        lineItemsToDelete = [SELECT Id FROM LineItem__c WHERE Opportunity__r.Name LIKE '%Test_CPM_availability' AND Opportunity__r.Tipo_Opportunity__c = 'Test' LIMIT 10000];
        System.assertEquals(0,lineItemsToDelete.size());
	}
	
}