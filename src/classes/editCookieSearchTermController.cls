/*
    Controller for EditCookieSearchTerm.page
    Manage cookies and search terms targeting for product and line item
*/

public class editCookieSearchTermController {

    public String sobjectName{get;set;} //LineItem__c or Product__c
    public String id {get;set;} //sobjectName id
    public String editable {get;set;} //'true' or 'false'
    
    /*
        Class for list of cookies and search terms to choose
    */
    public class csTargeted{
        public CookieSearchTermOas__c cs {get;set;}
        public boolean selected {get;set;}
        public csTargeted(CookieSearchTermOas__c cs, boolean selected){
            this.cs = cs;
            this.selected = selected;
        }
    }

    public Map<string,CookieSearchOasTargeted__c> csT {get;set;} //oasfield+categoria => CookieSearchOasTargeted__c
    public String csTKeySet {
                                get{
                                    string[] s = new string[]{};
                                    s.addAll(csT.keySet());
                                    return string.join(s,',');
                                }
                            }
    public Map<string,list<csTargeted>> csMap {get;set;} //oasfield+categoria => list csTargeted
    
    /*
        Inizialize maps to show categories, cookie and search term (CST) saved
    */
    public editCookieSearchTermController(){
    
        //get parameters
        this.id = ApexPages.CurrentPage().getParameters().get('id');
        this.sobjectName = ApexPages.CurrentPage().getParameters().get('sobjectName');
        this.editable = ApexPages.CurrentPage().getParameters().get('editable');
        
        if(id == null || sobjectName == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Errore nei parametri della pagina'));
            return;
        }
        
        
        //All CST available
        csT = new Map<string,CookieSearchOasTargeted__c>();
        for(CookieSearchOasTargeted__c csot : [select Id,Categoria__c,Names__c,LineItem__c,
                                                      Oas_field__c,Product__c,Values__c 
                                               from CookieSearchOasTargeted__c
                                               where LineItem__c =: id
                                               or Product__c =: id 
                                              ]){
            csot.names__c = csot.names__c.replace('__\n','<br />'); //to show in page
            csT.put(csot.Oas_field__c+'_'+csot.categoria__c,csot); //oasfield+categoria
        }
        
        //All CST targeted group by category
        csMap = new Map<string,list<csTargeted>>();
        
        for(CookieSearchTermOas__c cs : [select id,name,Categoria__c,Oas_Field__c,Value__c from CookieSearchTermOas__c order by Oas_Field__c]){
            string key = cs.Oas_Field__c+'_'+cs.Categoria__c;
            if(csMap.get(key) == null){
                csMap.put(key,new list<csTargeted>());
            }
            
            boolean selected = csT.get(key) != null && csT.get(key).values__c.indexOf(cs.value__c) > -1;
            csMap.get(key).add(new csTargeted(cs,selected));
        }
    }
    
    public string editCS {get;set;} // oasfield+categoria 
    public string operation {get;set;} //edit or reset
    
    public void editCookieSearch(){
        operation = 'edit';
    }
    
    //Remove all CST targeted for selected category
    public void resetCookieSearch(){
        operation = 'reset';
        for(csTargeted c : csMap.get(editCs)){ c.selected = false; }
        delete csT.remove(editCs);
        editCs = null;
    }
    
    public void deleteCookieSearch(){
        operation = 'delete';
    }
    
    
    /*
        Save CST targetd for selected cagegory.
        It's saved a record for each category, all values are stored in a text field
    */
    public void customSave(){
        CookieSearchOasTargeted__c csot = csT.get(editCs) != null ? csT.get(editCs) : new CookieSearchOasTargeted__c();
        
        string[] names = new string[]{};
        string[] values = new string[]{};
        
        for(csTargeted cst : csMap.get(editCs)) {
            if(cst.selected){
                names.add(cst.cs.name);
                values.add(cst.cs.value__c);
            }
        }
        if(names.size() > 0){
            csot.names__c = string.join(names,'__\n');
            csot.values__c = string.join(values,'__\n');
            csot.categoria__c = editCs.split('_')[1];
            csot.oas_field__c = editCs.split('_')[0];
            csot.put(sobjectName,id);
            upsert csot;
            csot.names__c = csot.names__c.replace('__\n','<br />');  //for showing correctly in page
            csT.put(editCs,csot);
        }else{
            if(csT.get(editCs) != null){
                delete csT.remove(editCs);
            }
        }
        
        editCs = null;
    }
    
    
    
    public static testMethod void testeditCookieSearchTermController(){
        Product2 prod = new Product2(Name = 'Test Product',BasePrice__c = 0.1110,Breakeven_cost__c = 0.1000);
        insert prod;
        
        editCookieSearchTermController c = new editCookieSearchTermController();
        
        ApexPages.CurrentPage().getParameters().put('id',prod.id);
        ApexPages.CurrentPage().getParameters().put('sobjectName','Product__c');
        ApexPages.CurrentPage().getParameters().put('editable','true');
        
        CookieSearchTermOas__c cs = new CookieSearchTermOas__c(categoria__c = 'GEO - Province', Oas_field__c  = 'Cookie Targeting',value__c='test');
        insert cs;
        
        c = new editCookieSearchTermController();
        
        c.editCookieSearch();
        
        c.editCs = 'Cookie Targeting_GEO - Province';
        c.csMap.get(c.editCs).get(0).selected = true;
        
        c.customSave();
        
        string s = c.csTKeySet;
        
        c = new editCookieSearchTermController();
        
        c.editCs = 'Cookie Targeting_GEO - Province';
        c.deleteCookieSearch();
        c.resetCookieSearch();
        
    }
    
    
}