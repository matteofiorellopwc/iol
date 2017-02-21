trigger Opportunity on Opportunity (
    after delete,
    after insert,
    after update, 
    before delete,
    before insert,
    before update
) {
    if(!UtilSkipTrigger.skipOpportunityTrigger && !UtilityTrigger.skipTrigger) {
        if(Trigger.isBefore) {          
            if(Trigger.isInsert) {
                OpportunityTriggerHandler.copyDataFromAccount(trigger.new);
                OpportunityTriggerHandler.doFieldUpdates(trigger.new);          
            } else if(Trigger.isUpdate) {
                OpportunityTriggerHandler.doFieldUpdates(trigger.new);
                OpportunityTriggerHandler.rollupLineItemFields(trigger.new);            
                OpportunityTriggerHandler.doFieldUpdatesOnChanged(trigger.new,trigger.oldMap);
            } else if(Trigger.isDelete) {
                UtilSkipTrigger.fromTriggerDeleteOpportunity = true;
                OpportunityTriggerHandler.checkDeletedLi(trigger.old);
                OpportunityTriggerHandler.deleteTeamTargeted(trigger.old);
                OpportunityTriggerHandler.deleteLi(trigger.old);
            }
        }
       
        if(Trigger.isAfter) {
            if(Trigger.isUpdate) {
                OpportunityTriggerHandler.updateLineItemsIfNeeded(trigger.new);
                if(!RevenueApplicationTriggerHandler.skipUpdateRevenues) {
                    //Aggiorno valori obiettivo (venditore) e i campi storico revenue
                    OpportunityTriggerHandler.updateRevenues(trigger.new);
                    //Aggiorno valori obiettivo (venditore) e i campi storico ricavo
                    OpportunityTriggerHandler.updateRicavi(trigger.new);
                }
            }
            if(Trigger.isInsert || Trigger.isUpdate){
                OpportunityTriggerHandler.manageSharing(trigger.new, trigger.oldMap, null);
                if(!Test.isRunningTest()) {
                    OpportunityTriggerHandler.notifyUsersRelated(trigger.newMap,trigger.oldMap);
                }
                
            }
            //Se necessario, invio le notifiche OAS
//            OpportunityTriggerHandler.sendOASEmails();
            system.debug('OpportunityTriggerHandler isbatch '+system.isBatch());
            if(!system.isBatch()){
                OpportunityTriggerHandler.sendCPLEmails();
            }
        }
    }                          
}