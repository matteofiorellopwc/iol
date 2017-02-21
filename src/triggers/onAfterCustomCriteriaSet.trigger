trigger onAfterCustomCriteriaSet on CustomCriteriaSet__c (after insert,after update,after delete){
    if(!LineItemTriggerHandler.SkipUpdateLineItem) {
    	update LineItemTriggerHandler.getLineItems(true); 
    }
}