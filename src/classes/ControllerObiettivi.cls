public class ControllerObiettivi {
/*
    sobject obb;
    public ControllerObiettivi(ApexPages.StandardController controller) {
        obb = controller.getRecord();
        obb.put('Obiettivo__c',true);
    }
    
    public list<selectOption> categorie {get{return getItems(Product2.categoria_libero__c);}}
    public list<selectOption> settori {get{return getItems(Account.settore__c);}}
    
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
    
    public PageReference customSave(){
        set<string> fields = new set<string>{'Venditore_obiettivo__c','Centro_Media_obiettivo__c','Categoria_Libero_obiettivo__c',
                                             'Canale_di_vendita_obiettivo__c','Agenzia_territoriale_obiettivo__c','Cliente_obiettivo__c','Market_obiettivo__c','Forecast_Classe_Prodotto_obiettivo__c'};
        string tipo = (string) obb.get('Tipo_obiettivo__c');
        tipo = tipo.replace(' ','_')+'_obiettivo__c';
        if(isblank((string)obb.get(tipo))){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Inserire un valore per il campo ' + (string) obb.get('Tipo_obiettivo__c') + ' obiettivo'));
            return null;
        }
        fields.remove(tipo);
        for(string s : fields){
            obb.put(s,null);
        }
        upsert obb;
        return page.obiettivi;
    }
    
    public pagereference customCancel(){
        return page.obiettivi;
    }
    
    public boolean isBlank(string s){
        return s == '' || s == null;
    }


    public revenue_application__c editObiettivo {get;set;}
    public integer rowLimit {get;set;}
    public list<revenue_application__c> obiettivi {
        get{
            string q = 'Select Valore__c,Mese__c,Anno__c,  Tipo_obiettivo__c, '+
                       '    Venditore_obiettivo__c,Forecast_Classe_Prodotto_obiettivo__c,  '+
                       '    Centro_Media_obiettivo__c, Categoria_Libero_obiettivo__c, Canale_di_vendita_obiettivo__c, '+
                       '    Agenzia_territoriale_obiettivo__c,market_obiettivo__c,cliente_obiettivo__c,'+
                       '    Venditore_formula__c,'+
                       '    Centro_Media_formula__c, Categoria_Libero_formula__c, Canale_di_vendita_formula__c, '+
                       '    Sotto_Classe_formula__c,Sotto_Classe_obiettivo__c,Forecast_Classe_Prodotto_formula__c,' +
                       '    Agenzia_territoriale_formula__c,market_formula__c,Cliente_formula__c '+
                       ' From Revenue_application__c'+
                       ' where obiettivo__c = true';
            
            if(ra.anno__c != null){
                q += ' and anno__c = \''+ra.anno__c+'\'';
            }
            if(ra.mese__c != null){
                q += ' and mese__c = \''+ra.mese__c+'\'';
            }
            if(ra.tipo_obiettivo__c != null){
                q += ' and tipo_obiettivo__c = \''+ra.tipo_obiettivo__c+'\'';
            }                        
            
            q += ' order by data_primo_mese__c LIMIT '+rowLimit;
            return Database.query(q);    
        }
        set;
    }    
    
    public revenue_application__c ra {get;set;}
    public ControllerObiettivi(){
        ra = new revenue_application__c();
        rowLimit = 20;
    }
    
    public pagereference nuovoObiettivo(){
        return new pageReference('/apex/obiettivo');
    }
    
    public static testMethod void testControllerObiettivi(){
        ControllerObiettivi co = new ControllerObiettivi(new ApexPages.StandardController(new revenue_application__c()));
        co.obb.put('Tipo_obiettivo__c','Canale_di_vendita');
        co.customSave();
        co.obb.put('Canale_di_vendita_obiettivo__c','CM');
        co.customSave();
        
        co.customCancel();

        co.nuovoObiettivo();
        co = new ControllerObiettivi();
        co.ra.anno__c = '2012';
        co.ra.mese__c = 'Dicembre';
        co.ra.tipo_obiettivo__c = 'Cliente_obiettivo__c';
        list<revenue_application__c> obiettivi = co.obiettivi;
        list<selectOption> categorie = co.categorie;
        list<selectOption> settori = co.settori;
    }
*/
}