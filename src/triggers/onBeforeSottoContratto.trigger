trigger onBeforeSottoContratto on SottoContratto__c (before update,after update) {

    //Nel before salvo i sottocontratti per i quali dovrò modificare i prodotti
    //Non posso aggiornare direttamente i prodotti nel before se no ricalcola i roll-up e provoca eccezione
    if(Trigger.isBefore){
        for(SottoContratto__c sc : Trigger.new){
            if(sc.Propaga_data_chiusura__c != null){ // || sc.chiuso__c
                contrattoSottoContrattoTriggerHandler.scToClose.put(sc.id,sc.clone());
                sc.Propaga_data_chiusura__c = null;
            }
            if(sc.Propaga_sospensione__c){
                contrattoSottoContrattoTriggerHandler.scToSuspend.put(sc.id,sc.clone());                
                sc.Propaga_sospensione__c = false;
            }
        }
    }
    if(Trigger.isAfter){
        list<ProdottoSottoContratto__c> prodottiSottoContrattiToClose = [select id,SottoContratto__c,Data_chiusura__c,Sospeso__c from ProdottoSottoContratto__c where SottoContratto__c in : contrattoSottoContrattoTriggerHandler.scToClose.keySet()]; //,chiuso__c
        list<ProdottoSottoContratto__c> prodottiSottoContrattiToSuspend = [select id,SottoContratto__c,Data_chiusura__c,Sospeso__c from ProdottoSottoContratto__c where SottoContratto__c in : contrattoSottoContrattoTriggerHandler.scToSuspend.keySet()]; //,chiuso__c
        map<id,ProdottoSottoContratto__c> prodottiSottoContrattiToUpdate = new map<id,ProdottoSottoContratto__c>();
        for(ProdottoSottoContratto__c psc : prodottiSottoContrattiToClose){
            if(contrattoSottoContrattoTriggerHandler.scToClose.get(psc.SottoContratto__c).Propaga_data_chiusura__c != null){
                psc.Data_chiusura__c = contrattoSottoContrattoTriggerHandler.scToClose.get(psc.SottoContratto__c).Propaga_data_chiusura__c;
                psc.rinnovo_automatico__c = false;
                prodottiSottoContrattiToUpdate.put(psc.id,psc);
            }
        }
        for(ProdottoSottoContratto__c pcs : prodottiSottoContrattiToSuspend){
            if(prodottiSottoContrattiToUpdate.get(pcs.id) != null){
                pcs = prodottiSottoContrattiToUpdate.get(pcs.id);
            }
            if(!pcs.sospeso__c){
                pcs.sospeso__c = contrattoSottoContrattoTriggerHandler.scToSuspend.get(pcs.SottoContratto__c).Propaga_sospensione__c;
                prodottiSottoContrattiToUpdate.put(pcs.id,pcs);
            }
        }
        update prodottiSottoContrattiToUpdate.values();
    }
}