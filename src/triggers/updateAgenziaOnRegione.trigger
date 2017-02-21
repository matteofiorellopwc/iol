trigger updateAgenziaOnRegione on Regione__c (after insert,after update) {

    RevenueApplicationTriggerHandler.skipUpdateRevenues = true;
    Id recordTypeId = [select id from RecordType where sobjecttype = 'Account' and developername = 'Brand'].id;

    set<string> regioni = new set<string>();
    for(Regione__c p : Trigger.new){
        regioni.add(p.name);
    }

    list<account> accs = [Select id 
                          From Account 
                          Where regione_di_competenza__c in : regioni 
                              and Competenza_indipendente_da_indirizzi__c = false
                              and recordTypeId =: recordTypeId
                         ];
    update accs;
}