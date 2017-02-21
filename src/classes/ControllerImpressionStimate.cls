public class ControllerImpressionStimate{
    public id prodId {get;set;}
    public list<product> products {get;set;}

    public class product{
        public boolean checked {get;set;}
        public product2 prod {get;set;}
    }

    public ControllerImpressionStimate() {
        products = new list<product>();
        prodname = '';
        deliveryModel = 'CPD';
    }
    
    public string prodname {get;set;}
    public list<selectOption> famiglie {get{return getItems(Product2.family);}}
    public string family {get;set;}
    public list<selectOption> sizes {get{return getItems(Product2.size__c);}}
    public string size {get;set;}
    public list<selectOption> deliveryModels {get{return getItems(Product2.delivery_model__c);}}
    public string deliveryModel {get;set;}    
    public list<selectOption> formati {get{return getItems(Product2.formato__c);}}
    public string formato {get;set;}    
    public list<selectOption> canali_primari {get{return getItems(Product2.canale_primario__c);}}
    public string canale_primario {get;set;}    
    public list<selectOption> fasce {get{return getItems(Product2.fascia_oraria__c);}}
    public string fascia {get;set;}            
    
    public integer impressions_stimate {get;set;}
    
    
    public List<selectOption> getItems(Schema.sObjectField field){
       List<SelectOption> options = new List<SelectOption>();
    
       Schema.DescribeFieldResult fieldResult = field.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         
       options.add(new SelectOption('',''));
       for( Schema.PicklistEntry f : ple){
          options.add(new SelectOption(f.getValue(),f.getLabel()));
       }
       return options;
    }    
    
    
    public void updateProd(){
        formato = '';
        canale_primario = '';
    }
    
    public void search(){
        string query = 'select id,name,formato__c,canale_primario__c,fascia_oraria__c,family,description,type__c,Impressions_stimate__c,Delivery_Model__c,size__c,RecordTypeId, '+
                       '    (select id from Inventory_Target__r),(select id from PlacementTargeting__r)'+
                       'from product2 where name like \'%'+prodname+'%\'';
       
        if(notVoid(deliveryModel)){
            query += 'and Delivery_Model__c = \''+ deliveryModel +'\'';
        }
        
        if(notVoid(family)){
            query += 'and family = \''+ family +'\'';
        }
        if(notVoid(size)){
            query += 'and size__c = \''+ size +'\'';
        }
        
        if(notVoid(formato)){
            query += 'and formato__c = \''+ formato +'\'';
        }
        
        if(notVoid(canale_primario)){
            query += 'and canale_primario__c = \''+ canale_primario +'\'';
        }
        
        if(notVoid(fascia)){
            query += 'and fascia_oraria__c = \''+ fascia +'\'';
        }
        
        products = new list<product>();
        for(product2 p : Database.query(query)){
            product pp = new product();
            pp.checked = true;
            pp.prod = p;
            products.add(pp);
        }
    }
    
    
    public boolean notVoid(String s){
        return s != null  && s != '';
    }
    
    public void saveImpressionsStimate(){
        list<product2> prodToUpdate = new list<product2>();
        for(Product p : products){
            if(p.checked){
                p.prod.impressions_stimate__c = impressions_stimate;
                prodToUpdate.add(p.prod);
            }
        }
        update prodToUpdate;
    
    }
    
    public static testMethod void testControllerImpressionStimate(){
        Product2 p = new Product2(name='test',delivery_model__c = 'CPD',type__c='SPONSORSHIP',formato__c='test',size__c='test',canale_primario__c='test',fascia_oraria__c='test');
        insert p;
        ControllerImpressionStimate ControllerImpressionStimate = new ControllerImpressionStimate();
        ControllerImpressionStimate.formato='test';
        ControllerImpressionStimate.size='test';
        ControllerImpressionStimate.canale_primario='test';
        ControllerImpressionStimate.fascia='test';
        ControllerImpressionStimate.impressions_stimate = 100000;
        ControllerImpressionStimate.search();
        ControllerImpressionStimate.saveImpressionsStimate();
        p = [select impressions_stimate__c from product2 where id =: p.id];
        system.assertEquals(100000,p.impressions_stimate__c);
        ControllerImpressionStimate.updateProd();
    }
    
}