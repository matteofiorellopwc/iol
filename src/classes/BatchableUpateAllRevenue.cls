global class BatchableUpateAllRevenue implements Database.Batchable<sObject>{

    global Iterable<sObject> start(Database.BatchableContext BC){
        return [select id from revenue_application__c where mese__c <> 'Totale'];
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        update scope;
    }

    global void finish(Database.BatchableContext BC){
        
    }
}