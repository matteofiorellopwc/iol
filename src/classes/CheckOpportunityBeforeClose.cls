global class CheckOpportunityBeforeClose implements Database.Batchable<sObject>{

    public set<id> ids;
    
    public CheckOpportunityBeforeClose(set<id> ids){
        this.ids = ids;
    }

    global Iterable<sObject> start(Database.BatchableContext BC){
        return [select id from opportunity where id in : ids];
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        list<opportunity> oppsToUpdate = new list<opportunity>();
        for(sObject obj : scope){
            Opportunity o = (Opportunity) obj;
            //controllo eventuali conflitti
            o.status__c = 'CHIUSA';
            oppsToUpdate.add(o);
        }
        update oppsToUpdate;
    }
    
    global void finish(Database.BatchableContext BC){

    }
    
    public static testMethod void testMethodCheckOpportunityBeforeClose(){
        Opportunity o = new Opportunity(stagename='test',name='test',closeDate=date.today());
        insert o;
        Database.executeBatch(new CheckOpportunityBeforeClose(new set<id>{o.id}),1);
    }
    
}