trigger onBeforeOptional on Optional__c (before insert,before update) {
    for(Optional__c o : Trigger.new){
        o.incremento_calcolato_lineitem__c = o.Incremento_calcolato_lineitem_formula__c;
    }
}