global class BatchableRevenueChecker implements Database.Batchable<SObject>, Database.Stateful {
	private static String query = 'SELECT Id, Start_date__c, End_date__C, ModalitaEditRevenue__c, Percentuale_commisioning_agenzia__c, totale__c, quantita__c FROM LineItem__c';
	
	private String errorCsv = '';
	
	global Database.Querylocator start(Database.BatchableContext BC) {
		errorCsv = 'LineItemId,ErrorMessage,StatusCode\n';
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, SObject[] scope) {
		System.savePoint sp = Database.setSavePoint();
		try {
			for(SObject so : scope) {
				LineItem__c li = (LineItem__c) so;
				li.ModalitaEditRevenue__c = 'Valore';
				ControllerRevenueApplication cra = new ControllerRevenueApplication(li);
				try {
					cra.setParentValues(li);
					cra.updateRevenueApplication();
					cra.customSave();
				} catch(Exception e) {
					errorCsv += li.Id + ',"' + e.getMessage() + '",' + '\n';					
				}
			}
		} finally {
			Database.rollback(sp);
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		delete [SELECT Id FROM Document WHERE Name = 'Report revenue check.csv' AND FolderId = :UserInfo.getUserId()];
		Document d = new Document();
		d.Name = 'Report revenue check.csv';
		d.folderId = UserInfo.getUserId();
		d.body = Blob.valueOf(errorCsv);
		insert d;
	}
	
	 static testmethod void test() {
        Opportunity opp = new Opportunity(Name='Test opp',StageName='Close won',closeDate = date.today());
	 	insert opp;
	 	LineItem__c li = new LineItem__c();
	 	li.Opportunity__c=opp.id; 
	 	li.Start_date__c=Date.today();
	 	li.End_date__C=Date.today();
	 	li.ModalitaEditRevenue__c='Valore';
	 	li.Percentuale_commisioning_agenzia__c=0;
	 	li.totale__c=10000000;
	 	li.quantita__c=10;
		insert li;
		BatchableRevenueChecker c= new BatchableRevenueChecker();
	    Database.executeBatch(c);
	
	 }
}