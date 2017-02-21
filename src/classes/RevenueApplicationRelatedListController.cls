public class RevenueApplicationRelatedListController {
	public Id idLI {get; set;}
	public List<Revenue_Application__c> listRA {get; set;}

	public RevenueApplicationRelatedListController() {
		listRA = new List<Revenue_Application__c>();
		idLI = Id.valueOf(ApexPages.currentPage().getParameters().get('id'));
		System.Debug('PuntoDebug - idLI: '+idLI);
		getRecords();
	}

	public void getRecords() {
		listRA = [SELECT Id, Name, Mese__c, Anno__c, ADXPlacementUpdated__c FROM Revenue_Application__c WHERE Line_Item__c = :idLI AND Mese__c != 'Totale'];
		System.Debug('PuntoDebug - listRA: '+listRA);
	}

	public void saveRecords() {
		try {
			update listRA;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Operazione effettuata con successo'));
		} catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Non è stato possibile eseguire l\'operazione. '+ex.getMessage()+' - '+ex.getStackTraceString()));
		}
	}
}