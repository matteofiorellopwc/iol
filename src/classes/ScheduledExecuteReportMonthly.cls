/*
    executes dfp reports and imports delivered data:
        at 3.00             -> run previous month flat
        at 10.00 and 12.00  -> retry import if it's failed
*/

global class ScheduledExecuteReportMonthly implements Schedulable {

    global void execute(SchedulableContext sc) {
        Datetime now = Datetime.now();
        Date d = Date.today().addDays(-1);
        
        if(now.hour() == 3) {
            runReport('FLAT', false, d);
        
        } else if(now.hour() == 10 || now.hour() == 12 ){
            for(reportlogger__c rl : [select tipo__c,adUnitView__c from reportlogger__c where Data_generazione__c =: d and stato__c = 'COMPLETED']){
                runReport('FLAT', false, d);
            }
        
        } else {
            Database.executeBatch(new BatchableCheckReportStatus(), 1);
        }
    }
    
    @future(callout=true)
    public static void runReport(String adUnitView, Boolean dayOrMonth, Date d) {
        UtilityReportIntegration.runReport(adUnitView, dayOrMonth, d);      
    }                  
}