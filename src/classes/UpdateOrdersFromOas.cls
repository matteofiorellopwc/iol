public class UpdateOrdersFromOas{
    
    /*
        update status/impressions/clicks for line items delivered in fromDate-toDate range
    */

    public static void UpdateLineItemByDate(date fromDate,date toDate){
        list<lineitem__c> lineitems = [select id_oas__c,reservationStatus__c,status_oas__c,clicksDelivered__c,impressionsDelivered__c 
                                          from lineitem__c
                                          where start_Date__c <= : toDate 
                                          AND end_Date__c >= : fromDate
                                          AND id_oas__c <> null
                                      ];
        try{
            OasIntegration oas = new OasIntegration();
            map<string,oasIntegration.campaignClass> campMap = new map<string,oasIntegration.campaignClass>(); 
            for(oasIntegration.campaignClass c : oas.getCampaignClass(oas.listCampaignByDate(toDate,fromDate),false)){ //use string methods instead of regex 
                campMap.put(c.id,c);
            }

            for(lineitem__c li : lineitems){
                if(campMap.get(li.id_oas__c) != null){
                    system.debug('salesforce : ' + li);
                    system.debug('oas : ' + campMap.get(li.id_oas__c));
                    li.status_oas__c = campMap.get(li.id_oas__c).status ;
                    if(campMap.get(li.id_oas__c).ClicksDelivered != null && campMap.get(li.id_oas__c).ClicksDelivered != ''){
                        li.clicksDelivered__c = decimal.valueOf(campMap.get(li.id_oas__c).ClicksDelivered) ;
                    }
                    if(campMap.get(li.id_oas__c).ImpDelivered != null &&  campMap.get(li.id_oas__c).ImpDelivered != '' ){
                        li.impressionsDelivered__c = decimal.valueOf(campMap.get(li.id_oas__c).ImpDelivered) ;
                    }
                }
            }
                
            LineItemTriggerHandler.skipValidationTotali = true;
            Database.SaveResult[] saveRes = database.update(lineitems,false);
            for(Database.SaveResult sr : saveRes){
                if(! sr.isSuccess()){
                    system.debug(sr.getErrors());            
                }
            }
        }catch(exception e){
            UtilExceptionIntegration.sendEmail('Error in updateLineItemByDate',e+'');
        }
    }
}