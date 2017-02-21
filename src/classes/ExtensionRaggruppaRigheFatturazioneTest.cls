@isTest
private class ExtensionRaggruppaRigheFatturazioneTest {
	
	@isTest static void ExtensionRaggruppaRigheFatturazioneTest() {
		Ticket_Fatturazione__c t = new Ticket_Fatturazione__c();
		insert t;
		Riga_Fatturazione__c r = new Riga_Fatturazione__c(Ticket_Fatturazione__c=t.id,Numero_riga__c = 2);
		insert r;
		r = new Riga_Fatturazione__c(Ticket_Fatturazione__c=t.id,Numero_riga__c = 1);
		insert r;


		ApexPages.StandardSetController contr = new ApexPages.StandardSetController(new Riga_Fatturazione__c[]{r});
		contr.setSelected(new Riga_Fatturazione__c[]{r});

		ExtensionRaggruppaRigheFatturazione ext = new ExtensionRaggruppaRigheFatturazione(contr);		

		ext.customSave();
	}
	
}