trigger onPacchettoCombo on PacchettoCombo__c (before update) {

    map<id,PacchettoCombo__c> pacchetti = new map<id,pacchettocombo__c>([select id,totale__c,(select totale__c from Prodotti_Pacchetti_Combo__r) from PacchettoCombo__c where id =: Trigger.newMap.keySet()]);
    for(PacchettoCombo__c pc : Trigger.new){
        pc.totale__c = 0;
        for(Pacchetto_Combo_Prodotto__c ppc : pacchetti.get(pc.id).Prodotti_Pacchetti_Combo__r){
            pc.totale__c += ppc.totale__c;
        }
    }

}