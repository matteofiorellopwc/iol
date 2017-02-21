public class ExtensionViewRevenueApplication {
    ApexPages.StandardController controller;
    public ExtensionViewRevenueApplication(ApexPages.StandardController controller) {
        this.controller = controller;
        if(!Test.isRunningTest()){
            controller.addFields(new list<string>{'obiettivo__c','line_item__c'});        
        }
    }

    public PageReference viewRevenueApplication(){
        PageReference p = null;
        revenue_application__c ra = (revenue_application__c) controller.getRecord();
        if(ra.obiettivo__c){
            p = new PageReference('/apex/Obiettivo?id='+ra.id);
        }else if(ra.line_item__c != null){
            p = new PageReference('/apex/editLineItem?id='+ra.line_item__c);
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore nella visualizzazione della Revenue Application. Contattare l\'amministratore'));
        }
        
        return p;
    }
    
    public static testMethod void testViewRevenueApplication(){
        Opportunity o = new Opportunity();
        //Name, StageName, CloseDate
        o.name = 'Opportunity Test';
        o.stageName = 'Open';
        o.closeDate = date.today();
        insert o; 
        lineitem__c li = new lineitem__c(opportunity__c=o.id);
        insert li;
        
        Revenue_application__c ra = new Revenue_application__c(line_item__c=li.id);
        insert ra;
        ExtensionViewRevenueApplication ex = new ExtensionViewRevenueApplication(new ApexPages.StandardController(ra));
        ex.viewRevenueApplication();
        ra = new Revenue_application__c(line_item__c=li.id);
        ra.obiettivo__c = true;
        insert ra;
        ex = new ExtensionViewRevenueApplication(new ApexPages.StandardController(ra));
        ex.viewRevenueApplication();
       
        
    }
}