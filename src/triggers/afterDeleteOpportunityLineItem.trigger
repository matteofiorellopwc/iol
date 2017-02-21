trigger afterDeleteOpportunityLineItem on OpportunityLineItem (after delete){

    list<id> liIdToDelete = new list<id>();
    
    for(OpportunityLineItem oli : Trigger.old){
        liIdToDelete.add(oli.line_item__c);
    }
    
    list<lineitem__c> liToDelete = [select id from lineitem__c where id in : liIdToDelete];
    delete liToDelete;

}