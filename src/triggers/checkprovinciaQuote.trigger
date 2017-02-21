trigger checkprovinciaQuote on Quote (before insert,before update) {

    map<string,string> mappaProvincia = new map<string,string>();
    for(Provincia__c p : [select sigla__c,Regione__c from provincia__c]){
        mappaProvincia.put(p.sigla__c,p.regione__c);
    }
    
    for(Quote q : Trigger.new){
        if(!isBlank(q.quoteToState)){
            if(! mappaProvincia.keySet().contains(q.quoteToState)){
                q.quoteToState.addError('Provincia non trovata, inserire la sigla oppure EE se stato estero');            
            }
        }
        if(!isBlank(q.shippingState)){
            if(! mappaProvincia.keySet().contains(q.shippingState)){
                q.shippingState.addError('Provincia non trovata, inserire la sigla oppure EE se stato estero');
            }
        }
    }
    

    public boolean isBlank(String s){
        return s == null || s == '';
    }




/*
    set<id> accounts = new set<id>();
    
    for(Quote q : Trigger.new){
        accounts.add(q.AccountId__c);
    }
    

    Map<Id,list<indirizzo__c>> indirizziAccountMap = new Map<Id,list<indirizzo__c>>();
    
    for(indirizzo__c i : [Select Account__c,Via__c, Tipo__c, Stato__c, Provincia__c, Citta__c, Cap__c From Indirizzo__c where Account__c =: accounts]){
        if(indirizziAccountMap.get(i.Account__c) == null){
            indirizziAccountMap.put(i.Account__c,new list<indirizzo__c>());
        }
        indirizzo__c ii = i.clone();
        ii.account__c = null;
        indirizziAccountMap.get(i.Account__c).add(ii);
    }
    
    list<indirizzo__c> indirizziToInsert = new list<indirizzo__c>();
    for(Quote q : Trigger.new){
        for(indirizzo__c i : indirizziAccountMap.get(q.AccountId__c)){
            indirizzo__c ii = i.clone();
            ii.quote__c = q.id;
            indirizziToInsert.add(ii);
        }
    }
    
    insert indirizziToInsert;
*/
}