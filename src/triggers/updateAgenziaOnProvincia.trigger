trigger updateAgenziaOnProvincia on Provincia__c (after insert,after update) {

    RevenueApplicationTriggerHandler.skipUpdateRevenues = true;

    Id recordTypeId = [select id from RecordType where sobjecttype = 'Account' and developername = 'Brand'].id;

    set<string> sigle = new set<string>();
    for(Provincia__c p : Trigger.new){
        sigle.add(p.sigla__c);
    }

    list<account> accs = [select id 
                          from account 
                          where provincia_di_competenza__c in : sigle 
                              and Competenza_indipendente_da_indirizzi__c = false
                              and recordTypeId =: recordTypeId
                         ];
    update accs;

}