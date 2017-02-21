public class ExtensionInviaTicketSelezionatiSap {
    
    public list<ticket_fatturazione__c> tickets {get;set;}
    public boolean error {get;set;}
    
    public ExtensionInviaTicketSelezionatiSap(ApexPages.StandardController controller) {
        error = false;
        if(!Test.isRunningTest()){
            controller.addFields(new list<string>{'Stato__c','name'});
        }
        tickets = new list<ticket_fatturazione__c>{(ticket_fatturazione__c) controller.getRecord()};
        if(tickets[0].Stato__c != 'Da inviare'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Lo stato del ticket ' +tickets[0].name+ ' non è "Da inviare" ma è "'+tickets[0].Stato__c+'"'));
            error = true;
        }
    }
    
    public ExtensionInviaTicketSelezionatiSap(ApexPages.StandardSetController controller) {
        error = false;
        if(!Test.isRunningTest()){
            controller.addFields(new list<string>{'Stato__c','name'});
        }
        tickets = (list<ticket_fatturazione__c>) controller.getSelected();
        for(ticket_fatturazione__c tf : tickets){
            if(tf.Stato__c != 'Da inviare'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Lo stato del ticket ' +tf.name+ ' non è "Da inviare" ma è "'+tf.Stato__c+'"'));
                error = true;
            }
        }
    }
    
    public void sendTicket(){
        if(!error){
            list<id> ids = new list<id>();
            for(ticket_fatturazione__c tf : tickets){
                ids.add(tf.id);
            }
            Database.executeBatch(new BatchableInsertTicketSap(ids),5);
        }
    }
/*    
    public static testMethod void testExtensionInviaTicketSelezionatiSap(){
        BasicAuthApplication__c cs = new BasicAuthApplication__c(name='Ticketing_Advertising',username__c='test',password__c='test',endpoint__c='test');
        insert cs;
        Id rtClienteITnetID = [SELECT Id FROM RecordType WHERE DeveloperName = 'Cliente_ItNet'].get(0).Id;
        system.debug('Rtype ID:'+rtClienteITnetID);
        Account a = new Account(Name='Test',RecordTypeId=rtClienteITnetID,Tipo_anagrafica__c='Giuridica',Ragione_sociale__c='Test s.r.l.',Partita_IVA__c='11122233345',
            BillingStreet='Via',BillingCity='Milano',BillingPostalCode='20100',BillingState='MI',BillingCountry='Italia',Stato__c='Attivo',email_principale__c ='test@test.com',Account_Accesso__c='test'
        );
        insert a;
        ticket_fatturazione__c tf = new ticket_fatturazione__c(Account__c=a.Id,stato__c='Da Inviare');
        insert tf;
        ExtensionInviaTicketSelezionatiSap ext = new ExtensionInviaTicketSelezionatiSap(new ApexPages.StandardSetController(new list<ticket_fatturazione__c>{tf}));
        ext = new ExtensionInviaTicketSelezionatiSap(new ApexPages.StandardController(tf));
        ext.sendTicket();
        tf = tf.clone();
        tf.stato__c = 'Inviato';
        insert tf;
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(new list<ticket_fatturazione__c>{tf});
        setController.setSelected(new list<ticket_fatturazione__c>{tf});
        ext = new ExtensionInviaTicketSelezionatiSap(setController);
        ext = new ExtensionInviaTicketSelezionatiSap(new ApexPages.StandardController(tf));
        ext.sendTicket();
    }*/
}