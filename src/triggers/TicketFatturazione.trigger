trigger TicketFatturazione on Ticket_Fatturazione__c (before insert, before delete, before update) {
	
	if(Trigger.isDelete && !UtilSkipTrigger.skipBeforeDeleteTicket_RowTrigger){
        for(Ticket_Fatturazione__c t:Trigger.old){
            if(t.Stato__c != 'Da inviare' && t.Stato__c != 'Fatturato manualmente' && t.Stato__c != 'Draft' &&
               t.Stato__c != 'Fatturato manualmente - TBC' && t.Stato__c != 'Draft - TBC'){
                t.addError('Non è possibile cancellare ticket già inviati o in fase di invio.');    
            }
        }
    }
    if(Trigger.isUpdate && !UtilSkipTrigger.skipBeforeDeleteTicket_RowTrigger){
        for(Ticket_Fatturazione__c t:Trigger.new){
            if(Trigger.oldMap.get(t.Id).Stato__c == 'Inviato' || Trigger.oldMap.get(t.Id).Stato__c == 'Inviato - TBC'){
                t.Stato__c.addError('Non è possibile aggiornare ticket già inviati o in fase di invio.');
            }
        }	
    }
    if(Trigger.isInsert || Trigger.isUpdate){
    	for(Ticket_Fatturazione__c ticket : Trigger.new){
    		if(ticket.Percentuale_ristorno_agenzia__c == null){
    			ticket.Percentuale_ristorno_agenzia__c = 0;
    		}
    	}
    }

}