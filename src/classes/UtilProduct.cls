public class UtilProduct{

   public static string getAdditionaFields(){
        return  '(Select Id From PricebookEntries), '+
                '         (Select dayOfWeek__c, Start_Hour__c, End_Hour__c, Start_Minute__c, End_Minute__c, LineItem__c, Product__c From Day_Part_Targeting__r), '+
                '         (Select LineItem__c, Product__c, maxImpressions__c, numTimeUnits__c, timeUnit__c From Frequency_Caps__r), '+
                '         (Select Ad_Unit__c, SectionOas__c, Product__c, includeDescendants__c, InventoryTargetingType__c, LineItem__c From Inventory_Target__r), '+
                '         (Select Product__c, LineItem__c, Type__c, isTargeted__c, valueIds__c, Values__c From Technology_Targeting__r), '+
                '		  (Select Product__c, Line_Item__c,Label__c From AppliedLabel__r),'+
                '		  (Select Product__c, LineItem__c,SectionOas__c From SectionsOasTargeted__r),'+
                '		  (Select Categoria__c,LineItem__c,Names__c,Oas_Field__c,Product__c,Values__c from CookieSearchTermsOASTargeted__r),'+
                '         (Select IncludedValuesIds__c,matches__c, ExcludedValuesIds__c,LineItem__c,Product__c from Geography__r),'+
                '         (Select Product__c, Line_Item__c, Placement__c From PlacementTargeting__r)';
    }
    
    public static list<product2> getProductsByIds(set<id> ids){
        string query = Util.getFieldsSOQL('Product2', ' id in : ids ', false,getAdditionaFields(),false);
        return database.query(query);
    }  
    
    public static testMethod void testUtilProduct(){
        UtilProduct.getAdditionaFields();
        UtilProduct.getProductsByIds(new set<id>());
    }

}