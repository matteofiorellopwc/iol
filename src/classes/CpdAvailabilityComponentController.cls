public class CpdAvailabilityComponentController {
    public id soId {get;set;} //id opportunity or id line item
    public sobject[] sobjects {get;set;} // [opportunity] or [li1,li2,...]
    public list<lineItem__c> lis {get;set;}
    public integer index {get;set;}
    public string errors {get;set;}
    public boolean isError {get;set;}
    public boolean isRunning {get;set;}
    public Boolean skipDispoCpd {get;set;}

    public CpdAvailabilityComponentController(){
        errors = '';
        isError = false;
        isRunning = false;
    }
    
    public void cpdAvailability(){
        soId = ApexPages.CurrentPage().getParameters().get('id');
        skipDispoCpd = false;
        if(soId.getSObjectType() == Opportunity.getSObjectType()){
            lis = UtilityLineItemIntegration.getLineItemsByOppId(soId,false);
            skipDispoCpd = [select skipDispoCpd__c from opportunity where id=: soId].skipDispoCpd__c;
        }else{
            lis = new list<lineitem__c>{ UtilityLineItemIntegration.getLineItemBySfdcId(soId) };
        }
        for(integer i=lis.size()-1;i>=0;i--){
            if(! (lis[i].delivery_model__c == 'CPD' && !lis[i].skipDispoCpd__c && lis[i].end_date__c >= date.today() && lis[i].goal__c != null)){
                lis.remove(i);
            }
        }
        index = 0;
        errors = '';
        isError = false;
        if(lis.size() > 0 && ! skipDispoCpd){
            isRunning = true;
        }
    }
    
    public void checkAvailabilityLi(){
        if(isRunning){
            isError = ControllerCpdAvailability.checkAvailabilityLineItems(new list<lineitem__c>{ lis.get(index) }) ? isError : true;
    
            if(ApexPages.getMessages()!=null && ApexPages.getMessages().size()!=0){
                for(ApexPages.Message m : ApexPages.getMessages()){
                    errors+=m.getSummary(); 
                }
            }
            errors = string.escapeSingleQuotes(errors);
            index++;
            if(index >= lis.size()){
                index--;
                isRunning = false;
            }
        }
    }
    
    
    
}