@isTest
private class ExtensionEditLineItemTest {

	private static Opportunity opportunity;
    private static Product2 product;

	@isTest static void test_method_one() {
		prepareData();

		LineItem__c lineitemDfp = new LineItem__c(
            Product__c = product.Id,
            Opportunity__c = opportunity.Id,
            id_DFP__c = 123
        );
        insert lineitemDfp;
        try{
        	ExtensionEditLineItem.getDataFineLineItem(lineitemDfp);
        }catch(Exception e){}
        LineItem__c lineitemOas = new LineItem__c(
            Product__c = product.Id,
            Opportunity__c = opportunity.Id,
            Id_oas__c = '123'
        );
        insert lineitemOas;
        try{
        	ExtensionEditLineItem.getDataFineLineItem(lineitemOas);
        }catch(Exception e){}
	}
	

	
	private static void prepareData(){
        LineItemTriggerHandler.skipValidationAdServer = true;
        opportunity = new Opportunity(
                    name = 'test',
                    CloseDate = Date.today(),
                    stageName = 'test'
        );
        insert opportunity;
        
        product = new Product2(
            Name = 'Test',
            Family = 'Banner',
            BasePrice__c = 0,
            Breakeven_cost__c = 0,
            ConsentiModificaSeMesiChiusi__c = false,
            Local__c = false       
        );
        insert product;
    }
}