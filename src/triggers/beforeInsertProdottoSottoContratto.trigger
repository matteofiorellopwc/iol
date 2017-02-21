trigger beforeInsertProdottoSottoContratto on ProdottoSottoContratto__c (before insert) {

    Map<id,list<RigaListino__c>> listiniMap =new Map <id,list<RigaListino__c>>(); //id prod -> listini
        
    for(Product2 p : [select id from product2 where recordTypeId =: UtilItNet.itNetProductRecordTypeId]){
        listiniMap.put(p.id,new list<RigaListino__c>());
    }
    Map<id,RigaListino__c> righeMap = new Map<id,RigaListino__c>([select id,listino__r.canale_di_vendita__c,Data_inizio_validita__c,Data_fine_validita__c,Product__c,rinnovo_automatico__c
                                                                  from RigaListino__c 
                                                                  where Product__c in : listiniMap.keySet()]);
    for(RigaListino__c l : righeMap.values() ){
        listiniMap.get(l.Product__c).add(l);
    }
    
    for(ProdottoSottoContratto__c psc : Trigger.new){
        psc.email__c = psc.email_cliente__c;
        if(psc.RigaListino__c == null){
            psc.RigaListino__c = UtilItNet.checkListini(psc.canale_di_vendita__c,psc.data_decorrenza__c,listiniMap.get(psc.Prodotto__c));
            if(psc.RigaListino__c != null){
                psc.rinnovo_automatico__c = righeMap.get(psc.RigaListino__c).rinnovo_automatico__c;
            }
        }else{
            psc.rinnovo_automatico__c = righeMap.get(psc.RigaListino__c).rinnovo_automatico__c;
        }
    }
}