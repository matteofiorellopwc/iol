global class BatchableUpsertImpressionStimate implements Database.Batchable<SObject> {
    public static final String query = Util.getFieldsSOQL('Product2', ' Delivery_Model__c = \'CPD\' AND CalcolaCPDconImprStimate__c = true', false, '', false);

    global Database.Querylocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, SObject[] scope) {
        ProductTriggerHandler.createImpressionStimateObj(scope, null, false);       
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }

}