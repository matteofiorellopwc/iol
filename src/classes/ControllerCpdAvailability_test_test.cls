@isTest private class ControllerCpdAvailability_test_test {
 
 /*
 @isTest static void testControllerCpdAvailability() {
        LineItemTriggerHandler.skipValidationTotali = true;
    
     AdUnit__c adu = new AdUnit__c(name='test',idDfp__c='adunit1',status__c='ACTIVE');
         insert adu;

         ControllerCPDAvailability_test cpdController = new ControllerCpdAvailability_test();
         
         Product2 prod = new Product2();
         prod.Name = 'Test prod';
         prod.Size__c = '0x0';
         prod.delivery_model__c = 'CPD';
         prod.Canale_Primario__c = 'HP';
         prod.Categoria_libero__c = 'Display';
         prod.fascia_oraria__c = '8-12';
         prod.Formato__c = 'Wallpaper';
         prod.Family = 'Banner';
         prod.ad_server__c = 'DFP';
         prod.isActive = true;
         prod.local__c = false;
         prod.type__c = 'asd';
         insert prod;
        
         Opportunity o = new Opportunity(Name='Test opp',StageName='Close won',closeDate = date.today());
         insert o;
         
         CPDTemplate__c template = new CPDTemplate__c();
         template.Name = 'Template test';
         insert template;
         
         LineItem__c li = new LineItem__c();
         li.skipValidationAdServer__c = true;
         li.Product__c = prod.id;
         li.Opportunity__c = o.id;
         li.Start_Date__c = date.today();
         li.end_Date__c = date.today();
         li.goal__c = 100;
         insert li;
         
         LineItem__c li2 = new LineItem__c();
         li2.skipValidationAdServer__c = true;
         li2.Product__c = prod.id;
         li2.Opportunity__c = o.id;
         li2.Start_Date__c = date.today();
         li2.end_Date__c = date.today();
         li2.goal__c = 100;
         insert li2;
         revenue_application__c ra = new revenue_application__c(Mese__c='Gennaio',Anno__c='2013',line_item__c=li2.id,percentuale_applicata__c = 100,valore__c=0);
         insert ra;
                  
         li = UtilityLineItemIntegration.getLineItemBySfdcId(li.id);
         Map<String,boolean> checkedAvailability = cpdController.checkAvailabilityLineItem(li);
         
         //Il lineItem li deve andare in blocco con li2 perchè lo riservo li2
         li2.reservationStatus__c = 'RESERVED';
         update li2;
         li2 = UtilityLineItemIntegration.getLineItemBySfdcId(li2.id);
         checkedAvailability = cpdController.checkAvailabilityLineItem(li);
         
         //Testing with standard controller       
         ApexPages.StandardController sc = new ApexPages.standardController(li); 
         cpdController = new ControllerCpdAvailability_test(sc);         

    }
    */
    @isTest static void testControllerCpdAvailability_multisize() {
        LineItemTriggerHandler.skipValidationTotali = true;
    
     AdUnit__c adu = new AdUnit__c(name='test',idDfp__c='adunit1',status__c='ACTIVE');
         insert adu;

         ControllerCPDAvailability_test cpdController = new ControllerCpdAvailability_test();
         
         Product2 prod = new Product2();
         prod.name = 'Test prod';
         prod.Size__c = '0x0';
         prod.Delivery_Model__c = 'CPD';
         prod.Canale_Primario__c = 'HP';
         prod.size__c = 'Multisize';
         prod.multisize__c = '120x270;240x1440';
         prod.Categoria_libero__c = 'Display';
         prod.fascia_oraria__c = '0-24';
         prod.Formato__c = 'Wallpaper';
         prod.Family = 'Banner';
         prod.ad_server__c = 'DFP';
         prod.isActive = true;
         prod.local__c = false;
         prod.type__c = 'asd';
         insert prod;
        
         Opportunity o = new Opportunity(Name='Test opp',StageName='Close won',closeDate = date.today());
         insert o;
                  
         CPDTemplate__c template = new CPDTemplate__c();
         template.Name = 'Template test';
         insert template;
         
         LineItem__c li = new LineItem__c();
         li.skipValidationAdServer__c = true;
         li.Product__c = prod.id;
         li.Opportunity__c = o.id;
         li.Start_Date__c = date.today();
         li.end_Date__c = date.today();
         li.goal__c = 100;
         insert li;
         
         LineItem__c li2 = new LineItem__c();
         li2.skipValidationAdServer__c = true;
         li2.Product__c = prod.id;
         li2.Opportunity__c = o.id;
         li2.Start_Date__c = date.today();
         li2.end_Date__c = date.today()+2;
         li2.goal__c = 100;
         insert li2;
         revenue_application__c ra = new revenue_application__c(Mese__c='Gennaio',Anno__c='2013',line_item__c=li2.id,percentuale_applicata__c = 100,valore__c=0);
         insert ra;
                  
         li = UtilityLineItemIntegration.getLineItemBySfdcId(li.id);
         Map<String,boolean> checkedAvailability = cpdController.checkAvailabilityLineItem(li);
         
         //Il lineItem li deve andare in blocco con li2 perchè lo riservo li2
         li2.reservationStatus__c = 'RESERVED';
         update li2;
         li2 = UtilityLineItemIntegration.getLineItemBySfdcId(li2.id);
         checkedAvailability = cpdController.checkAvailabilityLineItem(li);
         
         //Testing with standard controller       
         ApexPages.StandardController sc = new ApexPages.standardController(li); 
         cpdController = new ControllerCpdAvailability_test(sc);         

    }
    /*
    @isTest static void testControllerCpdAvailability_null() {
        LineItemTriggerHandler.skipValidationTotali = true;
    
     AdUnit__c adu = new AdUnit__c();
         insert adu;

         ControllerCPDAvailability_test cpdController = new ControllerCpdAvailability_test();

         
         Product2 prod = new Product2();
         prod.name = 'Test prod';
         prod.Delivery_Model__c = 'CPD';
         prod.Canale_Primario__c = 'HP';
         prod.size__c = '';
         prod.multisize__c = '';
         prod.Categoria_libero__c = 'Display';
         prod.fascia_oraria__c = '0-24';
         prod.Formato__c = 'Wallpaper';
         prod.Family = 'Banner';
         insert prod;
        
         Opportunity o = new Opportunity(Name='Test opp',StageName='Close won',closeDate = date.today());
         insert o;
         
         CPDTemplate__c template = new CPDTemplate__c();
         template.Name = 'Template test';
         insert template;
         
         LineItem__c li = new LineItem__c();
         li.skipValidationAdServer__c = true;
         li.Product__c = prod.id;
         li.Opportunity__c = o.id;
         li.Start_Date__c = date.today();
         li.end_Date__c = date.today()-1;
         li.goal__c = 100;
         insert li;
         
         LineItem__c li2 = new LineItem__c();
         li2.skipValidationAdServer__c = true;
         li2.Product__c = prod.id;
         li2.Opportunity__c = o.id;
         li2.Start_Date__c = date.today();
         li2.end_Date__c = date.today()+2;
         li2.goal__c = 100;
         insert li2;
         revenue_application__c ra = new revenue_application__c(Mese__c='Gennaio',Anno__c='2013',line_item__c=li2.id,percentuale_applicata__c = 100,valore__c=0);
         insert ra;
                  
         li = UtilityLineItemIntegration.getLineItemBySfdcId(li.id);
         Map<String,boolean> checkedAvailability = cpdController.checkAvailabilityLineItem(li);
         system.debug('@@@'+checkedAvailability.values());
         
         //Il lineItem li deve andare in blocco con li2 perchè lo riservo li2
         li2.reservationStatus__c = 'RESERVED';
         update li2;
         li2 = UtilityLineItemIntegration.getLineItemBySfdcId(li2.id);
         checkedAvailability = cpdController.checkAvailabilityLineItem(li);
         
         //Testing with standard controller       
         ApexPages.StandardController sc = new ApexPages.standardController(li); 
         cpdController = new ControllerCpdAvailability_test(sc);         

    } */
   }