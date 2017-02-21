trigger Account on Account (
    after delete,
    after insert,
    after update, 
    before delete,
    before insert,
    before update
) {
if(!UtilityTrigger.skipTrigger){
    if(Trigger.isBefore) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            AccountTriggerHandler.doFieldUpdates(trigger.new);
            AccountTriggerHandler.setupProvinciaAndAgenziaTerritoriale(trigger.new);
            AccountTriggerHandler.validateItNetAccount(trigger.new);
        }
    }
    
    if(Trigger.isAfter) {
        if(Trigger.isUpdate) {
            AccountTriggerHandler.updateEmailOnProdottiSottoContratto(trigger.new);
            AccountTriggerHandler.updateEmailOnPagamentiAria(trigger.new);
            //Aggiorno le revenue obiettivo collegate a questo account      
            Set<Id> accountModificati = new Set<Id>();
            for(Account a : trigger.new) {
                if(a.Name != trigger.oldMap.get(a.Id).Name) accountModificati.add(a.Id);
            }   
            update [SELECT
                Id
                FROM Revenue_application__c
                WHERE Tipo_Revenue_Application__c = 'Obiettivo' 
                AND (
                    Agenzia_territoriale_obiettivo__c IN :accountModificati
                    OR Centro_Media_obiettivo__c IN :accountModificati
                    OR Cliente_obiettivo__c IN :accountModificati   
                )               
            ];
            AccountTriggerHandler.manageSharing(trigger.new, trigger.oldMap);
        }
    }
}
}