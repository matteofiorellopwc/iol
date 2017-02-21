public class ExtensionEditProduct {

    public ApexPages.StandardController controller {get;set;}
    public Product2 prod {get;set;}
    public Integer inventoryTargetCount {get;set;}

    public ExtensionEditProduct(ApexPages.StandardController controller) {
        prod = (product2) controller.getRecord();
        this.controller = controller;
		this.inventoryTargetCount = [SELECT Count() FROM Inventory_target__c WHERE Product__c = :prod.Id];
    }
    
     public PageReference checkRecordType(){
         list<recordType> rt = [select name from recordType where id =: prod.recordtypeid];
         if(rt.size() == 1 && rt[0].name.toLowerCase().contains('itnet')){
             return new PageReference('/'+prod.id+'?nooverride=1');
         }
         return null;
     }
    
    public pageReference customSave(){
        return controller.save();
    }
    
    public void changeAdUnitType(){
        List<PlacementTargeting__c> pt = [select id from PlacementTargeting__c where Product__c =: prod.Id];
        List<Inventory_Target__c> it = [select id from Inventory_Target__c where Product__c =: prod.Id];
        delete pt;
        delete it;      
        controller.save();
    }
    
    static testMethod void testController() {
        
        Product2 p = new Product2();
        p.name = 'Test';
        insert p;     
        
        ApexPages.StandardController sc = new ApexPages.standardController(p);
        
        ExtensionEditProduct ep = new ExtensionEditProduct(sc);
        ep.changeAdUnitType();
        ep.customSave();

     } 
     
}