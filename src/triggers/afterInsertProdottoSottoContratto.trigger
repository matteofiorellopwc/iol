trigger afterInsertProdottoSottoContratto on ProdottoSottoContratto__c (after insert) {

    Map<id,list<rigalistino__c>> listiniMap =new Map<id,list<rigalistino__c>>(); //id prod -> listini
    Map<id,list<RigaListinoElementoContrattuale__c>> elementiListiniMap =new Map<id,list<RigaListinoElementoContrattuale__c>>(); //id listini -> elemento
    
    for(Product2 p : [select id from product2 where recordTypeId =: UtilItNet.itNetProductRecordTypeId]){
        listiniMap.put(p.id,new list<rigalistino__c>());
    }
    for(rigalistino__c l : [select id,listino__r.canale_di_vendita__c,Product__c,Data_inizio_validita__c,Data_fine_validita__c,(Select Id, Elemento_Contrattuale__c, Prezzo_esente_IVA__c, Sconto__c, Periodico__c, Unita_di_misura_periodo__c, Numero_unita_di_misura_periodo__c, Condizione_di_fatturazione__c From elementi_contrattuali__r) from rigalistino__c where Product__c in : listiniMap.keySet()] ){
        listiniMap.get(l.Product__c).add(l);
        elementiListiniMap.put(l.id,l.elementi_contrattuali__r);
    }
    
    list<RigaSottoContratto__c> elToInsert = new list<RigaSottoContratto__c>();
    for(ProdottoSottoContratto__c psc : Trigger.new){
        if(psc.rigalistino__c != null){
            for(RigaListinoElementoContrattuale__c el : elementiListiniMap.get(psc.rigalistino__c)){
                elToInsert.add(
                    new RigaSottoContratto__c(
                        Elemento_Contrattuale__c = el.Elemento_Contrattuale__c,
                        Condizione_di_fatturazione__c = el.Condizione_di_fatturazione__c,
                        Periodico__c = el.Periodico__c,
                        Prezzo_scontato__c = el.Prezzo_esente_IVA__c*(1-el.sconto__c/100),
                        Unita_di_misura_periodo__c = el.Unita_di_misura_periodo__c,
                        Numero_unita_di_misura_periodo__c = el.Numero_unita_di_misura_periodo__c,
                        ProdottoSottoContratto__c = psc.id
                    )
                );
            }
        }else{
            psc.addError('Nessuna riga listino valida trovata per il prodotto, il canale di vendita e la data selezionata');
        }
    }
    
    insert elToInsert;
}