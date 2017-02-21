trigger onAfterInventoryTarget on Inventory_Target__c (after insert,after update,after delete) {
    if(!LineItemTriggerHandler.SkipUpdateLineItem) {
    	update LineItemTriggerHandler.getLineItems(true);
    }
}