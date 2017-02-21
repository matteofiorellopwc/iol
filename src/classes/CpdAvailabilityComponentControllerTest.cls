@IsTest
public class CpdAvailabilityComponentControllerTest{
    
    public static testMethod void testCpdAvailabilityComponentController(){
        Opportunity o = utilityTest.insertDfpOasOpp();
        
        ApexPages.StandardController oppStndCtrl = new ApexPages.standardController(o);
        ExtensionAddProduct controller = new ExtensionAddProduct(oppStndCtrl);
        controller.prodId = utilityTest.createBannerCPD().id;
        controller.addProduct(); 
        system.debug('line items ' + [select id,delivery_model__c,skipDispoCpd__c,goal__c from lineitem__c ]);
        
        Test.startTest();
        ApexPages.CurrentPage().getParameters().put('id',o.id);
        CpdAvailabilityComponentController c = new CpdAvailabilityComponentController();
        c.cpdAvailability();
        while(c.IsRunning){
            c.checkAvailabilityLi();
        }
        Test.stopTest();
    }

}