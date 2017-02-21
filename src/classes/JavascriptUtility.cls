global class JavascriptUtility {
	
	webservice static void skipBeforeDeleteTicket_RowTrigger() // you can pass parameters
    { 
         UtilSkipTrigger.skipBeforeDeleteTicket_RowTrigger = true;

    }
	
	webservice static String setDraftTicket(String ticketID){
		String code = ticketID;
		Ticket_Fatturazione__c[] tfList = [select id from Ticket_Fatturazione__c where id = :code];
		for(Ticket_Fatturazione__c tf : tfList){
                tf.Stato__c = 'Draft';
                tf.Cliente_Inviato__c = false;
                tf.Testata_inviata__c = false;
		}
		Riga_Fatturazione__c[] righe = [select id,stato__C from Riga_Fatturazione__c where Ticket_Fatturazione__c in :tfList];
		for(Riga_Fatturazione__c r : righe){
            r.Stato__c = 'Draft';
		}
		list<Spaccato_Riga_Fatturazione__c> ss = [SELECT Id, Stato__c FROM Spaccato_Riga_Fatturazione__c WHERE Riga_Fatturazione__c IN : righe];
		for(Spaccato_Riga_Fatturazione__c s : ss){
    		s.stato__c = 'Draft';
		}
		UtilSkipTrigger.skipBeforeDeleteTicket_RowTrigger = true;
		try{
			update ss;
			update righe;
			update tfList;
		}catch (DmlException  e){
			code=e.getMessage();
		}	
		return 'ticket trovato= '+tfList.size();
	}
}