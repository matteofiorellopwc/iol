global class ScheduledReleaseReservation implements Schedulable{
    global void execute(SchedulableContext sc) {
        releaseReservation();
    }
    
    @future(callout=true)
    public static void releaseReservation(){
        LineItemTriggerHandler.skipValidationTotali = true;
        
        list<decimal> ids = new list<decimal>();
        list<lineitem__c> lineitems = [select id_dfp__c,reservationStatus__c,delivery_model__c,type_dfp__c
                                       from lineitem__c
                                       where reservationStatus__c = 'RESERVED' and 
                                       status__c = 'DRAFT' and
                                       opportunity__r.status__c = 'DRAFT' and
                                       //data_annullamento_prenotazione__c <= : date.today()
                                       opportunity__r.data_annullamento_prenotazione__c <= : date.today() and
                                       start_date__c >= : date.today()
                                       
                             ];
        for(lineitem__c li : lineitems){
            if(li.type_dfp__c == 'SPONSORSHIP' || li.type_dfp__c == 'STANDARD'){
                ids.add(li.id_dfp__c);
            }
            li.reservationStatus__c = 'UNRESERVED';
        }
        
        //TODO try - catch exception, notify errors
        if(ids.size() > 0){
            UtilityLineItemIntegration.releaseLineItems(ids);
        }
        update lineitems;
    }
}