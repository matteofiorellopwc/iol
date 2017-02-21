global class ControllerHistoryTrackingRicavoTempEmail {
    
    public String opportunityId {
        get;
        set;
    }
    public Datetime dataUltimaRiapertura {
        get;
        set;
    }
    
    public string test{
        get{ init();return''; }
        set;
    }
    
    private Boolean opportunityIdSet = false;
    private Boolean dataUltimaRiaperturaSet = false;
    public Map<String,String> lineItemsModificati {get;set;} //Map<LineItemId,LineItemName>
    public Map<String,List<Ricavo>> ricaviModificati {get;set;} //Map<LineItemId,List<Ricavo>>
    
    public void init(){
         
        lineItemsModificati = new Map<String,String>();
        ricaviModificati = new Map<String,List<Ricavo>>();
        Datetime d = dataUltimaRiapertura;
        Datetime dataRilascio = Datetime.newInstance(2014,08,04,15,0,0);
        if(d==null){
            d = Date.newInstance(1980, 1, 1);
        }
        if(d < dataRilascio){
            d = dataRilascio;
        }
        for(Ricavo__History ricavoHistory : 
                                            [SELECT 
                                                CreatedBy.Name,
                                                CreatedDate,
                                                Field,
                                                IsDeleted,
                                                NewValue,
                                                OldValue,
                                                Parent.Id,
                                                Parent.Name,
                                                Parent.Line_Item__r.Id,
                                                Parent.Line_Item__r.Name,
                                                Parent.Anno__c,
                                                Parent.Mese__c,
                                                Parent.Valore__c 
                                            FROM Ricavo__History
                                            WHERE CreatedDate >= :d 
                                            AND (Field = 'Modificato__c' OR  Parent.Modificato__c = TRUE)
                                            AND Parent.Line_Item__r.Opportunity__r.Id = :opportunityId
                                            AND Parent.Mese__c <> 'Totale'
                                            ORDER BY CreatedDate ASC]){
                                            
            Ricavo r = new Ricavo();
            r.ricavoId = ricavoHistory.Parent.Id;
            r.ricavoName = ricavoHistory.Parent.Name;
            r.authorName = ricavoHistory.CreatedBy.Name;
            r.createdDate = ricavoHistory.CreatedDate;
            r.field = ricavoHistory.Field;
            r.deleted = ricavoHistory.IsDeleted;
            r.valore = String.valueOf(ricavoHistory.Parent.Valore__c);
            if(ricavoHistory.NewValue != null){
                r.newValue = String.valueOf(ricavoHistory.NewValue);
            }else{
                r.newValue = '';
            }
            if(ricavoHistory.OldValue != null){
                r.oldValue = String.valueOf(ricavoHistory.OldValue);
            }else{
                r.oldValue = '';
            }
            r.anno = ricavoHistory.Parent.Anno__c;
            r.mese = ricavoHistory.Parent.Mese__c;
            
            String lineItemId = ricavoHistory.Parent.Line_Item__r.Id;
            String lineItemName = ricavoHistory.Parent.Line_Item__r.Name; 
            
            if(lineItemsModificati.get(lineItemId) == null){
                lineItemsModificati.put(lineItemId,lineItemName);
            }   
            if(ricaviModificati.get(lineItemId) == null){
                ricaviModificati.put(lineItemId,new List<Ricavo>());
            }
            if(r.getEditedField() != 'Modificato'){
                ricaviModificati.get(lineItemId).add(r);                
            }

        }
    }
    
    public class Ricavo{
        public String authorName {get;set;}
        public String ricavoName {get;set;}
        public String ricavoId {get;set;}
        public Boolean deleted {get;set;}
        public Datetime createdDate {get;set;}
        public String field {get;set;}
        public String oldValue {get;set;}
        //public String newValue {get;set;}
        
        public String newValue {
            get{
                return field == 'created' ? valore : newValue;
            }
            set;
        }
        
        public String anno {get;set;}
        public String mese {get;set;}
        public String valore {get;set;}
        
        public String getDataModifica(){
            return createdDate.format('dd/MM/yyyy HH:mm:ss');
        }
        
        public String getEditedField(){
            return field == 'created' ? '' : field.replace('__c','');
        }
        
        public String getStato(){
            String s = 'Ricavo ';
            if(deleted){
                s += 'cancellato';
            }else{
                if(field == 'created'){
                    s += 'creato';
                }else{
                    s += 'modificato';
                }
            }
            return s;
        }
    }
}