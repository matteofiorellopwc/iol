/**
 *  Date:   2013/02/18
 *  Description:    Extension controller for remove Ticket ID from Rev Apps
 *  Author: Ivano Cortese
 */
public class ExtensionEditTicket {
    private Ticket_Fatturazione__c t;
    ApexPages.StandardController controller;
    
    public Boolean exclude {get;set;}
    public List<tableItem> table {get;set;}

    public ExtensionEditTicket(ApexPages.StandardController controller) {
        t = (Ticket_Fatturazione__c) controller.getRecord();
        this.controller = controller;
        List<Revenue_application__c> RAs = [SELECT Id, Name, Mese__c, Anno__c, Percentuale_applicata__c, Valore__c, Ticket_Fatturazione__c,
                                                                Ticket_Fatturazione__r.Opportunity__r.Escludi_da_fatt_auto__c,line_item__r.nome_dfp__c
                                                                FROM Revenue_application__c
                                                                WHERE Ticket_Fatturazione__c = :t.Id];
        
        if(RAs.size() > 0)
            exclude = RAs.get(0).Ticket_Fatturazione__r.Opportunity__r.Escludi_da_fatt_auto__c;
        else
            exclude = false;
        
        table = new List<tableItem>();
        for(Revenue_application__c r : RAs){
            tableItem item = new tableItem();
            item.ra = r;
            table.add(item);
        }
    }
    
    public PageReference delRaRef(){
        List<Revenue_application__c> raToUpdate = new List<Revenue_application__c>();
        for(tableItem i : table){
            if(i.sel){
                i.ra.Ticket_Fatturazione__c = null;
                raToUpdate.add(i.ra);
            }   
        }
        update raToUpdate;
        return controller.view();
    }
    
    public class tableItem{
        public Boolean sel {get;set;}
        public Revenue_application__c ra {get;set;}
    }
}