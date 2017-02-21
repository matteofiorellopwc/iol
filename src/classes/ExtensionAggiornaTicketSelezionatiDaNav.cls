public with sharing class ExtensionAggiornaTicketSelezionatiDaNav {
	
	public list<Ticket_Fatturazione__c> tickets {get;set;}
	public boolean error {get;set;}

	public ExtensionAggiornaTicketSelezionatiDaNav(ApexPages.StandardController controller){
		if(!Test.isRunningTest()){
            controller.addFields(new list<string>{'Stato__c','name'});
        }
        //tickets = (list<Ticket_Fatturazione__c>) controller.getSelected();
        for(ticket_fatturazione__c tf : tickets){
            if(tf.Stato__c != 'Inviato'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Lo stato del ticket ' +tf.name+ ' non è "Inviato" ma è "'+tf.Stato__c+'"'));
                error = true;
            }
        }
	}
	
	
	
}