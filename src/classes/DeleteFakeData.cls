global class DeleteFakeData implements Schedulable{

    global void execute(SchedulableContext context){
        Database.delete([SELECT Id FROM LineItem__c WHERE Opportunity__r.Name LIKE '%Test_CPM_availability' AND Opportunity__r.Tipo_Opportunity__c = 'Test' LIMIT 10000]);
    }
}