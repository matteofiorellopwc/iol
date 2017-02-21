trigger onBeforeDeletePacchettoComboOpp on Pacchetto_Combo_Opportunity__c (before delete){
    LineItemTriggerHandler.pacchettiDeleting = Trigger.oldMap.keySet();
    delete [select id from lineitem__C where Pacchetto_Combo_Opportunity__c =: Trigger.oldMap.keySet()];
}