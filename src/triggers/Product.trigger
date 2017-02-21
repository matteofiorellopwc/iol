trigger Product on Product2 (
    after delete,
    after insert,
    after update, 
    before delete,
    before insert,
    before update
) {
    if(!UtilityTrigger.skipTrigger && !ProductTriggerHandler.skipProductTrigger){
        if(Trigger.isBefore) {
            if(Trigger.isInsert || Trigger.isUpdate) {
                ProductTriggerHandler.doFieldUpdates(trigger.new);
                if(Trigger.isUpdate){
                    ProductTriggerHandler.preventModify(trigger.new, trigger.oldMap);
                }
            } else if(Trigger.isDelete) {
                ProductTriggerHandler.deleteProductChilds(trigger.old);
            }
        }
        
        if(Trigger.isAfter) {
            if(Trigger.isInsert || Trigger.isUpdate) {
                //ProductTriggerHandler.addPriceBookEntry(trigger.new);   
                ProductTriggerHandler.createImpressionStimateObj(trigger.new, trigger.oldMap, Trigger.isInsert);
                ProductTriggerHandler.resetCPD(trigger.new, trigger.oldMap);                
            }
        }
    }
}