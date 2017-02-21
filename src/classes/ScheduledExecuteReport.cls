/*
        executes dfp reports and imports delivered data:
            every day at 3 -> run previous day flat
            first day of month at 3 -> run previous month flat
            every day at 5 -> run previous day top_level
            first day of month at 5 -> run previous month top_level
            every day at 10 and 12 -> retry import if it's failed
*/

global class ScheduledExecuteReport implements Schedulable {

    global void execute(SchedulableContext sc) {
        Datetime now = Datetime.now();
        Date d = Date.today().addDays(-1);
        Boolean firstDayOfMonth = now.day() == 1;
        if(now.hour() == 3) {
            runReport('FLAT', true, d); //day flat
            if(firstDayOfMonth) {
                runReport('FLAT', false, d); //month flat
            }
        }
        /*else if(now.hour() == 5) {
            runReport('TOP_LEVEL', true, d); //day top level
            if(firstDayOfMonth) {
                runReport('TOP_LEVEL', false, d); //month top level
            }
        }*/ 
        else if(now.hour() == 10 || now.hour() == 12 ){
            
            boolean dayFlat = false;
            boolean dayTop = false;
            boolean monthFlat = false;
            boolean monthTop = false;
            
            
            for(reportlogger__c rl : [select tipo__c,adUnitView__c from reportlogger__c where Data_generazione__c =: d and stato__c = 'COMPLETED']){
                if(rl.tipo__c == 'Giornaliero' && rl.adUnitView__c == 'FLAT'){
                    dayFlat = true;
                }
                /*if(rl.tipo__c == 'Giornaliero' && rl.adUnitView__c == 'TOP_LEVEL'){
                    dayTop = true;
                }*/
                if(rl.tipo__c == 'Mensile' && rl.adUnitView__c == 'FLAT'){
                    monthFlat = true;
                }
                /*if(rl.tipo__c == 'Mensile' && rl.adUnitView__c == 'TOP_LEVEL'){
                    monthTop = true;
                }*/
            }
        
            if(!dayFlat){
                runReport('FLAT', true, d);
            }
            /*if(!dayTop){
                runReport('TOP_LEVEL', true, d);
            }*/
            if(!monthFlat && firstDayOfMonth){
                runReport('FLAT', false, d);
            }
            /*if(!monthTop && firstDayOfMonth){
                runReport('TOP_LEVEL', false, d);
            }*/
            
        }else{
            Database.executeBatch(new BatchableCheckReportStatus(), 1);
        }
    }
    
    @future(callout=true)
    public static void runReport(String adUnitView, Boolean dayOrMonth, Date d) {
        UtilityReportIntegration.runReport(adUnitView, dayOrMonth, d);      
    }                  
}