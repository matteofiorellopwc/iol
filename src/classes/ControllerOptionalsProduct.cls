public class ControllerOptionalsProduct {
    
    public String id {get;set;}
    public integer indexToDelete {get;set;}

    public List<Optional__c> optionals {get;set;}
    List<Optional__c> optionalsToDelete;
    
    public ControllerOptionalsProduct(){
        this.id = ApexPages.CurrentPage().getParameters().get('id');
        this.init();
        
    }
    
    public Pagereference customSave(){
        insert optionals;
        delete optionalsToDelete;
        this.init();
        Pagereference p = new PageReference('/apex/editOptionalsProductComponent?id=' + id + '&editMode=false');
        p.setRedirect(true);
        return p;
    }
    
    public void addOptional(){
        optional__c o = new optional__c();
        o.product__c = id;
        optionals.add(o);
    }
    
    public void deleteOptional(){
        optionals.remove(indexToDelete);
    } 
    
    private void init(){
        optionalsToDelete = [select id,incremento__c,Product__c,Quantita__c,Tipo__c,Incremento_calcolato_prodotto__c from optional__c where product__c =: id];
        optionals = new List<optional__c>();
        for(optional__c o : optionalsToDelete){
            optionals.add(o.clone());
        }
    } 
    
    static testMethod void testController() {
        
        Product2 p = new Product2();
        p.name = 'Test';
        insert p;
        
        Opportunity o = new Opportunity();
        //Name, StageName, CloseDate
        o.name = 'Opportunity Test';
        o.stageName = 'Open';
        o.closeDate = date.today();
        insert o; 
        
        Optional__c c = new Optional__c();
        c.incremento__c = 10;
        c.Quantita__c = 10;
        c.Product__c = p.Id;
        insert c;    
        
        LineItem__c li = new LineItem__c();
        li.Product__c = p.Id;
        li.opportunity__c = o.id;
        insert li;
        
        ApexPages.CurrentPage().getParameters().put('id',p.id);
        
        ControllerOptionalsProduct ctt = new ControllerOptionalsProduct();
        ctt.addOptional();
        ctt.customSave();
        
        ctt.indexToDelete = 0;
        ctt.deleteOptional();
        
       

     }   
    
}