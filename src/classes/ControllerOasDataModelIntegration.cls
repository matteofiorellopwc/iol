public class ControllerOasDataModelIntegration {

    public AsyncApexJob  aaj {get;set;}

    public void syncPagesSections() {
        BatchableUpsertDatamodelOas.getPagesSection();
        id sfdcJobID = Database.executeBatch(new BatchableUpsertDatamodelOas(),10);
        aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: sfdcJobID ];     
    }
    
    public void getJobStatus(){
        aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: aaj.id];
    }
    
}