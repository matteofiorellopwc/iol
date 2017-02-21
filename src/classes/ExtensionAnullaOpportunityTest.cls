@isTest
private class ExtensionAnullaOpportunityTest {
	
	@isTest static void testArchiviaOpportunity() {

		UtilityTrigger.skipTrigger = true;
		Opportunity opportunity = new Opportunity(
			Name = 'Test',
			CloseDate = Date.today(),
			DataPrimaChiusaVinta__c = Datetime.now(),
			StageName = 'Chiusa Vinta – in modifica',
			IsArchived__c = false
		);
		insert opportunity;

		ApexPages.StandardController stdController = new ApexPages.StandardController(opportunity);
		ExtensionAnnullaOpportunity ext = new ExtensionAnnullaOpportunity(stdController);
		ext.init();
		System.assert(!ext.hasErrors); 

		PageReference pr = ext.annullaOpportunity();
		System.assertEquals(pr.getUrl(),'/'+opportunity.Id);
		opportunity = [SELECT Id,StageName,IsArchived__c FROM Opportunity WHERE Id = :opportunity.Id];
		System.assertEquals(opportunity.StageName,'Annullata');
		System.assert(opportunity.IsArchived__c);

		
	}
	
}