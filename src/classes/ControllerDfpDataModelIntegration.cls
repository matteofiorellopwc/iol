public class ControllerDfpDataModelIntegration {

    public AsyncApexJob  aaj {get;set;}

    public void syncDfpDataModel() {
        id sfdcJobID = Database.executeBatch(new BatchableUpdateDfpDataModel(100), 1);
        aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: sfdcJobID ];     
    }
    
    public void getJobStatus(){
        aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: aaj.id];
    }
    
}