public class ControllerOptionalLineItem{

    public String lineItemid {get;set;}
    public List<optional> optionals {get;set;}
    lineitem__c li;
    public ControllerOptionalLineItem(){
        this.lineItemid = ApexPages.CurrentPage().getParameters().get('id');
        
        li = [select prezzo_listino__c,product__c from lineitem__c where id =: lineItemid];
        
        
        String prodId = li.product__c;
        Product2 prod = [select id,name,BasePrice__c,family,
                            (select Id,Tipo__c,Quantita__c,incremento__c,Incremento_calcolato_prodotto__c,Incremento_calcolato_lineitem__c,UniqueKey__c
                                     from Optionals__r
                                     order by tipo__c,quantita__c)
                        from product2 
                        where id =: prodId];

        set<string> optionalAlreadyChecked = new set<string>();
        
        for(Optional__c o : [select (select UniqueKey__c from optionals__r) from lineitem__c where id =: lineItemid].optionals__r){
            optionalAlreadyChecked.add(o.UniqueKey__c);
        }
                
        optionals = new list<optional>();
        for(Optional__c o : prod.optionals__r){
            Optional oo = new Optional();
            oo.checked = optionalAlreadyChecked.contains(o.UniqueKey__c);
            oo.o = o;
            oo.o.Incremento_calcolato_lineitem__c = ((o.incremento__c*li.prezzo_listino__c)/100).setScale(4,ROUNDINGMODE.HALF_UP);
            optionals.add(oo);
        }
        
        system.debug(optionals);
    }
    
    public decimal calcSumOptionals(){
    
        System.debug('**** calcSum' );
        system.debug(optionals);
        decimal Sum_optionals = 0;
        
        for(optional oClass : optionals){
            System.debug('**** calcSum' + oClass);
            if(oClass.checked){
                Sum_optionals += oClass.o.Incremento_calcolato_lineitem__c;
            }
        }
        System.debug('**** Sum_optionals = ' + Sum_optionals );
        return Sum_optionals;
    }
    
    public void customSave(){
        
    
        list<optional__c> optionalToInsert = new list<optional__c>();
        
        for(optional oClass : optionals){
            if(oClass.checked){
                optional__c oObj = oClass.o.clone();
                oObj.line_item__c = lineItemId;
                oObj.product__c = null;
                optionalToInsert.add(oObj);
            }
        }
        
        list<optional__c> optionalToDelete = [select (select UniqueKey__c from optionals__r) from lineitem__c where id =: lineItemId].optionals__r;

        insert optionalToInsert;
        delete optionalToDelete;
        
        
    }
    
    public class optional{
        public optional__c o {get;set;}
        public boolean checked {get;set;}
    }
    
    public boolean notVoid(String s){
        return s != null  && s != '';
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
        li.prezzo_listino__c = 0;
        insert li;        
        
        LineItemTriggerHandler.skipUpdateLineItem = false;
        LineItemTriggerHandler.skipValidationTotali = true;
        
        ApexPages.CurrentPage().getParameters().put('id',li.id);
        ApexPages.CurrentPage().getParameters().put('sobjectName','LineItem__c');
       
        ControllerOptionalLineItem col = new ControllerOptionalLineItem();
        col.optionals[0].checked = true;
        col.customSave(); 
        col.calcSumOptionals();
        
        //Metodi di utilita
        col.notVoid('Test');

     } 

}