trigger onAfterTechnologyTargeting on TechnologyTargeting__c (after insert,after update,after delete) {
    if(!LineItemTriggerHandler.SkipUpdateLineItem) {
    	update LineItemTriggerHandler.getLineItems(true);
    }
}