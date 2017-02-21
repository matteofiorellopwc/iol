trigger RicavoTrigger on Ricavo__c (
    before update,
    after insert,
    after update,
    after delete
)
{
if(!UtilityTrigger.skipTrigger){
    if(Trigger.isBefore && Trigger.isUpdate) {
        if(RicavoTriggerHandler.updateRicavoStorico){
            RicavoTriggerHandler.updateFieldsStorico(trigger.new);
        }
    }
    
    if(Trigger.isAfter){
        RicavoTriggerHandler.checkIfRicaviSuMesiAperti(trigger.new, trigger.old, trigger.oldMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete); 
    }
}
}