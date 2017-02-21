trigger RevenueApplication on Revenue_application__c (
    after delete,
    after insert,
    after update, 
    before delete,
    before insert,
    before update
)
{  
if(!UtilityTrigger.skipTrigger){
    if(Trigger.isBefore) {
        if(Trigger.isDelete) {      
            RevenueApplicationTriggerHandler.preventDeleteIfFatturate(trigger.old);
        } else if(Trigger.isInsert) {
            RevenueApplicationTriggerHandler.updateFieldsObiettivo(trigger.new);                        
        } else if(Trigger.isUpdate) {
            RevenueApplicationTriggerHandler.updateFieldsObiettivo(trigger.new);
            if(RevenueApplicationTriggerHandler.updateRevenuesStorico){
                RevenueApplicationTriggerHandler.updateFieldsStorico(trigger.new);
            }
        }
    }
    
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            //RevenueApplicationTriggerHandler.copySharingFromOpportunity(trigger.new);
        }
        if(Trigger.isInsert || Trigger.isUpdate){
            RevenueApplicationTriggerHandler.updateAssets();
        }
        
        if(!LineItemTriggerHandler.skipUpdateLineItem) {
            RevenueApplicationTriggerHandler.updateLineItems(
                Trigger.isDelete ? 
                trigger.old : 
                trigger.new
            );          
        }   
    }
}
}