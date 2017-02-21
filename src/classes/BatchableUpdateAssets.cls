global class BatchableUpdateAssets implements Database.Batchable<sObject>{

    set<id> liToUpdateAsset;

    public BatchableUpdateAssets(set<id> liToUpdateAsset){
        this.liToUpdateAsset = liToUpdateAsset;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('select id from asset where line_item__c in : liToUpdateAsset');
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        update scope;
    }

    global void finish(Database.BatchableContext BC){
        
    }
}