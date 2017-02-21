global class ScheduledUpdateOrdersFromAdServer implements Schedulable{
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new BatchableUpdateOrdersFromDfp(),10);
        //on finish update orders from oas
    }
    
}