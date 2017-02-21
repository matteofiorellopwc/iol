trigger beforeUpdateProdottoSottoContratto on ProdottoSottoContratto__c (before update) {
    
    for(ProdottoSottoContratto__c psc : Trigger.new){
        if(psc.chiuso__c && !Trigger.oldMap.get(psc.id).chiuso__c){
            psc.operation__c = 'DEL';
        }else if(psc.sospeso__c && !Trigger.oldMap.get(psc.id).sospeso__c){
            psc.operation__c = 'SUS';
        }else if(!psc.sospeso__c && Trigger.oldMap.get(psc.id).sospeso__c){
            psc.operation__c = 'ACT';
        }
    }

}