global class BatchableUpdateOrdersFromDfp implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{

    date d;
    public BatchableUpdateOrdersFromDfp(date d){
        this.d = d;
    }
    public BatchableUpdateOrdersFromDfp(){
        this.d = date.today();
    }

    global Iterable<sObject> start(Database.BatchableContext BC){
        return [select id,id_dfp__c,status__c,Tempo_ultima_sincronizzazione__c
                      from Opportunity 
                      where (status__c = 'APPROVED' OR status__c = 'PAUSED' OR status__c = 'PENDING_APPROVAL')
                      AND data_inizio__c < : d.addDays(1)
                      AND data_fine__c > : d.addDays(-2)
                      AND id_dfp__c <> null];
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        LineItemTriggerHandler.skipValidationTotali = true;
        
        list<Opportunity> opps = (list<Opportunity>) scope;
        list<lineitem__c> lineitems = [select id_dfp__c,reservationStatus__c,status__c,clicksDelivered__c,impressionsDelivered__c 
                                          from lineitem__c
                                          where Opportunity__c in : opps
                                          AND start_date__c < : d.addDays(1)
                                          AND end_date__c > : d.addDays(-2)
                                          AND id_dfp__c <> null
                                     ];
        
        try{
            DfpIntegration dfp = new DfpIntegration();
            UtilityOrderIntegration.syncDfpToSfdcOrders(opps,dfp);
            UtilityLineItemIntegration.syncDfpToSfdcLineItems(lineitems,dfp);
    
            update lineitems;  
            for(opportunity o : opps){
                if(o.Tempo_ultima_sincronizzazione__c == 0){
                    o.Ultima_sincronizzazione_DFP__c = system.now();    
                }
            }
            update opps;
        }catch(exception e){
            UtilExceptionIntegration.sendEmailToCustomEmailLog('Error in BatchableUpdateOrdersFromDfp',e+'','IolLog');
        }
    }
    
    global void finish(Database.BatchableContext BC){
        //Update Orders from OAS
        OasApiProxy.getResponses = false;
        UpdateOrdersFromOas.UpdateLineItemByDate(date.today().addDays(-1),date.today().addDays(1));
    }
    
}