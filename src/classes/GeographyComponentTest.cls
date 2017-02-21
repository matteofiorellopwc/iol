@isTest
private class GeographyComponentTest {
	
	@isTest static void run() {
		
		ApexPages.CurrentPage().getParameters().put('sobjectName','LineItem__c');
		//ApexPages.CurrentPage().getParameters().put('Id','a0811000003tEC4AAM');
		Product2 p = new Product2(
            Name = 'Test',
            Family = 'Banner',
            BasePrice__c = 0,
            Breakeven_cost__c = 0       
        );
        insert p;
        
        Account a = utilityTest.insertBrand();
        
        Opportunity opp = new Opportunity(
            Name = 'Test opp',
            AccountId = a.id,
            StageName = 'Closed',
            CloseDate = System.today(),
            Commissione_Agenzia__c = 0
        );
        insert opp;          
        
        LineItem__c li = new LineItem__c(
            Product__c = p.Id,
            Opportunity__c = opp.Id,
            Start_Date__c = Date.today().addDays(1),
            End_Date__c = Date.today().addMonths(2),  
            quantita__c = 1,      
            Ultima_modifica_prezzo__c='Totale',
            Type_dfp__c = 'STANDARD'
        );
        insert li;    
		ApexPages.CurrentPage().getParameters().put('Id',li.Id);

		GeographyController ctrl = new GeographyController();
		GeographyController.Element root = ctrl.results;
		System.assertEquals(1,root.childs.size());
		GeographyController.Element italia = root.childs.get(0);
		System.assertEquals('italia',italia.name);
		System.assertEquals(1,italia.childs.size());
		GeographyController.Element lombardia = italia.childs.get(0);
		System.assertEquals('lombardia',lombardia.name);
		System.assertEquals(1,lombardia.childs.size());
		GeographyController.Element milano = lombardia.childs.get(0);
		System.assertEquals('milano',milano.name);
		System.assertEquals(0,milano.childs.size());
		
		System.assert(ctrl.searchResultJson.length()>0);

		ctrl.goInEditMode();
		System.assertEquals('edit',ctrl.mode);
		System.assertEquals(ctrl.customSave(),null);
	}
	
}