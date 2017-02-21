@isTest
private class ControllerContendingCPMTest {
    @isTest
    static void testController() {
        AdUnit__c root = new AdUnit__c(
            idDfp__c = '0',
            Name = 'root',
            explicitlyTargeted__c = false
        );
        insert root;
        
        AdUnit__c parentAu = new AdUnit__c(
            idDfp__c = '1',
            Name = 'parent',
            ParentAdUnit__c = root.Id,
            explicitlyTargeted__c = true
        );
        
        insert parentAu;
        
        AdUnit__c[] childs = new AdUnit__c[]{};
        AdUnit__c child1 = new AdUnit__c(
            idDfp__c = '2',
            Name = 'child1',
            ParentAdUnit__c = parentAu.id,
            explicitlyTargeted__c = false
        );
        childs.add(child1);
        
        AdUnit__c child2 = new AdUnit__c(
            idDfp__c = '3',
            Name = 'child2',
            ParentAdUnit__c = parentAu.id,
            explicitlyTargeted__c = true
                
        );
        childs.add(child2);

        AdUnit__c child3 = new AdUnit__c(
            idDfp__c = '4',
            Name = 'child3',
            ParentAdUnit__c = parentAu.id,
            explicitlyTargeted__c = false               
        );
        childs.add(child3);

        insert childs;
                
        Product2[] pL = new Product2[]{};
        
        //****** PROD 1
        Product2 p1 = new Product2(
            Name = 'P1',
            Delivery_model__c = 'CPM',
            Priority__c = '2',
            isActive = true,
            Size__c = '300x250'         
        );
        pL.add(p1);
        
        //****** PROD 2
        Product2 p2 = new Product2(
            Name = 'P2',
            Delivery_model__c = 'CPM',
            Priority__c = '2',
            isActive = true,
            Size__c = '300x250'         
        );
        pL.add(p2);
        
        //****** PROD 3
        Product2 p3 = new Product2(
            Name = 'P3',
            Delivery_model__c = 'CPM',
            Priority__c = '2',
            isActive = true,
            Size__c = '300x250'         
        );
        pL.add(p3);

        //****** PROD 4
        Product2 p4 = new Product2(
            Name = 'P4',
            Delivery_model__c = 'CPM',
            Priority__c = '2',
            isActive = true,
            Size__c = 'Multisize',
            multisize__c = '300x250;90x84'          
        );
        pL.add(p4);
        
        insert pL;
        
        Inventory_Target__c[] itL = new Inventory_Target__c[]{};
                
        Inventory_Target__c it1 = new Inventory_Target__c(
            Ad_Unit__c = parentAu.Id,
            Product__c = p1.Id,
            inventoryTargetingType__c = 'targeted'
        );
        itL.add(it1);
        
        Inventory_Target__c it2 = new Inventory_Target__c(
            Ad_Unit__c = child1.Id,
            Product__c = p2.Id,
            inventoryTargetingType__c = 'targeted'
        );
        itL.add(it2);

        Inventory_Target__c it3 = new Inventory_Target__c(
            Ad_Unit__c = child2.Id,
            Product__c = p3.Id,
            inventoryTargetingType__c = 'excluded'
        );
        itL.add(it3);

        Inventory_Target__c it4 = new Inventory_Target__c(
            Ad_Unit__c = child3.Id,
            Product__c = p4.Id,
            inventoryTargetingType__c = 'targeted'
        );
        itL.add(it4);
        
        insert itL;

        FattoreCorrettivoFasceOrarie__c fatt = new FattoreCorrettivoFasceOrarie__c(
            Name = 'default',
            Fattore_correttivo_fascia_0_12__c = 0.3,
            Fattore_correttivo_fascia_12_16__c = 0.3,
            Fattore_correttivo_fascia_16_24__c = 0.4            
        );
        insert fatt;
        
        Provincia__c p = new Provincia__c(name='SO', Sigla__c = 'SO');
        insert p;

        Account cliente = new Account(
            RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Cliente').getRecordTypeId(),
            Name = 'Cliente',
            Ragione_Sociale__c = 'aaaa',
            BillingState = 'SO'
        );
        insert cliente;

        Account brand = new Account(
            RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Brand').getRecordTypeId(),
            Name = 'Brand',
            Cliente_lookup__c = cliente.Id,
            BillingState = 'SO'
        );
        insert brand;
        
        Opportunity o = new Opportunity(
            StageName = '0%',
            CloseDate = Date.today(),
            Name = 'O1',
            AccountId = brand.Id 
        );
        insert o;
        
        ExtensionAddProduct eap = new ExtensionAddProduct(new ApexPages.Standardcontroller(o));
        eap.prodId = p1.Id;
        eap.addProduct();
        
        eap.prodId = p2.Id;
        eap.addProduct();
        
        Test.StartTest();
        
        eap.prodId = p3.Id;
        eap.addProduct();       
        
        eap.prodId = p4.Id;
        eap.addProduct();       
                        
        LineItem__c[] liL = UtilityLineItemIntegration.getLineItemsByOppId(o.Id);
        Map<String, LineItem__c> p2LiMap = new Map<String, LineItem__c>();
        Map<Id, Product2> pMap = new Map<Id, Product2>(pL);
        for(LineItem__c l : liL) {
            p2LiMap.put(pMap.get(l.Product__c).Name, l);
        }
        
        Test.StopTest();
                
        System.debug('Assertion 1 - Li1 ha Li2 e Li4 come contending. Li3 escluso in quanto explicitlyTargeted__c = true');
        System.debug('URL: /apex/ContendingCPM?id=' + p2LiMap.get('P1').Id);
        Test.setCurrentPage(new PageReference('/apex/ContendingCPM?id=' + p2LiMap.get('P1').Id));
        ControllerContendingCPM ctrl = new ControllerContendingCPM();
        System.assertEquals(2, ctrl.contendingLineItems.size());    
        System.assertEquals(true, p2LiMap.get('P2').Id == ctrl.contendingLineItems[0].Id || p2LiMap.get('P2').Id == ctrl.contendingLineItems[1].Id);    
        System.assertEquals(true, p2LiMap.get('P4').Id == ctrl.contendingLineItems[0].Id || p2LiMap.get('P4').Id == ctrl.contendingLineItems[1].Id);    

        System.debug('Assertion 2 - Li2 ha Li1 come contending. Gli altri figli non sono in conflitto');
        System.debug('URL: /apex/ContendingCPM?id=' + p2LiMap.get('P2').Id);
        Test.setCurrentPage(new PageReference('/apex/ContendingCPM?id=' + p2LiMap.get('P2').Id));
        ctrl = new ControllerContendingCPM();
        System.assertEquals(1, ctrl.contendingLineItems.size());
        System.assertEquals(true, p2LiMap.get('P1').Id == ctrl.contendingLineItems[0].Id);  

        System.debug('Assertion 3 - Li3 non ha nessuno come contending, in quanto explicitlyTargeted__c = true');
        System.debug('URL: /apex/ContendingCPM?id=' + p2LiMap.get('P3').Id);
        Test.setCurrentPage(new PageReference('/apex/ContendingCPM?id=' + p2LiMap.get('P3').Id));
        ctrl = new ControllerContendingCPM();
        System.assertEquals(true, ctrl.contendingLineItems.isEmpty());

        System.debug('Assertion 4 - Li4 ha Li1 come contending. Check multisize');
        System.debug('URL: /apex/ContendingCPM?id=' + p2LiMap.get('P4').Id);
        Test.setCurrentPage(new PageReference('/apex/ContendingCPM?id=' + p2LiMap.get('P4').Id));
        ctrl = new ControllerContendingCPM();
        System.assertEquals(1, ctrl.contendingLineItems.size());
        System.assertEquals(true, p2LiMap.get('P1').Id == ctrl.contendingLineItems[0].Id);  
        
        //TODO -> TESTARE LINEITEMS CON ESCLUSIONI

        System.debug('Testing back method');
        ctrl.back();
    }
}