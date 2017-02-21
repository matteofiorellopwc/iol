global class BatchableParseDfpReport implements Database.Batchable<Asset> {

    global Iterable<Asset> start(Database.BatchableContext ctx) {
        return new ReportLoggerIterable();
    }
    
    global void execute(Database.BatchableContext ctx, List<Asset> scope) {
        try{
            Set<long> lineItemIds = new Set<long>();
            
            for(Asset a : scope){
                lineItemIds.add(long.valueOf(a.SerialNumber));
            }
            
            //Ho la lista di asset. Devo popolarla con i lineitem
            Map<Long, Lineitem__c> lineItemMap = new Map<Long, Lineitem__c>();
            for(LineItem__c li : [SELECT
                                    Id,
                                    Id_dfp__c,
                                    product__c,
                                    opportunity__r.accountid,
                                    start_date__c,
                                    end_date__c,
                                    totale__c
                                    FROM lineitem__c 
                                    WHERE id_dfp__c in : lineItemIds
                                 ]){
                lineItemMap.put((long) li.id_dfp__c,li);
            }

            List<Asset> filteredAssets = new List<Asset>();
            for(Asset a : scope){
                if(lineItemMap.get(long.valueOf(a.SerialNumber)) != null){
                    lineitem__c li = lineItemMap.get(long.valueOf(a.SerialNumber));
                    a.line_item__c = li.id;
                    a.accountId = li.opportunity__r.accountid;
                    a.SerialNumber = '';
                    a.Product2Id = li.Product__c;        
                    filteredAssets.add(a);
                }
            }
                    
            upsert filteredAssets Asset.Fields.external_key__c;  
        }catch(Exception e)                    {
            UtilExceptionIntegration.sendEmail('Error in ParseDfpReport', e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext ctx) {
        Database.executeBatch(new BatchableSetDatiErogazioneOnAsset(), 100);
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