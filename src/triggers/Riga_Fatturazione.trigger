trigger Riga_Fatturazione on Riga_Fatturazione__c (before delete, before update,after update) {
    if(Trigger.isDelete && Trigger.isBefore && !UtilSkipTrigger.skipBeforeDeleteTicket_RowTrigger){
        for(Riga_Fatturazione__c r:Trigger.old){
            if(r.Stato__c != 'Da inviare' && r.Stato__c != 'Gestione manuale' && r.Stato__c != 'Draft'){
                r.addError('Non è possibile cancellare righe già inviate o in fase di invio.');    
            }
        }
    }
            
    if(Trigger.isUpdate && Trigger.isBefore && !UtilSkipTrigger.skipBeforeDeleteTicket_RowTrigger){
        for(Riga_Fatturazione__c r:Trigger.new){
            if(Trigger.oldMap.get(r.Id).Stato__c == 'Inviata'){
                r.Stato__c.addError('Non è possibile aggiornare righe già inviate o in fase di invio.');
            }
        }
    }

    /*
        se modifico il totale di una riga devo aggiornare i valori degli spaccati proporzionalmente con le impressions
    */
    if(Trigger.isUpdate && Trigger.isAfter){
        set<id> rowChangedPrezzoIds = new set<id>();

        for(Riga_Fatturazione__c r : trigger.new){
            if(r.Prezzo_unitario__c != Trigger.oldMap.get(r.id).Prezzo_unitario__c){
                rowChangedPrezzoIds.add(r.id);
            }
        }

        Spaccato_Riga_Fatturazione__c[] spaccatiToUpdate = new Spaccato_Riga_Fatturazione__c[]{};

        for(Riga_Fatturazione__c r : [select id,Prezzo_unitario__c,Somma_impression_spaccati__c,(select id,Spaccato_prezzo_unitario__c,Impression__c from Spaccato_Righe_Fatturazione__r) from Riga_Fatturazione__c where id in : rowChangedPrezzoIds]){
            decimal actual = 0;
            for(Integer i=0;i<r.Spaccato_Righe_Fatturazione__r.size();i++){
                Spaccato_Riga_Fatturazione__c s = r.Spaccato_Righe_Fatturazione__r.get(i);
                s.Spaccato_prezzo_unitario__c = r.Prezzo_unitario__c * (s.Impression__c/r.Somma_impression_spaccati__c);
                s.Spaccato_prezzo_unitario__c = s.Spaccato_prezzo_unitario__c.setScale(2,ROUNDINGMODE.HALF_UP);
                actual += s.Spaccato_prezzo_unitario__c;
                if(i==r.Spaccato_Righe_Fatturazione__r.size()-1 && r.Prezzo_unitario__c != actual){
                    s.Spaccato_prezzo_unitario__c += r.Prezzo_unitario__c-actual;
                }
                spaccatiToUpdate.add(s);
            }  
        }
        update spaccatiToUpdate;
    }
}