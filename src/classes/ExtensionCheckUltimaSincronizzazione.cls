public class ExtensionCheckUltimaSincronizzazione {
    private Opportunity opp;
    private List<LineItem__c> lineItems;
            
    public String statoSincronizzazione {get;set;}
    public Boolean isSynchronized {get;set;}

    public ExtensionCheckUltimaSincronizzazione(ApexPages.StandardController controller) {
        this.opp = [SELECT Id, Id_DFP__c, LastModifiedDate, Ultima_sincronizzazione_DFP__c FROM Opportunity WHERE Id = :controller.getId()];
        
        this.lineItems = [SELECT
            LastModifiedDate,
            (SELECT LastModifiedDate FROM AppliedLabel__r ORDER BY LastModifiedDate DESC),
            (SELECT LastModifiedDate FROM Technology_Targeting__r ORDER BY LastModifiedDate DESC),
            (SELECT LastModifiedDate FROM PlacementTargeting__r ORDER BY LastModifiedDate DESC),
            (SELECT LastModifiedDate FROM Inventory_Target__r ORDER BY LastModifiedDate DESC),
            (SELECT LastModifiedDate FROM Frequency_Caps__r ORDER BY LastModifiedDate DESC),
            (SELECT LastModifiedDate FROM Day_Part_Targeting__r ORDER BY LastModifiedDate DESC),
            (SELECT LastModifiedDate FROM Custom_Criteria_Set__r ORDER BY LastModifiedDate DESC)
            //(SELECT LastModifiedDate FROM Geography__r ORDER BY LastModifiedDate DESC),
            //(SELECT LastModifiedDate FROM UserDomains__r ORDER BY LastModifiedDate DESC)
            FROM LineItem__c WHERE Opportunity__c = :opp.Id all rows             
        ];
        
        System.debug(this.lineItems.size());
        System.debug(this.lineItems);                                  
    }    
    
    public PageReference init() {
        if(opp.id_dfp__c == null) {
            statoSincronizzazione = 'Campagna mai sincronizzata';
            isSynchronized = false;
            return null;
        }
                
        DateTime t0 = opp.Ultima_sincronizzazione_DFP__c;       
        setSynchronized(opp.LastModifiedDate <= t0);        
        if(!isSynchronized) return null;
                                
        for(LineItem__c l : lineItems) {
            setSynchronized(l.LastModifiedDate <= t0);      
            if(!isSynchronized) return null;
            
            if(l.AppliedLabel__r.size() > 0) {
                setSynchronized(l.AppliedLabel__r.get(0).LastModifiedDate <= t0);       
                if(!isSynchronized) return null;            
            }
                        
            if(l.Technology_Targeting__r.size() > 0) {
                setSynchronized(l.Technology_Targeting__r.get(0).LastModifiedDate <= t0);       
                if(!isSynchronized) return null;            
            }
                        
            if(l.PlacementTargeting__r.size() > 0) {
                setSynchronized(l.PlacementTargeting__r.get(0).LastModifiedDate <= t0);     
                if(!isSynchronized) return null;            
            }
                        
            if(l.Inventory_Target__r.size() > 0) {
                setSynchronized(l.Inventory_Target__r.get(0).LastModifiedDate <= t0);       
                if(!isSynchronized) return null;            
            }
                        
            if(l.Frequency_Caps__r.size() > 0) {
                setSynchronized(l.Frequency_Caps__r.get(0).LastModifiedDate <= t0);     
                if(!isSynchronized) return null;            
            }
                        
            if(l.Day_Part_Targeting__r.size() > 0) {
                setSynchronized(l.Day_Part_Targeting__r.get(0).LastModifiedDate <= t0);     
                if(!isSynchronized) return null;            
            }
                        
            if(l.Custom_Criteria_Set__r.size() > 0) {
                setSynchronized(l.Custom_Criteria_Set__r.get(0).LastModifiedDate <= t0);        
                if(!isSynchronized) return null;            
            }
/*
            if(l.Geography__r.size() > 0) {
                setSynchronized(l.Geography__r.get(0).LastModifiedDate <= t0);        
                if(!isSynchronized) return null;            
            }

            if(l.UserDomains__r.size() > 0) {
                setSynchronized(l.UserDomains__r.get(0).LastModifiedDate <= t0);        
                if(!isSynchronized) return null;            
            }
*/                        
        }       
        return null;    
    }
    
    public void setSynchronized(Boolean isSynchronized) {
        this.isSynchronized = isSynchronized;
        this.statoSincronizzazione = isSynchronized ? 'Campagna aggiornata con DFP' : 'Campagna non aggiornata con DFP';
    }
}