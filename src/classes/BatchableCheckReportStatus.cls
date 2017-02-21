global class BatchableCheckReportStatus implements Database.Batchable<SObject>, Database.AllowsCallouts {
    private static final String query = 'SELECT Name, Stato__c, Tipo__c, new_download_url__c, AdUnitView__c, Data_generazione__c FROM ReportLogger__c WHERE Stato__c = \'IN_PROGRESS\'';
    
    global Database.QueryLocator start(Database.BatchableContext ctx) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext ctx, List<SObject> scope) {    
        //Controllo se il report è finito e nel caso recupero l'url del report
        ReportLogger__c rl = (ReportLogger__c) scope.get(0);
        Long jobId = Long.valueOf(rl.Name);
        String job;
        try{
            job = UtilityReportIntegration.pollReportStatus(jobId);
        }catch(exception e){
            if(e.getMessage().contains('REPORT_NOT_FOUND')){
                UtilityReportIntegration.runReport(rl.AdUnitView__c, rl.Tipo__c == 'Giornaliero' ? true : false , rl.Data_generazione__c);
                rl.stato__c  = 'REPORT_NOT_FOUND';
                update rl;
            }
            return;
        }
        
        
        if(job == 'COMPLETED') {
            rl.Stato__c = 'READY';
            rl.new_download_url__c = UtilityReportIntegration.getReportUrl(jobId);             
        }else{
            return;
        }

        //Scarico il CSV del report
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(rl.new_download_url__c);
        req.setMethod('GET');                
        HttpResponse res = h.send(req);
        String body = res.getBody();
        
        //Salvo il csv come attachments
        Attachment att = new Attachment();
        att.body = Blob.valueOf(body);
        att.name = 'assets.csv';
        att.parentid = rl.id;
        insert att;
        att = null;
        
        update rl;
        
    }
    
    global void finish(Database.BatchableContext ctx) {
        Database.executeBatch(new BatchableParseDfpReport(), 100);
    }
    
/* recupero dati giornalieri

    set<date> datepresenti = new set<date>();
    for(reportlogger__c rl : [select Data_generazione__c from reportlogger__c where tipo__c = 'Giornaliero' and stato__c = 'COMPLETED']){
        datepresenti.add(rl.Data_generazione__c);
    }
    
    date startDate = date.newinstance(2013,1,1);
    
    integer x = 0;
    
    date d = startDate;
    while(d < date.today() && x < 10 ){
        if(!datepresenti.contains(d)){
            ScheduledExecuteReport.runReport('TOP_LEVEL', true, d);
            x++;
        }
        d = d.addDays(1);
    }
    
*/

    
}







/*

global class BatchableCheckReportStatus implements Database.Batchable<SObject>, Database.AllowsCallouts {
    private static final String query = 'SELECT Name, Stato__c, Tipo__c, new_new_download_url__c, AdUnitView__c, Data_generazione__c FROM ReportLogger__c WHERE Stato__c = \'IN_PROGRESS\'';
    
    global Database.QueryLocator start(Database.BatchableContext ctx) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext ctx, List<SObject> scope) {    
        //Controllo se il report è finito e nel caso recupero l'url del report
        ReportLogger__c rl = (ReportLogger__c) scope.get(0);
        Long jobId = Long.valueOf(rl.Name);
        system.debug('report logger '+jobId);
        String job;
        try{
            job = UtilityReportIntegration.pollReportStatus(jobId);
        }catch(exception e){
            if(e.getMessage().contains('REPORT_NOT_FOUND')){
                UtilityReportIntegration.runReport(rl.AdUnitView__c, rl.Tipo__c == 'Giornaliero' ? true : false , rl.Data_generazione__c);
                rl.stato__c  = 'REPORT_NOT_FOUND';
                update rl;
            }
            return;
        }
        
        
        if(job == 'COMPLETED') {
            rl.Stato__c = 'READY';
            rl.new_new_download_url__c = UtilityReportIntegration.getReportUrl(jobId);

        }else{
            return;
        }

        //Scarico il CSV del report
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(rl.new_new_download_url__c);
        req.setMethod('GET');                
        HttpResponse res = h.send(req);
        String body = res.getBody();
        
        
		
        
        
        //Salvo il csv come attachments
       /* Attachment att = new Attachment();
        att.body = Blob.valueOf(body);
        att.name = 'assets.csv';
        att.parentid = rl.id;
        insert att;
        att = null;
        
        update rl;
        
        
        
   /////////////////////nuovo codice
   
   
   // 1 mb di limite peso file
integer weight_limit =1000000;

 /*Http h = new Http();
 HttpRequest req = new HttpRequest();
 String u='http://vitv.it/test/assets.csv';
 req.setEndpoint(u);
req.setMethod('GET');                
HttpResponse res = h.send(req);
String body = res.getBody();

integer bodyLength=body.length();
system.debug('bodyLength '+bodyLength);

String testataCSV=body.substring(0,body.indexOf('\n'));

if(bodyLength<weight_limit){
    weight_limit=bodyLength;
}

integer currOffset=0;
integer count=0;
integer righeTot=body.countMatches('\n');
system.debug('nr righe'+righeTot);
while(currOffset<bodyLength){
        String file_uno='';
        if(count==0){
            file_uno=body.substring(0,weight_limit);
        }else{
            file_uno=testataCSV;
            if(currOffset+weight_limit>body.length())
            file_uno+=body.substring(0+currOffset,body.length());
            else
            file_uno+=body.substring(0+currOffset,currOffset+weight_limit);
        }
       
        
        system.debug(count+': prima del trim file uno lungo '+file_uno.length());
        file_uno=file_uno.substring(0,file_uno.lastIndexOf('\n'));
        Attachment att = new Attachment();
        att.body = Blob.valueOf(file_uno);
        att.name = 'asset_'+count+'.csv';
        att.parentid = rl.id;
        system.debug(count+': dopo del trim file uno lungo '+file_uno.length());
        system.debug('nr righe file 1'+file_uno.countMatches('\n'));

        insert att;
        att = null;
        currOffset+=file_uno.length();
        system.debug('fine del loop currOffset '+currOffset);
        count ++;
       
}     
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    }
    
    global void finish(Database.BatchableContext ctx) {
        Database.executeBatch(new BatchableParseDfpReport(), 100);
    }
    
 recupero dati giornalieri

    set<date> datepresenti = new set<date>();
    for(reportlogger__c rl : [select Data_generazione__c from reportlogger__c where tipo__c = 'Giornaliero' and stato__c = 'COMPLETED']){
        datepresenti.add(rl.Data_generazione__c);
    }
    
    date startDate = date.newinstance(2013,1,1);
    
    integer x = 0;
    
    date d = startDate;
    while(d < date.today() && x < 10 ){
        if(!datepresenti.contains(d)){
            ScheduledExecuteReport.runReport('TOP_LEVEL', true, d);
            x++;
        }
        d = d.addDays(1);
    }
    


    
}*/