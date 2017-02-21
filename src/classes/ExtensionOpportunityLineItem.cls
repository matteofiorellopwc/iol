public class ExtensionOpportunityLineItem {
    OpportunityLineItem oli {get;set;}

    public ExtensionOpportunityLineItem(ApexPages.StandardController controller) {
        oli = (OpportunityLineItem) controller.getRecord();
    }
    
    public PageReference redirectView(){
        return new PageReference('/'+oli.Line_Item__c);
    }
    
    public PageReference redirectEdit(){
        return new PageReference('/apex/editLineItem?id='+oli.Line_Item__c);
    }

}