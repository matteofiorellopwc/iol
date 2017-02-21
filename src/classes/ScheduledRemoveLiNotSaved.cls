public class ScheduledRemoveLiNotSaved implements Schedulable {    
    //System.schedule('ScheduledRemoveLiNotSaved', '0 0 4 * * ?', new ScheduledRemoveLiNotSaved());

    /*
        Tutte le notti cancello i LI che per qualche motivo non sono stati salvati correttamente
        Sono solo casi particolari, normalmente se si esce senza salvare si cancella il LI
    */
    
    public void execute(SchedulableContext SC) {
        list<lineitem__c> liNotSaved = [select id,id_dfp__c,stato_lavorazione_oas__c from LineItem__c where personalizzato__c = false];
        list<lineitem__c> liToDelete = new list<lineitem__c>();
        list<string> liToLog = new list<string>();
        
        for(lineitem__c li : liNotSaved){
            if(li.id_dfp__c == null && ! (new set<string>{'In Lavorazione','Sospeso','Lavorato','Da Lavorare (Creative)','Da Rilavorare'}).contains(li.stato_lavorazione_oas__c)){ //check stato lavorazione oas??
                liToDelete.add(li);
            }else{
                liToLog.add(li.id + ' id dfp = ' + li.id_dfp__c + ' stato lavorazione oas = ' + li.stato_lavorazione_oas__c);
            }
        }
        
        delete liToDelete;
        if(liToLog.size() > 0){
          UtilExceptionIntegration.sendEmailToCustomEmailLog('Error in ScheduledRemoveLiNotSaved',string.join(liToLog,'\n\n'),'TelnextLog');
        }
    }
    
    public static testMethod void testScheduledRemoveLiNotSaved(){
        EmailLog__c el = new EmailLog__c(name='TelnextLog',emails__c='test@test.com');
        insert el;
        Opportunity o = new Opportunity(name='test',stageName='test',closeDate=date.today());
        insert o;
        LineItem__c[] lis = new LineItem__c[]{  new LineItem__c(Opportunity__c=o.id),
                                                new LineItem__c(Opportunity__c=o.id,id_dfp__c=1),
                                                new LineItem__c(Opportunity__c=o.id,stato_lavorazione_oas__c='Lavorato')
                                             };
        insert lis;
        system.assertEquals(3,[select id from lineitem__c].size());
        ScheduledRemoveLiNotSaved s = new ScheduledRemoveLiNotSaved();
        s.execute(null);
        //deve aver cancellato solo il primo
        system.assertEquals(2,[select id from lineitem__c].size());
    }
}