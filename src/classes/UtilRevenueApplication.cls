public class UtilRevenueApplication{
    public AsyncApexJob  aaj {get;set;}

    public void updateAllRevenueApplication(){
        id sfdcJobID = Database.executeBatch(new BatchableUpateAllRevenue (),1000);
        aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: sfdcJobID ];
    }
    public void getJobStatus(){
        aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: aaj.id];
    }
    
    public static testMethod void testUtilRevenueApplication(){
        UtilRevenueApplication u = new UtilRevenueApplication();
        u.updateAllRevenueApplication();
        u.getJobStatus();
    }
}