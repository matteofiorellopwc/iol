trigger onBeforeContratto on Contratto__c (before update,after update) {

    //Nel before salvo i contratti per i quali dovrò modificare i sottocontratti
    //Non posso aggiornare direttamente i sottocontratti nel before se no ricalcola i roll-up e provoca eccezione
    if(Trigger.isBefore){
        for(Contratto__c c : Trigger.new){
            if(c.Propaga_data_chiusura__c){
                contrattoSottoContrattoTriggerHandler.cToClose.put(c.id,c.clone());
                c.Propaga_data_chiusura__c = false;
            }
            if(c.Propaga_sospensione__c){
                contrattoSottoContrattoTriggerHandler.cToSuspend.put(c.id,c.clone());
                c.Propaga_sospensione__c = false;
            }
        }
    }
    if(Trigger.isAfter){
        list<SottoContratto__c> sottoContrattiToClose = [select id,contratto__c,Propaga_data_chiusura__c,Propaga_sospensione__c from SottoContratto__c where contratto__c in : contrattoSottoContrattoTriggerHandler.cToClose.keySet()]; //,chiuso__c
        list<SottoContratto__c> sottoContrattiToSuspend = [select id,contratto__c,Propaga_data_chiusura__c,Propaga_sospensione__c from SottoContratto__c where contratto__c in : contrattoSottoContrattoTriggerHandler.cToSuspend.keySet()]; //,chiuso__c
        map<id,SottoContratto__c> sottoContrattiToUpdate = new map<id,SottoContratto__c>();
        for(SottoContratto__c sc : sottoContrattiToClose){
            if(sc.Propaga_data_chiusura__c != contrattoSottoContrattoTriggerHandler.cToClose.get(sc.contratto__c).data_chiusura__c){ // && Trigger.newMap.get(sc.contratto__c).propaga_data_chiusura__c
                sc.Propaga_data_chiusura__c = contrattoSottoContrattoTriggerHandler.cToClose.get(sc.contratto__c).data_chiusura__c;
                sottoContrattiToUpdate.put(sc.id,sc);
            }
        }
        for(SottoContratto__c sc : sottoContrattiToSuspend){
            if(sottoContrattiToUpdate.get(sc.id) != null){
                sc = sottoContrattiToUpdate.get(sc.id);
            }
            if(sc.Propaga_sospensione__c != contrattoSottoContrattoTriggerHandler.cToSuspend.get(sc.contratto__c).sospeso__c){
                sc.Propaga_sospensione__c = contrattoSottoContrattoTriggerHandler.cToSuspend.get(sc.contratto__c).sospeso__c;
                sottoContrattiToUpdate.put(sc.id,sc);
            }
        }
        
        update sottoContrattiToUpdate.values();
    }

}