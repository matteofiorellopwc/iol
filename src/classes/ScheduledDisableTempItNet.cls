global class ScheduledDisableTempItNet implements Schedulable {    
    //System.schedule('ScheduledDisableTempItNet', '0 0 * * * ?', new ScheduledDisableTempItNet());

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new BatchableDisableTempItNet(), 10);
    }        

}