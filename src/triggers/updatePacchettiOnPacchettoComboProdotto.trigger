trigger updatePacchettiOnPacchettoComboProdotto on Pacchetto_Combo_Prodotto__c (after insert,after update,after delete) {

    set<id> ids = new set<id>();
    for(Pacchetto_Combo_Prodotto__c pcp : (Trigger.isDelete ? Trigger.old : Trigger.new)){
        ids.add(pcp.PacchettoCombo__c);
    }
    
    update [select id from PacchettoCombo__c where id in : ids];
    
}